;	The pad input of a player. updatepadinput reads the pad and runs doinput for its player.
;	doinput handles the goalie (the dive, button C, the animation check) and the skater, including
;	the puck carrier. PadOnTeam reports whether the pad is on the player's team.

updatepadinput	;Pad d6 (0-6): read it, run doinput for its player and keep impact
	cmp.w	(c1playernum).w,d6	;check if cont 1 is puck carrier
	bne.w	.t0
	jsr	(ReadJoy1).l
	clr.w	d4	;pad index for cont 1 player
	move.w	#$FFFF,(joypuckcarrier).w
	jsr	(doinput).l
	bra.w	.t1
.t0
	cmp.w	(c2playernum).w,d6	;check if cont 2 is puck carrier
	bne.w	.t1
	jsr	(ReadJoy2).l
	move.w	#2,d4	;pad index for cont 2 player
	move.w	#$FFFF,(joypuckcarrier).w
	jsr	(doinput).l
.t1
	cmp.w	(c3playernum).w,d6
	bne.w	.t3
	jsr	(ReadJoy3).l
	move.w	#4,d4
	move.w	#$FFFF,(joypuckcarrier).w
	jsr	(doinput).l
.t3
	cmp.w	(c4playernum).w,d6
	bne.w	.t1cont
	jsr	(ReadJoy4).l
	move.w	#6,d4
	move.w	#$FFFF,(joypuckcarrier).w
	jsr	(doinput).l
.t1cont
	jsr	(doassignment).l
	clr.w	Wallcos(a3)	;clear wallcos
	clr.w	Wallsin(a3)	;clear wallsin
	move.w	(a3),d2	;Xpos
	move.w	Ypos(a3),d3	;Ypos
	cmp.w	OldXpos(a3),d2	;compare to oldXpos
	bne.w	.cc	;branch if not equal
	cmp.w	OldYpos(a3),d3	;compare to oldYpos
	beq.w	.nf	;branch if equal
.cc
	jsr	(checkcoll).l	;check for collisions
.nf
	move.w	d7,d0	;move d7 into d0 (elapsed frames)
	asl.w	#1,d0	;mult by 2
	sub.w	d0,impact(a3)	;reduce impact at a constant rate
	bpl.w	.nf1	;branch if positive
	clr.w	impact(a3)	;clear impact if negative or zero
.nf1
	move.w	impact(a3),limpact(a3)	;move impact into limpact
	rts

doinput	;Process controller input for player a3: d0 = dpad, d1 = new buttons, d2 = changed buttons, d3 = held buttons,
	;d4 = pad 0 / 2 / 4 / 6
	bclr	#0,(sflags13).w
	btst	#4,d3
	beq.w	.7
	bset	#0,(sflags13).w
.7
	btst	#6,d3
	bne.w	.0
	btst	#6,d2
	bne.w	.0
	movem.l	a0,-(sp)
	movea.l	#unk_FFC38C,a0
	asr.w	#1,d4
	clr.b	(a0,d4.w)
	add.w	d4,d4
	movem.l	(sp)+,a0
.0
	btst	#4,d1	;B button
	beq.w	.1	;branch if not pressed
	btst	#5,d1	;C button
	beq.w	.1	;branch if not pressed
	bclr	#4,d1
	bset	#6,pflags3(a3)
	bra.w	.5
.1
	btst	#4,d1
	beq.w	.2
	bclr	#6,pflags3(a3)
.2
	btst	#4,d2
	beq.w	.5
	bclr	#6,pflags3(a3)
	beq.w	.5
	tst.w	d4
	bne.w	.3
	move.b	#$F,(bholdtimer).w
	bra.w	.4
.3
	move.b	#$F,(bholdtimer+1).w
.4
	bclr	#4,d2
.5
	btst	#7,(gmode2).w
	beq.w	.6
	cmp.b	#8,d0
	beq.w	.6
	jsr	(ShortenMsgTimer).l
.6
	move.w	d0,(TempWord1).w
	andi.w	#$F,(TempWord1).w
	jsr	(setpads).l
	btst	#7,d1	;start button
	beq.w	.10
	tst.w	position(a3)
	beq.w	.8
	movem.w	d3,-(sp)
	andi.b	#$F,d3
	movem.w	(sp)+,d3
	beq.w	.8
	jsr	(sub_AFDA).l
	bra.w	.nostart
.8
	tst.w	d4
	bne.w	.34
	jmp	startpause1
.34
	cmp.w	#2,d4
	bne.w	.35
	jmp	startpause2
.35
	cmp.w	#4,d4
	bne.w	.9
	jmp	startpause3
.9
	cmp.w	#6,d4
	bne.w	.10
	jmp	startpause4
.10
	btst	#7,(sflags).w
	beq.w	.nostart
	btst	#3,d0
	bne.w	.nostart
	addq.w	#2,d0
	andi.w	#7,d0
.nostart
	btst	#0,(sflags2).w
	bne.w	faceoffinput
	btst	#3,pflags2(a3)
	bne.w	lineinput
	btst	#3,pflags(a3)
	beq.w	rtss15
	movem.l	d0-d2/a0/a3,-(sp)
	move.w	(lastplayer).w,d0
	cmp.w	SCnum(a3),d0
	bne.w	.26
	tst.w	(passplayer).w
	bmi.w	.26
	tst.w	(onetimerplayer).w
	bpl.w	.26
	bclr	#2,(GameFlags).w
	bne.w	.16
	btst	#5,d1
	beq.w	.26
.16
	bclr	#3,(GameFlags).w
	bsr.w	.20
	beq.w	.26
	movem.l	(sp)+,d0-d2/a0/a3
	rts
.20
	move.w	(passplayer).w,d0
	bmi.w	.24
	tst.w	(puckc).w
	bpl.w	.24
	asl.w	#7,d0
	movea.l	#SortCords,a3
	adda.w	d0,a3
	tst.w	position(a3)
	beq.w	.24
	jsr	(PuckOnAttackHalf).l
	beq.w	.24
	btst	#3,pflags(a3)
	bne.w	.24
	btst	#3,pflags3(a3)
	bne.w	.24
	move.w	d4,(inputjoy).w
	bsr.w	PadOnTeam
	beq.w	.24
	move.w	#$23,d0
	jsr	(assreplace).l
	move.w	#1,d0
	rts
.24
	clr.w	d0
	rts
.26
	movem.l	(sp)+,d0-d2/a0/a3
	btst	#6,d1
	beq.w	.32
	cmpi.w	#SPAhook,SPA(a3)
	bne.w	.32
	tst.w	SPAnum(a3)
	bne.w	.32
	movem.w	d1,-(sp)
	move.w	#SPA099A,d1
	jsr	(SetSPA).l
	bset	#5,pflags(a3)
	movem.w	(sp)+,d1
	bra.w	doinput_islocked
.32
	btst	#0,pflags2(a3)
	beq.w	.37
	btst	#5,pflags(a3)
	bne.w	doinput_islocked
	bra.w	fightinput
.37
	move.w	(puckc).w,d5
	cmp.w	SCnum(a3),d5
	bne.w	.38
	btst	#3,pflags3(a3)
	bne.w	doinput_ispc
	btst	#5,pflags(a3)
	beq.w	doinput_ispc
	bra.w	doinput_islocked
.38
	tst.w	position(a3)
	bne.w	.39
	btst	#3,pflags3(a3)
	bne.w	.11
	btst	#5,pflags(a3)
	bne.w	.39
	bra.w	.11
.39
	btst	#3,pflags3(a3)
	beq.w	.57
	btst	#5,pflags(a3)
	bne.w	doinput_islocked
	bra.w	.11
.57
	btst	#6,d1
	beq.w	.40
	btst	#0,(sflags13).w
	bne.w	.40
	movem.l	d0-d7/a0-a6,-(sp)
	bset	#3,(GameFlags).w
	bsr.w	.20
	movem.l	(sp)+,d0-d7/a0-a6
	beq.w	.41
	bset	#3,(GameFlags).w
	rts
.40
	btst	#5,pflags(a3)
	bne.w	doinput_islocked
	bra.w	.11
.41
	movem.l	d7-a0,-(sp)
	move.w	(lastplayer).w,d7
	asl.w	#7,d7
	movea.l	#SortCords,a0
	adda.w	d7,a0
	tst.w	position(a0)
	movem.l	(sp)+,d7-a0
	beq.w	.43
	movem.w	d7,-(sp)
	move.w	SCnum(a3),d7
	cmp.w	(passplayer).w,d7
	movem.w	(sp)+,d7
	bne.w	.43
	tst.w	(puckc).w
	bpl.w	.43
	bset	#3,(GameFlags).w
	jsr	(PuckOnAttackHalf).l
	beq.w	.43
	move.w	d0,-(sp)
	move.w	d4,(inputjoy).w
	bsr.w	PadOnTeam
	beq.w	.42
	move.w	#$23,d0
	jsr	(assreplace).l
.42
	move.w	(sp)+,d0
	rts
.43
	btst	#5,pflags(a3)
	bne.w	doinput_islocked
	jmp	holdplayer
.11
	tst.w	position(a3)
	beq.w	.12
	btst	#2,(BA_PS_flags).w
	bne.w	.noswitch
	bra.w	.bhold
.12
	btst	#6,(sflags5).w
	bne.w	.bhold
	tst.w	d4
	beq.w	.13
	tst.w	(goaliemode2).w
	bra.w	.14
.13
	tst.w	(goaliemode1).w
.14
	beq.w	.bhold
	movem.w	d0,-(sp)
	move.w	SCnum(a3),d0
	cmp.w	(puckc).w,d0
	movem.w	(sp)+,d0
	beq.w	.bhold
.15
	jmp	chgplayer
.bhold
	btst	#4,d3
	beq.w	.bpress
	tst.w	(holdreset).w
	bne.w	.bpress
	tst.w	d4
	beq.w	.c1
	tst.b	(bholdtimer+1).w
	beq.w	.noswitch
	subq.b	#1,(bholdtimer+1).w
	bpl.w	.17
	move.b	#0,(bholdtimer+1).w
.17
	tst.b	(bholdtimer+1).w
	bne.w	.bpress
	tst.w	d4
	beq.w	.18
	tst.w	(goaliemode2).w
	bra.w	.19
.18
	tst.w	(goaliemode1).w
.19
	bne.w	.bpress
	bra.w	.goalie
.c1
	tst.b	(bholdtimer).w
	beq.w	.noswitch
	subq.b	#1,(bholdtimer).w
	bpl.w	.21
	move.b	#0,(bholdtimer).w
.21
	tst.w	d4
	beq.w	.22
	tst.w	(goaliemode2).w
	bra.w	.23
.22
	tst.w	(goaliemode1).w
.23
	bne.w	.bpress
	tst.b	(bholdtimer).w
	beq.w	.goalie
.bpress
	btst	#4,d1
	beq.w	.brel
	tst.w	d4
	bne.w	.25
	move.b	#$F,(bholdtimer).w
	bra.w	.noswitch
.25
	move.b	#$F,(bholdtimer+1).w
	bra.w	.noswitch
.brel
	btst	#4,d2
	beq.w	.noswitch
	btst	#4,d3
	bne.w	.noswitch
	move.w	(bholdtimer).w,d0
	tst.w	d4
	beq.w	.29
	move.b	#$F,(bholdtimer+1).w
	andi.w	#$FF,d0
	bne.w	.15
	tst.w	d4
	beq.w	.27
	tst.w	(goaliemode2).w
	bra.w	.28
.27
	tst.w	(goaliemode1).w
.28
	bne.w	.15
	bra.w	.goalie
.29
	move.b	#$F,(bholdtimer).w
	andi.w	#$FF00,d0
	bne.w	.15
	tst.w	d4
	beq.w	.30
	tst.w	(goaliemode2).w
	bra.w	.31
.30
	tst.w	(goaliemode1).w
.31
	bne.w	.15
.goalie
	tst.w	(holdreset).w
	beq.w	.44
	jmp	chgplayer
.44
	move.w	#5,d0
	cmp.w	#5,d6
	ble.w	.33
	move.w	#$B,d0
.33
	jsr	(FindGoalie).l
	tst.w	d0
	bmi.w	rtss15
	movem.l	d0/a3,-(sp)
	movea.l	#SortCords,a3
	asl.w	#7,d0
	adda.w	d0,a3
	btst	#3,pflags(a3)
	movem.l	(sp)+,d0/a3
	bne.w	rtss15
	tst.w	d4
	bne.w	.45
	jmp	setc1player
.45
	cmp.w	#2,d4
	bne.w	.46
	jmp	setc2player
.46
	cmp.w	#4,d4
	bne.w	.36
	jmp	setc3player
.36
	jmp	setc4player
.noswitch
	tst.w	position(a3)
	bne.w	doinput_skater

doinput_goaliedive	;Goalie: A with a dpad direction dives that way (SPAgdive)
	btst	#6,d1
	beq.w	doinput_cbut
	move.w	(TempWord1).w,d0
	cmp.b	#8,d0
	beq.w	doinput_cbut
	move.w	d0,facedir(a3)
	move.b	#8,nopuck(a3)
	move.w	#SPAgdive,d1
	jsr	(SetSPA).l
	bset	#1,pflags2(a3)
	bset	#5,pflags(a3)
	addi.w	#$96,(crowdlevel).w

rtss15	;The shared rts of doinput_goaliedive and doinput_cbut
	rts

doinput_cbut	;Button C (bit 5): new press: face the puck (vtoa) and go on below; held: hold the SPA frame
	;(SPAcnt $A) at the end
	btst	#5,d1
	bne.w	.press
	btst	#5,d3
	bne.w	.held
	bclr	#7,pflags2(a3)
	bra.w	doinput_chkanim
.held
	btst	#7,pflags2(a3)
	beq.w	doinput_chkanim
	movem.l	d0-d3/a0-a3,-(sp)
	movea.l	#SPAlist,a0
	adda.w	SPA(a3),a0
	move.w	facedir(a3),d0
	btst	#3,attribute(a3)
	beq.w	.1
	neg.w	d0
	addq.w	#8,d0
	andi.w	#7,d0
.1
	asl.w	#1,d0
	adda.w	(a0,d0.w),a0
	tst.b	SPAnum+1(a3)
	movem.l	(sp)+,d0-d3/a0-a3
	bpl.s	rtss15
	move.w	#$A,SPAcnt(a3)
	rts
.press
	btst	#5,pflags(a3)
	bne.w	doinput_chkanim
	movem.w	d0-d1,-(sp)
	move.w	(puckx).w,d0
	sub.w	(a3),d0
	move.w	(pucky).w,d1
	sub.w	Ypos(a3),d1
	jsr	(vtoa).l
	move.w	d0,facedir(a3)
	movem.w	(sp)+,d0-d1
	move.w	(TempWord1).w,d0
	bclr	#0,(BA_PS_flags).w
	move.w	(gameclock).w,d0
	andi.w	#7,d0
	asl.w	#4,d0
	addi.w	#$A0,d0
	cmpi.w	#$F1,(pucky).w
	bgt.w	.3
	cmpi.w	#$FF0F,(pucky).w
	bgt.w	.4
.3
	subi.w	#$40,d0
.4
	move.w	d0,d1
	muls.w	(puckvx).w,d0
	swap	d0
	add.w	(puckx).w,d0
	muls.w	(puckvy).w,d1
	swap	d1
	add.w	(pucky).w,d1
	bsr.w	ClampTargetY
	movem.w	d0-d1,-(sp)
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	cmp.l	#$384,d0
	bhi.w	.far
	movem.w	(sp)+,d0-d1
	bra.w	.near
.far
	jsr	(sroot).l
	moveq	#1,d2
	add.w	d0,d2
	moveq	#$12,d4
	btst	#3,(sflags).w
	beq.w	.6
	addq.w	#8,d4
.6
	movem.w	(sp)+,d0-d1
	muls.w	d4,d1
	addq.w	#8,d4
	muls.w	d4,d0
	divs.w	d2,d0
	divs.w	d2,d1
.near
	add.w	d3,d1
	move.w	d1,d2
	cmpi.w	#$22,2(a0)
	cmpi.w	#$18,(a0)
	cmpi.w	#$FFE8,(a0)
	cmpi.w	#$C,2(a0)
	cmpi.w	#$11E,(pucky).w
	cmpi.w	#$FEE2,(pucky).w
	bset	#1,pflags2(a3)
	bne.w	doinput_chkanim
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#puckcross,a0
	move.w	#$11E,d3
	btst	#7,pflags(a3)
	beq.w	.save	;branch if bottom net
	neg.w	d3
	addq.w	#4,a0	;puckcross+4 (for bottom goalie)
.save
	jsr	(goaliesave).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ClampTargetY	;Clamp target y d1 to $119 / $FEE7, then d1 - d3; d0 = 0 for the puck carrier
	move.w	(puckc).w,d2
	cmp.w	SCnum(a3),d2
	bne.w	.0
	clr.w	d0
.0
	cmp.w	#$119,d1
	blt.w	.1
	move.w	#$119,d1
.1
	cmp.w	#$FEE7,d1
	bgt.w	.2
	move.w	#$FEE7,d1
.2
	sub.w	d3,d1
	rts
	;SPA offsets, unreferenced: SPAgglover, SPAgglovel, SPAgstackr, SPAgstackl, SPAgstickr,
	;SPAgstickl, then SPAgglover, SPAgglovel, SPAgstickr, SPAgstickl
	dc.w	SPAgglover,SPAgglovel,SPAgstackr,SPAgstackl,SPAgstickr,SPAgstickl,SPAgglover,SPAgglovel,SPAgstickr,SPAgstickl

doinput_chkanim	;Animation in progress (pflags2 bit 1): rts. Then the goalie checks, then playeracc with TempWord1
	btst	#1,pflags2(a3)
	beq.w	.0
	rts
.0
	tst.w	position(a3)
	bne.w	JumpToDoplayeracc
	bclr	#1,(BA_PS_flags).w
	cmpi.w	#$24,(a3)
	ble.w	.1
	tst.w	Xvel(a3)
	bmi.w	.1
	beq.w	.1
	bset	#1,(BA_PS_flags).w
	clr.w	Xvel(a3)
.1
	cmpi.w	#$FFDC,(a3)
	bge.w	.2
	tst.w	Xvel(a3)
	bpl.w	.2
	bset	#1,(BA_PS_flags).w
	clr.w	Xvel(a3)
.2
	cmpi.w	#$E7,Ypos(a3)
	bgt.w	.4
	cmpi.w	#$FF19,Ypos(a3)
	ble.w	.4
	bra.w	*+4	;to the next instruction
.3
	movem.w	d0-d1,-(sp)
	move.w	Ypos(a3),d0
	move.w	Yvel(a3),d1
	eor.w	d1,d0
	movem.w	(sp)+,d0-d1
	bpl.w	.4
	tst.w	Yvel(a3)
	beq.w	.4
	bset	#1,(BA_PS_flags).w
	clr.w	Yvel(a3)
.4
	btst	#1,(BA_PS_flags).w
	bne.w	rtss15
	move.w	(TempWord1).w,d0
	jmp	doplayeracc

doinput_skater	;Skater input (doinput, position not 0)
	move.w	(TempWord1).w,d0
	btst	#3,pflags3(a3)
	bne.w	rtss7
	btst	#5,d1
	beq.w	JumpToDoplayeracc
	movem.l	d7-a0,-(sp)
	move.w	(lastplayer).w,d7
	asl.w	#7,d7
	movea.l	#SortCords,a0
	adda.w	d7,a0
	tst.w	position(a0)
	movem.l	(sp)+,d7-a0
	bne.w	.1
.0
	jmp	burst
.1
	movem.w	d7,-(sp)
	move.w	SCnum(a3),d7
	cmp.w	(passplayer).w,d7
	movem.w	(sp)+,d7
	bne.s	.0
	tst.w	(puckc).w
	bpl.s	.0
	bclr	#3,(GameFlags).w
	jsr	(PuckOnAttackHalf).l
	beq.s	.0
	move.w	d0,-(sp)
	move.w	d4,(inputjoy).w
	bsr.w	PadOnTeam
	beq.w	.2
	move.w	#$23,d0
	bclr	#3,(GameFlags).w
	jsr	(assreplace).l
.2
	move.w	(sp)+,d0
	rts

doinput_ispc	;The puck carrier: checkob, then pass mode, shot mode, or the buttons
	jsr	(checkob).l
	tst.w	position(a3)
	bne.w	.42
	btst	#1,pflags2(a3)
	bne.w	rtss15
.42
	btst	#2,(sflags).w
	bne.w	passmode
	btst	#3,(sflags).w
	bne.w	ShotMode
	btst	#4,d1
	beq.w	.0
	jsr	(sub_1D920A).l
	bra.w	setpassmode
.0
	movem.l	a0,-(sp)
	btst	#6,d1
	beq.w	.1
	movea.l	#LineHoldTimer,a0
	move.w	#$F,(a0,d4.w)
	movem.l	(sp)+,a0
	bra.w	.51
.1
	btst	#6,d3
	beq.w	.51
	movea.l	#LineHoldTimer,a0
	subq.w	#1,(a0,d4.w)
	bpl.w	.50
	clr.w	(a0,d4.w)
.50
	tst.w	(a0,d4.w)
	bne.w	.51
	movem.l	(sp)+,a0
	bra.w	SetLCmode
.51
	movem.l	(sp)+,a0
	btst	#6,d3
	bne.w	.6
	btst	#6,d2
	beq.w	.6
	movem.l	a0,-(sp)
	movea.l	#unk_FFC38C,a0
	asr.w	#1,d4
	tst.b	(a0,d4.w)
	bmi.w	.5
	add.w	d4,d4
	movea.l	#LineHoldTimer,a0
	cmpi.w	#$3DE,(a0,d4.w)
	movem.l	(sp)+,a0
	bge.w	.6
	btst	#3,pflags2(a3)
	bne.w	.4
	movem.w	d0,-(sp)
	move.w	(pucky).w,d0
	bpl.w	.52
	neg.w	d0
.52
	cmp.w	#$76,d0
	blt.w	.55
	move.w	(pucky).w,d0
	btst	#7,pflags(a3)
	bne.w	.53
	neg.w	d0
.53
	tst.w	d0
	bmi.w	.55
	movem.w	(sp)+,d0
	btst	#3,(TempWord1+1).w
	bne.w	.3
	movem.w	d1,-(sp)
	move.w	#1,d1
	btst	#7,pflags(a3)
	bne.w	.2
	move.w	#0,d1
.2
	btst	d1,d3
	movem.w	(sp)+,d1
	beq.w	.3
	move.w	(TempWord1).w,d0
	bset	#1,(GameFlags).w
	bset	#2,(GameFlags).w
	jmp	setpassmode
.3
	bset	#0,(GameFlags).w	;fake shot (A released in the attacking zone)
	bne.w	.54
	jmp	SetShotMode
.54
	rts
.55
	movem.w	(sp)+,d0
.4
	bset	#3,(sflags5).w
	bra.w	setpassmode
.5
	movem.l	(sp)+,a0
	add.w	d4,d4
.6
	tst.w	position(a3)
	bne.w	.7
	jmp	doplayeracc
.7
	btst	#5,d1
	beq.w	JumpToDoplayeracc
	jsr	(sub_1D920A).l
	bra.w	SetShotMode

doinput_islocked	;B with the player not the carrier: change player (chgplayer)
	move.w	(puckc).w,d5
	cmp.w	SCnum(a3),d5
	beq.w	rtss15
	btst	#4,d1
	beq.w	rtss7
	btst	#6,(sflags5).w
	bne.w	rtss7
	jsr	(chgplayer).l
	movem.l	d0/a0,-(sp)
	tst.w	d4
	beq.w	.3
	cmp.w	#2,d4
	beq.w	.2
	cmp.w	#4,d4
	beq.w	.1
	bra.w	*+4
.0
	move.w	(c4playernum).w,d0
	bra.w	.4
.1
	move.w	(c3playernum).w,d0
	bra.w	.4
.2
	move.w	(c2playernum).w,d0
	bra.w	.4
.3
	move.w	(c1playernum).w,d0
.4
	tst.w	d0
	bmi.w	.x
	asl.w	#7,d0
	movea.l	#SortCords,a0
	adda.w	d0,a0
	bset	#6,pflags3(a0)
.x
	movem.l	(sp)+,d0/a0
	rts

JumpToDoplayeracc	;jmp doplayeracc, shared by doinput_chkanim, doinput_skater and doinput_islocked
	jmp	doplayeracc

sub_AFDA	;Start with a dpad direction: SPA288C with pflags2 bit 1 set and Xvel + $64,
	;not while pflags2 bit 2 or gmode bit 0 is set
	btst	#2,pflags2(a3)
	bne.w	.0
	btst	#0,(gmode).w
	bne.w	.0
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#SPA288C,d1
	jsr	(SetSPA).l
	bset	#1,pflags2(a3)
	addi.w	#$64,Xvel(a3)
	movem.l	(sp)+,d0-d7/a0-a6
.0
	rts

PadOnTeam	;d0 = 1 when pad inputjoy is on the team of player a3 (its cont1team ... cont4team
	;entry: 1 home, 2 visitors), else 0
	movem.l	d0-d1/a0,-(sp)
	movea.l	#cont1team,a0
	move.w	(inputjoy).w,d0
	move.w	(a0,d0.w),d0
	bmi.w	.1
	move.w	#1,d1
	btst	#6,pflags(a3)
	beq.w	.0
	move.w	#2,d1
.0
	cmp.w	d1,d0
	bne.w	.1
	move.w	#1,d0
	bra.w	.2
.1
	move.w	#0,d0
.2
	movem.l	(sp)+,d0-d1/a0
	rts
