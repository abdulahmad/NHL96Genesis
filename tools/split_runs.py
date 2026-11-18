#!/usr/bin/env python3
"""split_runs.py: cut a run of dc rows where code starts in the middle of the data, and mark the code part.

  python3 tools/split_runs.py [--apply]

tools/decode_hints.csv: `block,ADDR` says that code starts at ADDR, inside a run of dc.b / dc.w / dc.l rows that was not flagged
(for example code after a table, or a short routine that check_code_as_data.py skips). The run is cut at ADDR: the bytes before it
stay as dc.b rows, the rest gets the marker "Code kept as bytes" so that decode_code.py turns it into instructions.
Needs a finished build (output/obj/nhl96 .lst).
"""
import re, sys, os, glob
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import decode_code as D

MARKER = '; Code kept as bytes (decoded by decode_code.py).'


def rows_of(bs, a, b):
    return ['\tdc.b\t' + ','.join('$%02X' % x for x in bs[i:min(i + 16, b)]) for i in range(a, b, 16)]


def main():
    apply = '--apply' in sys.argv
    D.HINTS = D.load_hints()
    ctx = D.Ctx()
    blocks = []
    p = os.path.join(D.ROOT, 'tools', 'decode_hints.csv')
    for l in open(p):
        f = l.strip().split(',')
        if f[0] == 'block': blocks.append(int(f[1], 16))
    todo = set(blocks)
    for fn in sorted(glob.glob(os.path.join(D.ROOT, 'src', '**', '*.asm'), recursive=True)):
        raw = open(fn, errors='replace', newline='').read()
        crlf = '\r\n' in raw
        src = raw.replace('\r\n', '\n').split('\n')
        i, out, changed = 0, [], False
        while i < len(src):
            if re.match(r'^\tdc\.[bwl]\t', src[i]):
                j = i
                while j < len(src) and re.match(r'^\tdc\.[bwl]\t', src[j]): j += 1
                run = src[i:j]
                cands = D.find_run(ctx, run)
                done = False
                if len(cands) >= 1:
                    # several equal runs: the one after the nearest label above
                    if len(cands) > 1:
                        b = i
                        while b > 0 and not re.match(r'^[A-Za-z_][\w$]*', src[b]): b -= 1
                        ml = re.match(r'^([A-Za-z_][\w$]*)', src[b])
                        la = ctx.lab.get(ml.group(1)) if ml else None
                        c2 = sorted(c for c in cands if la is not None and c >= la)
                        cands = c2[:1] if c2 else []
                    if len(cands) == 1:
                        a0 = cands[0]
                        bs = b''.join(D.row_bytes(ctx, r) for r in run)
                        a1 = a0 + len(bs)
                        hit = sorted(t for t in todo if a0 <= t < a1)
                        if hit:
                            t = hit[0]
                            before = rows_of(bs, 0, t - a0)
                            after = rows_of(bs, t - a0, len(bs))
                            out.extend(before)
                            if not (not before and out and out[-1] == MARKER): out.append(MARKER)
                            out.extend(after)
                            todo.discard(t); changed = True; done = True
                            print('%s:%d: cut at %06X (run %06X-%06X)' % (os.path.relpath(fn, D.ROOT), i + 1, t, a0, a1))
                if not done: out.extend(run)
                i = j
            else:
                out.append(src[i]); i += 1
        if apply and changed:
            open(fn, 'w', newline='').write(('\r\n' if crlf else '\n').join(out))
    if todo: print('not placed:', ' '.join('%06X' % t for t in sorted(todo)))


if __name__ == '__main__':
    main()
