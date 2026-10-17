;	The two teams at the start of a game. clearTeamStats wipes the structs, and
;	setplayercolors copies each team's colors.

clearTeamStats	;Clear both team structs, keeping the start of each hot / cold table
	move.w	(tmstruct+$26).w,-(sp)
	move.w	(AwShots+$26).w,-(sp)
	movem.l	a1-a3,-(sp)
	move.w	#$1BF,d0
	movea.l	#$FFFFCC80,a1	;Hot/Cold table Away Team
	movea.l	#$FFFFC8E2,a0	;Hot/Cold table Home Team
	movea.l	#$FFFFD494,a2
	movea.l	#$FFFFD654,a3
.loop
	move.b	(a0)+,(a2)+
	move.b	(a1)+,(a3)+
	dbf	d0,.loop
	movem.l	(sp)+,a1-a3
	move.l	#$39D,d0
	movea.w	#(tmstruct-M68K_RAM),a0
.loop2
	clr.b	(a0)+
	dbf	d0,.loop2
	movea.w	#(AwShots-M68K_RAM),a0
	move.w	#$39D,d0
.loop3
	clr.b	(a0)+
	dbf	d0,.loop3
	movem.l	a1-a3,-(sp)
	move.w	#$1BF,d0
	movea.l	#$FFFFCC80,a1
	movea.l	#$FFFFC8E2,a0
	movea.l	#$FFFFD494,a2
	movea.l	#$FFFFD654,a3
.loop4
	move.b	(a2)+,(a0)+
	move.b	(a3)+,(a1)+
	dbf	d0,.loop4
	movem.l	(sp)+,a1-a3
	move.w	(sp)+,(AwShots+$26).w
	move.w	(sp)+,(tmstruct+$26).w
	st	(tmstruct+$A4).w
	st	(AwShots+$A4).w

setteams	;Use HomeTeam / VisTeam to set team structures (InitTeamStructure for each). Falls in from clearTeamStats
	movem.l	d0/a0-a2,-(sp)
	movea.w	#(tmstruct-M68K_RAM),a2
	move.w	(HomeTeam).w,d0
	move.w	#$B05E,$22(a2)
	bsr.w	InitTeamStructure
	movea.w	#(AwShots-M68K_RAM),a2
	move.w	(VisTeam).w,d0
	move.w	#$B35E,$22(a2)
	bsr.w	InitTeamStructure
	movem.l	(sp)+,d0/a0-a2
	rts

InitTeamStructure	;Set up team struct a2 for team d0: the team number at $28 and the team data address
	move.w	d0,$28(a2)
	movea.w	#TeamList,a0
	asl.w	#2,d0
	move.l	(a0,d0.w),$1E(a2)

SetOriginalLines	;The line sets of team struct a2 from GetTeamLines: with OptLine sets 0 and 2-7, else sets 1-7. The
	;"Set Original lines" item of the line menus
	tst.w	(OptLine).w
	beq.w	.0
	move.w	d7,-(sp)
	move.w	$28(a2),d7
	jsr	(GetTeamLines).l
	move.w	(sp)+,d7
	lea	$184(a2),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	addq.w	#8,a0
	move.w	#$B,d0
.loop
	move.l	(a0)+,(a1)+
	dbf	d0,.loop
	bsr.w	SetGoalieFromLines
	rts
.0
	moveq	#$D,d0
	move.w	d7,-(sp)
	move.w	$28(a2),d7
	jsr	(GetTeamLines).l
	move.w	(sp)+,d7
	addq.w	#8,a0
	lea	$184(a2),a1
.loop2
	move.l	(a0)+,(a1)+
	dbf	d0,.loop2
	bsr.w	SetGoalieFromLines
	rts

SetGoalieFromLines	;tmgoalie of team a2 = the first byte of its line sets ($184) - 1
	move.w	d0,-(sp)
	clr.w	d0
	move.b	$184(a2),d0
	subq.w	#1,d0
	move.w	d0,$26(a2)
	move.w	(sp)+,d0
	rts

setplayercolors	;Copy in correct color data for each team: .team for the home team, then falls in for the visitors. Called
	;from setupice and others
	clr.w	d1
	movea.w	#(tmstruct-M68K_RAM),a0
	bsr.w	.team
	moveq	#$20,d1
	adda.w	#$39E,a0
.team
	movea.l	$1E(a0),a2
	adda.w	2(a2),a2	;Palettedata
	adda.w	d1,a2
	movea.w	#(palfadenew+$40-M68K_RAM),a1
	adda.w	d1,a1
	moveq	#7,d0
.loop
	move.l	(a2)+,(a1)+
	dbf	d0,.loop
	rts

