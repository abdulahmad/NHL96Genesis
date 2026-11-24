;	The one-timer. The shot height, the pass, the target and the animation.

puckvzadj							;Set puckvz for a top shelf shot from the distance to the goal line ($11E)
									;over puckvy, at most $7FFF.
									;Gravity skillspeed (skillspeedpal with PalMode). Called from doshot
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(pucky).w,d0
	bpl.w	.0
	neg.w	d0
.0
	subi.w	#$11E,d0
	bpl.w	.1
	neg.w	d0
.1
	swap	d0
	andi.l	#$FFFF0000,d0
	move.w	(puckvy).w,d1
	beq.w	.7
	bpl.w	.2
	neg.w	d1
.2
	move.w	(skillspeed).w,d2
	tst.w	(PalMode).w
	beq.w	.3
	move.w	(skillspeedpal).w,d2
.3
	divu.w	d1,d0
	andi.l	#$FFFF,d0
	divu.w	d2,d0
	tst.w	d0
	bne.w	.4
	move.w	#1,d0
.4
	move.l	#$A0000,d1
	move.w	d0,d3
	mulu.w	d2,d0
	divu.w	d0,d1
	move.w	d2,d4
	add.w	d2,d2
	add.w	d4,d2
	mulu.w	d3,d2
	cmp.l	#$7FFF,d2
	blt.w	.5
	move.w	#$7FFF,d2
.5
	add.w	d2,d1
	tst.w	d1
	bpl.w	.6
	move.w	#$7FFF,d1
.6
	move.w	d1,(puckvz).w
.7
	movem.l	(sp)+,d0-d7/a0-a6
	rts

OneTimerPass						;One-timer pass: puckvz = sqrt(12 * onetimerheight), then puckvx / puckvy
									;toward the target onetimertargetx /
									;onetimertargety in puckvz / 3 frames
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$C,d0
	move.w	(onetimerheight).w,d1
	mulu.w	d1,d0
	swap	d0
	andi.l	#$FFFF0000,d0
	jsr	(Sroot).l
	move.w	d0,(puckvz).w
	ext.l	d0
	move.w	#3,d4
	divu.w	d4,d0
	clr.l	d1
	move.w	(onetimertargetx).w,d1
	sub.w	(puckx).w,d1
	swap	d1
	tst.w	d0
	bne.w	.0
	move.w	#1,d0
.0
	divs.w	d0,d1
	move.w	d1,(puckvx).w
	clr.l	d1
	move.w	(onetimertargety).w,d1
	sub.w	(pucky).w,d1
	swap	d1
	divs.w	d0,d1
	move.w	d1,(puckvy).w
	movea.l	#puckx,a3
	move.w	(puckvz).w,d0
	jsr	(puckflip).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

OneTimerTarget						;One-timer pass target for receiver a3: an offset by facing from
									;OneTimerNearTbl / OneTimerFarTbl (skater,
									;near or far from the goal) or OneTimerGoalieTbl, plus a random 0-9 on
									;each axis
	movem.l	d0-d7/a0-a6,-(sp)
	bclr	#2,(sflags6).w
	tst.w	position(a3)
	bne.w	.0
	movea.l	#OneTimerGoalieTbl,a0
	bra.w	.2
.0
	move.w	Ypos(a3),d0
	btst	#pfgoal,pflags(a3)
	bne.w	.1
	neg.w	d0
.1
	bset	#2,(sflags6).w
	movea.l	#OneTimerNearTbl,a0
	cmp.w	#$76,d0
	blt.w	.2
	movea.l	#OneTimerFarTbl,a0
	bclr	#2,(sflags6).w
.2
	move.w	facedir(a3),d0
	btst	#pfgoal,pflags(a3)
	bne.w	.3
	addq.w	#4,d0
	andi.w	#7,d0
.3
	asl.w	#2,d0
	move.w	(a0,d0.w),d1
	move.w	2(a0,d0.w),d2
	cmpa.l	#OneTimerFarTbl,a0
	bne.w	.6
	move.w	Ypos(a3),d0
	bpl.w	.4
	neg.w	d0
.4
	cmp.w	#$A8,d0
	blt.w	.6
	move.w	(a3),d0
	bpl.w	.5
	neg.w	d0
.5
	cmp.w	#$37,d0
	bgt.w	.6
	move.w	#$119,d2
.6
	btst	#pfgoal,pflags(a3)
	bne.w	.7
	neg.w	d1
	neg.w	d2
.7
	move.w	#$A,d0
	jsr	(randomd0).l
	add.w	d0,d1
	move.w	#$A,d0
	jsr	(randomd0).l
	add.w	d0,d2
	move.w	d1,(onetimertargetx).w
	tst.w	position(a3)
	beq.w	.9
	sub.w	(a3),d1
	bmi.w	.8
	subi.w	#$3C,d1
	bpl.w	.9
	neg.w	d1
	add.w	d1,(onetimertargetx).w
	bra.w	.9
.8
	addi.w	#$3C,d1
	bmi.w	.9
	sub.w	d1,(onetimertargetx).w
.9
	move.w	d2,(onetimertargety).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

OneTimerNearTbl						;OneTimerTarget target offsets (x, y) by facing, receiver near the goal
	dc.w	110,216,110,216,110,216,110,216
	dc.w	-110,216,-110,216,-110,216,-110,216

OneTimerFarTbl						;OneTimerTarget target offsets (x, y) by facing, receiver far from the
									;goal
	dc.w	-5,197,-5,197,-5,197,-5,197
	dc.w	-5,197,-5,197,-5,197,-5,197

OneTimerGoalieTbl					;OneTimerTarget target offsets (x, y) by facing, goalie
	dc.w	-5,-31,50,-31,50,-31,50,-31
	dc.w	-5,-31,-50,-31,-50,-31,-50,-31

assonetimer							;Assignment $23 (asstab), player a3 shooting a
									;one-timer: take control of him.
	bclr	#pfna,pflags(a3)		;pfna - clear new assignment
	beq.w	.5						;branch if not new assignment
	bset	#pf3onetimer,pflags3(a3)	;set one timer bit
	bne.w	.5						;branch if already set
	move.w	#$2D,(replaydelay+2).w
	bclr	#0,(onetimerflags).w
	bclr	#5,(sflags8).w
	clr.w	(onetimerflags).w
	clr.w	(onetimerplayer+2).w
	st	(passplayer).w
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	SCnum(a3),d0			;move a3 SCnum into d0
	move.w	d0,(onetimerplayer).w	;move d0
	btst	#pfjoycon,pflags(a3)	;check if joystick controlled
	bne.w	.4						;branch if so
	tst.w	(inputjoy).w			;check input controller (95: the pad number 0 / 2 / 4 / 6 of the passer)
	bmi.w	.4						;branch if minus (no control)
	beq.w	.1						;pad 1
	cmpi.w	#2,(inputjoy).w
	beq.w	.2
	cmpi.w	#4,(inputjoy).w
	beq.w	.3
	jsr	(setc4player).l				;each pad takes the shooter itself (94 swapped pads 3 / 4 into 1 / 2)
	bra.w	.4
.1
	jsr	(setc1player).l
	bra.w	.4
.2
	jsr	(setc2player).l
	bra.w	.4
.3
	jsr	(setc3player).l
	bra.w	.4						;*+4
.4
	move.w	d0,-(sp)
	bsr.w	setonetimeranim			;sets the one timer animation
	clr.w	SPAnum(a3)				;clear SPAnum
	jsr	(SetSPA).l
	bset	#pfalock,pflags(a3)		;lock animation
	bset	#pf2aip,pflags2(a3)		;set anim in progress
	move.w	(sp)+,d0
	movem.l	(sp)+,d0-d7/a0-a6
	bra.w	.30
.5
	btst	#0,(onetimerflags).w	;check if shot initiated
	bne.w	.10						;branch if set
	movem.w	d0-d1,-(sp)				;push to stack
	move.w	(puckx).w,d0			;move puckx to d0
	sub.w	(a3),d0					;sub Xpos from d0
	cmp.w	#$3C,d0					;'<'   ; compare diff to 3C (60 pixels)
	bgt.w	.6						;branch if greater than
	cmp.w	#$FFC4,d0				;compare to -60 pixels
	bgt.w	.7						;branch if greater than
.6
	move.w	(puckvx).w,d1			;move puckvx into d1
	eor.w	d1,d0					;EOR d1 with d0
	bmi.w	.7						;branch if minus
.loop
	movem.w	(sp)+,d0-d1				;pop from stack d0 and d1
	bra.w	.11
.7
	move.w	(pucky).w,d0			;move pucky into d0
	sub.w	Ypos(a3),d0				;sub Ypos from d0
	cmp.w	#$3C,d0					;'<'   ; compare diff to 60 pix
	bgt.w	.8						;branch if greater than
	cmp.w	#$FFC4,d0				;check with -60 pix
	bgt.w	.9						;branch if greater than
.8
	move.w	(puckvy).w,d1			;move puckvy into d0
	eor.w	d1,d0					;EOR d1 with d0
	bpl.s	.loop					;branch if positive
.9
	movem.w	(sp)+,d0-d1				;pop d0 and d1 from stack
.10
	tst.w	(puckc).w				;check if puck carrier
	bmi.w	.12						;branch if no puck carrier
.11
	bclr	#7,(sflags8).w			;clear bit 7
	bra.w	.29
.12
	btst	#gmclock,(gmode).w		;check if game clock
	bne.w	.29						;branch if clock stopped
	movem.l	d0-d1,-(sp)				;push to stack
	btst	#3,(GameFlags).w
	bne.w	.26
	cmpi.w	#$10,SPAnum(a3)			;compare 10 to SPAnum
	bge.w	.21						;branch if greater than or equal
	btst	#2,(onetimerflags).w	;check bit 2
	bne.w	.21						;branch if set
	move.w	(a3),d0					;move Xpos into d0
	move.w	(puckx).w,d1			;move puckx into d1
	sub.w	d1,d0					;sub d1 from d0
	bpl.w	.13						;branch if positive
	neg.w	d0						;negate d0
.13
	move.w	Ypos(a3),d1				;move Ypos into d1
	move.w	(pucky).w,d2			;move pucky into d2
	sub.w	d2,d1					;sub d2 from d1
	bpl.w	.14						;branch if positive
	neg.w	d1						;negate d1
.14
	move.w	(puckvx).w,d2			;move puckvx into d2
	beq.w	.15						;branch if d2 is 0
	cmp.w	d0,d1					;compare d0 to d1
	ble.w	.16						;branch if less than or equal
.15
	move.w	(puckvy).w,d2
	move.w	d1,d0
.16
	swap	d0
	andi.l	#$FFFF0000,d0
	tst.w	d2
	bpl.w	.17
	neg.w	d2
.17
	move.w	(skillspeed).w,d1
	tst.w	(PalMode).w
	beq.w	.18
	move.w	(skillspeedpal).w,d1
.18
	tst.w	d2
	bne.w	.19
	move.w	#1,d2
.19
	divu.w	d2,d0
	andi.l	#$FFFF,d0
	divu.w	d1,d0
	move.w	SPAnum(a3),d2
	lsr.w	#2,d2
	subq.w	#6,d2
	neg.w	d2
	asl.w	#2,d2
	cmp.w	d2,d0
	bgt.w	.20
	neg.w	SPAnum(a3)
	addi.w	#$18,SPAnum(a3)
	bra.w	.24
.20
	add.w	d7,(onetimerplayer+2).w
	bra.w	.22
.21
	bset	#2,(onetimerflags).w
	btst	#1,(onetimerflags).w
	bne.w	.22
	cmpi.w	#$18,SPAnum(a3)
	bne.w	.22
	addi.w	#$30,SPAcnt(a3)
	bset	#1,(onetimerflags).w
.22
	btst	#1,(onetimerflags).w
	beq.w	.23
	cmpi.w	#$18,SPAnum(a3)
	ble.w	.23
	btst	#0,(onetimerflags).w
	bne.w	.23
	movem.l	(sp)+,d0-d1
	bra.w	.29
.23
	btst	#0,(onetimerflags).w
	beq.w	.24
	cmpi.w	#$18,SPAnum(a3)
	bne.w	.24
	cmpi.w	#1,SPAcnt(a3)
	ble.w	.24
	move.w	#1,SPAcnt(a3)
.24
	btst	#pf2aip,pflags2(a3)
	bne.w	.25
	movem.l	(sp)+,d0-d1
	bra.w	.28
.25
	move.w	SPAnum(a3),d0
.26
	movem.l	(sp)+,d0-d1
	btst	#0,(onetimerflags).w
	beq.w	.27
	bclr	#pfalock,pflags(a3)
	bra.w	.28
.27
	nop
	btst	#3,(GameFlags).w
	beq.w	.28
	tst.w	(replaydelay+2).w
	bmi.w	.28
	subq.w	#1,(replaydelay+2).w
	bra.w	.30
.28
	btst	#pf2aip,pflags2(a3)
	bne.w	.30
.29
	jsr	(EndOneTimer).l
.30
	rts

setonetimeranim						;The one-timer animation: d1 = $856 or $11BA from the angle to the goal
									;(vtoa, CheckOneTimerFacing).
	btst	#3,(GameFlags).w
	beq.w	.1
	move.w	#$856,d1
	bra.w	.3
.1
	move.w	#SPAshotf,d1			;94 $7FC
	movem.w	d0-d1,-(sp)				;push to stack d0 and d1
	move.w	(a3),d0					;move XPos of a3 into d0
	neg.w	d0						;negate d0
	move.w	#$11E,d1
	btst	#pfgoal,pflags(a3)		;check which goal shooting at
	bne.w	.2						;branch if top
	neg.w	d1						;negate d1
.2
	sub.w	Ypos(a3),d1				;sub Ypos from d1
	jsr	(vtoa).l
	jsr	(CheckOneTimerFacing).l		;Z from Findhittype
	movem.w	(sp)+,d0-d1				;pop from stack d0 and d1
	beq.w	.3
	move.w	#SPAshotb,d1			;94 $92E
.3
	rts
