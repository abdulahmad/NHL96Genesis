#!/usr/bin/env python3
"""check_code_as_data_x86.py: flag x86 code that the NASM sources of the PC ports still keep as data (db/dw/dd).

  python3 tools/check_code_as_data_x86.py REPO_DIR [--heuristic] [--bits 32|16] [--min 10] [--verbose]

Default check (exact): a label defined under REPO_DIR/src/**/data/ (the data files) that code calls or jumps to
(call/jmp/jcc/loop LABEL) is code kept as data. Exit status 1 when there is one.
--heuristic (noisy, for a human to read): joins the db/dw/dd/times lines under each label into one byte string and
decodes it as x86 (capstone); a label is listed when at least --min instructions decode cleanly and end in
ret/retf/iret/jmp inside the label's bytes. Lookup tables decode too, so expect false positives (key maps, remap and
sine tables); the exact check is the one to run in CI. NHL 94 PC is 16-bit (--bits 16, the default for a repo named
*94*), the others are 32-bit. The heuristic needs `pip install capstone`.
Known false positives for the heuristic go in tools/code_as_data_x86_ok.txt as `label` lines (comment after #).
"""
import re, sys, os, glob, argparse

TERM = {'ret', 'retf', 'retn', 'iret', 'iretd', 'jmp'}


def num(t):
    t = t.strip()
    if re.fullmatch(r'0[xX][0-9a-fA-F]+', t): return int(t, 16)
    if re.fullmatch(r'[0-9][0-9A-Fa-f]*[hH]', t): return int(t[:-1], 16)
    if re.fullmatch(r'-?\d+', t): return int(t)
    raise ValueError(t)


def items(text):
    """Split a db/dw/dd operand list at commas outside quotes."""
    out, cur, q = [], '', None
    for ch in text:
        if q:
            cur += ch
            if ch == q: q = None
        elif ch in '\'"': q = ch; cur += ch
        elif ch == ',': out.append(cur.strip()); cur = ''
        else: cur += ch
    if cur.strip(): out.append(cur.strip())
    return out


def blocks(path):
    """[(label, line, bytes)] for labels followed only by data lines."""
    res, cur = [], None
    for i, l in enumerate(open(path, errors='replace').read().split('\n'), 1):
        l = l.rstrip('\r')
        m = re.match(r'^([A-Za-z_.@$][\w.@$]*):', l)
        if m:
            cur = [m.group(1), i, bytearray(), True]; res.append(cur)
            continue
        if cur is None: continue
        mm = re.match(r'^\s+(?:times\s+(\d+)\s+)?(db|dw|dd)\s+(.*?)\s*(;.*)?$', l, re.I)
        if not mm:
            if re.match(r'^\s+\S', l) and not l.strip().startswith(';'): cur[3] = False
            continue
        rep, k, ops = int(mm.group(1) or 1), mm.group(2).lower(), mm.group(3)
        w = {'db': 1, 'dw': 2, 'dd': 4}[k]
        b = bytearray()
        for t in items(ops):
            if t[0] in '\'"' and t[-1] == t[0]:
                b += t[1:-1].encode('latin1')
            else:
                try: b += (num(t) & ((1 << 8 * w) - 1)).to_bytes(w, 'little')
                except ValueError: cur[3] = False
        cur[2] += b * rep
    return [(a, b, bytes(c)) for a, b, c, ok in res if ok and len(c) >= 8]


def refcheck(repo):
    """Data-file labels that code calls or jumps to."""
    files = sorted(glob.glob(os.path.join(repo, 'src', '**', '*.asm'), recursive=True))
    isdata = lambda f: '/data/' in f.replace('\\', '/')
    labels = {}
    for f in files:
        if not isdata(f): continue
        for i, l in enumerate(open(f, errors='replace'), 1):
            m = re.match(r'^([A-Za-z_.@$][\w.@$]*):', l)
            if m: labels.setdefault(m.group(1), (f, i))
    pat = re.compile(r'^\s+(call|jmp|j[a-z]{1,3}|loop\w*)\s+(?:near\s+|short\s+|far\s+|dword\s+|strict\s+\w+\s+)?'
                     r'([A-Za-z_.@$][\w.@$]*)\s*(;.*)?$', re.I)
    hits = {}
    for f in files:
        if isdata(f): continue
        for i, l in enumerate(open(f, errors='replace'), 1):
            m = pat.match(l)
            if m and m.group(2) in labels: hits.setdefault(m.group(2), []).append((os.path.relpath(f, repo), i, m.group(1)))
    for k, v in sorted(hits.items()):
        f, i = labels[k]
        print('%s:%d %s  is called or jumped to from %s:%d (%s): code kept as data' % (os.path.relpath(f, repo), i, k, v[0][0], v[0][1], v[0][2]))
    print('%d data labels used as call or jump targets' % len(hits))
    return 1 if hits else 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('repo')
    ap.add_argument('--heuristic', action='store_true')
    ap.add_argument('--bits', type=int, default=None)
    ap.add_argument('--min', type=int, default=10)
    ap.add_argument('--verbose', action='store_true')
    a = ap.parse_args()
    if not a.heuristic: return refcheck(a.repo)
    from capstone import Cs, CS_ARCH_X86, CS_MODE_16, CS_MODE_32
    bits = a.bits or (16 if '94' in os.path.basename(os.path.abspath(a.repo)) and 'PC' in a.repo.upper() else 32)
    md = Cs(CS_ARCH_X86, CS_MODE_16 if bits == 16 else CS_MODE_32)
    ok = set()
    okf = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'code_as_data_x86_ok.txt')
    if os.path.exists(okf):
        for l in open(okf):
            l = l.split('#')[0].strip()
            if l: ok.add(l)
    n = 0
    for f in sorted(glob.glob(os.path.join(a.repo, 'src', '**', '*.asm'), recursive=True)):
        for label, line, data in blocks(f):
            if label in ok: continue
            ins = []
            end = 0
            for i in md.disasm(data, 0):
                ins.append(i); end = i.address + i.size
                if i.mnemonic in TERM: break
            if len(ins) < a.min or ins[-1].mnemonic not in TERM or end > len(data): continue
            zero = sum(1 for i in ins if i.mnemonic == 'add' and i.op_str.startswith(('byte ptr [eax]', 'byte ptr [bx + si]')))
            if zero * 5 > len(ins): continue
            n += 1
            print('%s:%d %s  %d instructions of code kept as data' % (os.path.relpath(f, a.repo), line, label, len(ins)))
            if a.verbose:
                for i in ins: print('    %04x %s %s' % (i.address, i.mnemonic, i.op_str))
    print('%d code-as-data candidates (x86-%d)' % (n, bits))
    return 1 if n else 0


if __name__ == '__main__':
    sys.exit(main())
