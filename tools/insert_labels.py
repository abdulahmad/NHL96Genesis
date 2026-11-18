#!/usr/bin/env python3
"""Insert a label at the start of the instruction (or data row) at a ROM address in already decoded source.
  python3 tools/insert_labels.py [--apply] LIST.csv      LIST.csv lines: ADDR,NAME[,comment]; NAME starting with = makes `Name equ *` (a label that does not start a new local scope and may be used before it is defined)
The address is found in the assembler listing (output/*.lst, run the build first); the label goes in front of the source
line that starts there (after any local label or comment-only lines directly above it). Addresses that fall inside a dc.b
or dc.w row (code still kept as bytes) are reported and skipped: decode_code.py names those."""
import re, sys, glob, os
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def norm(s): return re.sub(r'\s+', ' ', s.split(';')[0]).strip()

DATA = '--data' in sys.argv

def main():
    apply_ = '--apply' in sys.argv
    lst = [a for a in sys.argv[1:] if not a.startswith('--')][0]
    want = {}
    for l in open(lst):
        l = l.rstrip('\n')
        if not l or l.startswith('#'): continue
        p = l.split(',', 2)
        want[int(p[0], 16)] = (p[1], p[2] if len(p) > 2 else '')
    files = {}
    for f in glob.glob(os.path.join(ROOT, 'src/**/*.asm'), recursive=True):
        files[os.path.basename(f)[:-4]] = f
    found = {}
    for lf in glob.glob(os.path.join(ROOT, 'output/* .lst')):
        base = os.path.basename(lf)[:-5]
        sf = files.get(base)
        if not sf: continue
        src = open(sf, errors='replace', newline='').read().replace('\r\n', '\n').split('\n')
        sn = [norm(x) for x in src]
        ne = [k for k, x in enumerate(sn) if x]
        lines = []
        for l in open(lf, errors='replace'):
            m = re.match(r'^([0-9A-F]{8}) (.{25})(M?) ?(.*)$', l.rstrip('\r\n'))
            if m and not m.group(3): lines.append((int(m.group(1), 16), m.group(4)))
            elif not m and False: pass
        # find the lst line that starts the source file: its first 3 non-empty lines in a row
        first = [sn[k] for k in ne[:3]]
        start = None
        for n in range(len(lines)):
            if norm(lines[n][1]) == first[0]:
                k2, ok = 0, 0
                for a2, t2 in lines[n:n + 60]:
                    if norm(t2) == first[ok]: ok += 1
                    if ok == 3: break
                if ok == 3: start = n; break
        if start is None: continue
        q = ne[0]
        for a, t in lines[start:]:
            if q >= len(src): break
            if norm(t) != sn[q]:
                print('desync in %s at source line %d: %r vs %r' % (base, q + 1, norm(t)[:40], sn[q][:40])); break
            if a in want and sn[q] and not sn[q].startswith(('org', 'include', 'if', 'endif')) and (a, sf) not in found:
                found[(a, sf)] = q
            q += 1
    edits = {}
    for a, (name, cm) in sorted(want.items()):
        c = [(k[1], v) for k, v in found.items() if k[0] == a]
        if not c: print('%06X %s: not found as the start of a source line' % (a, name)); continue
        sf, q = c[0]
        src = edits.setdefault(sf, open(sf, errors='replace', newline='').read().replace('\r\n', '\n').split('\n'))
        # skip local labels / comment-only lines directly above: the label goes above the local label
        line = src[q]
        if re.match(r'^\s*(dc\.[bwl]|String|Code kept)', line, re.I) and not DATA:
            print('%06X %s: inside data row %s:%d' % (a, name, os.path.basename(sf), q + 1)); continue
        print('%06X %s: %s:%d' % (a, name, os.path.basename(sf), q + 1))
        edits.setdefault((sf, 'ins'), []).append((q, name, cm))
    if apply_:
        for sf in [k for k in edits if isinstance(k, str)]:
            src = edits[sf]
            for q, name, cm in sorted(edits.get((sf, 'ins'), []), reverse=True):
                lab = name[1:] + '\tequ\t*' if name.startswith('=') else name
                if cm: lab += '\t\t\t;' + cm
                src.insert(q, lab)
            crlf = '\r\n' in open(sf, errors='replace', newline='').read()
            open(sf, 'w', newline='').write(('\r\n' if crlf else '\n').join(src))
main()
