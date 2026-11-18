;	The wall collision during a check.

wallcollduringcheck					;During a check, a skater a2 (not a goalie) near the wall: test the wall
									;at his position with his size + $17.
									;Called from CCStart and FallDown
	tst.w	$34(a2)
	beq.w	.end
	movem.l	d0-d7,-(sp)
	move.w	(a2),d2					;Xpos of checking player
	move.w	Ypos(a2),d3
	move.w	$4A(a2),(wcradiusx).w
	addi.w	#$17,(wcradiusx).l		;add $17 to wcradiusx
	move.w	$4C(a2),(wcradiusy).w
	addi.w	#$17,(wcradiusy).l		;add $17 to wcradiusy
	movem.l	a0-a6,-(sp)
	exg	a2,a3						;swap a2 and a3
	jsr	(checkcornercoll).l
	exg	a2,a3						;swap a2 and a3
	movem.l	(sp)+,a0-a6
	movem.l	(sp)+,d0-d7
.end
	rts

