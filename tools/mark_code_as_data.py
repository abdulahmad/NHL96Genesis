#!/usr/bin/env python3
"""mark_code_as_data.py: put the "kept as bytes" marker above every dc.b run that check_code_as_data.py flags,
so that decode_code.py picks it up.   python3 tools/mark_code_as_data.py [--apply]
Reads the check's output for this repo (runs it), finds each flagged run's source lines by their text in the listing."""
import re, sys, os, glob, subprocess

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
apply_ = '--apply' in sys.argv
out = subprocess.run([sys.executable, os.path.join(ROOT, 'tools', 'check_code_as_data.py'), '--rom', os.path.join(ROOT, 'output/obj/nhl96.bin')],
                     capture_output=True, text=True, cwd=ROOT).stdout
cands = [int(m.group(1), 16) for m in re.finditer(r'^([0-9A-F]{6})-[0-9A-F]{6} ', out, re.M)]
lst = open(os.path.join(ROOT, 'output/obj/nhl96 .lst'), errors='replace').read().split('\n')
byaddr = {}
for i, l in enumerate(lst):
    m = re.match(r'^([0-9A-F]{8}) ', l)
    if m: byaddr.setdefault(int(m.group(1), 16), []).append(i)


def dc_after(i):
    """Source texts of the dc lines that start at listing line i."""
    t = []
    for k in range(i, min(i + 40, len(lst))):
        l = lst[k]
        m = re.match(r'^[0-9A-F]{8} [^\t]*\t(dc\.[bwl]\t.*)$', l)
        if m and ' M ' not in l[:30] and not re.match(r'^[0-9A-F]{8} .{18}M ', l):
            t.append(m.group(1).rstrip())
        elif re.match(r'^[0-9A-F]{8} ', l) and not l[9:].strip().startswith(';') and l[9:].strip() and not re.match(r'^[0-9A-F]{8} {28}', l):
            break
    return t


srcs = {}
for f in sorted(glob.glob(os.path.join(ROOT, 'src', '**', '*.asm'), recursive=True)):
    raw = open(f, errors='replace', newline='').read()
    srcs[f] = (raw, raw.replace('\r\n', '\n').split('\n'))
done = skipped = 0
edits = {}
for a in cands:
    texts = None
    for i in byaddr.get(a, []):
        t = dc_after(i)
        if t: texts = t; break
    if not texts:
        print('%06X: no dc line in listing' % a); skipped += 1; continue
    key = texts[0]
    found = []
    for f, (raw, lines) in srcs.items():
        for j, l in enumerate(lines):
            if l.rstrip() == '\t' + key.split('\t', 0)[0] or l.rstrip().lstrip('\t') == key.lstrip('\t').rstrip():
                if all(j + k < len(lines) and lines[j + k].rstrip().lstrip('\t') == texts[k].lstrip('\t') for k in range(min(3, len(texts)))):
                    found.append((f, j))
    if len(found) != 1:
        print('%06X: %d source candidates' % (a, len(found))); skipped += 1; continue
    f, j = found[0]
    lines = srcs[f][1]
    if j > 0 and re.search(r'kept as bytes|Not decoded|not decode', lines[j - 1], re.I): continue
    edits.setdefault(f, []).append(j)
    done += 1
print('%d marked, %d skipped' % (done, skipped))
if apply_:
    for f, js in edits.items():
        raw, lines = srcs[f]
        nl = '\r\n' if '\r\n' in raw else '\n'
        for j in sorted(js, reverse=True):
            lines.insert(j, '; Code kept as bytes (decoded by decode_code.py).')
        open(f, 'w', newline='').write(nl.join(lines))
