;	Whether a goalie is in its crease.

GoalieInCrease						;Z set when player a3 is in its crease: x within $17 of the middle, y
									;$100-$126 from the middle at its
									;end (pflags bit 7: the other end). Called from goalieacc
	cmpi.w	#$17,(a3)
	bgt.w	.1
	cmpi.w	#$FFE9,(a3)
	blt.w	.1
	btst	#pfgoal,pflags(a3)
	bne.w	.checkbottom
	cmpi.w	#$126,Ypos(a3)
	bgt.w	.1
	cmpi.w	#$100,Ypos(a3)
	blt.w	.1
	bra.w	.0
.checkbottom
	cmpi.w	#$FEDA,Ypos(a3)
	blt.w	.1
	cmpi.w	#$FF00,Ypos(a3)
	bgt.w	.1
.0
	movem.w	d0,-(sp)
	move.w	#0,d0
	bra.w	.2
.1
	movem.w	d0,-(sp)
	move.w	#1,d0
.2
	movem.w	(sp)+,d0
	rts
