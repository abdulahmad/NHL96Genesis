;	Team record and name log I/O, record updates, goalie and player counts.

ReadTeamRecord						;Read the 16 byte team record block d1 ($D22 + d1 * 16) to a0
									;(TeamRecordIO)
	bclr	#6,(sflags6).w

TeamRecordIO						;The team record block: read or write (sflags6 bit 6)
	movem.l	d0-d1/a0-a1,-(sp)
	move.l	d1,d0
	asl.w	#4,d0
	addi.l	#$ECE,d0
	moveq	#$10,d1
	btst	#6,(sflags6).w
	beq.w	.read
	jsr	(WriteSRAM).l
	bra.w	.x
.read
	jsr	(ReadSRAM).l
.x
	movem.l	(sp)+,d0-d1/a0-a1
	rts

WriteTeamRecord						;Write the team record block (TeamRecordIO)
	bset	#6,(sflags6).w
	bra.s	TeamRecordIO

WriteNameLog						;Write the user name log ($80 bytes at namelog) to save RAM SRNameLog
	bset	#6,(sflags6).w
	bra.w	NameLogIO

ReadNameLog							;Read the user name log from save RAM SRNameLog to namelog
	bclr	#6,(sflags6).w

NameLogIO							;Read or write (sflags6 bit 6) the name log
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$80,d1
	move.l	#$F4E,d0
	movea.l	#$FFFFD32C,a0
	btst	#6,(sflags6).w
	beq.w	.read
	jsr	(WriteSRAM).l
	bra.w	.x
.read
	jsr	(ReadSRAM).l
.x
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	dc.b	$00,$00,$00,$1C,$00,$38,$00,$54,$00,$70,$00,$8C,$00,$A8,$00,$C4
	dc.b	$00,$E0,$00,$FC,$01,$18,$01,$34,$01,$50,$01,$6C,$01,$88,$01,$A4
	dc.b	$01,$C0,$01,$DC,$01,$F8,$02,$14,$02,$30,$02,$4C,$02,$68,$02,$84
	dc.b	$02,$A0,$02,$BC,$02,$D8,$02,$F4,$03,$10

UpdateRecords						;With save RAM (ValidSRAM) and user records on (OptUserRec 0), update the
									;player records (UpdatePlayerRecords), with sflags11 bit 7 the crowd
									;records of both teams (UpdateCrowdRecord), then the team record of each
									;pad (UpdateUserRecord), then the save RAM checksum
	tst.w	(ValidSRAM).w
	bmi.w	.x
	tst.w	(OptUserRec).w
	bne.w	.x
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	CountGoalies
	bsr.w	CountPlayers
	movea.l	#ThreeStars,a0
	move.w	(pad1user).w,d1
	ext.l	d1
	move.w	(pad2user).w,d2
	move.w	(HomeTeam).w,d3
	move.w	(VisTeam).w,d4
	movea.l	#tmstruct,a1
	movea.l	#AwShots,a2
	bsr.w	UpdateTeamRecord
	movea.l	#ThreeStars,a0
	move.w	(pad2user).w,d1
	ext.l	d1
	move.w	(pad1user).w,d2
	move.w	(VisTeam).w,d3
	move.w	(HomeTeam).w,d4
	movea.l	#AwShots,a1
	movea.l	#tmstruct,a2
	bsr.w	UpdateTeamRecord
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
.x
	rts

UpdateTeamRecord					;Add the game of team a1 (against a2) to team record block d1 (games,
									;wins, ties) with sflags11 bit 7 keep the
									;biggest win and loss margins with users d3 / d4 and team d2
									;(WriteTeamRecord)
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	ReadTeamRecord
	st	d7
	movem.w	d0,-(sp)
	clr.w	d0
	move.b	$A(a0),d0
	lsl.w	#8,d0
	move.b	$B(a0),d0
	cmp.w	#$2328,d0
	bge.w	.1
	addq.w	#1,d0
	move.b	d0,$B(a0)
	lsr.w	#8,d0
	move.b	d0,$A(a0)
	move.w	tmscore(a1),d0
	cmp.w	tmscore(a2),d0
	bgt.w	.0
	blt.w	.1
	clr.w	d0
	move.b	$C(a0),d0
	lsl.w	#8,d0
	move.b	$D(a0),d0
	addq.w	#1,d0
	move.b	d0,$D(a0)
	lsr.w	#8,d0
	move.b	d0,$C(a0)
	bra.w	.1
.0
	clr.w	d0
	move.b	8(a0),d0
	lsl.w	#8,d0
	move.b	9(a0),d0
	addq.w	#1,d0
	move.b	d0,9(a0)
	lsr.w	#8,d0
	move.b	d0,8(a0)
.1
	movem.w	(sp)+,d0
	movem.w	d0,-(sp)
	move.w	tmscore(a1),d0
	cmp.w	tmscore(a2),d0
	movem.w	(sp)+,d0
	ble.w	.write
	move.w	tmscore(a1),d5
	cmp.b	(a0),d5
	ble.w	.2
	st	d7
	move.b	d5,(a0)
	move.b	d3,1(a0)
	move.b	d4,2(a0)
	move.b	d2,3(a0)
.2
	move.w	tmscore(a2),d5
	move.w	(a2),d6
	sub.w	d5,d6
	cmp.b	4(a0),d6
	ble.w	.write
	st	d7
	move.b	d6,4(a0)
	move.b	d3,5(a0)
	move.b	d4,6(a0)
	move.b	d2,7(a0)
.write
	bsr.w	WriteTeamRecord
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CountGoalies						;homegoalies / awaygoalies = goalies of the home / away team
									;(GetGoalieCount)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#tmstruct,a2
	jsr	(GetGoalieCount).l
	move.w	d0,(homegoalies).w
	movea.l	#AwShots,a2
	jsr	(GetGoalieCount).l
	move.w	d0,(awaygoalies).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CountPlayers						;homeplayers / awayplayers = players of the home / away team
									;(GetPlayerCount)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#tmstruct,a2
	jsr	(GetPlayerCount).l
	move.w	d0,(homeplayers).w
	movea.l	#AwShots,a2
	jsr	(GetPlayerCount).l
	move.w	d0,(awayplayers).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

