;	The season: the save RAM stats, injuries, standings and game log (96 keeps them as bit fields, ReadSRAMBits /
;	WriteSRAMBits), the day's games and the simulated days, the season header, the team select screen with the team
;	ranks, and the season menu. DrawSetupTeamBlock draws a team block of the controller setup screen.

SortBytesByWords	;Sort a5 words descending and swap the parallel a4 bytes. Stops at a negative byte
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

SaveGameStats	;Season game over: add both teams' game stats to the save RAM totals (AddTeamGameStats), then TickTeamInjuries
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

AddTeamGameStats	;Add the game stats of team struct a1 (player arrays, ice time) to its season or playoff totals in save RAM
	;(AddSavedStats)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	$28(a1),d7
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

AddSavedStats	;Add d3+1 values from a0 to the d2-bit save RAM fields at bit d1 + team d7 * d4 (sflags11 bit 3: word seconds,
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
	cmpi.w	#2,(OptPerlen).w
	beq.w	.4
	asl.w	#1,d4
	cmpi.w	#1,(OptPerlen).w
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

ReadSRAMBitWords	;Read d3+1 d2-bit save RAM fields from bit d1 + d7 * d4 into words at a0
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

WriteSRAMBitWords	;Write d3+1 words from a0 to the d2-bit save RAM fields from bit d1 + d7 * d4
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

TickTeamInjuries	;A game played: one injury game off every injured player of teams d0 and d1 (save RAM bits), then the checksum
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

StartNewSeason	;New season (sflags10 bit 6): reset the season header (day 0, default options), write it and clear the season
	;save data
	btst	#7,(GameFlags).w
	beq.w	.0
	bclr	#6,(sflags10).w
	beq.w	.0
	bset	#6,(GameFlags).w
	clr.w	(SeasonDay).w
	clr.b	(dword_FFDD82+3).w
	clr.b	(SeasonFlags).w
	bclr	#1,(sflags13).w
	move.b	#0,(SeasonDay+3).w
	move.b	#1,(dword_FFDD82).w
	move.b	#0,(dword_FFDD82+1).w
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

SimSeasonDays	;Simulate simdays days: every unplayed game of each day, save the results (WriteDayGames), step the day or
	;end the season
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(OptPerlen).w,-(sp)
	move.w	#2,(OptPerlen).w
	bset	#6,(GameFlags).w
	move.w	(simdays).w,d7
	bra.w	.12
.0
	bsr.w	BuildSeasonTeamList
	movea.l	#$FFFFDCFA,a2
	clr.w	d6
	move.b	(byte_FFDCF9).w,d6
	bra.w	.6
.1
	move.b	(dword_FFDD82+2).w,d0
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
	move.b	(dword_FFDD82+2).w,d0
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
	move.w	(sp)+,(OptPerlen).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

BuildSeasonTeamList	;Build the day's game list (day, count, 5 bytes a game) from SeasonSchedule; in the playoffs the round's series
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

WriteDayGames	;Save the results of the day's games: the user game log (SaveUserGame) and the standings (RecordGameResult);
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
	move.b	(dword_FFDD82+2).w,d0
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

SaveUserGame	;Game a2 of the user team: add it to the save RAM game log (scores, opponent), mark the day played, count it
	movem.l	d0-d2,-(sp)
	move.b	(dword_FFDD82+2).w,d0
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
	cmp.b	(dword_FFDD82+2).w,d0
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

UserGamePlayed	;ne when the user team's game of SeasonDay is already played (its save RAM day bit)
	movem.l	d0-d2,-(sp)
	move.w	(SeasonDay).w,d1
	mulu.w	#1,d1
	addi.l	#$6BE0,d1
	move.w	#1,d2
	jsr	(ReadSRAMBits).l
	btst	#0,d0
	movem.l	(sp)+,d0-d2
	rts

ReadUserGameCount	;d0 = the number of user team games in the save RAM game log (a season header byte)
	movem.l	d1-d2,-(sp)
	move.l	#$240,d1
	move.w	#8,d2
	jsr	(ReadSRAMBits).l
	movem.l	(sp)+,d1-d2
	rts

RecordGameResult	;Not in the playoffs: RecordTeamResult for the home and the away team of game a2
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

RecordTeamResult	;Add a win, tie or loss (own goals d2, opponent d3) to team d1's standings count in save RAM
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

WriteSeasonHeader	;Write the season header (SeasonDay ...) to save RAM and update the checksum
	movem.l	d0-d1/a0,-(sp)
	movea.l	#$FFFFDD7E,a0
	moveq	#$C,d1
	moveq	#$41,d0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d1/a0
	rts

ReadSeasonHeader	;Read the season header (SeasonDay ...) from save RAM
	movem.l	d0-d1/a0,-(sp)
	movea.l	#$FFFFDD7E,a0
	moveq	#$C,d1
	moveq	#$41,d0
	jsr	(ReadSRAM).l
	movem.l	(sp)+,d0-d1/a0
	rts
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$61,$00,$00,$26,$4E,$B9,$00,$1E,$1A,$5E,$4E,$B9
	dc.b	$00,$1E,$1A,$66,$4E,$B9,$00,$1E,$1A,$8E,$4E,$B9,$00,$1E,$1A,$A8
	dc.b	$4E,$B9,$00,$1E,$1A,$3C,$4C,$DF,$7F,$FF,$4E,$75,$11,$F8,$DD,$81
	dc.b	$D2,$5D,$11,$F8,$DD,$82,$D2,$63,$11,$F8,$DD,$83,$D2,$65,$11,$F8
	dc.b	$DD,$86,$D2,$67,$11,$F8,$DD,$87,$D2,$69,$11,$F8,$DD,$88,$D2,$5F
	dc.b	$11,$F8,$DD,$89,$D2,$61,$4E,$75

FindUserGame	;a2 = the user team's game in today's game list, or 0
	movem.l	d0-d2/a0,-(sp)
	movea.l	#0,a2
	movea.l	#$FFFFDCFA,a0
	clr.w	d0
	move.b	(byte_FFDCF9).w,d0
	bra.w	.1
.0
	move.b	(a0),d2
	cmp.b	(dword_FFDD82+2).w,d2
	beq.w	.2
	move.b	1(a0),d2
	cmp.b	(dword_FFDD82+2).w,d2
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

ClearSeasonData	;New season: clear the season stats, standings, game log and injuries in save RAM
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

sub_11582
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

LoadSeasonOptions	;Take the game options from the season header (period length, penalties, line changes); OptPlayMode 1 in the
	;playoffs
	clr.w	(OptPerlen).w
	move.b	(SeasonDay+3).w,(OptPerlen+1).w
	clr.w	(OptPen).w
	move.b	(dword_FFDD82).w,(OptPen+1).w
	clr.w	(OptLine).w
	move.b	(dword_FFDD82+1).w,(OptLine+1).w
	clr.w	(OptPlayMode).w
	btst	#2,(SeasonFlags).w
	beq.w	.0
	move.w	#1,(OptPlayMode).w
.0
	rts

ReadStandings	;Read the wins, ties and losses of every team (3 bytes a team) from save RAM into a0
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
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$80,$80,$42,$40,$20,$7C,$FF,$FF,$CF,$D2,$BE,$18,$67,$00
	dc.b	$00,$06,$52,$40,$60,$F6,$3E,$00,$4C,$DF,$01,$01,$4E,$75,$48,$E7
	dc.b	$00,$80,$42,$40,$20,$7C,$FF,$FF,$CF,$D2,$1E,$30,$70,$00,$4C,$DF
	dc.b	$01,$00,$4E,$75

SetupSeasonGame	;Set up the user's season game a2: the season options (LoadSeasonOptions) and the home and visiting teams
	jsr	(LoadSeasonOptions).l
	move.b	(a2),(Opt1team+1).w
	move.w	(Opt1team).w,(HomeTeam).w
	move.b	1(a2),(Opt2team+1).w
	move.w	(Opt2team).w,(VisTeam).w
	rts
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$BE,$30,$38,$DD,$7E,$42,$41,$20,$7C,$00,$01,$18,$0C
	dc.b	$42,$42,$14,$30,$10,$00,$B0,$42,$6F,$00,$00,$0A,$52,$41,$90,$42
	dc.b	$53,$40,$60,$EE,$22,$7C,$00,$01,$17,$9C,$60,$00,$00,$04,$D2,$D1
	dc.b	$51,$C9,$FF,$FC,$3F,$00,$26,$7C,$FF,$FF,$BF,$54,$30,$11,$53,$40
	dc.b	$16,$D9,$51,$C8,$FF,$FC,$30,$1F,$52,$40,$B0,$7C,$00,$09,$6F,$00
	dc.b	$00,$0A,$32,$3C,$00,$03,$60,$00,$00,$06,$32,$3C,$00,$02,$3F,$00
	dc.b	$4E,$B9,$00,$01,$BE,$1C,$26,$7C,$FF,$FF,$BF,$54,$4E,$B9,$00,$01
	dc.b	$BE,$80,$22,$7C,$00,$01,$17,$8C,$30,$1F,$48,$C0,$B0,$7C,$00,$0A
	dc.b	$6D,$00,$00,$0A,$B0,$7C,$00,$15,$6D,$00,$00,$3A,$81,$FC,$00,$0A
	dc.b	$48,$40,$B0,$7C,$00,$01,$66,$00,$00,$0C,$22,$7C,$00,$01,$17,$90
	dc.b	$60,$00,$00,$22,$B0,$7C,$00,$02,$66,$00,$00,$0C,$22,$7C,$00,$01
	dc.b	$17,$94,$60,$00,$00,$10,$B0,$7C,$00,$03,$66,$00,$00,$08,$22,$7C
	dc.b	$00,$01,$17,$98,$4E,$B9,$00,$01,$BE,$80,$22,$4B,$4C,$DF,$7D,$FF
	dc.b	$4E,$75,$00,$04,$54,$48,$00,$04,$53,$54,$00,$04,$4E,$44,$00,$04
	dc.b	$52,$44,$00,$0A,$4F,$43,$54,$4F,$42,$45,$52,$00,$00,$0A,$4E,$4F
	dc.b	$56,$45,$4D,$42,$45,$52,$00,$0A,$44,$45,$43,$45,$4D,$42,$45,$52
	dc.b	$00,$0A,$4A,$41,$4E,$55,$41,$52,$59,$00,$00,$0A,$46,$45,$42,$52
	dc.b	$55,$41,$52,$59,$00,$08,$4D,$41,$52,$43,$48,$00,$00,$08,$41,$50
	dc.b	$52,$49,$4C,$00,$48,$E7,$3F,$80,$42,$40,$10,$38,$DD,$7E,$58,$40
	dc.b	$42,$41,$20,$7C,$00,$01,$18,$0C,$42,$42,$14,$30,$10,$00,$B0,$42
	dc.b	$6F,$00,$00,$0A,$52,$41,$90,$42,$53,$40,$60,$EE,$4C,$DF,$01,$FC
	dc.b	$4E,$75,$1E,$1D,$1E,$1E,$1B,$1E,$1D,$FF

TeamSelectScreen	;Team select: up / down change the team, left / right pick home or visitors, with the team ranks; in a season
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
	move.b	#0,(dword_FFDD82+2).w
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
	bclr	#2,(disflags).w
	btst	#7,(GameFlags).w
	bne.w	.9
	bsr.w	PrintHomeRanks
	bsr.w	PrintVisRanks
	bra.w	.12
.9
	bsr.w	PrintUserRanks
.12
	bset	#0,(byte_FF2710).l
	bclr	#1,(byte_FF2710).l
	bclr	#2,(byte_FF2710).l
	move.w	#1,(word_FF2720).l
.frame
	move.w	(vcount).w,d0
.loop2
	cmp.w	(vcount).w,d0
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
	bclr	#0,(byte_FF2710).l
	beq.w	.1
	btst	#7,(GameFlags).w
	bne.w	.17
	bsr.w	RedrawTeamRanks
	bclr	#1,(byte_FF2710).l
	bne.w	.15
	bra.w	.16
.15
	bsr.w	DrawHomeLogo
	bsr.w	PrintHomeRanks
.16
	bclr	#2,(byte_FF2710).l
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
	opt	osq-	;keep the subi (SNASM would make it subq)
	subi.w	#1,(word_FF2720).l
	opt	osq+
	bpl.w	.19
	clr.w	(word_FF2720).l
	bra.w	.frame
.19
	jsr	(RedrawTeamRanks).l
	move	#$2500,sr
	bra.w	.frame
.3
	btst	#3,d1
	beq.w	.20
	tst.w	(word_FF2720).l
	bne.w	.frame
	move.w	#1,(word_FF2720).l
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
	bset	#1,(byte_FF2710).l
	bset	#2,(byte_FF2710).l
	bra.w	.26
.23
	btst	#7,(GameFlags).w
	bne.w	.25
	tst.w	(word_FF2720).l
	bne.w	.24
	bset	#2,(byte_FF2710).l
	subq.w	#1,(VisTeam).w
	bpl.w	.26
	move.w	#$19,(VisTeam).w
	bra.w	.26
.24
	bset	#1,(byte_FF2710).l
	subq.w	#1,(HomeTeam).w
	bpl.w	.26
	move.w	#$19,(HomeTeam).w
	bra.w	.26
.25
	subq.b	#1,(dword_FFDD82+2).w
	bpl.w	.26
	move.b	#$19,(dword_FFDD82+2).w
.26
	bset	#0,(byte_FF2710).l
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
	bset	#1,(byte_FF2710).l
	bset	#2,(byte_FF2710).l
	jsr	(NewPO).l
	bra.w	.32
.6
	btst	#7,(GameFlags).w
	bne.w	.31
	tst.w	(word_FF2720).l
	bne.w	.30
	bset	#2,(byte_FF2710).l
	addq.w	#1,(VisTeam).w
	cmpi.w	#$1A,(VisTeam).w
	blt.w	.32
	clr.w	(VisTeam).w
	bra.w	.32
.30
	bset	#1,(byte_FF2710).l
	addq.w	#1,(HomeTeam).w
	cmpi.w	#$1A,(HomeTeam).w
	blt.w	.32
	clr.w	(HomeTeam).w
	bra.w	.32
.31
	addq.b	#1,(dword_FFDD82+2).w
	cmpi.b	#$1A,(dword_FFDD82+2).w
	blt.w	.32
	clr.b	(dword_FFDD82+2).w
.32
	bset	#0,(byte_FF2710).l
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

TeamSelectGfx	;Team select video set up: backgrounds, the logos and the five rank names
	bset	#5,(sflags12).w
	move.l	#VBlank_Menus,(vbint).l
	bclr	#0,(disflags).w
	bset	#2,(disflags).w
	bclr	#1,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VSPRITES).w
	move.w	#$B800,(VmMap3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMap2).w
	move.w	#6,(Map2col1).w
	move.w	#$E000,(VmMap1).w
	move.w	#6,(Map1col1).w
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
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$2A,$15,$6E,$F9,$AB,$CD,$EF	;remap table
	move.w	d4,(homelogochars).l
	addi.w	#$A0,d4
	move.w	d4,(vislogochars).l
	addi.w	#$A0,d4
	jsr	(printsmallz).l
	String	$FF,$01,$FD,$00,$FC,$00
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
	String	$F8,$04,$01,$0E,$10,'EVEN-STRENGTH',$F8,$04,$01,$0F,$12,'POWER-PLAY',$F8,$04,$01,$0D,$14,'PENALTY KILLING',$F8,$04,$01,$0F,$16,'GOALTENDING',$F8,$04,$01,$11,$18,'OVERALL',$00
	bra.w	.4
.3
	jsr	(printbigz).l
	String	$F8,$04,$01,$12,$06,'EVEN-STRENGTH',$F8,$04,$01,$12,$08,'POWER-PLAY',$F8,$04,$01,$12,$0A,'PENALTY KILLING',$F8,$04,$01,$12,$0C,'GOALTENDING',$F8,$04,$01,$12,$0E,'OVERALL',$00
.4
	jsr	(RedrawTeamRanks).l
	move	#$2500,sr
	rts

PrintHomeRanks	;Team select: the home team's ranks (TeamRankPtrs) as ordinals, highlighted when the home side is selected
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(printbigchars).w,-(sp)
	cmpi.w	#1,(word_FFDDB6).w
	bne.w	.0
	move.w	(BigFontChars).w,(printbigchars).w
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

PrintVisRanks	;Team select: the visiting team's ranks as ordinals, highlighted when the visitor side is selected
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(printbigchars).w,-(sp)
	cmpi.w	#2,(word_FFDDB6).w
	bne.w	.0
	move.w	(BigFontChars).w,(printbigchars).w
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

PrintUserRanks	;Team select (new season): the ranks of the user team as ordinals
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
	move.b	(dword_FFDD82+2).w,d0
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

PrintOrdinal	;printbig the ordinal suffix of d0 (11 through 20 are th)
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

OrdinalSuffixPtr	;Ones digit: th, st, nd, rd, then th
	dc.l	OrdinalSuffix,OrdinalSuffix+4,OrdinalSuffix+8,OrdinalSuffix+12
	dc.l	OrdinalSuffix,OrdinalSuffix,OrdinalSuffix,OrdinalSuffix,OrdinalSuffix,OrdinalSuffix

OrdinalSuffix	;TH, ST, ND, RD
	dc.w	4
	dc.b	'TH'
	dc.w	4
	dc.b	'ST'
	dc.w	4
	dc.b	'ND'
	dc.w	4
	dc.b	'RD'
	;The team rank lookups TeamRankPtrs points to: d0 = the rank of team d0 from a byte table
	dc.b	$2F,$08,$48,$80,$20,$7C,$00,$01,$20,$16,$10,$30,$00,$00,$48,$80
	dc.b	$20,$5F,$4E,$75,$13,$0A,$11,$07,$08,$0B,$02,$19,$0E,$0C,$16,$12
	dc.b	$05,$10,$0D,$1A,$06,$04,$03,$17,$01,$14,$15,$09,$0F,$18,$01,$01
	dc.b	$2F,$08,$48,$80,$20,$7C,$00,$01,$20,$46,$10,$30,$00,$00,$48,$80
	dc.b	$20,$5F,$4E,$75,$1A,$04,$0B,$0C,$01,$13,$03,$11,$18,$0D,$0E,$10
	dc.b	$17,$14,$05,$15,$08,$09,$02,$19,$12,$16,$0F,$07,$06,$0A,$01,$01
	dc.b	$2F,$08,$48,$80,$20,$7C,$00,$01,$20,$76,$10,$30,$00,$00,$48,$80
	dc.b	$20,$5F,$4E,$75,$1A,$02,$04,$05,$07,$08,$01,$19,$0D,$14,$0F,$15
	dc.b	$12,$18,$0A,$16,$13,$17,$10,$0E,$11,$09,$03,$0B,$06,$0C,$01,$01
	dc.b	$2F,$08,$48,$80,$20,$7C,$00,$01,$20,$A6,$10,$30,$00,$00,$48,$80
	dc.b	$20,$5F,$4E,$75,$16,$07,$03,$09,$01,$0A,$02,$1A,$06,$0E,$17,$12
	dc.b	$05,$14,$0D,$18,$08,$13,$0B,$15,$0C,$0F,$11,$10,$04,$19,$01,$01
	dc.b	$2F,$08,$48,$80,$20,$7C,$00,$01,$20,$D6,$10,$30,$00,$00,$48,$80
	dc.b	$20,$5F,$4E,$75,$18,$06,$0B,$07,$08,$10,$01,$16,$11,$12,$14,$13
	dc.b	$09,$19,$0E,$1A,$05,$03,$02,$0F,$04,$17,$0C,$0D,$0A,$15,$01,$01

TeamRankPtrs	;The team rank lookups, one long each: overall, goaltending, penalty killing, power play, even strength
	dc.b	$00,$01,$20,$C2,$00,$01,$20,$92,$00,$01,$20,$62,$00,$01,$20,$32
	dc.b	$00,$01,$20,$02

DrawUserLogo	;Team select: draw the user team's logo
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$01,$08,$00
	clr.w	d7
	move.b	(dword_FFDD82+2).w,d7
	move.w	(homelogochars).l,d4
	moveq	#2,d5
	jsr	(DrawTeamLogoD7).l
	move.w	#$64,(palcount).w
	rts

DrawHomeLogo	;Team select: draw the home team's logo
	jsr	(printz).l
	String	-(TXPRI+TXMAP1),$17,$04,$00
	move.w	(HomeTeam).w,d7
	move.w	(homelogochars).l,d4
	moveq	#2,d5
	jsr	(DrawTeamLogoD7).l
	move.w	#$64,(palcount).w
	rts

DrawVisLogo	;Team select: draw the visiting team's logo (palette 3)
	jsr	(printz).l
	String	-(TXPRI+TXPAL3+TXMAP1),$01,$04,$00
	move.w	(VisTeam).w,d7
	move.w	(vislogochars).l,d4
	clr.w	d5
	jsr	(DrawTeamLogoD7).l
	move.w	#$64,(palcount).w
	rts

LoadScreenSprite	;Decompress the chars of sprite file a1 at char 1 (for DrawScreenSprite)
	move.w	#1,d4
	lea	8(a1),a2
	adda.l	(a1),a1
	jmp	DecompressGraphicsPlain

DrawScreenSprite	;Put frame 0 of sprite file a0 at the screen's top left (char 1, palette 3) as the only sprite
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
	bset	#0,(disflags).w
	rts

TeamSelectSide	;Team select: word_FFDDB6 = the highlighted side (0 season, 1 home, 2 visitors)
	clr.w	(word_FFDDB6).w
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
	tst.w	(word_FF2720).l
	bne.w	.oneside
	bra.w	.toomany
.oneside
	move.w	#1,(word_FFDDB6).w
	bra.w	.1
.toomany
	move.w	#2,(word_FFDDB6).w
.1
	movem.l	(sp)+,d0/a0
.2
	rts

RedrawTeamRanks	;Team select: update the selected side and reprint both teams' ranks with the highlight
	bsr.s	TeamSelectSide
	tst.w	(word_FFDDB6).w
	beq.w	.0
	bsr.w	PrintVisRanks
	bsr.w	PrintHomeRanks
.0
	rts

RunSeasonMenu	;Run the season screens: call the routine in NextScreenPtr (SeasonMenuScreen first) until one sets the end value
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	(menulist).w,-(sp)
	move.l	(menudraw).w,-(sp)
	move.w	(menuitem).w,-(sp)
	move.w	(menuitem+2).w,-(sp)
	btst	#1,(byte_FFC35A).w
	bne.w	.0
	move.w	#3,-(sp)
	jsr	(song).l
.0
	movea.l	(NextScreenPtr).w,a0
	cmpa.l	#$772,a0
	beq.w	.1
	move.w	(HomeTeam).w,-(sp)
	move.w	(VisTeam).w,-(sp)
	jsr	(a0)
	move.w	(sp)+,(VisTeam).w
	move.w	(sp)+,(HomeTeam).w
	bra.s	.0
.1
	bclr	#1,(byte_FFC35A).w
	move.l	(sp)+,(menudraw).w
	move.w	(sp)+,(menuitem).w
	move.w	(sp)+,(menuitem+2).w
	move.l	(sp)+,(menulist).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SeasonMenuScreen	;Season menu: Play Game, Simulate Game, Standings ... Exit Season (up / down); [] changes the day, start runs
	;the item
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$42,$78,$D3,$12,$61,$00,$02,$54,$42,$40,$10,$38
	dc.b	$DD,$85,$33,$C0,$FF,$FF,$27,$22,$67,$00,$00,$08,$53,$79,$FF,$FF
	dc.b	$27,$22,$B0,$79,$FF,$FF,$27,$24,$6D,$00,$00,$12,$33,$F9,$FF,$FF
	dc.b	$27,$24,$FF,$FF,$27,$22,$53,$79,$FF,$FF,$27,$22,$61,$00,$0A,$9C
	dc.b	$08,$F8,$00,$05,$C3,$56,$61,$00,$03,$6A,$20,$7C,$00,$17,$E3,$FC
	dc.b	$4E,$B9,$00,$01,$21,$8A,$31,$FC,$00,$18,$BD,$3C,$08,$B8,$00,$02
	dc.b	$BF,$B2,$08,$F8,$00,$02,$C3,$44,$61,$00,$06,$A0,$08,$B8,$00,$02
	dc.b	$C3,$44,$30,$38,$B0,$52,$B0,$78,$B0,$52,$67,$FA,$61,$00,$0A,$CE
	dc.b	$42,$79,$FF,$FF,$27,$10,$30,$38,$B0,$52,$B0,$78,$B0,$52,$67,$FA
	dc.b	$4E,$B9,$00,$01,$26,$40,$08,$B9,$00,$00,$FF,$FF,$27,$10,$67,$00
	dc.b	$00,$0C,$61,$00,$06,$66,$4E,$B9,$00,$01,$26,$40,$0C,$78,$54,$60
	dc.b	$D3,$12,$4E,$B9,$00,$01,$B2,$82,$4E,$B9,$00,$01,$B3,$20,$4A,$41
	dc.b	$67,$00,$00,$06,$42,$78,$D3,$12,$08,$01,$00,$07,$66,$00,$01,$84
	dc.b	$08,$01,$00,$05,$66,$00,$01,$7C,$08,$01,$00,$00,$67,$00,$00,$0C
	dc.b	$53,$78,$CF,$FE,$61,$00,$0A,$66,$60,$9C,$08,$01,$00,$01,$67,$00
	dc.b	$00,$0C,$52,$78,$CF,$FE,$61,$00,$0A,$54,$60,$8A,$08,$01,$00,$02
	dc.b	$67,$00,$00,$9C,$4A,$79,$FF,$FF,$27,$22,$67,$00,$FF,$7A,$0C,$79
	dc.b	$00,$02,$FF,$FF,$27,$22,$6F,$00,$00,$0A,$08,$F9,$00,$01,$FF,$FF
	dc.b	$27,$10,$3F,$39,$FF,$FF,$27,$1E,$33,$F9,$FF,$FF,$27,$1C,$FF,$FF
	dc.b	$27,$1E,$33,$F9,$FF,$FF,$27,$1A,$FF,$FF,$27,$1C,$33,$F9,$FF,$FF
	dc.b	$27,$18,$FF,$FF,$27,$1A,$33,$F9,$FF,$FF,$27,$16,$FF,$FF,$27,$18
	dc.b	$33,$DF,$FF,$FF,$27,$16,$53,$79,$FF,$FF,$27,$22,$08,$F9,$00,$00
	dc.b	$FF,$FF,$27,$10,$30,$39,$FF,$FF,$27,$22,$52,$40,$B0,$38,$DD,$85
	dc.b	$66,$00,$00,$0E,$42,$78,$D0,$00,$42,$78,$CF,$FE,$61,$00,$09,$CE
	dc.b	$30,$39,$FF,$FF,$27,$22,$B0,$38,$DD,$85,$66,$00,$FE,$FA,$42,$78
	dc.b	$D0,$00,$42,$78,$CF,$FE,$61,$00,$09,$B4,$60,$00,$FE,$EA,$08,$01
	dc.b	$00,$03,$67,$00,$00,$AA,$30,$39,$FF,$FF,$27,$24,$53,$40,$B0,$79
	dc.b	$FF,$FF,$27,$22,$6F,$00,$FE,$D0,$30,$39,$FF,$FF,$27,$24,$57,$40
	dc.b	$B0,$79,$FF,$FF,$27,$22,$6D,$00,$00,$0A,$08,$F9,$00,$02,$FF,$FF
	dc.b	$27,$10,$3F,$39,$FF,$FF,$27,$16,$33,$F9,$FF,$FF,$27,$18,$FF,$FF
	dc.b	$27,$16,$33,$F9,$FF,$FF,$27,$1A,$FF,$FF,$27,$18,$33,$F9,$FF,$FF
	dc.b	$27,$1C,$FF,$FF,$27,$1A,$33,$F9,$FF,$FF,$27,$1E,$FF,$FF,$27,$1C
	dc.b	$33,$DF,$FF,$FF,$27,$1E,$52,$79,$FF,$FF,$27,$22,$08,$F9,$00,$00
	dc.b	$FF,$FF,$27,$10,$30,$39,$FF,$FF,$27,$22,$53,$40,$B0,$38,$DD,$85
	dc.b	$66,$00,$00,$0E,$42,$78,$D0,$00,$42,$78,$CF,$FE,$61,$00,$09,$1E
	dc.b	$30,$39,$FF,$FF,$27,$22,$B0,$38,$DD,$85,$66,$00,$FE,$4A,$42,$78
	dc.b	$D0,$00,$42,$78,$CF,$FE,$61,$00,$09,$04,$60,$00,$FE,$3A,$60,$00
	dc.b	$FE,$36,$20,$78,$D0,$0C,$4E,$90,$4C,$DF,$7F,$FF,$4E,$75,$08,$38
	dc.b	$00,$02,$DD,$80,$66,$00,$00,$7A,$42,$79,$FF,$FF,$27,$24,$20,$7C
	dc.b	$FF,$FF,$27,$26,$22,$7C,$00,$01,$35,$58,$12,$38,$DD,$84,$42,$43
	dc.b	$16,$19,$42,$44,$60,$00,$00,$54,$42,$42,$14,$19,$60,$00,$00,$46
	dc.b	$B2,$11,$67,$00,$00,$0A,$B2,$29,$00,$01,$66,$00,$00,$36,$52,$79
	dc.b	$FF,$FF,$27,$24,$10,$D1,$10,$E9,$00,$01,$30,$C4,$26,$7C,$00,$20
	dc.b	$19,$7E,$28,$7C,$00,$20,$1A,$26,$30,$39,$FF,$FF,$27,$24,$53,$40
	dc.b	$D0,$40,$42,$58,$11,$73,$00,$01,$FF,$FF,$42,$58,$11,$74,$00,$01
	dc.b	$FF,$FF,$54,$49,$51,$CA,$FF,$BA,$52,$44,$51,$CB,$FF,$AC,$4E,$75
	dc.b	$42,$79,$FF,$FF,$27,$24,$20,$7C,$FF,$FF,$27,$26,$22,$7C,$00,$20
	dc.b	$0E,$68,$26,$7C,$00,$20,$19,$7E,$28,$7C,$00,$20,$1A,$26,$12,$38
	dc.b	$DD,$84,$42,$43,$16,$38,$DD,$85,$42,$44,$60,$00,$00,$3C,$30,$19
	dc.b	$08,$00,$00,$07,$66,$00,$00,$10,$02,$40,$00,$7F,$10,$F8,$DD,$84
	dc.b	$10,$C0,$60,$00,$00,$0C,$02,$40,$00,$7F,$10,$C0,$10,$F8,$DD,$84
	dc.b	$30,$C4,$30,$1B,$02,$40,$00,$FF,$30,$C0,$30,$1C,$02,$40,$00,$FF
	dc.b	$30,$C0,$52,$79,$FF,$FF,$27,$24,$51,$CB,$FF,$C4,$4E,$B9,$00,$01
	dc.b	$15,$10,$B5,$FC,$00,$00,$00,$00,$67,$00,$00,$1C,$08,$38,$00,$01
	dc.b	$DD,$80,$66,$00,$00,$12,$10,$D2,$10,$EA,$00,$01,$30,$F8,$DD,$7E
	dc.b	$52,$79,$FF,$FF,$27,$24,$4E,$75,$08,$38,$00,$05,$C3,$56,$66,$00
	dc.b	$00,$16,$30,$38,$B0,$00,$4E,$B9,$00,$01,$B6,$78,$30,$BC,$00,$00
	dc.b	$30,$38,$D3,$1A,$30,$80,$52,$78,$D3,$1A,$4E,$75

SetMenuScroll	;Write the vertical scroll: plane A 0, plane B the menu background scroll (homegoalies)
	move.w	(VSCRLPM).w,d0
	jsr	(Vmaddr).l
	move.w	#0,(a0)
	move.w	(homegoalies).w,d0
	move.w	d0,(a0)
	rts
	;Code the listing does not decode: kept as bytes
	dc.b	$23,$FC,$00,$01,$2D,$46,$FF,$FF,$D2,$44,$08,$B8,$00,$00,$BF,$B2
	dc.b	$08,$F8,$00,$02,$BF,$B2,$08,$B8,$00,$01,$BF,$B2,$31,$FC,$00,$00
	dc.b	$B0,$00,$31,$FC,$B4,$00,$B0,$02,$31,$FC,$B8,$00,$B0,$0C,$31,$FC
	dc.b	$00,$05,$B0,$0E,$31,$FC,$C0,$00,$B0,$08,$31,$FC,$00,$06,$B0,$0A
	dc.b	$31,$FC,$E0,$00,$B0,$04,$31,$FC,$00,$06,$B0,$06,$30,$3C,$00,$00
	dc.b	$08,$F8,$00,$05,$BF,$B2,$4E,$B9,$00,$01,$B5,$7E,$08,$B8,$00,$05
	dc.b	$BF,$B2,$4E,$B9,$00,$01,$B2,$C4,$38,$3C,$00,$01,$22,$7C,$00,$17
	dc.b	$E3,$FC,$4E,$B9,$00,$01,$21,$7A,$31,$C4,$B0,$1C,$24,$7C,$00,$17
	dc.b	$91,$70,$4E,$B9,$00,$01,$B7,$30,$31,$C4,$B0,$1E,$24,$7C,$00,$17
	dc.b	$A1,$6C,$4E,$B9,$00,$01,$B7,$30,$23,$FC,$00,$17,$91,$68,$FF,$FF
	dc.b	$BF,$8A,$31,$C4,$B0,$14,$24,$7C,$00,$17,$AA,$7A,$4E,$B9,$00,$01
	dc.b	$B7,$30,$08,$B8,$00,$02,$C3,$54,$33,$C4,$FF,$FF,$27,$16,$06,$44
	dc.b	$00,$19,$33,$C4,$FF,$FF,$27,$18,$06,$44,$00,$19,$33,$C4,$FF,$FF
	dc.b	$27,$1A,$06,$44,$00,$19,$33,$C4,$FF,$FF,$27,$1C,$06,$44,$00,$19
	dc.b	$33,$C4,$FF,$FF,$27,$1E,$06,$44,$00,$19,$3F,$04,$26,$7C,$00,$01
	dc.b	$2C,$DE,$22,$7C,$FF,$FF,$27,$16,$30,$39,$FF,$FF,$27,$22,$55,$40
	dc.b	$6A,$00,$00,$0E,$54,$49,$52,$40,$6A,$00,$00,$06,$54,$49,$52,$40
	dc.b	$E7,$40,$20,$7C,$FF,$FF,$27,$26,$1E,$30,$00,$00,$BE,$38,$DD,$84
	dc.b	$66,$00,$00,$06,$1E,$30,$00,$01,$BE,$7C,$00,$1A,$6C,$00,$00,$2A
	dc.b	$48,$87,$E5,$47,$24,$73,$70,$00,$50,$4A,$38,$11,$4E,$B9,$00,$01
	dc.b	$B7,$30,$B3,$FC,$FF,$FF,$27,$1E,$67,$00,$00,$0E,$E6,$40,$54,$49
	dc.b	$52,$40,$B0,$7C,$00,$53,$6F,$B8,$38,$1F,$33,$C4,$FF,$FF,$27,$12
	dc.b	$06,$44,$00,$20,$33,$C4,$FF,$FF,$27,$14,$06,$44,$00,$20,$4E,$B9
	dc.b	$00,$01,$BA,$2E,$00,$08,$FF,$01,$FD,$00,$FC,$00,$70,$28,$72,$1C
	dc.b	$34,$3C,$07,$FF,$4E,$B9,$00,$01,$B9,$76,$4E,$B9,$00,$01,$BB,$8E
	dc.b	$00,$06,$BF,$00,$00,$00,$20,$7C,$00,$17,$C2,$CE,$22,$48,$24,$48
	dc.b	$D1,$DA,$D3,$DA,$42,$40,$42,$41,$74,$28,$76,$1C,$7A,$08,$4E,$B9
	dc.b	$00,$01,$B6,$92,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$0B,$01,$00
	dc.b	$20,$7C,$00,$17,$DB,$DC,$22,$48,$24,$48,$D1,$DA,$D3,$DA,$42,$40
	dc.b	$42,$41,$34,$11,$36,$29,$00,$02,$7A,$08,$4E,$B9,$00,$01,$B6,$92
	dc.b	$3F,$38,$B0,$1C,$31,$F8,$B0,$1E,$B0,$1C,$4E,$B9,$00,$01,$BC,$72
	dc.b	$00,$24,$8F,$0C,$19,$7B,$7D,$2D,$4D,$45,$4E,$55,$20,$4F,$50,$54
	dc.b	$49,$4F,$4E,$53,$8F,$0C,$1A,$5B,$5D,$2D,$43,$48,$41,$4E,$47,$45
	dc.b	$20,$44,$41,$59,$31,$DF,$B0,$1C,$4E,$B9,$00,$01,$BB,$8E,$00,$06
	dc.b	$BF,$01,$04,$00,$42,$47,$1E,$38,$DD,$84,$7A,$02,$61,$00,$03,$2E
	dc.b	$4E,$B9,$00,$01,$BB,$8E,$00,$06,$FE,$00,$00,$00,$20,$7C,$00,$17
	dc.b	$0B,$0C,$22,$48,$24,$48,$D1,$DA,$D3,$DA,$42,$40,$42,$41,$74,$40
	dc.b	$76,$1C,$7A,$01,$4E,$B9,$00,$01,$B6,$92,$46,$FC,$25,$00,$4E,$75
	dc.b	$3F,$38,$DD,$7E,$4A,$79,$FF,$FF,$27,$22,$67,$00,$00,$10,$4E,$B9
	dc.b	$00,$01,$BE,$D6,$00,$08,$F8,$04,$01,$0D,$14,$5B,$08,$38,$00,$02
	dc.b	$DD,$80,$67,$00,$00,$24,$4E,$B9,$00,$01,$BE,$D6,$00,$08,$F8,$04
	dc.b	$01,$0E,$14,$00,$4E,$B9,$00,$01,$BE,$D6,$00,$0A,$50,$4C,$41,$59
	dc.b	$4F,$46,$46,$53,$60,$00,$00,$22,$31,$F9,$FF,$FF,$27,$20,$DD,$7E
	dc.b	$4E,$B9,$00,$01,$16,$BA,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$0E
	dc.b	$14,$00,$4E,$B9,$00,$01,$BE,$EC,$30,$39,$FF,$FF,$27,$22,$52,$40
	dc.b	$B0,$79,$FF,$FF,$27,$24,$6C,$00,$00,$0C,$4E,$B9,$00,$01,$BE,$D6
	dc.b	$00,$04,$5D,$00,$31,$DF,$DD,$7E,$4E,$75,$42,$40,$10,$38,$DD,$85
	dc.b	$67,$00,$00,$64,$53,$40,$B0,$79,$FF,$FF,$27,$22,$6D,$00,$00,$58
	dc.b	$30,$39,$FF,$FF,$27,$22,$E7,$40,$20,$7C,$FF,$FF,$27,$26,$48,$E7
	dc.b	$80,$80,$30,$30,$00,$04,$32,$3C,$00,$02,$4E,$B9,$00,$01,$BE,$1C
	dc.b	$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$1F,$14,$00,$4E,$B9,$00,$01
	dc.b	$BE,$EC,$4C,$DF,$01,$01,$30,$30,$00,$06,$32,$3C,$00,$02,$4E,$B9
	dc.b	$00,$01,$BE,$1C,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$08,$14,$00
	dc.b	$4E,$B9,$00,$01,$BE,$EC,$4E,$75,$4E,$B9,$00,$01,$BE,$D6,$00,$22
	dc.b	$F8,$04,$01,$08,$14,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$30,$39,$FF,$FF,$27,$22,$E7,$40,$20,$7C,$FF,$FF,$27,$26,$33,$F0
	dc.b	$00,$02,$FF,$FF,$27,$20,$48,$E7,$80,$80,$61,$00,$FE,$C4,$61,$00
	dc.b	$FF,$4A,$30,$38,$B0,$52,$B0,$78,$B0,$52,$67,$FA,$4C,$D7,$01,$01
	dc.b	$42,$47,$1E,$30,$00,$00,$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$17
	dc.b	$16,$00,$38,$39,$FF,$FF,$27,$12,$61,$00,$01,$64,$1E,$30,$00,$01
	dc.b	$4E,$B9,$00,$01,$BB,$8E,$00,$06,$BF,$01,$16,$00,$38,$39,$FF,$FF
	dc.b	$27,$14,$61,$00,$01,$4A,$30,$38,$B0,$52,$B0,$78,$B0,$52,$67,$FA
	dc.b	$4C,$D7,$01,$01,$61,$00,$00,$08,$4C,$DF,$01,$01,$4E,$75,$3C,$3C
	dc.b	$00,$04,$24,$7C,$FF,$FF,$27,$1E,$3A,$39,$FF,$FF,$27,$22,$54,$45
	dc.b	$08,$F8,$00,$00,$C3,$46,$30,$39,$FF,$FF,$27,$24,$53,$40,$BA,$40
	dc.b	$6F,$00,$00,$0A,$61,$00,$00,$D4,$60,$00,$00,$BA,$4A,$45,$6A,$00
	dc.b	$00,$0A,$61,$00,$00,$C6,$60,$00,$00,$AC,$38,$12,$4E,$B9,$00,$01
	dc.b	$BB,$8E,$00,$06,$BF,$00,$0E,$00,$20,$7C,$00,$01,$2B,$4A,$11,$F0
	dc.b	$60,$00,$B0,$41,$30,$05,$E7,$40,$20,$7C,$FF,$FF,$27,$26,$12,$30
	dc.b	$00,$00,$B2,$38,$DD,$84,$66,$00,$00,$06,$12,$30,$00,$01,$20,$7C
	dc.b	$00,$01,$2C,$DE,$48,$81,$E5,$41,$20,$70,$10,$00,$08,$F8,$00,$00
	dc.b	$C3,$46,$BC,$7C,$00,$04,$66,$00,$00,$14,$08,$B9,$00,$02,$FF,$FF
	dc.b	$27,$10,$67,$00,$00,$08,$08,$B8,$00,$00,$C3,$46,$4A,$46,$66,$00
	dc.b	$00,$14,$08,$B9,$00,$01,$FF,$FF,$27,$10,$67,$00,$00,$08,$08,$B8
	dc.b	$00,$00,$C3,$46,$08,$38,$00,$02,$C3,$44,$67,$00,$00,$08,$08,$B8
	dc.b	$00,$00,$C3,$46,$48,$E7,$FF,$FE,$22,$48,$24,$48,$D1,$DA,$D3,$DA
	dc.b	$42,$40,$42,$41,$74,$05,$76,$05,$7A,$04,$4E,$B9,$00,$01,$B6,$92
	dc.b	$4C,$DF,$7F,$FF,$55,$8A,$53,$45,$51,$CE,$FF,$2C,$08,$B8,$00,$00
	dc.b	$C3,$46,$4E,$75,$02,$0A,$12,$1A,$22,$FF,$48,$E7,$FF,$FE,$4E,$B9
	dc.b	$00,$01,$BB,$8E,$00,$06,$BF,$00,$0E,$00,$20,$7C,$00,$01,$2B,$4A
	dc.b	$11,$F0,$60,$00,$B0,$41,$70,$05,$72,$05,$34,$3C,$07,$FF,$00,$42
	dc.b	$80,$00,$4E,$B9,$00,$01,$B9,$76,$4C,$DF,$7F,$FF,$4E,$75

DrawSetupTeamBlock	;Draw the team block (TeamBlockPtrs) of team d7 at printx / printy (the controller setup screen)
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

DrawTeamLogoD7	;Draw the logo of team d7 at printx / printy, char d4; d5 = 0 also copies its palette to palfadenew+$40
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
