#!/usr/bin/env python3
"""check_names.py: every label in tools/decode_names.csv must sit at its address in the segment listings (output/*.lst).
Prints the ones that are missing or at another address."""
import re, glob, os, sys
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
want = {}
for l in open(os.path.join(ROOT, 'tools', 'decode_names.csv')):
    p = l.rstrip('\n').split(',', 2)
    if len(p) > 1 and re.match(r'^[0-9A-F]{6}$', p[0]) and not p[1].startswith('.') and '+' not in p[1]:
        want[p[1].lstrip('=')] = int(p[0], 16)
got = {}
for f in glob.glob(os.path.join(ROOT, 'output', '* .lst')):
    for l in open(f, errors='replace'):
        m = re.match(r'^([0-9A-F]{8}) ', l)
        if not m or (len(l) > 34 and l[34] == 'M'): continue
        v = re.match(r'=([0-9A-F]{8})', l[9:18])
        n = re.match(r'[ ]*([A-Za-z_][\w$]*)', l[35:]) if len(l) > 35 else None
        if n and not l[35:].startswith('\t'):
            got.setdefault(n.group(1), set()).add(int(v.group(1) if v else m.group(1), 16))
bad = 0
for n, a in sorted(want.items(), key=lambda x: x[1]):
    g = got.get(n)
    if g is None: print('%06X %s: not defined' % (a, n)); bad += 1
    elif a not in g: print('%06X %s: at %s' % (a, n, ','.join('%06X' % x for x in sorted(g)))); bad += 1
print(bad, 'of', len(want), 'names wrong')
