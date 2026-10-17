;	The playoff seeding. ScoutingReport is an rts. ResolveDayGames scores the day's series.
;	BeginPlayoffs and InitPlayoffs seed the conferences, and SetupPlayoffs writes the bracket
;	into the save RAM.

ScoutingReport	;The pre-game scouting report: an empty rts in 96
	rts

ResolveDayGames	;Compute winners and losers for the playoff matchups of the day: the series wins (gsstruct),
	;WinBits and gamelevel when the round is over; at gamelevel 4 the final flags in SeasonDay, else
	;maketree; then the save RAM write
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	(rosterscroll).w
	jsr	(GetShifter).l
	movea.l	#gsstruct,a0
	moveq	#$10,d3
	mulu.w	d1,d3
	adda.w	d3,a0
	cmpi.w	#7,(bosgames).w
	beq.w	.notbos
.loop
	cmpi.w	#4,4(a0)
	beq.w	.b1
	cmpi.w	#4,6(a0)
	beq.w	.b1
	st	(rosterscroll).w
	clr.w	d3
	btst	#0,$E(a0)
	beq.w	.0
	eori.w	#2,d3
.0
	move.w	$A(a0),d0
	sub.w	$C(a0),d0
	bpl.w	.win
	eori.w	#2,d3
.win
	addq.w	#1,4(a0,d3.w)
.b1
	suba.w	#$10,a0
	dbf	d1,.loop
	addq.w	#1,(bosgames).w
	cmpi.w	#7,(bosgames).w
	beq.w	.1
	tst.w	(rosterscroll).w
	beq.w	.1
	bra.w	.4
.1
	clr.w	(bosgames).w
	jsr	(GetShifter).l
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
	bra.w	.4
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
.4
	cmpi.w	#4,(gamelevel).w
	bne.w	.7
	bset	#1,(SeasonFlags).w
	movem.l	d0/a0-a1,-(sp)
	movea.l	#$FFFFDCF8,a0
	lea	2(a0),a1
	move.b	2(a1),d0
	cmp.b	3(a1),d0
	bgt.w	.5
	addq.w	#1,a1
.5
	move.b	(a1),d0
	bclr	#3,(SeasonFlags).w
	cmp.b	(dword_FFDD82+2).w,d0
	bne.w	.6
	bset	#3,(SeasonFlags).w
.6
	movem.l	(sp)+,d0/a0-a1
	bra.w	.8
.7
	jsr	(maketree).l
.8
	movea.w	#(pwddatabuffer-M68K_RAM),a3
	jsr	(WritePassBits).l
	jsr	(WritePassData).l
	bclr	#4,(sflags).w
	move.w	#$FFFF,(lastsfx).w
	move.l	#M68K_RAM,(recbpr).w
	jsr	(WriteDayGames).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

BeginPlayoffs	;Seed the playoffs with sflags11 bit 0 (the pairings to POPairingsTmp), SetupPlayoffs, then seed them to save RAM
	;(InitPlayoffs again); GameFlags bit 6 holds the checksum until the end
	bset	#6,(GameFlags).w
	bset	#0,(sflags11).w
	bsr.w	InitPlayoffs
	bclr	#0,(sflags11).w
	btst	#1,(sflags11).w
	bsr.w	SetupPlayoffs
	bsr.w	InitPlayoffs
	jsr	(maketree).l
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	rts

InitPlayoffs	;Seed the playoffs: the two conferences (ConferenceTeams1 / 2) sorted by points (SortSeeds), the pairings
	;to save RAM SRPOPairings and SRPOSlots (BuildPOSlots). With sflags11 bit 0 the pairings go to POPairingsTmp
	;instead, and sflags11 bit 1 is set when the team in dword_FFDD82+2 is not in them
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$B,d0
	movea.l	#AwardIds,a0
	movea.l	#ConferenceTeams1,a1
	bsr.w	CopyBytes
	move.w	#$D,d0
	movea.l	#AwardIds+$14,a0
	movea.l	#ConferenceTeams2,a1
	bsr.w	CopyBytes
	movea.l	#SeedStandings,a0
	jsr	(ReadStandings).l
	bsr.w	CalcSeedPoints
	move.w	#$C,(SeedCount).l
	movea.l	#AwardIds,a0
	bsr.w	SortSeeds
	move.w	#$E,(SeedCount).l
	movea.l	#AwardIds+$14,a0
	bsr.w	SortSeeds
	movea.l	#SaveRAM+SRPOPairings,a0
	btst	#0,(sflags11).w
	beq.w	.0
	movea.l	#POPairingsTmp,a0
.0
	movea.l	#AwardIds,a1
	bsr.w	SeedPairings
	adda.l	#$10,a0
	movea.l	#AwardIds+$14,a1
	bsr.w	SeedPairings
	btst	#0,(sflags11).w
	beq.w	.3
	bset	#1,(sflags11).w
	movea.l	#POPairingsTmp,a0
	move.b	(dword_FFDD82+2).w,d1
	move.w	#$F,d0
.1
	cmp.b	1(a0),d1
	bne.w	.2
	bclr	#1,(sflags11).w
.2
	tst.w	(a0)+
	dbf	d0,.1
	bra.w	.4
.3
	bsr.w	BuildPOSlots
	jsr	(MakeSRAMChecksum).l
.4
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SeedPairings	;Write the pairings of the sorted conference a1 to a0: the top team, the first team of another division
	;(TeamDivisions), then the rest in order
	movea.l	#TeamDivisions,a2
	clr.w	d0
	move.b	(a1)+,d0
	move.b	d0,3(a0)
	move.b	(a2,d0.w),d1
	clr.w	d2
.0
	move.b	(a1,d2.w),d0
	cmp.b	(a2,d0.w),d1
	bne.w	.1
	addq.w	#1,d2
	bra.s	.0
.1
	move.b	d0,$F(a0)
	move.b	d0,d1
.2
	move.b	(a1)+,d0
	cmp.b	d0,d1
	beq.s	.2
	move.b	d0,$B(a0)
.3
	move.b	(a1)+,d0
	cmp.b	d0,d1
	beq.s	.3
	move.b	d0,7(a0)
.4
	move.b	(a1)+,d0
	cmp.b	d0,d1
	beq.s	.4
	move.b	d0,5(a0)
.5
	move.b	(a1)+,d0
	cmp.b	d0,d1
	beq.s	.5
	move.b	d0,9(a0)
.6
	move.b	(a1)+,d0
	cmp.b	d0,d1
	beq.s	.6
	move.b	d0,$D(a0)
.7
	move.b	(a1)+,d0
	cmp.b	d0,d1
	beq.s	.7
	move.b	d0,1(a0)
	rts

TeamDivisions	;The division of each team (SeedPairings)
	dc.b	0,2,2,0,1,1,1,0,3,2,0,2,3,3,3,2,3,2,2,0,1,3,1,0,3,1

SortSeeds	;Bubble sort the SeedCount team bytes at a0 by SeedPoints, then SeedGames, highest first
	movea.l	#SeedPoints,a1
	movea.l	#SeedGames,a2
	move.w	d1,-(sp)
.pass
	bclr	#6,(sflags6).w
	clr.w	d7
.cmp
	clr.w	d6
	move.b	(a0,d7.w),d6
	clr.w	d0
	move.b	(a1,d6.w),d0
	move.b	1(a0,d7.w),d6
	clr.w	d1
	move.b	(a1,d6.w),d1
	cmp.w	d1,d0
	bgt.w	.next
	blt.w	.swap
	move.b	(a0,d7.w),d6
	move.b	(a2,d6.w),d0
	move.b	1(a0,d7.w),d6
	cmp.b	(a2,d6.w),d0
	bge.w	.next
.swap
	bset	#6,(sflags6).w
	move.b	(a0,d7.w),d5
	move.b	1(a0,d7.w),d4
	move.b	d5,1(a0,d7.w)
	move.b	d4,(a0,d7.w)
.next
	addq.w	#2,d7
	cmp.w	(SeedCount).l,d7
	bge.w	.4
	subq.w	#1,d7
	bra.s	.cmp
.4
	btst	#6,(sflags6).w
	bne.s	.pass
	move.w	(sp)+,d1
	rts

CalcSeedPoints	;SeedPoints = 2 * wins + ties and SeedGames = wins of the teams (SeedStandings)
	move.w	#$1A,d0
	movea.l	#SeedStandings,a1
	movea.l	#SeedPoints,a2
	movea.l	#SeedGames,a3
	clr.w	d2
	move.w	d1,-(sp)
	bra.w	.1
.0
	move.w	d2,d5
	mulu.w	#3,d5
	clr.w	d3
	move.b	(a1,d5.w),d3
	add.w	d3,d3
	clr.w	d1
	move.b	1(a1,d5.w),d1
	add.w	d1,d3
	move.b	d3,(a2,d2.w)
	clr.w	d3
	move.b	(a1,d5.w),d3
	move.b	d3,(a3,d2.w)
	addq.w	#1,d2
.1
	dbf	d0,.0
	move.w	(sp)+,d1
	rts

CopyBytes	;Copy d0 + 1 bytes from a1 to a0
	move.b	(a1)+,(a0)+
	dbf	d0,CopyBytes
	rts

ConferenceTeams1	;The teams of the first conference
	dc.b	ANH,CGY,EDM,LA,SJ,VAN,CHI,DAL,DET,STL,TOR,WPG

ConferenceTeams2	;The teams of the second conference
	dc.b	BOS,BUF,HFD,MTL,OTW,PIT,QUE,FLA,NJ,NYI,NYR,PHI,TB,WSH

SetupPlayoffs	;Start the playoffs: save the season header (SRSeasonHeaderSave) and clear it, clear save RAM blocks (ClearSRAMBytes),
	;OptPlayMode 1
	movem.l	d0-d7/a0-a6,-(sp)
	bset	#6,(GameFlags).w
	move.b	(SeasonDay+3).w,-(sp)
	move.b	(dword_FFDD82).w,-(sp)
	move.b	(dword_FFDD82+1).w,-(sp)
	move.b	(dword_FFDD82+2).w,-(sp)
	movea.l	#SaveRAM+SRSeasonHeader,a0
	movea.l	#SaveRAM+SRSeasonHeaderSave,a1
	move.w	#$C,d0
	subq.w	#1,d0
.save
	move.w	(a0)+,(a1)+
	dbf	d0,.save
	movea.l	#SaveRAM+SRSeasonHeader,a0
	clr.l	(a0)
	jsr	(ReadSeasonHeader).l
	bset	#2,(SeasonFlags).w
	move.b	(sp)+,(dword_FFDD82+2).w
	move.b	(sp)+,(dword_FFDD82+1).w
	move.b	(sp)+,(dword_FFDD82).w
	move.b	(sp)+,(SeasonDay+3).w
	clr.b	(dword_FFDD82+3).w
	jsr	(WriteSeasonHeader).l
	move.l	#$CBF,d0
	move.w	#$54,d1
	jsr	(ClearSRAMBytes).l
	move.l	#$D13,d0
	move.w	#$54,d1
	jsr	(ClearSRAMBytes).l
	move.l	#$D67,d0
	move.w	#$15,d1
	jsr	(ClearSRAMBytes).l
	move.l	#$D7C,d0
	move.w	#$18,d1
	jsr	(ClearSRAMBytes).l
	move.l	#$89,d0
	move.l	#$6C0,d1
	jsr	(ClearSRAMBytes).l
	jsr	(ClearFreeAgentStats).l
	moveq	#$4D,d0
	moveq	#$A,d1
	jsr	(ClearSRAMBytes).l
	move.w	#1,(OptPlayMode).w
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

RestoreSeasonHeader	;Put back the season header saved by SetupPlayoffs. Nothing calls it.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$20,$7C,$00,$20,$00,$82,$22,$7C,$00,$20,$00,$CE
	dc.b	$30,$3C,$00,$0C,$53,$40,$30,$D9,$51,$C8,$FF,$FC,$4E,$B9,$00,$01
	dc.b	$14,$9E,$4E,$B9,$00,$02,$41,$AA,$4C,$DF,$7F,$FF,$4E,$75

GetTeamPOSlot	;d7 = the seed slot of team d7 (save RAM SRPOSlots)
	move.l	a0,-(sp)
	movea.l	#SaveRAM+SRPOSlots,a0
	add.w	d7,d7
	move.w	(a0,d7.w),d7
	ext.w	d7
	movea.l	(sp)+,a0
	rts

GetPOSlotTeam	;d7 = the team in seed slot d7 (save RAM SRPOPairings)
	move.l	a0,-(sp)
	movea.l	#SaveRAM+SRPOPairings,a0
	add.w	d7,d7
	move.w	(a0,d7.w),d7
	ext.w	d7
	movea.l	(sp)+,a0
	rts

BuildPOSlots	;Save RAM SRPOSlots from SRPOPairings: the seed slot of each team
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#SaveRAM+SRPOPairings,a0
	movea.l	#SaveRAM+SRPOSlots,a1
	move.w	#$F,d1
.0
	move.w	d1,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d2
	ext.w	d2
	add.w	d2,d2
	move.b	d1,1(a1,d2.w)
	dbf	d1,.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

