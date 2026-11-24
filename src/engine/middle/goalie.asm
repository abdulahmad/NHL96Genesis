;	ReadGoaliePulled.

ReadGoaliePulled					;Z clear when the team of a3 pulled its goalie ($26 of the team struct).
									;Called from doshot, assdefo asspuckc
									;and assnearest
	movem.l	a1,-(sp)
	movea.l	#tmstruct,a1
	btst	#pfteam,pflags(a3)
	beq.w	.0
	movea.l	#AwShots,a1
.0
	tst.w	tmgoalie(a1)
	movem.l	(sp)+,a1
	rts
