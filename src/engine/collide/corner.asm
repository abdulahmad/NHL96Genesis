;	The stop with animation kept, and the corner collision.

stopfast							;Stop, keeping the animation: Xvel / Yvel toward 0 by $7D0 a frame
									;(stopna2 with a bigger step)
	tst.w	Xvel(a3)
	bpl.w	.xp
	addi.w	#$7D0,Xvel(a3)
	bmi.w	.y
	clr.w	Xvel(a3)
.xp
	subi.w	#$7D0,Xvel(a3)
	bpl.w	.y
	clr.w	Xvel(a3)
.y
	tst.w	Yvel(a3)
	bpl.w	.yp
	addi.w	#$7D0,Yvel(a3)
	bmi.w	.end
	clr.w	Yvel(a3)
.yp
	subi.w	#$7D0,Yvel(a3)
	bpl.w	.end
	clr.w	Yvel(a3)
.end
	rts

checkcornercoll						;Corner circles and side walls for object a3 at d2 / d3 (wcradiusx /
									;wcradiusy); a hit goes to end boards $128
	bclr	#pf3wall,pflags3(a3)	;wall collision bit
	move.w	#$96,d4
	sub.w	(wcradiusx).w,d4
	move.w	#$148,d5
	sub.w	(wcradiusy).w,d5
	movem.w	d2-d5,-(sp)
	neg.w	d4
	neg.w	d5
	addi.w	#$40,d4					;radius
	addi.w	#$40,d5
	cmp.w	d5,d3
	bgt.w	.ctc
	cmp.w	d4,d2
	blt.w	.circle
	neg.w	d4
	cmp.w	d4,d2
	bgt.w	.circle
	bra.w	.2
.ctc
	neg.w	d5
	cmp.w	d5,d3
	blt.w	.2
	cmp.w	d4,d2
	blt.w	.circle
	neg.w	d4
	cmp.w	d4,d2
	bgt.w	.circle
	bra.w	.2
.circle
	sub.w	d4,d2
	sub.w	d5,d3
	move.w	d3,d0					;cos0 = dy/r
	move.w	d2,d1					;sin0 = -dx/r
	neg.w	d1
	muls.w	d3,d3
	muls.w	d2,d2
	add.l	d2,d3					;dist from dot
	cmp.l	#$1000,d3
	bls.w	.2
	exg	d0,d3
	jsr	(Sroot).l
	exg	d0,d3
	ext.l	d0
	asl.l	#8,d0
	divs.w	d3,d0
	ext.l	d1
	asl.l	#8,d1
	divs.w	d3,d1
	bsr.w	cornercollb
.2
	movem.w	(sp)+,d2-d5
	move.w	$4E(a3),d0
	or.w	$50(a3),d0
	bne.w	.rtss3
	move.w	#$100,d0				;now check side walls
	clr.w	d1
	cmp.w	d5,d3
	bge.w	cornercollb
	neg.w	d5
	neg.w	d0
	cmp.w	d5,d3
	ble.w	cornercollb
	exg	d0,d1
	cmp.w	d4,d2
	bge.w	cornercollb
	neg.w	d4
	neg.w	d1
	cmp.w	d4,d2
	ble.w	cornercollb
.rtss3
	rts

cornercollb							;Straight to wallcollb
	jmp	wallcollb

