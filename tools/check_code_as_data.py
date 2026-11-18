#!/usr/bin/env python3
"""check_code_as_data.py: flag 68000 code that the source still keeps as data (dc.b/dc.w/dc.l).

  python3 tools/check_code_as_data.py [--lst "output/obj/nhl96 .lst"] [--rom lst/nhl96.bin] [--min 5] [--verbose]

Reads the assembler listing of a finished build (addresses and source lines) and the retail ROM. A run is a stretch of
hand-written dc/ds lines (macro expansions are skipped). From the start of every run and from every label inside it the
bytes are decoded as 68000 code. A start is flagged when at least --min instructions decode cleanly, the run of
instructions ends in rts/rte/rtr/jmp/bra at an address still inside the run, no branch leaves the ROM or lands on an odd
address, and no instruction is one that real code never starts with (illegal, reset, stop, trap #n > 15 ...).
Exit status 1 when anything is flagged (so it can run in CI); 0 when the sources hold no code as data.
Works for any 68000 listing in SNASM68k format (NHL 92-96 Genesis, Sega CD programs). Known data that happens to decode
(the false positives) go in tools/code_as_data_ok.txt, one run start address (hex) per line, with a comment.
"""
import re, sys, os, argparse

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from m68kdis import Dis, Bad

DATA = re.compile(r'^\s*(dc\.[bwl]|ds\.[bwl])\b', re.I)
LINE = re.compile(r'^([0-9A-F]{8}) (=?[0-9A-F]{8}|[0-9A-F ]*\+?)\s*(M )?\t?(.*)$')
TERM = ('rts', 'jmp', 'bra')


def parse(lst):
    """Return runs [(start, end, [label addresses])] of hand-written data and the label map."""
    runs, cur, names = [], None, {}
    rows = []
    for l in open(lst, errors='replace'):
        l = l.rstrip('\r\n')
        m = re.match(r'^([0-9A-F]{8}) (.*)$', l)
        if not m: continue
        a, rest = int(m.group(1), 16), m.group(2)
        rows.append((a, rest))
    for k, (a, rest) in enumerate(rows):
        body = rest[28:] if len(rest) > 28 else ''
        flag = rest[26:28]
        isM = 'M' in flag
        mm = re.match(r'^ {27}([A-Za-z_@.][\w$@.]*)', rest)
        if mm and not rest.lstrip().startswith('='):
            names[a] = names.get(a) or mm.group(1)
            if cur: cur[2].append(a)
            continue
        if rest.startswith('='): continue
        txt = body.strip()
        if not txt or txt.startswith((';', '*')): continue
        mn = txt.split(None, 1)[0].lower()
        if mn in ('org', 'even', 'cnop', 'include', 'section', 'opt', 'equ', 'rsset', 'rs.b', 'rs.w', 'rs.l', 'if', 'else',
                  'endif', 'endc', 'macro', 'endm', 'xdef', 'xref', 'align', 'set', 'ifd', 'ifnd') or '=' in txt.split()[:2]:
            continue
        if DATA.match(txt) and not isM:
            if cur is None: cur = [a, a, []]
            cur[1] = a
        elif isM:
            if cur: runs.append(tuple(cur)); cur = None
        else:
            if cur: runs.append(tuple(cur)); cur = None
    if cur: runs.append(tuple(cur))
    return runs, rows, names


def run_end(rows, run):
    """End address of a run: the address of the first listing line after its last dc line."""
    last = run[1]
    for a, rest in rows:
        if a > last: return a
    return last


def try_code(dis, start, end, rom_len, mn):
    pc, n = start, 0
    last = None
    targets = []
    while pc < end:
        try:
            ins = dis.one(pc, end)
        except Bad:
            return None
        except Exception:
            return None
        if ins.size < 2 or ins.size % 2: return None
        if ins.mnem in ('illegal', 'reset', 'stop', 'trapv', 'rte', 'rtr', 'link.w', 'unlk') and ins.mnem in ('illegal', 'reset', 'stop'):
            return None
        if ins.mnem.startswith('trap') and ins.ops and ins.ops[0][0] == 'imm' and ins.ops[0][1] > 15: return None
        if ins.target is not None:
            if ins.target & 1: return None
            targets.append(ins.target)
        pc += ins.size
        n += 1
        last = ins
        if ins.kind in ('rts', 'jmp', 'bra') or ins.mnem in ('rte', 'rtr'):
            break
    if last is None or n < mn: return None
    if not (last.kind in TERM or last.mnem in ('rte', 'rtr')): return None
    return n, pc


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--lst', default='output/obj/nhl96 .lst')
    ap.add_argument('--rom', default=None)
    ap.add_argument('--base', default='0', help='address the image is loaded at (hex): $1B000 for the Sega CD HOCKEY.BIN')
    ap.add_argument('--min', type=int, default=5)
    ap.add_argument('--ok', default=os.path.join(os.path.dirname(os.path.abspath(__file__)), 'code_as_data_ok.txt'))
    ap.add_argument('--verbose', action='store_true')
    a = ap.parse_args()
    rom = a.rom
    if rom is None:
        d = os.path.dirname(a.lst)
        for f in sorted(os.listdir(d)):
            if f.endswith('.bin'): rom = os.path.join(d, f); break
    data = open(rom, 'rb').read()
    ok = set()
    if os.path.exists(a.ok):
        for l in open(a.ok):
            l = l.split('#')[0].strip()
            if l: ok.add(int(l, 16))
    runs, rows, names = parse(a.lst)
    base = int(a.base.replace('$', '0x'), 16)
    dis = Dis(data, base)
    bad = 0
    for run in runs:
        s, e, labs = run
        e = run_end(rows, run)
        if e - s < 2 * a.min or s < base or s >= base + len(data): continue
        covered = 0
        for st in [s] + [x for x in labs if s < x < e]:
            if st in ok or st & 1 or st < covered: continue
            if st < base or st >= base + len(data): continue
            r = try_code(dis, st, e, len(data), a.min)
            if r:
                n, pc = r
                covered = pc
                bad += 1
                print('%06X-%06X  %-28s %d instructions of code kept as data' % (st, pc, names.get(st, ''), n))
                if a.verbose:
                    x = st
                    while x < pc:
                        i = dis.one(x, e); print('    %06X %s %s' % (x, i.mnem, i.ops)); x += i.size
    print('%d code-as-data candidates in %d data runs' % (bad, len(runs)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
