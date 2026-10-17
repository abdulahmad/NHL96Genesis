;	The game clock on the ice, and the big score.

showclock	;Put the game clock on screen (m:ss), or else queue it (showclockdma)
	btst	#7,(sflags).w
	beq.w	showclockdma
	btst	#0,(gmode2).w
	bne.w	.2
	move.l	a1,-(sp)
	jsr	(printz).l
	String	$BE,$0D,$05
	move.w	(gameclock).w,d0
	ext.l	d0
	divu.w	#$258,d0
	move.l	d0,-(sp)
	tst.w	d0
	bne.w	.0
	addq.w	#1,(printx).w
	bra.w	.1
.0
	jsr	(PrintClockDigit).l
.1
	move.l	(sp)+,d0
	swap	d0
	ext.l	d0
	divu.w	#$3C,d0
	move.l	d0,-(sp)
	jsr	(PrintClockDigit).l
	move.l	(sp)+,d0
	swap	d0
	ext.l	d0
	addq.w	#2,(printx).w
	divu.w	#$A,d0
	move.l	d0,-(sp)
	jsr	(PrintClockDigit).l
	move.l	(sp)+,d0
	swap	d0
	ext.l	d0
	jsr	(PrintClockDigit).l
	movea.l	(sp)+,a1
	jsr	(printz).l
	String	$BD,$0D,$05
.2
	rts

PrintClockDigit	;Print digit d0 (ClockDigitText)
	movea.l	#ClockDigitText,a1
	asl.w	#2,d0
	adda.w	d0,a1
	jsr	(print).l
	rts

ClockDigitText	;The digits 0-9
	String	$30
	String	$31
	String	$32
	String	$33
	String	$34
	String	$35
	String	$36
	String	$37
	String	$38
	String	$39

showclockdma	;When dfclock is set queue the clock chars in the dma list (a5)
	bclr	#3,(disflags).w
	beq.w	rtsBigClock
	btst	#3,(sflags2).w
	bne.w	rtsBigClock
	cmpi.w	#4,(gsp).w
	beq.w	rtsBigClock
	movea.w	#(clockram+8-M68K_RAM),a0
	movea.l	#BigFontMap,a1
	adda.l	4(a1),a1
	move.w	$50(a1),d0
	add.w	(bigfont1chars).w,d0
	ori.w	#$8000,d0
	move.w	d0,(clockram).w
	move.w	$4E(a1),d0
	add.w	(bigfont1chars).w,d0
	ori.w	#$8000,d0
	move.w	d0,-(a0)
	move.w	(gameclock).w,d0
	btst	#1,(gmode2).w
	beq.w	.gotclock
	move.w	(shootoutclock).w,d0
.gotclock
	ext.l	d0
	divu.w	#$A,d0
	bsr.w	BigClockDigitChar
	divu.w	#6,d0
	bsr.w	BigClockDigitChar
	subq.w	#2,a0
	divu.w	#$A,d0
	bsr.w	BigClockDigitChar
	swap	d0
	tst.l	d0
	bne.w	.1
	moveq	#-1,d0
	swap	d0
.1
	bsr.w	BigClockDigitChar
	move.w	$52(a1),d0
	add.w	(bigfont1chars).w,d0
	ori.w	#$8000,d0
	move.w	d0,-(a0)
	move.l	a0,(a5)+
	move.w	#7,(a5)+
	movea.w	#(VmMap1-M68K_RAM),a1
	moveq	#$19,d0
	moveq	#1,d2
	btst	#7,(sflags).w
	beq.w	.0
	movea.w	#(VmMap2-M68K_RAM),a1
	moveq	#5,d0
	moveq	#$D,d2
.0
	move.w	2(a1),d1
	asl.w	d1,d0
	add.w	d2,d0
	asl.w	#1,d0
	add.w	(a1),d0
	move.w	d0,(a5)+
	movea.w	#(clockram2+8-M68K_RAM),a0
	movea.l	#BigFontMap,a1
	adda.l	4(a1),a1
	move.w	$B0(a1),d0
	add.w	(bigfont1chars).w,d0
	ori.w	#$8000,d0
	move.w	d0,(clockram2).w
	move.w	$AE(a1),d0
	add.w	(bigfont1chars).w,d0
	ori.w	#$8000,d0
	move.w	d0,-(a0)
	move.w	(gameclock).w,d0
	btst	#1,(gmode2).w
	beq.w	.2
	move.w	(shootoutclock).w,d0
.2
	ext.l	d0
	divu.w	#$A,d0
	bsr.w	ClockDigitChar2
	divu.w	#6,d0
	bsr.w	ClockDigitChar2
	subq.w	#2,a0
	divu.w	#$A,d0
	bsr.w	ClockDigitChar2
	swap	d0
	tst.l	d0
	bne.w	.3
	moveq	#-1,d0
	swap	d0
.3
	bsr.w	ClockDigitChar2
	move.w	$B2(a1),d0
	add.w	(bigfont1chars).w,d0
	ori.w	#$8000,d0
	move.w	d0,-(a0)
	move.l	a0,(a5)+
	move.w	#7,(a5)+
	movea.w	#(VmMap1-M68K_RAM),a1
	moveq	#$1A,d0
	moveq	#1,d2
	btst	#7,(sflags).w
	beq.w	.4
	movea.w	#(VmMap2-M68K_RAM),a1
	moveq	#5,d0
	moveq	#$D,d2
.4
	move.w	2(a1),d1
	asl.w	d1,d0
	add.w	d2,d0
	asl.w	#1,d0
	add.w	(a1),d0
	move.w	d0,(a5)+
	rts

BigClockDigitChar	;showclockdma helper: next digit of d0 as a big-font clock char word to -(a0)
	swap	d0
	asl.w	#1,d0
	move.w	$38(a1,d0.w),d0
	add.w	(bigfont1chars).w,d0
	ori.w	#$8000,d0
	move.w	d0,-(a0)
	swap	d0
	ext.l	d0

rtsBigClock	;BigClockDigitChar returns here. showclockdma exits here too
	rts

ClockDigitChar2	;The same from the second char row of the font
	swap	d0
	asl.w	#1,d0
	addi.w	#$98,d0
	move.w	(a1,d0.w),d0
	add.w	(bigfont1chars).w,d0
	ori.w	#$8000,d0
	move.w	d0,-(a0)
	swap	d0
	ext.l	d0
	rts

ShowBigScore	;The big score of both teams with the EASN logo; in a shootout also the period (ScorePeriodText)
	movem.l	d0-d7/a0-a6,-(sp)
	bset	#2,(sflags12).w
	bset	#0,(byte_FFC35A).w
	jsr	(ErasePowerPlayBox).l
	jsr	(EASNLogo).l
	jsr	(printbigz2).l
	String	$F8,$04,$01,$06,$15,$20,$FB,$0F
	move.w	(AwGoals).w,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printbig2).l
	jsr	(printbigz2).l
	String	$3E
	jsr	(printbigz2).l
	String	$F8,$04,$01,$06,$17,$20,$FB,$0F
	move.w	(HmGoals).w,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printbig2).l
	jsr	(printbigz2).l
	String	$3E
	btst	#0,(gmode2).w
	beq.w	.0
	jsr	(printz).l
	String	$BF,$08,$19
	jsr	(printbigz2).l
	String	'    shootout    '
	jsr	(printbigz2).l
	String	$3E
	bra.w	.1
.0
	jsr	(printz).l
	String	$BF,$08,$19
	movea.l	#ScorePeriodText,a1
	move.w	(gsp).w,d0
	jsr	(SkipStrings).l
	jsr	(printbig2).l
	jsr	(printbigz2).l
	String	$3E
.1
	jsr	(printbigz1).l
	String	$F8,$04,$01,$07,$15,'<            >',$FD,$08
	move.w	(AwShots+$28).w,d0
	movea.w	#TeamList,a1
	asl.w	#2,d0
	movea.l	(a1,d0.w),a1
.2
	adda.w	4(a1),a1
	adda.w	(a1),a1
	adda.w	(a1),a1
	jsr	(printbig1).l
	jsr	(printbigz1).l
	String	$F8,$04,$01,$07,$17,'<            >',$FD,$08
	move.w	(tmstruct+$28).w,d0
	movea.w	#TeamList,a1
	asl.w	#2,d0
	movea.l	(a1,d0.w),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	adda.w	(a1),a1
	jsr	(printbig1).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ScorePeriodText	;ShowBigScore: the period names
	String	'  1st period    '
	String	'  2nd period    '
	String	'  3rd period    '
	String	'   overtime     '
	String	'     final      '

ClearBigScore	;Erase the big score
	movem.l	d0-d7/a0-a6,-(sp)
	bclr	#0,(byte_FFC35A).w
	jsr	(printz).l
	String	$BF,$01,$15
	move.w	#$1B,d0
	move.w	#4,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	$BF,$08,$19
	move.w	#$14,d0
	move.w	#2,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

