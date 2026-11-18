#!/usr/bin/env python3
"""decode_code.py: turn code that the source keeps as dc.b bytes into real SNASM68k assembly.

  python3 tools/decode_code.py [--apply] [--structs] [--list] FILE.asm ...

Needs a finished full build (tools/verify_all.sh) for output/obj/nhl96 .lst (addresses) and the retail ROM.
A block is a run of `dc.b` lines that follows a comment containing "kept as bytes", "Not decoded" or "not decode".
Without --apply it only reports what it would do (decode errors, unnamed ROM targets, unnamed RAM addresses).
With --apply it rewrites the file. The build must still MATCH (tools/verify_all.sh) afterwards.
"""
import re, sys, os, glob, argparse
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from m68kdis import Dis, Bad, Insn, reglist_text


def _tn(self, ctx):
    if self.target is not None: return ctx.a2l.get(self.target, [None])[0]
    o = self.ops[0] if self.ops else None
    if o and o[0] in ('absl', 'absw'): return ctx.a2l.get(o[1], [None])[0]
    return None


Insn.target_name = _tn

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
IMM_NUMBERS = set()   # long immediates in the ROM range that are numbers, not addresses (decode_hints.csv: `number,ADDR`)
MARK = re.compile(r'kept as bytes|Not decoded|not decode', re.I)


def load_rom():
    for p in glob.glob(os.path.join(ROOT, '*.bin')) + [os.path.join(ROOT, 'lst', 'nhl96.bin')]:
        if os.path.exists(p) and os.path.getsize(p) == 2097152:
            return open(p, 'rb').read()
    sys.exit('no ROM')


SPA = {}
PRINTERS = ('printz', 'printcurz', 'printsmallz', 'printbigz', 'appendz', 'printbigcurz', 'printbigz1', 'printbigz2')


def load_lst():
    """lst lines: [(addr, text)], and label -> addr / addr -> [labels] (non-local only)."""
    lines, lab, addr2lab = [], {}, {}
    for l in open(os.path.join(ROOT, 'output', 'obj', 'nhl96 .lst'), errors='replace').read().split('\n'):
        l = l.rstrip('\r')
        m = re.match(r'^([0-9A-F]{8}) (.*)$', l)
        if not m:
            lines.append((None, l)); continue
        a, rest = int(m.group(1), 16), m.group(2)
        lines.append((a, rest))
        m3 = re.match(r'^=([0-9A-F]{8}) +(SPA\w+)\s*=', rest)
        if m3: SPA.setdefault(int(m3.group(1), 16), m3.group(2))
        m2 = re.match(r'^ {27}([A-Za-z_][\w$]*)', rest)
        if m2:
            lab.setdefault(m2.group(1), a); addr2lab.setdefault(a, []).append(m2.group(1))
    return lines, lab, addr2lab


def load_ram():
    ram, ports = {}, {}
    for f in ('src/ram96.asm', 'src/inc/ports.inc', 'src/inc/equals.inc', 'src/externs96.asm'):
        p = os.path.join(ROOT, f)
        if not os.path.exists(p): continue
        for l in open(p, errors='replace'):
            m = re.match(r'^([A-Za-z_]\w*)\s+(?:equ|=)\s+\$([0-9A-Fa-f]+)\s*(;.*)?$', l.rstrip())
            if not m: continue
            v = int(m.group(2), 16)
            if f.endswith('ram96.asm'):
                ram.setdefault(v, m.group(1))
            elif 'ports' in f:
                ports.setdefault(v, m.group(1))
    return ram, ports


def load_syms():
    syms = {}
    for l in open(os.path.join(ROOT, 'output', 'obj', 'nhl96 .lst'), errors='replace'):
        m = re.match(r'^[0-9A-F]{8} =([0-9A-F]{8})\s+(?:M )?([A-Za-z_][\w]*)\s', l)
        if m: syms.setdefault(m.group(2), int(m.group(1), 16))
    return syms


def load_struct():
    """Player structure field offsets (Xpos .. checking in equals.inc) -> name."""
    st, on = {}, False
    for l in open(os.path.join(ROOT, 'src/inc/equals.inc'), errors='replace'):
        m = re.match(r'^([A-Za-z_]\w*)\s+equ\s+\$([0-9A-Fa-f]+)\b', l)
        if m and m.group(1) == 'Xpos': on = True
        if on and m and not (re.match(r'^(pf|sf)', m.group(1)) and not m.group(1).startswith('pflags')):
            st.setdefault(int(m.group(2), 16), m.group(1))
        if m and m.group(1) == 'checking': on = False
    return st


HEXS = lambda v: ('$%X' % v)


def sh(v):
    return '%d' % v if 0 <= v < 10 else ('-' + '$%X' % -v if v < 0 else '$%X' % v)


class Ctx:
    def __init__(self):
        self.rom = load_rom()
        self.lines, self.lab, self.a2l = load_lst()
        self.ram, self.ports = load_ram()
        self.syms = load_syms()
        self.struct = load_struct()
        self.dis = Dis(self.rom, 0)
        self.defs = self.src_definitions()
        self.newg = {}

    def src_definitions(self):
        d = {}
        for f in glob.glob(os.path.join(ROOT, 'src', '**', '*.asm'), recursive=True):
            for l in open(f, errors='replace'):
                m = re.match(r'^([A-Za-z_][\w$]*)\b', l)
                if m and not l.startswith(('\t', ' ', ';')):
                    d.setdefault(m.group(1), os.path.relpath(f, os.path.join(ROOT, 'src')).replace('/', '\\'))
        return d


def row_bytes(ctx, row):
    """Bytes of one dc.b / dc.w / dc.l source row (numbers, or symbols whose value the listing knows). None when it has other symbols."""
    m = re.match(r'^\tdc\.([bwl])\t([^;]*)', row)
    if not m: return None
    size = {'b': 1, 'w': 2, 'l': 4}[m.group(1)]
    out = bytearray()
    for tok in m.group(2).split(','):
        tok = tok.strip()
        if not tok: continue
        if re.match(r'^\$[0-9A-Fa-f]+$', tok): v = int(tok[1:], 16)
        elif re.match(r'^[0-9]+$', tok): v = int(tok)
        elif tok in ctx.syms: v = ctx.syms[tok]
        else: return None
        out += (v & ((1 << (8 * size)) - 1)).to_bytes(size, 'big')
    return bytes(out)


def find_run(ctx, run):
    """Address of a dc run (list of source lines) by matching the listing and checking the ROM."""
    first = run[0].strip()
    bs = bytearray()
    for r in run:
        b = row_bytes(ctx, r)
        if b is None: return []
        bs += b
    cands = []
    for i, (a, rest) in enumerate(ctx.lines):
        if a is not None and rest.rstrip().endswith(first) and re.search(r'\tdc\.[bwl]', rest):
            if ctx.rom[a:a + len(bs)] == bytes(bs):
                cands.append(a)
    return cands


class Out:
    def __init__(self):
        self.unres_ram, self.unres_rom, self.errors, self.needname = [], [], [], []
        self.unres_imm = []


def symbolize(ctx, ins, op, lab_here, blk, local, structs, pos):
    """Operand tuple -> text."""
    k = op[0]
    if k == 'dn': return 'd%d' % op[1]
    if k == 'an': return 'sp' if op[1] == 7 else 'a%d' % op[1]
    if k == 'ind': return '(%s)' % ('sp' if op[1] == 7 else 'a%d' % op[1])
    if k == 'post': return '(%s)+' % ('sp' if op[1] == 7 else 'a%d' % op[1])
    if k == 'pre': return '-(%s)' % ('sp' if op[1] == 7 else 'a%d' % op[1])
    if k == 'disp':
        d, n = op[1], op[2]
        if d == 0x58 and ins.mnem in ('cmpi.w', 'move.w') and ins.ops[0][0] == 'imm' and ins.ops[0][1] in SPA:
            return 'SPA(%s)' % ('sp' if n == 7 else 'a%d' % n)
        an = 'sp' if n == 7 else 'a%d' % n
        if structs and n in STRUCTREGS and d in ctx.struct and d >= 0: return '%s(%s)' % (ctx.struct[d], an)
        return ('%s(%s)' % (sh(d) if d else '0', an))
    if k == 'idx':
        d, n, t, r, s = op[1:]
        an = 'sp' if n == 7 else 'a%d' % n
        ix = '%s%d.%s' % (t, r, s)
        return '%s(%s,%s)' % (sh(d), an, ix) if d else '(%s,%s)' % (an, ix)
    if k == 'absw':
        v = op[1] & 0xFFFFFFFF
        if op[1] < 0: v = 0xFFFF0000 | (op[1] & 0xFFFF)
        return '(%s).w' % name_addr(ctx, v, blk)
    if k == 'absl':
        return '(%s).l' % name_addr(ctx, op[1], blk)
    if k == 'pcd':
        return '%s(pc)' % name_target(ctx, op[1], blk, local)
    if k == 'pcidx':
        return '%s(pc,%s%d.%s)' % (name_target(ctx, op[1], blk, local), op[2], op[3], op[4])
    if k == 'imm':
        v, sz = op[1], op[2]
        if sz == 'q': return '#%s' % sh(v)
        m = ins.mnem
        if m in ('cmpi.w', 'move.w') and ins.ops[1][0] == 'disp' and ins.ops[1][1] == 0x58 and v in SPA:
            return '#' + SPA[v]
        if m == 'movea.w' and v >= 0x8000:
            full = 0xFFFF0000 | v
            if full in ctx.ram: return '#(%s-M68K_RAM)' % ctx.ram[full]
            for d in range(1, 9):
                if (full + d) in ctx.ram:
                    blk.unres_ram.append((full, 'imm %s-%d' % (ctx.ram[full + d], d)))
                    return '#(%s-%d-M68K_RAM)' % (ctx.ram[full + d], d)
        if m in ('movea.l', 'move.l') and ins.ops[1][0] == 'an' and v >= 0xFF0000:
            full = v | 0xFF000000 if v < 0x1000000 else v
            if full in ctx.ram: return '#%s' % ctx.ram[full]
            for d in range(1, 9):
                if (full - d) in ctx.ram:
                    blk.unres_ram.append((full, 'imm %s+%d' % (ctx.ram[full - d], d)))
                    return '#%s+%d' % (ctx.ram[full - d], d)
        if m in ('movea.l', 'move.l') and 0x1000 <= v < 0x200000 and ins.ops[1][0] in ('an', 'absl', 'absw', 'ind', 'disp') and v not in IMM_NUMBERS:
            nm = (ctx.a2l.get(v) or [None])[0] or ctx.newg.get(v)
            if nm: return '#%s' % nm
            blk.unres_imm.append(v)
            return '#$%X' % v
        if sz == 'l': return '#$%X' % v
        if sz == 'w':
            return '#%s' % ('$%X' % (v & 0xFFFF) if v >= 10 else '%d' % v)
        return '#%s' % ('$%X' % v if v >= 10 else '%d' % v)
    if k == 'sr': return 'sr'
    if k == 'ccr': return 'ccr'
    if k == 'usp': return 'usp'
    if k == 'reglist': return reglist_text(op[1], op[2])
    if k == 'target': return name_target(ctx, op[1], blk, local)
    raise Bad(str(op))


def name_addr(ctx, v, blk):
    v &= 0xFFFFFFFF
    if v >= 0xFF000000 or v >= 0xFFFF0000 or (0xFF0000 <= v <= 0xFFFFFF):
        v |= 0xFF000000 if v < 0x1000000 else 0
        v &= 0xFFFFFFFF
        if v in ctx.ram: return ctx.ram[v]
        # nearest lower name inside 8 bytes
        for d in range(1, 9):
            if (v - d) in ctx.ram:
                blk.unres_ram.append((v, 'near %s+%d' % (ctx.ram[v - d], d)))
                return '%s+%d' % (ctx.ram[v - d], d)
        blk.unres_ram.append((v, None))
        return '$%08X' % v
    if v in ctx.ports: return ctx.ports[v]
    if v in ctx.a2l: return ctx.a2l[v][0]
    if v in ctx.newg: return ctx.newg[v]
    # hardware and save RAM ranges are named from their base
    if v == 0xC00004: return 'Vctrl'
    if 0xA00000 <= v < 0xA02000: return 'Z80_RAM' + ('+$%X' % (v - 0xA00000) if v > 0xA00000 else '')
    if 0xA10000 <= v < 0xA10010:
        for d in range(1, 4):
            if (v - d) in ctx.ports: return '%s+%d' % (ctx.ports[v - d], d)
    if 0x200000 <= v < 0x204000: return 'SaveRAM' + ('+$%X' % (v - 0x200000) if v > 0x200000 else '')
    blk.unres_rom.append(v)
    return '$%06X' % v


def name_target(ctx, t, blk, local):
    if t in local: return local[t]
    if t in ctx.a2l: return ctx.a2l[t][0]
    if t in ctx.newg: return ctx.newg[t]
    blk.unres_rom.append(t)
    return '$%06X' % t


def decode_block(ctx, start, end, entry_label):
    """Recursive descent from the block start, from every label inside and from every internal call or branch
    target. Returns (segments, notes). A segment is ('code', [Insn]) or ('data', start, end, why)."""
    ent, forced = HINTS
    cov, insns, work, notes = {}, {}, [start] + [e for e in ent if start <= e < end], []
    for a in range(start, end):
        if a in ctx.a2l and a != start: work.append(a)
    seen = set()
    pc_refs = set()
    while work:
        a = work.pop()
        while start <= a < end and a not in insns and not any(fa <= a < fb for fa, fb in forced):
            try:
                ins = ctx.dis.one(a, end)
            except Bad as e:
                notes.append('bad at %06X: %s' % (a, e)); break
            insns[a] = ins
            if ins.kind in ('jsr', 'bsr') and ins.target_name(ctx) in PRINTERS:
                sa = a + ins.size
                L = int.from_bytes(ctx.rom[sa:sa + 2], 'big')
                if L < 2 or sa + L > end:
                    notes.append('bad string at %06X' % sa); break
                st = Insn(sa, L, 'String', [('str', ctx.rom[sa + 2:sa + L], sa)])
                insns[sa] = st
                work.append(sa + L)
                break
            for o in ins.ops:
                if o[0] in ('pcd', 'pcidx') and start <= o[1] < end: pc_refs.add(o[1])
            if ins.kind in ('bcc', 'dbcc', 'bsr'):
                if start <= ins.target < end: work.append(ins.target)
                a += ins.size
            elif ins.kind == 'bra':
                if start <= ins.target < end: work.append(ins.target)
                break
            elif ins.kind in ('rts', 'jmp'):
                break
            else:
                a += ins.size
    # check overlap
    covered = {}
    for a, ins in insns.items():
        for x in range(a, a + ins.size):
            if x in covered: notes.append('overlap at %06X' % x)
            covered[x] = a
    segs, a = [], start
    while a < end:
        if a in insns:
            run = []
            while a in insns:
                run.append(insns[a]); a += insns[a].size
            segs.append(('code', run))
        else:
            b = a
            while b < end and b not in insns: b += 1
            for fa, fb in forced:
                if a < fa < b: b = fa
                if fa <= a < fb: b = min(b, fb)
            # try the gap as an orphan code run
            seg = ('data', a, b, 'pocket')
            if any(fa <= a < fb for fa, fb in forced):
                segs.append(seg); a = b; continue
            try:
                x, run = a, []
                while x < b:
                    i2 = ctx.dis.one(x, b); run.append(i2); x += i2.size
                    if i2.kind in ('jsr', 'bsr') and i2.target_name(ctx) in PRINTERS:
                        L = int.from_bytes(ctx.rom[x:x + 2], 'big')
                        if L < 2 or x + L > b: raise Bad('bad string')
                        run.append(Insn(x, L, 'String', [('str', ctx.rom[x + 2:x + L], x)])); x += L
                if run and run[-1].kind in ('rts', 'jmp', 'bra') and a not in pc_refs and not any(
                        ai.kind == 'rts' and False for ai in run):
                    seg = ('code', run)
                    for i2 in run: insns[i2.addr] = i2
                    notes.append('orphan code at %06X' % a)
            except Bad:
                pass
            segs.append(seg)
            a = b
    return segs, notes


def fmt_string(d, sa):
    d = bytes(d)
    k = len(d)
    if k and d[-1] == 0 and (sa + 2 + k - 1) % 2 == 1:
        d = d[:-1]
    out, run = [], ''
    if d and d[0] == 0xBF:
        out.append('-(TXPRI+TXMAP1)'); d = d[1:]
    for b in d:
        if 0x20 <= b < 0x7F and b not in (0x27, 0x22):
            run += chr(b)
        else:
            if run: out.append("'%s'" % run); run = ''
            out.append('$%X' % b if b >= 10 else str(b))
    if run: out.append("'%s'" % run)
    return ','.join(out)


def fmt_data(ctx, a, b):
    """dc.w rows when the span is word sized and even, else dc.b."""
    out, rom = [], ctx.rom
    if (b - a) % 2 == 0 and a % 2 == 0:
        for x in range(a, b, 16):
            ws = []
            for y in range(x, min(x + 16, b), 2):
                v = int.from_bytes(rom[y:y + 2], 'big')
                ws.append(SPA[v] if v in SPA and v > 0x100 else '$%04X' % v)
            out.append('\tdc.w\t' + ','.join(ws))
    else:
        for x in range(a, b, 16):
            out.append('\tdc.b\t' + ','.join('$%02X' % v for v in rom[x:min(x + 16, b)]))
    return out


class Rec:
    """One output line: optional global label, optional local label, code text, trailing comment, comment lines above."""
    def __init__(self, addr, text, ins=None):
        self.addr, self.text, self.ins = addr, text, ins
        self.glabel = self.llabel = None
        self.comment, self.pre = '', []
        self.norm = None


def load_hints():
    """tools/decode_hints.csv: `entry,ADDR` adds a code entry point, `data,START,END` forces a data pocket."""
    ent, data = set(), []
    p = os.path.join(ROOT, 'tools', 'decode_hints.csv')
    if os.path.exists(p):
        for l in open(p, errors='replace'):
            f = l.strip().split(',')
            if f[0] == 'number': IMM_NUMBERS.add(int(f[1], 16))
            elif f[0] == 'entry': ent.add(int(f[1], 16))
            elif f[0] == 'data': data.append((int(f[1], 16), int(f[2], 16)))
    return ent, data


def load_names():
    """tools/decode_names.csv: addr,name,comment (comment = the header comment of a new global label)."""
    d = {}
    p = os.path.join(ROOT, 'tools', 'decode_names.csv')
    if os.path.exists(p):
        for l in open(p, errors='replace'):
            l = l.rstrip('\n')
            if not l or l.startswith('#'): continue
            f = l.split(',', 2)
            d[int(f[0], 16)] = (f[1], f[2] if len(f) > 2 else '')
    return d


def make_records(ctx, segs, start, end, entry_label, names, reserved=frozenset()):
    blk = Out()
    ins_list = [i for s in segs if s[0] == 'code' for i in s[1]]
    addrs = {i.addr for i in ins_list}
    # global labels inside the block: lst labels, names.csv entries
    glob_at, pre_local, mid_at = {}, {}, {}
    for a in range(start, end):
        if a in ctx.a2l: glob_at[a] = ctx.a2l[a][0]
        elif a in names and names[a][0].startswith('.'): pre_local[a] = names[a][0]
        elif a in names and names[a][0].startswith('='): mid_at[a] = names[a][0][1:]
        elif a in names: glob_at[a] = names[a][0]
    if entry_label: glob_at[start] = entry_label
    scope_of = {}
    cur = None
    order = sorted(set([start] + list(glob_at)))
    def scope(a):
        r = start
        for g in order:
            if g <= a: r = g
        return r
    tgt = {}
    for i in ins_list:
        refs = []
        if i.target is not None and i.kind != 'bsr': refs.append(i.target)
        if i.kind == 'bsr' and i.target is not None: refs.append(i.target)
        for o in i.ops:
            if o[0] in ('pcd', 'pcidx'): refs.append(o[1])
        for t in refs:
            if start <= t < end: tgt.setdefault(t, []).append(i.addr)
    local, newglobal = {}, dict(pre_local)
    local.update(pre_local)
    counters = {}
    calls = {i.target for i in ins_list if i.kind == 'bsr' and i.target is not None and start <= i.target < end}
    for t in sorted(tgt):
        if t in glob_at or t in pre_local or t in mid_at: continue
        if t in calls:
            blk.errors.append('call target %06X needs a name' % t); blk.needname.append(t)
            local[t] = '.call%06X' % t
            continue
        dataT = any(s[0] == 'data' and s[1] <= t < s[2] for s in segs)
        if t not in addrs and not dataT:
            blk.errors.append('target %06X mid-instruction' % t); continue
        srcs = tgt[t]
        if any(scope(x) != scope(t) for x in srcs):
            blk.errors.append('target %06X needs a global name (called from another scope)' % t)
            continue
        sc = scope(t)
        back = any(x >= t for x in srcs)
        c = counters.setdefault(sc, {'n': 0, 'loop': 0, 'tab': 0})
        if dataT:
            c['tab'] += 1
            while ('.table' if c['tab'] == 1 else '.table%d' % c['tab']) in reserved: c['tab'] += 1
            local[t] = '.table' if c['tab'] == 1 else '.table%d' % c['tab']
        elif back:
            c['loop'] += 1
            while ('.loop' if c['loop'] == 1 else '.loop%d' % c['loop']) in reserved: c['loop'] += 1
            local[t] = '.loop' if c['loop'] == 1 else '.loop%d' % c['loop']
        else:
            c['n'] += 1
            while '.%d' % c['n'] in reserved: c['n'] += 1
            local[t] = '.%d' % c['n']
    recs = []
    names_at = dict(glob_at); names_at.update(mid_at)
    def lookup(v):
        return names_at.get(v) or local.get(v)
    for s in segs:
        if s[0] == 'code':
            for i in s[1]:
                if i.mnem == 'String':
                    r = Rec(i.addr, '\tString\t' + fmt_string(i.ops[0][1], i.ops[0][2]), i); r.norm = 'String'
                else:
                    ops = []
                    for o in i.ops:
                        ops.append(symbolize2(ctx, i, o, blk, names_at, local, start, end))
                    mn = i.mnem
                    if mn == 'cmpi.w' and i.ops[1][0] == 'dn': mn = 'cmpi'   # fixopcodes.js rewrites cmpi.w #x,dn to EA's cmp
                    r = Rec(i.addr, '\t' + mn + ('\t' + ','.join(ops) if ops else ''), i)
                    from lineage import norm_ins
                    r.norm = norm_ins(i)
                if i.addr in glob_at and not (i.addr == start and entry_label):
                    r.glabel = glob_at[i.addr]; r.header = names.get(i.addr, ('', ''))[1]
                elif i.addr == start and entry_label: r.glabel = None
                if i.addr in mid_at: r.mid = mid_at[i.addr]; r.midc = names.get(i.addr, ('', ''))[1]
                if i.addr in local: r.llabel = local[i.addr]
                if i.addr in pre_local: r.lheader = names[i.addr][1]
                recs.append(r)
        else:
            cuts = sorted({a for a in list(names_at) + list(local) if s[1] < a < s[2]})
            pieces = list(zip([s[1]] + cuts, cuts + [s[2]]))
            for pa, pb in pieces:
                rows = fmt_data(ctx, pa, pb)
                for k, t in enumerate(rows):
                    r = Rec(pa + 16 * k, t); r.norm = 'dc'
                    if k == 0:
                        if pa in glob_at and not (pa == start and entry_label): r.glabel = glob_at[pa]; r.header = names.get(pa, ('', ''))[1]
                        if pa in mid_at: r.mid = mid_at[pa]; r.midc = names.get(pa, ('', ''))[1]
                        if pa in local: r.llabel = local[pa]
                    recs.append(r)
    return recs, blk


def symbolize2(ctx, ins, op, blk, glob_at, local, start, end):
    """symbolize() with block-local labels."""
    k = op[0]
    if k in ('target', 'pcd', 'pcidx') or (k == 'absl' and False):
        t = op[1]
        nm = local.get(t) or glob_at.get(t)
        if nm is None:
            nm = name_target(ctx, t, blk, {})
        if k == 'target': return nm
        if k == 'pcd': return '%s(pc)' % nm
        return '%s(pc,%s%d.%s)' % (nm, op[2], op[3], op[4])
    if k in ('absl', 'absw'):
        v = op[1] & 0xFFFFFFFF
        if k == 'absw' and op[1] < 0: v = 0xFFFF0000 | (op[1] & 0xFFFF)
        if v in glob_at or v in local:
            nm = glob_at.get(v) or local.get(v)
            return '(%s).%s' % (nm, 'l' if k == 'absl' else 'w')
    return symbolize(ctx, ins, op, None, blk, local, STRUCTS, ins.addr)


# ----- symbols and numbers -------------------------------------------------------------------------------------------

def ev(text, syms):
    """Evaluate a small constant expression with known symbols; None when unknown."""
    t = text.strip()
    if t.startswith('#'): t = t[1:]
    t = re.sub(r'\$([0-9A-Fa-f]+)', lambda m: str(int(m.group(1), 16)), t)
    t = t.replace('<<', '<<').replace('(', ' ( ').replace(')', ' ) ')
    out = []
    for tok in re.findall(r"[A-Za-z_][\w.]*|\d+|<<|>>|[-+*()&|~/^]|\S", t):
        if re.match(r'[A-Za-z_]', tok):
            if tok in syms: out.append(str(syms[tok]))
            else: return None
        else:
            out.append(tok)
    try:
        return eval(''.join(out), {}, {})
    except Exception:
        return None


def my_imm_value(rec):
    ins = rec.ins
    if ins is None: return None
    for o in ins.ops:
        if o[0] == 'imm': return o[1]
    return None


def transplant(ctx, recs, parents):
    """Carry names and comments from the best matching parent routines into recs. Returns [(coverage, parent)]."""
    import lineage as L
    idx = [i for i, r in enumerate(recs) if r.norm and r.norm != 'dc']
    norms = [recs[i].norm for i in idx]
    found = L.covers(norms, parents)
    found.sort(key=lambda x: (-x[0] * len(x[1].norms), L.PARENTS.index(x[1].repo)))
    taken, matches = set(), []
    for cov, p, mp, plines in found:
        mine = [k for k in mp if k not in taken]
        if len(mine) < 0.6 * len(p.norms): continue
        for k in mine:
            taken.add(k)
            r, pl = recs[idx[k]], mp[k]
            ops = r.ins.ops if r.ins else []
            ok = True
            for po, o in zip(pl.ops, ops):
                if o[0] == 'imm' and po.startswith('#'):
                    v = ev(po, ctx.syms)
                    if v is not None and (v & 0xFFFFFFFF) != (o[1] & 0xFFFFFFFF): ok = False
                elif o[0] == 'disp':
                    m = re.match(r'^(.*)\(', po)
                    if m and m.group(1):
                        v = ev(m.group(1), ctx.syms)
                        if v is not None and v != o[1]: ok = False
            if not ok: continue
            if pl is plines[0]: r.suggest = p.name
            elif pl.label: r.suggest = p.name + pl.label
            if pl.comment: r.comment = pl.comment
            r.pre = [x.lstrip(';').strip() for x in (pl.pre or []) if x.strip(';').strip()]
            if r.ins and r.ins.mnem != 'String':
                for po, o in zip(pl.ops, ops):
                    if o[0] == 'imm' and po.startswith('#') and re.match(r'^#[A-Za-z_(]', po):
                        v = ev(po, ctx.syms)
                        if v is not None and (v & 0xFFFFFFFF) == (o[1] & 0xFFFFFFFF):
                            r.text = re.sub(r'#[^,]*', lambda m: po, r.text, count=1)
                            break
            if pl.label and pl.label.startswith('.') and r.llabel:
                r.want_label = pl.label
        matches.append((cov, p))
    return matches


def name_bits(ctx, recs):
    bits = {'pflags': {}, 'pflags2': {}, 'pflags3': {}}
    for n, v in ctx.syms.items():
        if re.match(r'^pf[a-z]\w*$', n) and not n.startswith('pflags') and not re.match(r'^pf[23]', n) and v < 8: bits['pflags'][v] = bits['pflags'].get(v) or n
        elif n.startswith('pf2') and v < 8: bits['pflags2'][v] = n
        elif n.startswith('pf3') and v < 8: bits['pflags3'][v] = n
    for r in recs:
        m = re.match(r'^(\t(?:btst|bset|bclr|bchg)\t)#(\d+),(.*?)(\$6[234]|pflags[23]?)\((a[0-7])\)(.*)$', r.text)
        if m:
            off = {'$62': 'pflags', '$63': 'pflags2', '$64': 'pflags3'}.get(m.group(4), m.group(4))
            nm = bits[off].get(int(m.group(2)))
            if nm: r.text = '%s#%s,%s%s(%s)%s' % (m.group(1), nm, m.group(3), off, m.group(5), m.group(6))


def wrap_header(label, text):
    pad = '\t' * max(1, -(-(36 - vis(label)) // 4))
    first = label + pad
    w = 110 - 36
    words, rows, cur = text.split(), [], ''
    for wd in words:
        if len(cur) + len(wd) + 1 > w and cur:
            rows.append(cur); cur = wd
        else:
            cur = (cur + ' ' + wd).strip()
    if cur: rows.append(cur)
    out = [first + ';' + rows[0]]
    for rr in rows[1:]: out.append('\t' * 9 + ';' + rr)
    return out


def vis(s):
    c = 0
    for ch in s:
        c = (c // 4 + 1) * 4 if ch == '\t' else c + 1
    return c


def needs_opt(ins):
    """SNASM options that must be off so this instruction keeps its retail encoding."""
    if ins is None: return set()
    out = set()
    m = ins.mnem
    if m.startswith('addi.') and ins.ops[0][0] == 'imm' and 1 <= ins.ops[0][1] <= 8: out.add('oaq')
    if m.startswith('subi.') and ins.ops[0][0] == 'imm' and 1 <= ins.ops[0][1] <= 8: out.add('osq')
    for o in ins.ops:
        if o[0] == 'disp' and o[1] == 0: out.add('oz')
        if o[0] == 'idx' and o[1] == 0 and False: out.add('oz')
    return out


def render(recs, reserved=frozenset()):
    """Lines of text; locals renamed from the parent where possible and unique within the scope."""
    # scope = since last global label
    lines, used, ren = [], set(), {}
    scope_recs = []
    # first pass: rename locals
    cur_used = set(reserved)
    for r in recs:
        if r.glabel: cur_used = set(reserved)
        if r.llabel:
            want = getattr(r, 'want_label', None)
            if want and want not in cur_used and not re.match(r'^\.\d+$', want):
                ren[(id(r), r.llabel)] = want
                cur_used.add(want)
            else:
                cur_used.add(r.llabel)
    # map old->new per scope
    scope_map, cur_map = [], {}
    maps = []
    cur = {}
    for r in recs:
        if r.glabel: cur = {}
        if r.llabel and (id(r), r.llabel) in ren: cur[r.llabel] = ren[(id(r), r.llabel)]
        maps.append(dict(cur))
    # references can appear before the label: use the complete per scope map
    full, cur_scope, scopes = [], 0, []
    sc = 0
    scope_of = []
    for r in recs:
        if r.glabel: sc += 1
        scope_of.append(sc)
    final = {}
    for r, s_ in zip(recs, scope_of):
        if r.llabel and (id(r), r.llabel) in ren: final.setdefault(s_, {})[r.llabel] = ren[(id(r), r.llabel)]
    for r, s_ in zip(recs, scope_of):
        m = final.get(s_, {})
        def sub(t):
            return re.sub(r'(?<![\w$])\.(?:\d+|loop\d*|table\d*)\b', lambda x: m.get(x.group(0), x.group(0)), t)
        if r.glabel:
            hc = getattr(r, 'header', '')
            if hc:
                lines.extend(wrap_header(r.glabel, hc))
            else:
                lines.append(r.glabel)
        if r.llabel and r.llabel in m: r.llabel = m[r.llabel]
        if getattr(r, 'mid', None):
            lines.append(r.mid + '\t' * max(1, -(-(36 - vis(r.mid + ' = *')) // 4)) + '= *' if False else (r.mid + '\tequ\t*' + (('\t;' + r.midc) if r.midc else '')))
        for p in r.pre:
            lines.append('\t;' + p if False else '\t;' + p)
        text = sub(r.text)
        code = text
        if r.llabel:
            lh = getattr(r, 'lheader', '')
            lines.extend(wrap_header(r.llabel, lh) if lh else [r.llabel])
        if r.comment:
            pad = '\t' * max(1, -(-(36 - vis(code)) // 4)) if vis(code) < 36 else '\t'
            code = code + pad + ';' + r.comment
        lines.append((code, needs_opt(r.ins) if not r.llabel and not r.glabel or True else set()))
    # wrap runs that need options off
    out, cur = [], set()
    for item in lines:
        if isinstance(item, str):
            out.append(item); continue
        code, need = item
        if need != cur:
            if cur: out.append('\topt\t' + ','.join(o + '+' for o in sorted(cur)))
            if need: out.append('\topt\t' + ','.join(o + '-' for o in sorted(need)))
            cur = need
        out.append(code)
    if cur: out.append('\topt\t' + ','.join(o + '+' for o in sorted(cur)))
    return out


def update_stub(ctx, relfile, names_needed, pending_defs):
    """Add `name = $ADDR ;file` lines for outside labels the file now uses."""
    base = os.path.splitext(os.path.basename(relfile))[0]
    p = os.path.join(ROOT, 'src', 'stubinc', base + '_stub.asm')
    if not os.path.exists(p): return []
    txt = open(p, errors='replace', newline='').read()
    crlf = '\r\n' in txt
    txt = txt.replace('\r\n', '\n')
    have = set(re.findall(r'^([A-Za-z_]\w*)\s*=', txt, re.M))
    add = []
    for n in sorted(names_needed):
        if n in have: continue
        if ctx.defs.get(n, '').replace('\\', '/') == relfile.replace('\\', '/'): continue
        if n not in ctx.lab and n not in pending_defs: continue
        a = ctx.lab.get(n, pending_defs.get(n))
        if a is None or a >= 0xFF0000: continue
        d = ctx.defs.get(n, '')
        add.append('%s = $%06X\t\t\t\t;%s' % (n, a, os.path.splitext(d.split('\\')[-1])[0]))
    if add:
        marker = '\n\n; Main segment code'
        i = txt.index(marker) if marker in txt else txt.rindex('\ninclude') if False else -1
        if i < 0:
            m = re.search(r'\n\t*include\s+[^\n]*\n*$', txt)
            i = m.start() if m else len(txt)
        txt = txt[:i].rstrip('\n') + '\n' + '\n'.join(add) + '\n' + txt[i:]
        open(p, 'w', newline='').write(txt.replace('\n', '\r\n') if crlf else txt)
    return add


SCOPE_USED = {}


def is_glob(l):
    """A line that starts a new local label scope: a global label, but not `Name = *` or `Name equ x`."""
    return bool(re.match(r'^[A-Za-z_][\w$]*', l)) and not re.match(r'^[A-Za-z_][\w$]*\s*(=|equ\b)', l, re.I)


def reserved_locals(src, i, k):
    """Local labels already used in the global scope(s) the block at src[i:k] sits in."""
    a = i
    while a > 0 and not is_glob(src[a]): a -= 1
    b = k
    while b < len(src) and not is_glob(src[b]): b += 1
    return frozenset(m.group(0) for l in src[a:b] for m in [re.match(r'^\.[\w]+', l)] if m) | SCOPE_USED.get((id(src), a), frozenset())


def scope_key(src, i):
    a = i
    while a > 0 and not is_glob(src[a]): a -= 1
    return (id(src), a)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('files', nargs='*')
    ap.add_argument('--apply', action='store_true')
    ap.add_argument('--structs', action='store_true')
    ap.add_argument('--structregs', default='2,3')
    ap.add_argument('--parents', default=os.path.dirname(ROOT))
    ap.add_argument('--no-lineage', action='store_true')
    ap.add_argument('--force', action='store_true')
    ap.add_argument('--stdout', action='store_true')
    a = ap.parse_args()
    global STRUCTS
    STRUCTS = a.structs
    global STRUCTREGS
    STRUCTREGS = tuple(int(x) for x in a.structregs.split(','))
    global HINTS
    HINTS = load_hints()
    ctx = Ctx()
    names = load_names()
    ctx.newg = {k: v[0].lstrip('=') for k, v in names.items() if not v[0].startswith('.')}
    import lineage
    parents = [] if a.no_lineage else lineage.load_parents(a.parents)
    files = a.files or sorted(glob.glob(os.path.join(ROOT, 'src', '**', '*.asm'), recursive=True))
    tot = {'blocks': 0, 'ok': 0, 'bad': 0}
    for f in files:
        f = os.path.abspath(f)
        raw = open(f, errors='replace', newline='').read()
        crlf = '\r\n' in raw
        src = raw.replace('\r\n', '\n').split('\n')
        rel = os.path.relpath(f, os.path.join(ROOT, 'src'))
        i, newsrc, changed, used_names = 0, [], False, set()
        while i < len(src):
            line = src[i]
            if MARK.search(line) and not line.startswith('\tdc') and line.lstrip().startswith(';') or (MARK.search(line) and not line.startswith('\tdc')):
                j = i + 1
                while j < len(src) and src[j].lstrip().startswith(';') and not src[j].startswith('\tdc'): j += 1
                k = j
                while k < len(src) and re.match(r'^\tdc\.[bwl]\t', src[k]): k += 1
                if k == j:
                    newsrc.append(line); i += 1; continue
                run = src[j:k]
                tot['blocks'] += 1
                cands = find_run(ctx, run)
                if len(cands) > 1:
                    # identical bytes elsewhere: take the first candidate at or after the nearest label above the block
                    b = i
                    while b > 0 and not re.match(r'^[A-Za-z_][\w$]*', src[b]): b -= 1
                    ml = re.match(r'^([A-Za-z_][\w$]*)', src[b])
                    la = ctx.lab.get(ml.group(1)) if ml else None
                    if la is not None:
                        after = sorted(c for c in cands if c >= la)
                        if after: cands = after[:1]
                if len(cands) != 1:
                    print('%s:%d: %d address candidates' % (rel, i + 1, len(cands))); tot['bad'] += 1
                    newsrc.extend(src[i:k]); i = k; continue
                start = cands[0]
                end = start + sum(len(row_bytes(ctx, r) or b'') for r in run)
                lab = ctx.a2l.get(start, [None])[0]
                segs, notes = decode_block(ctx, start, end, lab)
                recs, blk = make_records(ctx, segs, start, end, lab, names, reserved_locals(src, i, k))
                blk.errors.extend(notes)
                matches = transplant(ctx, recs, parents) if parents else []
                name_bits(ctx, recs)
                text = render(recs, reserved_locals(src, i, k))
                SCOPE_USED[scope_key(src, i)] = SCOPE_USED.get(scope_key(src, i), frozenset()) | frozenset(m.group(0) for l in text for m in [re.match(r'^\.\w+', l)] if m)
                msgs = []
                if blk.unres_ram: msgs.append('ram ' + ','.join(sorted({'%08X%s' % (v, ' ' + n if n else '') for v, n in blk.unres_ram})))
                ur = sorted({v for v in blk.unres_rom if not (start <= v < end)})
                if ur: msgs.append('rom ' + ','.join('%06X' % v for v in ur))
                ui = sorted({v for v in blk.unres_imm if not (start <= v < end)})
                if ui: msgs.append('imm ' + ','.join('%06X' % v for v in ui))
                if ur: blk.errors.append('unnamed targets outside the block')
                if blk.errors: msgs.append('; '.join(blk.errors))
                for nn in blk.needname:
                    sg = [getattr(r, 'suggest', None) for r in recs if r.addr == nn]
                    msgs.append('NAME %06X?%s' % (nn, ' ' + sg[0] if sg and sg[0] else ''))
                if matches: msgs.append('lineage ' + ','.join('%s/%s %.2f' % (p.repo[:6], p.name, c) for c, p in matches))
                print('%s:%d: %06X-%06X %d insns %s' % (rel, i + 1, start, end, sum(len(x[1]) for x in segs if x[0] == 'code'), ' | '.join(msgs)))
                tot['ok'] += 1
                bad = [e for e in blk.errors if not e.startswith('orphan')]
                if a.force: bad = []
                if a.stdout: print('\n'.join(text))
                if a.apply and not bad:
                    keep = [l for l in src[i:j] if not (MARK.search(l) and l.lstrip().startswith(';'))]
                    # drop empty-comment leftovers
                    newsrc.extend(keep); newsrc.extend(text); changed = True
                else:
                    newsrc.extend(src[i:k])
                i = k
            else:
                newsrc.append(line); i += 1
        if a.apply and changed:
            open(f, 'w', newline='').write(('\r\n' if crlf else '\n').join(newsrc))
    print(tot)


if __name__ == '__main__':
    main()
