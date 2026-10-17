;	The penalties. Big-print sits in front of AddPenalty. PenaltyManager runs
;	the referee, the penalty box and the power play.

PrintBigChar	;Print big font char d0 (printbigtext)
	subi.w	#$20,d0
	btst	#6,(sflags13).w
	beq.w	.0
	cmp.b	#$3A,d0
	bne.w	.0
	move.b	#$2E,d1
	clr.w	d2
	bra.w	.1
.0
	movea.l	#bfasciicon,a0
	clr.w	d2
	move.b	(a0,d0.w),d1
.1
	ext.w	d1
	asl.w	#1,d1
	movea.l	(bigfontptr).w,a0
	adda.l	4(a0),a0
.loop
	move.w	4(a0,d1.w),d3
	bsr.w	PutBigTile
	move.w	(a0),d7
	asl.w	#1,d7
	add.w	d7,d1
	move.w	4(a0,d1.w),d3
	sub.w	d7,d1
	addq.w	#1,d5
	bsr.w	PutBigTile
	subq.w	#1,d5
	addq.w	#1,d4
	addq.w	#2,d1
	dbf	d2,.loop
	rts

PutBigTile	;Write tile d3 + d6 at column d4, row d5 of the map at VmMap1 + printm
	add.w	d6,d3
	movem.l	d1/a0,-(sp)
	move.w	d5,d0
	movea.l	#$FFFFB004,a0
	adda.w	(printm).w,a0
	move.w	2(a0),d1
	asl.w	d1,d0
	add.w	d4,d0
	asl.w	#1,d0
	add.w	(a0),d0
	bsr.w	Vmaddr
	move.w	d3,(a0)
	movem.l	(sp)+,d1/a0
	rts

BigControlCodeJumpTable	;printbigtext control codes indexed by -byte (as ControlCodeJumpTable); the handlers follow
	dc.b	$00,$01,$F8,$4A,$00,$01,$C0,$50,$00,$01,$C0,$62,$00,$01,$C0,$88
	dc.b	$00,$01,$C0,$9A,$00,$01,$C0,$AC,$00,$01,$C0,$BE,$00,$01,$C0,$D0
	dc.b	$00,$01,$C0,$40,$61,$00,$00,$20,$61,$00,$00,$0A,$61,$00,$00,$3E
	dc.b	$60,$00,$00,$4C,$10,$19,$53,$43,$02,$40,$00,$03,$E5,$40,$59,$40
	dc.b	$31,$C0,$B0,$46,$4E,$75,$1C,$19,$02,$46,$00,$07,$53,$43,$E6,$5E
	dc.b	$31,$C6,$B0,$44,$08,$38,$00,$02,$C3,$54,$66,$00,$00,$0A,$DC,$78
	dc.b	$B0,$14,$60,$00,$00,$06,$DC,$78,$B0,$18,$4E,$75,$42,$40,$10,$19
	dc.b	$53,$43,$31,$C0,$B0,$40,$38,$38,$B0,$40,$60,$00,$F8,$B2,$42,$40
	dc.b	$10,$19,$53,$43,$31,$C0,$B0,$42,$3A,$38,$B0,$42,$60,$00,$F8,$A0
	dc.b	$10,$19,$48,$80,$53,$43,$D1,$78,$B0,$40,$38,$38,$B0,$40,$60,$00
	dc.b	$F8,$8E,$10,$19,$48,$80,$53,$43,$D1,$78,$B0,$42,$3A,$38,$B0,$42
	dc.b	$60,$00,$F8,$7C,$42,$40,$10,$19,$53,$43,$31,$F8,$B0,$16,$B0,$14
	dc.b	$23,$FC,$00,$1B,$89,$C8,$FF,$FF,$B0,$10,$B0,$7C,$00,$02,$67,$00
	dc.b	$00,$1C,$B0,$7C,$00,$03,$66,$00,$00,$12,$31,$F8,$B0,$1A,$B0,$14
	dc.b	$23,$FC,$00,$1B,$9E,$D8,$FF,$FF,$B0,$10,$4E,$75,$31,$F8,$B0,$18
	dc.b	$B0,$14,$23,$FC,$00,$1B,$94,$16,$FF,$FF,$B0,$10,$4E,$75

printbigz1	;printbig1 with the String after the call
	move.l	a1,-(sp)
	movea.l	4(sp),a1
	bsr.w	printbig1
	move.l	a1,4(sp)
	movea.l	(sp)+,a1
	rts

printbigz2	;printbig2 with the String after the call
	move.l	a1,-(sp)
	movea.l	4(sp),a1
	bsr.w	printbig2
	move.l	a1,4(sp)
	movea.l	(sp)+,a1
	rts

printbig1	;printbigcur with the font map BigFontMap (chars bigfont1chars)
	bclr	#2,(sflags11).w
	move.l	#BigFontMap,(bigfontptr).l
	move.w	(bigfont1chars).w,(printbigchars).w
	jmp	printbigcur

printbig2	;printbigcur with the font map BigFontMap3 (chars BigFontChars)
	bclr	#2,(sflags11).w
	move.l	#BigFontMap3,(bigfontptr).l
	move.w	(BigFontChars).w,(printbigchars).w
	jmp	printbigcur
	;After printbig2: code that nothing in the listing reaches.
	;Code the listing does not decode: kept as bytes
	dc.b	$31,$C4,$B0,$1C,$24,$7C,$00,$17,$9A,$7E,$60,$00,$F5,$AE

AddFramer	;Load the framer tiles (Framermap+8) at char d4, framercset = d4
	movea.l	#Framermap+8,a2
	move.w	d4,(framercset).w
	bra.w	DecompressGraphicsPlain

AddPenalty	;Add penalty d0 (Penaltylist offset) for player a3. Ignored while the clock is stopped
	btst	#0,(gmode).w
	bne.w	rtss2
	cmp.w	#$C,d0
	beq.w	AddPenalty2
	cmpi.w	#3,(gsp).w
	nop
	nop
	tst.w	(OptPen).w
	beq.w	rtss2
	btst	#2,pflags2(a3)
	bne.w	rtss2
	btst	#5,(gmode).w
	bne.w	AddPenalty2
	cmp.w	#$10,d0
	beq.w	rtss2

AddPenalty2	;Forced penalties like faceoff and game over. d0 = penalty number, a3 = player
	btst	#4,(sflags9).w
	bne.w	rtss2
	btst	#7,(sflags).w
	bne.w	rtss2
	movem.l	d1/a0-a1,-(sp)
	cmp.w	#$E,d0	;goal and up
	blt.w	.nonoise
	addi.w	#$C8,(crowdlevel).w	;200
	addq.w	#5,(ChkCnt).w
	move.w	#$C,-(sp)	;song $C for the home team
	btst	#6,pflags(a3)
	beq.w	.0
	addi.w	#$14,(CwdExciteLvl).w	;visitors: +20 excitement
	move.w	#$B,(sp)	;song $B
.0
	jsr	(song).l
.nonoise
	movea.w	#(PenBuf-M68K_RAM),a1
	moveq	#$1F,d1	;MaxPen-1
.2
	tst.w	(a1)+
	dbeq	d1,.2
	bne.w	.noplayer
	move.b	$53(a3),-(a1)
	move.b	d0,-(a1)
	movea.l	#$E818,a0
	adda.w	(a0,d0.w),a0
	tst.b	1(a0)	;penalty minutes
	beq.w	.noplayer
	bmi.w	.noplayer
	btst	#6,pflags(a3)
	bne.w	.3
	bset	#1,(sflags9).w
	bra.w	.setpenflag
.3
	bset	#2,(sflags9).w
.setpenflag
	bset	#4,pflags2(a3)	;pflags2 bit 4
	beq.w	.noplayer
	clr.w	(a1)	;player already has a penalty, drop this one
.noplayer
	movem.l	(sp)+,d1/a0-a1
	rts

PenaltyManager	;Called periodically. d7 = elapsed time since last call: checkfornewpen, chkprogress, updatepentime, UpdatePA
	bsr.w	updatepentime
	bsr.w	checkfornewpen
	bsr.w	chkprogress
	bra.w	UpdatePA

chkprogress	;Control the progress of the ref and the game through penalty events. While BA_PS_flags bit 2 is set run
	;PenaltyShotBox (bit 7) or the msgtimer count down and erase the message area
	btst	#2,(BA_PS_flags).w
	beq.w	.3
	btst	#7,(BA_PS_flags).w
	bne.w	.sops
	tst.w	(msgtimer).w
	bmi.w	.3
	subq.w	#1,(msgtimer).w
	bpl.w	.ex
	movem.l	d0-d7/a0-a6,-(sp)
	bclr	#2,(sflags2).w
	bclr	#7,(gmode2).w
	bsr.w	printz
	String	$FF,$03,$02
	moveq	#$1B,d0
	moveq	#8,d1
	btst	#0,(gmode2).w
	beq.w	.0
	move.w	#$C,d1	;12 rows when gmode2 bit 0 is set
.0
	move.l	#$7FF,d2	;blank tile
	jsr	(eraser).l
	movem.l	(sp)+,d0-d7/a0-a6
	bra.w	.ex
.sops
	jsr	(PenaltyShotBox).l
	bclr	#7,(BA_PS_flags).w
.ex
	rts
.3
	btst	#2,(gmode).w	;gmpen: penalty called
	beq.w	rtss2
	tst.w	(Pencntdwn).w
	bmi.w	InProgress
	sub.w	d7,(Pencntdwn).w
	bpl.w	rtss2
	movea.l	#$FFFFC3A6,a0
.1
	tst.w	(a0)+
	bne.s	.1
	subq.l	#4,a0
	cmpa.l	#$FFFFC3A6,a0
	blt.w	.2
	cmpi.b	#$2E,(a0)
	bne.w	.2
	jsr	(ClearMessageLine).l
.2
	bclr	#3,(gmode).w
	movea.w	#(PenBuf-M68K_RAM),a0
.4
	tst.w	(a0)+	;any penalty with minutes
	beq.w	rtss2
	clr.w	d0
	move.b	-2(a0),d0
	movea.l	#$E818,a1
	adda.w	(a1,d0.w),a1
	tst.b	1(a1)	;penalty minutes
	beq.s	.4
	bmi.s	.4
	bset	#2,(sflags2).w
	bset	#4,(sflags9).w
	btst	#6,(sflags).w
	bne.w	.5
	move.w	#$96,(xc1).w
	move.w	#0,(yc1).w
	bset	#6,(sflags).w
.5
	move.w	(ExtraChars).w,d4	;load horizontal ref tiles
	movea.l	#RefTilesHor+8,a2
	bsr.w	DecompressGraphicsPlain
	st	(puckc).w
	movea.w	#(puckx-M68K_RAM),a3
	moveq	#$1A,d0
	bsr.w	assinsert
	move.w	#$1C20,$40(a3)	;temp1 = 120*60
	st	(RefStep).w
	clr.w	(RefCnt).w
	bsr.w	UpdatePA
	move.w	#$32,(RefCnt).w	;50
	move.w	#5,d0
	bsr.w	PushRef
	move.w	#$18,(palcount).w
	rts

DoubleMinorChk	;Penalty d0 becomes its 4 minute double minor when its DoubleMinorPenalties entry is not negative
	movem.l	d1-d3/a0,-(sp)
	movea.l	#$EBF8,a0
	move.w	(a0,d0.w),d1
	bmi.w	.0
	move.w	d1,d0
.0
	movem.l	(sp)+,d1-d3/a0
	rts

PenShotChk	;A breakaway shooter hit: a penalty shot when penalty d0 allows one (PenShotPenalties); d0 = the penalty
	movem.l	d1-d3/a0,-(sp)
	btst	#1,pflags3(a2)	;breakaway
	beq.w	.loop
	btst	#0,(gmode).w
	bne.w	.loop
	btst	#3,(BA_PS_flags).w
	beq.w	.0
.loop
	move.w	#$FFFF,d1
	bra.w	.end
.0
	movea.l	#$EBC2,a0
	move.w	(a0,d0.w),d1
	bmi.w	.end
	move.w	SCnum(a2),d2	;SCnum
	movem.w	d0-d1,-(sp)
	move.w	d2,d0
	jsr	(getBAplayerInfo).l
	movem.w	(sp)+,d0-d1
	bpl.w	.found
	bclr	#3,(BA_PS_flags).w
	bra.s	.loop
.found
	move.w	d1,(pspenalty).w
	move.w	d1,d0	;return the penalty shot penalty
.end
	movem.l	(sp)+,d1-d3/a0
	rts

getBAplayerInfo	;Keep the breakaway shooter, team, goalie and checker for the penalty shot; N clear when set
	movem.l	d1-d3/a1,-(sp)
	tst.w	(OptPen).w
	beq.w	.noPen
	bset	#3,(BA_PS_flags).w
	movem.w	d0,-(sp)
	move.w	#5,d1
	move.w	#0,d2
	cmp.w	#5,d0
	bgt.w	.findgoalie
	move.w	#$B,d1
	move.w	#1,d2
.findgoalie
	move.w	d1,d0
	jsr	(FindGoalie).l
	tst.w	d0
	bpl.w	.goaliein
	movem.w	(sp)+,d0	;no goalie
	bclr	#3,(BA_PS_flags).w
	bra.w	.end
.goaliein
	move.w	d0,d1	;d1 = goalie's SCnum
	move.w	(sp)+,d0	;d0 now back to player checked on breakaway SCnum
	move.w	d0,(BA_Sktr_SCnum).w
	movea.l	#SortCords,a1
	move.w	d0,d3
	asl.w	#7,d3	;scsize
	move.w	#0,(BA_Team).w
	btst	#6,$62(a1,d3.w)
	beq.w	.2
	move.w	#1,(BA_Team).w
.2
	move.w	#0,(BA_Skater_Offset).w
	move.b	$67(a1,d3.w),(BA_Skater_Offset+1).w
	move.w	d1,(BA_Goalie_SCnum).w
	asl.w	#7,d1	;scsize
	move.w	#0,(BA_Goalie_Offset).w
	move.b	$67(a1,d1.w),(BA_Goalie_Offset+1).w
	move.w	#0,(BA_Checker_Offset).w
	move.b	$67(a3),(BA_Checker_Offset+1).w
.end
	movem.l	(sp)+,d1-d3/a1
	rts
.noPen
	move.w	#$FFFF,d1	;N set: no penalty shot
	bra.s	.end

InProgress	;Ref in progress: update the graphics, stats and penalty information
	tst.w	(RefCnt).w
	bpl.w	rtss2
	tst.w	(RefStep).w
	bpl.w	rtss2
	movem.l	d0/a0-a3,-(sp)
.top
	movea.w	#(PenBuf-M68K_RAM),a0
	tst.w	(a0)+
	beq.w	.exit
.1
	tst.w	(a0)+
	bne.s	.1
	subq.w	#4,a0
	bclr	#7,1(a0)	;player who is guilty
	bne.w	.Sa
	movem.l	a3,-(sp)
	clr.w	d1
	move.b	1(a0),d1
	asl.w	#7,d1	;scsize
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d1,a3
	tst.w	$34(a3)
	movem.l	(sp)+,a3
	bpl.w	.ex
	clr.w	(a0)
	bra.w	.ex
.Sa
	clr.w	d0
	move.b	(a0),d0
	movea.l	#$E818,a1
	adda.w	(a1,d0.w),a1
	bclr	#5,(sflags5).w
	clr.w	d2
	move.b	1(a1),d2	;penalty minutes
	beq.w	.10
	bmi.w	.10
	cmp.b	#5,d2
	bne.w	.3
	bset	#5,(sflags5).w
.3
	movem.l	d0-d1/a1-a4,-(sp)
	bsr.w	GetPeriodTimeRemaining
	movea.w	#(PenSum-M68K_RAM),a4
	adda.w	(PenSumLength).w,a4
	cmpi.w	#$EC,(PenSumLength).w	;log full: keep overwriting the last entry
	beq.w	.full
	addq.w	#4,(PenSumLength).w
.full
	move.w	d0,(a4)+	;time
	move.b	(a0),(a4)+	;penalty
	clr.w	d1
	move.b	1(a0),d1
	asl.w	#7,d1	;scsize
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d1,a3
	clr.w	d0
	movea.w	#(tmstruct-M68K_RAM),a2
	lea	$39E(a2),a1	;tmsize: visitors
	btst	#6,$62(a3)
	beq.w	.5
	bset	#7,-1(a4)	;log: visitors
	move.w	#$8000,d0
	exg	a1,a2
.5
	addq.w	#1,6(a2)
	add.w	d2,8(a2)
	move.b	$67(a3),d0
	move.b	d0,(a4)	;log: player
	move.w	d0,(TempPlOffset).w
	ext.w	d0
	addi.w	#$114,d0
	add.b	d2,(a2,d0.w)
	subi.w	#$114,d0
	asl.w	#1,d0
	ext.w	d2
	mulu.w	#$3C,d2	;60
	bset	#$D,d2	;tmpdst bit 13
	tst.w	$6C(a2,d0.w)
	bmi.w	.st
	btst	#4,$6C(a2,d0.w)
	beq.w	.st
	bset	#$C,d2	;keep byte bit 4 (word bit 12) of an old penalty time
.st
	move.w	d2,$6C(a2,d0.w)
	andi.w	#$EFFF,d2
	moveq	#$38,d1	;(MaxRos-1)*2+2
.ctop
	subq.w	#2,d1	;same time on the other team
	bmi.w	.8
	move.w	$6C(a1,d1.w),d3
	andi.w	#$EFFF,d3
	cmp.w	d3,d2
	bne.s	.ctop
	btst	#5,(sflags5).w
	beq.s	.ctop
.8
	movem.l	a0,-(sp)
	lea	$A4(a2),a0
	moveq	#$1A,d1
.pl
	tst.b	(a0)+
	dbmi	d1,.pl
	move.b	d0,-1(a0)
	st	(a0)
	movem.l	(sp)+,a0
	move.w	#$C,d0
	bsr.w	assreplace
	movem.l	(sp)+,d0-d1/a1-a4
	bsr.w	SetPA
	bra.w	.ex
.10
	clr.w	(a0)
	btst	#4,(sflags9).w
	bne.w	.top
	btst	#7,(sflags).w
	bne.w	.top
	bsr.w	SetPA
	bra.w	.ex
.exit
	movea.w	#(tmstruct-M68K_RAM),a2
	bsr.w	coinsearch
	adda.w	#$39E,a2
	bsr.w	coinsearch
	bclr	#2,(gmode).w
	movea.w	#(puckx-M68K_RAM),a3
	bclr	#6,(BA_PS_flags).w
	move.w	#$1B,d0
	btst	#3,(BA_PS_flags).w
	beq.w	.0
	move.w	#$1E,d0
.0
	bsr.w	assreplace
.ex
	movem.l	(sp)+,d0/a0-a3
	rts

coinsearch	;a2 = team. Count the players kept off the ice by penalties (coincidental penalties)
	moveq	#6,d1
	moveq	#$36,d0	;(MaxRos-1)*2
.loop
	tst.w	$6C(a2,d0.w)
	ble.w	.nap
	bclr	#5,$6C(a2,d0.w)
	btst	#6,$6C(a2,d0.w)	;coincidental
	bne.w	.nap
	btst	#4,$6C(a2,d0.w)
	bne.w	.nap
	cmp.w	#4,d1	;never below 4 players
	beq.w	.nap
	subq.w	#1,d1
.nap
	subq.w	#2,d0
	bpl.s	.loop
	move.w	d1,$24(a2)
	rts

checkfornewpen	;Look for a new penalty (entered through AddPenalty / AddPenalty2)
	btst	#7,(sflags).w	;gmclock: clock stopped
	bne.w	rtss2
	btst	#4,(sflags9).w
	bne.w	rtss2
	movea.w	#(PenBuf-M68K_RAM),a0
.0
	tst.w	(a0)+
	beq.w	rtss2
	btst	#2,(gmode).w
	bne.w	.iscalled
	clr.w	d0
	move.b	-2(a0),d0
	movea.l	#$E818,a1
	adda.w	(a1,d0.w),a1
	tst.b	1(a1)	;time for penalty
	beq.w	.callit
	move.w	(puckc).w,d0
	bmi.w	.3
	subq.w	#6,d0
	move.b	-1(a0),d1	;player penalized
	ext.w	d1
	subq.w	#6,d1
	eor.w	d1,d0
	bmi.w	.3
.callit
	bsr.w	Stop4Pen
.iscalled
	bset	#7,-1(a0)
	bne.s	.0
	clr.w	d0
	move.b	-2(a0),d0	;penalty called
	movea.l	#$E818,a1
	adda.w	(a1,d0.w),a1
	clr.w	d1
	move.b	(a1),d1	;delay for stopping action
	asl.w	#5,d1
	cmp.w	(Pencntdwn).w,d1
	ble.s	.0
	move.w	d1,(Pencntdwn).w
	bra.s	.0
.3
	bset	#3,(gmode).w
	bne.s	.0
	addq.w	#4,(ChkCnt).w
	move.w	#$2C,d0
	bsr.w	SetPA
	bra.w	.0

Stop4Pen	;a0 = Penaltylist penalty + 2. Stop the clock, set the faceoff spot from the penalty type, blow the whistle
	;and start the ref (SetPA)
	bset	#0,(gmode).w
	bne.w	.5
	clr.w	d0
	clr.w	d1
	cmpi.b	#$E,-2(a0)	;goal: center ice
	beq.w	.0
	move.w	(ltx).w,d0
	move.w	(lty).w,d1
	cmpi.b	#6,-2(a0)	;OOP
	beq.w	.0
	move.w	(puckx).w,d0
	move.w	(pucky).w,d1
	cmpi.b	#$C,-2(a0)	;icing
	bne.w	.0
	move.l	a3,-(sp)
	movea.w	#(SortCords-M68K_RAM),a3
	move.b	-1(a0),d1
	ext.w	d1
	asl.w	#7,d1	;scsize
	adda.w	d1,a3
	move.w	#$258,d1	;600
	btst	#7,$62(a3)
	movea.l	(sp)+,a3
	beq.w	.0
	neg.w	d1
.0
	movem.w	d0-d1,-(sp)
	cmp.w	#$51,d0
	blt.w	.1
	move.w	#$51,d0
.1
	cmp.w	#$FFAF,d0
	bgt.w	.2
	move.w	#$FFAF,d0
.2
	cmp.w	#$B0,d1
	blt.w	.3
	move.w	#$D8,d1
	move.w	#$51,d0
	tst.w	(sp)
	bpl.w	.3
	neg.w	d0
.3
	cmp.w	#$FF50,d1
	bgt.w	.4
	move.w	#$FF28,d1
	move.w	#$51,d0
	tst.w	(sp)
	bpl.w	.4
	neg.w	d0
.4
	move.w	d0,(fox).w
	move.w	d1,(foy).w
	addq.w	#4,sp
	jsr	(limitfo).l
.5
	clr.w	(Pencntdwn).w
	bset	#2,(gmode).w
	jsr	(stop_current_song).l
	move.w	#3,-(sp)	;whistle
	jsr	(sfx).l
	move.w	#$A,d0
	bra.w	SetPA

UpdatePA	;Animate the ref in the ref window (RefCnt, SetPA2)
	tst.w	(RefCnt).w
	bmi.w	rtss2
	sub.w	d7,(RefCnt).w
	bpl.w	.contplay
	bsr.w	SetPA2
.contplay
	cmpi.w	#4,(RefPen).w	;check if cont playoffs
	bne.w	.0
	bsr.w	ShowThreeStars
.0
	sub.w	d7,(penmsgtimer).w
	bpl.w	rtss2
	move.w	#$7FFF,(penmsgtimer).w
	bsr.w	ErasePenaltyMessage
	bsr.w	printz
	String	$BF,$11,$0B
	bsr.w	GetPlayerName
	move.w	(a1),d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	bra.w	print

SetPA	;Start ref animation d0 (penalty number)
	move.w	d0,(RefPen).w
	cmp.w	#$38,d0
	blt.w	.0
	rts
.0
	clr.w	(RefStep).w
	bsr.w	prefmes
	cmp.w	#$E,d0	;goal
	bne.w	.1
	bsr.w	ShowGoalBox
.1
	btst	#0,(gmode2).w
	beq.w	.2
	btst	#3,(gmode2).w
	beq.w	.2
	jsr	(ShootoutWonBy).l
.2
	move.w	#$7FFF,(penmsgtimer).w
	btst	#7,(sflags).w
	beq.w	SetPA2
	btst	#4,(sflags9).w
	beq.w	SetPA2
	move.w	#$3C,(penmsgtimer).w	;60

SetPA2	;Update the ref animation: next frame / delay pair from the Penaltylist animation
	movem.l	d0-d2/a0-a1,-(sp)
	moveq	#$40,d0	;clear ref window
	tst.w	(RefStep).w
	bmi.w	.pr
	move.w	(RefStep).w,d0
	addq.w	#2,(RefStep).w
	move.w	(RefPen).w,d1
	movea.l	#$E818,a0
	adda.w	(a0,d1.w),a0
	addq.w	#2,a0
	adda.w	(a0),a0
	move.w	(a0,d0.w),d0
	bpl.w	.0
	neg.w	d0	;negative = last frame
	st	(RefStep).w
.0
	clr.w	d1
	move.b	d0,d1
	asl.w	#3,d1
	move.w	d1,(RefCnt).w
	btst	#0,(gmode2).w
	beq.w	.1
	btst	#3,(gmode2).w
	beq.w	.1
	move.w	d0,-(sp)
	move.w	(RefCnt).w,d0
	add.w	d0,d0
	move.w	d0,(RefCnt).w
	move.w	(sp)+,d0
.1
	lsr.w	#8,d0
.pr
	bsr.w	PushRef
	movem.l	(sp)+,d0-d2/a0-a1
	rts

PushRef	;Tell vblank what to display: ref frame d0
	movem.l	d0-d2/a0-a1,-(sp)
	cmp.w	#$40,d0
	beq.w	.clearit
	mulu.w	#$70,d0	;refwidth*refheight*2
	movea.l	#RefTiles,a0
	btst	#4,(sflags9).w
	beq.w	.m1
	movea.l	#RefTilesHor,a0
.m1
	adda.l	4(a0),a0
	addq.w	#4,a0
	adda.w	d0,a0
	movea.w	#(RefRamMap-M68K_RAM),a1
	move.w	(ExtraChars).w,d2
	ori.w	#$8000,d2	;priority
	moveq	#$37,d0	;(refheight*refwidth)-1
.1
	move.w	(a0)+,(a1)
	add.w	d2,(a1)+
	dbf	d0,.1
	bset	#1,(sflags2).w
	bra.w	.ex
.clearit
	btst	#7,(sflags).w
	bne.w	.4
	btst	#4,(sflags9).w
	bne.w	.4
	movea.w	#(RefRamMap-M68K_RAM),a1
	moveq	#$37,d0	;(refheight*refwidth)-1
.3
	move.w	#$7FF,(a1)+	;blank tile
	dbf	d0,.3
	bset	#1,(sflags2).w
.4
	moveq	#-1,d0
	bsr.w	prefmes
.ex
	movem.l	(sp)+,d0-d2/a0-a1
	rts

prefmes	;Print the penalty message: the player, the penalty and its length (PenaltyTimeTxt)
	movem.l	d0-d2/a1-a2,-(sp)
	btst	#7,(sflags).w
	bne.w	.1
	btst	#4,(sflags9).w
	bne.w	.1
	tst.w	d0
	bpl.w	.0
	bsr.w	printz
	String	$BF,$00,$0A
	moveq	#$D,d0
	moveq	#3,d1
	move.w	#$7FF,d2
	bsr.w	eraser
	bra.w	.8
.0
	bsr.w	printz
	String	$BF,$05,$0A
	movea.l	#$E818,a1
	adda.w	(a1,d0.w),a1
	addq.w	#2,a1
	move.w	(a1),d0
	subq.w	#2,d0	;empty string
	beq.w	.8
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	bpl.w	.nb0
	clr.w	(printx).w
.nb0
	move.w	(a1),d0
	tst.b	-1(a1,d0.w)
	bne.w	.2
	subq.w	#1,d0
.2
	moveq	#3,d1
	bsr.w	Framer
	subq.w	#2,(printy).w
	addq.w	#1,(printx).w
	bsr.w	print
	bra.w	.8
.1
	tst.w	d0
	bmi.w	.8
	cmpi.w	#$3E8,(glovecords).w
	bne.w	.3
	cmpi.w	#$3E8,(glovecords+2).w
	beq.w	.4
.3
	jsr	(ClearMessageLine).l
.4
	move.w	d0,-(sp)
	jsr	(printz).l
	String	$BF,$0B,$02
	move.w	#$14,d0
	move.w	#8,d1
	jsr	(Framer).l
	jsr	(printbigz2).l
	String	$F8,$04,$01,$0C,$03,'                  '
	move.w	#$15,(printx).w
	move.w	#3,(printy).w
	move.w	(sp)+,d0
	movea.l	#$E818,a1
	adda.w	(a1,d0.w),a1
	addq.w	#2,a1
	move.w	(a1),d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	bsr.w	printbig2
	movea.l	#$FFFFC3A6,a1
.5
	tst.w	(a1)+
	bne.s	.5
	move.w	-4(a1),d0
	move.w	d0,-(sp)
	andi.w	#$7F,d0
	movea.l	#tmstruct,a2
	cmp.w	#6,d0
	blt.w	.6
	movea.l	#AwShots,a2
.6
	asl.w	#7,d0
	movea.l	#SortCords,a1
	adda.w	d0,a1
	clr.w	d0
	move.b	$67(a1),d0
	jsr	(GetPlayerNumInitial).l
	jsr	(printz).l
	String	$BF,$0C,$06
	cmpi.b	#$20,2(a1)
	beq.w	.7
	addq.w	#1,(printx).w
.7
	jsr	(print).l
	jsr	(printz).l
	String	$BF,$11,$05,'penalty'
	move.w	#$D,(printx).w
	movea.l	$1E(a2),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	jsr	(print).l
	jsr	(printz).l
	String	$2E
	jsr	(printz).l
	String	$BF,$0D,$07
	move.w	(sp)+,d0
	lsr.w	#8,d0
	andi.w	#$FF,d0
	movea.l	#$E818,a1
	adda.w	(a1,d0.w),a1
	move.w	(a1),d0
	andi.w	#$FF,d0
	movea.l	#PenaltyTimeTxt,a1
	jsr	(SkipStrings).l
	jsr	(print).l
.8
	movem.l	(sp)+,d0-d2/a1-a2
	rts

PenaltyTimeTxt	;prefmes: the penalty lengths
	String	'penalty error '
	String	'1 minute minor'
	String	'2 minute minor'
	String	'3 minute minor'
	String	'4 minute db minor'
	String	'5 minute major'

ErasePenaltyMessage	;Erase the penalty message box prefmes draws
	jsr	(printz).l
	String	$BF,$0B,$02
	move.w	#$14,d0
	move.w	#8,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	rts

PenGoalStuff	;Do this stuff after a goal: a1 = scored on team, a2 = scoring team. Clears PenBuf, lets the first penalized
	;player of the scored on team out (RemovePlayerFromList), erases the message box
	movem.l	d0-d2/a0,-(sp)
.0
	cmpi.w	#6,$24(a1)
.3
	bne.w	.1
.4
	jsr	(ClearPenaltyBuffer).l
.1
	move.w	$24(a2),d2
.5
	cmp.w	$24(a1),d2
.6
	ble.w	.ex
	lea	$A4(a1),a0
.2
	clr.w	d2
	move.b	(a0)+,d2
.7
	bmi.w	.ex
.8
	btst	#6,$6C(a1,d2.w)
	bne.s	.2
.9
	clr.w	$6C(a1,d2.w)
.10
	jsr	(RemovePlayerFromList).l
.11
	bset	#0,(sflags9).w
	addq.w	#1,$24(a1)
	addq.w	#1,2(a2)
.12
	bset	#0,(tmstruct+$30).w
.13
	bset	#0,(AwShots+$30).w
.ex
	movem.l	(sp)+,d0-d2/a0
	rts

ClearPenaltyBuffer	;Clear PenBuf
	moveq	#$1F,d0
	movea.w	#(PenBuf-M68K_RAM),a0
.loop
	clr.w	(a0)+
	dbf	d0,.loop
	rts

updatepentime	;Update the time remaining on all penalized players, once a second (Penaltytimer); sets sflags3 bit 6 on that
	;tick. chkatop, updatePPTeamTime, then ProcessPenaltyList for both teams
	bclr	#6,(sflags3).w
	btst	#0,(gmode).w
	bne.w	rtss2
	sub.w	d7,(Penaltytimer).w
	bpl.w	rtss2
	addi.w	#$18,(Penaltytimer).w
	bset	#6,(sflags3).w
	bsr.w	chkatop
	jsr	(updatePPTeamTime).l
	movea.w	#(tmstruct-M68K_RAM),a2
	bsr.w	ProcessPenaltyList
	adda.w	#$39E,a2

ProcessPenaltyList	;a2 = team. Walk the penalty box list: count down the penalty time of each player in it
	lea	$A4(a2),a0
	movea.w	#(mesarea-M68K_RAM),a1
	moveq	#2,d1
	moveq	#2,d3

.next
	clr.w	d0
	move.b	(a0)+,d0
	bmi.w	.done
	btst	#6,$6C(a2,d0.w)
	bne.w	.coinpen
	subq.w	#1,d1
	bmi.s	.next
	move.w	d0,(a1)+
	subq.w	#1,$6C(a2,d0.w)
	bne.w	.cont
	bsr.w	RemovePlayerFromList
.cont
	bra.s	.next
.done
	move.w	(mesarea).w,d0
	cmp.w	#1,d1
	beq.w	.5
	tst.w	d1
	bne.w	.3
	bsr.w	.5
	bra.w	.two
.3
	cmp.w	#$FFFF,d1
	bne.w	rtss2
.two
	move.w	(TextBuffer).w,d0

.5	;ProcessPenaltyList: a player d0 whose time is nearly up beeps; at 0 he is released (releasepl)
	cmpi.w	#5,$6C(a2,d0.w)
	bgt.w	rtss2
	move.w	#1,-(sp)
	tst.w	$6C(a2,d0.w)
	bne.w	.6
	bsr.w	releasepl
	move.w	#2,(sp)
.6
	jsr	(sfx).l
	rts

.coinpen
	subq.w	#1,$6C(a2,d0.w)
	btst	#3,$6C(a2,d0.w)
	beq.s	.next
	btst	#4,$6C(a2,d0.w)
	bne.w	.clr
	move.w	#$1000,$6C(a2,d0.w)
	bra.w	RemovePlayerFromList
.clr
	clr.w	$6C(a2,d0.w)

RemovePlayerFromList	;Remove the entry before a0 from a penalty box list by shifting the rest down. Return a0 = removed slot
	moveq	#-1,d2
.shift
	addq.w	#1,d2
	move.b	(a0,d2.w),-1(a0,d2.w)
	bpl.s	.shift
	subq.w	#1,a0
	rts

chkatop	;Attack time of possession stat update. Called once a second from updatepentime
	moveq	#0,d1
	move.w	(pucky).w,d0
	cmp.w	#$76,d0
	bgt.w	.0
	move.l	#$39E,d1
	neg.w	d0
	cmp.w	#$76,d0
	blt.w	rtss2
.0
	btst	#1,(gmode).w
	beq.w	.1
	eori.w	#$39E,d1
.1
	movea.w	#(tmstruct-M68K_RAM),a2
	addq.w	#1,$A(a2,d1.w)
	rts

releasepl	;The player's penalty time is up, so let him out (if appropriate). a2 = team, d0 = player * 2
	movem.l	d0-d3/a0-a3,-(sp)
	movea.w	$22(a2),a3
	suba.w	#$80,a3
.0
	adda.w	#$80,a3
	tst.w	$34(a3)
	bpl.s	.0
	move.w	d0,d3
	lsr.w	#1,d3
	move.w	$24(a2),d1
	addq.w	#1,$24(a2)
	bset	#0,(tmstruct+$30).w
	bset	#0,(AwShots+$30).w
	movea.l	#priolist,a0
	tst.w	$26(a2)
	bpl.w	.gin
	addq.w	#1,a0
.gin
	clr.w	$34(a3)
	move.b	(a0,d1.w),$35(a3)
	bsr.w	AssignByPosition
	bsr.w	setplayer
	bset	#2,$63(a3)
	movem.l	(sp)+,d0-d3/a0-a3
	rts

GetLowestPen	;a2 = shorthanded team, a3 = team on the power play. d0 = power play time left from the penalty box times
	clr.w	d0
	clr.w	d3
	lea	$A4(a2),a0
.getstatus
	clr.w	d2
	move.b	(a0)+,d2
	bmi.w	.1
	move.w	$6C(a2,d2.w),d2
	btst	#$E,d2
	bne.s	.getstatus
	sub.w	d3,d2
	add.w	d2,d0
	move.w	d2,d3
	bra.s	.getstatus
.1
	cmpi.w	#6,$24(a3)
	beq.w	rtss2
	sub.w	d3,d0
	lea	$A4(a3),a0
	clr.w	d2
.2
	move.b	(a0)+,d2
	bmi.w	rtss2
	btst	#6,$6C(a3,d2.w)
	bne.s	.2
	cmp.w	$6C(a3,d2.w),d0
	blt.w	rtss2
	add.w	d3,d0
	rts

updatepwrplay	;The power play box: the team and the time left (GetLowestPen). Called once a second
	btst	#7,(gmode).w
	bne.w	rtss2
	btst	#1,(gmode2).w
	bne.w	rtss2
	btst	#4,(sflags9).w
	bne.w	rtss2
	btst	#2,(sflags12).w
	bne.w	rtss2
	btst	#1,(tmstruct+$30).w
	bne.w	rtss2
	btst	#1,(AwShots+$30).w
	bne.w	rtss2
	movea.w	#(tmstruct-M68K_RAM),a2
	lea	$39E(a2),a3
	move.w	$24(a2),d0
	sub.w	$24(a3),d0
	beq.w	.clrpwrplay
	bpl.w	.0
	btst	#6,(sflags2).w
	bne.w	.1
	bsr.w	.clrpwrplay
	bset	#6,(sflags2).w
	bra.w	.1
.0
	exg	a2,a3
	btst	#6,(sflags2).w
	beq.w	.1
	bsr.w	.clrpwrplay
	bclr	#6,(sflags2).w
.1
	btst	#5,(sflags2).w
	beq.w	.2
	bclr	#3,(sflags12).w
	bne.w	.4
.2
	bset	#5,(sflags2).w
	bne.w	.5
	addq.w	#1,4(a3)
.4
	movem.l	d0-d1/a3,-(sp)
	bsr.w	DrawPowerPlayBox
	movem.l	(sp)+,d0-d1/a3
	cmpa.w	#(tmstruct-M68K_RAM),a3
	bne.w	.3
.home
	bra.w	.5
.3
	bra.s	.home
.5
	bclr	#7,(sflags11).w
	beq.w	.6
	bsr.w	DrawPowerPlayBox
.6
	jsr	(printz).l
	String	$BF,$17,$19
	jsr	(printbigz1).l
	String	$2B
	bsr.w	GetLowestPen
	bsr.w	PushTime
	cmpi.b	#$20,3(a1)
	bne.w	.7
	move.b	#$7A,3(a1)
.7
	bsr.w	printbig1
	jsr	(printbigz1).l
	String	$2A
	movea.l	$1E(a3),a0
	movea.w	#(mesarea-M68K_RAM),a3
	move.w	#2,(a3)
	bsr.w	appendz
	String	$BF,$14,$19
	adda.w	4(a0),a0
	adda.w	(a0),a0
	movea.l	a0,a1
	bsr.w	appstring
	movea.w	a3,a1
	bsr.w	print
	bsr.w	printz
	String	$BF,$14,$1A,'PP'
	bset	#3,(disflags).w
	rts

.clrpwrplay	;With sflags2 bit 5 set, clear it and erase the power play box (ErasePowerPlayBox)
	bclr	#5,(sflags2).w
	beq.w	rtss2
	bsr.w	ErasePowerPlayBox
	bset	#3,(disflags).w
	rts

ErasePowerPlayBox	;Erase the power play box
	jsr	(printz).l
	String	$BF,$13,$18
	move.w	#$C,d0
	move.w	#4,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	rts

DrawPowerPlayBox	;Draw the power play box frame (Framer)
	jsr	(printz).l
	String	$BF,$13,$18
	move.w	#$C,d0
	move.w	#4,d1
	jmp	Framer

ClrHor	;Back to the vertical rink: reload the rink graphics, SprSort, clear the screen unless paused
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$08,$B8,$00,$07,$C3,$3A,$31,$FC,$03,$E8,$BD,$30
	dc.b	$4E,$B9,$00,$01,$54,$D8,$61,$00,$43,$78,$08,$38,$00,$00,$C3,$3A
	dc.b	$66,$00,$00,$1C,$61,$00,$EB,$4A,$00,$06,$FF,$00,$00,$00,$70,$20
	dc.b	$72,$1C,$34,$3C,$07,$FF,$61,$00,$E9,$20,$61,$00,$00,$08,$4C,$DF
	dc.b	$7F,$FF,$4E,$75

printscores1	;The scoreboard redraw: an empty rts in 96
	rts

EASNLogo	;Draw the EASN logo
	bsr.w	printz
	String	$BF,$01,$15
	movea.l	#EASNmap,a1
	adda.l	4(a1),a1
	movea.w	#$772,a2
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	move.w	(EASNcset).w,d4
	clr.w	d5
	bra.w	dobitmap
	;The rest of EASNLogo.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$F0,$08,$F8,$00,$03,$BF,$B2,$61,$C6,$61,$00,$EA,$F0
	dc.b	$00,$06,$BE,$14,$08,$00,$34,$7C,$C7,$26,$61,$00,$00,$1A,$61,$00
	dc.b	$EA,$DE,$00,$06,$BE,$05,$08,$00,$34,$7C,$CA,$C4,$61,$00,$00,$08
	dc.b	$4C,$DF,$0F,$FF,$4E,$75,$41,$EA,$00,$A4,$42,$40,$10,$18,$6B,$00
	dc.b	$00,$10,$08,$32,$00,$06,$00,$6C,$66,$F0,$61,$00,$00,$1E,$60,$EA
	dc.b	$41,$EA,$00,$A4,$42,$40,$10,$18,$6B,$00,$27,$60,$08,$32,$00,$06
	dc.b	$00,$6C,$67,$F0,$61,$00,$00,$04,$60,$EA,$0C,$78,$00,$0A,$B0,$42
	dc.b	$62,$00,$27,$48,$34,$32,$00,$6C,$02,$42,$07,$FF,$3E,$2A,$00,$28
	dc.b	$E2,$48,$4E,$B9,$00,$01,$01,$E6,$D2,$D1,$50,$49,$42,$40,$10,$29
	dc.b	$FF,$F8,$3F,$38,$B0,$40,$32,$7C,$BF,$F4,$61,$00,$5F,$98,$32,$7C
	dc.b	$BF,$F2,$32,$BC,$00,$04,$61,$00,$EA,$68,$30,$02,$61,$00,$EC,$46
	dc.b	$61,$00,$EA,$5E,$31,$DF,$B0,$40,$52,$78,$B0,$42,$4E,$75

