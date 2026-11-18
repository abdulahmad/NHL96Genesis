;	Run the current assignment of one player.

doassignment						;Run the current assignment of player a3 (asslist entry assnum, asstab)
									;with a2 / a1 = its team / the other
									;team (loadTeamStruct).
	move.w	assnum(a3),d0
	clr.w	d1
	move.b	asslist(a3,d0.w),d1
	asl.w	#2,d1
	movea.l	#asstab,a0
	movea.l	(a0,d1.w),a0
	jsr	(loadTeamStruct).l
	jsr	(a0)
	rts
