;	The lead song and the penalty clear.

LeadSong							;Not in a shootout (gmode2 bit 1) and one team has more players on ice
									;(tmap): once (sflags2 bit 5) ChooseSong
									;with SongIndex 1 (home) or 4, and sflags8 bit 6; sflags2 bit 6 keeps
									;which team. sflags2 is put back on exit. Called from puckfaceoff2.
	movem.l	d0/a0-a3,-(sp)
	move.w	(sflags2).w,-(sp)
	btst	#1,(gmode2).w
	bne.w	LeadSongExit
	movea.w	#(tmstruct-M68K_RAM),a2
	lea	$39E(a2),a3
	move.w	tmap(a2),d0
	sub.w	$24(a3),d0
	beq.w	LeadSongExit
	bpl.w	.1
	btst	#sf2pwrtm,(sflags2).w
	bne.w	.2
	bsr.w	ClearSongLeadFlag
	bset	#sf2pwrtm,(sflags2).w
	bra.w	.2
.1
	exg	a2,a3
	btst	#sf2pwrtm,(sflags2).w
	beq.w	.2
	bsr.w	ClearSongLeadFlag
	bclr	#sf2pwrtm,(sflags2).w
.2
	bset	#sf2pwrplay,(sflags2).w
	bne.w	LeadSongExit
	cmpa.w	#(tmstruct-M68K_RAM),a3
	bne.w	.3
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#1,(SongIndex).w
	jsr	(ChooseSong).l
.loop
	bset	#6,(sflags8).w
	bra.w	LeadSongExit
.3
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#4,(SongIndex).w
	jsr	(ChooseSong).l
	bra.s	.loop
ClearSongLeadFlag					;Clear sflags2 bit 5
	bclr	#5,(sflags2).w
	rts
LeadSongExit	equ	*	;Restore sflags2 and the registers and return
	move.w	(sp)+,(sflags2).w
	movem.l	(sp)+,d0/a0-a3
	rts

ClearPenalties						;Clear the penalties: PBnum, Penaltytimer, PenCntDwn, PenBuf and both
									;teams' penalty slots (clrTmPdst)
	movem.l	d0/a0,-(sp)
	clr.w	(PBnum).w
	clr.w	(Penaltytimer).w
	clr.w	(PenCntDwn).w
	move.w	#$10,d0
	movea.l	#$FFFFC3A6,a0
.loop
	clr.l	(a0)+
	dbf	d0,.loop
	movea.l	#tmstruct,a0
	bsr.w	clrTmPdst
	movea.l	#AwShots,a0
	bsr.w	clrTmPdst
	movem.l	(sp)+,d0/a0
	rts

clrTmPdst							;Set the 26 tmpdst words of team a0 to -2 (bench), then -1
	move.w	#$1B,d0					;19 = 25 decimal (max roster size)
	adda.w	#$6C,a0
.loop
	move.w	#$FFFE,(a0)+			;-2 = bench
	dbf	d0,.loop
	move.w	#$FFFF,(a0)
	rts
