;	How many skaters a team has. GetGoalieCount and GetPlayerCount read the save RAM,
;	or the roster when the teams are not from the save. WaitVSyncAndReadInput waits
;	for a new button on the menu pad.

GetGoalieCountD7					;d0 = goalies on team d7: the low 2 bits of byte 3 of its save RAM
									;SRTeamCounts entry, or 2 with sflags11 bit 4
	movem.l	d1/d7-a0,-(sp)
	btst	#4,(sflags11).w
	bne.w	.1
	movea.l	#SaveRAM+SRTeamCounts,a0
	mulu.w	#4,d7
	clr.w	d0
	move.b	3(a0,d7.w),d0
	andi.w	#3,d0
.0
	movem.l	(sp)+,d1/d7-a0
	rts
.1
	move.w	#2,d0
	bra.s	.0

GetGoalieCount						;d0 = goalies on team a2 (GetGoalieCountD7 with d7 = the team number)
	movem.l	d1/d7-a0,-(sp)
	move.w	$28(a2),d7
	bsr.s	GetGoalieCountD7
	movem.l	(sp)+,d1/d7-a0
	rts

GetPlayerCountD7					;d0 = players on team d7: byte 1 of its save RAM SRTeamCounts entry, or
									;with sflags11 bit 4 from the roster in TeamList (records until a length
									;word of 2)
	movem.l	d7-a0,-(sp)
	btst	#4,(sflags11).w
	bne.w	.2
	movea.l	#SaveRAM+SRTeamCounts,a0
	mulu.w	#4,d7
	clr.w	d0
	move.b	1(a0,d7.w),d0
.0
	movem.l	(sp)+,d7-a0
	rts
.2
	movea.l	#TeamList,a0
	asl.w	#2,d7
	movea.l	(a0,d7.w),a0
	adda.w	(a0),a0
	clr.w	d0
.1
	addq.w	#1,d0
	adda.w	(a0),a0
	addq.w	#8,a0
	cmpi.w	#2,(a0)
	bne.s	.1
	bra.s	.0

GetPlayerCount						;d0 = players on team a2 (GetPlayerCountD7 with d7 = the team number)
	movem.l	d7-a0,-(sp)
	move.w	$28(a2),d7
	bsr.s	GetPlayerCountD7
	movem.l	(sp)+,d7-a0
	rts

WaitVSyncAndReadInput				;Wait for the next vblank, read the menu pad (ReadMenuJoy) until a new
									;button press.
									;Code the listing does not decode: kept as bytes
	dc.b	$32,$38,$B0,$52,$B2,$78,$B0,$52,$67,$FA,$61,$00,$04,$C8,$61,$00
	dc.b	$5A,$E4,$4A,$01,$67,$EA,$4E,$75

