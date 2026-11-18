#!/usr/bin/env python3
"""reflow_comments.py FILE...: put every trailing comment at column 36 (or one tab after longer code), as CONTRIBUTING.md asks."""
import sys, re
def vis(s):
    c = 0
    for ch in s: c = (c // 4 + 1) * 4 if ch == '\t' else c + 1
    return c
def split(line):
    q = None
    for i, ch in enumerate(line):
        if q:
            if ch == q: q = None
        elif ch in "'\"": q = ch
        elif ch == ';': return line[:i], line[i:]
    return line, None
for f in sys.argv[1:]:
    out = []
    for l in open(f, errors='replace').read().split('\n'):
        code, com = split(l)
        if com is not None and code.strip() and not l.startswith(';'):
            c = code.rstrip(' \t')
            if c.strip():
                v = vis(c)
                pad = '\t' * (-(-(36 - v) // 4)) if v < 36 else '\t'
                l = c + pad + com
        out.append(l)
    open(f, 'w', newline='').write('\n'.join(out))
