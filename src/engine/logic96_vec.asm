;	The puck flip and the assignment exits. vtoa turns a vector into a direction,
;	and GetHot reads a hot spot.

puckflip							;Flip the puck
	andi.w	#1,d0
	eor.w	d0,facedir(a3)			;facedir
	andi.w	#3,facedir(a3)
	st	SPAcnt(a3)					;SPAcnt
	move.w	#SPApflip,d1
	bra.w	SetSPA

puckshadow							;asstab entry: the puck shadow.
	cmpi.w	#SPAbglass,SPA(a3)
	beq.w	.2
	cmpi.w	#$299,frame(a3)
	bne.w	.3						;shadow turns into siren on goals
	move.w	-$80(a3),(a3)			;Xpos-SCstruct, Xpos
	move.w	-$6C(a3),Ypos(a3)		;Ypos-SCstruct, Ypos
	clr.w	Zpos(a3)				;Zpos
	moveq	#Ypos,d0				;Ypos
	btst	#sfhor,(sflags).w		;#sfhor - check if horizontal mode
	beq.w	.1
	moveq	#Xpos,d0				;Xpos
	;coordinate chosen
.1
	addq.w	#1,(a3,d0.w)
.2
	rts
	;the goal light: only when it is lit
.3
	tst.w	frame(a3)				;frame
	beq.w	rtss2
	clr.w	(a3)					;Xpos
	move.w	#$14B,Ypos(a3)
	move.w	#$E,Zpos(a3)			;Zpos
	tst.w	-$6C(a3)				;Ypos-SCstruct
	bpl.w	.5						;puck y >= 0: siren at the top, as set
	move.w	#$8000,attribute(a3)	;attribute
	btst	#0,(sflags14).w
	beq.w	.4
	move.w	#0,attribute(a3)
.4
	move.w	#$FEB1,Ypos(a3)
	subq.w	#1,Zpos(a3)
.5
	rts

findpc								;Where and when the puck crosses each goal line (puckcross).
	movem.l	d0-d4/a1-a2,-(sp)
	movea.w	#(puckcross-M68K_RAM),a1
	move.w	#$96,d1
	move.w	#$11E,d4
	bsr.w	PuckPathAtLine
	neg.w	d4						;make d4 negative to check bottom goal line
	bsr.w	PuckPathAtLine
	movem.l	(sp)+,d0-d4/a1-a2
	rts
PuckPathAtLine						;Where the puck path crosses the line d4 (uses the puck velocity)
	move.w	d4,d0					;move goaline into d0
	sub.w	(pucky).w,d0			;sub pucky from d0
	tst.w	(puckvy).w				;check puckvy
	beq.w	.3						;branch if 0
	move.w	d0,d2					;move d0 into d2
	swap	d2						;swap upper and lower word of d2
	clr.w	d2						;clear bottom word of d2
	asr.l	#4,d2					;shift 4 bits right (divide by 16)
	divs.w	(puckvy).w,d2			;divide puckvy into d2
	bmi.w	.3						;branch if negative
	move.w	d2,2(a1)				;time until crossing in frames (puckcross y)
	muls.w	(puckvx).w,d0			;mult puckvx with d0
	divs.w	(puckvy).w,d0			;divide puckvy into d0
	bvs.w	.3						;branch if overflow set
	add.w	(puckx).w,d0			;add puckx to d0
	cmp.w	d1,d0					;compare d1 (sideline) to d0
	blt.w	.1						;branch if less than (in play)
	neg.w	d0						;negate d0
	add.w	d1,d0					;add d1 3 times to d0
	add.w	d1,d0
	add.w	d1,d0
.1
	neg.w	d1						;negate d1
	cmp.w	d1,d0					;compare d1 (other sideline) to d0
	bgt.w	.2						;branch if greater than (in play)
	neg.w	d0						;negate d0
	add.w	d1,d0					;add d1 to d0 3 times
	add.w	d1,d0
	add.w	d1,d0
.2
	neg.w	d1						;negate d1
	move.w	d0,(a1)					;move d0 into puckcross
	bra.w	.4
.3
	move.w	#$FFFF,2(a1)			;move -1 into puckcross y
.4
	addq.w	#4,a1					;add 4 to puckcross (to move to the other goal line)
	rts

skateto								;Skate a3 to d0 / d1, a0 = an extra collision routine (EvadePC); every 12
									;frames, then doplayeracc
	sub.b	d7,$42(a3)				;sub d7 from temp2
	bpl.w	.4						;exit if not 0 or less
	addi.b	#$C,$42(a3)				;add 12 - only execute every 12 frames
	bsr.w	avdgoal					;avoid the goal nets
	movem.w	d0-d1,-(sp)
	move.w	$28(a3),d0				;Xvel
	asr.w	#8,d0					;divide by 256
	neg.w	d0						;make negative
	add.w	(sp)+,d0				;add new x coord from stack
	sub.w	(a3),d0					;sub Xpos
	move.w	$2A(a3),d1				;Yvel
	asr.w	#8,d1					;divide by 256
	neg.w	d1						;make negative
	add.w	(sp)+,d1				;add new y coord from stack
	sub.w	$14(a3),d1				;sub Ypos
	cmp.w	#$C,d0					;compare 12 to d0
	bgt.w	.1
	cmp.w	#$FFF4,d0				;cmp -12
	blt.w	.1
	cmp.w	#$C,d1					;compare 12 to d1
	bgt.w	.1
	cmp.w	#$FFF4,d1				;cmp -12
	blt.w	.1
	moveq	#9,d0
	bra.w	.2
.1
	bsr.w	vtoa
.2
	jsr	(a0)						;extra collision routine
	move.b	d0,$43(a3)				;move d0 into temp2+1
	cmp.w	#7,d0					;compare to 7
	ble.w	.4
	move.w	$28(a3),d0				;Xvel
	or.w	$2A(a3),d0				;Yvel
	bne.w	.4
	move.w	(puckx).w,d0			;move puckx into d0
	move.w	(pucky).w,d1			;move pucky into d1
	btst	#pf2fight,(puck_pflags2).w	;#pf2fight, puckx+pflags2
	beq.w	.3
	move.w	(xc1).w,d0				;scroll lock x coord
	move.w	(yc1).w,d1				;scroll lock y coord
.3
	sub.w	(a3),d0					;Xpos
	sub.w	$14(a3),d1				;Ypos - face towards puck
	bsr.w	vtoa
	sub.w	$54(a3),d0				;facedir
	beq.w	.4
	neg.w	d0
	andi.w	#4,d0
	lsr.w	#1,d0					;divide by 2
	subq.w	#1,d0
	add.w	$54(a3),d0				;facedir
	andi.w	#7,d0
	move.w	d0,$54(a3)				;facedir
.4
	clr.w	d0
	move.b	$43(a3),d0				;temp2+1
	bra.w	doplayeracc
avdgoal								;Skate target adjusted to stay out of the goalie crease (clears fodir2,
									;steers around the goal)
	clr.w	(fodir2+2).w
	clr.w	(fodir2+4).w
	tst.w	$34(a3)					;goalie? If so, quit
	beq.w	rtss2
	move.w	(a3),d2					;Xpos
	eor.w	d0,d2
	bpl.w	.6
	move.w	d1,d2
	sub.w	$14(a3),d2				;Ypos
	move.w	(a3),d3					;Xpos
	muls.w	d3,d2
	sub.w	d0,d3
	divs.w	d3,d2
	add.w	$14(a3),d2				;Ypos
	cmp.w	#$137,d2
	bgt.w	.6
	cmp.w	#$F1,d2
	blt.w	.3
	move.w	#$15A,d3
	cmp.w	#$114,d2
	bgt.w	.2
	blt.w	.1
	cmpi.w	#$114,$14(a3)
	bgt.w	.2
.1
	move.w	#$CE,d3
.2
	sub.w	d2,d3
	move.w	d3,(fodir2+4).w
	bra.w	.6
.3
	cmp.w	#$FF0F,d2
	bgt.w	.6
	cmp.w	#$FEC9,d2
	blt.w	.6
	move.w	#$FF32,d3
	cmp.w	#$FEEC,d2
	bgt.w	.5
	blt.w	.4
	cmpi.w	#$FEEC,$14(a3)
	bgt.w	.5
.4
	move.w	#$FEA6,d3
.5
	sub.w	d2,d3
	move.w	d3,(fodir2+4).w
.6
	move.w	d1,d3
	subi.w	#$114,d3
	move.w	$14(a3),d2
	subi.w	#$114,d2
	bsr.w	avdgoalcrease
	move.w	d1,d3
	addi.w	#$114,d3
	move.w	$14(a3),d2
	addi.w	#$114,d2
	bsr.w	avdgoalcrease
	add.w	(fodir2+2).w,d0
	add.w	(fodir2+4).w,d1
	rts
avdgoalcrease						;Second half of avdgoal: keep the target inside the crease width ($50) on
									;the far side
	move.w	d3,d4
	eor.w	d2,d4
	bpl.w	rtss2
	move.w	d0,d4
	sub.w	(a3),d4					;Xpos
	muls.w	d2,d4
	sub.w	d3,d2
	divs.w	d2,d4
	add.w	(a3),d4					;Xpos
	cmp.w	#$50,d4					;'P'   ; #.xr
	bgt.w	rtss2
	cmp.w	#$FFB0,d4				;#-.xr
	blt.w	rtss2
	moveq	#$50,d3					;'P'   ; #.xr
	tst.w	d4
	bne.w	.1
	tst.w	(a3)					;Xpos
.1
	bpl.w	.2
	neg.w	d3
.2
	sub.w	d4,d3
	move.w	d3,(fodir2+2).w
	rts
PuckLeadPosition					;d0/d1 = puck position plus its velocity (puck lead point for skating to
									;the puck)
	btst	#pfrev,pflags(a3)
	bne.w	.1
	move.w	(puckvx).w,d0
	asr.w	#8,d0
	add.w	(puckx).w,d0
	move.w	(puckvy).w,d1
	asr.w	#8,d1
	add.w	(pucky).w,d1
	rts
.1
	move.b	(puckvx).w,d0
	asr.b	#1,d0
	ext.w	d0
	add.w	(puckx).w,d0
	move.b	(puckvy).w,d1
	asr.b	#1,d1
	ext.w	d1
	add.w	(pucky).w,d1
	rts
skatetoIntercept	equ	*
	tst.w	$34(a3)
	bne.w	.2
	nop
.2
	bsr.s	PuckLeadPosition
	sub.b	d7,$42(a3)				;temp2
	bpl.w	.7
	addi.b	#$A,$42(a3)				;temp2
	bsr.w	avdgoal
	movem.w	d0-d1,-(sp)
	move.l	a3,-(sp)
	bsr.w	GetHot
	neg.b	d0
	neg.b	d1
	sub.b	$28(a3),d0				;Xvel
	ext.w	d0
	add.w	(sp)+,d0
	sub.w	(a3),d0					;Xpos
	sub.b	$2A(a3),d1				;Yvel
	ext.w	d1
	add.w	(sp)+,d1
	sub.w	$14(a3),d1				;Ypos
	bsr.w	vtoa
	move.b	d0,$43(a3)				;temp2 lower byte
	tst.w	$34(a3)
	beq.w	.7
	move.w	(puckvx).w,d0
	move.w	(puckvy).w,d1
	bsr.w	vtoa
	eori.w	#4,d0
	cmp.w	$54(a3),d0				;facedir
	beq.w	.7
	move.w	(puckx).w,d0
	sub.w	(a3),d0					;Xpos
	move.w	(pucky).w,d1
	sub.w	$14(a3),d1				;Ypos
	movem.w	d0-d1,-(sp)
	bsr.w	vtoa
	cmp.w	$54(a3),d0				;$54 = facedir
	movem.w	(sp)+,d0-d1
	bne.w	.7
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	cmp.l	#$400,d0
	bls.w	.7
	tst.w	$34(a3)
	beq.w	.6
	movem.w	d0,-(sp)
	move.w	$14(a3),d0
	btst	#pfgoal,pflags(a3)
	beq.w	.3
	neg.w	d0
.3
	cmp.w	#$76,d0
	blt.w	.5
	move.w	$2A(a3),d0
	btst	#pfgoal,pflags(a3)
	beq.w	.4
	neg.w	d0
.4
	tst.w	d0
	bpl.w	.5
	movem.w	(sp)+,d0
	bra.w	.6
.5
	move.w	#$64,d0
	bsr.w	randomd0
	cmp.w	#$4B,d0
	movem.w	(sp)+,d0
	blt.w	.6
	cmp.l	#$9C4,d0
	bls.w	.6
	btst	#pfalock,pflags(a3)
	bne.w	.6
	bsr.w	FindGoalieAimOffset
.6
	cmp.l	#$5A4,d0
	bls.w	Sweepcheck
.7
	move.b	$43(a3),d0
	ext.w	d0
	cmp.w	#7,d0
	bgt.w	.8
	cmp.w	$54(a3),d0
	beq.w	.8
	tst.w	$34(a3)
	beq.w	.8
	bsr.w	FacePuck
.8
	bra.w	doplayeracc

FacePuck							;Turn a3's facedir one step toward the puck (vtoa); d0 / d1 kept Code the
	movem.w	d0-d1,-(sp)
	move.w	(puckx).w,d0
	move.w	(pucky).w,d1
	sub.w	(a3),d0
	sub.w	Ypos(a3),d1
	bsr.w	vtoa
	sub.w	facedir(a3),d0
	beq.w	.1
	neg.w	d0
	andi.w	#4,d0
	lsr.w	#1,d0
	subq.w	#1,d0
	add.w	facedir(a3),d0
	andi.w	#7,d0
	move.w	d0,facedir(a3)
.1
	movem.w	(sp)+,d0-d1
	rts

assexit								;Exit the current assignment of player a3
	addq.w	#1,$36(a3)				;add 1 to current assignment index
	andi.w	#7,$36(a3)				;mask passing first 3 bits
	bset	#1,$62(a3)				;signal next assignment
	rts

assinsert							;Insert assignment d0 on player a3
	subq.w	#1,assnum(a3)			;$36 = assnum
	andi.w	#7,$36(a3)

assreplace							;Replace the current assignment of player a3 with d0
	move.l	d1,-(sp)				;push on stack
	move.w	assnum(a3),d1			;$36 = assnum
	move.b	d0,asslist(a3,d1.w)		;replace current assignment with d0 on asslist
	bset	#1,$62(a3)				;set flag to start new assignment
	move.l	(sp)+,d1				;pop on stack
	rts

vtoa								;d0/d1 = vector: return d0 = direction 0-7 (8 for no vector) through .dt
	movem.l	d2/a0,-(sp)
	move.w	d0,d2
	or.w	d1,d2
	beq.w	.nodir
	clr.w	d2
	tst.w	d0
	bpl.w	.0
	neg.w	d0
	bset	#0,d2
.0
	tst.w	d1
	bpl.w	.1
	neg.w	d1
	bset	#1,d2
.1
	asl.w	#1,d1
	cmp.w	d1,d0
	bhi.w	.2
	bset	#2,d2
.2
	lsr.w	#1,d1
	asl.w	#1,d0
	cmp.w	d0,d1
	bhi.w	.3
	bset	#3,d2
.3
	movea.l	#.dt,a0
	clr.w	d0
	move.b	(a0,d2.w),d0
	movem.l	(sp)+,d2/a0
	rts
.nodir
	moveq	#8,d0
	movem.l	(sp)+,d2/a0
	rts
.dt
	dc.b	1,7,3,5,0,0,4,4,2,6,2,6,1,7,3,5

GetHot								;Push long address of structure to get hot spot from; hot spot x/y
									;returned in d0/d1 (HotList by frame, flipped with the attribute)
	movem.l	a0-a1,-(sp)
	movea.l	$C(sp),a0				;move stored address before sub routine call into a0
	clr.w	d0						;clear d0
	clr.w	d1						;clear d1
	tst.w	frame(a0)
	ble.w	.ex
	movea.l	#HotList,a1
	move.w	frame(a0),d0
	add.w	d0,d0					;double d0
	move.b	1(a1,d0.w),d1			;SprStrHot Y byte
	ext.w	d1						;extend d1
	move.b	(a1,d0.w),d0
	ext.w	d0						;extend d0
	btst	#3,attribute(a0)
	beq.w	.0
	neg.w	d0						;negate d0 (flip)
.0
	btst	#4,attribute(a0)
	bne.w	.1
	neg.w	d1						;ngate d1 (x now)
.1
	btst	#sfhor,(sflags).w
	beq.w	.ex
	exg	d0,d1
	neg.w	d1						;ngate d1 (x now)
.ex
	movem.l	(sp)+,a0-a1
	move.l	(sp)+,(sp)
	rts

GetHot2a							;Push a struct: d0 / d1 = rink x / y of its first HotList2 hot spot for
									;its frame (0 / 0 with no frame)
	movem.l	a0-a1,-(sp)				;$C(sp) = the address the caller pushed (above 2 longs and the return
	movea.l	$C(sp),a0				;move stored address before sub routine call into a0
	clr.w	d0						;clear d0
	clr.w	d1						;clear d1
	tst.w	6(a0)
	ble.w	.4						;branch if <= 0
	movea.l	#HotList2,a1			;move HotList address into a1
	move.w	6(a0),d0				;move frame into d0
	move.w	(a1)+,d1
	subq.w	#1,d1
	sub.w	d1,d0
	bmi.w	.loop
	asl.w	#2,d0
	add.w	6(a0),d0
	add.w	6(a0),d0
	move.b	1(a1,d0.w),d1			;SprStrHot Y byte
	ext.w	d1						;extend d1
	move.b	(a1,d0.w),d0			;SprStrHot X byte
	ext.w	d0						;extend d0
	btst	#3,4(a0)				;check attribute for X flip
	beq.w	.1						;branch if equal
	neg.w	d0						;negate d0 (flip)
	;x flipped sprites mirror the hot spot x
.1
	btst	#4,4(a0)				;check attribute for Y flip
	bne.w	.2						;branch if no flip
	neg.w	d1						;negate d1 (flip)
	;y flipped sprites mirror the hot spot y; horizontal mode swaps x and y
.2
	btst	#sfhor,(sflags).w		;check if horizontal mode
	beq.w	.3						;branch if not
	exg	d0,d1						;swap d0 and d1
	neg.w	d1						;ngate d1 (x now)
.3
	add.w	$14(a0),d1
	add.w	(a0),d0
.4
	movem.l	(sp)+,a0-a1
	move.l	(sp)+,(sp)
	rts
.loop
	nop
	bra.s	.loop

GetHot2b							;Push a struct: d0 / d1 = rink x / y of its second HotList2 hot spot for
									;its frame
	movem.l	a0-a1,-(sp)				;$C(sp) = the address the caller pushed (above 2 longs and the return
	movea.l	$C(sp),a0				;move stored address before sub routine call into a0
	clr.w	d0						;clear d0
	clr.w	d1						;clear d1
	tst.w	6(a0)
	ble.w	.4						;branch if <= 0
	movea.l	#HotList2,a1			;move HotList address into a1
	move.w	6(a0),d0				;move frame into d0
	move.w	(a1)+,d1
	subq.w	#1,d1
	sub.w	d1,d0
	bmi.w	.loop
	asl.w	#2,d0
	add.w	6(a0),d0
	add.w	6(a0),d0
	move.b	3(a1,d0.w),d1			;SprStrHot Y byte
	ext.w	d1						;extend d1
	move.b	2(a1,d0.w),d0			;SprStrHot X byte
	ext.w	d0						;extend d0
	btst	#3,4(a0)				;check attribute for X flip
	beq.w	.1						;branch if equal
	neg.w	d0						;negate d0 (flip)
	;x flipped sprites mirror the hot spot x
.1
	btst	#4,4(a0)				;check attribute for Y flip
	bne.w	.2						;branch if no flip
	neg.w	d1						;negate d1 (flip)
	;y flipped sprites mirror the hot spot y; horizontal mode swaps x and y
.2
	btst	#sfhor,(sflags).w		;check if horizontal mode
	beq.w	.3						;branch if not
	exg	d0,d1						;swap d0 and d1
	neg.w	d1						;ngate d1 (x now)
.3
	add.w	$14(a0),d1
	add.w	(a0),d0
.4
	movem.l	(sp)+,a0-a1
	move.l	(sp)+,(sp)
	rts
.loop
	nop
	bra.s	.loop

GetHot2c							;Push a struct: d0 / d1 = rink x / y of its third HotList2 hot spot for
									;its frame
	movem.l	a0-a1,-(sp)				;$C(sp) = the address the caller pushed (above 2 longs and the return
	movea.l	$C(sp),a0				;move stored address before sub routine call into a0
	clr.w	d0						;clear d0
	clr.w	d1						;clear d1
	tst.w	6(a0)
	ble.w	.4						;branch if <= 0
	movea.l	#HotList2,a1			;move HotList address into a1
	move.w	6(a0),d0				;move frame into d0
	move.w	(a1)+,d1
	subq.w	#1,d1
	sub.w	d1,d0
	bmi.w	.loop
	asl.w	#2,d0
	add.w	6(a0),d0
	add.w	6(a0),d0
	move.b	5(a1,d0.w),d1			;SprStrHot Y byte
	ext.w	d1						;extend d1
	move.b	4(a1,d0.w),d0			;SprStrHot X byte
	ext.w	d0						;extend d0
	btst	#3,4(a0)				;check attribute for X flip
	beq.w	.1						;branch if equal
	neg.w	d0						;negate d0 (flip)
	;x flipped sprites mirror the hot spot x
.1
	btst	#4,4(a0)				;check attribute for Y flip
	bne.w	.2						;branch if no flip
	neg.w	d1						;negate d1 (flip)
	;y flipped sprites mirror the hot spot y; horizontal mode swaps x and y
.2
	btst	#sfhor,(sflags).w		;check if horizontal mode
	beq.w	.3						;branch if not
	exg	d0,d1						;swap d0 and d1
	neg.w	d1						;ngate d1 (x now)
.3
	add.w	$14(a0),d1
	add.w	(a0),d0
.4
	movem.l	(sp)+,a0-a1
	move.l	(sp)+,(sp)
	rts
.loop
	nop
	bra.s	.loop
