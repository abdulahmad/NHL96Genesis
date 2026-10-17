;	The boxes at a whistle. The three stars, an injury and a penalty shot share
;	this file with the goal box.

ShowThreeStars	;End of game Stars of the Game box. Waits for RefCnt <= $40 and runs once (gmode bit 7); then disflags
	;bit 3 and a vblank. Frames the box, then the three best star scores (TakeTopStarScore)
	cmpi.w	#$40,(RefCnt).w
	bgt.w	rtss2
	bset	#7,(gmode).w
	bne.w	rtss2
	jsr	(ClearBigScore).l
	jsr	(ErasePowerPlayBox).l
	movem.l	d0/a1,-(sp)
	bset	#3,(disflags).w
	move.w	(vcount).w,d0
.loop2
	cmp.w	(vcount).w,d0
	beq.s	.loop2
	movem.l	(sp)+,d0/a1
	movem.l	d0-d5/a0-a4,-(sp)
	bsr.w	printz
	String	$BF,$02,$0E
	moveq	#$1C,d0
	moveq	#9,d1
	bsr.w	Framer
	bsr.w	printbigz2
	String	$F8,$04,$01,$03,$10,'    Stars of the Game     ',$F8,$04,$01,$03,$0F
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

TakeTopStarScore	;Take the highest star score at ThreeStars (home team first) and clear it. Returns d0 = player slot, a2 =
	;its team struct
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

CalcStarScores	;Star score for every roster slot of both teams to ThreeStars (home team first).
	;Code the listing does not decode: kept as bytes
	dc.b	$38,$7C,$D1,$30,$4E,$B9,$00,$01,$48,$A2,$3A,$00,$DA,$42,$34,$7C
	dc.b	$C7,$26,$47,$EA,$03,$9E,$61,$00,$00,$48,$34,$4B,$47,$EA,$FC,$62
	dc.b	$61,$00,$00,$3E,$0C,$78,$00,$03,$C4,$BC,$66,$00,$00,$32,$4A,$43
	dc.b	$67,$00,$00,$2C,$30,$7C,$C4,$C6,$D0,$F8,$C4,$CA,$42,$40,$08,$28
	dc.b	$00,$07,$00,$02,$67,$00,$00,$06,$06,$40,$00,$1C,$D0,$28,$00,$03
	dc.b	$E5,$40,$30,$7C,$D1,$30,$21,$BC,$7F,$FF,$FF,$FF,$00,$00,$4E,$75

CalcTeamStarScores	;Star scores of team a2 (a3 = other team) to (a4)+, one long per roster slot.
	;Code the listing does not decode: kept as bytes
	dc.b	$32,$4A,$36,$2A,$00,$0C,$96,$6B,$00,$0C,$48,$C3,$78,$1B,$4E,$B9
	dc.b	$00,$01,$57,$A2,$44,$40,$D0,$44,$28,$83,$B8,$40,$62,$00,$00,$3C
	dc.b	$42,$41,$12,$2A,$00,$C0,$C2,$FC,$2A,$F8,$D3,$94,$42,$41,$12,$2A
	dc.b	$00,$DC,$C2,$FC,$27,$74,$D3,$94,$42,$41,$12,$2A,$00,$F8,$C2,$FC
	dc.b	$00,$0A,$4A,$43,$66,$00,$00,$0E,$C2,$FC,$00,$64,$D3,$94,$42,$81
	dc.b	$D2,$69,$01,$4C,$D3,$94,$60,$00,$00,$3A,$BA,$69,$01,$4C,$62,$00
	dc.b	$00,$32,$42,$41,$12,$2A,$00,$C0,$C2,$FC,$00,$64,$42,$42,$14,$2A
	dc.b	$00,$F8,$67,$00,$00,$1E,$82,$C2,$B2,$7C,$00,$04,$62,$00,$00,$14
	dc.b	$06,$94,$00,$00,$7D,$00,$4A,$41,$66,$00,$00,$08,$06,$94,$00,$01
	dc.b	$24,$F8,$54,$49,$52,$4A,$58,$4C,$51,$CC,$FF,$7E,$4E,$75

ShowInjuryBox	;The injury message (CheckInjury): "Injured player", "Out for period", "game" or n "games", then the player
	;(GetPlayerNumInitial)
	movem.l	d0-d2/a0-a4,-(sp)
	bsr.w	printz
	String	$BF,$0B,$02
	moveq	#$12,d0
	moveq	#6,d1
	bsr.w	Framer
	btst	#3,(sflags13).w
	bne.w	.1
	btst	#5,(sflags7).w
	bne.w	.0
	bsr.w	printbigz2
	String	$F8,$04,$01,$0C,$03,'Injured player  '
	jsr	(printz).l
	String	$BF,$0C,$06,'Out for period',$BF,$0C,$05
	bra.w	.4
.0
	bsr.w	printbigz2
	String	$F8,$04,$01,$0C,$03,'Injured player  '
	jsr	(printz).l
	String	$BF,$0C,$06,'Out for game',$BF,$0C,$05
	bra.w	.4
.1
	bsr.w	printbigz2
	String	$F8,$04,$01,$0C,$03,'Injured player  '
	jsr	(printz).l
	String	$BF,$0C,$06,'Out for '
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
	String	$BF,$0C,$05
.4
	bsr.w	GetPlayerNumInitial
	bsr.w	print
	btst	#0,(puck_pflags2).w
	beq.w	.5
	bsr.w	printz
	String	$BF,$14,$06,'the game'
.5
	movem.l	(sp)+,d0-d2/a0-a4
	rts

PenaltyShotBox	;In a shootout ShootoutModeBox; else the "PENALTY SHOT!" box: the shooter, the penalty (Penaltylist) and " by"
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
	String	$BF,$06,$02
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
	String	$BF,$07,$07
	movem.l	a1/a3,-(sp)
	move.w	(pspenalty).w,d0
	movea.l	#Penaltylist,a1
	adda.w	(a1,d0.w),a1
	lea	2(a1),a1
	bsr.w	print
	movem.l	(sp)+,a1/a3
	bsr.w	printz
	String	' by',$BF,$07,$08
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

PenShotBigTxt	;PenaltyShotBox big text
	String	$F8,$04,$01,$07,$03,'   PENALTY SHOT    ',$F8,$04,$01,$07,$05

ShowGoalBox	;Goal box: close both line change boxes (lcfound2), then the scorer and the assists from ScoreSum
	;(PrintPlayerGoals / PrintPlayerAssists), the goalie counts (CountGoalies)
	movem.l	d0-d2/a0-a4,-(sp)
	btst	#2,(BA_PS_flags).w
	beq.w	.0
	bset	#2,(sflags2).w
.0
	movea.w	#(tmstruct-M68K_RAM),a2
	jsr	(lcfound2).l
	adda.w	#$39E,a2
	jsr	(lcfound2).l
	jsr	(ShowBigScore).l
	movea.w	#(ScoreSum-6-M68K_RAM),a4
	adda.w	(ScoreSumbytes).w,a4
	bsr.w	printz
	String	$BF,$0B,$02
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
	lea	GoalBigTxt(pc),a1
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
	String	$BF,$0E,$06,'Assist by:',$BF,$0C,$07
	move.w	d0,-(sp)
	bsr.w	FormatPlayerName
	bsr.w	print
	move.w	(sp)+,d0
	jsr	(PrintPlayerAssists).l
	clr.w	d0
	move.b	5(a4),d0
	bmi.w	.6
	bsr.w	printz
	String	$BF,$0C,$08
	move.w	d0,-(sp)
	bsr.w	FormatPlayerName
	bsr.w	print
	move.w	(sp)+,d0
	jsr	(PrintPlayerAssists).l
.6
	bclr	#5,(sflags4).w
	movem.l	(sp)+,d0-d2/a0-a4
	rts

GoalBigTxt	;printbig Strings for ShowGoalBox: GOAL!, then HAT TRICK!
	String	$F8,$04,$01,$0C,$03,'      GOAL!      ',$F8,$04,$01,$0C,$05
	String	$F8,$04,$01,$0C,$03,'   HAT TRICK!    ',$F8,$04,$01,$0C,$05

PPGoalBigTxt	;The same after a power play: PP GOAL!, then HAT TRICK!
	String	$F8,$04,$01,$0C,$03,'    PP GOAL!     ',$F8,$04,$01,$0C,$05
	String	$F8,$04,$01,$0C,$03,'   HAT TRICK!    ',$F8,$04,$01,$0C,$05

box	;Fill a $14 x $C rectangle at printz position $FF,$B,2 with char $7FF (eraser)
	bsr.w	printz
	String	$FF,$0B,$02
	moveq	#$14,d0
	moveq	#$C,d1
	move.l	#$7FF,d2
	bra.w	eraser

