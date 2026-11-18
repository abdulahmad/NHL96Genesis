#!/usr/bin/env python3
"""m68kdis.py: a small 68000 disassembler that writes SNASM68k-style source.

Used by decode_code.py (turns code that the source keeps as dc.b bytes into real assembly) and by
check_code_as_data.py (flags dc.b runs that decode cleanly as 68000 code).

An instruction is decoded to an Insn: addr, size, mnem (with .b/.w/.l/.s suffix, SNASM68k spelling), ops (operand
tuples), and `kind` for flow control (None, 'bra', 'bcc', 'bsr', 'jsr', 'jmp', 'rts', 'dbcc'). Operand tuples:
  ('dn',n) ('an',n) ('ind',n) ('post',n) ('pre',n) ('disp',d,n) ('idx',d,n,'d'|'a',reg,'w'|'l')
  ('absw',v) ('absl',v) ('pcd',target) ('pcidx',target,'d'|'a',reg,'w'|'l') ('imm',v,size) ('sr',) ('ccr',) ('usp',)
  ('reglist',mask,predec) ('target',addr)
"""
import struct

CC = ['t', 'f', 'hi', 'ls', 'cc', 'cs', 'ne', 'eq', 'vc', 'vs', 'pl', 'mi', 'ge', 'lt', 'gt', 'le']


class Bad(Exception):
    pass


class Insn:
    def __init__(self, addr, size, mnem, ops, kind=None, target=None):
        self.addr, self.size, self.mnem, self.ops, self.kind, self.target = addr, size, mnem, ops, kind, target

    def __repr__(self):
        return '%06X %s %s' % (self.addr, self.mnem, self.ops)


class Reader:
    def __init__(self, data, base, pos, limit):
        self.d, self.base, self.p, self.limit = data, base, pos, limit

    def w(self):
        if self.p + 2 > self.limit:
            raise Bad('eof')
        v = struct.unpack_from('>H', self.d, self.p)[0]
        self.p += 2
        return v

    def sw(self):
        v = self.w()
        return v - 0x10000 if v & 0x8000 else v

    def l(self):
        return (self.w() << 16) | self.w()


def sext(v, bits):
    return v - (1 << bits) if v & (1 << (bits - 1)) else v


def ea_op(r, mode, reg, size):
    """Decode an effective address; size is 'b','w','l' (used for immediates)."""
    if mode == 0: return ('dn', reg)
    if mode == 1: return ('an', reg)
    if mode == 2: return ('ind', reg)
    if mode == 3: return ('post', reg)
    if mode == 4: return ('pre', reg)
    if mode == 5: return ('disp', r.sw(), reg)
    if mode == 6:
        ext = r.w()
        if ext & 0x100: raise Bad('68020 extension')
        return ('idx', sext(ext & 0xFF, 8), reg, 'a' if ext & 0x8000 else 'd', (ext >> 12) & 7,
                'l' if ext & 0x800 else 'w')
    if mode == 7:
        if reg == 0: return ('absw', r.sw())
        if reg == 1: return ('absl', r.l())
        if reg == 2:
            at = r.base + (r.p - 0)  # filled by caller: pc value is address of the extension word
            return ('pcd_raw', r.sw(), at)
        if reg == 3:
            at = r.base + r.p
            ext = r.w()
            if ext & 0x100: raise Bad('68020 extension')
            return ('pcidx_raw', sext(ext & 0xFF, 8), at, 'a' if ext & 0x8000 else 'd', (ext >> 12) & 7,
                    'l' if ext & 0x800 else 'w')
        if reg == 4:
            if size == 'b': return ('imm', r.w() & 0xFF, 'b')
            if size == 'w': return ('imm', r.w(), 'w')
            return ('imm', r.l(), 'l')
    raise Bad('ea')


class Dis:
    """Disassemble one instruction at file offset `off` (address `addr`)."""

    def __init__(self, data, org=0):
        self.data, self.org = data, org

    def one(self, addr, limit=None):
        off = addr - self.org
        limit = (limit - self.org) if limit is not None else len(self.data)
        r = Reader(self.data, self.org, off, limit)
        # base for pc-relative: address of the extension word = org + position of that word
        r.base = self.org
        op = r.w()
        ins = self._decode(r, op, addr)
        ins.size = r.p - off
        # resolve pc relative operands
        ops = []
        for o in ins.ops:
            if o[0] == 'pcd_raw':
                ops.append(('pcd', o[2] + o[1]))
            elif o[0] == 'pcidx_raw':
                ops.append(('pcidx', o[2] + o[1], o[3], o[4], o[5]))
            else:
                ops.append(o)
        ins.ops = ops
        return ins

    # ------------------------------------------------------------------
    def _decode(self, r, op, addr):
        g = op >> 12
        mode, reg = (op >> 3) & 7, op & 7
        rx = (op >> 9) & 7
        SZ = {0: 'b', 1: 'w', 2: 'l'}
        if g == 0:
            return self._g0(r, op, addr)
        if g in (1, 2, 3):
            sz = {1: 'b', 3: 'w', 2: 'l'}[g]
            src = ea_op(r, mode, reg, sz)
            dm, dr = (op >> 6) & 7, (op >> 9) & 7
            if dm == 1:
                if sz == 'b': raise Bad('movea.b')
                dst = ('an', dr)
                return Insn(addr, 0, 'movea.' + sz, [src, dst])
            dst = ea_op(r, dm, dr, sz)
            if dm == 7 and dr > 1: raise Bad('move dst')
            if dm == 1: raise Bad('x')
            return Insn(addr, 0, 'move.' + sz, [src, dst])
        if g == 4:
            return self._g4(r, op, addr)
        if g == 5:
            sz = (op >> 6) & 3
            if sz == 3:
                cc = (op >> 8) & 15
                if mode == 1:
                    disp = r.sw()
                    t = addr + 2 + disp
                    return Insn(addr, 0, 'db' + CC[cc],
                                [('dn', reg), ('target', t)], 'dbcc', t)
                dst = ea_op(r, mode, reg, 'b')
                if mode == 1 or (mode == 7 and reg > 1): raise Bad('scc')
                return Insn(addr, 0, 's' + CC[cc], [dst])
            n = (op >> 9) & 7 or 8
            m = 'subq' if op & 0x100 else 'addq'
            dst = ea_op(r, mode, reg, SZ[sz])
            if mode == 1 and sz == 0: raise Bad('addq.b an')
            if mode == 7 and reg > 1: raise Bad('addq ea')
            return Insn(addr, 0, m + '.' + SZ[sz], [('imm', n, 'q'), dst])
        if g == 6:
            cc = (op >> 8) & 15
            d8 = op & 0xFF
            if d8 == 0:
                d = r.sw(); t = addr + 2 + d; suf = '.w'
            elif d8 == 0xFF:
                raise Bad('68020 long branch')
            else:
                d = sext(d8, 8); t = addr + 2 + d; suf = '.s'
            if cc == 0: return Insn(addr, 0, 'bra' + suf, [('target', t)], 'bra', t)
            if cc == 1: return Insn(addr, 0, 'bsr' + suf, [('target', t)], 'bsr', t)
            return Insn(addr, 0, 'b' + CC[cc] + suf, [('target', t)], 'bcc', t)
        if g == 7:
            if op & 0x100: raise Bad('moveq')
            return Insn(addr, 0, 'moveq', [('imm', sext(op & 0xFF, 8), 'q'), ('dn', rx)])
        if g in (8, 12):
            return self._g8c(r, op, addr, g)
        if g in (9, 13):
            return self._g9d(r, op, addr, g)
        if g == 11:
            return self._gb(r, op, addr)
        if g == 14:
            return self._ge(r, op, addr)
        raise Bad('opcode')

    def _g0(self, r, op, addr):
        mode, reg = (op >> 3) & 7, op & 7
        rx = (op >> 9) & 7
        SZ = {0: 'b', 1: 'w', 2: 'l'}
        if op & 0x100:
            if mode == 1:
                # movep
                d = r.sw()
                sz = 'l' if op & 0x40 else 'w'
                if op & 0x80:
                    return Insn(addr, 0, 'movep.' + sz, [('dn', rx), ('disp', d, reg)])
                return Insn(addr, 0, 'movep.' + sz, [('disp', d, reg), ('dn', rx)])
            bt = ['btst', 'bchg', 'bclr', 'bset'][(op >> 6) & 3]
            ea = ea_op(r, mode, reg, 'b')
            if mode == 1 or (mode == 7 and reg == 4 and bt != 'btst'): raise Bad('bit')
            return Insn(addr, 0, bt, [('dn', rx), ea])
        t = (op >> 9) & 7
        if t == 4:
            bt = ['btst', 'bchg', 'bclr', 'bset'][(op >> 6) & 3]
            n = r.w() & 0xFF
            ea = ea_op(r, mode, reg, 'b')
            if mode == 1: raise Bad('bit')
            return Insn(addr, 0, bt, [('imm', n, 'b'), ea])
        names = {0: 'ori', 1: 'andi', 2: 'subi', 3: 'addi', 5: 'eori', 6: 'cmpi'}
        if t not in names: raise Bad('g0')
        sz = (op >> 6) & 3
        if sz == 3: raise Bad('g0 size')
        s = SZ[sz]
        if mode == 7 and reg == 4:
            if t in (0, 1, 5) and sz in (0, 1):
                v = r.w()
                if sz == 0: return Insn(addr, 0, names[t] + '.b', [('imm', v & 0xFF, 'b'), ('ccr',)])
                return Insn(addr, 0, names[t] + '.w', [('imm', v, 'w'), ('sr',)])
            raise Bad('g0 imm')
        imm = ea_op(r, 7, 4, s)
        ea = ea_op(r, mode, reg, s)
        if mode == 1 or (mode == 7 and reg > 1 and t != 6) or (mode == 7 and reg > 3): raise Bad('g0 ea')
        return Insn(addr, 0, names[t] + '.' + s, [imm, ea])

    def _g4(self, r, op, addr):
        mode, reg = (op >> 3) & 7, op & 7
        rx = (op >> 9) & 7
        SZ = {0: 'b', 1: 'w', 2: 'l'}
        if op == 0x4E71: return Insn(addr, 0, 'nop', [])
        if op == 0x4E75: return Insn(addr, 0, 'rts', [], 'rts')
        if op == 0x4E73: return Insn(addr, 0, 'rte', [], 'rts')
        if op == 0x4E77: return Insn(addr, 0, 'rtr', [], 'rts')
        if op == 0x4E76: return Insn(addr, 0, 'trapv', [])
        if op == 0x4E70: return Insn(addr, 0, 'reset', [])
        if op == 0x4E72: return Insn(addr, 0, 'stop', [('imm', r.w(), 'w')])
        if op == 0x4AFC: return Insn(addr, 0, 'illegal', [])
        if (op & 0xFFF0) == 0x4E40: return Insn(addr, 0, 'trap', [('imm', op & 15, 'q')])
        if (op & 0xFFF8) == 0x4E50: return Insn(addr, 0, 'link', [('an', reg), ('imm', r.sw(), 'w')])
        if (op & 0xFFF8) == 0x4E58: return Insn(addr, 0, 'unlk', [('an', reg)])
        if (op & 0xFFF8) == 0x4E60: return Insn(addr, 0, 'move.l', [('an', reg), ('usp',)])
        if (op & 0xFFF8) == 0x4E68: return Insn(addr, 0, 'move.l', [('usp',), ('an', reg)])
        if (op & 0xFFC0) == 0x4E80:
            ea = ea_op(r, mode, reg, 'l'); self._ctl(mode, reg)
            return Insn(addr, 0, 'jsr', [ea], 'jsr')
        if (op & 0xFFC0) == 0x4EC0:
            ea = ea_op(r, mode, reg, 'l'); self._ctl(mode, reg)
            return Insn(addr, 0, 'jmp', [ea], 'jmp')
        if (op & 0xFFF8) == 0x4840: return Insn(addr, 0, 'swap', [('dn', reg)])
        if (op & 0xFFC0) == 0x4840:
            ea = ea_op(r, mode, reg, 'l'); self._ctl(mode, reg)
            return Insn(addr, 0, 'pea', [ea])
        if (op & 0xFFF8) in (0x4880, 0x48C0):
            return Insn(addr, 0, 'ext.' + ('w' if (op & 0xFFF8) == 0x4880 else 'l'), [('dn', reg)])
        if (op & 0xFB80) == 0x4880:
            mask = r.w()
            sz = 'l' if op & 0x40 else 'w'
            if op & 0x400:
                ea = ea_op(r, mode, reg, sz)
                if mode in (0, 1, 4) or (mode == 7 and reg > 3): raise Bad('movem')
                return Insn(addr, 0, 'movem.' + sz, [ea, ('reglist', mask, False)])
            ea = ea_op(r, mode, reg, sz)
            if mode in (0, 1, 3) or (mode == 7 and reg > 1): raise Bad('movem')
            return Insn(addr, 0, 'movem.' + sz, [('reglist', mask, mode == 4), ea])
        if (op & 0xF1C0) == 0x41C0:
            ea = ea_op(r, mode, reg, 'l'); self._ctl(mode, reg)
            return Insn(addr, 0, 'lea', [ea, ('an', rx)])
        if (op & 0xF1C0) == 0x4180:
            ea = ea_op(r, mode, reg, 'w')
            if mode == 1: raise Bad('chk')
            return Insn(addr, 0, 'chk', [ea, ('dn', rx)])
        if (op & 0xFFC0) == 0x40C0:
            return Insn(addr, 0, 'move.w', [('sr',), ea_op(r, mode, reg, 'w')])
        if (op & 0xFFC0) == 0x44C0:
            return Insn(addr, 0, 'move.w', [ea_op(r, mode, reg, 'w'), ('ccr',)])
        if (op & 0xFFC0) == 0x46C0:
            return Insn(addr, 0, 'move.w', [ea_op(r, mode, reg, 'w'), ('sr',)])
        if (op & 0xFFC0) == 0x4AC0:
            ea = ea_op(r, mode, reg, 'b')
            if mode == 1: raise Bad('tas')
            return Insn(addr, 0, 'tas', [ea])
        if (op & 0xFFC0) == 0x4800:
            ea = ea_op(r, mode, reg, 'b')
            if mode == 1: raise Bad('nbcd')
            return Insn(addr, 0, 'nbcd', [ea])
        names = {0x4000: 'negx', 0x4200: 'clr', 0x4400: 'neg', 0x4600: 'not', 0x4A00: 'tst'}
        base = op & 0xFF00
        sz = (op >> 6) & 3
        if base in names and sz != 3:
            ea = ea_op(r, mode, reg, SZ[sz])
            if mode == 1 and base != 0x4A00: raise Bad('g4 an')
            if mode == 7 and reg > 1 and base != 0x4A00: raise Bad('g4 ea')
            if mode == 1 and sz == 0: raise Bad('tst.b an')
            return Insn(addr, 0, names[base] + '.' + SZ[sz], [ea])
        raise Bad('g4')

    def _ctl(self, mode, reg):
        if mode in (0, 1, 3, 4) or (mode == 7 and reg > 3): raise Bad('control ea')

    def _g8c(self, r, op, addr, g):
        mode, reg = (op >> 3) & 7, op & 7
        rx = (op >> 9) & 7
        SZ = {0: 'b', 1: 'w', 2: 'l'}
        opm = (op >> 6) & 7
        base = 'or' if g == 8 else 'and'
        if opm in (3, 7):
            n = ('divu', 'divs')[opm == 7] if g == 8 else ('mulu', 'muls')[opm == 7]
            ea = ea_op(r, mode, reg, 'w')
            if mode == 1: raise Bad('mul an')
            return Insn(addr, 0, n + '.w', [ea, ('dn', rx)])
        if (op & 0x1F0) == 0x100:
            n = 'sbcd' if g == 8 else 'abcd'
            if mode == 0: return Insn(addr, 0, n, [('dn', reg), ('dn', rx)])
            if mode == 1: return Insn(addr, 0, n, [('pre', reg), ('pre', rx)])
        if g == 12 and opm in (5, 6, 1) and (op & 0x130) == 0x100:
            if opm == 5 and mode == 0: return Insn(addr, 0, 'exg', [('dn', rx), ('dn', reg)])
            if opm == 5 and mode == 1: return Insn(addr, 0, 'exg', [('an', rx), ('an', reg)])
            if opm == 6 and mode == 1: return Insn(addr, 0, 'exg', [('dn', rx), ('an', reg)])
        s = SZ[opm & 3]
        ea = ea_op(r, mode, reg, s)
        if mode == 1: raise Bad('and an')
        if opm < 3:
            return Insn(addr, 0, base + '.' + s, [ea, ('dn', rx)])
        if mode == 0 or (mode == 7 and reg > 1): raise Bad('and dst')
        return Insn(addr, 0, base + '.' + s, [('dn', rx), ea])

    def _g9d(self, r, op, addr, g):
        mode, reg = (op >> 3) & 7, op & 7
        rx = (op >> 9) & 7
        SZ = {0: 'b', 1: 'w', 2: 'l'}
        opm = (op >> 6) & 7
        base = 'sub' if g == 9 else 'add'
        if opm in (3, 7):
            s = 'w' if opm == 3 else 'l'
            ea = ea_op(r, mode, reg, s)
            return Insn(addr, 0, base + 'a.' + s, [ea, ('an', rx)])
        s = SZ[opm & 3]
        if opm >= 4 and mode in (0, 1):
            if mode == 0: return Insn(addr, 0, base + 'x.' + s, [('dn', reg), ('dn', rx)])
            return Insn(addr, 0, base + 'x.' + s, [('pre', reg), ('pre', rx)])
        ea = ea_op(r, mode, reg, s)
        if opm < 3:
            if mode == 1 and s == 'b': raise Bad('byte an')
            return Insn(addr, 0, base + '.' + s, [ea, ('dn', rx)])
        if mode == 0 or mode == 1 or (mode == 7 and reg > 1): raise Bad('dst')
        return Insn(addr, 0, base + '.' + s, [('dn', rx), ea])

    def _gb(self, r, op, addr):
        mode, reg = (op >> 3) & 7, op & 7
        rx = (op >> 9) & 7
        SZ = {0: 'b', 1: 'w', 2: 'l'}
        opm = (op >> 6) & 7
        if opm in (3, 7):
            s = 'w' if opm == 3 else 'l'
            ea = ea_op(r, mode, reg, s)
            return Insn(addr, 0, 'cmpa.' + s, [ea, ('an', rx)])
        s = SZ[opm & 3]
        if opm < 3:
            ea = ea_op(r, mode, reg, s)
            if mode == 1 and s == 'b': raise Bad('cmp.b an')
            return Insn(addr, 0, 'cmp.' + s, [ea, ('dn', rx)])
        if mode == 1:
            return Insn(addr, 0, 'cmpm.' + s, [('post', reg), ('post', rx)])
        ea = ea_op(r, mode, reg, s)
        if mode == 7 and reg > 1: raise Bad('eor dst')
        return Insn(addr, 0, 'eor.' + s, [('dn', rx), ea])

    def _ge(self, r, op, addr):
        mode, reg = (op >> 3) & 7, op & 7
        rx = (op >> 9) & 7
        SZ = {0: 'b', 1: 'w', 2: 'l'}
        names = ['as', 'ls', 'rox', 'ro']
        d = 'l' if op & 0x100 else 'r'
        if ((op >> 6) & 3) == 3:
            if op & 0x800: raise Bad('bitfield')
            t = names[(op >> 9) & 3]
            ea = ea_op(r, mode, reg, 'w')
            if mode in (0, 1) or (mode == 7 and reg > 1): raise Bad('shift ea')
            return Insn(addr, 0, t + d + '.w', [ea])
        s = SZ[(op >> 6) & 3]
        t = names[(op >> 3) & 3]
        if op & 0x20:
            return Insn(addr, 0, t + d + '.' + s, [('dn', rx), ('dn', reg)])
        return Insn(addr, 0, t + d + '.' + s, [('imm', rx or 8, 'q'), ('dn', reg)])


def reglist_text(mask, predec):
    """movem register list. For predecrement the mask is bit-reversed (bit 0 = a7)."""
    if predec:
        mask = int('{:016b}'.format(mask)[::-1], 2)
    regs = [('d%d' % i) for i in range(8)] + [('a%d' % i) for i in range(8)]
    out = []
    i = 0
    while i < 16:
        if mask >> i & 1:
            j = i
            while j + 1 < 16 and (mask >> (j + 1) & 1) and (j + 1) // 8 == i // 8:
                j += 1
            out.append(regs[i] if i == j else '%s-%s' % (regs[i], regs[j]))
            i = j + 1
        else:
            i += 1
    return '/'.join(out)
