#!/usr/bin/env python3
"""fix_stub.py SEG: build the segment under wine and add `name = $value` equates for every symbol the stub lacks.

The segment stubs (src/stubinc/<seg>_stub.asm) list the labels and constants that live outside the segment. After code
moves from dc.b bytes into real instructions, the file uses more of them. Values come from the full build listing
(output/obj/nhl96 .lst, run tools/verify_all.sh first): label addresses and `=` constants. Run until it builds.
"""
import re, os, subprocess, sys
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
seg = sys.argv[1]
lab, const, where = {}, {}, {}
cur = None
for l in open(os.path.join(ROOT, 'output/obj/nhl96 .lst'), errors='replace'):
    m = re.match(r'^([0-9A-F]{8}) =([0-9A-F]{8})\s+(?:M )?([A-Za-z_]\w*)\s', l)
    if m:
        const.setdefault(m.group(3).lower(), (m.group(3), int(m.group(2), 16))); continue
    m = re.match(r'^([0-9A-F]{8}) {28}([A-Za-z_][\w$]*)', l)
    if m: lab.setdefault(m.group(2).lower(), (m.group(2), int(m.group(1), 16)))
stub = os.path.join(ROOT, 'src/stubinc/%s_stub.asm' % seg)
src = {}
import glob
for f in glob.glob(os.path.join(ROOT, 'src/**/*.asm'), recursive=True):
    for l in open(f, errors='replace'):
        m = re.match(r'^([A-Za-z_][\w$]*)\b', l)
        if m and not l.startswith(('\t', ' ', ';')): src.setdefault(m.group(1).lower(), os.path.splitext(os.path.basename(f))[0])
for it in range(12):
    env = dict(os.environ, WINEDEBUG='-all', NHL_PREBUILD_DONE='1')
    subprocess.run('wine cmd /c "buildseg.bat %s" > output/seg_%s.log 2>&1' % (seg, seg), shell=True, cwd=ROOT, env=env)
    log = open(os.path.join(ROOT, 'output/Build_%s.log' % seg), errors='replace').read()
    miss = sorted(set(re.findall(r"Symbol '([^']+)' not defined", log)))
    if not miss:
        print('stub ok after', it, 'rounds'); break
    add = []
    for n in miss:
        k = n.lower()
        if k in lab: nm, v = lab[k]; add.append('%s = $%06X\t\t\t\t;%s' % (nm, v, src.get(k, '')))
        elif k in const: nm, v = const[k]; add.append('%s = $%X\t\t\t\t;%s' % (nm, v, src.get(k, '')))
        else: print('unknown symbol', n)
    if not add: sys.exit(1)
    t = open(stub, errors='replace').read()
    i = t.find('\n\n; Main segment code')
    if i < 0:
        i = len(t)
    t = t[:i].rstrip('\n') + '\n' + '\n'.join(add) + '\n' + t[i:]
    open(stub, 'w', newline='').write(t)
    print('added', len(add))
