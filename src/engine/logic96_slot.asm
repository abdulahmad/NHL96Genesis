;	Sets a slot bit.

setSlotBit							;sflags6 bit 5 (the slot) = the puck carrier is in the slot
	bclr	#5,(sflags6).w			;clears Slot Bit
	tst.w	(puckc).w
	bmi.w	.x						;exit if no puckc
	movem.l	d0/a0,-(sp)
	movea.l	#SortCords,a0			;start of SCStructs
	move.w	(puckc).w,d0			;move puckc SCnum into d0
	asl.w	#7,d0					;mult by 128 decimal
	adda.w	d0,a0					;move to start of puckc SCstruct
	move.w	Ypos(a0),d0				;Ypos
	btst	#pfgoal,pflags(a0)		;pfgoal - which goal shooting at
	bne.w	.checkpos				;jump if top goal
	neg.w	d0						;negative d0
.checkpos
	cmp.w	#$76,d0					;compare to blueline
	blt.w	.restore				;branch if not in off zone
	cmpi.w	#$51,(a0)				;compare X position to $47
	bgt.w	.restore				;branch if greater than 47
	cmpi.w	#$FFAF,(a0)				;compare X position to -$47
	blt.w	.restore				;branch if less than -47
	bset	#5,(sflags6).w			;set bit
.restore
	movem.l	(sp)+,d0/a0
.x
	rts

