;	The playoff tree and the saved series. ContinuePlayoffs reads the bits,
;	maketree builds the bracket, and ResolveGames picks the winners.

ContinuePlayoffs	;Continue the playoffs: read the saved bits (ReadPassBits)
	movem.l	d0-d7/a0-a3,-(sp)
	movea.l	#$FFFFD296,a3
	bsr.w	ReadPassBits
	move.w	(gamelevel).w,d0
	or.w	(bosgames).w,d0
	beq.w	.x
	bsr.w	maketree
	moveq	#7,d0
	tst.w	(FourWayPlay).w
	beq.w	.0
	move.w	#$B,d0
.0
	tst.w	(FourWayPlay).w
	bne.w	.1
	cmpi.w	#2,(pojoy).w
	ble.w	.set
	subq.w	#2,(pojoy).w
	bra.w	.set
.1
	cmpi.w	#1,(pojoy).w
	bne.w	.2
	move.w	#3,(pojoy).w
	bra.w	.set
.2
	cmpi.w	#2,(pojoy).w
	bne.w	.set
	move.w	#4,(pojoy).w
.set
	sub.w	(pojoy).w,d0
	move.w	d0,(OptNOP).w
.x
	movem.l	(sp)+,d0-d7/a0-a3
	rts

NewPO	;New playoff tree
	btst	#7,(GameFlags).w
	beq.w	.1
	jsr	(BeginPlayoffs).l
	btst	#1,(sflags11).w
	beq.w	.0
	rts
.0
	move.w	(dword_FFDD82+2).w,(Opt1team).w
	movea.l	#$FFFFD130,a0
	moveq	#$57,d0
	moveq	#$10,d1
	jsr	(ReadSRAM).l
	clr.w	(Opt1team).w
	move.b	(dword_FFDD82+2).w,(Opt1team+1).w
	bra.w	.2
.1
	move.l	#$E5E,d0
	moveq	#$A,d1
	jsr	(ClearSRAMBytes).l
	jsr	(MakeSRAMChecksum).l
	moveq	#$20,d0
	bsr.w	randomd0
.top
	addq.w	#1,d0
	andi.w	#$1F,d0
	asl.w	#4,d0
	movea.l	#$54F0,a0
	adda.w	d0,a0
	lsr.w	#4,d0
.2
	moveq	#$F,d1
	move.w	(Opt1team).w,d2
	cmp.w	#$19,d2
	bls.w	.loop
	moveq	#$19,d2
.loop
	cmp.b	(a0)+,d2
	dbeq	d1,.loop
	bne.s	.top
	eori.w	#$F,d1
	move.w	d1,(potreeteam).w
	move.w	d0,(postarts).w
	clr.w	(gamelevel).w
	btst	#7,(GameFlags).w
	bne.w	.3
	move.w	#7,(bosgames).w
	cmpi.w	#2,(OptPlayMode).w
	beq.w	.4
.3
	clr.w	(bosgames).w
	moveq	#7,d0
	movea.w	#(gsstruct-M68K_RAM),a0
.cg
	clr.w	4(a0)
	clr.w	6(a0)
	adda.w	#$10,a0
	dbf	d0,.cg
.4
	clr.w	(WinBits).w

maketree	;Make the playoff tree (potree) from the playoff seeds and WinBits, then FigureJoy; with GameFlags bit 7
	;the seeds come from save RAM. Called after ResolveGames, ResolveDayGames and BeginPlayoffs
	movem.l	d0-d4/a0-a3,-(sp)
	btst	#7,(GameFlags).w
	beq.w	.0
	btst	#2,(SeasonFlags).w
	beq.w	.nogames
	movea.l	#$FFFFD130,a0
	moveq	#$57,d0
	moveq	#$10,d1
	jsr	(ReadSRAM).l
.0
	move.w	(postarts).w,d1
	asl.w	#4,d1
	movea.w	#(potree-M68K_RAM),a0
	movea.l	#$54F0,a1
	adda.w	d1,a1
	btst	#7,(GameFlags).w
	beq.w	.1
	movea.l	#$FFFFD130,a1
.1
	movem.l	d5-d6/a4-a5,-(sp)
	movea.l	#$FFFFD108,a5
	movea.l	#FirstRoundSeeds,a4
	move.l	(a4),(a5)
	move.l	4(a4),4(a5)
	move.l	8(a4),8(a5)
	move.l	$C(a4),$C(a5)
	lea	$10(a5),a4
	move.l	(a1),(a0)
	move.l	4(a1),4(a0)
	move.l	8(a1),8(a0)
	move.l	$C(a1),$C(a0)
	lea	$10(a0),a1
	moveq	#$E,d2
	move.w	(WinBits).w,d0

.loop
	move.w	d0,d1
	andi.w	#1,d1
	move.b	(a0,d1.w),(a1)+
	move.b	(a5,d1.w),(a4)+
	addq.w	#2,a0
	addq.l	#2,a5
	cmp.w	#$B,d2
	beq.w	.reseed4
	cmp.w	#7,d2
	beq.w	.reseed4
	cmp.w	#5,d2
	beq.w	.reseed2
	cmp.w	#3,d2
	beq.w	.reseed2
	cmp.w	#1,d2
	beq.w	.final
	bra.w	.next
.final
	btst	#7,(GameFlags).w
	beq.w	.next
	bsr.w	.bypoints
	bra.w	.next

.bypoints
	movem.l	d0-d3,-(sp)
	clr.l	d1
	move.b	-2(a4),d1
	mulu.w	#7,d1
	addi.l	#$63D0,d1
	moveq	#7,d2
	jsr	(ReadSRAMBits).l
	add.l	d0,d0
	move.l	d0,-(sp)
	clr.l	d1
	move.b	-2(a4),d1
	mulu.w	#7,d1
	addi.l	#$653C,d1
	moveq	#7,d2
	jsr	(ReadSRAMBits).l
	add.l	(sp)+,d0
	move.l	d0,d5
	clr.l	d1
	move.b	-1(a4),d1
	mulu.w	#7,d1
	addi.l	#$63D0,d1
	moveq	#7,d2
	jsr	(ReadSRAMBits).l
	add.l	d0,d0
	move.l	d0,-(sp)
	clr.l	d1
	move.b	-1(a4),d1
	mulu.w	#7,d1
	addi.l	#$653C,d1
	moveq	#7,d2
	jsr	(ReadSRAMBits).l
	add.l	(sp)+,d0
	move.l	d0,d6
	cmp.w	d5,d6
	bge.w	.keep
	move.b	-1(a4),d5
	move.b	-2(a4),-1(a4)
	move.b	d5,-2(a4)
.keep
	movem.l	(sp)+,d0-d3
	rts

.reseed2
	move.b	-2(a4),d5
	cmp.b	-1(a4),d5
	bge.w	.next
	move.b	-1(a4),d6
	move.b	d5,-1(a4)
	move.b	d6,-2(a4)
	move.b	-2(a1),d5
	move.b	-1(a1),d6
	move.b	d5,-1(a1)
	move.b	d6,-2(a1)
	bra.w	.next

.reseed4
	clr.w	d6
	move.b	-4(a4),d5
	cmp.b	-3(a4),d5
	ble.w	.p1
	move.b	-3(a4),d6
	move.b	d5,-3(a4)
	move.b	d6,-4(a4)
	move.b	-3(a1),-(sp)
	move.b	-4(a1),-3(a1)
	move.b	(sp)+,-4(a1)
.p1
	move.b	-3(a4),d5
	cmp.b	-2(a4),d5
	ble.w	.p2
	move.b	-2(a4),d6
	move.b	d5,-2(a4)
	move.b	d6,-3(a4)
	move.b	-3(a1),-(sp)
	move.b	-2(a1),-3(a1)
	move.b	(sp)+,-2(a1)
.p2
	move.b	-2(a4),d5
	cmp.b	-1(a4),d5
	ble.w	.p3
	move.b	-1(a4),d6
	move.b	d5,-1(a4)
	move.b	d6,-2(a4)
	move.b	-2(a1),-(sp)
	move.b	-1(a1),-2(a1)
	move.b	(sp)+,-1(a1)
.p3
	tst.w	d6
	bne.s	.reseed4
	move.b	-4(a4),d5
	move.b	-4(a1),d6
	move.b	-3(a4),-4(a4)
	move.b	-3(a1),-4(a1)
	move.b	d5,-3(a4)
	move.b	d6,-3(a1)
	move.b	-4(a4),d5
	move.b	-4(a1),d6
	move.b	-1(a4),-4(a4)
	move.b	-1(a1),-4(a1)
	move.b	d5,-1(a4)
	move.b	d6,-1(a1)

.next
	lsr.w	#1,d0
	dbf	d2,.loop
	btst	#7,(GameFlags).w
	beq.w	.nofinal
	movea.l	#$FFFFCFF0,a4
	bsr.w	.bypoints
.nofinal
	movem.l	(sp)+,d5-d6/a4-a5
	bsr.w	GetShifter
	tst.w	d1
	bmi.w	.nogames
	movea.w	#(potree-M68K_RAM),a0
	adda.w	d2,a0
	adda.w	d2,a0
	movea.w	#(gsstruct-M68K_RAM),a1
.games
	clr.w	$A(a1)
	clr.w	$C(a1)
	clr.w	8(a1)
	bclr	#1,$E(a1)
	bsr.w	SetTreeGameTeams
	adda.w	#$10,a1
	dbf	d1,.games
	bsr.w	FigureJoy

.nogames
	movem.l	(sp)+,d0-d4/a0-a3
	rts

FirstRoundSeeds	;The seed of each first round team in tree order (1-8, 4-5, 3-6, 2-7), both conferences; maketree copies it
	dc.b	$08,$01,$05,$04,$06,$03,$07,$02,$08,$01,$05,$04,$06,$03,$07,$02

SetTreeGameTeams	;Put the two teams at a0 in game a1: flipped (gsstruct flags bit 0) except for bosgames 2, 3 and 5
	cmpi.w	#2,(bosgames).w
	beq.w	.noflip
	cmpi.w	#3,(bosgames).w
	beq.w	.noflip
	cmpi.w	#5,(bosgames).w
	beq.w	.noflip
	bset	#0,$E(a1)
	move.b	(a0)+,3(a1)
	move.b	(a0)+,1(a1)
	rts
.noflip
	bclr	#0,$E(a1)
	move.b	(a0)+,1(a1)
	move.b	(a0)+,3(a1)
	rts

FigureJoy	;Set cont1team ... cont4team
	movem.l	d0-d3/a0-a1,-(sp)
	clr.w	(cont1team).w
	clr.w	(cont2team).w
	clr.w	(cont3team).w
	clr.w	(cont4team).w
	tst.w	(demoflag).w
	beq.w	.ex
	tst.w	(OptPlayMode).w
	beq.w	.fjnpo
	btst	#0,(gmode2).w
	bne.w	.fjnpo
	bsr.w	GetShifter
	movea.w	#(potree-M68K_RAM),a0
	move.w	(potreeteam).w,d2
	move.b	(a0,d2.w),d2
	btst	#7,(GameFlags).w
	beq.w	.0
	clr.w	d2
	move.b	(dword_FFDD82+2).w,d2
.0
	movea.w	#(gsstruct-M68K_RAM),a1
	moveq	#$10,d4
	mulu.w	d1,d4
	adda.w	d4,a1
	st	(gamenum).w
	clr.w	d0
.f0
	cmp.w	(a1),d2
	beq.w	.3
	cmp.w	2(a1),d2
	beq.w	.it2
	suba.w	#$10,a1
	dbf	d1,.f0
	bra.w	.ex
.it2
	moveq	#4,d0
	tst.w	(FourWayPlay).w
	beq.w	.2
	move.w	#5,d0
.2
	move.w	(a1),(Opt2team).w
	move.w	2(a1),(Opt1team).w
	bra.w	.itx
.3
	clr.w	d0
	move.w	2(a1),(Opt2team).w
	move.w	(a1),(Opt1team).w
.itx
	add.w	(pojoy).w,d0
	move.w	d1,(gamenum).w
	move.w	(a1),(HomeTeam).w
	move.w	2(a1),(VisTeam).w
	btst	#0,$E(a1)
	asl.w	#2,d0
	lea	.9(pc),a0
	tst.w	(FourWayPlay).w
	beq.w	.5
	lea	.10(pc),a0
.5
	move.w	(a0,d0.w),(cont1team).w
	move.w	2(a0,d0.w),(cont2team).w
	tst.w	(FourWayPlay).w
	beq.w	.ex
	cmp.w	#4,d0
	beq.w	.6
	cmp.w	#$18,d0
	beq.w	.6
	bra.w	.7
.6
	move.w	(cont1team).w,(cont3team).w
	move.w	(cont2team).w,(cont4team).w
	bra.w	.ex
.7
	cmp.w	#8,d0
	beq.w	.8
	cmp.w	#$1C,d0
	beq.w	.8
	bra.w	.ex
.8
	move.w	(cont1team).w,(cont3team).w
	move.w	#0,(cont4team).w
	bra.w	.ex

.9	;FigureJoy table
	dc.b	$00,$01,$00,$00,$00,$01,$00,$01,$00,$01,$00,$02,$00,$02,$00,$01
	dc.b	$00,$02,$00,$00,$00,$02,$00,$02,$00,$02,$00,$01,$00,$01,$00,$02

.10	;FigureJoy table
	dc.b	$00,$01,$00,$00,$00,$01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$01
	dc.b	$00,$01,$00,$02,$00,$02,$00,$00,$00,$02,$00,$01,$00,$02,$00,$01
	dc.b	$00,$02,$00,$02,$00,$02,$00,$01

.fjnpo
	move.w	(OptNOP).w,d0
	asl.w	#2,d0
	lea	NOPJoyTbl(pc),a0
	move.w	(a0,d0.w),(cont1team).w
	move.w	2(a0,d0.w),(cont2team).w

.ex
	movem.l	(sp)+,d0-d3/a0-a1
	rts

NOPJoyTbl	;FigureJoy: cont1team, cont2team by OptNOP when it is not a playoff game
	dc.b	$00,$00,$00,$00,$00,$01,$00,$00,$00,$02,$00,$00,$00,$01,$00,$01
	dc.b	$00,$01,$00,$02,$00,$01,$00,$02,$00,$01,$00,$02
	btst	#7,(GameFlags).w
	bne.w	rtsInitGames

InitializeGameStructures	;Random team pairs for all 8 gsstruct games, none of them HomeTeam or VisTeam
	st	(gamenum).w
	clr.l	d3
	move.w	(HomeTeam).w,d1
	bset	d1,d3
	move.w	(VisTeam).w,d1
	bset	d1,d3
	movea.w	#(gsstruct-M68K_RAM),a1
	moveq	#7,d2
.loop
	bsr.w	GetRandomUnusedTeam
	move.w	d0,(a1)
	bsr.w	GetRandomUnusedTeam
	move.w	d0,2(a1)
	adda.w	#$10,a1
	dbf	d2,.loop
	rts

GetRandomUnusedTeam	;d0 = a random team 0-25 not yet set in d3, and set its bit
	moveq	#$1A,d0
	bsr.w	randomd0
	bset	d0,d3
	bne.s	GetRandomUnusedTeam
rtsInitGames	;GameFlags bit 7 skips the random pairs and returns here
	rts

ReadPassBits	;Translate the saved bits at a3 (5 words) to the playoff variables; the 5 words are kept
	moveq	#4,d0
	lea	$A(a3),a0
.save
	move.w	-(a0),-(sp)	;SuperDiv destroys the bits
	dbf	d0,.save
	moveq	#7,d2
	movea.w	#(gsstruct+$70-M68K_RAM),a1
.1
	bclr	#2,$E(a1)
	moveq	#5,d0
	bsr.w	SuperDiv
	move.w	d0,6(a1)
	cmp.w	#4,d0
	bne.w	.nsf0
	bset	#2,$E(a1)
.nsf0
	moveq	#5,d0
	bsr.w	SuperDiv
	move.w	d0,4(a1)
	cmp.w	#4,d0
	bne.w	.3
	bset	#2,$E(a1)
.3
	suba.w	#$10,a1
	dbf	d2,.1
	move.w	#$4000,d0
	bsr.w	SuperDiv
	move.w	d0,(WinBits).w
	move.w	#8,d0
	bsr.w	SuperDiv
	move.w	d0,(pojoy).w
	tst.w	(FourWayPlay).w
	beq.w	.5
	cmpi.w	#1,(pojoy).w
	bne.w	.4
	move.w	#3,(pojoy).w
	bra.w	.5
.4
	cmpi.w	#2,(pojoy).w
	bne.w	.5
	move.w	#4,(pojoy).w
.5
	moveq	#$10,d0
	bsr.w	SuperDiv
	move.w	d0,(potreeteam).w
	moveq	#4,d0
	bsr.w	SuperDiv
	move.w	d0,(gamelevel).w
	moveq	#8,d0
	bsr.w	SuperDiv
	move.w	d0,(bosgames).w
	moveq	#$20,d0
	bsr.w	SuperDiv
	move.w	d0,(postarts).w
	moveq	#4,d0
	lea	(a3),a0
.restore
	move.w	(sp)+,(a0)+	;put the bits back
	dbf	d0,.restore
	rts

EncodePW	;After a playoff game compute winners and save the bits if needed
	tst.w	(OptNOP).w
	beq.w	rtss2
	tst.w	(OptPlayMode).w
	beq.w	rtss2
	cmpi.w	#4,(OptPlayMode).w
	beq.w	rtss2
	bset	#6,(GameFlags).w
	move.w	#1,(OptPlayMode).w	;continue playoffs
	move.w	#1,(TempOptPlayMode).w
	bsr.w	ResolveGames
	bsr.w	maketree
	cmpi.w	#4,(gamelevel).w
	beq.w	.2	;finished playoffs
	btst	#7,(GameFlags).w
	bne.w	.0
	tst.w	(gamenum).w
	bmi.w	.2
.0
	movea.l	#pwddatabuffer,a3
	bsr.w	WritePassBits
	jsr	(WritePassData).l
	bclr	#4,(sflags).w
	move.w	#$FFFF,(lastsfx).w
	move.l	#$FFFF0000,(recbpr).w
	btst	#2,(sflags3).w
	beq.w	.1
	movea.w	#(tpassbits-M68K_RAM),a3
	bsr.w	ReadPassBits
	bsr.w	maketree
.1
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	rts
.2
	movea.w	#(pwddatabuffer-M68K_RAM),a3
	bsr.w	ClrPassBits
	jsr	(WritePassData).l
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	bclr	#4,(sflags).w
	move.w	#$FFFF,(lastsfx).w
	move.l	#$FFFF0000,(recbpr).w
	move.w	#2,(OptPlayMode).w	;new playoffs
	move.w	#2,(TempOptPlayMode).w
	cmpi.w	#7,(bosgames).w
	beq.w	rtss2
	move.w	#3,(OptPlayMode).w	;new playoffs best of 7
	move.w	#3,(TempOptPlayMode).w
	rts

ReadPassData	;Read pwddatabuffer from save RAM (GameFlags bit 7: the season copy)
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$E5E,d0
	btst	#7,(GameFlags).w
	beq.w	.0
	moveq	#$4D,d0
.0
	moveq	#$A,d1
	movea.l	#pwddatabuffer,a0
	jsr	(ReadSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

WritePassData	;Write pwddatabuffer to save RAM and its checksum (GameFlags bit 7: the season copy, only with
	;SeasonDay bit 2)
	movem.l	d0-d1/a0,-(sp)
	move.l	#$E5E,d0
	btst	#7,(GameFlags).w
	beq.w	.0
	btst	#2,(SeasonFlags).w
	beq.w	.1
	moveq	#$4D,d0
.0
	moveq	#$A,d1
	movea.l	#pwddatabuffer,a0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
.1
	movem.l	(sp)+,d0-d1/a0
	rts

WritePassBits	;Transfer the game variables to the bits at a3
	bsr.w	ClrPassBits
	move.w	(postarts).w,d0
	moveq	#$20,d1
	bsr.w	PushBits
	move.w	(bosgames).w,d0
	moveq	#8,d1
	bsr.w	PushBits
	move.w	(gamelevel).w,d0
	moveq	#4,d1
	bsr.w	PushBits
	move.w	(potreeteam).w,d0
	moveq	#$10,d1
	bsr.w	PushBits
	move.w	(pojoy).w,d0
	moveq	#8,d1
	bsr.w	PushBits
	move.w	(WinBits).w,d0
	move.w	#$4000,d1
	bsr.w	PushBits
	moveq	#5,d1
	moveq	#7,d2
	movea.w	#(gsstruct-M68K_RAM),a1
.0
	move.w	4(a1),d0
	bsr.w	PushBits
	move.w	6(a1),d0
	bsr.w	PushBits
	adda.w	#$10,a1
	dbf	d2,.0
	rts

PushBits	;Bits = bits * d1 + d0. d1 = range 2^1-2^15, d0 = data
	movem.l	d0-d1,-(sp)
	exg	d0,d1
	bsr.w	SuperMult
	clr.l	d0
	move.w	d1,d0
	bsr.w	SuperAdd
	movem.l	(sp)+,d0-d1
	rts

ClrPassBits	;Clear the 5 words of bits at a3
	movea.w	a3,a0
	moveq	#4,d0
.0
	clr.w	(a0)+
	dbf	d0,.0
	rts

SuperAdd	;1 long (d0.L) added to the 5 words at a3
	movem.l	d1/a0,-(sp)
	lea	$A(a3),a0
	moveq	#3,d1
	add.l	d0,-(a0)
	bra.w	.1
.0
	addq.w	#1,-(a0)	;carry into the next word up
.1
	dbcc	d1,.0
	movem.l	(sp)+,d1/a0
	rts

SuperMult	;1 word (d0) multiplied by the 5 words at a3
	movem.l	d1-d4/a0,-(sp)
	movea.w	a3,a0
	moveq	#4,d4
.0
	move.w	(a0),-(sp)
	clr.w	(a0)+
	dbf	d4,.0
	moveq	#4,d4
.1
	move.w	d0,d1
	mulu.w	(sp)+,d1
	lea	2(a3),a0
	adda.w	d4,a0
	adda.w	d4,a0
	move.w	d4,d2
	add.l	d1,-(a0)
	bra.w	.3
.2
	addq.w	#1,-(a0)
.3
	dbcc	d2,.2
	dbf	d4,.1
	movem.l	(sp)+,d1-d4/a0
	rts

SuperDiv	;5 words at a3 divided by 1 word (d0); d0 = remainder on exit
	movem.l	d1-d2/a0,-(sp)
	movea.w	a3,a0
	moveq	#4,d1
	clr.l	d2
.0
	move.w	(a0),d2
	divu.w	d0,d2
	move.w	d2,(a0)+
	dbf	d1,.0
	swap	d2
	move.w	d2,d0
	movem.l	(sp)+,d1-d2/a0
	rts

GetShifter	;Returns d1 = number of games - 1, d2 = first bit of WinBits
	move.l	d0,-(sp)
	moveq	#-16,d2
	moveq	#$10,d1
	move.w	(gamelevel).w,d0
.0
	add.w	d1,d2
	lsr.w	#1,d1
	dbf	d0,.0
	subq.w	#1,d1
	move.l	(sp)+,d0
	rts

AddPlayoffTeamStats	;Add the po team's game stats to its playoff totals in statsbuffer (ReadTeamStats) and write them back
	;to save RAM
	btst	#7,(GameFlags).w
	bne.w	.2
	cmpi.w	#1,(OptPlayMode).w
	blt.w	rtss2
	bsr.w	ReadTeamStats
	movea.w	#(potree-M68K_RAM),a0
	move.w	(potreeteam).w,d2
	move.b	(a0,d2.w),d2
	movea.w	#(tmstruct-M68K_RAM),a2
	cmp.w	$28(a2),d2
	beq.w	.0
	adda.w	#$39E,a2
	cmp.w	$28(a2),d2
	bne.w	.2
.0
	adda.w	#$C0,a2
	moveq	#$6F,d0
	movea.w	#(statsbuffer-M68K_RAM),a1
.1
	clr.w	d1
	move.b	(a2)+,d1
	add.w	d1,(a1)+
	dbf	d0,.1
	bset	#6,(GameFlags).w
	move.w	d2,d7
	jsr	(GetGoalieCountD7).l
	move.w	d0,d6
	move.w	#$1B,d3
	sub.w	d6,d3
	add.w	d6,d6
	clr.w	d7
	moveq	#$A,d2
	move.l	#$7340,d1
	movea.l	#statsbuffer,a0
	adda.w	d6,a0
	jsr	(WriteSRAMBitWords).l
	moveq	#$A,d2
	move.l	#$7430,d1
	movea.l	#statsbuffer+$38,a0
	adda.w	d6,a0
	jsr	(WriteSRAMBitWords).l
	moveq	#9,d2
	move.l	#$7520,d1
	movea.l	#statsbuffer+$A8,a0
	adda.w	d6,a0
	jsr	(WriteSRAMBitWords).l
	asr.w	#1,d6
	move.w	d6,d3
	moveq	#$D,d2
	move.l	#$75F8,d1
	movea.l	#statsbuffer+$70,a0
	jsr	(WriteSRAMBitWords).l
	moveq	#$D,d2
	move.l	#$761F,d1
	movea.l	#statsbuffer,a0
	jsr	(WriteSRAMBitWords).l
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
.2
	rts

ReadTeamStats	;Read the playoff stat totals of the po team from save RAM into statsbuffer words
	movea.w	#(potree-M68K_RAM),a0
	move.w	(potreeteam).w,d2
	move.b	(a0,d2.w),d2
	move.w	d2,d7
	jsr	(GetGoalieCountD7).l
	move.w	d0,d6
	move.w	#$1B,d3
	sub.w	d6,d3
	add.w	d6,d6
	clr.w	d7
	moveq	#$A,d2
	move.l	#$7340,d1
	movea.l	#statsbuffer,a0
	adda.w	d6,a0
	jsr	(ReadSRAMBitWords).l
	moveq	#$A,d2
	move.l	#$7430,d1
	movea.l	#statsbuffer+$38,a0
	adda.w	d6,a0
	jsr	(ReadSRAMBitWords).l
	moveq	#9,d2
	move.l	#$7520,d1
	movea.l	#statsbuffer+$A8,a0
	adda.w	d6,a0
	jsr	(ReadSRAMBitWords).l
	asr.w	#1,d6
	move.w	d6,d3
	moveq	#$D,d2
	move.l	#$75F8,d1
	movea.l	#statsbuffer+$70,a0
	jsr	(ReadSRAMBitWords).l
	moveq	#$D,d2
	move.l	#$761F,d1
	movea.l	#statsbuffer,a0
	jsr	(ReadSRAMBitWords).l
	rts

ResolveGames	;Compute winners and losers for playoff matchups
	tst.w	(gamenum).w
	bmi.w	.1
	move.w	(gamenum).w,d0
	mulu.w	#$10,d0
	movea.w	#(gsstruct-M68K_RAM),a0
	move.w	(HmGoals).w,$A(a0,d0.w)
	move.w	(AwGoals).w,$C(a0,d0.w)
.1
	bsr.w	GetShifter
	movea.w	#(gsstruct-M68K_RAM),a0
	moveq	#$10,d3
	mulu.w	d1,d3
	adda.w	d3,a0
	cmpi.w	#7,(bosgames).w
	beq.w	.notbos
.loop
	cmpi.w	#4,4(a0)
	beq.w	.5
	cmpi.w	#4,6(a0)
	beq.w	.5
	clr.w	d3
	btst	#0,$E(a0)
	beq.w	.0
	eori.w	#2,d3
.0
	move.w	$A(a0),d0
	sub.w	$C(a0),d0
	bpl.w	.4
	eori.w	#2,d3
.4
	btst	#7,(GameFlags).w
	bne.w	.5
	addq.w	#1,4(a0,d3.w)
.5
	suba.w	#$10,a0
	dbf	d1,.loop
	btst	#7,(GameFlags).w
	bne.w	.6
	addq.w	#1,(bosgames).w
.6
	cmpi.w	#7,(bosgames).w
	beq.w	.nextround
	move.w	(gamenum).w,d0
	mulu.w	#$10,d0
	movea.w	#(gsstruct-M68K_RAM),a0
	adda.w	d0,a0
	cmpi.w	#4,4(a0)
	beq.w	.cround
	cmpi.w	#4,6(a0)
	bne.w	rtss2
.cround
	cmpi.w	#3,(gamelevel).w	;finish off rest of round games here
	bge.w	.nextround
	btst	#7,(GameFlags).w
	bne.w	rtss2
	bsr.w	GetShifter
	movea.w	#(gsstruct-M68K_RAM),a0
	moveq	#$10,d3
	mulu.w	d1,d3
	adda.w	d3,a0
.cr0
	cmp.w	(gamenum).w,d1
	beq.w	.crn
	cmpi.w	#4,4(a0)
	beq.w	.crn
	cmpi.w	#4,6(a0)
	beq.w	.crn
	addq.w	#1,4(a0)
	move.l	#$C8,d0	;200
	jsr	(randomd0).l
	andi.w	#1,d0
	beq.s	.cr0
	subq.w	#1,4(a0)
	addq.w	#1,6(a0)
	bra.s	.cr0
.crn
	suba.w	#$10,a0
	dbf	d1,.cr0
	movea.w	#(tpassbits-M68K_RAM),a3
	bsr.w	WritePassBits
	bset	#2,(sflags3).w
.nextround
	clr.w	(bosgames).w	;advance to next round
	bsr.w	GetShifter
	movea.w	#(gsstruct-M68K_RAM),a0
	moveq	#$10,d3
	mulu.w	d1,d3
	adda.w	d3,a0
	clr.w	d3
.loop2
	cmpi.w	#4,4(a0)
	beq.w	.2
	bset	d1,d3
.2
	clr.w	4(a0)
	clr.w	6(a0)
	suba.w	#$10,a0
	dbf	d1,.loop2
	moveq	#1,d1
	asl.w	d2,d1
	subq.w	#1,d1
	and.w	d1,(WinBits).w
	asl.w	d2,d3
	or.w	d3,(WinBits).w
	addq.w	#1,(gamelevel).w
	rts
.notbos
	clr.w	d3	;solve for no best of 7 playoffs (much simpler)
.loop3
	move.w	$A(a0),d0
	cmp.w	$C(a0),d0
	bhi.w	.3
	bset	d1,d3
.3
	btst	#0,$E(a0)
	beq.w	.nb2
	bchg	d1,d3
.nb2
	suba.w	#$10,a0
	dbf	d1,.loop3
	moveq	#1,d1
	asl.w	d2,d1
	subq.w	#1,d1
	and.w	d1,(WinBits).w
	asl.w	d2,d3
	or.w	d3,(WinBits).w
	addq.w	#1,(gamelevel).w
	rts

