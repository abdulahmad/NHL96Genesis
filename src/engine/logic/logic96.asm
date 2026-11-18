;	The assignment table. asstab lists the assignment routines, most of them here as bytes
;	the listing does not decode. Penaltylist is the penalty texts and the referee signals,
;	with PenShotPenalties and a second table by penalty number.

asstab								;Assignment routines: assignment number = index
									;(asslist entries; doassignment)
	dc.l	rtss2					;$0
	dc.l	assdefo					;$1
	dc.l	assdefd					;$2
	dc.l	asswingd				;$3
	dc.l	asswingo				;$4
	dc.l	asscenterd				;$5
	dc.l	asscentero				;$6
	dc.l	assscore				;$7
	dc.l	assstanley				;$8
	dc.l	asseben					;$9
	dc.l	assepen					;$A
	dc.l	assbench				;$B
	dc.l	asspenalty				;$C
	dc.l	assdopen				;$D
	dc.l	assgoaliecpu			;$E
	dc.l	assgoalietopuck			;$F
	dc.l	asspuckc				;$10
	dc.l	assnearest				;$11
	dc.l	assshoot				;$12
	dc.l	asspassrec				;$13
	dc.l	assfight				;$14
	dc.l	assfwatch				;$15
	dc.l	assfaceoff				;$16
	dc.l	assfaceoffpl			;$17
	dc.l	pucknorm				;$18
	dc.l	puckshadow				;$19
	dc.l	puckunflip				;$1A
	dc.l	puckfaceoff				;$1B
	dc.l	puckfaceoff2			;$1C
	dc.l	assgoaliectrl			;$1D
	dc.l	puckshootout			;$1E
	dc.l	puckpenshot				;$1F
	dc.l	assgoaliebreakwait		;$20
	dc.l	chkpuckc				;$21
	dc.l	assbreakaway			;$22
	dc.l	assonetimer				;$23
	dc.l	assdefo5				;$24
	dc.l	assdefd5				;$25
	dc.l	assdefo4				;$26
	dc.l	assdefd4				;$27
	dc.l	asswingd5				;$28
	dc.l	asswingd4				;$29
	dc.l	asswingo5				;$2A
	dc.l	asswingo4				;$2B
	dc.l	asscenterd5				;$2C
	dc.l	asscenterd4				;$2D
	dc.l	asscentero5				;$2E
	dc.l	asscentero4				;$2F
	;each asstab entry
GoAssReplace	equ	*			;Jump to assreplace
	jmp	(assreplace).l

asscentero4							;Center on offense, two men short (tmap 4); back to asscentero /
									;asscentero5 when tmap changes, asscenterd4
									;when the other team has the puck
	btst	#pfalock,pflags(a3)
	bne.w	.22
	cmpi.w	#4,$24(a2)
	beq.w	.2
	move.w	#6,d0
	cmpi.w	#6,$24(a2)
	bne.w	.1
	bra.s	GoAssReplace
.1
	move.w	#$2E,d0
	cmpi.w	#5,$24(a2)
	bne.w	.2
	bra.s	GoAssReplace
.2
	btst	#0,(gmode).w
	beq.w	.3
	jmp	(donothing).l
.3
	jsr	(check4bench).l
	btst	#pfjoycon,pflags(a3)
	bne.w	.22
	move.w	#$2D,d0
	move.w	(pucky).w,d1
	subq.w	#6,d1
	move.w	$52(a3),d2
	subq.w	#6,d2
	eor.w	d2,d1
	bmi.s	GoAssReplace
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.4
	neg.w	d1
.4
	cmp.w	#$76,d1
	bgt.w	GoAssReplace
	bclr	#pfna,pflags(a3)
	beq.w	.5
	clr.w	$40(a3)
	move.w	#8,$42(a3)
.5
	sub.b	d7,$40(a3)
	bpl.w	.13
	move.b	$6B(a3),$40(a3)
	jsr	(ReadGoaliePulled).l
	bmi.w	.6
	btst	#6,(sflags7).w
	beq.w	.7
	tst.b	$40(a3)
	beq.w	.7
.6
	subq.b	#1,$40(a3)
.7
	clr.w	d1
	move.b	$65(a3),d1
	bpl.w	.8
	move.w	$34(a3),d1
	bmi.w	.22
.8
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.9
	neg.w	d1
.9
	cmp.w	#$76,d1
	bgt.w	.12
	move.w	#$51,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.10
	neg.w	d0
.10
	move.w	d0,$44(a3)
	move.w	#$96,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.11
	neg.w	d1
.11
	move.w	d1,$46(a3)
	bra.w	.13
.12
	move.w	(puckx).w,$44(a3)
	clr.w	$46(a3)
.13
	move.w	$46(a3),d1
	btst	#pfgoal,pflags(a3)
	bne.w	.17
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.14
	adda.w	#$300,a0
.14
	move.w	#5,d2
.loop
	btst	#pf2unav,pflags2(a0)
	bne.w	.16
	tst.b	$65(a0)
	bpl.w	.15
	tst.w	$34(a0)
	bmi.w	.16
.15
	move.w	$2A(a0),d0
	asr.w	#7,d0
	add.w	$14(a0),d0
	cmp.w	d0,d1
	bgt.w	.16
	move.w	d0,d1
.16
	adda.w	#$80,a0
	dbf	d2,.loop
	bra.w	.21
.17
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.18
	adda.w	#$300,a0
.18
	move.w	#5,d2
.loop2
	btst	#pf2unav,pflags2(a0)
	bne.w	.20
	tst.b	$65(a0)
	bpl.w	.19
	tst.w	$34(a0)
	bmi.w	.20
.19
	move.w	$2A(a0),d0
	asr.w	#7,d0
	add.w	$14(a0),d0
	cmp.w	d0,d1
	blt.w	.20
	move.w	d0,d1
.20
	adda.w	#$80,a0
	dbf	d2,.loop2
.21
	move.w	$44(a3),d0
	movea.l	#EvadePC,a0
	jmp	(skateto).l
.22
	rts

asscentero5							;Center on offense, one man short (tmap 5); asscenterd5 when the other
									;team has the puck
	cmpi.w	#5,$24(a2)
	beq.w	.2
	move.w	#6,d0
	cmpi.w	#6,$24(a2)
	bne.w	.1
	bra.w	GoAssReplace
.1
	move.w	#$2F,d0
	cmpi.w	#4,$24(a2)
	bne.w	.2
	bra.w	GoAssReplace
.2
	btst	#pfalock,pflags(a3)
	bne.w	.13
	btst	#0,(gmode).w
	beq.w	.3
	jmp	(donothing).l
.3
	jsr	(check4bench).l
	btst	#pfjoycon,pflags(a3)
	bne.w	.13
	moveq	#$2C,d0
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.4
	neg.w	d1
.4
	cmp.w	#$76,d1
	bgt.w	GoAssReplace
	move.w	(puckc).w,d1
	bmi.w	.5
	subq.w	#6,d1
	move.w	$52(a3),d2
	subq.w	#6,d2
	eor.w	d2,d1
	bmi.w	GoAssReplace
.5
	bclr	#pfna,$62(a3)			;clear new assignment bit
	beq.w	.6						;branch if it was already cleared
	st	$48(a3)						;set old zone # (temp5)
	clr.w	$40(a3)					;clear temp1
	move.w	#8,$42(a3)				;move 8 into temp2
	;count down the timer
.6
	sub.b	d7,$40(a3)				;subtract frames elapsed from temp1
	bpl.w	.11						;branch if positive
	move.b	$6C(a3),$40(a3)
	btst	#6,(sflags7).w			;check if crowd meter currently broken
	beq.w	.7
	tst.b	$40(a3)					;check if temp1 is 0
	beq.w	.7
	subq.b	#1,$40(a3)				;subtract 1 from temp1
.7
	move.w	(puckvy).w,d0
	asr.w	#7,d0
	add.w	(pucky).w,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.8
	neg.w	d0						;negate d3
	;coordinates for his end
.8
	clr.w	d2						;clear zone number
	cmp.w	#$FF8A,d0
	blt.w	.9						;branch if in defensive zone
	addq.w	#8,d2					;add 8 to d2 (d2 = 8)
	cmp.w	#$76,d0
	blt.w	.9						;branch if in neutral zone
	btst	#4,$30(a2)				;currently offside (tmfoside of the team's tmflags)
	bne.w	.9						;branch if set
	addq.w	#8,d2					;add 8 to d2 (d2 = $10)
	cmp.w	#$11E,d0
	blt.w	.9						;branch if in offensive zone
	addq.w	#8,d2					;add 8 to d2 (d2 = $18)
	;d2 = zone index by where the puck is (offensive zone and past the goal
.9
	cmp.w	$48(a3),d2				;compare temp5 with d2
	bne.w	.10						;branch if different zone
	move.w	(Vcount).w,d0			;move frame counter into d0
	andi.w	#$7F,d0					;pass first 7 bits
	cmp.w	#2,d0
	bgt.w	.11
	;new zone (or 1 frame in 128): pick a new random spot from .dedata
.10
	move.w	d2,$48(a3)				;move d2 into temp5
	lea	.table(pc),a0				;move zonedata address into a0
	move.w	2(a0,d2.w),d0			;move X Coord into d0
	jsr	(randomd0s).l				;RNG d0
	add.w	(a0,d2.w),d0			;add X Coord offset to d0
	move.w	d0,$44(a3)				;move d0 into temp3
	move.w	6(a0,d2.w),d0			;move Y Coord into d0
	jsr	(randomd0s).l				;RNG d0
	add.w	4(a0,d2.w),d0			;add Y Coord offset into d0
	move.w	d0,$46(a3)				;move d0 into temp4
	bra.w	.11
.table
	dc.w	$0000,$003C,$FFBA,$000A,$0000,$003C,$003C,$000A
	dc.w	$0000,$0028,$00AA,$001E,$0000,$0050,$00AA,$0014
	;skate to the spot; LW mirrors x
.11
	move.w	$44(a3),d0				;move temp3 into d0
	;d1 = spot y; flip both for the bottom net
	move.w	$46(a3),d1				;move temp4 into d1
	btst	#pfgoal,$62(a3)			;check if shooting up or down
	bne.w	.12						;branch if shooting up
	neg.w	d1						;negate d0
.12
	movea.l	#EvadePC,a0
	jmp	(skateto).l
.13
	rts

asscenterd4							;Center on defense, two men short (tmap 4); asscentero4 when his team gets
									;the puck
	cmpi.w	#4,$24(a2)
	beq.w	.2
	move.w	#5,d0
	cmpi.w	#6,$24(a2)
	bne.w	.1
	bra.w	GoAssReplace
.1
	move.w	#$2C,d0
	cmpi.w	#5,$24(a2)
	bne.w	.2
	bra.w	GoAssReplace
.2
	btst	#pfalock,$62(a3)		;pfalock - locked animation
	bne.w	.14						;exit if locked
	btst	#gmclock,(gmode).w		;gmclock - check if clock is running
	bne.w	GoDoNothing				;exit if stoppage
	jsr	(check4bench).l
	btst	#pfjoycon,$62(a3)		;pfjoycon - check if joystick controlled
	bne.w	.14						;exit if joystick controlled
	bclr	#pfna,$62(a3)			;pfna - new assignment
	beq.w	.3						;branch if no new assignment
	clr.w	$40(a3)					;clear temp1
	move.w	#8,$42(a3)				;move 8 into temp2
	;count down the timer
.3
	sub.b	d7,$40(a3)				;subtract d7 from temp1
	bpl.w	.13
	move.b	$6C(a3),$40(a3)
	btst	#6,(sflags7).w			;check for crowd record flag
	beq.w	.4						;jump if not set
	tst.b	$40(a3)					;check if 0
	beq.w	.4
	subq.b	#1,$40(a3)				;subtract 1 from temp1
	;center on defense: switch to asscentero if our team has the puck
.4
	move.w	(puckc).w,d1			;move puck carrier SCnum into d1
	bmi.w	.6
	move.w	(pucky).w,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.5
	neg.w	d0
.5
	cmp.w	#$76,d0
	bgt.w	.6
	moveq	#$2F,d0
	subq.w	#6,d1					;subtract 6 from d1
	move.w	$52(a3),d2				;move player's SCnum into d2
	subq.w	#6,d2					;subtract 6 from d2
	eor.w	d2,d1					;compare d2 and d1
	bpl.w	GoAssReplace			;if team has puck, replace assignment with acentero
	;no carrier or the other team has it: cover between the puck and our net
.6
	move.w	(pucky).w,d0			;Xpos of puck
	btst	#pfgoal,pflags(a3)
	beq.w	.7
	neg.w	d0
.7
	cmp.w	#$76,d0
	blt.w	.11
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.8
	adda.w	#$300,a0
.8
	move.w	(puckc).w,d0
	bpl.w	.9
	move.w	#$E,d0
.9
	asl.w	#7,d0
	movea.l	#SortCords,a0
	adda.w	d0,a0
	move.w	$28(a0),d0
	asr.w	#7,d0
	add.w	(a0),d0
	asr.w	#2,d0
	move.w	d0,d1
	add.w	d0,d1
	add.w	d0,d1
	move.w	d1,$44(a3)
	move.w	#$11E,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.10
	neg.w	d0
.10
	move.w	$2A(a0),d1
	asr.w	#7,d1
	add.w	$14(a0),d1
	sub.w	d0,d1
	asr.w	#2,d1
	add.w	d1,d0
	add.w	d1,d0
	add.w	d1,d0
	move.w	d0,$46(a3)
	bra.w	.13
.11
	move.w	(puckx).w,$44(a3)
	move.w	#$76,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.12
	neg.w	d0
.12
	move.w	d0,$46(a3)
.13
	move.w	$44(a3),d0
	move.w	$46(a3),d1
	lea	.14(pc),a0
	jmp	(skateto).l
.14
	rts
GoDoNothing	equ	*	;Jump to donothing
	jmp	(donothing).l

asscenterd5							;Center on defense, one man short (tmap 5); asscentero5 when his team gets
									;the puck
	cmpi.w	#5,$24(a2)
	beq.w	.2
	move.w	#5,d0
	cmpi.w	#6,$24(a2)
	bne.w	.1
	bra.w	GoAssReplace
.1
	move.w	#$2D,d0
	cmpi.w	#4,$24(a2)
	bne.w	.2
	bra.w	GoAssReplace
.2
	btst	#pfalock,$62(a3)		;pfalock - locked animation
	bne.w	.20						;exit if locked
	btst	#gmclock,(gmode).w		;gmclock - check if clock is running
	bne.s	GoDoNothing				;exit if stoppage
	jsr	(check4bench).l
	btst	#pfjoycon,$62(a3)		;pfjoycon - check if joystick controlled
	bne.w	.20						;exit if joystick controlled
	bclr	#pfna,$62(a3)			;pfna - new assignment
	beq.w	.3						;branch if no new assignment
	clr.w	$40(a3)					;clear temp1
	move.w	#8,$42(a3)				;move 8 into temp2
	;count down the timer
.3
	sub.b	d7,$40(a3)				;subtract d7 from temp1
	bpl.w	.19
	move.b	$6C(a3),$40(a3)
	btst	#6,(sflags7).w			;check for crowd record flag
	beq.w	.4						;jump if not set
	tst.b	$40(a3)					;check if 0
	beq.w	.4
	subq.b	#1,$40(a3)				;subtract 1 from temp1
	;center on defense: switch to asscentero if our team has the puck
.4
	move.w	(puckc).w,d1			;move puck carrier SCnum into d1
	bmi.w	.6
	move.w	(pucky).w,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.5
	neg.w	d0
.5
	cmp.w	#$76,d0
	bgt.w	.6
	moveq	#$2E,d0
	subq.w	#6,d1					;subtract 6 from d1
	move.w	$52(a3),d2				;move player's SCnum into d2
	subq.w	#6,d2					;subtract 6 from d2
	eor.w	d2,d1					;compare d2 and d1
	bpl.w	GoAssReplace			;if team has puck, replace assignment with acentero
	;no carrier or the other team has it: cover between the puck and our net
.6
	move.w	(pucky).w,d0			;Xpos of puck
	btst	#pfgoal,pflags(a3)
	beq.w	.7
	neg.w	d0
.7
	cmp.w	#$76,d0
	blt.w	.16
	move.w	(puckc).w,d1
	bmi.w	.10
	subq.w	#6,d1
	move.w	$52(a3),d2
	subq.w	#6,d2
	eor.w	d2,d1
	bmi.w	.10
	move.w	#$FFAF,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.8
	neg.w	d1
.8
	move.w	#$14,d0
	jsr	(randomd0s).l
	add.w	d1,d0
	move.w	d0,$44(a3)
	move.w	#$76,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.9
	neg.w	d1
.9
	move.w	d1,$46(a3)
	bra.w	.19
.10
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.11
	adda.w	#$300,a0
.11
	move.w	#1,d0
	bsr.w	asswingoCheckSlot
	move.w	$14(a0),d1
	btst	#pfgoal,pflags(a3)
	beq.w	.12
	neg.w	d1
.12
	cmp.w	#$76,d1
	bge.w	.14
	move.w	(a0),d0
	move.w	#$A3,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.13
	neg.w	d1
.13
	move.w	d0,$44(a3)
	move.w	d1,$46(a3)
	bra.w	.19
.14
	move.w	$28(a0),d0
	asr.w	#7,d0
	add.w	(a0),d0
	asr.w	#2,d0
	move.w	d0,d1
	add.w	d0,d1
	add.w	d0,d1
	move.w	d1,$44(a3)
	move.w	#$11E,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.15
	neg.w	d0
.15
	move.w	$2A(a0),d1
	asr.w	#7,d1
	add.w	$14(a0),d1
	sub.w	d0,d1
	asr.w	#2,d1
	add.w	d1,d0
	add.w	d1,d0
	add.w	d1,d0
	move.w	d0,$46(a3)
	bra.w	.19
.16
	move.w	(puckx).w,d0
	move.w	(a3),d1
	eor.w	d1,d0
	bmi.w	.18
	move.w	(puckx).w,$44(a3)
.loop
	move.w	#$76,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.17
	neg.w	d0
.17
	move.w	d0,$46(a3)
	bra.w	.19
.18
	move.w	#0,$44(a3)
	bra.s	.loop
.19
	move.w	$44(a3),d0
	move.w	$46(a3),d1
	lea	.20(pc),a0
	jmp	(skateto).l
.20
	rts

asswingo4							;Winger on offense, two men short (tmap 4): does nothing
	dc.b	$4E,$75

asswingo5							;Winger on offense, one man short (tmap 5); asswingd5 when the other team
									;has the puck
	cmpi.w	#5,$24(a2)
	beq.w	.2
	move.w	#4,d0
	cmpi.w	#6,$24(a2)
	bne.w	.1
	bra.w	GoAssReplace
.1
	move.w	#$2B,d0
	cmpi.w	#4,$24(a2)
	bne.w	.2
	bra.w	GoAssReplace
.2
	btst	#pfalock,$62(a3)		;check if locked in animation
	bne.w	.12						;exit if so
	btst	#gmclock,(gmode).w		;check game clock
	bne.w	GoDoNothing				;donothing if stopped
	jsr	(check4bench).l				;check if player going to bench
	btst	#pfjoycon,$62(a3)		;check if joystick controlled
	bne.w	.12						;exit if so
	moveq	#$28,d0
	move.w	(puckc).w,d1
	bmi.w	.3
	subq.w	#6,d1
	move.w	$52(a3),d2
	subq.w	#6,d2
	eor.w	d2,d1
	bmi.w	GoAssReplace
.3
	bclr	#pfna,$62(a3)			;clear new assignment bit
	beq.w	.4						;branch if it was already cleared
	st	$48(a3)						;set old zone # (temp5)
	clr.w	$40(a3)					;clear temp1
	move.w	#8,$42(a3)				;move 8 into temp2
.4
	sub.b	d7,$40(a3)				;subtract frames elapsed from temp1
	bpl.w	.10						;branch if positive
	move.b	$6C(a3),$40(a3)
	btst	#6,(sflags7).w			;check if crowd meter currently broken
	beq.w	.5
	tst.b	$40(a3)					;check if temp1 is 0
	beq.w	.5
	subq.b	#1,$40(a3)				;subtract 1 from temp1
.5
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.6
	neg.w	d1
.6
	cmp.w	#$76,d1
	bgt.w	GoAssReplace
	move.w	(pucky).w,d0			;pucky into d0
	move.w	(puckvy).w,d3			;puckvy into d3
	asr.w	#6,d3					;divide d3 by 64
	add.w	d0,d3					;add d0 to d3
	btst	#pfgoal,$62(a3)			;check which goal shooting on
	bne.w	.7						;branch if top goal
	neg.w	d0						;negate d0
	neg.w	d3						;negate d3
.7
	clr.w	d2						;clear zone number
	cmp.w	#$FF8A,d3
	blt.w	.8						;branch if in defensive zone
	addq.w	#8,d2					;add 8 to d2 (d2 = 8)
	cmp.w	#$76,d0
	blt.w	.8						;branch if in neutral zone
	btst	#4,$30(a2)				;check bit 4 of offset 30 (currently offside)
	;(C6FE Home, CA62 Away)
	bne.w	.8						;branch if set
	addq.w	#8,d2					;add 8 to d2 (d2 = $10)
	cmp.w	#$11E,d3
	blt.w	.8						;branch if in offensive zone
	addq.w	#8,d2					;add 8 to d2 (d2 = $18)
.8
	cmp.w	$48(a3),d2				;compare temp5 with d2
	bne.w	.9						;branch if different zone
	move.w	(Vcount).w,d0
	andi.w	#$7F,d0
	cmp.w	#2,d0
	bgt.w	.10
	;movement in zone while waiting
.9
	move.w	d2,$48(a3)				;move d2 into temp5
	lea	.table(pc),a0				;move zonedata address into a0
	move.w	2(a0,d2.w),d0			;move X Coord into d0
	jsr	(randomd0s).l				;RNG d0
	add.w	(a0,d2.w),d0			;add X Coord offset to d0
	move.w	d0,$44(a3)				;move d0 into temp3
	move.w	6(a0,d2.w),d0			;move Y Coord into d0
	jsr	(randomd0s).l				;RNG d0
	add.w	4(a0,d2.w),d0			;add Y Coord offset into d0
	move.w	d0,$46(a3)
	bra.w	.10
.table
	dc.w	$0050,$0014,$FFBA,$000A,$0064,$0014,$0058,$0005
	dc.w	$0047,$0032,$00E6,$0014,$0050,$001E,$00FA,$0014
.10
	move.w	$44(a3),d0
	move.w	$46(a3),d1				;move temp4 into d1
	btst	#pfgoal,$62(a3)			;check if shooting up or down
	bne.w	.11						;branch if shooting up
	neg.w	d0						;negate d0
	neg.w	d1						;negate d1
.11
	movea.l	#EvadePC,a0
	jmp	(skateto).l
.12
	rts

asswingd4							;Winger on defense, two men short (tmap 4): does nothing
	dc.b	$4E,$75

asswingd5							;Winger on defense, one man short (tmap 5); asswingo5 when his team gets
									;the puck
	cmpi.w	#5,$24(a2)
	beq.w	.2
	move.w	#3,d0
	cmpi.w	#6,$24(a2)
	bne.w	.1
	bra.w	GoAssReplace
.1
	move.w	#$29,d0
	cmpi.w	#4,$24(a2)
	bne.w	.2
	bra.w	GoAssReplace
.2
	btst	#pfalock,pflags(a3)
	bne.w	.20
	btst	#0,(gmode).w
	bne.w	GoDoNothing
	jsr	(check4bench).l
	btst	#pfjoycon,pflags(a3)
	bne.w	.20
	bclr	#pfna,pflags(a3)
	beq.w	.3
	clr.w	$40(a3)
	move.w	#8,$42(a3)
.3
	sub.b	d7,$40(a3)
	bpl.w	.19
	move.b	$6C(a3),$40(a3)
	btst	#6,(sflags7).w
	beq.w	.4
	tst.b	$40(a3)
	beq.w	.4
	subq.b	#1,$40(a3)
.4
	moveq	#$2A,d0
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.5
	neg.w	d1
.5
	cmp.w	#$76,d1
	bgt.w	.6
	move.w	(puckc).w,d1
	bmi.w	.6
	subq.w	#6,d1
	move.w	$52(a3),d2
	subq.w	#6,d2
	eor.w	d2,d1
	bpl.w	GoAssReplace
.6
	move.w	(pucky).w,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.7
	neg.w	d0
.7
	cmp.w	#$76,d0
	blt.w	.16
	move.w	(puckc).w,d1
	bmi.w	.10
	subq.w	#6,d1
	move.w	$52(a3),d2
	subq.w	#6,d2
	eor.w	d2,d1
	bmi.w	.10
	move.w	#$51,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.8
	neg.w	d1
.8
	move.w	#$14,d0
	jsr	(randomd0s).l
	add.w	d1,d0
	move.w	d0,$44(a3)
	move.w	#$76,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.9
	neg.w	d1
.9
	move.w	d1,$46(a3)
	bra.w	.19
.10
	move.w	#2,d0
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.11
	adda.w	#$300,a0
.11
	bsr.w	asswingoCheckSlot
	move.w	$14(a0),d1
	btst	#pfgoal,pflags(a3)
	beq.w	.12
	neg.w	d1
.12
	cmp.w	#$76,d1
	bge.w	.14
	move.w	(a0),d0
	move.w	#$A3,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.13
	neg.w	d1
.13
	move.w	d0,$44(a3)
	move.w	d1,$46(a3)
	bra.w	.19
.14
	move.w	#$76,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.15
	neg.w	d1
.15
	move.w	$2A(a0),d0
	asr.w	#7,d0
	add.w	$14(a0),d0
	sub.w	d1,d0
	asr.w	#2,d0
	add.w	d0,d1
	add.w	d0,d1
	add.w	d0,d1
	move.w	d1,$46(a3)
	move.w	$28(a0),d1
	asr.w	#7,d1
	add.w	(a0),d1
	asr.w	#2,d1
	move.w	d1,d0
	add.w	d1,d0
	add.w	d1,d0
	move.w	d0,$44(a3)
	bra.w	.19
.16
	move.w	(puckx).w,d0
	move.w	(a3),d1
	eor.w	d1,d0
	bmi.w	.18
	move.w	(puckx).w,$44(a3)
.loop
	move.w	#$76,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.17
	neg.w	d0
.17
	move.w	d0,$46(a3)
	bra.w	.19
.18
	move.w	#0,$44(a3)
	bra.s	.loop
.19
	move.w	$44(a3),d0
	move.w	$46(a3),d1
	lea	.20(pc),a0
	jmp	(skateto).l
.20
	rts

assdefo4							;Defenseman on offense, two men short (tmap 4); assdefd4 when his team
									;loses the puck
	btst	#pfalock,pflags(a3)
	bne.w	.34
	cmpi.w	#4,$24(a2)
	beq.w	.2
	move.w	#1,d0
	cmpi.w	#6,$24(a2)
	bne.w	.1
	bra.w	GoAssReplace
.1
	move.w	#$24,d0
	cmpi.w	#5,$24(a2)
	bne.w	.2
	bra.w	GoAssReplace
.2
	btst	#0,(gmode).w
	bne.w	GoDoNothing
	jsr	(check4bench).l
	btst	#pfjoycon,pflags(a3)
	bne.w	.34
	move.w	#$27,d0
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.3
	neg.w	d1
.3
	cmp.w	#$76,d1
	bgt.w	GoAssReplace
	move.w	(puckc).w,d1
	bmi.w	GoAssReplace
	subq.w	#6,d1
	move.w	$52(a3),d2
	subq.w	#6,d2
	eor.w	d2,d1
	bmi.w	GoAssReplace
	bclr	#pfna,pflags(a3)
	beq.w	.4
	clr.w	$40(a3)
	move.w	#8,$42(a3)
.4
	sub.b	d7,$40(a3)
	bpl.w	.25
	move.b	$6B(a3),$40(a3)
	jsr	(ReadGoaliePulled).l
	bmi.w	.5
	btst	#6,(sflags7).w
	beq.w	.6
	tst.b	$40(a3)
	beq.w	.6
.5
	subq.b	#1,$40(a3)
.6
	clr.w	d1
	move.b	$65(a3),d1
	bpl.w	.7
	move.w	$34(a3),d1
	bmi.w	.34
.7
	cmp.w	#2,d1
	bne.w	.16
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.8
	neg.w	d1
.8
	cmp.w	#$76,d1
	bgt.w	.11
	move.w	#$51,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.9
	neg.w	d0
.9
	move.w	d0,$44(a3)
	move.w	#$96,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.10
	neg.w	d1
.10
	move.w	d1,$46(a3)
	bra.w	.25
.11
	move.w	(puckx).w,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.12
	neg.w	d0
.12
	tst.w	d0
	bpl.w	.13
	clr.w	$44(a3)
	clr.w	$46(a3)
	bra.w	.25
.13
	move.w	#$51,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.14
	neg.w	d0
.14
	move.w	d0,$44(a3)
	move.w	#$6C,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.15
	neg.w	d1
.15
	move.w	d1,$46(a3)
	bra.w	.25
.16
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.17
	neg.w	d1
.17
	cmp.w	#$76,d1
	bgt.w	.20
	move.w	#$FFAF,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.18
	neg.w	d0
.18
	move.w	d0,$44(a3)
	move.w	#$96,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.19
	neg.w	d1
.19
	move.w	d1,$46(a3)
	bra.w	.25
.20
	move.w	(puckx).w,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.21
	neg.w	d0
.21
	tst.w	d0
	bmi.w	.22
	clr.w	$44(a3)
	clr.w	$46(a3)
	bra.w	.25
.22
	move.w	#$FFAF,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.23
	neg.w	d0
.23
	move.w	d0,$44(a3)
	move.w	#$6C,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.24
	neg.w	d1
.24
	move.w	d1,$46(a3)
	bra.w	.25
.25
	move.w	$46(a3),d1
	btst	#pfgoal,pflags(a3)
	bne.w	.29
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.26
	adda.w	#$300,a0
.26
	move.w	#5,d2
.loop
	btst	#pf2unav,pflags2(a0)
	bne.w	.28
	tst.b	$65(a0)
	bpl.w	.27
	tst.w	$34(a0)
	bmi.w	.28
.27
	move.w	$2A(a0),d0
	asr.w	#7,d0
	add.w	$14(a0),d0
	cmp.w	d0,d1
	bgt.w	.28
	move.w	d0,d1
.28
	adda.w	#$80,a0
	dbf	d2,.loop
	bra.w	.33
.29
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.30
	adda.w	#$300,a0
.30
	move.w	#5,d2
.loop2
	btst	#pf2unav,pflags2(a0)
	bne.w	.32
	tst.b	$65(a0)
	bpl.w	.31
	tst.w	$34(a0)
	bmi.w	.32
.31
	move.w	$2A(a0),d0
	asr.w	#7,d0
	add.w	$14(a0),d0
	cmp.w	d0,d1
	blt.w	.32
	move.w	d0,d1
.32
	adda.w	#$80,a0
	dbf	d2,.loop2
.33
	move.w	$44(a3),d0
	movea.l	#EvadePC,a0
	jmp	(skateto).l
.34
	rts

assdefo5							;Defenseman on offense, one man short (tmap 5); assdefd5 when his team
									;loses the puck
	btst	#pfalock,pflags(a3)
	bne.w	.34
	cmpi.w	#5,$24(a2)
	beq.w	.2
	move.w	#1,d0
	cmpi.w	#6,$24(a2)
	bne.w	.1
	bra.w	GoAssReplace
.1
	move.w	#$26,d0
	cmpi.w	#4,$24(a2)
	bne.w	.2
	bra.w	GoAssReplace
.2
	btst	#0,(gmode).w
	bne.w	GoDoNothing
	jsr	(check4bench).l
	btst	#pfjoycon,pflags(a3)
	bne.w	.34
	move.w	#$25,d0
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.3
	neg.w	d1
.3
	cmp.w	#$76,d1
	bgt.w	GoAssReplace
	move.w	(puckc).w,d1
	bmi.w	GoAssReplace
	subq.w	#6,d1
	move.w	$52(a3),d2
	subq.w	#6,d2
	eor.w	d2,d1
	bmi.w	GoAssReplace
	bclr	#pfna,pflags(a3)
	beq.w	.4
	clr.w	$40(a3)
	move.w	#8,$42(a3)
.4
	sub.b	d7,$40(a3)
	bpl.w	.25
	move.b	$6B(a3),$40(a3)
	jsr	(ReadGoaliePulled).l
	bmi.w	.5
	btst	#6,(sflags7).w
	beq.w	.6
	tst.b	$40(a3)
	beq.w	.6
.5
	subq.b	#1,$40(a3)
.6
	clr.w	d1
	move.b	$65(a3),d1
	bpl.w	.7
	move.w	$34(a3),d1
	bmi.w	.34
.7
	cmp.w	#2,d1
	bne.w	.16
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.8
	neg.w	d1
.8
	cmp.w	#$76,d1
	bgt.w	.11
	move.w	#$51,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.9
	neg.w	d0
.9
	move.w	d0,$44(a3)
	move.w	#$96,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.10
	neg.w	d1
.10
	move.w	d1,$46(a3)
	bra.w	.25
.11
	move.w	(puckx).w,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.12
	neg.w	d0
.12
	tst.w	d0
	bpl.w	.13
	clr.w	$44(a3)
	clr.w	$46(a3)
	bra.w	.25
.13
	move.w	#$51,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.14
	neg.w	d0
.14
	move.w	d0,$44(a3)
	move.w	#$6C,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.15
	neg.w	d1
.15
	move.w	d1,$46(a3)
	bra.w	.25
.16
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.17
	neg.w	d1
.17
	cmp.w	#$76,d1
	bgt.w	.20
	move.w	#$FFAF,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.18
	neg.w	d0
.18
	move.w	d0,$44(a3)
	move.w	#$96,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.19
	neg.w	d1
.19
	move.w	d1,$46(a3)
	bra.w	.25
.20
	move.w	(puckx).w,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.21
	neg.w	d0
.21
	tst.w	d0
	bmi.w	.22
	clr.w	$44(a3)
	clr.w	$46(a3)
	bra.w	.25
.22
	move.w	#$FFAF,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.23
	neg.w	d0
.23
	move.w	d0,$44(a3)
	move.w	#$6C,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.24
	neg.w	d1
.24
	move.w	d1,$46(a3)
	bra.w	.25
.25
	move.w	$46(a3),d1
	btst	#pfgoal,pflags(a3)
	bne.w	.29
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.26
	adda.w	#$300,a0
.26
	move.w	#5,d2
.loop
	btst	#pf2unav,pflags2(a0)
	bne.w	.28
	tst.b	$65(a0)
	bpl.w	.27
	tst.w	$34(a0)
	bmi.w	.28
.27
	move.w	$2A(a0),d0
	asr.w	#7,d0
	add.w	$14(a0),d0
	cmp.w	d0,d1
	bgt.w	.28
	move.w	d0,d1
.28
	adda.w	#$80,a0
	dbf	d2,.loop
	bra.w	.33
.29
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.30
	adda.w	#$300,a0
.30
	move.w	#5,d2
.loop2
	btst	#pf2unav,pflags2(a0)
	bne.w	.32
	tst.b	$65(a0)
	bpl.w	.31
	tst.w	$34(a0)
	bmi.w	.32
.31
	move.w	$2A(a0),d0
	asr.w	#7,d0
	add.w	$14(a0),d0
	cmp.w	d0,d1
	blt.w	.32
	move.w	d0,d1
.32
	adda.w	#$80,a0
	dbf	d2,.loop2
.33
	move.w	$44(a3),d0
	movea.l	#EvadePC,a0
	jmp	(skateto).l
.34
	rts

assdefd4							;Defenseman on defense, two men short (tmap 4); assdefo4 when his team
									;gets the puck
	btst	#pfalock,pflags(a3)
	bne.w	.17
	cmpi.w	#4,$24(a2)
	beq.w	.2
	move.w	#2,d0
	cmpi.w	#6,$24(a2)
	bne.w	.1
	bra.w	GoAssReplace
.1
	move.w	#$25,d0
	cmpi.w	#5,$24(a2)
	bne.w	.2
	bra.w	GoAssReplace
.2
	btst	#gmclock,(gmode).w		;gmclock - check if clock is running
	bne.w	GoDoNothing				;exit if stoppage
	jsr	(check4bench).l
	btst	#pfjoycon,$62(a3)		;pfjoycon - check if joystick controlled
	bne.w	.17						;exit if joystick controlled
	bclr	#pfna,$62(a3)			;pfna - new assignment
	beq.w	.3						;branch if no new assignment
	clr.w	$40(a3)					;clear temp1
	move.w	#8,$42(a3)				;move 8 into temp2
	;count down the timer
.3
	sub.b	d7,$40(a3)				;subtract d7 from temp1
	bpl.w	.14
	move.b	$6C(a3),$40(a3)
	btst	#6,(sflags7).w			;check for crowd record flag
	beq.w	.4						;jump if not set
	tst.b	$40(a3)					;check if 0
	beq.w	.4
	subq.b	#1,$40(a3)				;subtract 1 from temp1
	;center on defense: switch to asscentero if our team has the puck
.4
	move.w	(puckc).w,d1			;move puck carrier SCnum into d1
	bmi.w	.6
	moveq	#$26,d0
	subq.w	#6,d1					;subtract 6 from d1
	move.w	$52(a3),d2				;move player's SCnum into d2
	subq.w	#6,d2					;subtract 6 from d2
	eor.w	d2,d1					;compare d2 and d1
	bmi.w	.6
	move.w	(puckvy).w,d1
	asr.w	#8,d1
	add.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.5
	neg.w	d1
.5
	cmp.w	#$76,d1
	blt.w	GoAssReplace
.6
	clr.w	d0
	move.b	$65(a3),d0
	bpl.w	.7
	move.w	$34(a3),d0
	bmi.w	.17
.7
	cmp.w	#2,d0
	beq.w	.13
	move.w	#$FFFF,d1
.loop
	move.w	(puckx).w,d0			;Ypos of puck
	btst	#pfgoal,$62(a3)			;pfgoal - check which net to shoot on
	bne.w	.8						;branch if top net
	neg.w	d1						;negate d2 if shooting on bottom net
.8
	move.w	d1,$44(a3)
	eor.w	d0,d1
	bpl.w	.10
	move.w	#$FF14,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.9
	neg.w	d1
.9
	move.w	d1,$46(a3)
	bra.w	.14
.10
	movea.l	#SortCords,a0
	move.w	(puckc).w,d0
	bpl.w	.11
	move.w	#$E,d0
.11
	asl.w	#7,d0
	adda.w	d0,a0
	move.w	$28(a0),d0
	asr.w	#7,d0
	add.w	(a0),d0
	ext.l	d0
	divs.w	#3,d0
	move.w	d0,$44(a3)
	move.w	#$11E,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.12
	neg.w	d0
.12
	move.w	$2A(a0),d1
	asr.w	#7,d1
	add.w	$14(a0),d1
	sub.w	d0,d1
	ext.l	d1
	divs.w	#3,d1
	add.w	d1,d0
	move.w	d0,$46(a3)
	bra.w	.14
.13
	move.w	#1,d1
	bra.w	.loop
.14
	move.w	$44(a3),d0
	move.w	$46(a3),d1
	movea.l	#EvadePC,a0
	move.b	$6A(a3),-(sp)
	cmpi.l	#$15F9,$2A(a2)
	blt.w	.15
	move.b	#$1E,$6A(a3)
.15
	jsr	(skateto).l
	move.b	(sp)+,$6A(a3)
	move.w	$14(a3),d0
	btst	#pfgoal,pflags(a3)
	beq.w	.16
	neg.w	d0
.16
	cmp.w	#$76,d0
	bgt.w	.17
	jmp	(check4check).l
.17
	rts

assdefd5							;Defenseman on defense, one man short (tmap 5); assdefo5 when his team
									;gets the puck
	btst	#pfalock,pflags(a3)
	bne.w	.17
	cmpi.w	#5,$24(a2)
	beq.w	.2
	move.w	#2,d0
	cmpi.w	#6,$24(a2)
	bne.w	.1
	bra.w	GoAssReplace
.1
	move.w	#$27,d0
	cmpi.w	#4,$24(a2)
	bne.w	.2
	bra.w	GoAssReplace
.2
	btst	#gmclock,(gmode).w		;gmclock - check if clock is running
	bne.w	GoDoNothing				;exit if stoppage
	jsr	(check4bench).l
	btst	#pfjoycon,$62(a3)		;pfjoycon - check if joystick controlled
	bne.w	.17						;exit if joystick controlled
	bclr	#pfna,$62(a3)			;pfna - new assignment
	beq.w	.3						;branch if no new assignment
	clr.w	$40(a3)					;clear temp1
	move.w	#8,$42(a3)				;move 8 into temp2
	;count down the timer
.3
	sub.b	d7,$40(a3)				;subtract d7 from temp1
	bpl.w	.14
	move.b	$6C(a3),$40(a3)
	btst	#6,(sflags7).w			;check for crowd record flag
	beq.w	.4						;jump if not set
	tst.b	$40(a3)					;check if 0
	beq.w	.4
	subq.b	#1,$40(a3)				;subtract 1 from temp1
	;center on defense: switch to asscentero if our team has the puck
.4
	move.w	(puckc).w,d1			;move puck carrier SCnum into d1
	bmi.w	.6
	moveq	#$24,d0
	subq.w	#6,d1					;subtract 6 from d1
	move.w	$52(a3),d2				;move player's SCnum into d2
	subq.w	#6,d2					;subtract 6 from d2
	eor.w	d2,d1					;compare d2 and d1
	bmi.w	.6
	move.w	(puckvy).w,d1
	asr.w	#8,d1
	add.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.5
	neg.w	d1
.5
	cmp.w	#$76,d1
	blt.w	GoAssReplace
.6
	clr.w	d0
	move.b	$65(a3),d0
	bpl.w	.7
	move.w	$34(a3),d0
	bmi.w	.17
.7
	cmp.w	#2,d0
	beq.w	.13
	move.w	#$FFFF,d1
.loop
	move.w	(puckx).w,d0			;Ypos of puck
	btst	#pfgoal,$62(a3)			;pfgoal - check which net to shoot on
	bne.w	.8						;branch if top net
	neg.w	d1						;negate d2 if shooting on bottom net
.8
	move.w	d1,$44(a3)
	eor.w	d0,d1
	bpl.w	.10
	move.w	#$FF14,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.9
	neg.w	d1
.9
	move.w	d1,$46(a3)
	bra.w	.14
.10
	movea.l	#SortCords,a0
	move.w	(puckc).w,d0
	bpl.w	.11
	move.w	#$E,d0
.11
	asl.w	#7,d0
	adda.w	d0,a0
	move.w	$28(a0),d0
	asr.w	#7,d0
	add.w	(a0),d0
	asr.w	#1,d0
	move.w	d0,$44(a3)
	move.w	#$11E,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.12
	neg.w	d0
.12
	move.w	$2A(a0),d1
	asr.w	#7,d1
	add.w	$14(a0),d1
	sub.w	d0,d1
	asr.w	#1,d1
	add.w	d1,d0
	move.w	d0,$46(a3)
	bra.w	.14
.13
	move.w	#1,d1
	bra.w	.loop
.14
	move.w	$44(a3),d0
	move.w	$46(a3),d1
	movea.l	#EvadePC,a0
	move.b	$6A(a3),-(sp)
	cmpi.l	#$15F9,$2A(a2)
	blt.w	.15
	move.b	#$1E,$6A(a3)
.15
	jsr	(skateto).l
	move.b	(sp)+,$6A(a3)
	move.w	$14(a3),d0
	btst	#pfgoal,pflags(a3)
	beq.w	.16
	neg.w	d0
.16
	cmp.w	#$76,d0
	blt.w	.17
	jmp	(check4check).l
.17
	rts

assdefd								;Defenseman on defense (tmap 5 / 4: assdefd5 / assdefd4); assdefo when his
									;team carries the puck up; ends in
									;check4check
	cmpi.w	#6,$24(a2)
	beq.w	.2
	move.w	#$25,d0
	cmpi.w	#5,$24(a2)
	bne.w	.1
	bra.w	GoAssReplace
.1
	move.w	#$27,d0
	cmpi.w	#4,$24(a2)
	bne.w	.2
	bra.w	GoAssReplace
.2
	btst	#pfalock,pflags(a3)
	bne.w	.35
	btst	#0,(gmode).w
	bne.w	GoDoNothing
	jsr	(check4bench).l
	btst	#pfjoycon,pflags(a3)
	bne.w	.35
	jsr	(GetRoleAss).l
	bne.w	GoAssReplace
	bclr	#pfna,pflags(a3)
	beq.w	.3
	clr.w	$40(a3)
	move.w	#8,$42(a3)
.3
	btst	#4,$30(a2)
	bne.w	.5
	move.w	(puckc).w,d1
	bmi.w	.5
	cmpi.b	#4,$40(a3)
	bge.w	.5
	moveq	#1,d0
	subq.w	#6,d1
	move.w	$52(a3),d2
	subq.w	#6,d2
	eor.w	d2,d1
	bmi.w	.5
	move.w	(puckvy).w,d1
	asr.w	#8,d1
	add.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.4
	neg.w	d1
.4
	cmp.w	#$76,d1
	blt.w	GoAssReplace
.5
	sub.b	d7,$40(a3)
	bpl.w	.31
	move.b	$6C(a3),$40(a3)
	btst	#6,(sflags7).w
	beq.w	.6
	tst.b	$40(a3)
	beq.w	.6
	subq.b	#1,$40(a3)
.6
	st	(LastCarrierAway+2).w
	clr.w	d0
	move.b	$65(a3),d0
	bpl.w	.7
	move.w	$34(a3),d0
	bmi.w	.35
.7
	cmp.w	#2,d0
	bne.w	.17
	move.w	#1,d1
	move.w	(puckx).w,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.8
	neg.w	d1
.8
	move.w	d1,$44(a3)
	eor.w	d0,d1
	bpl.w	.10
	move.w	#$FF14,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.9
	neg.w	d1
.9
	move.w	d1,$46(a3)
	move.w	$52(a3),(LastCarrierAway+2).w
	movem.w	d0,-(sp)
	move.w	$28(a3),d0
	or.w	$2A(a3),d0
	movem.w	(sp)+,d0
	bne.w	.27
	jsr	(FacePuck).l
	bra.w	.27
.10
	move.w	#3,d0
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.11
	adda.w	#$300,a0
.11
	bsr.w	asswingoCheckSlot
	move.w	$14(a0),d0
	btst	#pfgoal,pflags(a3)
	beq.w	.12
	neg.w	d0
.12
	cmp.w	#$11E,d0
	blt.w	.14
	move.w	#$F6,d1
	move.w	#$FFC3,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.13
	neg.w	d1
	neg.w	d0
.13
	move.w	d0,$44(a3)
	move.w	d1,$46(a3)
	bra.w	.31
.14
	move.w	(a0),d0
	asr.w	#1,d0
	move.w	d0,$44(a3)
	move.w	#$11E,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.15
	neg.w	d1
.15
	sub.w	$14(a0),d1
	asr.w	#1,d1
	move.w	#$11E,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.16
	neg.w	d0
.16
	neg.w	d1
	add.w	d0,d1
	move.w	d1,$46(a3)
	bra.w	.27
.17
	move.w	#$FFFF,d1
	move.w	(puckx).w,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.18
	neg.w	d1
.18
	move.w	d1,$44(a3)
	eor.w	d0,d1
	bpl.w	.20
	move.w	#$FF14,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.19
	neg.w	d1
.19
	move.w	d1,$46(a3)
	move.w	$52(a3),(LastCarrierAway+2).w
	movem.w	d0,-(sp)
	move.w	$28(a3),d0
	or.w	$2A(a3),d0
	movem.w	(sp)+,d0
	bne.w	.27
	jsr	(FacePuck).l
	bra.w	.27
.20
	move.w	#5,d0
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.21
	adda.w	#$300,a0
.21
	bsr.w	asswingoCheckSlot
	move.w	$14(a0),d0
	btst	#pfgoal,pflags(a3)
	beq.w	.22
	neg.w	d0
.22
	cmp.w	#$11E,d0
	blt.w	.24
	move.w	#$F6,d1
	move.w	#$3D,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.23
	neg.w	d1
	neg.w	d0
.23
	move.w	d0,$44(a3)
	move.w	d1,$46(a3)
	bra.w	.31
.24
	move.w	(a0),d0
	asr.w	#1,d0
	move.w	d0,$44(a3)
	move.w	#$11E,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.25
	neg.w	d1
.25
	sub.w	$14(a0),d1
	asr.w	#1,d1
	move.w	#$11E,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.26
	neg.w	d0
.26
	neg.w	d1
	add.w	d0,d1
	move.w	d1,$46(a3)
.27
	cmpi.w	#$11E,(pucky).w
	bgt.w	.33
	cmpi.w	#$FEE2,(pucky).w
	blt.w	.33
	move.w	(puckc).w,d0
	bmi.w	.28
	asl.w	#7,d0
	movea.l	#SortCords,a0
	adda.w	d0,a0
	tst.w	$34(a0)
	beq.w	.33
.28
	move.w	$46(a3),d1
	move.w	(pucky).w,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.29
	neg.w	d1
	neg.w	d0
.29
	addi.w	#$A,d0
	cmp.w	d0,d1
	bgt.w	.33
	btst	#pfgoal,pflags(a3)
	beq.w	.30
	neg.w	d0
.30
	move.w	d0,$46(a3)
.31
	move.w	$44(a3),d0
	move.w	$46(a3),d1
	movea.l	#EvadePC,a0
	move.b	$6A(a3),-(sp)
	cmpi.l	#$15F9,$2A(a2)
	blt.w	.32
	move.b	#$1E,$6A(a3)
.32
	jsr	(skateto).l
	move.b	(sp)+,$6A(a3)
	rts
.33
	move.w	$44(a3),d0
	move.w	$46(a3),d1
	movea.l	#EvadePC,a0
	move.b	$6A(a3),-(sp)
	cmpi.l	#$15F9,$2A(a2)
	blt.w	.34
	move.b	#$1E,$6A(a3)
.34
	jsr	(skateto).l
	move.b	(sp)+,$6A(a3)
	jmp	(check4check).l
.35
	rts

asswingd							;Winger on defense (tmap 5 / 4: asswingd5 / asswingd4); asswingo when his
									;team gets the puck
	cmpi.w	#6,$24(a2)
	beq.w	.2
	move.w	#$28,d0
	cmpi.w	#5,$24(a2)
	bne.w	.1
	bra.w	GoAssReplace
.1
	move.w	#$29,d0
	cmpi.w	#4,$24(a2)
	bne.w	.2
	bra.w	GoAssReplace
.2
	btst	#pfalock,$62(a3)
	bne.w	.34
	btst	#gmclock,(gmode).w
	bne.w	GoDoNothing
	jsr	(check4bench).l
	btst	#pfjoycon,$62(a3)
	bne.w	.34
	jsr	(GetRoleAss).l
	bne.w	GoAssReplace
	bclr	#pfna,$62(a3)
	beq.w	.3
	clr.w	$40(a3)
	move.w	#8,$42(a3)
.3
	move.w	(puckc).w,d1
	bmi.w	.4
	moveq	#4,d0					;acentero
	subq.w	#6,d1
	move.w	$52(a3),d2
	subq.w	#6,d2
	eor.w	d2,d1
	bpl.w	GoAssReplace			;our team has puck
.4
	sub.b	d7,$40(a3)
	bpl.w	.33
	move.b	$6C(a3),$40(a3)
	btst	#6,(sflags7).w
	beq.w	.5
	tst.b	$40(a3)
	beq.w	.5
	subq.b	#1,$40(a3)
.5
	clr.w	d1
	move.b	$65(a3),d1
	bpl.w	.6
	move.w	$34(a3),d1
	bmi.w	.34
.6
	cmp.w	#5,d1
	bne.w	.17
	move.w	#1,d1
	move.w	(puckx).w,d0
	btst	#pfgoal,$62(a3)
	bne.w	.7
	neg.w	d1
.7
	eor.w	d0,d1
	bmi.w	.14
	btst	#4,$30(a1)
	bne.w	.31
	move.w	#$76,d0
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.8
	neg.w	d1
.8
	cmp.w	d0,d1
	blt.w	.28
.loop
	move.w	#1,d0
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.9
	adda.w	#$300,a0
.9
	bsr.w	asswingoCheckSlot
	move.w	$14(a0),d0
	btst	#pfgoal,pflags(a3)
	beq.w	.10
	neg.w	d0
.10
	cmp.w	#$11E,d0
	blt.w	.12
	move.w	(a0),d0
	move.w	#$E2,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.11
	neg.w	d1
.11
	bra.w	.32
.12
	move.w	(a0),d1
	asr.w	#2,d1
	move.w	d1,d0
	add.w	d1,d0
	add.w	d1,d0
	move.w	d0,-(sp)
	move.w	$14(a0),d0
	move.w	#$11E,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.13
	neg.w	d1
.13
	move.w	d1,-(sp)
	sub.w	d0,d1
	asr.w	#2,d1
	move.w	d1,d0
	add.w	d1,d0
	add.w	d1,d0
	sub.w	(sp)+,d0
	neg.w	d0
	move.w	d0,d1
	move.w	(sp)+,d0
	bra.w	.32
.14
	move.w	#$51,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.15
	neg.w	d0
.15
	btst	#4,$30(a1)
	bne.w	.29
	movem.w	d0,-(sp)
	move.w	#$76,d0
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.16
	neg.w	d1
.16
	cmp.w	d0,d1
	movem.w	(sp)+,d0
	blt.w	.29
	bra.w	.loop
.17
	move.w	#1,d1
	move.w	(puckx).w,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.18
	neg.w	d1
.18
	eor.w	d0,d1
	bmi.w	.25
	btst	#4,$30(a1)
	bne.w	.31
	move.w	#$76,d0
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.19
	neg.w	d1
.19
	cmp.w	d0,d1
	blt.w	.28
.loop2
	move.w	#2,d0
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.20
	adda.w	#$300,a0
.20
	bsr.w	asswingoCheckSlot
	move.w	$14(a0),d0
	btst	#pfgoal,pflags(a3)
	beq.w	.21
	neg.w	d0
.21
	cmp.w	#$11E,d0
	blt.w	.23
	move.w	(a0),d0
	move.w	#$3A,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.22
	neg.w	d1
.22
	bra.w	.32
.23
	move.w	(a0),d1
	asr.w	#2,d1
	move.w	d1,d0
	add.w	d1,d0
	add.w	d1,d0
	move.w	d0,-(sp)
	move.w	$14(a0),d0
	move.w	#$11E,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.24
	neg.w	d1
.24
	move.w	d1,-(sp)
	sub.w	d0,d1
	asr.w	#2,d1
	move.w	d1,d0
	add.w	d1,d0
	add.w	d1,d0
	sub.w	(sp)+,d0
	neg.w	d0
	move.w	d0,d1
	move.w	(sp)+,d0
	bra.w	.32
.25
	move.w	#$51,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.26
	neg.w	d0
.26
	btst	#4,$30(a1)
	bne.w	.29
	movem.w	d0,-(sp)
	move.w	#$76,d0
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.27
	neg.w	d1
.27
	cmp.w	d0,d1
	movem.w	(sp)+,d0
	blt.w	.29
	bra.w	.loop2
.28
	move.w	(puckx).w,d0
.29
	move.w	#$67,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.30
	neg.w	d1
.30
	bra.w	.32
.31
	move.w	(puckvx).w,d0
	asr.w	#8,d0
	add.w	(puckx).w,d0
	move.w	(puckvy).w,d1
	asr.w	#8,d1
	add.w	(pucky).w,d1
.32
	move.w	d0,$44(a3)
	move.w	d1,$46(a3)
.33
	move.w	$44(a3),d0
	move.w	$46(a3),d1
	lea	.34(pc),a0
	jmp	(skateto).l
.34
	rts

asscenterd							;Center on defense (tmap 5 / 4: asscenterd5 / asscenterd4); asscentero
									;when his team gets the puck
	cmpi.w	#6,$24(a2)
	beq.w	.2
	move.w	#$2C,d0
	cmpi.w	#5,$24(a2)
	bne.w	.1
	bra.w	GoAssReplace
.1
	move.w	#$2D,d0
	cmpi.w	#4,$24(a2)
	bne.w	.2
	bra.w	GoAssReplace
.2
	btst	#pfalock,$62(a3)		;pfalock - locked animation
	bne.w	.21						;exit if locked
	btst	#gmclock,(gmode).w		;gmclock - check if clock is running
	bne.w	GoDoNothing				;exit if stoppage
	jsr	(check4bench).l
	btst	#pfjoycon,$62(a3)		;pfjoycon - check if joystick controlled
	bne.w	.21
	jsr	(GetRoleAss).l
	bne.w	GoAssReplace			;exit if joystick controlled
	bclr	#pfna,$62(a3)			;pfna - new assignment
	beq.w	.3						;branch if no new assignment
	clr.w	$40(a3)					;clear temp1
	move.w	#8,$42(a3)				;move 8 into temp2
	;count down the timer
.3
	sub.b	d7,$40(a3)				;subtract d7 from temp1
	bpl.w	.19
	move.b	$6C(a3),$40(a3)
	btst	#6,(sflags7).w			;check for crowd record flag
	beq.w	.4						;jump if not set
	tst.b	$40(a3)					;check if 0
	beq.w	.4
	subq.b	#1,$40(a3)				;subtract 1 from temp1
	;center on defense: switch to asscentero if our team has the puck
.4
	move.w	(puckc).w,d1			;move puck carrier SCnum into d1
	bmi.w	.5
	moveq	#6,d0					;asscentero
	subq.w	#6,d1					;subtract 6 from d1
	move.w	$52(a3),d2				;move player's SCnum into d2
	subq.w	#6,d2					;subtract 6 from d2
	eor.w	d2,d1					;compare d2 and d1
	bpl.w	GoAssReplace			;if team has puck, replace assignment with acentero
	;no carrier or the other team has it: cover between the puck and our net
.5
	move.w	(puckc).w,d1			;Xpos of puck
	bmi.w	.6
	asl.w	#7,d1
	movea.l	#SortCords,a0
	adda.w	d1,a0
	tst.w	$34(a0)
	bne.w	.6
	move.b	$62(a0),d1
	move.b	$62(a3),d0
	eor.b	d1,d0
	btst	#6,d0
	beq.w	.6
	clr.w	d0
	clr.w	d1
	bra.w	.18
.6
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.7
	neg.w	d1
.7
	cmp.w	#$76,d1
	bgt.w	.10
	move.w	(puckx).w,d0
	cmp.w	#$19,d0
	bgt.w	.8
	cmp.w	#$FFE7,d0
	blt.w	.8
	move.w	(puckvx).w,d0
	asr.w	#8,d0
	add.w	(puckx).w,d0
	move.w	(puckvy).w,d1
	asr.w	#8,d1
	add.w	(pucky).w,d1
	bra.w	.18
.8
	clr.w	d0
	move.w	#$6C,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.9
	neg.w	d1
.9
	bra.w	.18
.10
	move.w	#4,d0
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.11
	adda.w	#$300,a0
.11
	bsr.w	asswingoCheckSlot
	move.w	(pucky).w,d0
	btst	#pfgoal,pflags(a3)
	beq.w	.12
	neg.w	d0
.12
	cmp.w	#$11E,d0
	blt.w	.14
	clr.w	d0
	move.w	#$E7,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.13
	neg.w	d1
.13
	bra.w	.18
.14
	move.w	$14(a0),d0
	btst	#pfgoal,pflags(a3)
	beq.w	.15
	neg.w	d0
.15
	cmp.w	#$11E,d0
	blt.w	.17
	move.w	(a0),d0
	move.w	#$F1,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.16
	neg.w	d1
.16
	bra.w	.18
.17
	move.w	(puckx).w,d0
	sub.w	(a0),d0
	asr.w	#3,d0
	move.w	d0,d1
	add.w	d1,d0
	add.w	d1,d0
	add.w	(a0),d0
	move.w	(pucky).w,d1
	sub.w	$14(a0),d1
	asr.w	#3,d1
	move.w	d1,-(sp)
	add.w	(sp),d1
	add.w	(sp)+,d1
	add.w	$14(a0),d1
.18
	move.w	d0,$44(a3)
	move.w	d1,$46(a3)
.19
	move.w	$44(a3),d0
	move.w	$46(a3),d1
	lea	.21(pc),a0
	move.b	$6A(a3),-(sp)
	cmpi.l	#$15F9,$2A(a2)
	blt.w	.20
	move.b	#$1E,$6A(a3)
.20
	jsr	(skateto).l
	move.b	(sp)+,$6A(a3)
.21
	rts

assdefo								;Defenseman on offense (tmap 5 / 4: assdefo5 / assdefo4); assdefd when his
									;team loses the puck or it leaves the
									;zone
	cmpi.w	#6,$24(a2)
	beq.w	.2
	move.w	#$24,d0
	cmpi.w	#5,$24(a2)
	bne.w	.1
	bra.w	GoAssReplace
.1
	move.w	#$26,d0
	cmpi.w	#4,$24(a2)
	bne.w	.2
	bra.w	GoAssReplace
.2
	btst	#pfalock,pflags(a3)
	bne.w	.25
	btst	#0,(gmode).w
	bne.w	GoDoNothing
	jsr	(check4bench).l
	btst	#pfjoycon,pflags(a3)
	bne.w	.25
	jsr	(GetRoleAss).l
	bne.w	GoAssReplace
	moveq	#2,d0
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.3
	neg.w	d1
.3
	cmp.w	#$76,d1
	bgt.w	GoAssReplace
	move.w	(puckc).w,d1
	bmi.w	GoAssReplace
	subq.w	#6,d1
	move.w	$52(a3),d2
	subq.w	#6,d2
	eor.w	d2,d1
	bmi.w	GoAssReplace
	bclr	#pfna,pflags(a3)
	beq.w	.4
	clr.w	$40(a3)
	move.w	#8,$42(a3)
.4
	sub.b	d7,$40(a3)
	bpl.w	.24
	move.b	$6B(a3),$40(a3)
	jsr	(ReadGoaliePulled).l
	bmi.w	.5
	btst	#6,(sflags7).w
	beq.w	.6
	tst.b	$40(a3)
	beq.w	.6
.5
	subq.b	#1,$40(a3)
.6
	movea.l	#EvadePC,a0
	clr.w	d1
	move.b	$65(a3),d1
	bpl.w	.7
	move.w	$34(a3),d1
	bmi.w	.25
.7
	cmp.w	#2,d1
	beq.w	.14
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.8
	neg.w	d1
.8
	cmp.w	#$76,d1
	bgt.w	.10
	move.w	#$FFAF,d0
	move.w	#$FF8A,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.9
	neg.w	d0
	neg.w	d1
.9
	bra.w	.21
.10
	move.w	#$80,d1
	move.w	#$FF88,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.11
	neg.w	d0
	neg.w	d1
.11
	bra.w	.12
	movem.l	d0/a0,-(sp)
	move.w	#5,d0
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.26
	adda.w	#$300,a0
.26
	bsr.w	asswingoCheckSlot
	move.w	$14(a0),d2
	btst	#pfgoal,pflags(a3)
	bne.w	.27
	addi.w	#$F,d2
	bra.w	.28
.27
	subi.w	#$F,d2
.28
	movem.l	(sp)+,d0/a0
	btst	#pfgoal,pflags(a3)
	bne.w	.29
	cmp.w	d1,d2
	blt.w	assdefoLeftSide
	bra.w	.30
.29
	cmp.w	d1,d2
	bgt.w	assdefoLeftSide
.30
	move.w	d2,d1
assdefoLeftSide	equ	*			;Defense wing: pick the x offset on the left side relative to the puck (low confidence)
.12
	move.w	(puckx).w,d2
	eor.w	d0,d2
	bpl.w	.13
	move.w	#$FFF6,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.13
	neg.w	d0
.13
	bra.w	.21
.14
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.15
	neg.w	d1
.15
	cmp.w	#$76,d1
	bgt.w	.17
	move.w	#$51,d0
	move.w	#$FF8A,d1
	btst	#pfgoal,pflags(a3)
	bne.w	.16
	neg.w	d0
	neg.w	d1
.16
	bra.w	.21
.17
	move.w	#$80,d1
	move.w	#$78,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.18
	neg.w	d0
	neg.w	d1
.18
	bra.w	.19
	movem.l	d0/a0,-(sp)
	move.w	#3,d0
	movea.l	#SortCords,a0
	btst	#pfteam,pflags(a3)
	bne.w	.31
	adda.w	#$300,a0
.31
	bsr.w	asswingoCheckSlot
	move.w	$14(a0),d2
	btst	#pfgoal,pflags(a3)
	bne.w	.32
	addi.w	#$F,d2
	bra.w	.33
.32
	subi.w	#$F,d2
.33
	movem.l	(sp)+,d0/a0
	btst	#pfgoal,pflags(a3)
	bne.w	.34
	cmp.w	d1,d2
	blt.w	assdefoRightSide
	bra.w	.35
.34
	cmp.w	d1,d2
	bgt.w	assdefoRightSide
.35
	move.w	d2,d1
assdefoRightSide	equ	*			;Defense wing: pick the x offset on the right side relative to the puck (low confidence)
.19
	move.w	(puckx).w,d2
	eor.w	d0,d2
	bpl.w	.20
	move.w	#$A,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.20
	neg.w	d0
.20
	bra.w	.21
.21
	btst	#4,$30(a2)
	beq.w	.23
	btst	#pfgoal,pflags(a3)
	bne.w	.22
	cmp.w	(pucky).w,d1
	bgt.w	.23
	move.w	(pucky).w,d1
	addi.w	#$A,d1
	bra.w	.23
.22
	cmp.w	(pucky).w,d1
	blt.w	.23
	move.w	(pucky).w,d1
	subi.w	#$A,d1
.23
	move.w	d0,$44(a3)
	move.w	d1,$46(a3)
.24
	move.w	$44(a3),d0
	move.w	$46(a3),d1
	movea.l	#EvadePC,a0
	jmp	(skateto).l
.25
	rts

asscentero							;Center on offense (tmap 5 / 4: asscentero5 / asscentero4): a random spot
									;ahead of the puck; asscenterd when it
									;is lost
	cmpi.w	#6,$24(a2)
	beq.w	.2
	move.w	#$2E,d0
	cmpi.w	#5,$24(a2)
	bne.w	.1
	bra.w	GoAssReplace
.1
	move.w	#$2F,d0
	cmpi.w	#4,$24(a2)
	bne.w	.2
	bra.w	GoAssReplace
.2
	btst	#pfalock,$62(a3)		;check if locked in animation
	bne.w	.11						;exit if so
	btst	#gmclock,(gmode).w		;check game clock
	bne.w	GoDoNothing				;donothing if stopped
	jsr	(check4bench).l				;check if player going to bench
	btst	#pfjoycon,$62(a3)		;check if joystick controlled
	bne.w	.11
	jsr	(GetRoleAss).l
	bne.w	GoAssReplace			;exit if so
	bclr	#pfna,$62(a3)			;clear new assignment bit
	beq.w	.3						;branch if it was already cleared
	st	$48(a3)						;set old zone # (temp5)
	clr.w	$40(a3)					;clear temp1
	move.w	#8,$42(a3)				;move 8 into temp2
.3
	sub.b	d7,$40(a3)				;subtract frames elapsed from temp1
	bpl.w	.9						;branch if positive
	move.b	$6C(a3),$40(a3)
	btst	#6,(sflags7).w			;check if crowd meter currently broken
	beq.w	.4
	tst.b	$40(a3)					;check if temp1 is 0
	beq.w	.4
	subq.b	#1,$40(a3)				;subtract 1 from temp1
.4
	move.w	(puckc).w,d1
	bmi.w	.5
	moveq	#5,d0
	subq.w	#6,d1					;sub 6 from d1
	move.w	$52(a3),d2				;move SCnum into d2
	subq.w	#6,d2					;sub 6 from d2
	eor.w	d2,d1					;EOR d2 with d1. Checks if puckc on same team
	bmi.w	GoAssReplace			;if not, branch to assreplace
.5
	move.w	(puckvy).w,d0			;pucky into d0
	asr.w	#8,d0
	add.w	(pucky).w,d0
	btst	#pfgoal,pflags(a3)
	bne.w	.6
	neg.w	d0						;negate d3
.6
	clr.w	d2						;clear zone number
	cmp.w	#$FF8A,d0
	blt.w	.7						;branch if in defensive zone
	addq.w	#8,d2					;add 8 to d2 (d2 = 8)
	cmp.w	#$76,d0
	blt.w	.7						;branch if in neutral zone
	btst	#4,$30(a2)				;check bit 4 of offset 30 (currently offside)
	;(C6FE Home, CA62 Away)
	bne.w	.7						;branch if set
	addq.w	#8,d2					;add 8 to d2 (d2 = $10)
	cmp.w	#$11E,d0
	blt.w	.7						;branch if in offensive zone
	addq.w	#8,d2					;add 8 to d2 (d2 = $18)
.7
	cmp.w	$48(a3),d2				;compare temp5 with d2
	bne.w	.8						;branch if different zone
	move.w	(Vcount).w,d0
	andi.w	#$7F,d0
	cmp.w	#2,d0
	bgt.w	.9
	;movement in zone while waiting
.8
	move.w	d2,$48(a3)				;move d2 into temp5
	lea	.table(pc),a0				;move zonedata address into a0
	move.w	2(a0,d2.w),d0			;move X Coord into d0
	jsr	(randomd0s).l				;RNG d0
	add.w	(a0,d2.w),d0			;add X Coord offset to d0
	move.w	d0,$44(a3)				;move d0 into temp3
	move.w	6(a0,d2.w),d0			;move Y Coord into d0
	jsr	(randomd0s).l				;RNG d0
	add.w	4(a0,d2.w),d0			;add Y Coord offset into d0
	move.w	d0,$46(a3)
	bra.w	.9
.table
	dc.w	$0000,$003C,$FFBA,$000A,$0000,$003C,$003C,$000A
	dc.w	$0000,$0028,$00CB,$001E,$0000,$0050,$00CB,$0014
.9
	move.w	$44(a3),d0
	move.w	$46(a3),d1				;move temp4 into d1
	btst	#pfgoal,$62(a3)			;check if shooting up or down
	bne.w	.10						;branch if shooting up
	neg.w	d1						;negate d0
.10
	movea.l	#EvadePC,a0
	jmp	(skateto).l
.11
	rts

asswingo							;Winger on offense (tmap 5 / 4: asswingo5 / asswingo4): a random spot in
									;the puck zone; asswingd when the puck
									;is lost
	cmpi.w	#6,$24(a2)
	beq.w	.2
	move.w	#$2A,d0
	cmpi.w	#5,$24(a2)
	bne.w	.1
	bra.w	GoAssReplace
.1
	move.w	#$2B,d0
	cmpi.w	#4,$24(a2)
	bne.w	.2
	bra.w	GoAssReplace
.2
	btst	#pfalock,$62(a3)		;check if locked in animation
	bne.w	.13						;exit if so
	btst	#gmclock,(gmode).w		;check game clock
	bne.w	GoDoNothing				;donothing if stopped
	jsr	(check4bench).l				;check if player going to bench
	btst	#pfjoycon,$62(a3)		;check if joystick controlled
	bne.w	.13
	jsr	(GetRoleAss).l
	bne.w	GoAssReplace			;exit if so
	bclr	#pfna,$62(a3)			;clear new assignment bit
	beq.w	.3						;branch if it was already cleared
	st	$48(a3)						;set old zone # (temp5)
	clr.w	$40(a3)					;clear temp1
	move.w	#8,$42(a3)				;move 8 into temp2
.3
	sub.b	d7,$40(a3)				;subtract frames elapsed from temp1
	bpl.w	.9						;branch if positive
	move.b	$6C(a3),$40(a3)
	btst	#6,(sflags7).w			;check if crowd meter currently broken
	beq.w	.4
	tst.b	$40(a3)					;check if temp1 is 0
	beq.w	.4
	subq.b	#1,$40(a3)				;subtract 1 from temp1
.4
	moveq	#3,d0
	move.w	(puckc).w,d1			;move puckc SCnum into d1
	bmi.w	.5						;branch if no puckc
	subq.w	#6,d1					;sub 6 from d1
	move.w	$52(a3),d2				;move SCnum into d2
	subq.w	#6,d2					;sub 6 from d2
	eor.w	d2,d1					;EOR d2 with d1. Checks if puckc on same team
	bmi.w	GoAssReplace			;if not, branch to assreplace
.5
	move.w	(pucky).w,d0			;pucky into d0
	move.w	(puckvy).w,d3			;puckvy into d3
	asr.w	#6,d3					;divide d3 by 64
	add.w	d0,d3					;add d0 to d3
	btst	#pfgoal,$62(a3)			;check which goal shooting on
	bne.w	.6						;branch if top goal
	neg.w	d0						;negate d0
	neg.w	d3						;negate d3
.6
	clr.w	d2						;clear zone number
	cmp.w	#$FF8A,d3
	blt.w	.7						;branch if in defensive zone
	addq.w	#8,d2					;add 8 to d2 (d2 = 8)
	cmp.w	#$76,d0
	blt.w	.7						;branch if in neutral zone
	btst	#4,$30(a2)				;check bit 4 of offset 30 (currently offside)
	;(C6FE Home, CA62 Away)
	bne.w	.7						;branch if set
	addq.w	#8,d2					;add 8 to d2 (d2 = $10)
	cmp.w	#$11E,d3
	blt.w	.7						;branch if in offensive zone
	addq.w	#8,d2					;add 8 to d2 (d2 = $18)
.7
	cmp.w	$48(a3),d2				;compare temp5 with d2
	bne.w	.8						;branch if different zone
	move.w	(Vcount).w,d0
	andi.w	#$7F,d0
	cmp.w	#2,d0
	bgt.w	.9
	;movement in zone while waiting
.8
	move.w	d2,$48(a3)				;move d2 into temp5
	lea	.table(pc),a0				;move zonedata address into a0
	move.w	2(a0,d2.w),d0			;move X Coord into d0
	jsr	(randomd0s).l				;RNG d0
	add.w	(a0,d2.w),d0			;add X Coord offset to d0
	move.w	d0,$44(a3)				;move d0 into temp3
	move.w	6(a0,d2.w),d0			;move Y Coord into d0
	jsr	(randomd0s).l				;RNG d0
	add.w	4(a0,d2.w),d0			;add Y Coord offset into d0
	move.w	d0,$46(a3)
	bra.w	.9
.table
	dc.w	$0050,$0014,$FFBA,$000A,$0064,$0014,$0058,$0005
	dc.w	$0047,$0032,$00E6,$0014,$0050,$001E,$00FA,$0014
.9
	move.w	$44(a3),d0
	clr.w	d1
	move.b	$65(a3),d1
	bpl.w	.10
	move.w	$34(a3),d1
	bmi.w	.13
.10
	cmp.w	#5,d1
	beq.w	.11						;branch if RW
	neg.w	d0						;negate d0
.11
	move.w	$46(a3),d1				;move temp4 into d1
	btst	#pfgoal,$62(a3)			;check if shooting up or down
	bne.w	.12						;branch if shooting up
	neg.w	d0						;negate d0
	neg.w	d1						;negate d1
.12
	movea.l	#EvadePC,a0
	jmp	(skateto).l
.13
	rts
asswingoCheckSlot	equ	*	;Part of asswingo: d1 = 5; test the player a0 (pflags2 bit 2, number at $65) against d0 and branch to the winger lane setup
	move.w	d1,-(sp)
	move.w	#5,d1
.loop
	btst	#pf2unav,pflags2(a0)
	bne.w	.15
	tst.b	$65(a0)
	bmi.w	.14
	cmp.b	$65(a0),d0
	bne.w	.15
	bra.w	.16
.14
	cmp.w	$34(a0),d0
	beq.w	.16
.15
	adda.w	#$80,a0
	dbf	d1,.loop
	movea.l	#puckx,a0
.16
	move.w	(sp)+,d1
	rts

Penaltylist							;Penalty number = word offset into this table
	dc.w	$0000
	dc.w	PenDataEOP-Penaltylist	;$02
	dc.w	PenDataEOG-Penaltylist	;$04
	dc.w	PenDataGhold-Penaltylist	;$06
	dc.w	PenDataGhold-Penaltylist	;$08
	dc.w	PenDatawhistle-Penaltylist	;$0A
	dc.w	PenDataice-Penaltylist	;$0C
	dc.w	PenDataGoal-Penaltylist	;$0E
	dc.w	PenDataoffsides-Penaltylist	;$10
	dc.w	PenDatarough2-Penaltylist	;$12
	dc.w	PenDataNoText-Penaltylist	;$14
	dc.w	PenDatacharge-Penaltylist	;$16
	dc.w	PenDataslash-Penaltylist	;$18
	dc.w	PenDatarough-Penaltylist	;$1A
	dc.w	PenDatacross-Penaltylist	;$1C
	dc.w	PenDatahook-Penaltylist	;$1E
	dc.w	PenDatatrip-Penaltylist	;$20
	dc.w	PenDataint-Penaltylist	;$22
	dc.w	PenDataHold-Penaltylist	;$24
	dc.w	PenDatafight-Penaltylist	;$26
	dc.w	PenDatafight2-Penaltylist	;$28
	dc.w	PenDataInst-Penaltylist	;$2A
	dc.w	PenDatadelay-Penaltylist	;$2C
	dc.w	PenDatap2E-Penaltylist	;$2E
	dc.w	PenDatap30-Penaltylist	;$30
	dc.w	PenDatap32-Penaltylist	;$32
	dc.w	PenDatap34-Penaltylist	;$34
	dc.w	PenDatap36-Penaltylist	;$36
	dc.w	PenDatap38-Penaltylist	;$38
	dc.w	PenDatap3A-Penaltylist	;$3A
	dc.w	PenDatap3C-Penaltylist	;$3C
	dc.w	PenDatap3E-Penaltylist	;$3E
	dc.w	PenDatap40-Penaltylist	;$40
	dc.w	PenDatap42-Penaltylist	;$42
	dc.w	PenDatap44-Penaltylist	;$44
	dc.w	PenDatap46-Penaltylist	;$46
	dc.w	PenDatap48-Penaltylist	;$48
	dc.w	PenDatap4A-Penaltylist	;$4A
PenDataEOP	dc.w	$0100
	String	'Period Over'
	dc.w	-$0510
PenDataEOG	dc.w	$0100
	String	'Game Over'
	dc.w	$0510,-$4060
PenDataGoal	dc.w	$0100
	dc.w	2						;String with no text
	dc.w	$050A,-$4018
PenDataNoText	dc.w	$0100
	dc.w	2						;String with no text
	dc.w	$0510,-$4018
PenDataice	dc.w	$0100
	String	'Icing'
	dc.w	$0002,$0101,-$0206
PenDataoffsides	dc.w	$0100
	String	'Off-side'
	dc.w	$0002,$0301,-$040F
PenDataGhold	dc.w	$0100
	String	'Face-off '
	dc.w	-$050A
PenDatap3C	dc.w	$0000
	String	'Face-off '
	dc.w	-$050A
PenDatadelay	dc.w	$0000
	String	'Penalty'
	dc.w	$0003,$0301,-$040F
PenDatawhistle	dc.w	$0000
	dc.w	2						;String with no text
	dc.w	-$050A
PenDatacharge	dc.w	$0402
	String	'Charging'
	dc.w	$0504,$0A01,$0B01,$0C01,$0A01,$0B01,$0C01,$0A01,$0B01,$0C01,$0A01,$0B01,-$0C01
PenDatap42	dc.w	$04FF
	String	'Charging'
	dc.w	$0504,$0A01,$0B01,$0C01,$0A01,$0B01,$0C01,$0A01,$0B01,$0C01,$0A01,$0B01,-$0C01
PenDataslash	dc.w	$0402
	String	'Slashing'
	dc.w	$0504,$0101,$0001,$0101,$0001,$0101,$0001,$0101,$0001,$0101,$0001,-$0101
PenDatap46	dc.w	$04FF
	String	'Slashing'
	dc.w	$0504,$0101,$0001,$0101,$0001,$0101,$0001,$0101,$0001,$0101,$0001,-$0101
PenDatatrip	dc.w	$0402
	String	'Tripping'
	dc.w	$0504,$0708,-$0701
PenDatap3A	dc.w	$04FF
	String	'Tripping'
	dc.w	$0504,$0708,-$0701
PenDatarough2	dc.w	$0A02
	String	'Roughing'
	dc.w	$0504,$0808,-$0801
PenDatarough	dc.w	$0402
	String	'Roughing'
	dc.w	$0504,$0808,-$0801
PenDatap34	dc.w	$0404
	String	'Roughing'
	dc.w	$0504,$0808,-$0801
PenDatap2E	dc.w	$0A02
	String	'Roughing'
	dc.w	$0504,$0808,-$0801
PenDatap40	dc.w	$04FF
	String	'Roughing'
	dc.w	$0504,$0808,-$0801
PenDatahook	dc.w	$0402
	String	'Hooking'
	dc.w	$0504,$0201,$0301,$0201,$0301,$0201,$0301,$0201,$0301,$0201,-$0301
PenDatap38	dc.w	$04FF
	String	'Hooking'
	dc.w	$0504,$0201,$0301,$0201,$0301,$0201,$0301,$0201,$0301,$0201,-$0301
PenDatacross	dc.w	$0402
	String	'Cross Check'
	dc.w	$0504,$0501,$0601,$0501,$0601,$0501,$0601,$0501,$0601,-$0501
PenDatap44	dc.w	$04FF
	String	'Cross Check'
	dc.w	$0504,$0501,$0601,$0501,$0601,$0501,$0601,$0501,$0601,-$0501
PenDatap36	dc.w	$0404
	String	'Cross Check'
	dc.w	$0504,$0501,$0601,$0501,$0601,$0501,$0601,$0501,$0601,-$0501
PenDataint	dc.w	$0402
	String	'Interference'
	dc.w	$0504,$0907,-$0501
PenDatap3E	dc.w	$04FF
	String	'Interference'
	dc.w	$0504,$0907,-$0501
PenDataHold	dc.w	$0402
	String	'Holding'
	dc.w	$0504,$0407,-$0501
PenDatafight	dc.w	$0105
	String	'Fighting'
	dc.w	$0504,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,-$0501
PenDatafight2	dc.w	$2805
	String	'Fighting *'
	dc.w	$0504,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,-$0501
PenDataInst	dc.w	$2802
	String	'Fight Instigator'
	dc.w	$0004,$1008,-$0101
	dc.w	$0402					;not in the table
	String	'Boarding'
	dc.w	$0504,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,-$0501
PenDatap30	dc.w	$0402
	String	'Elbowing'
	dc.w	$0504,$0F08,-$0501
PenDatap48	dc.w	$04FF
	String	'Elbowing'
	dc.w	$0504,$0F08,-$0501
PenDatap32	dc.w	$0402
	String	'High Sticking'
	dc.w	$0504,$1108,-$0501
PenDatap4A	dc.w	$04FF
	String	'High Sticking'
	dc.w	$0504,$1108,-$0501

PenShotPenalties					;The penalty shot penalty number for penalty number d0 (word offset), -1
									;none
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,$42,$46
	dc.w	$40,$44,$38,$3A,$3E,-1,-1,-1,-1,-1,-1,$48
	dc.w	$4A,-1,-1

DoubleMinorPenalties				;The double minor version of each penalty (word offset), -1 none
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,$34,$36,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1

