;	The replay icon and the home team graphics.

LoadReplayIcon						;Load the replay icon tiles (ReplayIconMap+8) at char d4 (ReplayIconChars)
	move.w	d4,(ReplayIconChars).w
	movea.l	#ReplayIconMap+8,a2
	jmp	DecompressGraphicsPlain

LoadHomeTeamGfx						;Load the HomeTeam graphics of TeamGfxList to VRAM d4 - $18
									;(DecompressGraphicsPlain). Called from setupice
									;and ClrHor
	move.w	d0,-(sp)
	subi.w	#$18,d4
	movea.l	#TeamGfxList,a2
	move.w	(HomeTeam).w,d0
	asl.w	#2,d0
	movea.l	(a2,d0.w),a2
	addq.w	#8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	(sp)+,d0
	rts

TeamGfxList							;The team graphics map of each team
									;(LoadHomeTeamGfx), a long pointer per team
	dc.l	$1419D2,$1465CC,$141CDC,$141FE6
	dc.l	$1422F0,$1425FA,$142904,$142C0E
	dc.l	$142F18,$143222,$14352C,$143836
	dc.l	$143B40,$143E4A,$144154,$14445E
	dc.l	$144768,$144A72,$144D7C,$145086
	dc.l	$145390,$14569A,$1459A4,$145CAE
	dc.l	$145FB8,$1462C2
