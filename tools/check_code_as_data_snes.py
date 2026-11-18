#!/usr/bin/env python3
"""check_code_as_data_snes.py: flag 65816 code that the SNES sources still keep as data.

  python3 tools/check_code_as_data_snes.py REPO_DIR

Exact check: a label whose first statement is a data directive (db/dw/dl/dd/incbin) that some instruction calls or
jumps to (jsr/jsl/jmp/jml/bra/brl/b<cc> LABEL, also with a .l/.w/.b suffix) holds code, not data. Exit status 1 when
there is one. (There is no 65816 decoder here, so unreferenced code stored as data is not found by this check.)
"""
import re, sys, os, glob

DATA = re.compile(r'^\s+\.?(db|dw|dl|dd|byte|word|long|incbin|ds)\b', re.I)
LABEL = re.compile(r'^([A-Za-z_@.][\w.@$]*):?(\s|$)')
REF = re.compile(r'^\s+(jsr|jsl|jmp|jml|bra|brl|bcc|bcs|beq|bne|bmi|bpl|bvc|bvs)(?:\.\w)?\s+([A-Za-z_@][\w.@$]*)\s*(?:;.*)?$', re.I)


def main():
    repo = sys.argv[1]
    files = sorted(glob.glob(os.path.join(repo, 'src', '**', '*.asm'), recursive=True))
    dl = {}
    for f in files:
        lines = open(f, errors='replace').read().split('\n')
        for i, l in enumerate(lines):
            m = LABEL.match(l)
            if not m or l.startswith((';', ' ', '\t')) or m.group(1).startswith('.'): continue
            rest = l[m.end():].strip()
            if rest and not rest.startswith(';'):
                if DATA.match('\t' + rest): dl.setdefault(m.group(1), (f, i + 1))
                continue
            for j in range(i + 1, min(i + 12, len(lines))):
                t = lines[j]
                if not t.strip() or t.strip().startswith(';'): continue
                if LABEL.match(t) and not t.startswith((' ', '\t')): continue
                if DATA.match(t): dl.setdefault(m.group(1), (f, i + 1))
                break
    hits = {}
    for f in files:
        for i, l in enumerate(open(f, errors='replace'), 1):
            m = REF.match(l)
            if m and m.group(2) in dl: hits.setdefault(m.group(2), []).append((os.path.relpath(f, repo), i, m.group(1)))
    for k, v in sorted(hits.items()):
        f, i = dl[k]
        print('%s:%d %s  is called or jumped to from %s:%d (%s): code kept as data' % (os.path.relpath(f, repo), i, k, v[0][0], v[0][1], v[0][2]))
    print('%d data labels used as call or jump targets' % len(hits))
    return 1 if hits else 0


if __name__ == '__main__':
    sys.exit(main())
