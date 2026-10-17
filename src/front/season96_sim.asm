;	The season game simulation. SimGameStats, SimGoalie and PickSimGoalie play out the games
;	the user does not play.

SimGameStats
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(vcount).w,d0
	jsr	(randomd0).l
	movea.l	#tmstruct,a1
	move.w	#$39D,d0
.loop
	clr.w	(a1)+
	dbf	d0,.loop
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,(HomeTeam).w
	clr.w	d0
	move.b	1(a0),d0
	move.w	d0,(VisTeam).w
	movea.l	#tmstruct,a1
	movea.l	#AwShots,a2
	move.w	(HomeTeam).w,$28(a1)
	move.w	(VisTeam).w,$28(a2)
	movem.l	a2,-(sp)
	movea.l	#tmstruct,a2
	jsr	(SetSeasonInjuries).l
	movea.l	#AwShots,a2
	jsr	(SetSeasonInjuries).l
	movem.l	(sp)+,a2
	clr.w	d0
	move.b	2(a0),d0
	move.w	d0,$C(a1)
	move.w	d0,(rosterscroll).w
	move.w	(HomeTeam).w,d1
	move.w	(VisTeam).w,d2
	bsr.w	SimShots
	move.w	d0,(a1)
	movea.l	#$FFFF5208,a5
	movea.l	#$FFFF5244,a4
	bsr.w	SimScorers
	bsr.w	SimTeamAssists
	movea.l	#$FFFF5668,a6
	bsr.w	SimPenalties
	clr.w	d0
	move.b	3(a0),d0
	move.w	d0,$C(a2)
	move.w	d0,(rosterscroll).w
	move.w	(VisTeam).w,d1
	move.w	(HomeTeam).w,d2
	bsr.w	SimShots
	move.w	d0,(a2)
	movea.l	a2,a1
	movea.l	#$FFFF55F0,a5
	movea.l	#$FFFF562C,a4
	bsr.w	SimScorers
	bsr.w	SimTeamAssists
	movea.l	#$FFFF56A4,a6
	bsr.w	SimPenalties
	bsr.w	SimGoalieStats
	jsr	(SaveGameStats).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SimPenalties	;Sim penalties of team d1: the count (SimPenaltyBase), 2 PIM each to skaters by aggression rank (SimRankOdds),
	;the first a major
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$C0,d0
	jsr	(randomd0).l
	asr.w	#5,d0
	movea.l	#SimPenaltyBase,a3
	add.b	(a3,d1.w),d0
	cmp.b	#1,d0
	ble.w	.0
	asr.b	#1,d0
.0
	move.l	a1,-(sp)
	addq.w	#6,a1
	move.w	d0,(a1)
	movea.l	(sp)+,a1
	move.w	d1,$28(a1)
	movem.l	d1/a0-a1,-(sp)
	movea.l	#TeamList,a0
	asl.w	#2,d1
	move.l	(a0,d1.w),-(sp)
	adda.w	#$1E,a1
	move.l	(sp)+,(a1)
	movem.l	(sp)+,d1/a0-a1
	movem.l	a4/a6,-(sp)
	move.l	(PAttribAggressMask).l,d4
	movea.l	a1,a2
.1
	clr.w	d0
	move.b	(a4)+,d0
	bmi.w	.2
	movem.l	d2-d7/a0-a6,-(sp)
	bset	#4,(sflags13).w
	jsr	(CalcAttrib).l
	bclr	#4,(sflags13).w
	movem.l	(sp)+,d2-d7/a0-a6
	move.w	d0,(a6)+
	bra.s	.1
.2
	movem.l	(sp)+,a4/a6
	move.l	a5,-(sp)
	movea.l	a6,a5
	bsr.w	SortBytesByWords
	movea.l	(sp)+,a5
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	6(a1),d6
	move.w	d6,d7
	subq.w	#1,d7
	movea.l	#SimRankOdds,a3
	bra.w	.7
.3
	move.w	#$64,d0
	jsr	(randomd0).l
	clr.w	d5
.4
	cmp.b	(a3,d5.w),d0
	ble.w	.5
	addq.w	#1,d5
	bra.s	.4
.5
	clr.w	d0
	move.b	(a4,d5.w),d0
	move.w	d0,d1
	asl.w	#1,d1
	addi.w	#$6C,d1
	tst.w	(a1,d1.w)
	bne.w	.7
	move.l	a1,-(sp)
	adda.w	#$114,a1
	addq.b	#2,(a1,d0.w)
	cmp.w	d7,d6
	bne.w	.6
	addq.b	#3,(a1,d0.w)
.6
	movea.l	(sp)+,a1
.7
	dbf	d6,.3
	movem.l	(sp)+,d0-d7/a0-a6
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SimPenaltyBase	;Per team: the base sim penalty count (SimPenalties)
	dc.b	$04,$04,$06,$09,$07,$07,$06,$08,$04,$05,$06,$05,$04,$05,$04,$04
	dc.b	$04,$06,$04,$05,$06,$07,$04,$07,$08,$08

SimGoalieStats
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(HomeTeam).w,d7
	movea.l	#tmstruct,a1
	movea.l	#AwShots,a2
	bsr.w	SimGoalie
	move.w	(VisTeam).w,d7
	movea.l	#AwShots,a1
	movea.l	#tmstruct,a2
	bsr.w	SimGoalie
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SimGoalie
	jsr	(GetGoalieCountD7).l
	subq.w	#1,d0
	bsr.w	PickSimGoalie
	move.w	d0,d3
	add.w	d3,d3
	addi.w	#$14C,d3
	addi.w	#$E10,(a1,d3.w)
	move.w	(a2),d4
	cmp.w	#$FF,d4
	ble.w	.0
	move.w	#$FF,d4
.0
	move.w	d0,d3
	addi.w	#$F8,d3
	move.b	d4,(a1,d3.w)
	move.w	$C(a2),d4
	move.w	d0,d3
	addi.w	#$C0,d3
	move.b	d4,(a1,d3.w)
	rts

PickSimGoalie
	movem.l	d1-d7,-(sp)
	clr.w	d1
	move.w	#$64,d0
	jsr	(randomd0).l
	cmp.w	#$2D,d0
	bgt.w	.0
	move.w	#1,d1
.0
	move.w	d1,d0
	movem.l	(sp)+,d1-d7
	rts

SimScorers	;Give each of the rosterscroll goals to a skater picked by rank (SimRankOdds) from the sorted list a4; injured
	;picks re-roll
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(rosterscroll).w,d6
	movea.l	#SimRankOdds,a3
	bra.w	.3
.0
	move.w	#$64,d0
	jsr	(randomd0).l
	clr.w	d5
.1
	cmp.b	(a3,d5.w),d0
	ble.w	.2
	addq.w	#1,d5
	bra.s	.1
.2
	clr.w	d0
	move.b	(a4,d5.w),d0
	move.w	d0,d1
	asl.w	#1,d1
	addi.w	#$6C,d1
	tst.w	(a1,d1.w)
	bne.s	.0
	move.l	a1,-(sp)
	adda.w	#$C0,a1
	addq.b	#1,(a1,d0.w)
	movea.l	(sp)+,a1
.3
	dbf	d6,.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SimTeamAssists	;Sim assists: goals x 1.0-2.0, each to a skater picked by rank (SimAssistOdds); injured picks are dropped
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(rosterscroll).w,d6
	move.w	#$64,d0
	jsr	(randomd0).l
	addi.w	#$64,d0
	muls.w	d0,d6
	divs.w	#$64,d6
	movea.l	#SimAssistOdds,a3
	bra.w	.3
.0
	move.w	#$64,d0
	jsr	(randomd0).l
	clr.w	d5
.1
	cmp.b	(a3,d5.w),d0
	ble.w	.2
	addq.w	#1,d5
	bra.s	.1
.2
	clr.w	d0
	move.b	(a4,d5.w),d0
	move.w	d0,d1
	asl.w	#1,d1
	addi.w	#$6C,d1
	tst.w	(a1,d1.w)
	bne.w	.3
	move.l	a1,-(sp)
	adda.w	#$DC,a1
	addq.b	#1,(a1,d0.w)
	movea.l	(sp)+,a1
.3
	dbf	d6,.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SimShots	;d0 = shots: d0 (goals) - SimTeamDefense of team d2 + 30 + a random 0-20
	movem.l	d1-d7/a0-a6,-(sp)
	movea.l	#SimTeamDefense,a1
	clr.w	d3
	move.b	(a1,d2.w),d3
	sub.w	d3,d0
	move.w	d0,-(sp)
	move.w	#$14,d0
	jsr	(randomd0).l
	addi.w	#$1E,d0
	add.w	(sp)+,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts

SimAssistOdds	;SimTeamAssists: cumulative % of picking each rank of the sorted skater list
	dc.b	$0C,$18,$24,$2E,$36,$3E,$46,$4C,$52,$56,$5A,$5E,$60,$62,$64

SimRankOdds	;SimScorers / SimPenalties: cumulative % of picking each rank of the sorted skater list
	dc.b	$0D,$19,$22,$2B,$34,$3B,$42,$48,$4E,$54,$58,$5C,$60,$62,$64
