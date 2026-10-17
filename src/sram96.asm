;	Battery save RAM. Copy it in, check it, read it and write it.

InitSaveRAM	;Called from Begin. Copy the $2000 byte save RAM (the odd bytes at SaveRAM) to M68K_RAM and check it
	;(ValidateSRAM; ValidSRAM 0 = good, -1 = bad). A bad save RAM is cleared (ClearSRAM) and read again. Two power-on
	;tests that never return: Start+A+C held writes and reads back every bit of every byte, writes $12,$34,$56,$78
	;to bytes 0-3 and flashes the screen green, or red at the first bad byte; Start+B+C held flashes green if bytes
	;0-3 are $12345678, else red
	move.l	#VBcount,(vbint).l
	move	#$2500,sr
	clr.w	(ValidSRAM).w
	jsr	(ReadJoy1).l	;get joypad buttons held
	move.w	d3,d0	;d3 = buttons held
	movea.l	#SaveRAM,a0	;move SRAM address into a0
	move.w	#$E,d3	;red ($00E), fading by 2 a frame
	move.w	#2,d4	;move 2 into d4
	cmp.b	#$E0,d0	;Start+A+C button held down
	beq.w	.setiterator	;branch if held down
	cmp.b	#$B0,d0	;Start+B+C buttons held down
	beq.w	.setiterator2	;branch if held down
	moveq	#0,d0	;move 0 into d0
	move.l	#$2000,d1	;$2000 bytes
	movea.l	#M68K_RAM,a0	;start of RAM into a0
	bsr.w	ReadSRAM	;Writes SRAM to RAM
	bsr.w	ValidateSRAM
	tst.w	(ValidSRAM).w
	bpl.w	.ex
	bsr.w	ClearSRAM
	moveq	#0,d0
	move.l	#$2000,d1
	movea.l	#M68K_RAM,a0
	bsr.w	ReadSRAM	;Writes SRAM to RAM
	bsr.w	ValidateSRAM
.ex
	rts
.setiterator
	move.w	#$1FFF,d2	;$2000 bytes
.SRAMloop
	move.w	#1,d1	;bit 0, then up to bit 7
	move.w	#7,d0
.setto80
	move.w	d1,(a0)
	cmp.b	1(a0),d1
	bne.w	.loadcolor
	lsl.w	#1,d1
	dbf	d0,.setto80
	adda.w	#2,a0
	dbf	d2,.SRAMloop
	movea.l	#SaveRAM,a0
	move.l	#$120034,(a0)+	;bytes 0-3 = $12,$34,$56,$78 (word writes: the low byte goes to the odd SRAM byte)
	move.l	#$560078,(a0)+
	move.w	#$E0,d3	;green ($0E0), fading by $20 a frame
	move.w	#$20,d4
.loadcolor
	move.w	d3,d0	;move d3 (color of flashing screen) to d0
.flashscreen
	move.l	#CRAM_W,(VDP_CTRL).l	;cram write 0: the background colour
	move.w	d0,d1
	and.w	d3,d1
	move.w	d1,(VDP_DATA).l
	bsr.w	SRAMWaitVblank	;wait a vblank
	sub.w	d4,d0
	bra.s	.flashscreen
.setiterator2
	move.w	#3,d1
.SRAMloop2
	adda.w	#1,a0	;odd byte
	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.SRAMloop2
	cmp.l	#$12345678,d0
	bne.s	.loadcolor	;branch if not equal (screen flashes red)
	move.w	#$E0,d3	;green
	move.w	#$20,d4
	bra.s	.loadcolor	;branch (screen flashes green)

SRAMWaitVblank	;Wait for the next vblank. Called from InitSaveRAM
	jsr	(vcountwait).l
	rts

VBcount	;vbint handler while InitSaveRAM runs: vcount + 1 only.
	;Code the listing does not decode: kept as bytes
	dc.b	$52,$78,$B0,$52,$4E,$73

ValidateSRAM	;Check the save RAM copy in M68K_RAM: byte $1FFF must be the sum of bytes 0-$1FFD and byte $1FFE its
	;complement. ValidSRAM = 0 if they match, -1 if not. Called from InitSaveRAM
	move.w	#$1FFD,d1	;bytes 0-$1FFD
	clr.w	d0	;clear d0
	lea	(M68K_RAM).l,a0	;set a0 to start of RAM
.loop
	add.b	(a0)+,d0	;add value at a0 to d0 and increment a0
	dbf	d1,.loop	;loop through RAM d1 times
	clr.w	d1	;clear d1
	cmp.b	1(a0),d0	;compare data at 1+a0 ($1FFF) to d0
	beq.w	.0	;branch if equal
	addq.w	#1,d1	;add 1 to d1
.0
	not.w	d0	;toggle bits in d0 from 1->0 and vice-versa
	cmp.b	(a0),d0	;compare byte at a0 ($1FFE) with d0
	beq.w	.1	;branch if equal
	addq.w	#1,d1	;add 1 to d1 if not
.1
	swap	d0	;swap d0 word size
	move.b	(a0),d0	;move data at a0 into d0
	not.b	d0	;toggle bits
	cmp.b	1(a0),d0	;compare data a0+1 with d0
	beq.w	.2	;branch if equal
	addq.w	#1,d1	;add 1 to d1 if not
.2
	swap	d0	;swap d0 word size
	tst.w	d1	;test d1
	bne.w	.3	;branch if d1 not 0
	clr.w	(ValidSRAM).w
	bra.w	.4
.3
	st	(ValidSRAM).w
.4
	rts

ClearSRAM	;Clear RAM $0-$1FFF and the save RAM, then write the defaults: the options (OptPlayMode ...) to save RAM
	;$1EC6, the rosters (DefaultRosters) and the saved tables, then MakeSRAMChecksum. Called from InitSaveRAM
	bset	#6,(GameFlags).w
	lea	(M68K_RAM).l,a0
	move.l	#$7FF,d0	;$800 longs
	clr.l	d1
.loop
	move.l	d1,(a0)+
	dbf	d0,.loop
	moveq	#0,d0
	move.l	#$2000,d1
	movea.l	#M68K_RAM,a0
	bsr.w	WriteSRAM
	clr.w	(OptPlayMode).w
	clr.w	(OptNOP).w
	move.w	#6,(Opt1team).w
	move.w	#$C,(Opt2team).w
	clr.w	(OptPerlen).w
	clr.w	(OptGoalie).w
	clr.w	(OptUserRec).w
	move.w	#1,(OptPen).w
	clr.w	(OptLine).w
	clr.w	(OptFighting).w
	move.w	#1,(OptSkill).w
	clr.w	(OptRosters).w
	movea.l	#OptPlayMode,a0
	move.l	#$1EC6,d0
	moveq	#$18,d1
	jsr	(WriteSRAM).l
	jsr	(DefaultRosters).l
	move.l	#$57C,d1
	move.l	#$1550,d0
	movea.l	#M68K_RAM+$1550,a0
	bsr.w	WriteSRAM
	moveq	#$34,d1
	move.l	#$1ACC,d0
	movea.l	#M68K_RAM+$1ACC,a0
	bsr.w	WriteSRAM
	move.l	#$2BE,d1
	move.l	#$1B00,d0
	movea.l	#M68K_RAM+$1B00,a0
	bsr.w	WriteSRAM
	jsr	(NullSaveClear).l
	jsr	(ClearCreatedPlayers).l
	move.l	#$DB4,d0
	moveq	#$28,d1
	movea.l	#M68K_RAM+$DB4,a0
	bsr.w	WriteSRAM
	clr.l	(SeasonDay).w
	clr.l	(dword_FFDD82).w
	clr.w	(SeasonDay+8).w
	move.b	#$FF,(dword_FFDD82+2).w
	bset	#6,(GameFlags).w
	jsr	(WriteSeasonHeader).l
	bclr	#6,(GameFlags).w
	move.l	#$AB,d0
	move.l	#$F700,d1
	move.w	#8,d2
	jsr	(WriteSRAMBits).l
	bclr	#6,(GameFlags).w
	bsr.w	MakeSRAMChecksum
	rts

WriteSRAM	;Write d1 bytes from a0 to save RAM byte d0 on (each byte is the odd byte of a word at SaveRAM + d0 * 2)
	movem.l	d0-d2/a0-a1,-(sp)
	movea.l	#SaveRAM,a1
	add.l	d0,d0
	subq.l	#1,d1
	clr.w	d2
.loop
	move.b	(a0)+,d2
	move.w	d2,(a1,d0.w)
	addq.w	#2,d0
	dbf	d1,.loop
	movem.l	(sp)+,d0-d2/a0-a1
	rts

MakeSRAMChecksum	;Sum save RAM bytes 0-$1FFD, put the sum in SRAMChecksum+1 and its complement in SRAMChecksum, and
	;write those two bytes to save RAM $1FFE. Skipped while GameFlags bit 6 is set (a batch of save RAM writes)
	btst	#6,(GameFlags).w
	bne.w	.x
	move.w	d2,-(sp)
	movea.l	#SaveRAM,a0
	move.l	#$1FFD,d1
	clr.l	d0
.0
	move.w	(a0)+,d2
	add.b	d2,d0
	dbf	d1,.0
	move.w	(sp)+,d2
	movea.l	#SRAMChecksum,a0
	move.b	d0,1(a0)
	not.w	d0
	move.b	d0,(a0)
	moveq	#2,d1
	move.l	#$1FFE,d0
	bsr.s	WriteSRAM
.x
	rts

ReadSRAM	;Copy d1 save RAM bytes from byte d0 (the odd bytes at SaveRAM + d0 * 2) to (a0)+
	movem.l	d0-d2/a0-a1,-(sp)
	movea.l	#SaveRAM,a1
	add.l	d0,d0
	subq.l	#1,d1
.0
	move.b	1(a1,d0.w),d2
	move.b	d2,(a0)+
	addq.w	#2,d0
	dbf	d1,.0
	movem.l	(sp)+,d0-d2/a0-a1
	rts

ClearSRAMBytes	;Clear d1 save RAM bytes from byte d0
	movem.l	d0-d2/a0-a1,-(sp)
	movea.l	#SaveRAM,a1
	add.l	d0,d0
	subq.l	#1,d1
.0
	clr.w	(a1,d0.w)
	addq.w	#2,d0
	dbf	d1,.0
	movem.l	(sp)+,d0-d2/a0-a1
	rts
