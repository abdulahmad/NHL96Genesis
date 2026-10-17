;	The line change box. SetLCmode opens it for the team of player a3 when line changes are
;	on. SetLCmode2 draws the choices, lineinput reads the pad, and lcfound sets the line.

SetLCmode	;Open the line change box for the team of player a3 (loadTeamStruct): not with line changes
	;off (OptLine)
	tst.w	(OptLine).w
	bne.w	rtss7
	btst	#4,(sflags7).w
	bne.w	rtss7
	jsr	(loadTeamStruct).l
	bset	#1,tmflags(a2)
	bne.w	rtss7
	btst	#3,(sflags5).w
	bne.w	.0
	bclr	#2,(sflags).w
.0
	bclr	#3,(sflags).w
	bset	#3,pflags2(a3)
SetLCmode2	;Open the line change box: wait for the box, then draw the line choices (setlccords, getlchoice)
	btst	#0,(gmode).w
	beq.w	.0
	bsr.w	setlccords
	cmpi.w	#$F,(printy).w
	blt.w	.2
	jsr	(ClearBigScore).l
	bclr	#2,(sflags12).w
.0
	bset	#2,(sflags12).w
	bne.w	.2
	jsr	(ErasePowerPlayBox).l
.2
	bsr.w	setlccords
	cmpi.w	#$F,(printy).w
	blt.w	.box
	bset	#0,(sflags3).w
	bra.w	.1
.box
	jsr	(box).l
	bsr.w	setlccords
.1
	jsr	(Framer).l
	subq.w	#2,(printy).w
	addq.w	#1,(printx).w
	moveq	#2,d4
.loop
	move.w	d4,d0
	bsr.w	getlchoice
	tst.w	d0
	bmi.w	.next
	btst	#1,$30(a2)
	bne.w	.pr
	cmp.w	$2E(a2),d4
	bne.w	.up
	move.w	$16(a2),d0
.pr
	movea.w	#(mesarea-M68K_RAM),a1
	move.l	#$44120,(a1)	;String length 4, 'A '
	add.b	d4,2(a1)
	jsr	(print).l
	move.w	d0,-(sp)
	movea.l	#linelist,a1
	jsr	(SkipStrings).l
	jsr	(print).l
	move.w	(sp)+,d0
	jsr	(linebar).l
	subq.w	#5,(printx).w
.up
	subq.w	#1,(printy).w
.next
	dbf	d4,.loop
	movea.l	$1E(a2),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	addq.w	#2,(printx).w
	jmp	print

setlccords	;printx / printy of the line change box for team a2
	clr.w	d0
	cmpa.w	#$C726,a2
	bne.w	.0
	eori.w	#$16,d0
.0
	btst	#1,(gmode).w
	beq.w	.1
	eori.w	#$16,d0
.1
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$16,0,0
	add.w	d0,(printy).w
	moveq	#2,d0
	bsr.w	getlchoice
	moveq	#6,d1
	tst.w	d0
	bpl.w	.ex
	subq.w	#1,d1
	addq.w	#1,(printy).w
.ex
	moveq	#9,d0
	rts

getlchoice	;Line choice d0 from the line change box
	movem.l	d1-d2,-(sp)
	move.w	$3C2(a2),d2
	cmpa.w	#$C726,a2
	beq.w	getlchoice2
	move.w	-$37A(a2),d2

getlchoice2
	sub.w	$24(a2),d2
	beq.w	.0
	addi.w	#$15,d0
	tst.w	d2
	bmi.w	.0
	addi.w	#$15,d0
.0
	move.w	$16(a2),d1
	add.w	d1,d0
	add.w	d1,d0
	add.w	d1,d0
	lea	.tab(pc),a0
	move.b	(a0,d0.w),d0
	ext.w	d0
	movem.l	(sp)+,d1-d2
	rts

.tab
	dc.b	$00,$01,$02,$01,$02,$00,$02,$00,$01,$00,$01,$02,$00,$01,$02,$00
	dc.b	$01,$02,$00,$01,$02,$03,$04,$FF,$03,$04,$FF,$03,$04,$FF,$03,$04
	dc.b	$FF,$04,$03,$FF,$03,$04,$FF,$03,$04,$FF,$05,$06,$FF,$05,$06,$FF
	dc.b	$05,$06,$FF,$05,$06,$FF,$05,$06,$FF,$05,$06,$FF,$06,$05,$FF,$FF

lineinput	;Pad input while the line change box is open (pflags2 bit 3)
	movem.w	d1/d4,-(sp)
	movea.w	#(tmstruct-M68K_RAM),a2
	btst	#6,pflags(a3)
	beq.w	.1
	adda.w	#$39E,a2
.1
	bclr	#0,limpact(a2)
	beq.w	.0
	bsr.w	lcfound2
	bsr.w	SetLCmode2
.0
	movem.w	(sp)+,d1/d4
	clr.w	d2
	btst	#6,d1
	bne.w	.2
	addq.w	#1,d2
	btst	#4,d1
	bne.w	lcfound
	addq.w	#1,d2
	btst	#5,d1
	bne.w	lcfound
	btst	#3,pflags(a3)
	beq.w	.x
	btst	#5,pflags(a3)
	bne.w	.x
	btst	#0,pflags2(a3)
	beq.w	.5
.x
	rts
.5
	jmp	doplayeracc
.2
	movem.l	a0,-(sp)
	movea.l	#$FFFFD2EC,a0
	move.w	#$3E8,(a0,d4.w)
	movem.l	(sp)+,a0

lcfound	;Line choice d2 made: set the line, close the box
	move.w	d2,d0
	move.w	d2,impactp(a2)
	bsr.w	getlchoice	;translate choice 0-2 into line number 0-6
	tst.w	d0
	bmi.w	rtss
	bclr	#3,pflags2(a3)
	bset	#3,pflags(a3)
	jsr	(loadTeamStruct).l
	bclr	#1,limpact(a2)
	move.w	d0,$16(a2)
	jsr	(setpersonel).l

lcfound2
	btst	#4,(sflags9).w
	bne.w	rtss
	bsr.w	setlccords
	cmpi.w	#$F,(printy).w
	blt.w	.nollcm
	bclr	#0,(sflags3).w
.nollcm
	addq.w	#1,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	bclr	#2,(sflags12).w
	bset	#3,(sflags12).w
	jmp	printscores1

