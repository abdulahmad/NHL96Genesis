#!/usr/bin/env python3
"""lineage.py: find the same routine in the earlier games' sources and carry its names and comments over.

Used by decode_code.py. The parents are read from sibling checkouts of NHL95Genesis, NHL94Genesis, NHLPA93Genesis and
NHL92Genesis (a directory next to this repo, or --parents DIR). Routines are compared by instruction shape
(mnemonic and operand kinds, not names or numbers), so a routine whose RAM names or constants changed still matches.
"""
import re, os, glob, difflib

PARENTS = ['NHL95Genesis', 'NHL94Genesis', 'NHLPA93Genesis', 'NHL92Genesis']
BR = re.compile(r'^(b(ra|sr|hi|ls|cc|cs|ne|eq|vc|vs|pl|mi|ge|lt|gt|le)|db\w+)(\.[bws])?$')
DIRECTIVES = {'dc', 'ds', 'org', 'include', 'incbin', 'even', 'equ', 'if', 'else', 'endif', 'endc', 'macro', 'endm',
              'rept', 'endr', 'section', 'rsset', 'rs', 'cnop', 'opt', 'xdef', 'xref', 'align', 'set', 'ifd', 'ifnd'}


def split_ops(t):
    out, d, cur = [], 0, ''
    for ch in t:
        if ch == '(': d += 1
        if ch == ')': d -= 1
        if ch == ',' and d == 0:
            out.append(cur); cur = ''
        else:
            cur += ch
    if cur.strip(): out.append(cur)
    return [o.strip() for o in out]


def kind_text(o, branch):
    o = o.strip()
    if re.fullmatch(r'd[0-7]', o, re.I): return 'D'
    if re.fullmatch(r'(a[0-7]|sp)', o, re.I): return 'A'
    if re.fullmatch(r'\((a[0-7]|sp)\)', o, re.I): return '(A)'
    if re.fullmatch(r'\((a[0-7]|sp)\)\+', o, re.I): return '(A)+'
    if re.fullmatch(r'-\((a[0-7]|sp)\)', o, re.I): return '-(A)'
    if o.startswith('#'): return 'I'
    if re.search(r'\(pc', o, re.I): return 'P'
    if re.search(r'\((a[0-7]|sp),\s*[da][0-7]', o, re.I): return 'd(A,X)'
    if re.search(r'\((a[0-7]|sp)\)$', o, re.I): return 'd(A)'
    if re.fullmatch(r'(d[0-7]|a[0-7])([/-](d[0-7]|a[0-7]))*', o, re.I) and ('/' in o or '-' in o): return 'R'
    if branch: return 'L'
    if re.fullmatch(r'(sr|ccr|usp)', o, re.I): return o.lower()
    return 'M'


def norm_mn(m):
    m = m.lower()
    base, _, suf = m.partition('.')
    base = {'cmpi': 'cmp', 'addq': 'add', 'addi': 'add', 'subq': 'sub', 'subi': 'sub', 'andi': 'and', 'ori': 'or',
            'eori': 'eor', 'movea': 'move', 'moveq': 'move', 'adda': 'add', 'suba': 'sub', 'cmpa': 'cmp', 'dbra': 'dbf',
            'bsr': 'call', 'jsr': 'call', 'jmp': 'jump', 'bra': 'jump', 'blo': 'bcs', 'bhs': 'bcc'}.get(base, base)
    if base in ('call', 'jump') or BR.match(m): suf = ''
    if m == 'moveq': suf = 'l'
    if suf == 's': suf = 'w'
    return base + ('.' + suf if suf else '')


def norm_text(mn, ops):
    br = bool(BR.match(mn.lower())) or mn.lower() in ('jsr', 'jmp')
    n = norm_mn(mn)
    if n in ('call', 'jump', 'jump') or br:
        return n  # operand kinds differ (label, abs, pc) between games for the same call
    return n + ' ' + ','.join(kind_text(o, br) for o in ops)


def norm_ins(ins):
    """Normalized token of a m68kdis Insn."""
    if ins.mnem == 'String': return 'String'
    mn = ins.mnem
    if ins.kind in ('jsr', 'bsr'): return 'call'
    if ins.kind in ('jmp', 'bra'): return 'jump'
    br = ins.kind in ('bcc', 'dbcc')
    if br: return norm_mn(mn)
    kinds = []
    for o in ins.ops:
        k = o[0]
        kinds.append({'dn': 'D', 'an': 'A', 'ind': '(A)', 'post': '(A)+', 'pre': '-(A)', 'disp': 'd(A)', 'idx': 'd(A,X)',
                      'absw': 'M', 'absl': 'M', 'pcd': 'P', 'pcidx': 'P', 'imm': 'I', 'reglist': 'R', 'sr': 'sr',
                      'ccr': 'ccr', 'usp': 'usp', 'target': 'L'}[k])
    return norm_mn(mn) + ' ' + ','.join(kinds)


class PLine:
    __slots__ = ('no', 'label', 'text', 'norm', 'comment', 'pre', 'mn', 'ops')


class Routine:
    def __init__(self, repo, file, name, line):
        self.repo, self.file, self.name, self.line = repo, file, name, line
        self.lines, self.header, self.norms = [], [], []


def parse_file(repo, path):
    routines, cur, pre = [], None, []
    header = []
    for no, raw in enumerate(open(path, errors='replace').read().split('\n'), 1):
        raw = raw.rstrip('\r')
        m = re.match(r'^([A-Za-z_.][\w.$]*):?(?:\s+(.*))?$', raw)
        code_part = None
        label = None
        if m and not raw.startswith(';'):
            label, rest = m.group(1), (m.group(2) or '')
            code_part = rest
        elif raw.startswith((' ', '\t')):
            code_part = raw.strip()
        elif raw.strip() == '':
            pre = []
            continue
        else:
            code_part = None
        if label and not label.startswith('.'):
            cur = Routine(repo, path, label, no)
            routines.append(cur)
            hdr = []
            if code_part and code_part.startswith(';'):
                hdr.append(code_part.lstrip(';').strip())
            cur.header = header_comments(pre) + hdr
            pre = []
            code_part = code_part if code_part and not code_part.startswith(';') else ''
        if cur is None:
            if raw.lstrip().startswith(';'): pre.append(raw.strip())
            continue
        text = (code_part or '').strip()
        if not text:
            if raw.lstrip().startswith(';') and not label:
                pre.append(raw.strip())
            continue
        if text.startswith(';'):
            if not label and vis_(raw) >= 32:
                continue
            pre.append(text)
            if label:
                pl = PLine(); pl.no, pl.label, pl.text, pl.norm, pl.comment, pl.pre, pl.mn, pl.ops = no, label, '', None, text.lstrip(';').strip(), [], None, []
                cur.lines.append(pl)
            continue
        code, _, comment = split_comment(text)
        mm = re.match(r'^(\S+)\s*(.*)$', code)
        if not mm:
            continue
        mn, opsraw = mm.group(1), mm.group(2)
        base = mn.lower().split('.')[0]
        pl = PLine()
        pl.no, pl.label, pl.text, pl.comment, pl.pre, pl.mn = no, label if label and label.startswith('.') else None, code, comment, pre, mn
        pl.ops = split_ops(opsraw)
        pre = []
        if base in DIRECTIVES or base.startswith('dc'):
            pl.norm = 'dc'
        else:
            pl.norm = norm_text(mn, pl.ops)
        cur.lines.append(pl)
    return routines


def vis_(s):
    c = 0
    for ch in s:
        if ch not in ' \t': break
        c = (c // 4 + 1) * 4 if ch == '\t' else c + 1
    return c


def header_comments(pre):
    return [p.lstrip(';').strip() for p in pre]


def split_comment(t):
    q = None
    for i, ch in enumerate(t):
        if q:
            if ch == q: q = None
        elif ch in "'\"":
            q = ch
        elif ch == ';':
            return t[:i].strip(), ';', t[i + 1:].strip()
    return t.strip(), '', ''


def load_parents(base):
    out = []
    for repo in PARENTS:
        d = os.path.join(base, repo, 'src')
        if not os.path.isdir(d): continue
        for f in sorted(glob.glob(os.path.join(d, '**', '*.asm'), recursive=True)):
            if '/macros/' in f: continue
            for r in parse_file(repo, f):
                r.norms = [l.norm for l in r.lines if l.norm and l.norm != 'dc']
                if len(r.norms) >= 3:
                    out.append(r)
    return out


def best_match(norms, parents, min_score=0.6):
    """Return list of (score, routine, matching_blocks) sorted best first (top 3)."""
    if len(norms) < 3: return []
    sm = difflib.SequenceMatcher(None, autojunk=False)
    sm.set_seq2(norms)
    res = []
    for p in parents:
        sm.set_seq1(p.norms)
        if sm.real_quick_ratio() < min_score or sm.quick_ratio() < min_score: continue
        r = sm.ratio()
        if r >= min_score:
            res.append((r, p))
    res.sort(key=lambda x: (-round(x[0], 2), PARENTS.index(x[1].repo)))
    return res[:3]


def align(norms, parent):
    """Map index in my norms -> index in the parent's instruction list (parent.lines filtered to norm != dc)."""
    plines = [l for l in parent.lines if l.norm and l.norm != 'dc']
    sm = difflib.SequenceMatcher(None, plines and [l.norm for l in plines], norms, autojunk=False)
    mp = {}
    for a, b, n in sm.get_matching_blocks():
        for k in range(n):
            mp[b + k] = plines[a + k]
    return mp


def covers(norms, parents, min_cov=0.6, min_len=6):
    """Parent routines found inside a longer instruction list. Returns [(coverage, parent, {my_index: PLine})]."""
    from collections import Counter
    mine = Counter(norms)
    out = []
    for p in parents:
        pn = p.norms
        if len(pn) < min_len: continue
        c = Counter(pn)
        inter = sum((c & mine).values())
        if inter / len(pn) < min_cov: continue
        plines = [l for l in p.lines if l.norm and l.norm != 'dc']
        sm = difflib.SequenceMatcher(None, pn, norms, autojunk=False)
        blocks = [b for b in sm.get_matching_blocks() if b.size]
        m = sum(b.size for b in blocks)
        if m / len(pn) < min_cov: continue
        mp = {}
        for a, b, n in blocks:
            if n < 4: continue
            for k in range(n):
                mp[b + k] = plines[a + k]
        if not mp: continue
        lo, hi = min(mp), max(mp)
        if hi - lo + 1 > len(pn) * 1.6: continue
        out.append((m / len(pn), p, mp, plines))
    return out
