;	Roster names. DefaultRosters fills the default rosters. GetRosterName, GetJerseyNumber
;	and the name helpers read a player's name and number.

DefaultRosters
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#0,d1
	movea.l	#$FFFF1550,a6
	movea.l	#$FFFF1ACC,a5
	movea.l	#$FFFF1B00,a4
.team
	clr.w	d2
	movea.l	a6,a0
	move.w	#$1A,d5
.clr
	move.w	#$8000,(a0)+
	dbf	d5,.clr
	movea.l	a6,a0
	movea.l	a4,a2
	movea.l	#TeamList,a1
	move.w	d1,d0
	asl.w	#2,d0
	movea.l	(a1,d0.w),a1
	adda.w	(a1),a1
	bra.w	.store
.player
	cmpi.w	#2,(a1)
	beq.w	.counts
	addq.w	#1,d2
.store
	move.b	d1,(a0)+
	move.b	d2,(a0)+
	adda.w	(a1),a1
	move.b	(a1),d4
	move.b	d4,(a2)+
	addq.w	#8,a1
	bra.s	.player
.counts
	movem.l	d1-d7/a0,-(sp)
	move.w	d1,d7
	movea.l	#TeamList,a0
	asl.w	#2,d7
	movea.l	(a0,d7.w),a0
	adda.w	$A(a0),a0
	move.w	(a0),d1
	clr.w	d0
.goalies
	addq.w	#1,d0
	asl.w	#4,d1
	bne.s	.goalies
	movea.l	a5,a0
	move.b	d2,(a0)
	addq.b	#1,(a0)
	andi.b	#3,d0
	move.b	d0,1(a0)
	movem.l	(sp)+,d1-d7/a0
	adda.l	#$36,a6
	adda.l	#$1B,a4
	addq.l	#2,a5
	addq.w	#1,d1
	cmp.w	#$1A,d1
	blt.w	.team
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	;Not decoded in the listing and not referenced from it: kept as bytes
	dc.b	$48,$E7,$F1,$A0,$61,$00,$00,$4E,$22,$48,$4C,$DF,$05,$8F,$4E,$75

FormatPlayerNameD7
	movem.l	d0-d3/d7-a0/a2,-(sp)
	bsr.w	getplayernameD7
	move.l	a0,-(sp)
	movea.w	#(TextBuffer-M68K_RAM),a1
	adda.w	(a0),a0
	jsr	(GetJerseyNumber).l
	move.b	(jerseynum+1).w,d0
	jsr	(ConvertByteToDigits).l
	move.b	#$20,(a1)+
	movea.l	(sp)+,a0
	move.w	(a0)+,d0
	lea	-2(a0,d0.w),a2
.skipfirst
	cmpi.b	#$20,(a0)+
	bne.s	.skipfirst
.copy
	move.b	(a0)+,(a1)+
	cmpa.l	a0,a2
	bne.s	.copy
	jsr	(FinalizeTextBuffer).l
	movem.l	(sp)+,d0-d3/d7-a0/a2
	rts

getplayernameD7	;Getplayername for team d7
	movem.l	d0/d7/a2,-(sp)
	bra.w	getnamea0

GetPlayerNamePointer	;a0 = name string of player d0 (roster offset) of team struct a2 (GetRosterName)
	movem.l	d0/d7/a2,-(sp)
	move.w	$28(a2),d7

getnamea0	;Shared tail of getplayername: GetRosterName, a0 = the name
	jsr	(GetRosterName).l
	movea.l	a1,a0
	movem.l	(sp)+,d0/d7/a2
	rts

GetCreatedName
	movem.l	d0-d1/d5-d7/a0,-(sp)
	bra.w	GetRosterNameTail
	;Not decoded in the listing and not referenced from it: kept as bytes
	dc.b	$4E,$75

GetRosterName	;a1 = name String of player d0 of team d7 (season roster aware)
	movem.l	d0-d1/d5-d7/a0,-(sp)
	btst	#4,(sflags11).w
	beq.w	.season
	move.w	d7,d6
	movea.l	#TeamList,a1
	asl.w	#2,d6
	movea.l	(a1,d6.w),a1
	adda.w	(a1),a1
	bra.w	.next
.skip
	adda.w	(a1),a1
	addq.w	#8,a1
.next
	dbf	d0,.skip
	movem.l	(sp)+,d0-d1/d5-d7/a0
	rts
.season
	cmp.w	#$1B,d7
	ble.w	.team
	add.w	d0,d0
	ext.l	d0
	addi.l	#$DB4,d0
	bra.w	.0
.team
	move.w	d7,d6
	mulu.w	#$36,d7
	add.w	d0,d0
	ext.l	d0
	add.l	d7,d0
	addi.l	#$1550,d0
.0
	movea.l	#$FFFFBF7E,a0
	movea.l	#SaveRAM,a1
	add.w	d0,d0
	move.b	1(a1,d0.w),(a0)
	move.b	3(a1,d0.w),1(a0)
	move.w	(a0),d0

GetRosterNameTail
	move.w	d0,-(sp)
	andi.w	#$1F00,d0
	cmp.w	#$1E00,d0
	bne.w	.team
	move.w	(sp)+,d0
	andi.w	#$FF,d0
	asl.w	#5,d0
	ext.l	d0
	addi.l	#$12CE,d0
	moveq	#$20,d1
	movea.l	#$FFFFDD8A,a0
	jsr	(ReadSRAM).l
	movea.l	a0,a1
	bra.w	.done
.team
	move.w	(sp)+,d0
	move.w	d0,d6
	lsr.w	#8,d6
	andi.w	#$1F,d6
	andi.w	#$FF,d0
	movea.l	#TeamList,a1
	asl.w	#2,d6
	movea.l	(a1,d6.w),a1
	adda.w	(a1),a1
	bra.w	.next
.skip
	adda.w	(a1),a1
	addq.w	#8,a1
.next
	dbf	d0,.skip
.done
	movem.l	(sp)+,d0-d1/d5-d7/a0
	rts

GetJerseyNumber	;The jersey number byte of player d0 of team d7
	movem.l	d0-d1/a0-a1,-(sp)
	btst	#4,(sflags11).w
	beq.w	.0
	move.w	d7,-(sp)
	movea.l	#TeamList,a0
	asl.w	#2,d7
	movea.l	(a0,d7.w),a0
	adda.w	(a0),a0
	bra.w	.next
.skip
	adda.w	(a0),a0
	addq.w	#8,a0
.next
	dbf	d0,.skip
	adda.w	(a0),a0
	clr.w	(jerseynum).w
	move.b	(a0),(jerseynum+1).w
	move.w	(sp)+,d7
	bra.w	.2
.0
	cmp.w	#$1C,d7
	beq.w	.1
	move.w	d7,d1
	muls.w	#$1B,d1
	ext.l	d1
	ext.l	d0
	add.l	d1,d0
	addi.l	#$1B00,d0
	add.l	d0,d0
	movea.l	#SaveRAM,a0
	move.w	(a0,d0.w),d0
	andi.w	#$FF,d0
	move.w	d0,(jerseynum).w
	bra.w	.2
.1
	jsr	(GetRosterName).l
	adda.w	(a1),a1
	clr.w	d0
	move.b	(a1),d0
	move.w	d0,(jerseynum).w
.2
	movem.l	(sp)+,d0-d1/a0-a1
	rts
	;Not decoded in the listing: kept as bytes. The trade screen calls into it
	dc.b	$48,$E7,$C0,$00,$30,$07,$72,$36,$C0,$C1,$06,$80,$00,$00,$15,$50
	dc.b	$4E,$B9,$00,$02,$41,$E8,$4C,$DF,$00,$03,$4E,$75,$48,$E7,$C0,$00
	dc.b	$30,$07,$72,$36,$C0,$C1,$06,$80,$00,$00,$15,$50,$4E,$B9,$00,$02
	dc.b	$41,$88,$4E,$B9,$00,$02,$41,$AA,$4C,$DF,$00,$03,$4E,$75,$08,$38
	dc.b	$00,$04,$C3,$54,$66,$00,$00,$28,$48,$E7,$81,$80,$E5,$40,$48,$C0
	dc.b	$20,$7C,$00,$20,$2A,$A0,$CE,$FC,$00,$02,$DE,$87,$DE,$80,$30,$30
	dc.b	$78,$00,$02,$40,$00,$1F,$B0,$7C,$00,$1E,$4C,$DF,$01,$81,$4E,$75

GetPositionSlot	;d0 = the position slot (0 G, 1 LD, 2 RD, 3 LW, 4 C, 5 RW) of player d0 of team d7; season roster aware,
	;created players from their record
	movem.l	d1/d6-d7/a0-a1,-(sp)
	btst	#4,(sflags11).w
	beq.w	.1
	move.w	d7,d6
	movea.l	#TeamList,a1
	asl.w	#2,d6
	movea.l	(a1,d6.w),a1
	adda.w	4(a1),a1	;city
	adda.w	(a1),a1
	adda.w	(a1),a1
	adda.w	(a1),a1	;arena
	adda.w	(a1),a1
	move.w	d0,d1
	asr.w	#1,d0
	move.b	(a1,d0.w),d0
	btst	#0,d1
	bne.w	.0
	lsr.w	#4,d0
.0
	andi.w	#$F,d0
	bra.w	.5
.1
	cmp.w	#$1B,d7
	ble.w	.team
	add.w	d0,d0
	ext.l	d0
	addi.l	#$DB4,d0
	bra.w	.2
.team
	move.w	d7,d6
	mulu.w	#$36,d7
	add.w	d0,d0
	ext.l	d0
	add.l	d7,d0
	addi.l	#$1550,d0
.2
	movea.l	#$FFFFBF7E,a0
	movea.l	#SaveRAM,a1
	add.w	d0,d0
	move.b	1(a1,d0.w),(a0)
	move.b	3(a1,d0.w),1(a0)
	move.w	(a0),d0
	move.w	d0,-(sp)
	andi.w	#$1F00,d0
	cmp.w	#$1E00,d0
	bne.w	.3
	move.w	(sp)+,d0
	andi.w	#$FF,d0
	asl.w	#5,d0
	ext.l	d0
	addi.l	#$12CE,d0
	moveq	#$20,d1
	movea.l	#$FFFFDD8A,a0
	jsr	(ReadSRAM).l
	adda.w	(a0),a0
	addq.w	#8,a0
	move.b	(a0),d0
	ext.w	d0
	bra.w	.5
.3
	move.w	(sp)+,d0
	move.w	d0,d6
	lsr.w	#8,d6
	andi.w	#$1F,d6
	andi.w	#$FF,d0
	movea.l	#TeamList,a1
	asl.w	#2,d6
	movea.l	(a1,d6.w),a1
	adda.w	4(a1),a1	;city
	adda.w	(a1),a1
	adda.w	(a1),a1
	adda.w	(a1),a1	;arena
	adda.w	(a1),a1
	move.w	d0,d6
	lsr.b	#1,d6
	move.b	(a1,d6.w),d6
	btst	#0,d0
	bne.w	.4
	lsr.b	#4,d6
.4
	andi.w	#$F,d6
	clr.w	d0
	move.b	d6,d0
.5
	movem.l	(sp)+,d1/d6-d7/a0-a1
	rts
	;Not decoded in the listing: kept as bytes. ExtractTradedPlayer and InsertTradedPlayer call into it
	dc.b	$48,$E7,$C0,$00,$30,$07,$C0,$FC,$00,$36,$06,$80,$00,$00,$15,$50
	dc.b	$72,$36,$4E,$B9,$00,$02,$41,$E8,$4C,$DF,$00,$03,$4E,$75,$48,$E7
	dc.b	$C0,$00,$30,$07,$C0,$FC,$00,$36,$06,$80,$00,$00,$15,$50,$72,$36
	dc.b	$4E,$B9,$00,$02,$41,$88,$4E,$B9,$00,$02,$41,$AA,$4C,$DF,$00,$03
	dc.b	$4E,$75

GetSeasonRosterId	;(a0) = the season roster id word of player d0 of team d7, from save RAM
	movem.l	d0/d7-a1,-(sp)
	mulu.w	#$36,d7
	add.w	d0,d0
	ext.l	d0
	add.l	d7,d0
	addi.l	#$1550,d0
	movea.l	#SaveRAM,a1
	add.w	d0,d0
	move.b	1(a1,d0.w),(a0)
	move.b	3(a1,d0.w),1(a0)
	movem.l	(sp)+,d0/d7-a1
	rts

SimScore	;Simulate the score of game a0: SimTeamStrength / SimTeamGoals for both teams; a playoff tie gets a random
	;winner
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,(TempLegSpd).w
	clr.w	d0
	move.b	(a0),d0
	movea.l	#$FFFF5208,a5
	movea.l	#$FFFF5244,a4
	bsr.w	SimTeamStrength
	clr.w	d1
	movea.l	(TempLegSpd).w,a0
	move.b	1(a0),d1
	bsr.w	SimTeamGoals
	move.b	d2,2(a0)
	clr.w	d0
	move.b	1(a0),d0
	movea.l	#$FFFF55F0,a5
	movea.l	#$FFFF562C,a4
	bsr.w	SimTeamStrength
	clr.w	d1
	movea.l	(TempLegSpd).w,a0
	move.b	(a0),d1
	bsr.w	SimTeamGoals
	movea.l	(TempLegSpd).w,a0
	move.b	d2,3(a0)
	btst	#7,(GameFlags).w
	beq.w	.0
	btst	#2,(SeasonFlags).w
	beq.w	.0
	move.b	2(a0),d0
	move.b	3(a0),d1
	cmp.b	d0,d1
	bne.w	.0
	btst	#2,(vcount).w
	beq.w	.1
	addq.b	#1,3(a0)
	bra.w	.0
.1
	addq.b	#1,2(a0)
.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SimTeamGoals	;d2 = goals of a team of strength d3 against team d1 (its defense, goalie rating, home / away adjust;
	;SimGoalSteps / SimGoalOdds)
	move.w	d1,(TempMaxSpd).w
	movea.l	#SimTeamDefense,a1
	move.b	(a1,d1.w),d1
	sub.w	d1,d3
	movea.l	#AwShots,a2
	move.w	(TempMaxSpd).w,d4
	move.w	d3,-(sp)
	move.w	d4,$28(a2)
	movea.l	#TeamList,a1
	asl.w	#2,d4
	move.l	(a1,d4.w),(AwShots+tmdata).w
	move.l	(GAttribOverallMask).l,d4
	clr.w	d0
	jsr	(CalcAttrib).l
	muls.w	#$64,d0
	divs.w	d1,d0
	movea.l	#SimRatingPoints,a0
	clr.w	d1
	move.b	(a0,d0.w),d1
	move.w	(sp)+,d3
	sub.w	d1,d3
	movea.l	(TempLegSpd).w,a0
	movea.l	#SimHomeGoalAdj,a1
	move.w	(TempMaxSpd).w,d0
	cmp.b	(a0),d0
	beq.w	.0
	movea.l	#SimAwayGoalAdj,a1
.0
	move.b	(a1,d0.w),d1
	ext.w	d1
	add.w	d1,d3
	bpl.w	.1
	clr.w	d3
.1
	cmp.w	#$64,d3
	ble.w	.2
	move.w	#$64,d3
.2
	movea.l	#SimGoalSteps,a1
	move.w	d3,d0
	clr.w	d3
.3
	cmp.b	(a1,d3.w),d0
	ble.w	.4
	addq.w	#1,d3
	bra.s	.3
.4
	muls.w	#$A,d3
	movea.l	#SimGoalOdds,a1
	adda.l	d3,a1
	move.w	#$64,d0
	jsr	(randomd0).l
	clr.w	d2
.5
	cmp.b	(a1,d2.w),d0
	ble.w	rtsSimTeamGoals
	addq.w	#1,d2
	bra.s	.5

SimGoalSteps	;SimTeamGoals: strength steps (0-100); the index picks the SimGoalOdds row
	dc.b	$09,$13,$18,$1D,$21,$24,$27,$2A,$2D,$30,$33,$36,$39,$3C,$3F,$42
	dc.b	$46,$4B,$50,$5A,$64,$FF

rtsSimTeamGoals	;SimTeamGoals: the goal count is picked
	rts

SimTeamStrength	;d3 = the sim strength of team d0: SimRatingPoints of its best skaters - SimStrengthSub + SimStrengthAdd; a5 /
	;a4 = sorted ratings / players
	movem.l	d0-d2/d4-d7/a0-a6,-(sp)
	move.w	d0,(TempWord1).w
	movea.l	#$202AA0,a6
	move.w	d0,d1
	muls.w	#$6C,d1
	adda.l	d1,a6
	movea.l	#$FFFFC8E2,a0
	move.w	#$6F,d1
.0
	clr.l	(a0)+
	dbf	d1,.0
	movea.l	#tmstruct,a2
	move.w	d0,$28(a2)
	movea.l	#TeamList,a0
	asl.w	#2,d0
	move.l	(a0,d0.w),(tmstruct+tmdata).w
	move.l	(PAttribOverallMask).l,d4
	bsr.w	GetGoalieCount
	move.w	d0,-(sp)
	bsr.w	GetPlayerCount
	sub.w	(sp),d0
	subq.w	#1,d0
	move.w	d0,d2
	move.w	(sp)+,d0
	movem.l	a4-a5,-(sp)
.1
	btst	#6,1(a6)
	bne.w	.2
	movem.l	d0/d2/d4,-(sp)
	movem.l	a4-a6,-(sp)
	jsr	(CalcAttrib).l
	muls.w	#$64,d0
	divs.w	d1,d0
	movem.l	(sp)+,a4-a6
	move.w	d0,(a5)+
	movem.l	(sp)+,d0/d2/d4
	move.b	d0,(a4)
.2
	addq.w	#1,a4
	addq.w	#1,d0
	addq.w	#4,a6
	dbf	d2,.1
	move.b	#$FF,(a4)
	movem.l	(sp)+,a4-a5
	bsr.w	SortBytesByWords
	move.w	#$D,d0
	clr.w	d3
	movea.l	#SimRatingPoints,a2
.3
	move.w	(a5)+,d2
	move.b	(a2,d2.w),d2
	add.w	d2,d3
	dbf	d0,.3
	move.w	(TempWord1).w,d0
	movea.l	#SimStrengthSub,a1
	clr.w	d1
	move.b	(a1,d0.w),d1
	sub.w	d1,d3
	movea.l	#SimStrengthAdd,a1
	clr.w	d1
	move.b	(a1,d0.w),d1
	add.w	d1,d3
	movem.l	(sp)+,d0-d2/d4-d7/a0-a6
	rts

SimRatingPoints	;Overall rating % (0-100) to sim points 1-6 (SimTeamStrength skaters, SimTeamGoals goalie)
	dc.b	$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	dc.b	$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	dc.b	$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	dc.b	$01,$01,$01,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	dc.b	$02,$02,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03
	dc.b	$03,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05
	dc.b	$06,$06,$06,$06,$06

SimStrengthAdd	;Per team: added to the sim strength (SimTeamStrength)
	dc.b	$1B,$2D,$28,$2C,$2B,$23,$32,$1D,$22,$21,$1F,$20,$2A,$1A,$25,$19
	dc.b	$2E,$30,$31,$24,$2F,$1C,$27,$26,$29,$1E

SimStrengthSub	;Per team: taken off the sim strength (SimTeamStrength)
	dc.b	$1D,$26,$28,$26,$26,$21,$26,$1D,$1D,$20,$23,$22,$23,$20,$2A,$1D
	dc.b	$26,$2B,$27,$22,$22,$1F,$25,$25,$23,$22

SimTeamDefense	;Per team, 1-6: taken off the other team's strength (SimTeamGoals) and shots (SimShots)
	dc.b	$02,$05,$06,$05,$06,$04,$06,$01,$05,$03,$01,$02,$06,$02,$04,$01
	dc.b	$05,$02,$04,$02,$04,$03,$03,$03,$06,$01

SimHomeGoalAdj	;Per home team: added to the away team's strength in SimTeamGoals
	dc.b	$01,$02,$02,$02,$01,$01,$03,$01,$01,$02,$00,$02,$02,$01,$01,$00
	dc.b	$03,$03,$03,$01,$03,$01,$02,$01,$02,$01

SimAwayGoalAdj	;Per away team: added to the home team's strength in SimTeamGoals
	dc.b	$FD,$00,$FE,$FF,$00,$FE,$00,$FE,$00,$FE,$FF,$FD,$FF,$FD,$FF,$FD
	dc.b	$00,$00,$00,$FF,$00,$FE,$FD,$FE,$FE,$FD

SimGoalOdds	;SimTeamGoals: rows of cumulative % for 0-9 goals, one row per SimGoalSteps step
	dc.b	$0A,$19,$2E,$43,$52,$5C,$62,$64,$64,$64,$0A,$18,$2C,$40,$4E,$59
	dc.b	$61,$64,$64,$64,$09,$17,$2A,$3D,$4B,$56,$60,$64,$64,$64,$09,$16
	dc.b	$28,$3B,$49,$55,$60,$64,$64,$64,$08,$14,$25,$38,$46,$53,$5F,$64
	dc.b	$64,$64,$07,$12,$1E,$31,$45,$52,$5E,$63,$64,$64,$07,$11,$1C,$2F
	dc.b	$43,$50,$5C,$63,$64,$64,$06,$0F,$1A,$2D,$41,$4E,$5A,$62,$64,$64
	dc.b	$06,$0F,$1A,$2C,$3E,$4C,$59,$62,$64,$64,$05,$0D,$17,$29,$3B,$49
	dc.b	$57,$61,$64,$64,$05,$0C,$15,$23,$35,$48,$57,$61,$64,$64,$04,$0A
	dc.b	$12,$20,$32,$45,$54,$60,$64,$64,$04,$0A,$12,$1E,$30,$43,$52,$5F
	dc.b	$64,$64,$03,$08,$0F,$1B,$2D,$40,$4F,$5D,$63,$64,$03,$08,$0F,$1B
	dc.b	$2C,$3D,$4C,$5B,$62,$64,$02,$06,$0D,$19,$2A,$3B,$4A,$59,$61,$64
	dc.b	$02,$05,$0B,$15,$23,$36,$49,$58,$60,$64,$01,$03,$09,$13,$21,$3E
	dc.b	$47,$56,$5F,$64,$01,$03,$09,$12,$1F,$32,$45,$54,$5E,$64,$00,$01
	dc.b	$06,$0F,$1C,$2F,$42,$52,$5D,$64,$00,$00,$04,$0C,$19,$2C,$3F,$50
	dc.b	$5C,$64,$FF

