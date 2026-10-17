;	Skating. SetSPA starts an animation, doplayeracc and goalieacc move a player,
;	and dirtab holds the acceleration for each direction.

SetSPA	;Set animation d1 for player a3 unless it is already running
	cmp.w	SPA(a3),d1
	beq.w	rtss2
	clr.w	SPAnum(a3)
	move.w	d1,SPA(a3)
	st	SPAcnt(a3)	;restart animation
	rts

doplayeracc	;Player acceleration toward direction d0 by his speed rating (dirtab, MaxSpeed), with the turning and
	;the skating animations; goalies go to goalieacc
	tst.w	position(a3)
	beq.w	goalieacc
	move.w	(puckc).w,d1
	cmp.w	SCnum(a3),d1
	bne.w	.1
	move.w	#$856,d1
	bra.w	.d0
.1
	move.w	#$856,d1
	btst	#pfrev,pflags(a3)
	beq.w	.d0
	move.w	#$856,d1
.d0
	andi.w	#$F,d0	;pass first 4 bits of d0
	cmp.w	#7,d0	;compare to 7
	ble.w	.0
	cmp.w	#9,d0	;compare to 9
	bne.w	.4
	move.w	Xvel(a3),d0
	or.w	Yvel(a3),d0	;OR Yvel with Xvel
	bne.w	dostop
.4
	btst	#pf2aip,pflags2(a3)
	beq.s	SetSPA
	rts
.0
	movem.w	d0-d1,-(sp)
	move.w	d0,d2
	move.w	SCnum(a3),d0
	cmp.w	(puckc).w,d0	;check if puckc
	beq.w	.7
	move.w	(puckx).w,d0	;puckx into d0
	sub.w	(a3),d0	;sub Xpos
	move.w	Ypos(a3),d3	;Ypos into d3
	move.b	(puckvy).w,d1	;puckvy into d1
	ext.w	d1
	add.w	(pucky).w,d1	;add pucky to d1
	sub.w	d3,d1	;sub Ypos from d1
	btst	#pfgoal,pflags(a3)
	bne.w	.8
	neg.w	d0
	neg.w	d1
	neg.w	d3
	eori.w	#4,d2
.8
	btst	#pfrev,pflags(a3)
	bne.w	.2
	tst.w	d3
	bpl.w	.7
	cmp.w	#4,d2
	bne.w	.7
	bsr.w	vtoa
	addq.w	#1,d0
	andi.w	#7,d0
	cmp.w	#2,d0
	bhi.w	.7
	bra.w	.3
.2
	subq.w	#3,d2
	andi.w	#7,d2
	cmp.w	#2,d2
	bhi.w	.5
	bsr.w	vtoa
	addq.w	#2,d0
	andi.w	#7,d0
	cmp.w	#4,d0
	bhi.w	.5
.3
	btst	#pfrev,pflags(a3)
	bne.w	.done
	move.w	Xvel(a3),d0	;move Xvel into d0
	or.w	Yvel(a3),d0	;or with Yvel
	beq.w	.10
	move.w	Xvel(a3),d0	;move Xvel into d0
	move.w	Yvel(a3),d1	;Yvel to d1
	bsr.w	vtoa
	sub.w	(sp),d0
	addq.w	#1,d0
	andi.w	#7,d0
	cmp.w	#2,d0
	bhi.w	.done
.10
	bset	#pfrev,pflags(a3)
	bra.w	.done
.5
	movem.w	d0-d1,-(sp)
	move.w	(puckx).w,d0
	move.w	(pucky).w,d1
	sub.w	(a3),d0
	sub.w	Ypos(a3),d1
	bsr.w	vtoa
	sub.w	facedir(a3),d0
	beq.w	.6
	neg.w	d0
	andi.w	#4,d0
	lsr.w	#1,d0
	subq.w	#1,d0
	add.w	facedir(a3),d0
	andi.w	#7,d0
	move.w	d0,facedir(a3)
.6
	movem.w	(sp)+,d0-d1
.7
	bclr	#pfrev,pflags(a3)
.done
	movem.w	(sp)+,d0-d1
	move.w	facedir(a3),d2	;facedir into d2
	sub.w	d2,d0
	andi.w	#7,d0
	movea.l	#.ftab,a0
	asl.w	#1,d0
	tst.w	(a0,d0.w)
	beq.w	noturn0
	move.w	Xvel(a3),d4	;Xvel to d4
	muls.w	d4,d4	;square d4
	move.w	Yvel(a3),d3	;Yvel to d3
	muls.w	d3,d3	;square d3
	add.l	d4,d3	;add d4 and d3
	swap	d3	;swap upper and lower words
	move.w	#$300,d4
	sub.w	d3,d4
	cmp.w	#$180,d4
	bge.w	.9
	move.w	#$180,d4
.9
	muls.w	(a0,d0.w),d4
	btst	#pfrev,pflags(a3)
	beq.w	.i0
	neg.l	d4
.i0
	add.l	d4,facedir(a3)	;add d4 to facedir
	andi.w	#7,facedir(a3)	;pass the first 3 bits to facedir
	move.w	facedir(a3),d2	;move facedir to d2
	cmp.w	#$14,d3
	bls.w	.11
	clr.w	d1
	tst.w	(a0,d0.w)
	bpl.w	.19
	eori.w	#$FFCE,d1
.19
	btst	#3,attribute(a3)
	beq.w	.20
	eori.w	#$FFCE,d1
.20
	addi.w	#$2052,d1
	bset	#pf2aip,pflags2(a3)
.11
	bsr.w	SetSPA
	cmp.w	#2,d3
	bhi.w	noturn
	rts

.ftab	;Turn step by direction difference (0, +$10, 0, -$10)
	dc.w	$0,$10,$10,$10,$0,$FFF0,$FFF0,$FFF0

goalieacc	;Goalie movement
	btst	#pfjoycon,pflags(a3)
	beq.w	.28
	movem.w	d0,-(sp)
	move.w	(puckc).w,d0
	cmp.w	SCnum(a3),d0
	movem.w	(sp)+,d0
	beq.w	.28
	jsr	(GoalieInCrease).l
	bne.w	.28
	movem.w	d0-d1,-(sp)
	move.w	(puckx).w,d0
	sub.w	(a3),d0
	move.w	(pucky).w,d1
	cmp.w	#$11E,d1
	bgt.w	.0
	cmp.w	#$FEE2,d1
	bgt.w	.1
.0
	cmpi.w	#$11E,Ypos(a3)
	bgt.w	.1
	cmpi.w	#$FEE2,Ypos(a3)
	blt.w	.1
	move.w	#$11E,d1
	tst.w	(pucky).w
	bpl.w	.1
	neg.w	d1
.1
	sub.w	Ypos(a3),d1
	cmp.w	#$10,d0
	bgt.w	.22
	cmp.w	#$FFF0,d0
	blt.w	.22
	cmp.w	#$10,d1
	bgt.w	.22
	cmp.w	#$FFF0,d1
	blt.w	.22
	move.w	facedir(a3),d0
	bra.w	.2
.22
	bsr.w	vtoa
.2
	btst	#0,(sflags4).w
	bne.w	.adjustkeepdir
	bsr.w	AdjustFacingDirection
	movem.w	(sp)+,d0-d1
	bra.w	.8
.adjustkeepdir
	movem.w	(sp)+,d0-d1
	cmp.w	#8,d0
	beq.w	.8
	movem.w	d0-d1,-(sp)
	bsr.w	AdjustFacingDirection
	movem.w	(sp)+,d0-d1
.8
	move.w	#$712,d1
	btst	#pf2aip,pflags2(a3)
	bne.w	.15
	bsr.w	SetSPA
	cmp.w	#8,d0
	bne.w	.3
	tst.w	position(a3)
	bne.w	.3
	btst	#pfjoycon,pflags(a3)
	beq.w	.3
	move.w	d0,-(sp)
	move.w	Ypos(a3),d0
	btst	#pfgoal,pflags(a3)
	beq.w	.6
	neg.w	d0
.6
	cmp.w	#$D8,d0
	blt.w	.stopandrestore
	move.w	(a3),d0
	cmp.w	#$20,d0
	bgt.w	.stopandrestore
	cmp.w	#$FFE0,d0
	blt.w	.stopandrestore
	move.w	(sp)+,d0
	jsr	(stopfast).l
	bra.w	.3
.stopandrestore
	jsr	(stopfast).l
	move.w	(sp)+,d0
.3
	move.w	d0,d2
	jsr	(GoalieInCrease).l
	bne.w	.27
	btst	#pfgoal,pflags(a3)
	bne.w	.4
	cmpi.w	#$11E,Ypos(a3)
	blt.w	playeracc
	tst.w	d2
	beq.w	.5
	cmp.w	#1,d2
	beq.w	.5
	cmp.w	#7,d2
	bne.w	playeracc
	rts
.4
	cmpi.w	#$FEE2,Ypos(a3)
	bgt.w	playeracc
	cmp.w	#4,d2
	beq.w	.5
	cmp.w	#3,d2
	beq.w	.5
	cmp.w	#5,d2
	bne.w	playeracc
.5
	rts
.27
	bra.w	playeracc
.28
	move.w	#$712,d1
	btst	#pfjoycon,pflags(a3)
	beq.w	.goalieacc2
	btst	#pf3gctrl,pflags3(a3)
	bne.w	.14
	cmp.w	#8,d0
	bne.w	.turnskater
	tst.w	position(a3)
	bne.w	.14
	move.w	d0,-(sp)
	move.w	Ypos(a3),d0
	btst	#pfgoal,pflags(a3)
	beq.w	.10
	neg.w	d0
.10
	cmp.w	#$D8,d0
	blt.w	.restoreidle
	move.w	(a3),d0
	cmp.w	#$20,d0
	bgt.w	.restoreidle
	cmp.w	#$FFE0,d0
	blt.w	.restoreidle
	move.w	(sp)+,d0
	bsr.w	stopna2
	bra.w	.14
.restoreidle
	move.w	(sp)+,d0
	bra.w	.14
.turnskater
	bra.w	.d1
.goalieacc2
	andi.w	#$F,d0
	cmp.w	#7,d0
	ble.w	.d1
	cmp.w	#9,d0
	bne.w	.14
	move.w	Xvel(a3),d0
	or.w	Yvel(a3),d0
	beq.w	.14
	jmp	stopfast
.14
	btst	#pf2aip,pflags2(a3)
	beq.w	SetSPA
.15
	rts
.d1
	sub.w	facedir(a3),d0
	beq.w	.18
	neg.w	d0
	andi.w	#4,d0
	lsr.w	#1,d0
	subq.w	#1,d0
	add.w	facedir(a3),d0
	andi.w	#7,d0
	move.w	d0,facedir(a3)
.18
	move.w	#$640,d1
	bsr.w	SetSPA
	move.w	facedir(a3),d2
	bra.w	playeracc

noturn0	;doplayeracc: no turn
	moveq	#2,d4
	btst	#4,$62(a3)
	beq.w	.0
	addq.w	#4,d4
	eori.w	#8,d0
.0
	tst.w	d0
	beq.w	.28
	move.w	$28(a3),d0
	move.w	$2A(a3),d1
	bsr.w	vtoa
	btst	#3,d0
	bne.w	.1
	sub.w	$54(a3),d0
	add.w	d4,d0
	andi.w	#7,d0
	cmp.w	#4,d0
	blt.w	dostop
.1
	addq.w	#1,$54(a3)
	btst	#3,4(a3)
	beq.w	.2
	subq.w	#2,$54(a3)
.2
	andi.w	#7,$54(a3)
	move.w	(puckc).w,d1
	cmp.w	$52(a3),d1
	bne.w	.26
	move.w	#$856,d1
	bra.w	.27
.26
	move.w	#$856,d1
	btst	#4,$62(a3)
	beq.w	SetSPA
	move.w	#$856,d1
.27
	bra.w	SetSPA
.28
	move.w	#$888,d1
	btst	#4,$62(a3)
	bne.w	.9
	move.w	#$2952,d1
	btst	#6,$63(a3)
	beq.w	.3
	move.w	#$12EC,d1
.3
	move.w	(puckc).w,d4
	cmp.w	$52(a3),d4
	bne.w	.9
	move.w	#$744,d1
.9
	btst	#1,$63(a3)
	bne.w	noturn
	bsr.w	SetSPA

noturn	;doplayeracc: no turn, d2 = facedir
	btst	#4,$62(a3)
	beq.w	playeracc
	eori.w	#4,d2

playeracc	;Player acceleration with facing d2 (doplayeracc entry used by the goalie and input code)
	asl.w	#2,d2
	lea	dirtab(pc),a0
	cmpi.w	#$2052,SPA(a3)
	beq.w	.0
	cmpi.w	#$2020,SPA(a3)
	bne.w	.1
.0
	lea	dirtab2(pc),a0
	move.w	Xvel(a3),d0
	move.w	#4,d1
	asr.w	d1,d0
	sub.w	d0,Xvel(a3)
	move.w	Yvel(a3),d0
	asr.w	d1,d0
	sub.w	d0,Yvel(a3)
.1
	move.w	2(a0,d2.w),d1	;Y Inc
	move.w	(a0,d2.w),d0
	move.w	$50(a3),d2	;check acc dir and dont push wall
	beq.w	.nox
	eor.w	d0,d2
	bpl.w	.nox
	clr.w	d0
.nox
	move.w	$4E(a3),d2
	beq.w	.noy
	eor.w	d1,d2
	bmi.w	.noy
	clr.w	d1
.noy
	clr.w	d2	;clear d2
	move.b	$68(a3),d2	;move wgt of player into d2
	lsr.w	#2,d2	;divide d2 by 2
	neg.w	d2	;make it negative
	addi.w	#$40,d2
	add.b	$69(a3),d2	;add agl (legstr) of player to d2
	addq.b	#2,d2
	tst.w	position(a3)
	bne.w	.2
	add.b	$69(a3),d2
	addi.w	#$10,d2
.2
	asr.w	#1,d2	;divide by 2
	muls.w	d2,d0	;x
	muls.w	d2,d1	;y
	asr.l	#5,d0	;divide by 32
	asr.l	#5,d1
	muls.w	d7,d0	;mult d0 with frames elapsed (d7)
	muls.w	d7,d1	;mult d1 by frames elapsed (d7)
	tst.w	position(a3)
	bne.w	.noy3
	btst	#pfjoycon,pflags(a3)
	beq.w	.noy3
	move.w	(puckc).w,d2
	cmp.w	SCnum(a3),d2
	bne.w	.noy3
	asr.w	#1,d0
	asr.w	#1,d1
.noy3
	add.w	Xvel(a3),d0
	add.w	Yvel(a3),d1
	move.w	d0,d2	;move d0 into d2
	move.w	d1,d3	;move d1 into d3
	muls.w	d2,d2	;square d2
	muls.w	d3,d3	;square d3
	add.l	d2,d3	;add together
	movem.w	d0-d1,-(sp)	;push d0 and d1 to stack
	bsr.w	getpde
	btst	#4,(sflags7).w
	beq.w	.noy4
	move.w	#$1000,d0	;d0 = energy, move 1000 hex into d0
.noy4
	clr.w	d2	;clear d2
	move.b	$6A(a3),d2
	movem.l	a0,-(sp)
	lea	$36(a3),a0
	adda.w	(a0),a0
	addq.w	#2,a0
	cmpi.b	#2,(a0)
	movem.l	(sp)+,a0
	bne.w	.3
	addq.b	#6,d2
.3
	addq.b	#2,d2
	cmp.b	#$1E,d2
	ble.w	.4
	move.b	#$1E,d2
.4
	move.w	d2,(TempRawSpd).w	;hold spd value
	lsr.w	#1,d2	;divide by 2
	mulu.w	d0,d2	;multiply energy with spd
	asl.l	#4,d2	;mult by 16
	swap	d2	;swap d2 words (this math is to adjust for energy. Line Changes off, d2 = Spd value / 2)
	asl.w	#2,d2	;mult by 4 (No Line changes result from above = Spd value * 2)
	andi.w	#$3F,d2	;pass first 6 bits. Limits d2 to $3F (63 decimal)
	lea	MaxSpeed(pc),a2	;move Maxspeed table address into a2
	move.w	d2,(rosterscroll).w
	move.l	(a2,d2.w),d2
	move.l	d2,(TempMaxSpd).w	;hold MaxSpeed value
	cmpi.w	#$3C,(rosterscroll).w
	bge.w	.fgtinj
	btst	#0,(TempRawSpd+1).w	;check if TempRawSpd is odd
	beq.w	.fgtinj
	move.w	(rosterscroll).w,d2
	addq.w	#4,d2	;add 4 to d2
	move.l	(a2,d2.w),d2
	sub.l	(TempMaxSpd).w,d2	;sub TempMaxSpd from d2
	asr.l	#1,d2	;divide by 2
	add.l	(TempMaxSpd).w,d2	;add TempMaxSpd to d2 (so halves the difference between the 2 Speed steps)
.fgtinj
	btst	#pf2inj,pflags2(a3)	;check if injured during fight
	beq.w	.5
	lsr.l	#3,d2	;divide d2 by 8
.5
	tst.w	position(a3)
	bne.w	.noy6
	move.w	(puckc).w,d0	;puck carrier SCnum
	cmp.w	SCnum(a3),d0
	bne.w	.noy6
	asr.l	#1,d2	;divide d2 by 2
.noy6
	movem.w	(sp)+,d0-d1	;pop from stack
	cmp.l	d2,d3	;Compare d3 to d2 (max speed check)
	bhi.w	.7
	move.w	d0,Xvel(a3)	;move new Xvel into Xvel
	move.w	d1,Yvel(a3)	;move new Yvel into Yvel
.7
	tst.w	(OptLine).w
	bne.w	rtss2
	move.w	(VDP_CNTR).l,d0
	andi.w	#$7F,d0
	bne.w	rtss2
	bsr.w	getpde
	subi.w	#$1E,d0
	cmp.w	#$C00,d0
	blt.w	setpde
	move.b	$73(a3),d2
	ext.w	d2
	lsr.w	#1,d2
	add.w	d2,d0
	bsr.w	setpde
	btst	#0,$73(a3)
	beq.w	.6
	btst	#0,(vcount+1).w
	beq.w	.6
	addq.w	#1,d0
	bra.w	setpde
.6
	rts

MaxSpeed	;Max speed values for each rating level 0-$F
	dc.l	$1CD9410,$1FCE3E1,$22E8284,$2626FF9
	dc.l	$298AC40,$2D13759,$30C1144,$3493A01
	dc.l	$388B190,$3CA77F1,$40E8D24,$454F129
	dc.l	$49DA400,$4E8A5A9,$535F624,$5859571

dostop
	btst	#3,$62(a3)
	beq.w	.cpu
	cmpi.w	#$1000,$28(a3)
	bgt.w	.glide
	cmpi.w	#$F000,$28(a3)
	blt.w	.glide
	cmpi.w	#$1000,$2A(a3)
	bgt.w	.glide
	cmpi.w	#$F000,$2A(a3)
	blt.w	.glide
	bra.w	.stop

.cpu
	cmpi.w	#$2000,Xvel(a3)
	bgt.w	.glide
	cmpi.w	#$E000,Xvel(a3)
	blt.w	.glide
	cmpi.w	#$2000,Yvel(a3)
	bgt.w	.glide
	cmpi.w	#$E000,Yvel(a3)
	blt.w	.glide

.stop
	tst.w	$34(a3)
	bne.w	stopna2
	jmp	stopfast

.glide
	move.w	(puckc).w,d1
	cmp.w	$52(a3),d1
	bne.w	.1
	move.w	#$856,d1
	bra.w	.2
.1
	move.w	#$856,d1
.2
	btst	#4,$62(a3)
	bne.w	.0
	bset	#1,$63(a3)
	move.w	#$281A,d1
.0
	bsr.w	SetSPA
	tst.w	$34(a3)
	bne.w	stopna2
	jmp	stopfast

stopna2	;Stop, keeping the animation (goalies)
	tst.w	Xvel(a3)
	bpl.w	.xp
	addi.w	#$B4,Xvel(a3)
	bmi.w	.y
	clr.w	Xvel(a3)
.xp
	subi.w	#$B4,Xvel(a3)
	bpl.w	.y
	clr.w	Xvel(a3)
.y
	tst.w	Yvel(a3)
	bpl.w	.yp
	addi.w	#$B4,Yvel(a3)
	bmi.w	rtss2
	clr.w	Yvel(a3)
.yp
	subi.w	#$B4,Yvel(a3)
	bpl.w	rtss2
	clr.w	Yvel(a3)
	rts

runspeed	equ	200	;acc speed equate for dirtab
runspeed2	equ	450	;acc speed equate for dirtab2

dirtab	;X / Y acc speed for each direction 0-7 (runspeed / sqrt(2) = runspeed*1000/1414)
	dc.w	0,runspeed,runspeed*1000/1414,runspeed*1000/1414,runspeed,0,runspeed*1000/1414,-runspeed*1000/1414
	dc.w	0,-runspeed,-runspeed*1000/1414,-runspeed*1000/1414,-runspeed,0,-runspeed*1000/1414,runspeed*1000/1414
	dc.w	0,0

dirtab2	;The same with runspeed2 (playeracc uses it while SPA is $2052 or $2020)
	dc.w	0,runspeed2,runspeed2*1000/1414,runspeed2*1000/1414,runspeed2,0,runspeed2*1000/1414,-runspeed2*1000/1414
	dc.w	0,-runspeed2,-runspeed2*1000/1414,-runspeed2*1000/1414,-runspeed2,0,-runspeed2*1000/1414,runspeed2*1000/1414
	dc.w	0,0
	;After dirtab2: code that nothing in the listing reaches.
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$E0,$C0,$32,$7C,$D2,$30,$42,$42,$60,$00,$00,$16,$12,$18
	dc.b	$08,$42,$00,$00,$66,$00,$00,$06,$53,$48,$E8,$49,$02,$41,$00,$0F
	dc.b	$32,$C1,$51,$C8,$FF,$EA,$4C,$DF,$03,$07,$4E,$75

WeightedRandomSelect	;d0 = number of word weights at nibblebuffer: return a weighted random index
	movem.l	d1/a1,-(sp)
	movea.w	#(nibblebuffer-M68K_RAM),a1
	clr.w	d1
	bra.w	.pick
.sumloop
	add.w	(a1)+,d1
.pick
	dbf	d0,.sumloop
	move.w	d1,d0
	bsr.w	randomd0
.findloop
	sub.w	-(a1),d0
	bpl.s	.findloop
	suba.w	#$D230,a1
	move.w	a1,d0
	lsr.w	#1,d0
	movem.l	(sp)+,d1/a1
	rts
