;	The season: the save RAM stats, injuries, standings and game log (96 keeps them as bit fields,
;	ReadSRAMBits / WriteSRAMBits), the day's games and the simulated days, the team select
;	screen and the season menu.

SortBytesByWords					;Sort a5 words descending and swap the parallel a4 bytes. Stops at a
									;negative byte
	movem.l	a4-a5,-(sp)
.0
	clr.w	d2
	movem.l	a4-a5,-(sp)
.1
	tst.b	1(a4)
	bmi.w	.3
	move.w	(a5)+,d0
	move.w	(a5),d1
	cmp.w	d0,d1
	ble.w	.2
	st	d2
	move.w	d0,(a5)
	move.w	d1,-2(a5)
	move.b	(a4),d0
	move.b	1(a4),(a4)
	move.b	d0,1(a4)
.2
	addq.w	#1,a4
	bra.s	.1
.3
	movem.l	(sp)+,a4-a5
	tst.w	d2
	bne.s	.0
	movem.l	(sp)+,a4-a5
	rts

SaveGameStats						;Season game over: add both teams' game stats to the save RAM totals
									;(AddTeamGameStats), then TickTeamInjuries
	movem.l	d0-d7/a0-a6,-(sp)
	bset	#6,(GameFlags).w
	movea.l	#tmstruct,a1
	bsr.w	AddTeamGameStats
	movea.l	#AwShots,a1
	bsr.w	AddTeamGameStats
	move.w	(tmstruct+$28).w,d0
	move.w	(AwShots+$28).w,d1
	jsr	(TickTeamInjuries).l
	bclr	#6,(GameFlags).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

AddTeamGameStats					;Add the game stats of team struct a1 (player arrays, ice time) to its
									;season or playoff totals in save RAM
									;(AddSavedStats)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	tmteam(a1),d7
	moveq	#$C,d2
	move.w	#$18,d3
	move.l	#$120,d4
	move.l	#$268,d1
	btst	#2,(SeasonFlags).w
	beq.w	.0
	moveq	#$A,d2
	move.w	#$18,d3
	move.l	#$F0,d4
	move.l	#$448,d1
.0
	movea.l	a1,a0
	adda.w	#$C0,a0
	jsr	(GetGoalieCountD7).l
	adda.w	d0,a0
	bsr.w	AddSavedStats
	moveq	#$E,d2
	jsr	(GetGoalieCountD7).l
	move.w	d0,d3
	moveq	#$2A,d4
	move.l	#$598C,d1
	btst	#2,(SeasonFlags).w
	beq.w	.1
	moveq	#$2A,d4
	move.l	#$3268,d1
.1
	movea.l	a1,a0
	adda.w	#$C0,a0
	bsr.w	AddSavedStats
	moveq	#$C,d2
	move.w	#$18,d3
	move.l	#$120,d4
	move.l	#$1FA8,d1
	btst	#2,(SeasonFlags).w
	beq.w	.2
	moveq	#$A,d2
	move.w	#$18,d3
	move.l	#$F0,d4
	move.l	#$1348,d1
.2
	movea.l	a1,a0
	adda.w	#$DC,a0
	jsr	(GetGoalieCountD7).l
	adda.w	d0,a0
	bsr.w	AddSavedStats
	moveq	#$E,d2
	jsr	(GetGoalieCountD7).l
	move.w	d0,d3
	move.w	#$2A,d4
	move.l	#$5548,d1
	btst	#2,(SeasonFlags).w
	beq.w	.3
	move.w	#$2A,d4
	move.l	#$2FC8,d1
.3
	movea.l	a1,a0
	adda.w	#$F8,a0
	bsr.w	AddSavedStats
	moveq	#$A,d2
	move.w	#$18,d3
	move.w	#$F0,d4
	move.l	#$3CE8,d1
	btst	#2,(SeasonFlags).w
	beq.w	.4
	moveq	#9,d2
	move.w	#$18,d3
	move.w	#$D8,d4
	move.l	#$2248,d1
.4
	movea.l	a1,a0
	adda.w	#$114,a0
	jsr	(GetGoalieCountD7).l
	adda.w	d0,a0
	bsr.w	AddSavedStats
	moveq	#$D,d2
	jsr	(GetGoalieCountD7).l
	move.w	d0,d3
	move.w	#$27,d4
	move.l	#$5DD0,d1
	btst	#2,(SeasonFlags).w
	beq.w	.5
	move.w	#$27,d4
	move.l	#$3508,d1
.5
	movea.l	a1,a0
	adda.w	#$14C,a0
	bset	#3,(sflags11).w
	bsr.w	AddSavedStats
	bclr	#3,(sflags11).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

AddSavedStats						;Add d3+1 values from a0 to the d2-bit save RAM fields at bit d1 + team d7
									;* d4 (sflags11 bit 3: word seconds,
									;as minutes)
	movem.l	d0-d1/d4/d7-a0,-(sp)
	btst	#2,(SeasonFlags).w
	beq.w	.0
	bsr.w	GetTeamPOSlot
.0
	mulu.w	d7,d4
	add.l	d4,d1
	bra.w	.5
.1
	jsr	(ReadSRAMBits).l
	btst	#3,(sflags11).w
	beq.w	.2
	move.w	(a0)+,d4
	bra.w	.3
.2
	move.b	(a0)+,d4
	ext.w	d4
.3
	btst	#3,(sflags11).w
	beq.w	.4
	ext.l	d4
	divu.w	#$3C,d4
	cmpi.w	#2,(Optperlen).w
	beq.w	.4
	asl.w	#1,d4
	cmpi.w	#1,(Optperlen).w
	beq.w	.4
	asl.w	#1,d4
.4
	add.l	d4,d0
	jsr	(WriteSRAMBits).l
	add.l	d2,d1
.5
	dbf	d3,.1
	movem.l	(sp)+,d0-d1/d4/d7-a0
	rts

ReadSRAMBitWords					;Read d3+1 d2-bit save RAM fields from bit d1 + d7 * d4 into words at a0
	movem.l	d0-d1/d3-d4/a0,-(sp)
	mulu.w	d7,d4
	add.l	d4,d1
	bra.w	.1
.0
	jsr	(ReadSRAMBits).l
	move.w	d0,(a0)+
	add.l	d2,d1
.1
	dbf	d3,.0
	movem.l	(sp)+,d0-d1/d3-d4/a0
	rts

WriteSRAMBitWords					;Write d3+1 words from a0 to the d2-bit save RAM fields from bit d1 + d7 *
									;d4
	movem.l	d0-d1/d3-d4/a0,-(sp)
	mulu.w	d7,d4
	add.l	d4,d1
	bra.w	.1
.0
	move.w	(a0)+,d0
	ext.l	d0
	jsr	(WriteSRAMBits).l
	add.l	d2,d1
.1
	dbf	d3,.0
	movem.l	(sp)+,d0-d1/d3-d4/a0
	rts

TickTeamInjuries					;A game played: one injury game off every injured player of teams d0 and
									;d1 (save RAM bits), then the checksum
	movem.l	d0-d4/a0,-(sp)
	move.l	d1,-(sp)
	move.w	#$1A,d4
	move.l	#$EDF0,d1
	mulu.w	#$51,d0
	add.l	d0,d1
	move.w	#3,d2
.0
	jsr	(ReadSRAMBits).l
	tst.w	d0
	beq.w	.1
	subq.w	#1,d0
	jsr	(WriteSRAMBits).l
.1
	addq.l	#3,d1
	dbf	d4,.0
	move.l	(sp)+,d0
	move.w	#$1A,d4
	move.l	#$EDF0,d1
	mulu.w	#$51,d0
	add.l	d0,d1
	move.w	#3,d2
.2
	jsr	(ReadSRAMBits).l
	tst.w	d0
	beq.w	.3
	subq.w	#1,d0
	jsr	(WriteSRAMBits).l
.3
	addq.l	#3,d1
	dbf	d4,.2
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d4/a0
	rts

StartNewSeason						;New season (sflags10 bit 6): reset the season header (day 0, default
									;options), write it and clear the season
									;save data
	btst	#7,(GameFlags).w
	beq.w	.0
	bclr	#6,(sflags10).w
	beq.w	.0
	bset	#6,(GameFlags).w
	clr.w	(SeasonDay).w
	clr.b	(SeasonTeam+1).w
	clr.b	(SeasonFlags).w
	bclr	#1,(sflags13).w
	move.b	#0,(SeasonDay+3).w
	move.b	#1,(SeasonPen).w
	move.b	#0,(SeasonPen+1).w
	move.b	#0,(SeasonDay+8).w
	move.b	#1,(SeasonDay+8+1).w
	move.b	#0,(SeasonDay+$A).w
	move.b	#0,(SeasonDay+$B).w
	jsr	(WriteSeasonHeader).l
	jsr	(ClearSeasonData).l
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
.0
	rts

SimSeasonDays						;Simulate simdays days: every unplayed game of each day, save the results
									;(WriteDayGames), step the day or
									;end the season
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(Optperlen).w,-(sp)
	move.w	#2,(Optperlen).w
	bset	#6,(GameFlags).w
	move.w	(simdays).w,d7
	bra.w	.12
.0
	bsr.w	BuildSeasonTeamList
	movea.l	#$FFFFDCFA,a2
	clr.w	d6
	move.b	(DayGameCount).w,d6
	bra.w	.6
.1
	move.b	(SeasonTeam).w,d0
	cmp.b	(a2),d0
	beq.w	.2
	cmp.b	1(a2),d0
	bne.w	.3
.2
	bsr.w	UserGamePlayed
	bne.w	.5
.3
	movem.l	d3/a3,-(sp)
	lea	2(a2),a3
	suba.l	a2,a3
	move.l	a3,d3
	divu.w	#5,d3
	mulu.w	#$10,d3
	movea.l	#$FFFFCF44,a3
	adda.l	d3,a3
	cmpi.w	#4,4(a3)
	beq.w	.4
	cmpi.w	#4,6(a3)
.4
	movem.l	(sp)+,d3/a3
	beq.w	.5
	movea.l	a2,a0
	bsr.w	SimScore
	bsr.w	SimGameStats
.5
	addq.w	#5,a2
.6
	dbf	d6,.1
	bset	#6,(GameFlags).w
	bsr.w	WriteDayGames
	btst	#2,(SeasonFlags).w
	beq.w	.9
	jsr	(ResolveDayGames).l
	btst	#1,(SeasonFlags).w
	bne.w	.10
	jsr	(GetShifter).l
	movea.l	#$FFFFCF44,a0
	clr.w	d0
	move.b	(SeasonTeam).w,d0
.7
	cmp.w	(a0),d0
	beq.w	.8
	cmp.w	2(a0),d0
	beq.w	.8
	adda.w	#$10,a0
	dbf	d1,.7
	bra.w	.10
.8
	cmpi.w	#4,4(a0)
	beq.w	.10
	cmpi.w	#4,6(a0)
	beq.w	.10
	addq.w	#1,(SeasonDay).w
	bra.w	.10
.9
	cmpi.w	#$BE,(SeasonDay).l
	blt.w	.11
	bset	#0,(SeasonFlags).w
	bclr	#1,(SeasonFlags).w
	bclr	#2,(SeasonFlags).w
.10
	bsr.w	WriteSeasonHeader
	bra.w	.13
.11
	addq.w	#1,(SeasonDay).w
	bsr.w	WriteSeasonHeader
.12
	dbf	d7,.0
.13
	clr.w	(simdays).w
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	move.w	(sp)+,(Optperlen).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

BuildSeasonTeamList					;Build the day's game list (day, count, 5 bytes a game) from
									;SeasonSchedule; in the playoffs the round's series
									;from gsstruct
	move.w	(SeasonDay).w,d1
	clr.w	d2
	movea.l	#$FFFFDCF8,a2
	btst	#2,(SeasonFlags).w
	beq.w	.0
	bra.w	.5
.0
	movem.l	d0-d7/a0-a6,-(sp)
	move.b	d1,(a2)+
	movea.l	#SeasonSchedule,a0
	clr.w	d5
	move.b	(a0)+,d5
	add.w	d2,d1
	cmp.w	d5,d1
	blt.w	.1
	sub.w	d5,d1
.1
	bra.w	.2
.skipday
	clr.l	d3
	move.b	(a0)+,d3
	move.w	d3,d4
	add.w	d4,d4
	adda.w	d4,a0
.2
	dbf	d1,.skipday
	clr.w	d1
	move.b	(a0)+,d1
	move.b	d1,(a2)+
	bra.w	.4
.3
	move.b	(a0)+,(a2)
	move.b	(a0)+,1(a2)
	addq.w	#5,a2
.4
	dbf	d1,.3
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.5
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#3,d2
	sub.w	(gamelevel).w,d2
	move.w	#1,d0
	asl.w	d2,d0
	move.b	d0,1(a2)
	addq.w	#2,a2
	movea.l	#$FFFFCF44,a0
	cmpi.w	#3,(gamelevel).w
	bne.w	.7
	cmpi.w	#4,4(a0)
	beq.w	.8
	cmpi.w	#4,6(a0)
	beq.w	.8
	bra.w	.7
.6
	move.b	1(a0),(a2)
	move.b	3(a0),1(a2)
	addq.w	#5,a2
	adda.w	#$10,a0
.7
	dbf	d0,.6
.8
	movem.l	(sp)+,d0-d7/a0-a6
	rts

WriteDayGames						;Save the results of the day's games: the user game log (SaveUserGame) and
									;the standings (RecordGameResult);
									;playoffs: scores into gsstruct
	clr.w	d2
	movea.l	#$FFFFDCF8,a2
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d1
	move.b	(a2)+,d1
	btst	#0,(SeasonFlags).w
	beq.w	.2
	clr.w	d1
	clr.w	d0
	move.b	(a2),d0
	move.l	a2,-(sp)
	addq.w	#1,a2
	movea.l	#$FFFFCF44,a0
	bra.w	.1
.0
	move.b	2(a2),$B(a0)
	move.b	3(a2),$D(a0)
	addq.w	#5,a2
	adda.w	#$10,a0
.1
	dbf	d0,.0
	movea.l	(sp)+,a2
	bra.w	.4
.2
	movea.l	#SeasonSchedule,a0
	clr.w	d5
	move.b	(a0)+,d5
	add.w	d2,d1
	cmp.w	d5,d1
	blt.w	.4
	sub.w	d5,d1
.4
	bra.w	.3
.skipday
	clr.l	d3
	move.b	(a0)+,d3
	move.w	d3,d4
	add.w	d4,d4
	adda.w	d4,a0
.3
	dbf	d1,.skipday
	clr.w	d1
	move.b	(a2)+,d1
	bra.w	.5
.6
	move.b	(SeasonTeam).w,d0
	cmp.b	(a2),d0
	beq.w	.7
	cmp.b	1(a2),d0
	bne.w	.8
.7
	bsr.w	UserGamePlayed
	bne.w	.8
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	SaveUserGame
	movem.l	(sp)+,d0-d7/a0-a6
.8
	bsr.w	RecordGameResult
	addq.w	#5,a2
.5
	dbf	d1,.6
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SaveUserGame						;Game a2 of the user team: add it to the save RAM game log (scores,
									;opponent), mark the day played, count it
	movem.l	d0-d2,-(sp)
	move.b	(SeasonTeam).w,d0
	cmp.b	(a2),d0
	beq.w	.0
	cmp.b	1(a2),d0
	bne.w	.5
.0
	bsr.w	ReadUserGameCount
	move.l	d0,d1
	move.l	d1,-(sp)
	clr.l	d0
	move.b	2(a2),d0
	asl.w	#3,d1
	andi.l	#$FFFF,d1
	addi.l	#$65F8,d1
	move.w	#8,d2
	jsr	(WriteSRAMBits).l
	addi.l	#$2A0,d1
	move.b	3(a2),d0
	jsr	(WriteSRAMBits).l
	btst	#2,(SeasonFlags).w
	beq.w	.3
	addi.l	#-$2EF8,d1
	move.w	#8,d2
	move.b	(a2),d0
	cmp.b	(SeasonTeam).w,d0
	beq.w	.1
	ori.b	#$80,d0
	bra.w	.2
.1
	move.b	1(a2),d0
.2
	jsr	(WriteSRAMBits).l
.3
	move.l	(sp),d1
	mulu.w	#2,d1
	addi.l	#$6B38,d1
	move.w	#2,d2
	clr.l	d0
	btst	#7,(sflags10).w
	beq.w	.4
	bset	#0,d0
.4
	bset	#1,d0
	jsr	(WriteSRAMBits).l
	move.w	(SeasonDay).w,d1
	mulu.w	#1,d1
	addi.l	#$6BE0,d1
	move.w	#1,d2
	moveq	#1,d0
	jsr	(WriteSRAMBits).l
	move.l	(sp)+,d1
	addq.l	#1,d1
	move.l	d1,d0
	move.l	#$240,d1
	move.w	#8,d2
	jsr	(WriteSRAMBits).l
	jsr	(MakeSRAMChecksum).l
	jsr	(ReadSeasonHeader).l
.5
	movem.l	(sp)+,d0-d2
	rts

UserGamePlayed						;ne when the user team's game of SeasonDay is already played (its save RAM
									;day bit)
	movem.l	d0-d2,-(sp)
	move.w	(SeasonDay).w,d1
	mulu.w	#1,d1
	addi.l	#$6BE0,d1
	move.w	#1,d2
	jsr	(ReadSRAMBits).l
	btst	#0,d0
	movem.l	(sp)+,d0-d2
	rts

ReadUserGameCount					;d0 = the number of user team games in the save RAM game log (a season
									;header byte)
	movem.l	d1-d2,-(sp)
	move.l	#$240,d1
	move.w	#8,d2
	jsr	(ReadSRAMBits).l
	movem.l	(sp)+,d1-d2
	rts

RecordGameResult					;Not in the playoffs: RecordTeamResult for the home and the away team of
									;game a2
	btst	#2,(SeasonFlags).w
	bne.w	.0
	movem.l	d0-d3,-(sp)
	clr.w	d1
	move.b	(a2),d1
	move.b	2(a2),d2
	move.b	3(a2),d3
	bsr.w	RecordTeamResult
	clr.w	d1
	move.b	1(a2),d1
	move.b	3(a2),d2
	move.b	2(a2),d3
	bsr.w	RecordTeamResult
	movem.l	(sp)+,d0-d3
.0
	rts

RecordTeamResult					;Add a win, tie or loss (own goals d2, opponent d3) to team d1's standings
									;count in save RAM
	cmp.b	d2,d3
	blt.w	.1
	beq.w	.2
	mulu.w	#7,d1
	addi.l	#$6486,d1
	move.w	#7,d2
.0
	jsr	(ReadSRAMBits).l
	addq.l	#1,d0
	jmp	WriteSRAMBits
.1
	mulu.w	#7,d1
	addi.l	#$63D0,d1
	move.w	#7,d2
	bra.s	.0
.2
	mulu.w	#7,d1
	addi.l	#$653C,d1
	move.w	#7,d2
	bra.s	.0

WriteSeasonHeader					;Write the season header (SeasonDay ...) to save RAM and update the
									;checksum
	movem.l	d0-d1/a0,-(sp)
	movea.l	#$FFFFDD7E,a0
	moveq	#$C,d1
	moveq	#$41,d0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d1/a0
	rts

ReadSeasonHeader					;Read the season header (SeasonDay ...) from save RAM
	movem.l	d0-d1/a0,-(sp)
	movea.l	#$FFFFDD7E,a0
	moveq	#$C,d1
	moveq	#$41,d0
	jsr	(ReadSRAM).l
	movem.l	(sp)+,d0-d1/a0
	rts
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	SeasonHeaderToOptions
	jsr	(FlipUserRec).l
	jsr	(SetLineOption).l
	jsr	(SetPenOption).l
	jsr	(SetSkillLevel).l
	jsr	(SetGoalieModes).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts
SeasonHeaderToOptions				;Copy the option bytes of the season header (SeasonDay, SeasonPen,
									;SeasonTeam ...) into the Opt* words
	move.b	(SeasonDay+3).w,(Optperlen+1).w
	move.b	(SeasonPen).w,(OptPen+1).w
	move.b	(SeasonPen+1).w,(OptLine+1).w
	move.b	(SeasonTeam+2).w,(OptFighting+1).w
	move.b	(SeasonTeam+3).w,(OptSkill+1).w
	move.b	(SeasonTeam+4).w,(OptGoalie+1).w
	move.b	(SeasonTeam+5).w,(OptUserRec+1).w
	rts

FindUserGame						;a2 = the user team's game in today's game list, or 0
	movem.l	d0-d2/a0,-(sp)
	movea.l	#0,a2
	movea.l	#$FFFFDCFA,a0
	clr.w	d0
	move.b	(DayGameCount).w,d0
	bra.w	.1
.0
	move.b	(a0),d2
	cmp.b	(SeasonTeam).w,d2
	beq.w	.2
	move.b	1(a0),d2
	cmp.b	(SeasonTeam).w,d2
	beq.w	.2
	addq.w	#5,a0
.1
	dbf	d0,.0
	bra.w	.3
.2
	movea.l	a0,a2
.3
	movem.l	(sp)+,d0-d2/a0
	rts

ClearSeasonData						;New season: clear the season stats, standings, game log and injuries in
									;save RAM
	movem.l	d0-d1,-(sp)
	moveq	#$4D,d0
	move.l	#$D67,d1
	jsr	(ClearSRAMBytes).l
	move.l	#$1DBE,d0
	move.l	#$108,d1
	jsr	(ClearSRAMBytes).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d1
	rts

ClearRosterSave						;Reset Rosters: clear player stats ($4D/$BEC, or playoff $89/$666),
									;the 9 bytes at $DDD, injuries, and the free-agent stats
	movem.l	d0-d1,-(sp)
	jsr	(ReadSeasonHeader).l
	moveq	#$4D,d0
	move.l	#$BEC,d1
	btst	#2,(SeasonFlags).w
	beq.w	.0
	move.l	#$89,d0
	move.l	#$666,d1
.0
	jsr	(ClearSRAMBytes).l
	move.l	#$DDD,d0
	moveq	#9,d1
	jsr	(ClearSRAMBytes).l
	move.l	#$1DBE,d0
	move.l	#$108,d1
	jsr	(ClearSRAMBytes).l
	move.l	#$DE6,d0
	moveq	#$78,d1
	jsr	(ClearSRAMBytes).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d1
	rts

LoadSeasonOptions					;Take the game options from the season header (period length, penalties,
									;line changes); OptPlayMode 1 in the
									;playoffs
	clr.w	(Optperlen).w
	move.b	(SeasonDay+3).w,(Optperlen+1).w
	clr.w	(OptPen).w
	move.b	(SeasonPen).w,(OptPen+1).w
	clr.w	(OptLine).w
	move.b	(SeasonPen+1).w,(OptLine+1).w
	clr.w	(OptPlayMode).w
	btst	#2,(SeasonFlags).w
	beq.w	.0
	move.w	#1,(OptPlayMode).w
.0
	rts

ReadStandings						;Read the wins, ties and losses of every team (3 bytes a team) from save
									;RAM into a0
	movem.l	d0-d7/a0,-(sp)
	move.l	#$63D0,d3
	move.l	#$653C,d4
	move.l	#$6486,d5
	moveq	#7,d2
	move.w	#$19,d7
.0
	move.l	d3,d1
	jsr	(ReadSRAMBits).l
	move.b	d0,(a0)+
	addq.l	#7,d3
	move.l	d4,d1
	jsr	(ReadSRAMBits).l
	move.b	d0,(a0)+
	addq.l	#7,d4
	move.l	d5,d1
	jsr	(ReadSRAMBits).l
	move.b	d0,(a0)+
	addq.l	#7,d5
	dbf	d7,.0
	movem.l	(sp)+,d0-d7/a0
	rts
	movem.l	d0/a0,-(sp)
	clr.w	d0
	movea.l	#potree,a0
.loop
	cmp.b	(a0)+,d7
	beq.w	.1
	addq.w	#1,d0
	bra.s	.loop
.1
	move.w	d0,d7
	movem.l	(sp)+,d0/a0
	rts
	movem.l	a0,-(sp)
	clr.w	d0
	movea.l	#potree,a0
	move.b	(a0,d7.w),d7
	movem.l	(sp)+,a0
	rts

SetupSeasonGame						;Set up the user's season game a2: the season options (LoadSeasonOptions)
									;and the home and visiting teams
	jsr	(LoadSeasonOptions).l
	move.b	(a2),(Opt1team+1).w
	move.w	(Opt1team).w,(HomeTeam).w
	move.b	1(a2),(Opt2team+1).w
	move.w	(Opt2team).w,(VisTeam).w
	rts
SetupSeasonGameLookup	equ	*			;Look up the day in the schedule table to find the game
	movem.l	d0-d7/a0/a2-a6,-(sp)
	move.w	(SeasonDay).w,d0
	clr.w	d1
	movea.l	#$1180C,a0
	clr.w	d2
.loop
	move.b	(a0,d1.w),d2
	cmp.w	d2,d0
	ble.w	.1
	addq.w	#1,d1
	sub.w	d2,d0
	subq.w	#1,d0
	bra.s	.loop
.1
	movea.l	#$1179C,a1
	bra.w	.2
.loop2
	adda.w	(a1),a1
.2
	dbf	d1,.loop2
	move.w	d0,-(sp)
	movea.l	#TempLegSpd+2,a3
	move.w	(a1),d0
	subq.w	#1,d0
.loop3
	move.b	(a1)+,(a3)+
	dbf	d0,.loop3
	move.w	(sp)+,d0
	addq.w	#1,d0
	cmp.w	#9,d0
	ble.w	.3
	move.w	#3,d1
	bra.w	.4
.3
	move.w	#2,d1
.4
	move.w	d0,-(sp)
	jsr	(PushNumberWidth).l
	movea.l	#TempLegSpd+2,a3
	jsr	(appstring).l
	movea.l	#$1178C,a1
	move.w	(sp)+,d0
	ext.l	d0
	cmp.w	#$A,d0
	blt.w	.5
	cmp.w	#$15,d0
	blt.w	.8
.5
	divs.w	#$A,d0
	swap	d0
	cmp.w	#1,d0
	bne.w	.6
	movea.l	#$11790,a1
	bra.w	.8
.6
	cmp.w	#2,d0
	bne.w	.7
	movea.l	#$11794,a1
	bra.w	.8
.7
	cmp.w	#3,d0
	bne.w	.8
	movea.l	#$11798,a1
.8
	jsr	(appstring).l
	movea.l	a3,a1
	movem.l	(sp)+,d0-d7/a0/a2-a6
	rts
	dc.w	$0004,$5448,$0004,$5354,$0004,$4E44,$0004,$5244
	dc.w	$000A,$4F43,$544F,$4245,$5200,$000A,$4E4F,$5645
	dc.w	$4D42,$4552,$000A,$4445,$4345,$4D42,$4552,$000A
	dc.w	$4A41,$4E55,$4152,$5900,$000A,$4645,$4252,$5541
	dc.w	$5259,$0008,$4D41,$5243,$4800,$0008,$4150,$5249
	dc.w	$4C00,$48E7,$3F80,$4240,$1038,$DD7E,$5840,$4241
	dc.w	$207C,$0001,$180C,$4242,$1430,$1000,$B042,$6F00
	dc.w	$000A,$5241,$9042,$5340,$60EE,$4CDF,$01FC,$4E75
	dc.w	$1E1D,$1E1E,$1B1E,$1DFF

TeamSelectScreen					;Team select: up / down change the team, left / right pick home or
									;visitors, with the team ranks; in a season
									;only for a new season (the user team)
	clr.w	(carddelay).w
	bsr.w	TeamSelectSide
	btst	#7,(GameFlags).w
	beq.w	.0
	btst	#6,(sflags10).w
	beq.w	.exit
.0
	btst	#7,(GameFlags).w
	bne.w	.2
	move.w	#2,-(sp)
	jsr	(song).l
.2
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#7,(GameFlags).w
	beq.w	.4
	move.b	#0,(SeasonTeam).w
	bra.w	.10
.4
	tst.w	(demoflag).w
	bne.w	.7
	move.w	#$19,d0
	jsr	(randomd0).l
	move.w	d0,(Opt1team).w
	move.w	#$19,d0
	jsr	(randomd0).l
	cmp.w	(Opt1team).w,d0
	bne.w	.5
	addq.w	#1,d0
	cmp.w	#$1A,d0
	blt.w	.5
	clr.w	d0
.5
	move.w	d0,(Opt2team).w
.7
	cmpi.w	#1,(OptPlayMode).w
	beq.w	.10
	move.w	(Opt1team).w,(HomeTeam).w
	move.w	(Opt2team).w,(VisTeam).w
	cmpi.w	#2,(OptPlayMode).w
	beq.w	.8
	cmpi.w	#3,(OptPlayMode).w
	bne.w	.10
.8
	jsr	(NewPO).l
.10
	bsr.w	TeamSelectGfx
	movea.l	#SelectTeamSeasonSprites,a0
	btst	#7,(GameFlags).w
	bne.w	.11
	movea.l	#SelectTeamSprites,a0
.11
	bsr.w	DrawScreenSprite
	move.w	#$18,(palcount).w
	bclr	#dfng,(disflags).w
	btst	#7,(GameFlags).w
	bne.w	.9
	bsr.w	PrintHomeRanks
	bsr.w	PrintVisRanks
	bra.w	.12
.9
	bsr.w	PrintUserRanks
.12
	bset	#0,(TeamSelectRedraw).l
	bclr	#1,(TeamSelectRedraw).l
	bclr	#2,(TeamSelectRedraw).l
	move.w	#1,(TeamSelectHome).l
.frame
	move.w	(Vcount).w,d0
.loop2
	cmp.w	(Vcount).w,d0
	beq.s	.loop2
	jsr	(SetMenuScroll).l
	tst.w	(demoflag).w
	bne.w	.13
	addq.w	#1,(carddelay).w
.13
	cmpi.w	#$2A30,(carddelay).w
	blt.w	.14
	clr.w	(demoflag).w
	bra.w	.33
.14
	bclr	#0,(TeamSelectRedraw).l
	beq.w	.1
	btst	#7,(GameFlags).w
	bne.w	.17
	bsr.w	RedrawTeamRanks
	bclr	#1,(TeamSelectRedraw).l
	bne.w	.15
	bra.w	.16
.15
	bsr.w	DrawHomeLogo
	bsr.w	PrintHomeRanks
.16
	bclr	#2,(TeamSelectRedraw).l
	beq.w	.1
	bsr.w	DrawVisLogo
	bsr.w	PrintVisRanks
	bra.w	.1
.17
	bsr.w	DrawUserLogo
	bsr.w	PrintUserRanks
.1
	jsr	(FindHeldMenuPad).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.18
	clr.w	(carddelay).w
.18
	btst	#7,d1
	bne.w	.33
	btst	#7,(GameFlags).w
	bne.w	.20
	cmpi.w	#1,(OptPlayMode).w
	beq.w	.frame
	btst	#2,d1
	beq.w	.3
	opt	osq-						;keep the subi (SNASM would make it subq)
	subi.w	#1,(TeamSelectHome).l
	opt	osq+
	bpl.w	.19
	clr.w	(TeamSelectHome).l
	bra.w	.frame
.19
	jsr	(RedrawTeamRanks).l
	move	#$2500,sr
	bra.w	.frame
.3
	btst	#3,d1
	beq.w	.20
	tst.w	(TeamSelectHome).l
	bne.w	.frame
	move.w	#1,(TeamSelectHome).l
	jsr	(RedrawTeamRanks).l
	move	#$2500,sr
	bra.w	.frame
.20
	btst	#0,d1
	beq.w	.27
	cmpi.w	#3,(OptPlayMode).w
	beq.w	.21
	cmpi.w	#2,(OptPlayMode).w
	bne.w	.23
.21
	subq.w	#1,(Opt1team).w
	bpl.w	.22
	move.w	#$19,(Opt1team).w
.22
	jsr	(NewPO).l
	bset	#1,(TeamSelectRedraw).l
	bset	#2,(TeamSelectRedraw).l
	bra.w	.26
.23
	btst	#7,(GameFlags).w
	bne.w	.25
	tst.w	(TeamSelectHome).l
	bne.w	.24
	bset	#2,(TeamSelectRedraw).l
	subq.w	#1,(VisTeam).w
	bpl.w	.26
	move.w	#$19,(VisTeam).w
	bra.w	.26
.24
	bset	#1,(TeamSelectRedraw).l
	subq.w	#1,(HomeTeam).w
	bpl.w	.26
	move.w	#$19,(HomeTeam).w
	bra.w	.26
.25
	subq.b	#1,(SeasonTeam).w
	bpl.w	.26
	move.b	#$19,(SeasonTeam).w
.26
	bset	#0,(TeamSelectRedraw).l
	bra.w	.frame
.27
	btst	#1,d1
	beq.w	.frame
	cmpi.w	#3,(OptPlayMode).w
	beq.w	.28
	cmpi.w	#2,(OptPlayMode).w
	bne.w	.6
.28
	addq.w	#1,(Opt1team).w
	cmpi.w	#$1A,(Opt1team).w
	blt.w	.29
	clr.w	(Opt1team).w
.29
	bset	#1,(TeamSelectRedraw).l
	bset	#2,(TeamSelectRedraw).l
	jsr	(NewPO).l
	bra.w	.32
.6
	btst	#7,(GameFlags).w
	bne.w	.31
	tst.w	(TeamSelectHome).l
	bne.w	.30
	bset	#2,(TeamSelectRedraw).l
	addq.w	#1,(VisTeam).w
	cmpi.w	#$1A,(VisTeam).w
	blt.w	.32
	clr.w	(VisTeam).w
	bra.w	.32
.30
	bset	#1,(TeamSelectRedraw).l
	addq.w	#1,(HomeTeam).w
	cmpi.w	#$1A,(HomeTeam).w
	blt.w	.32
	clr.w	(HomeTeam).w
	bra.w	.32
.31
	addq.b	#1,(SeasonTeam).w
	cmpi.b	#$1A,(SeasonTeam).w
	blt.w	.32
	clr.b	(SeasonTeam).w
.32
	bset	#0,(TeamSelectRedraw).l
	bra.w	.frame
.33
	movea.l	#tmstruct,a0
	jsr	(Create_HotCold_Table).l
	movea.l	#AwShots,a0
	jsr	(Create_HotCold_Table).l
	btst	#0,(gmode2).w
	beq.w	.34
	move.w	(shootoutteam).w,-(sp)
	clr.w	(shootoutteam).w
	jsr	(InitShooters).l
	move.w	#1,(shootoutteam).w
	jsr	(InitShooters).l
	move.w	(sp)+,(shootoutteam).w
.34
	cmpi.w	#2,(OptPlayMode).w
	beq.w	.35
	cmpi.w	#3,(OptPlayMode).w
	bne.w	.36
.35
	move.b	#1,($203D8F).l
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
.36
	movem.l	(sp)+,d0-d7/a0-a6
.exit
	rts

TeamSelectGfx						;Team select video set up: backgrounds, the logos and the five rank names
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(VBint).l
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col).w
	move.w	#0,d0
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	jsr	(orjoy).l
	movea.l	#SelectTeamSeasonSprites,a1
	btst	#7,(GameFlags).w
	bne.w	.0
	movea.l	#SelectTeamSprites,a1
.0
	bsr.w	LoadScreenSprite
	move.w	d4,(printbigchars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DecompressGraphicsPlain).l
	bclr	#2,(sflags11).w
	move.w	d4,(BigFontchars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$2A,$15,$6E,$F9,$AB,$CD,$EF	;remap table
	move.w	d4,(homelogochars).l
	addi.w	#$A0,d4
	move.w	d4,(vislogochars).l
	addi.w	#$A0,d4
	jsr	(printsmallz).l
	String	CC_SetMap,$01,CC_SetX,$00,CC_SetY,$00
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$00,$00,$00
	movea.l	#SelectTeamSeasonBgMap,a0
	btst	#7,(GameFlags).w
	bne.w	.1
	movea.l	#SelectTeamBgMap,a0
.1
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#8,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$0B,$01,$00
	movea.l	#SelectTeamTitleMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	-TXMAP2,$00,$00,$00
	movea.l	#ControllerBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$40,d2
	moveq	#$1C,d3
	moveq	#1,d5
	jsr	(dobitmap).l
	btst	#7,(GameFlags).w
	beq.w	.11
	bsr.w	DrawUserLogo
	bra.w	.2
.11
	bsr.w	DrawHomeLogo
	bsr.w	DrawVisLogo
.2
	btst	#7,(GameFlags).w
	bne.w	.3
	jsr	(printbigz).l
	String	CC_SetMapAndPosition,$04,$01,$0E,$10,'EVEN-STRENGTH',CC_SetMapAndPosition,$04,$01,$0F,$12,'POWER-PLAY',CC_SetMapAndPosition,$04,$01,$0D,$14,'PENALTY KILLING',CC_SetMapAndPosition,$04,$01,$0F,$16,'GOALTENDING',CC_SetMapAndPosition,$04,$01,$11,$18,'OVERALL',$00
	bra.w	.4
.3
	jsr	(printbigz).l
	String	CC_SetMapAndPosition,$04,$01,$12,$06,'EVEN-STRENGTH',CC_SetMapAndPosition,$04,$01,$12,$08,'POWER-PLAY',CC_SetMapAndPosition,$04,$01,$12,$0A,'PENALTY KILLING',CC_SetMapAndPosition,$04,$01,$12,$0C,'GOALTENDING',CC_SetMapAndPosition,$04,$01,$12,$0E,'OVERALL',$00
.4
	jsr	(RedrawTeamRanks).l
	move	#$2500,sr
	rts

PrintHomeRanks						;Team select: the home team's ranks (TeamRankPtrs) as ordinals,
									;highlighted when the home side is selected
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(printbigchars).w,-(sp)
	cmpi.w	#1,(TeamSelSide).w
	bne.w	.0
	move.w	(BigFontchars).w,(printbigchars).w
.0
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$1E,$10,$00
	move.w	(printx).w,-(sp)
	movea.l	#TeamRankPtrs,a5
	move.w	#4,d7
.1
	move.w	d7,d0
	asl.w	#2,d0
	movea.l	(a5,d0.w),a0
	move.w	(HomeTeam).w,d0
	jsr	(a0)
	move.w	#2,d1
	move.w	d0,-(sp)
	jsr	(PushNumberWidth).l
	jsr	(printbig).l
	move.w	(sp)+,d0
	bsr.w	PrintOrdinal
	move.w	(sp),(printx).w
	addq.w	#2,(printy).w
	dbf	d7,.1
	move.w	(sp)+,(printx).w
	move.w	(sp)+,(printbigchars).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintVisRanks						;Team select: the visiting team's ranks as ordinals, highlighted when the
									;visitor side is selected
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(printbigchars).w,-(sp)
	cmpi.w	#2,(TeamSelSide).w
	bne.w	.0
	move.w	(BigFontchars).w,(printbigchars).w
.0
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$06,$10,$00
	move.w	(printx).w,-(sp)
	movea.l	#TeamRankPtrs,a5
	move.w	#4,d7
.1
	move.w	d7,d0
	asl.w	#2,d0
	movea.l	(a5,d0.w),a0
	move.w	(VisTeam).w,d0
	jsr	(a0)
	move.w	#2,d1
	move.w	d0,-(sp)
	jsr	(PushNumberWidth).l
	jsr	(printbig).l
	move.w	(sp)+,d0
	bsr.w	PrintOrdinal
	move.w	(sp),(printx).w
	addq.w	#2,(printy).w
	dbf	d7,.1
	move.w	(sp)+,(printx).w
	move.w	(sp)+,(printbigchars).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintUserRanks						;Team select (new season): the ranks of the user team as ordinals
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$22,$06,$00
	move.w	(printx).w,-(sp)
	movea.l	#TeamRankPtrs,a5
	move.w	#4,d7
.0
	move.w	d7,d0
	asl.w	#2,d0
	movea.l	(a5,d0.w),a0
	move.b	(SeasonTeam).w,d0
	jsr	(a0)
	move.w	#2,d1
	move.w	d0,-(sp)
	jsr	(PushNumberWidth).l
	jsr	(printbig).l
	move.w	(sp)+,d0
	bsr.w	PrintOrdinal
	move.w	(sp),(printx).w
	addq.w	#2,(printy).w
	dbf	d7,.0
	move.w	(sp)+,(printx).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintOrdinal						;printbig the ordinal suffix of d0 (11 through 20 are th)
	ext.l	d0
	cmp.w	#$A,d0
	blt.w	.0
	cmp.w	#$15,d0
	bge.w	.0
	movea.l	#OrdinalSuffix,a1
	jmp	printbig
.0
	divs.w	#$A,d0
	swap	d0
	asl.w	#2,d0
	movea.l	#OrdinalSuffixPtr,a0
	movea.l	(a0,d0.w),a1
	jmp	printbig

OrdinalSuffixPtr					;Ones digit: th, st, nd, rd, then th
	dc.l	OrdinalSuffix,OrdinalSuffix+4,OrdinalSuffix+8,OrdinalSuffix+12
	dc.l	OrdinalSuffix,OrdinalSuffix,OrdinalSuffix,OrdinalSuffix,OrdinalSuffix,OrdinalSuffix

OrdinalSuffix						;TH, ST, ND, RD
	String	'TH'
	String	'ST'
	String	'ND'
	String	'RD'
	;The team rank lookups TeamRankPtrs points to: d0 = the rank of team d0 from a byte table
TeamRankEvenStrength				;Team select rank lookup: the even strength rank of team d0
	move.l	a0,-(sp)
	ext.w	d0
	movea.l	#TeamRankEvenStrengthTable,a0
	move.b	(a0,d0.w),d0
	ext.w	d0
	movea.l	(sp)+,a0
	rts
TeamRankEvenStrengthTable			;Even strength rank of each team
	dc.w	$130A,$1107,$080B,$0219,$0E0C,$1612,$0510,$0D1A
	dc.w	$0604,$0317,$0114,$1509,$0F18,$0101
TeamRankPowerPlay					;Team select rank lookup: the power play rank of team d0
	move.l	a0,-(sp)
	ext.w	d0
	movea.l	#TeamRankPowerPlayTable,a0
	move.b	(a0,d0.w),d0
	ext.w	d0
	movea.l	(sp)+,a0
	rts
TeamRankPowerPlayTable				;Power play rank of each team
	dc.w	$1A04,$0B0C,$0113,$0311,$180D,$0E10,$1714,$0515
	dc.w	$0809,$0219,$1216,$0F07,$060A,$0101
TeamRankPenaltyKilling				;Team select rank lookup: the penalty killing rank of team d0
	move.l	a0,-(sp)
	ext.w	d0
	movea.l	#TeamRankPenaltyKillingTable,a0
	move.b	(a0,d0.w),d0
	ext.w	d0
	movea.l	(sp)+,a0
	rts
TeamRankPenaltyKillingTable			;Penalty killing rank of each team
	dc.w	$1A02,$0405,$0708,$0119,$0D14,$0F15,$1218,$0A16
	dc.w	$1317,$100E,$1109,$030B,$060C,$0101
TeamRankGoaltending					;Team select rank lookup: the goaltending rank of team d0
	move.l	a0,-(sp)
	ext.w	d0
	movea.l	#TeamRankGoaltendingTable,a0
	move.b	(a0,d0.w),d0
	ext.w	d0
	movea.l	(sp)+,a0
	rts
TeamRankGoaltendingTable			;Goaltending rank of each team
	dc.w	$1607,$0309,$010A,$021A,$060E,$1712,$0514,$0D18
	dc.w	$0813,$0B15,$0C0F,$1110,$0419,$0101
TeamRankOverall						;Team select rank lookup: the rank of team d0 in the overall standings (a
									;byte table)
	move.l	a0,-(sp)
	ext.w	d0
	movea.l	#TeamRankOverallTable,a0
	move.b	(a0,d0.w),d0
	ext.w	d0
	movea.l	(sp)+,a0
	rts
TeamRankOverallTable				;Overall rank of each team (one byte per team, 1 = best)
	dc.w	$1806,$0B07,$0810,$0116,$1112,$1413,$0919,$0E1A
	dc.w	$0503,$020F,$0417,$0C0D,$0A15,$0101

TeamRankPtrs						;The team rank lookups, one long each: overall, goaltending, penalty
									;killing, power play, even strength
	dc.b	$00,$01,$20,$C2,$00,$01,$20,$92,$00,$01,$20,$62,$00,$01,$20,$32
	dc.b	$00,$01,$20,$02

DrawUserLogo						;Team select: draw the user team's logo
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$01,$08,$00
	clr.w	d7
	move.b	(SeasonTeam).w,d7
	move.w	(homelogochars).l,d4
	moveq	#2,d5
	jsr	(DrawTeamLogoD7).l
	move.w	#$64,(palcount).w
	rts

DrawHomeLogo						;Team select: draw the home team's logo
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$17,$04,$00
	move.w	(HomeTeam).w,d7
	move.w	(homelogochars).l,d4
	moveq	#2,d5
	jsr	(DrawTeamLogoD7).l
	move.w	#$64,(palcount).w
	rts

DrawVisLogo							;Team select: draw the visiting team's logo (palette 3)
	jsr	(printz).l
	String	-(TXPRI+TXPAL3+TXMAP1),$01,$04,$00
	move.w	(VisTeam).w,d7
	move.w	(vislogochars).l,d4
	clr.w	d5
	jsr	(DrawTeamLogoD7).l
	move.w	#$64,(palcount).w
	rts

LoadScreenSprite					;Decompress the chars of sprite file a1 at char 1 (for DrawScreenSprite)
	move.w	#1,d4
	lea	8(a1),a2
	adda.l	(a1),a1
	jmp	DecompressGraphicsPlain

DrawScreenSprite					;Put frame 0 of sprite file a0 at the screen's top left (char 1, palette
									;3) as the only sprite
	move.w	#$80,d0
	move.w	#$80,d1
	move.w	#0,d2
	move.w	#1,d3
	ori.w	#$6000,d3
	movea.l	#$FFFFC066,a6
	move.w	#1,d6
	jsr	(SetSframe).l
	clr.b	-5(a6)
	move.l	a6,d0
	subi.l	#$FFFFC066,d0
	lsr.w	#1,d0
	move.w	d0,(Sattsize).w
	bset	#dfok,(disflags).w
	rts

TeamSelectSide						;Team select: TeamSelSide = the highlighted side (0 season, 1 home, 2
									;visitors)
	clr.w	(TeamSelSide).w
	btst	#7,(GameFlags).w
	bne.w	.2
	movem.l	d0/a0,-(sp)
	tst.w	(OptPlayMode).w
	beq.w	.0
	cmpi.w	#3,(OptPlayMode).w
	bgt.w	.0
	move.w	(potreeteam).w,d0
	movea.l	#$FFFFCFD2,a0
	move.b	(a0,d0.w),d0
	cmp.w	(HomeTeam).w,d0
	beq.w	.oneside
	bra.w	.toomany
.0
	tst.w	(TeamSelectHome).l
	bne.w	.oneside
	bra.w	.toomany
.oneside
	move.w	#1,(TeamSelSide).w
	bra.w	.1
.toomany
	move.w	#2,(TeamSelSide).w
.1
	movem.l	(sp)+,d0/a0
.2
	rts

RedrawTeamRanks						;Team select: update the selected side and reprint both teams' ranks with
									;the highlight
	bsr.s	TeamSelectSide
	tst.w	(TeamSelSide).w
	beq.w	.0
	bsr.w	PrintVisRanks
	bsr.w	PrintHomeRanks
.0
	rts

RunSeasonMenu						;Run the season screens: call the routine in NextScreenPtr
									;(SeasonMenuScreen first) until one sets the end value
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(menulist).w,-(sp)
	move.l	(menudraw).w,-(sp)
	move.w	(menuitem).w,-(sp)
	move.w	(menuitem+2).w,-(sp)
	btst	#1,(sflags14).w
	bne.w	.0
	move.w	#3,-(sp)
	jsr	(song).l
.0
	movea.l	(NextScreenPtr).w,a0
	cmpa.l	#ZeroLong,a0
	beq.w	.1
	move.w	(HomeTeam).w,-(sp)
	move.w	(VisTeam).w,-(sp)
	jsr	(a0)
	move.w	(sp)+,(VisTeam).w
	move.w	(sp)+,(HomeTeam).w
	bra.s	.0
.1
	bclr	#1,(sflags14).w
	move.l	(sp)+,(menudraw).w
	move.w	(sp)+,(menuitem).w
	move.w	(sp)+,(menuitem+2).w
	move.l	(sp)+,(menulist).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SeasonMenuScreen					;Season menu: Play Game, Simulate Game, Standings ... Exit Season (up /
									;down); [] changes the day, start runs
									;the item
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	(carddelay).w
	bsr.w	BuildSeasonMenuTeamList
	clr.w	d0
	move.b	(SeasonTeam+1).w,d0
	move.w	d0,(TeamSelectHome+2).l
	beq.w	.1
	subq.w	#1,(TeamSelectHome+2).l
.1
	cmp.w	(TeamSelectHome+4).l,d0
	blt.w	.2
	move.w	(TeamSelectHome+4).l,(TeamSelectHome+2).l
	subq.w	#1,(TeamSelectHome+2).l
.2
	bsr.w	SeasonMenuListByDay
	bset	#5,(sflags12).w
	bsr.w	SetupLeagueOptionsScreen
	movea.l	#LeagueOptionsSprites,a0
	jsr	(DrawScreenSprite).l
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	bset	#2,(sflags5).w
	bsr.w	DrawSeasonTeamSelect
	bclr	#2,(sflags5).w
	move.w	(Vcount).w,d0			;frame counter
	;loop
.loop
	cmp.w	(Vcount).w,d0
	beq.s	.loop					;wait for a new frame
	bsr.w	SeasonMenuListSixRows	;read the pads
	clr.w	(TeamSelectRedraw).l
.loop2
	move.w	(Vcount).w,d0
.loop3
	cmp.w	(Vcount).w,d0
	beq.s	.loop3
	jsr	(SetMenuScroll).l
	bclr	#0,(TeamSelectRedraw).l
	beq.w	.3
	bsr.w	DrawSeasonTeamSelect
	jsr	(SetMenuScroll).l
.3
	cmpi.w	#$5460,(carddelay).w
	jsr	(FindHeldMenuPad).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.4
	clr.w	(carddelay).w
.4
	btst	#7,d1
	bne.w	.13
	btst	#5,d1
	bne.w	.13
	btst	#0,d1
	beq.w	.5
	subq.w	#1,(menuitem).w
	bsr.w	SeasonMenuListSixRows
	bra.s	.loop2
.5
	btst	#1,d1
	beq.w	.6
	addq.w	#1,(menuitem).w
	bsr.w	SeasonMenuListSixRows
	bra.s	.loop2
.6
	btst	#2,d1
	beq.w	.9
	tst.w	(TeamSelectHome+2).l
	beq.w	.loop2
	cmpi.w	#2,(TeamSelectHome+2).l
	ble.w	.7
	bset	#1,(TeamSelectRedraw).l
.7
	move.w	(vislogochars+6).l,-(sp)
	move.w	(vislogochars+4).l,(vislogochars+6).l
	move.w	(vislogochars+2).l,(vislogochars+4).l
	move.w	(vislogochars).l,(vislogochars+2).l
	move.w	(homelogochars).l,(vislogochars).l
	move.w	(sp)+,(homelogochars).l
	subq.w	#1,(TeamSelectHome+2).l
	bset	#0,(TeamSelectRedraw).l
	move.w	(TeamSelectHome+2).l,d0
	addq.w	#1,d0
	cmp.b	(SeasonTeam+1).w,d0
	bne.w	.8
	clr.w	(menuitem+2).w
	clr.w	(menuitem).w
	bsr.w	SeasonMenuListSixRows
.8
	move.w	(TeamSelectHome+2).l,d0
	cmp.b	(SeasonTeam+1).w,d0
	bne.w	.loop2
	clr.w	(menuitem+2).w
	clr.w	(menuitem).w
	bsr.w	SeasonMenuListSixRows
	bra.w	.loop2
.9
	btst	#3,d1
	beq.w	.12
	move.w	(TeamSelectHome+4).l,d0
	subq.w	#1,d0
	cmp.w	(TeamSelectHome+2).l,d0
	ble.w	.loop2
	move.w	(TeamSelectHome+4).l,d0
	subq.w	#3,d0
	cmp.w	(TeamSelectHome+2).l,d0
	blt.w	.10
	bset	#2,(TeamSelectRedraw).l
.10
	move.w	(homelogochars).l,-(sp)
	move.w	(vislogochars).l,(homelogochars).l
	move.w	(vislogochars+2).l,(vislogochars).l
	move.w	(vislogochars+4).l,(vislogochars+2).l
	move.w	(vislogochars+6).l,(vislogochars+4).l
	move.w	(sp)+,(vislogochars+6).l
	addq.w	#1,(TeamSelectHome+2).l
	bset	#0,(TeamSelectRedraw).l
	move.w	(TeamSelectHome+2).l,d0
	subq.w	#1,d0
	cmp.b	(SeasonTeam+1).w,d0
	bne.w	.11
	clr.w	(menuitem+2).w
	clr.w	(menuitem).w
	bsr.w	SeasonMenuListSixRows
.11
	move.w	(TeamSelectHome+2).l,d0
	cmp.b	(SeasonTeam+1).w,d0
	bne.w	.loop2
	clr.w	(menuitem+2).w
	clr.w	(menuitem).w
	bsr.w	SeasonMenuListSixRows
	bra.w	.loop2
.12
	bra.w	.loop2
.13
	movea.l	(menurows+2).w,a0
	jsr	(a0)
	movem.l	(sp)+,d0-d7/a0-a6
	rts
BuildSeasonMenuTeamList				;Season menu: build the team select list TeamSelectHome+6 from
									;SeasonSchedule (or leave it for the playoffs)
	btst	#2,(SeasonDay+2).w
	bne.w	.5
	clr.w	(TeamSelectHome+4).l
	movea.l	#TeamSelectHome+6,a0
	movea.l	#SeasonSchedule,a1
	move.b	(SeasonTeam).w,d1
	clr.w	d3
	move.b	(a1)+,d3
	clr.w	d4
	bra.w	.4
.loop
	clr.w	d2
	move.b	(a1)+,d2
	bra.w	.3
.loop2
	cmp.b	(a1),d1
	beq.w	.1
	cmp.b	1(a1),d1
	bne.w	.2
.1
	addq.w	#1,(TeamSelectHome+4).l
	move.b	(a1),(a0)+
	move.b	1(a1),(a0)+
	move.w	d4,(a0)+
	movea.l	#$20197E,a3
	movea.l	#$201A26,a4
	move.w	(TeamSelectHome+4).l,d0
	subq.w	#1,d0
	add.w	d0,d0
	clr.w	(a0)+
	move.b	1(a3,d0.w),-$1(a0)
	clr.w	(a0)+
	move.b	1(a4,d0.w),-$1(a0)
.2
	addq.w	#2,a1
.3
	dbf	d2,.loop2
	addq.w	#1,d4
.4
	dbf	d3,.loop
	rts
.5
	clr.w	(TeamSelectHome+4).l
	movea.l	#TeamSelectHome+6,a0
	movea.l	#$200E68,a1
	movea.l	#$20197E,a3
	movea.l	#$201A26,a4
	move.b	(SeasonTeam).w,d1
	clr.w	d3
	move.b	(SeasonTeam+1).w,d3
	clr.w	d4
	bra.w	.8
.loop3
	move.w	(a1)+,d0
	btst	#7,d0
	bne.w	.6
	andi.w	#$7F,d0
	move.b	(SeasonTeam).w,(a0)+
	move.b	d0,(a0)+
	bra.w	.7
.6
	andi.w	#$7F,d0
	move.b	d0,(a0)+
	move.b	(SeasonTeam).w,(a0)+
.7
	move.w	d4,(a0)+
	move.w	(a3)+,d0
	andi.w	#$FF,d0
	move.w	d0,(a0)+
	move.w	(a4)+,d0
	andi.w	#$FF,d0
	move.w	d0,(a0)+
	addq.w	#1,(TeamSelectHome+4).l
.8
	dbf	d3,.loop3
	jsr	(FindUserGame).l
	cmpa.l	#$0,a2
	beq.w	.9
	btst	#1,(SeasonDay+2).w
	bne.w	.9
	move.b	(a2),(a0)+
	move.b	1(a2),(a0)+
	move.w	(SeasonDay).w,(a0)+
	addq.w	#1,(TeamSelectHome+4).l
.9
	rts
SeasonMenuCountGoalie	equ	*	;Draw the goalie mark and count one goalie (low confidence)
	btst	#5,(sflags12).w
	bne.w	.10
	move.w	(VSCRLPM).w,d0
	jsr	(Vmaddr).l
	move.w	#0,(a0)
	move.w	(homegoalies).w,d0
	move.w	d0,(a0)
.10
	addq.w	#1,(homegoalies).w
	rts

SetMenuScroll						;Write the vertical scroll: plane A 0, plane B the menu background scroll
									;(homegoalies)
	move.w	(VSCRLPM).w,d0
	jsr	(Vmaddr).l
	move.w	#0,(a0)
	move.w	(homegoalies).w,d0
	move.w	d0,(a0)
	rts
SetupLeagueOptionsScreen	equ	*			;Set the VBint handler, the scroll and map addresses, load the League options sprites and fonts
	move.l	#$12D46,(VBint).l
	bclr	#dfok,(disflags).w
	bset	#dfng,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VSPRITES).w
	move.w	#$B800,(VmMAP3).w
	move.w	#5,(Map3col).w
	move.w	#$C000,(VmMAP2).w
	move.w	#6,(Map2col).w
	move.w	#$E000,(VmMAP1).w
	move.w	#6,(Map1col).w
	move.w	#0,d0
	bset	#5,(disflags).w
	jsr	(setVram).l
	bclr	#5,(disflags).w
	jsr	(orjoy).l
	move.w	#1,d4
	movea.l	#LeagueOptionsSprites,a1
	jsr	(LoadScreenSprite).l
	move.w	d4,(smallfontchars).w
	movea.l	#$179170,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(smallfont2chars).w
	movea.l	#$17A16C,a2
	jsr	(DecompressGraphicsPlain).l
	move.l	#$179168,(smallfontptr).l
	move.w	d4,(printbigchars).w
	movea.l	#$17AA7A,a2
	jsr	(DecompressGraphicsPlain).l
	bclr	#2,(sflags11).w
	move.w	d4,(homelogochars).l
	addi.w	#$19,d4
	move.w	d4,(vislogochars).l
	addi.w	#$19,d4
	move.w	d4,(vislogochars+2).l
	addi.w	#$19,d4
	move.w	d4,(vislogochars+4).l
	addi.w	#$19,d4
	move.w	d4,(vislogochars+6).l
	addi.w	#$19,d4
	move.w	d4,-(sp)
	movea.l	#SmallLogoPtrs,a3
	movea.l	#homelogochars,a1
	move.w	(TeamSelectHome+2).l,d0
	subq.w	#2,d0
	bpl.w	.loop
	addq.w	#2,a1
	addq.w	#1,d0
	bpl.w	.loop
	addq.w	#2,a1
	addq.w	#1,d0
.loop
	asl.w	#3,d0
	movea.l	#TeamSelectHome+6,a0
	move.b	(a0,d0.w),d7
	cmp.b	(SeasonTeam).w,d7
	bne.w	.1
	move.b	1(a0,d0.w),d7
.1
	cmp.w	#$1A,d7
	bge.w	.2
	ext.w	d7
	asl.w	#2,d7
	movea.l	(a3,d7.w),a2
	addq.w	#8,a2
	move.w	(a1),d4
	jsr	(DecompressGraphicsPlain).l
	cmpa.l	#$FFFF271E,a1
	beq.w	.2
	asr.w	#3,d0
	addq.w	#2,a1
	addq.w	#1,d0
	cmp.w	#$53,d0
	ble.s	.loop
.2
	move.w	(sp)+,d4
	move.w	d4,(pstatsblockchars).l
	addi.w	#$20,d4
	move.w	d4,(pstatscount).l
	addi.w	#$20,d4
	jsr	(printsmallz).l
	String	$FF,1,$FD,0,$FC
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,0
	movea.l	#LeagueOptionsBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#8,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$B,1
	movea.l	#LeagueOptionsTitleMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#8,d5
	jsr	(dobitmap).l
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printcurz).l
	String	$8F,$C,$19,'{}-MENU OPTIONS',$8F,$C,$1A,'[]-CHANGE DAY'
	move.w	(sp)+,(smallfontchars).w
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,4
	clr.w	d7
	move.b	(SeasonTeam).w,d7
	moveq	#2,d5
	bsr.w	DrawTeamLogoD7
	jsr	(printz).l
	String	$FE,0,0
	movea.l	#IceBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$40,d2
	moveq	#$1C,d3
	moveq	#1,d5
	jsr	(dobitmap).l
	move.w	#$2500,sr
	rts
SeasonMenuDrawTeamRow	equ	*	;Season menu: draw the team row (low confidence)
	move.w	(SeasonDay).w,-(sp)
	tst.w	(TeamSelectHome+2).l
	beq.w	.3
	jsr	(printbigz).l
	String	$F8,4,1,$D,$14,'['
.3
	btst	#2,(SeasonDay+2).w
	beq.w	.4
	jsr	(printbigz).l
	String	$F8,4,1,$E,$14
	jsr	(printbigz).l
	String	'PLAYOFFS'
	bra.w	.5
.4
	move.w	(TeamSelectHome).l,(SeasonDay).w
	jsr	(SetupSeasonGameLookup).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$E,$14
	jsr	(printbig).l
.5
	move.w	(TeamSelectHome+2).l,d0
	addq.w	#1,d0
	cmp.w	(TeamSelectHome+4).l,d0
	bge.w	.6
	jsr	(printbigz).l
	String	']'
.6
	move.w	(sp)+,(SeasonDay).w
	rts
SeasonMenuClampTeam	equ	*	;Season menu: clamp the selected team (low confidence)
	clr.w	d0
	move.b	(SeasonTeam+1).w,d0
	beq.w	.7
	subq.w	#1,d0
	cmp.w	(TeamSelectHome+2).l,d0
	blt.w	.7
	move.w	(TeamSelectHome+2).l,d0
	asl.w	#3,d0
	movea.l	#TeamSelectHome+6,a0
	movem.l	d0/a0,-(sp)
	move.w	4(a0,d0.w),d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$1F,$14
	jsr	(printbig).l
	movem.l	(sp)+,d0/a0
	move.w	6(a0,d0.w),d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),8,$14
	jsr	(printbig).l
.7
	rts
DrawSeasonTeamSelect	equ	*	;Season menu: draw the team select rows with the team blocks and wait for the next frame
	jsr	(printbigz).l
	String	$F8,4,1,8,$14,'                           '
	move.w	(TeamSelectHome+2).l,d0
	asl.w	#3,d0
	movea.l	#TeamSelectHome+6,a0
	move.w	2(a0,d0.w),(TeamSelectHome).l
	movem.l	d0/a0,-(sp)
	bsr.w	SeasonMenuDrawTeamRow
	bsr.w	SeasonMenuClampTeam
	move.w	(Vcount).w,d0
.loop2
	cmp.w	(Vcount).w,d0
	beq.s	.loop2
	movem.l	(sp),d0/a0
	clr.w	d7
	move.b	(a0,d0.w),d7
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$17,$16
	move.w	(pstatsblockchars).l,d4
	bsr.w	DrawSetupTeamBlock
	move.b	1(a0,d0.w),d7
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),1,$16
	move.w	(pstatscount).l,d4
	bsr.w	DrawSetupTeamBlock
	move.w	(Vcount).w,d0
.loop3
	cmp.w	(Vcount).w,d0
	beq.s	.loop3
	movem.l	(sp),d0/a0
	bsr.w	SeasonMenuDrawLogos
	movem.l	(sp)+,d0/a0
	rts
SeasonMenuDrawLogos	equ	*	;Season menu: draw the team logos
	move.w	#4,d6
	movea.l	#vislogochars+6,a2
	move.w	(TeamSelectHome+2).l,d5
	addq.w	#2,d5
	bset	#0,(sflags6).w
.loop4
	move.w	(TeamSelectHome+4).l,d0
	subq.w	#1,d0
	cmp.w	d0,d5
	ble.w	.8
	bsr.w	SeasonMenuDrawLegend
	bra.w	.14
.8
	tst.w	d5
	bpl.w	.9
	bsr.w	SeasonMenuDrawLegend
	bra.w	.14
.9
	move.w	(a2),d4
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,$E
	movea.l	#$12B4A,a0
	move.b	(a0,d6.w),(printx+1).w
	move.w	d5,d0
	asl.w	#3,d0
	movea.l	#TeamSelectHome+6,a0
	move.b	(a0,d0.w),d1
	cmp.b	(SeasonTeam).w,d1
	bne.w	.10
	move.b	1(a0,d0.w),d1
.10
	movea.l	#SmallLogoPtrs,a0
	ext.w	d1
	asl.w	#2,d1
	movea.l	(a0,d1.w),a0
	bset	#0,(sflags6).w
	cmp.w	#4,d6
	bne.w	.11
	bclr	#2,(TeamSelectRedraw).l
	beq.w	.11
	bclr	#0,(sflags6).w
.11
	tst.w	d6
	bne.w	.12
	bclr	#1,(TeamSelectRedraw).l
	beq.w	.12
	bclr	#0,(sflags6).w
.12
	btst	#2,(sflags5).w
	beq.w	.13
	bclr	#0,(sflags6).w
.13
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#5,d2
	moveq	#5,d3
	moveq	#4,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a6
.14
	subq.l	#2,a2
	subq.w	#1,d5
	dbf	d6,.loop4
	bclr	#0,(sflags6).w
	rts
	dc.w	$020A,$121A,$22FF
SeasonMenuDrawLegend	equ	*	;Season menu: print the legend line
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),0,$E
	movea.l	#$12B4A,a0
	move.b	(a0,d6.w),(printx+1).w
	moveq	#5,d0
	moveq	#5,d1
	move.w	#$7FF,d2
	ori.w	#$8000,d2
	jsr	(eraser).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawSetupTeamBlock					;Draw the team block (TeamBlockPtrs) of team d7 at printx / printy (the
									;controller setup screen)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#TeamBlockPtrs,a0
	asl.w	#2,d7
	movea.l	(a0,d7.w),a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$10,d2
	moveq	#2,d3
	moveq	#4,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawTeamLogoD7						;Draw the logo of team d7 at printx / printy, char d4; d5 = 0 also copies
									;its palette to palfadenew+$40
	movem.l	d0-d3/d5-d7/a0-a6,-(sp)
	movea.l	#TeamLogoPtrs,a0
	asl.w	#2,d7
	movea.l	(a0,d7.w),a0
	tst.w	d5
	bne.w	.1
	movea.l	a0,a1
	adda.l	(a1),a1
	adda.w	#$20,a1
	movea.l	#$FFFFBD7E,a2
	move.w	#7,d0
.0
	move.l	(a1)+,(a2)+
	dbf	d0,.0
.1
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d3/d5-d7/a0-a6
	rts
