;	The boxes at a whistle. The three stars, an injury and a penalty shot share
;	this file with the goal box.

ShowThreeStars						;End of game Stars of the Game box. Waits for RefCnt <= $40 and runs once
									;(gmode bit 7); then disflags bit 3 and a vblank. Frames the box, then the
									;three best star scores (TakeTopStarScore)
	cmpi.w	#$40,(RefCnt).w
	bgt.w	rtss2
	bset	#gmstars,(gmode).w
	bne.w	rtss2
	jsr	(ClearBigScore).l
	jsr	(ErasePowerPlayBox).l
	movem.l	d0/a1,-(sp)
	bset	#dfclock,(disflags).w
	move.w	(Vcount).w,d0
.loop2
	cmp.w	(Vcount).w,d0
	beq.s	.loop2
	movem.l	(sp)+,d0/a1
	movem.l	d0-d5/a0-a4,-(sp)
	bsr.w	printz
	String	CC_Font1Pri,$02,$0E
	moveq	#$1C,d0
	moveq	#9,d1
	bsr.w	Framer
	bsr.w	printbigz2
	String	CC_SetMapAndPosition,$04,$01,$03,$10,'    Stars of the Game     ',CC_SetMapAndPosition,$04,$01,$03,$0F
	bsr.w	CalcStarScores
	move.w	#$12,(printy).w
	moveq	#2,d2
.loop
	bsr.w	TakeTopStarScore
.0
	move.w	#$1A,(printx).w
	addq.w	#1,(printy).w
	movea.l	$1E(a2),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	bsr.w	print
	bsr.w	getname
	move.w	#3,(printx).w
	bsr.w	print
	dbf	d2,.loop
	move.w	(HmGoals).w,d0
	sub.w	(AwGoals).w,d0
	ble.w	.nosong
	move.w	#$F,-(sp)
	jsr	(song).l
.nosong
	movem.l	(sp)+,d0-d5/a0-a4
	rts

TakeTopStarScore					;Take the highest star score at ThreeStars (home team first) and clear it.
									;Returns d0 = player slot, a2 = its team struct
	movem.l	d1-d2/a1/a4,-(sp)
.0
	movea.w	#(ThreeStars-M68K_RAM),a4
	clr.l	d0
	moveq	#$37,d2
.find
	cmp.l	(a4)+,d0
	bge.w	.next
	lea	-4(a4),a1
	move.l	(a1),d0
.next
	dbf	d2,.find
	clr.l	(a1)
	move.w	a1,d0
	subi.w	#(ThreeStars-M68K_RAM),d0
	lsr.w	#2,d0
	movea.w	#(tmstruct-M68K_RAM),a2
	cmp.w	#$1C,d0
	blt.w	.home
	subi.w	#$1C,d0
	adda.w	#$39E,a2
.home
	movem.l	(sp)+,d1-d2/a1/a4
	rts

CalcStarScores						;Star score for every roster slot of both teams to ThreeStars (home team
									;first).
	movea.w	#(ThreeStars-M68K_RAM),a4
	jsr	(GetPeriodTime).l
	move.w	d0,d5
	add.w	d2,d5
	movea.w	#(tmstruct-M68K_RAM),a2
	lea	$39E(a2),a3
	bsr.w	CalcTeamStarScores		;home
	movea.w	a3,a2
	lea	-$39E(a2),a3
	bsr.w	CalcTeamStarScores		;away (d3 = away - home score)
	cmpi.w	#3,(gsp).w
	bne.w	.2
	tst.w	d3
	beq.w	.2
	movea.w	#(ChkCnt2-M68K_RAM),a0
	adda.w	(ScoreSumbytes).w,a0
	clr.w	d0
	btst	#7,2(a0)
	beq.w	.1
	addi.w	#$1C,d0
.1
	add.b	3(a0),d0
	asl.w	#2,d0
	movea.w	#(ThreeStars-M68K_RAM),a0
	move.l	#$7FFFFFFF,(a0,d0.w)
.2
	rts

CalcTeamStarScores					;Star scores of team a2 (a3 = other team) to (a4)+, one long per roster
									;slot.
	movea.w	a2,a1
	move.w	$C(a2),d3
	sub.w	$C(a3),d3
	ext.l	d3
	moveq	#$1B,d4
	jsr	(GetGoalieCount).l
	neg.w	d0
	add.w	d4,d0
.loop
	move.l	d3,(a4)
	cmp.w	d0,d4
	bhi.w	.2
	clr.w	d1
	move.b	$C0(a2),d1
	mulu.w	#$2AF8,d1				;goals * 11000
	add.l	d1,(a4)
	clr.w	d1
	move.b	$DC(a2),d1
	mulu.w	#$2774,d1				;assists * 10100
	add.l	d1,(a4)
	clr.w	d1
	move.b	$F8(a2),d1
	mulu.w	#$A,d1
	tst.w	d3
	bne.w	.1
	mulu.w	#$64,d1					;tied: shots * 1000
	add.l	d1,(a4)
	clr.l	d1
	add.w	$14C(a1),d1
.1
	add.l	d1,(a4)
	bra.w	.3
.2
	cmp.w	$14C(a1),d5
	bhi.w	.3
	clr.w	d1
	move.b	$C0(a2),d1
	mulu.w	#$64,d1
	clr.w	d2
	move.b	$F8(a2),d2
	beq.w	.3
	divu.w	d2,d1
	cmp.w	#4,d1
	bhi.w	.3
	addi.l	#$7D00,(a4)				;32000
	tst.w	d1
	bne.w	.3
	addi.l	#$124F8,(a4)			;75000 for a shutout
.3
	addq.w	#2,a1
	addq.w	#1,a2
	addq.w	#4,a4
	dbf	d4,.loop
	rts

ShowInjuryBox						;The injury message (CheckInjury): "Injured player", "Out for period",
									;"game" or n "games", then the player
									;(GetPlayerNumInitial)
	movem.l	d0-d2/a0-a4,-(sp)
	bsr.w	printz
	String	CC_Font1Pri,$0B,$02
	moveq	#$12,d0
	moveq	#6,d1
	bsr.w	Framer
	btst	#3,(sflags13).w
	bne.w	.1
	btst	#5,(sflags7).w
	bne.w	.0
	bsr.w	printbigz2
	String	CC_SetMapAndPosition,$04,$01,$0C,$03,'Injured player  '
	jsr	(printz).l
	String	CC_Font1Pri,$0C,$06,'Out for period',CC_Font1Pri,$0C,$05
	bra.w	.4
.0
	bsr.w	printbigz2
	String	CC_SetMapAndPosition,$04,$01,$0C,$03,'Injured player  '
	jsr	(printz).l
	String	CC_Font1Pri,$0C,$06,'Out for game',CC_Font1Pri,$0C,$05
	bra.w	.4
.1
	bsr.w	printbigz2
	String	CC_SetMapAndPosition,$04,$01,$0C,$03,'Injured player  '
	jsr	(printz).l
	String	CC_Font1Pri,$0C,$06,'Out for '
	move.w	(injurygames).w,d0
	move.w	#1,d1
	jsr	(PushNumberWidth).l
	jsr	(print).l
	cmpi.w	#1,(injurygames).w
	bgt.w	.2
	jsr	(printz).l
	String	' game'
	bra.w	.3
.2
	jsr	(printz).l
	String	' games'
.3
	jsr	(printz).l
	String	CC_Font1Pri,$0C,$05
.4
	bsr.w	GetPlayerNumInitial
	bsr.w	print
	btst	#0,(puck_pflags2).w
	beq.w	.5
	bsr.w	printz
	String	CC_Font1Pri,$14,$06,'the game'
.5
	movem.l	(sp)+,d0-d2/a0-a4
	rts

PenaltyShotBox						;In a shootout ShootoutModeBox; else the "PENALTY SHOT!" box: the shooter,
									;the penalty (Penaltylist) and " by"
									;the checker
	bset	#7,(gmode2).w
	btst	#0,(gmode2).w
	beq.w	.box
	jmp	ShootoutModeBox
.box
	movem.l	d0-d2/a0-a4,-(sp)
	move.w	#$FFFF,d0
.0
	jsr	(prefmes).l
	bsr.w	printz
	String	CC_Font1Pri,$06,$02
	moveq	#$15,d0
	moveq	#8,d1
.1
	bsr.w	Framer
	lea	PenShotBigTxt(pc),a1
.3
	jsr	(printbig2).l
	move.w	(BA_Sktr_SCnum).w,d0
	asl.w	#7,d0
	movea.l	#SortCords,a2
	adda.w	d0,a2
	clr.w	d0
	move.b	$67(a2),d0
	movea.l	#tmstruct,a2
	tst.w	(BA_Team).w
	beq.w	.5
.4
	movea.l	#AwShots,a2
.5
	bsr.w	FormatPlayerNumInitial
	bsr.w	print
	bsr.w	printz
	String	CC_Font1Pri,$07,$07
	movem.l	a1/a3,-(sp)
	move.w	(pspenalty).w,d0
	movea.l	#Penaltylist,a1
	adda.w	(a1,d0.w),a1
	lea	penname(a1),a1
	bsr.w	print
	movem.l	(sp)+,a1/a3
	bsr.w	printz
	String	' by',CC_Font1Pri,$07,$08
	move.w	(BA_Checker_Offset).w,d0
	movea.l	#AwShots,a2
	tst.w	(BA_Team).w
	beq.w	.2
	movea.l	#tmstruct,a2
.2
	jsr	(FormatPlayerNumInitial).l
	jsr	(print).l
	movem.l	(sp)+,d0-d2/a0-a4
	rts

PenShotBigTxt						;PenaltyShotBox big text
	String	CC_SetMapAndPosition,$04,$01,$07,$03,'   PENALTY SHOT    ',CC_SetMapAndPosition,$04,$01,$07,$05

ShowGoalBox							;Goal box: close both line change boxes (lcfound2), then the scorer and
									;the assists from ScoreSum (PrintPlayerGoals / PrintPlayerAssists), the
									;goalie counts (CountGoalies)
	movem.l	d0-d2/a0-a4,-(sp)
	btst	#2,(BA_PS_flags).w
	beq.w	.0
	bset	#sf2drec,(sflags2).w
.0
	movea.w	#(tmstruct-M68K_RAM),a2
	jsr	(lcfound2).l
	adda.w	#$39E,a2
	jsr	(lcfound2).l
	jsr	(ShowBigScore).l
	movea.w	#(ScoreSum-6-M68K_RAM),a4
	adda.w	(ScoreSumbytes).w,a4
	bsr.w	printz
	String	CC_Font1Pri,$0B,$02
	moveq	#$13,d0
	move.w	#5,d1
	tst.b	4(a4)
	bmi.w	.4
	addq.w	#2,d1
	tst.b	5(a4)
	bmi.w	.4
	addq.w	#1,d1
.4
	bsr.w	Framer
	jsr	(CountGoalies).l
	movea.w	#(tmstruct-M68K_RAM),a2
	move.w	(homegoalies).w,(recwins).w
	btst	#7,2(a4)
	beq.w	.1
	adda.w	#$39E,a2
	move.w	(awaygoalies).w,(recwins).w
.1
	lea	GoalBoxText(pc),a1
	bclr	#0,(sflags9).w
	beq.w	.2
	lea	PPGoalBigTxt(pc),a1
.2
	clr.w	d0
	move.b	3(a4),d0
	addi.w	#$C0,d0
	cmpi.b	#3,(a2,d0.w)
	bne.w	.print
	movem.w	d1,-(sp)
	clr.w	d1
	move.b	3(a4),d1
	cmp.w	(recwins).w,d1
	movem.w	(sp)+,d1
	blt.w	.print
	adda.w	(a1),a1
	move.w	d0,-(sp)
	move.w	$28(a2),d0
	cmp.w	(HomeTeam).w,d0
	bne.w	.3
	move.w	#0,d0
	jsr	(StartArenaAnim).l
.3
	move.w	(sp)+,d0
.print
	jsr	(printbig2).l
	clr.w	d0
	move.b	3(a4),d0
	move.w	d0,-(sp)
	move.w	#$C,(printx).w
	bsr.w	FormatPlayerName
	bsr.w	print
	move.w	(sp)+,d0
	movem.w	d1,-(sp)
	clr.w	d1
	move.b	3(a4),d1
	cmp.w	(recwins).w,d1
	movem.w	(sp)+,d1
	blt.w	.5
	jsr	(PrintPlayerGoals).l
.5
	clr.w	d0
	move.b	4(a4),d0
	bmi.w	.6
	bclr	#5,(sflags4).w
	bne.w	.6
	bsr.w	printz
	String	CC_Font1Pri,$0E,$06,'Assist by:',CC_Font1Pri,$0C,$07
	move.w	d0,-(sp)
	bsr.w	FormatPlayerName
	bsr.w	print
	move.w	(sp)+,d0
	jsr	(PrintPlayerAssists).l
	clr.w	d0
	move.b	5(a4),d0
	bmi.w	.6
	bsr.w	printz
	String	CC_Font1Pri,$0C,$08
	move.w	d0,-(sp)
	bsr.w	FormatPlayerName
	bsr.w	print
	move.w	(sp)+,d0
	jsr	(PrintPlayerAssists).l
.6
	bclr	#5,(sflags4).w
	movem.l	(sp)+,d0-d2/a0-a4
	rts

GoalBoxText							;printbig Strings for ShowGoalBox: GOAL!, then HAT TRICK!
	String	CC_SetMapAndPosition,$04,$01,$0C,$03,'      GOAL!      ',CC_SetMapAndPosition,$04,$01,$0C,$05
	String	CC_SetMapAndPosition,$04,$01,$0C,$03,'   HAT TRICK!    ',CC_SetMapAndPosition,$04,$01,$0C,$05

PPGoalBigTxt						;The same after a power play: PP GOAL!, then HAT TRICK!
	String	CC_SetMapAndPosition,$04,$01,$0C,$03,'    PP GOAL!     ',CC_SetMapAndPosition,$04,$01,$0C,$05
	String	CC_SetMapAndPosition,$04,$01,$0C,$03,'   HAT TRICK!    ',CC_SetMapAndPosition,$04,$01,$0C,$05

box									;Fill a $14 x $C rectangle at printz position
									;$FF,$B,2 with char $7FF (eraser)
	bsr.w	printz
	String	CC_Font1,$0B,$02
	moveq	#$14,d0
	moveq	#$C,d1
	move.l	#$7FF,d2
	bra.w	eraser

