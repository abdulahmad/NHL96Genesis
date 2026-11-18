#!/usr/bin/env python3
"""fix_stubs.py: after decode_code.py --apply, add the outside labels each segment now uses to its stub
(src/stubinc/NAME_stub.asm) by reading `Symbol 'x' not defined` from the failed segment builds (output/Build_*.log).
Names come from the last good listing (output/obj/nhl96 .lst is gone while the build fails, so use tools/decode_names.csv
and the per-segment listings) ."""
import re, sys, os, glob
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import decode_code as D

def main():
    D.HINTS = D.load_hints()
    ctx = D.Ctx()
    names = D.load_names()
    pend = {v[0].lstrip('='): k for k, v in names.items() if not v[0].startswith('.')}
    pend.update({n: a for n, a in ((n, a) for n, a in pend.items())})
    low = {}
    for n, a in list(ctx.lab.items()): low.setdefault(n.lower(), (n, a))
    for n, a in pend.items(): low.setdefault(n.lower(), (n, a))
    for l in open(os.path.join(D.ROOT, 'output', 'frames96 .lst'), errors='replace'):
        m = re.match(r'^[0-9A-F]{8} =([0-9A-F]{8})\s+(SPA\w+)\s*=\s*\*-SPAlist', l)
        if m: low.setdefault(m.group(2).lower(), (m.group(2), int(m.group(1), 16)))
    tot = 0
    for lg in glob.glob(os.path.join(D.ROOT, 'output', 'Build_*.log')):
        base = os.path.basename(lg)[6:-4]
        txt = open(lg, errors='replace').read().replace('\r', '\n')
        miss = sorted(set(m.lower() for m in re.findall(r"Symbol '([^']+)' not defined", txt)))
        if not miss: continue
        need, pd, unk = set(), {}, []
        for m in miss:
            if m in low:
                n, a = low[m]; need.add(n); pd[n] = a
            else: unk.append(m)
        rel = base
        add = D.update_stub(ctx, rel, need, pd)
        tot += len(add)
        print('%s: added %d%s' % (base, len(add), ('; unknown: ' + ' '.join(unk)) if unk else ''))
    # a stub must not define a name its own file defines now
    for st in glob.glob(os.path.join(D.ROOT, 'src', 'stubinc', '*_stub.asm')):
        base = os.path.basename(st)[:-9]
        srcs = glob.glob(os.path.join(D.ROOT, 'src', '**', base + '.asm'), recursive=True)
        if not srcs: continue
        own = {m.group(1) for l in open(srcs[0], errors='replace') for m in [re.match(r'^([A-Za-z_][\w$]*)\b', l)] if m}
        raw = open(st, errors='replace', newline='').read()
        crlf = '\r\n' in raw
        L = raw.replace('\r\n', '\n').split('\n')
        out = [l for l in L if not (re.match(r'^([A-Za-z_]\w*)\s*=\s*\$', l) and re.match(r'^([A-Za-z_]\w*)', l).group(1) in own)]
        if len(out) != len(L):
            open(st, 'w', newline='').write(('\r\n' if crlf else '\n').join(out)); print('%s: removed %d own names' % (base, len(L) - len(out)))
    print('total', tot)
main()
