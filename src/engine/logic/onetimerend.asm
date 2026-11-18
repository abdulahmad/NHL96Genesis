;	EndOneTimer.

EndOneTimer							;End a one-timer for a3: the one-timer bits cleared, onetimerplayer = -1,
									;SetSPA $856
	movem.l	d0/a0,-(sp)
	bclr	#pf3onetimer,pflags3(a3)
	bclr	#pfalock,pflags(a3)
	bclr	#pf2aip,pflags2(a3)
	clr.w	(onetimerflags).w
	st	(onetimerplayer).w
	move.w	d1,-(sp)
	move.w	#SPAglide,d1			;SPA
	jsr	(SetSPA).l
	tst.w	$34(a3)
	bpl.w	.0
	jsr	(assexit).l
	bra.w	.1
.0
	jsr	(AssignBySavedPos).l
.1
	clr.w	$5A(a3)
	st	$5C(a3)
	move.w	(sp)+,d1
	movem.l	(sp)+,d0/a0
	rts
