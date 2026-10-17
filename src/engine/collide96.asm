;	Collisions. checkcoll tests the players and the boards, checkgoal scores,
;	and wallcoll bounces an object off the boards.

checkcoll	;d2 = new x coord, d3 = new y coord, a3 = struct of object. Check wall collision (around the hot spot and the
	;end of the stick) and player collisions, then move a3 in the OOlist sort order by its y. If a player
	;collision set collflag, restore the old x/y instead. Called from updateplayers.
	clr.w	(collflag).w
	btst	#7,(sflags).w
	beq.w	.0
	exg	d2,d3
.0
	btst	#2,pflags(a3)
	bne.w	.ex
	movem.l	d0-d7,-(sp)
	move.w	(a3),d2
	move.w	Ypos(a3),d3
	move.w	$4A(a3),(wcradiusx).w
	move.w	$4C(a3),(wcradiusy).w
	bsr.w	checkwallcoll
	move.w	$4E(a3),d0
	or.w	$50(a3),d0
	bne.w	.xx
	cmpi.w	#$B,SCnum(a3)
	bgt.w	.xx
	movem.l	(sp),d0-d7
	move.l	a3,-(sp)
	bsr.w	GetHot
	move.w	(a3),d2
	move.w	Ypos(a3),d3
	add.w	d0,d2
	add.w	d1,d3
	move.w	#1,(wcradiusx).w
	move.w	#1,(wcradiusy).w
	bsr.w	checkwallcoll
.xx
	movem.l	(sp)+,d0-d7
	bsr.w	checkplcoll
.ex
	tst.w	(collflag).w
	bne.w	.restoreold
	move.w	SCnum(a3),d0
	asl.w	#1,d0
	movea.w	#(OOlistpos-M68K_RAM),a0
	movea.w	#(OOlist-M68K_RAM),a1
	movea.w	#(Ylist-M68K_RAM),a2
	move.w	(a0,d0.w),d1
.2
	cmp.w	#$F,d1
	beq.w	.cl2
	clr.w	d4
	move.b	1(a1,d1.w),d4
	cmp.w	(a2,d4.w),d3
	ble.w	.cl2
	addq.w	#1,(a0,d0.w)
	subq.w	#1,(a0,d4.w)
	move.b	d4,(a1,d1.w)
	move.b	d0,1(a1,d1.w)
	addq.w	#1,d1
	bra.s	.2
.cl2
	move.w	(a0,d0.w),d1
	beq.w	.ex2
.4
	clr.w	d4
	move.b	-1(a1,d1.w),d4
	cmp.w	(a2,d4.w),d3
	bge.w	.ex2
	subq.w	#1,(a0,d0.w)
	addq.w	#1,(a0,d4.w)
	move.b	d4,(a1,d1.w)
	move.b	d0,-1(a1,d1.w)
	subq.w	#1,d1
	bne.s	.4
.ex2
	move.w	d3,(a2,d0.w)
	rts
.restoreold
	move.w	$1C(a3),(a3)
	move.w	$20(a3),Ypos(a3)
	rts

checkplcoll	;Check collision with other players. d2/d3 = x/y cords, a3 = struct. Walk up and down the OOlist from a3 and
	;call checkcx for each object within $10 in y. Called from checkcoll
	btst	#5,pflags2(a3)
	bne.w	.ex
	cmpi.w	#$B,SCnum(a3)
	bgt.w	.ex
	move.w	SCnum(a3),d0
	asl.w	#1,d0
	movea.w	#(OOlistpos-M68K_RAM),a0
	movea.w	#(OOlist-M68K_RAM),a1
	movea.w	#(Ylist-M68K_RAM),a2
	move.w	(a0,d0.w),d1
.0
	cmp.w	#$F,d1
	beq.w	.cl
	clr.w	d4
	move.b	1(a1,d1.w),d4
	move.w	(a2,d4.w),d5
	sub.w	d3,d5
	cmp.w	#$10,d5
	bgt.w	.cl
	bsr.w	checkcx
	addq.w	#1,d1
	bra.s	.0
.cl
	move.w	(a0,d0.w),d1
	beq.w	.ex
.2
	clr.w	d4
	move.b	-1(a1,d1.w),d4
	move.w	d3,d5
	sub.w	(a2,d4.w),d5
	cmp.w	#$10,d5
	bgt.w	.ex
	bsr.w	checkcx
	subq.w	#1,d1
	bne.s	.2
.ex
	rts

checkcx	;d4 = obj. # * 2 for possible collision so check x range and distance for collision. d2 = x, d5 = delta y, a3
	;= moving object.
	movem.l	d0-d7/a0-a3,-(sp)
	asl.w	#6,d4
	movea.l	#SortCords,a2
	adda.w	d4,a2
	btst	#2,pflags(a2)
	bne.w	.exit
	btst	#5,pflags2(a2)
	bne.w	.exit
	cmpi.w	#$B,SCnum(a2)
	bgt.w	.exit
	move.w	(a2),d0
	btst	#7,(sflags).w
	beq.w	.0
	move.w	Ypos(a2),d0
.0
	sub.w	d2,d0
	cmp.w	#$FFF0,d0
	blt.w	.exit
	cmp.w	#$10,d0
	bgt.w	.exit
	muls.w	d5,d5
	muls.w	d0,d0
	add.l	d5,d0
	cmp.l	#$100,d0
	bgt.w	.exit
	move.w	#0,(word_FFBFF0).w
	move.b	pflags(a3),d6
	move.b	pflags(a2),d0
	eor.b	d0,d6
	move.w	Xvel(a3),d0
	sub.w	Xvel(a2),d0
	move.w	Yvel(a3),d1
	sub.w	Yvel(a2),d1
	move.w	(a3),d2
	sub.w	(a2),d2
	neg.w	d2
	move.w	Ypos(a3),d3
	sub.w	Ypos(a2),d3
	neg.w	d3
	movem.w	d0-d1,-(sp)
	muls.w	d3,d1
	muls.w	d2,d0
	add.l	d0,d1
	bmi.w	.exit4
	asr.l	#4,d1
	btst	#6,d6
	beq.w	.not
	move.w	d1,d4
	lsr.w	#8,d4
	cmp.w	#5,d4
	bgt.w	.g40
	moveq	#5,d4
.g40
	add.w	d4,impact(a3)
	add.w	d4,impact(a2)
	btst	#0,pflags2(a2)
	bne.w	.2
	move.w	SCnum(a3),impactp(a2)
.2
	btst	#0,pflags2(a3)
	bne.w	.3
	move.w	SCnum(a2),impactp(a3)
.3
	cmp.w	#$14,d4
	blt.w	.4
	move.w	(puckc).w,d0
	cmp.w	SCnum(a3),d0
	beq.w	.1
	cmp.w	SCnum(a2),d0
	bne.w	.4
.1
	jsr	(newcheck).l
.4
	bsr.w	checkint
	bsr.w	checkcheck
	jsr	(checkfight).l
.not
	move.w	d1,d4
	movem.w	(sp)+,d0-d1
	tst.w	(collflag).w
	bmi.w	.exit
	movem.l	d0/a0,-(sp)
	movea.l	a3,a0
	bsr.w	.droppuck
	movea.l	a2,a0
	bsr.w	.droppuck
	movem.l	(sp)+,d0/a0
	muls.w	d2,d1
	muls.w	d3,d0
	sub.l	d1,d0
	asr.l	#4,d0
	move.w	d0,d5
	clr.w	d0
	move.b	$68(a3),d0
	tst.w	position(a3)
	bne.w	.6
	move.b	#$78,d0
.6
	tst.w	position(a2)
	bne.w	.5
	clr.b	d0
.5
	addi.w	#$8C,d0
	clr.w	d1
	move.b	$68(a2),d1
	tst.w	position(a2)
	bne.w	.7
	move.b	#$78,d1
.7
	tst.w	position(a3)
	bne.w	.8
	clr.b	d1
.8
	addi.w	#$8C,d1
	move.w	(word_FFBFF0).w,d7
	mulu.w	d1,d7
	lsr.w	#4,d7
	add.w	d0,d1
	sub.w	d7,d0
	muls.w	d4,d0
	divs.w	d1,d0
	move.w	(word_FFBFF0).w,d1
	muls.w	d4,d1
	asr.w	#4,d1
	add.w	d0,d1
	movem.w	d2-d3,-(sp)
	muls.w	d5,d3
	muls.w	d0,d2
	add.l	d2,d3
	asr.l	#4,d3
	tst.w	position(a3)
	beq.w	.9
	add.w	Xvel(a2),d3
.9
	tst.w	position(a3)
	bne.w	.10
	asr.w	#2,d3
.10
	move.w	d3,Xvel(a3)
	movem.w	(sp),d2-d3
	muls.w	d5,d2
	muls.w	d0,d3
	sub.l	d2,d3
	asr.l	#4,d3
	tst.w	position(a3)
	beq.w	.11
	add.w	Yvel(a2),d3
.11
	tst.w	position(a3)
	bne.w	.12
	asr.w	#2,d3
.12
	move.w	d3,Yvel(a3)
	movem.w	(sp)+,d2-d3
	muls.w	d1,d2
	asr.l	#4,d2
	add.w	d2,Xvel(a2)
	muls.w	d1,d3
	asr.l	#4,d3
	add.w	d3,Yvel(a2)
	st	(collflag).w

.exit
	movem.l	(sp)+,d0-d7/a0-a3
	rts

.droppuck	;A pad controlled puck carrier a0 at speed 2 or less loses the puck (puckc -1, nopuck $1E)
	tst.w	position(a0)
	beq.w	.done
	btst	#3,pflags(a0)
	beq.w	.done
	move.w	(puckc).w,d0
	cmp.w	SCnum(a0),d0
	bne.w	.done
	move.w	Xvel(a0),d0
	bpl.w	.absx
	neg.w	d0
.absx
	cmp.w	#2,d0
	bgt.w	.done
	move.w	Yvel(a0),d0
	bpl.w	.absy
	neg.w	d0
.absy
	cmp.w	#2,d0
	bgt.w	.done
	st	(puckc).w
	move.b	#$1E,nopuck(a0)
.done
	rts

.exit4
	addq.w	#4,sp
	bra.s	.exit

checkint	;Check for interference penalty. player a2 interferes with a3 or vice-versa; goalie is only player who can
	;cause an interference call. Called from checkcx. .ci (checkint .1): a2 = goalie, a3 = player interfering with
	;goalie. a3 falls. The penalty ($22) needs a3 in the crease area, a CPU player or a pad player's joystick
	;player, and randomd0($1E - aggres) <= 5
	move.l	d0,-(sp)
	bsr.w	.1
	exg	a2,a3
	bsr.w	.1
	exg	a2,a3
	move.l	(sp)+,d0
	rts
.1
	tst.w	position(a2)
	bne.w	rtss2
	btst	#0,(gmode).w
	bne.w	rtss2
	move.w	(puckc).w,d0
	cmp.w	SCnum(a3),d0
	beq.w	.0
	cmpi.w	#$19,impact(a3)
	ble.w	rtss2
.0
	cmpi.w	#2,impact(a3)
	ble.w	rtss2
	exg	a2,a3
	bsr.w	FallDown
	exg	a2,a3
	cmpi.w	#$14,impact(a2)
	ble.w	rtss2
	btst	#4,pflags2(a3)
	bne.w	rtss2
	cmpi.w	#3,(gsp).w
	beq.w	rtss2
	tst.w	position(a2)
	bne.w	rtss2
	move.w	#1,d0
	btst	#6,pflags(a3)
	beq.w	.control
	move.w	#2,d0
.control
	cmp.w	(cont1team).w,d0
	beq.w	.4
	cmp.w	(cont2team).w,d0
	beq.w	.4
	cmp.w	(cont3team).w,d0
	beq.w	.4
	cmp.w	(cont4team).w,d0
	bne.w	.5
.4
	btst	#3,pflags(a3)
	beq.w	rtss2
.5
	move.w	Ypos(a2),d0
	btst	#7,pflags(a2)
	beq.w	.6
	neg.w	d0
.6
	cmp.w	#$EF,d0
	blt.w	rtss2
	cmp.w	#$11E,d0
	bgt.w	rtss2
	move.w	(a2),d0
	cmp.w	#$14,d0
	bgt.w	rtss2
	cmp.w	#$FFEC,d0
	blt.w	rtss2
	move.w	#$28,d0
	sub.b	$74(a3),d0
	bsr.w	randomd0
	cmp.w	#4,d0
	bhi.w	rtss2
	btst	#4,(gmode).w
	bne.w	rtss2
	moveq	#$22,d0
	jmp	AddPenalty

checkcheck	;Contact: a stopped pad controlled puck carrier a2 loses the puck, then CCStart for a3 on a2 and for a2 on a3
	movem.l	d0-d4/a0-a3,-(sp)
	btst	#3,pflags(a2)
	beq.w	.0
	tst.w	position(a2)
	beq.w	.0
	move.w	Xvel(a2),d0
	or.w	Yvel(a2),d0
	bne.w	.0
	move.w	(puckc).w,d0
	cmp.w	SCnum(a2),d0
	bne.w	.0
	st	(puckc).w
	move.b	#$14,nopuck(a2)
.0
	bsr.w	CCStart
	exg	a2,a3
	bsr.w	CCStart
	movem.l	(sp)+,d0-d4/a0-a3
	rts

CCStart	;Player a3 is checking player a2
	cmpi.w	#$169C,SPA(a2)
	beq.w	holdcheck
	cmpi.w	#$16EE,SPA(a2)
	beq.w	holdcheck
	cmpi.w	#$1792,SPA(a2)
	beq.w	holdcheck
	cmpi.w	#$216A,SPA(a2)
	beq.w	Bcheck
	cmpi.w	#$52C,SPA(a2)
	beq.w	Bcheck
	cmpi.w	#$2C5C,SPA(a3)
	bne.w	rtss2
	btst	#0,(gmode).w
	beq.w	.nofight
	move.w	#$100,impact(a3)
	move.w	#$100,impact(a2)
.nofight
	move.w	(a2),d0
	sub.w	(a3),d0
	move.w	Ypos(a2),d1
	sub.w	Ypos(a3),d1
	bsr.w	vtoa
	sub.w	facedir(a3),d0
	andi.w	#7,d0
	btst	#3,attribute(a3)
	beq.w	.1
	neg.w	d0
	addq.w	#8,d0
	andi.w	#7,d0
.1
	asl.w	#1,d0
	lea	checkinglist(pc),a0
	move.w	(a0,d0.w),d1
	bset	#5,pflags(a3)
	bsr.w	SetSPA
	tst.w	position(a2)
	beq.w	rtss2
	cmp.w	#$14,d4
	blt.w	rtss2
	moveq	#$78,d0
	btst	#3,pflags(a3)
	beq.w	*+4
.0
	sub.b	$68(a3),d0
	add.b	$68(a2),d0
	lsr.w	#1,d0
	exg	a2,a3
	jsr	(wallcollduringcheck).l
	exg	a2,a3
	sub.w	impact(a2),d0
	beq.w	.2
	bmi.w	.2
	btst	#4,pflags3(a3)
	bne.w	.2
	bsr.w	randomd0
	clr.w	(TempWord1).w
	move.b	$76(a3),(TempWord1+1).w
	lsr	(TempWord1).w
	cmp.b	(TempWord1+1).w,d0
	ble.w	.2
	bsr.w	checkagr
	cmp.w	#4,d0
	bhi.w	rtss2
	btst	#4,(gmode).w
	bne.w	rtss2
	move.b	(VDP_CNTR).l,d0
	andi.w	#2,d0
	addi.w	#$16,d0
	jsr	(PenShotChk).l
	jmp	AddPenalty
.2
	bsr.w	checkagr
	cmp.w	#3,d0
	bhi.w	.4
	btst	#4,(gmode).w
	bne.w	.4
	move.b	(seed+1).w,d0
	andi.w	#3,d0
	move.l	a0,-(sp)
	movea.l	#CheckPenalties,a0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	movea.l	(sp)+,a0
	jsr	(PenShotChk).l
	bpl.w	.3
	jsr	(DoubleMinorChk).l
.3
	jsr	(AddPenalty).l
.4
	bra.w	FallDown

checkinglist	;Check animation by the direction from a3 to a2 (CCStart)
	dc.b	$15,$26,$14,$94,$14,$94,$14,$94,$14,$94,$15,$26,$15,$26,$15,$26

CheckPenalties	;Penalties a check can draw: Roughing, Cross Check, Elbowing, High Sticking (one picked by seed)
	dc.b	$00,$1A,$00,$1C,$00,$30,$00,$32

checkagr	;Aggression check
	move.w	#$28,d0
	sub.b	$74(a3),d0
	lsr.b	#1,d0
	mulu.w	#$D,d0
	btst	#3,pflags(a3)
	beq.w	.checkpos
	asl.w	#1,d0
.checkpos
	move.w	(a3),d1
	sub.w	(puckx).w,d1
	cmp.w	#$28,d1
	bgt.w	.0
	cmp.w	#$FFD8,d1
	blt.w	.0
	move.w	Ypos(a3),d1
	sub.w	(pucky).w,d1
	cmp.w	#$28,d1
	bgt.w	.0
	cmp.w	#$FFD8,d1
	blt.w	.0
	asr.w	#1,d0
.0
	bsr.w	randomd0
	btst	#1,pflags3(a2)
	beq.w	.teamchk
	move.w	Ypos(a2),d1
	bpl.w	.2
	neg.w	d1
.2
	subi.w	#$11E,d1
	neg.w	d1
	move.w	#4,d0
	cmp.w	#$70,d1
	bgt.w	.1
	move.w	#3,d0
	cmp.w	#$38,d1
	bgt.w	.1
	move.w	#2,d0
	cmp.w	#$2A,d1
	bgt.w	.1
	move.w	#1,d0
.1
	bsr.w	randomd0
.teamchk
	btst	#6,pflags(a3)
	bne.w	.5
	btst	#2,(sflags9).w
	bne.w	.nopen
	bra.w	.3
.5
	btst	#1,(sflags9).w
	beq.w	.3
.nopen
	move.w	#$7F,d0
.3
	cmpi.w	#3,(gsp).w
	bne.w	.4
	move.w	#$7F,d0
.4
	rts

holdcheck	;Player a2 in a hold or hook animation holds a3 (within 1 direction of where a2 faces): both get the average
	;velocity, the hold animations, and checkagr rolls penalty $24 or $1E
	btst	#5,pflags(a3)
	bne.w	rtss2
	tst.w	position(a3)
	beq.w	rtss2
	btst	#0,pflags2(a3)
	bne.w	rtss2
	move.w	(a3),d0
	sub.w	(a2),d0
	move.w	Ypos(a3),d1
	sub.w	Ypos(a2),d1
	bsr.w	vtoa
	sub.w	facedir(a2),d0
	addq.w	#1,d0
	andi.w	#7,d0
	cmp.w	#2,d0
	bhi.w	rtss2
	move.w	(puckc).w,d0
	cmp.w	SCnum(a3),d0
	bne.w	.holdcheck
	bclr	#3,(sflags).w
.holdcheck
	move.w	Xvel(a3),d0
	add.w	Xvel(a2),d0
	asr.w	#1,d0
	move.w	d0,Xvel(a3)
	move.w	d0,Xvel(a2)
	move.w	Yvel(a3),d0
	add.w	Yvel(a2),d0
	asr.w	#1,d0
	move.w	d0,Yvel(a3)
	move.w	d0,Yvel(a2)
	bset	#5,pflags(a3)
	move.w	#$139E,d1
	cmpi.w	#$16EE,SPA(a2)
	bne.w	.0
	move.w	#$BBE,d1
	move.w	(puckc).w,d0
	cmp.w	SCnum(a3),d0
	bne.w	.0
	st	(puckc).w
	move.b	#$20,nopuck(a3)
.0
	bsr.w	SetSPA
	exg	a2,a3
	bset	#5,pflags(a3)
	move.w	#$16EE,d1
	cmpi.w	#$16EE,SPA(a3)
	beq.w	.1
	move.w	#$164A,d1
	cmpi.w	#$169C,SPA(a3)
	beq.w	.1
	move.w	#$1740,d1
.1
	bsr.w	SetSPA
	bsr.w	checkagr
	cmp.w	#3,d0
	bhi.w	.exit
	btst	#4,(gmode).w
	bne.w	.exit
	move.w	#$24,d0
	cmpi.w	#$164A,SPA(a3)
	beq.w	.2
	move.w	#$1E,d0
.2
	jsr	(PenShotChk).l
	jsr	(AddPenalty).l
.exit
	exg	a2,a3
	st	(collflag).w
	rts

Bcheck	;a2 B-checks a3 (CCStart, SPA216A / SPA052C). With OptPen off and a pad controlled a2 it needs randomd0($20 +
	;a2 checking - a3 legstr) >= $18; a3 within 1 direction of where a2 faces falls (FallDown) and checkagr may
	;call tripping ($20). Sets collflag
	btst	#5,pflags(a3)
	bne.w	rtss2
	tst.w	position(a3)
	beq.w	rtss2
	btst	#0,pflags2(a3)
	bne.w	rtss2
	tst.w	(OptPen).w
	bne.w	.checkdir
	btst	#3,pflags(a2)
	beq.w	.checkdir
	move.w	#$20,d0
	add.b	$76(a2),d0
	sub.b	$69(a3),d0
	btst	#1,(sflags8).w
	bne.w	.0
	btst	#6,(sflags7).w
	beq.w	.1
.0
	subq.b	#2,d0
.1
	bsr.w	randomd0
	cmp.w	#$18,d0
	blt.w	rtss2
.checkdir
	move.w	(a3),d0
	sub.w	(a2),d0
	move.w	Ypos(a3),d1
	sub.w	Ypos(a2),d1
	bsr.w	vtoa
	sub.w	facedir(a2),d0
	addq.w	#1,d0
	andi.w	#7,d0
	cmp.w	#2,d0
	bhi.w	rtss2
	exg	a2,a3
	bsr.w	FallDown
	tst.w	position(a3)
	beq.w	.exit
	bsr.w	checkagr
	cmp.w	#4,d0
	bhi.w	.exit
	move.w	#$20,d0
	jsr	(PenShotChk).l
	jsr	(AddPenalty).l
.exit
	exg	a2,a3
	st	(collflag).w
	rts

FallDown	;Player a2 falls down (hit by a3, or the puck): the fall animation, the injury chance, the penalty
	cmpi.w	#$B,SCnum(a2)
	bgt.w	rtss2
	cmpi.w	#SPA17E4,SPA(a2)
	blt.w	.0
	cmpi.w	#SPA1F76,SPA(a2)
	ble.w	rtss2
.0
	cmpi.w	#SPA12EC,SPA(a2)
	beq.w	rtss2
	cmpi.w	#SPA2576,SPA(a2)
	beq.w	rtss2
	cmpi.w	#SPA26C8,SPA(a2)
	beq.w	rtss2
	cmpi.w	#SPA0F14,SPA(a2)
	beq.w	rtss2
	cmpa.l	(PlayerChked).w,a2
	bne.w	.1
	cmpa.l	(PlayerChking).w,a3
	bne.w	.1
	rts
.1
	move.l	a2,(PlayerChked).w	;player checked
	move.l	a3,(PlayerChking).w	;player checking
	btst	#3,pflags3(a2)	;is player a2 doing a one-timer
	bne.w	rtss2
	btst	#3,pflags3(a3)	;Is player a3 doing a one-timer
	bne.w	rtss2
	move.w	#SPA12EC,d1
	btst	#4,pflags3(a3)	;wall collision bit
	bne.w	.cont2
	cmpi.b	#$18,$72(a2)
	blt.w	.cont2
	tst.b	$5F(a2)	;check if puck collision possible
	bne.w	.cont2
	move.w	(VDP_CNTR).l,d0	;frame counter
	andi.w	#$F,d0	;pass 1st byte of d0
	addi.w	#$10,d0
	cmp.w	impact(a2),d0	;compare impact value to d0.
	ble.w	.cont2
	move.b	#$3C,$5F(a2)	;move 3C (60 decimal) into nopuck
	bra.w	.hitter
.cont2
	tst.w	position(a3)	;check for goalie
	beq.w	.chkpos
	movea.w	#(tmstruct-M68K_RAM),a0	;Start of Home Team Stats Struct
	btst	#6,pflags(a3)
	beq.w	.AddChktoPlayerStats
	adda.w	#$39E,a0	;Change to Away Team Stats
.AddChktoPlayerStats
	addq.w	#1,$10(a0)	;Add 1 Chk to Team Total
	clr.w	d0
	move.b	$67(a3),d0
	adda.w	d0,a0
	addq.b	#1,$130(a0)
	addq.w	#1,(ChkCnt).w	;Add 1 to ChkCnt
	tst.b	$75(a3)
	bne.w	.chkpos
	addq.w	#2,(ChkCnt).w	;add 2 to ChkCnt
.chkpos
	move.b	#$78,nopuck(a2)
	move.w	(a3),d0	;Xpos
	sub.w	(a2),d0	;sub Xpos
	move.w	Ypos(a3),d1
	sub.w	Ypos(a2),d1	;sub Ypos
	bsr.w	vtoa
	tst.w	position(a2)
	beq.w	.24
	jsr	(wallcollduringcheck).l	;check for wall collision
	btst	#4,pflags3(a2)	;check wall collision bit
	beq.w	.24
	movem.l	d1-d4,-(sp)
	move.w	Xvel(a2),d1
	bpl.w	.yvel
	neg.w	d1	;negate d1
.yvel
	move.w	Yvel(a2),d2
	bpl.w	.chkpos2
	neg.w	d2	;negate d2
.chkpos2
	move.w	(a2),d3	;Xpos of player into d3
	sub.w	(a3),d3	;sub Xpos of checker
	move.w	Ypos(a2),d4
	sub.w	Ypos(a3),d4
	cmpi.w	#$11E,Ypos(a3)
	bgt.w	.bnet1
	cmpi.w	#$FEE2,Ypos(a3)
	blt.w	.bnet2
	tst.w	(a3)	;In between goal lines
	bpl.w	.posx
	tst.w	d3	;check diff of Xpos
	bpl.w	.chktowardcenterice
	cmp.w	#$FFFD,d3	;comp diff of Xpos with -3
	bgt.w	.chktowardcenterice
	bra.w	.chkawayfromcenterice
.posx
	tst.w	d3	;check diff of Xpos
	bmi.w	.chktowardcenterice
	cmp.w	#3,d3	;comp diff of Xpos with 3
	blt.w	.chktowardcenterice
	bra.w	.chkawayfromcenterice
.bnet2
	tst.w	d4	;check diff of Ypos
	bpl.w	.chktowardcenterice
	bra.w	.chkawayfromcenterice
.bnet1
	tst.w	d4	;check diff of Ypos
	bmi.w	.chktowardcenterice
	bra.w	.chkawayfromcenterice
.chktowardcenterice
	movem.l	(sp)+,d1-d4
	bra.w	.24
.chkawayfromcenterice
	movem.l	(sp)+,d1-d4	;pop from stack
	bra.w	*+4	;to the next instruction (.playerpos)
.10
	cmpi.w	#$122,Ypos(a2)
	bgt.w	.chkawayfrommiddle
	cmpi.w	#$FEDE,Ypos(a2)
	blt.w	.chkawayfrommiddle
	cmpi.w	#$76,(a2)
	bgt.w	.chkawayfrommiddle
	cmpi.w	#$FF8A,(a2)
	blt.w	.chkawayfrommiddle
	bra.w	.24
.chkawayfrommiddle
	cmpi.w	#$B,SCnum(a3)
	bgt.w	.12
	addi.w	#$A,(CwdExciteLvl).w
	addi.w	#$96,(crowdlevel).w
	move.w	d1,-(sp)	;push to stack
	move.b	#0,$40(a3)
	move.b	#0,$66(a3)
	move.w	#SPA15B8,d1
	jsr	(SetSPA).l	;set animation
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	move.w	(sp)+,d1	;pop from stack
.12
	movem.l	d0/a0,-(sp)	;push to stack
	cmpi.w	#$122,Ypos(a2)
	bgt.w	.playerabovetopgoalline
	cmpi.w	#$FEDE,Ypos(a2)
	blt.w	.playerbelowbottomgoalline
	tst.w	(a2)	;test player Xpos
	bmi.w	.playerleftofcenter
	move.w	#2,d0	;player right of center
	bra.w	.getchkanim
.playerleftofcenter
	move.w	#6,d0
	bra.w	.getchkanim
.playerabovetopgoalline
	move.w	#0,d0
	bra.w	.getchkanim
.playerbelowbottomgoalline
	move.w	#4,d0
.getchkanim
	add.w	d0,d0
	movea.l	#.23,a0
	move.w	(a0,d0.w),d1
	move.w	Ypos(a2),(FallYPos).w
	move.w	(a2),(FallXPos).w
	cmp.w	#$24C4,d1
	bne.w	.2
	cmpi.w	#$59,Ypos(a2)
	bgt.w	.2
	cmpi.w	#$FFA7,Ypos(a2)
	blt.w	.2
	move.w	d0,-(sp)
	move.w	#7,d0
	jsr	(StartArenaAnim).l
	move.w	(sp)+,d0
	addq.w	#3,(ChkCnt).w
	move.w	#SPAboardmidl,d1
	btst	#3,attribute(a2)
	beq.w	.20
	bra.w	.20
.2
	addq.w	#2,(ChkCnt).w
	btst	#3,attribute(a2)
	beq.w	.20
	cmp.w	#$2360,d1
	beq.w	.19
	cmp.w	#$24C4,d1
	bne.w	.20
	move.w	#SPAboardleft,d1
	bra.w	.20
.19
	move.w	#SPAboardmidr,d1
.20
	clr.w	Xvel(a2)
	clr.w	Yvel(a2)
	btst	#5,pflags3(a2)
	bne.w	.22
	move.w	#$C,-(sp)
	btst	#6,pflags(a2)
	beq.w	.21
	move.w	#$B,(sp)
.21
	jsr	(sfx).l
.22
	bset	#5,pflags3(a2)	;set falldown bit
	bset	#0,pflags(a2)
	movem.l	(sp)+,d0/a0	;pop from stack
	bra.w	.25

.23	;Board check animation by side of the rink (two words a side)
	dc.b	$22,$AE,$22,$AE,$23,$60,$23,$60,$24,$12,$24,$12,$24,$C4,$24,$C4

.24
	move.w	#$26C8,d1
	sub.w	$54(a2),d0
	addq.w	#1,d0
	andi.w	#7,d0
	cmp.w	#2,d0
	bls.w	.hitter
	move.w	#$2576,d1

.25
	move.w	$54(a2),d0
	andi.w	#3,d0
	bne.w	.hitter
	cmpi.b	#$14,$76(a3)
	blt.w	.hitter
	cmpi.w	#$B,$52(a3)	;check if SCNum of checker is a player
	bgt.w	.hitter
	btst	#5,$64(a2)	;check if falldown bit is set for player
	bne.w	.hitter
	move.w	#$F14,d1

.hitter
	exg	a2,a3	;swap a2 and a3
	bset	#5,$62(a3)
	bsr.w	SetSPA
	exg	a2,a3
	tst.w	$34(a3)
	beq.w	.h0
	tst.w	$34(a2)
	beq.w	.h0
	addi.w	#$12C,(crowdlevel).w
	addi.w	#$F,(CwdExciteLvl).w
.h0
	move.w	(puckc).w,d0	;move puck carrier SCNum into d0
	bmi.w	.h6
	cmp.w	$52(a2),d0	;check if puck carrier is a2
	bne.w	.h6
	st	(puckc).w	;clear out puck carrier
	btst	#4,(gmode).w	;check if highlight
	bne.w	.h4
	cmpi.w	#$26C8,$58(a2)
	bne.w	.h4
	move.w	$54(a2),d0	;facedir into d0
	andi.w	#3,d0	;pass first 2 bits of d0
	bne.w	.h4
	btst	#4,$63(a2)	;check if player is unavailable
	bne.w	.h4
	move.w	#$DC,d0
	bsr.w	randomd0
	cmp.w	$32(a2),d0	;compare impact to d0
	bgt.w	.h4
	btst	#0,(gmode).w	;check if clock running
	bne.w	.h4
	exg	a2,a3
	move.w	#$17E4,d1
	btst	#0,(seed+1).w
	beq.w	.h1
	move.w	#$1EAC,d1
.h1
	bsr.w	SetSPA
	exg	a2,a3
	bsr.w	setInjuryType
	btst	#5,(sflags7).w	;check if clock running
	bne.w	.h3
	exg	a2,a3
	move.w	#$188E,d1
	btst	#0,(seed+1).w
	bne.w	.h2
	move.w	#$1F76,d1
.h2
	bsr.w	SetSPA
	exg	a2,a3
.h3
	move.w	#4,(InjCntDown).w
	moveq	#$14,d0
	tst.w	$34(a3)
	beq.w	.h7
	tst.w	(OptPen).w
	beq.w	.h7
	moveq	#$12,d0
	jsr	(AddPenalty2).l
	jmp	Stop4Pen
.h4
	addq.w	#5,(ChkCnt).w
	move.w	#$B,-(sp)
	btst	#6,$62(a2)
	bne.w	.h5
	move.w	#$C,(sp)
.h5
	jsr	(song).l
	rts
.h6
	jmp	newcheck
.h7
	jmp	AddPenalty2

setInjuryType	;a2 injured: out for the period ($FFFD) or the game ($FFFC); in a season a random games count (SetInjuryGames)
	bclr	#2,(sflags13).w
	addq.w	#5,(ChkCnt).w
	move.w	d0,-(sp)
	bset	#2,pflags2(a2)
	addi.w	#$12C,(crowdlevel).w
	addi.w	#$1E,(CwdExciteLvl).w
	move.w	#$D,-(sp)	;sound effect
	jsr	(sfx).l
	move.w	(a2),(xc1).w	;move Xpos to scroll center
	move.w	Ypos(a2),(yc1).w
	bset	#6,(sflags).w
	clr.w	d1	;clear d1
	movea.w	#(tmstruct-M68K_RAM),a0	;move Home team Struct to a0
	btst	#6,pflags(a2)
	beq.w	.0	;branch if home
	move.w	#$8000,d1
	adda.w	#$39E,a0	;add $364 to a0 (Away Team Struct start)
.0
	move.b	$67(a2),d1
	move.w	d1,(TempPlOffset).w
	ext.w	d1	;sign extend - in this case just makes upper bye of word 00
	add.w	d1,d1	;add d1 to itself
	exg	a2,a3	;swap a2 and a3
	jsr	(getFgtbyte).l	;get the Fgt byte (divided by 4)
	exg	a2,a3	;swap back
	tst.w	d0	;check if d0 is zero
	bne.w	.not0
	bclr	#5,(sflags7).w	;clear injury game bit
	move.w	#$FFFD,$6C(a0,d1.w)
	bra.w	.1
.not0
	cmp.w	#3,d0	;compare d0 to 3 (if H/F was 12, d0 = 3)
	beq.w	.2
	bclr	#5,(sflags7).w
	move.w	#$FFFD,$6C(a0,d1.w)
	jsr	(chkFgtBit1).l	;check Fgt bit 1 of player.
	beq.w	.1
.2
	bset	#5,(sflags7).w	;set injury game bit
	move.w	#$FFFC,$6C(a0,d1.w)
	btst	#7,(GameFlags).w
	beq.w	.1
	jsr	(RandomInjuryGames).l
.1
	move.w	(sp)+,d0
	rts

checkwallcoll	;d2/d3 = x/y to test, a3 = object, wcradiusx/wcradiusy = radius. Check the corner circles, the goals
	;(checkgoal with a2 = SortCords+(13*SCstruct) top, SortCords+(12*SCstruct) bottom) and then the side and end
	;boards. Calls wallcollb on a hit, with d0/d1 = cos/sin of the wall.
	bclr	#4,pflags3(a3)	;wall collision bit
	move.w	#$96,d4
	sub.w	(wcradiusx).w,d4
	move.w	#$148,d5
	sub.w	(wcradiusy).w,d5
	movem.w	d2-d5,-(sp)
	neg.w	d4
	neg.w	d5
	addi.w	#$40,d4
	addi.w	#$40,d5
	cmp.w	d5,d3
	bgt.w	.ctc
	cmp.w	d4,d2
	blt.w	.circle
	neg.w	d4
	cmp.w	d4,d2
	bgt.w	.circle
	movea.w	#(SortCords+$680-M68K_RAM),a2
	bsr.w	checkgoal
	bra.w	.exit
.ctc
	neg.w	d5
	cmp.w	d5,d3
	blt.w	.exit
	cmp.w	d4,d2
	blt.w	.circle
	neg.w	d4
	cmp.w	d4,d2
	bgt.w	.circle
	movea.w	#(SortCords+$600-M68K_RAM),a2
	bsr.w	checkgoal
	bra.w	.exit
.circle
	sub.w	d4,d2
	sub.w	d5,d3
	move.w	d3,d0
	move.w	d2,d1
	neg.w	d1
	muls.w	d3,d3
	muls.w	d2,d2
	add.l	d2,d3
	cmp.l	#$1000,d3
	bls.w	.exit
	exg	d0,d3
	bsr.w	sroot
	exg	d0,d3
	ext.l	d0
	asl.l	#8,d0
	divs.w	d3,d0
	ext.l	d1
	asl.l	#8,d1
	divs.w	d3,d1
	bsr.w	wallcollb
.exit
	movem.w	(sp)+,d2-d5
	move.w	$4E(a3),d0
	or.w	$50(a3),d0
	bne.w	rtss2
	move.w	#$100,d0	;now check side walls
	clr.w	d1
	cmp.w	d5,d3
	bge.w	wallcollb
	neg.w	d5
	neg.w	d0
	cmp.w	d5,d3
	ble.w	wallcollb
	exg	d0,d1
	cmp.w	d4,d2
	bge.w	wallcollb
	neg.w	d4
	neg.w	d1
	cmp.w	d4,d2
	ble.w	wallcollb
	rts

checkgoal	;Check object a3 against the goal / net a2: the puck scores (Goal), a player collides (checkgoalp)
	cmpi.w	#$D,Zpos(a3)
	bgt.w	rtss2
	cmpi.w	#$E,SCnum(a3)
	bne.w	checkgoalp	;coll with player not puck
	tst.w	(puckc).w
	bmi.w	.8
	movem.l	d0/a0,-(sp)
	move.w	(puckc).w,d0
	asl.w	#7,d0
	movea.l	#SortCords,a0
	adda.w	d0,a0
	move.w	Ypos(a0),d4
	movem.l	(sp)+,d0/a0
	cmp.w	#$11E,d4
	bgt.w	.8
	cmp.w	#$FEE2,d4
	bge.w	rtss2
.8
	sub.w	(a2),d2	;Xpos
	moveq	#$10,d4
	add.w	(wcradiusx).w,d4
	cmp.w	d4,d2
	bgt.w	rtss2
	neg.w	d4
	cmp.w	d4,d2
	blt.w	rtss2
	sub.w	Ypos(a2),d3
	move.w	#2,d5
	add.w	(wcradiusy).w,d5
	cmp.w	d5,d3
	bgt.w	rtss2
	neg.w	d5
	cmp.w	d5,d3
	blt.w	rtss2
	st	(collflag).w	;inside goal area now
	cmpi.w	#$D,OldZpos(a3)	;compare OldZpos to zside
	blt.w	.nod
	move.w	OldZpos(a3),Zpos(a3)
	bra.w	.7
.nod
	bclr	#7,pflags(a3)
	move.w	(puckc).w,d0
	bmi.w	.nocon
	st	(puckc).w
	asl.w	#7,d0
	movea.w	#(SortCords-M68K_RAM),a0
	move.b	#8,nopuck(a0,d0.w)
	move.w	(pucky).w,d1
	btst	#7,pflags(a0,d0.w)
	bne.w	.an
	neg.w	d1
.an
	tst.w	d1
	bpl.w	.nocon
	bset	#7,pflags(a3)
.nocon
	move.w	#$FF00,d0
	move.l	Ypos(a3),d1
	sub.l	OldYpos(a3),d1
	asr.l	#8,d1
	beq.w	.sideentry
	bmi.w	.3
	neg.w	d0	;check top entry
	neg.w	d5
.3
	add.w	d3,d5
	move.l	(a3),d3
	sub.l	OldXpos(a3),d3
	asr.l	#8,d3
	muls.w	d3,d5
	divs.w	d1,d5
	bvs.w	.sideentry
	sub.w	d5,d2
	cmp.w	d4,d2
	blt.w	.sideentry
	neg.w	d4
	cmp.w	d4,d2
	bgt.w	.sideentry
	clr.w	d1
	move.w	Ypos(a3),d3
	eor.w	d0,d3
	bmi.w	wallcoll
	neg.w	d0
	btst	#7,pflags(a3)
	bne.w	wallcoll
	cmpi.w	#$D,Zpos(a3)
	beq.w	.10
	subq.w	#1,d4
	cmp.w	d4,d2
	bgt.w	.10
	neg.w	d4
	cmp.w	d4,d2
	bge.w	.17
.10
	bsr.w	ChkShotStat
	move.w	#$25,-(sp)	;sfx $25 when the clock is stopped
	btst	#0,(gmode).w	;gmclock: no goal after the whistle
	bne.w	.5
	move.w	#8,(sp)	;sfx 8 and crowd
	addi.w	#$12C,(crowdlevel).w
	addi.w	#$28,(CwdExciteLvl).w
.5
	jsr	(sfx).l
	move.w	#$1000,d0
	bsr.w	randomd0
	tst.w	Ypos(a3)
	bmi.w	.df0
	neg.w	d0
.df0
	move.w	d0,Yvel(a3)
	move.w	#$1000,d0
	bsr.w	randomd0s
	move.w	d0,Xvel(a3)
	move.w	#$1000,d0
	bsr.w	randomd0s
	move.w	d0,Zvel(a3)
	bra.w	puckflip
.7
	neg.w	Zvel(a3)
	bpl.w	rtss2
	neg.w	Zvel(a3)
	rts
.sideentry
	clr.w	d0
	move.w	#$100,d1
	move.w	(a3),d2
	sub.w	OldXpos(a3),d2
	bmi.w	wallcoll
	neg.w	d1
	bra.w	wallcoll
.17
	tst.w	(puckc).w
	bpl.w	rtss2
Goal	;A goal: the shootout count, EndPenaltyShotPlay, the score and both teams
	btst	#2,(BA_PS_flags).w
	beq.w	.6
	btst	#0,(gmode2).w
	bne.w	.0
	movem.l	d0/a0,-(sp)
	move.w	(BA_Sktr_SCnum).w,d0
	asl.w	#7,d0
	movea.l	#SortCords,a0
	adda.w	d0,a0
	btst	#7,pflags(a0)
	movem.l	(sp)+,d0/a0
	bne.w	.1
	bra.w	.2
.0
	tst.w	(shootoutteam).w
	bne.w	.2
.1
	tst.w	(pucky).w
	bmi.w	rtss2
	bra.w	.18
.2
	tst.w	(pucky).w
	bpl.w	rtss2
.18
	bset	#5,(sflags4).w
	tst.w	(shootoutteam).w
	beq.w	.4
	addq.w	#1,(awayshootgoals).w
	bra.w	.19
.4
	addq.w	#1,(homeshootgoals).w
.19
	bset	#0,(sflags8).w
	jsr	(EndPenaltyShotPlay).l
	bra.w	.20
.6
	btst	#0,(gmode).w
	bne.w	rtss2
.20
	bset	#0,(sflags4).w
	bclr	#3,(sflags8).w
	bsr.w	ChkShotStat
	jsr	(stop_current_song).l
	move.w	d0,-(sp)
	move.w	(vcount).w,d0
.loop
	cmp.w	(vcount).w,d0
	beq.s	.loop
	move.w	(sp)+,d0
	addq.w	#5,(ChkCnt).w
	move.w	#0,-(sp)
	jsr	(sfx).l
	jsr	(LockScroll).l
	addi.w	#$1F4,(crowdlevel).w
	movea.w	#(tmstruct-M68K_RAM),a2
	lea	$39E(a2),a1
	tst.w	Ypos(a3)
	bpl.w	.9
	exg	a2,a1
.9
	btst	#1,(gmode).w
	beq.w	.23
	exg	a2,a1
.23
	cmpi.w	#$7D,$C(a2)
	bge.w	.28
	addq.w	#1,$C(a2)
.28
	btst	#5,(sflags4).w
	beq.w	.11
	btst	#0,(gmode2).w
	bne.w	.11
	addq.w	#1,$39C(a2)
.11
	bclr	#4,(gmode2).w
	beq.w	.12
	addq.w	#1,$394(a2)
.12
	btst	#5,(sflags2).w
	beq.w	.14
	btst	#6,(sflags2).w
	bne.w	.13
	cmpa.l	#AwShots,a2
	bne.w	.14
.loop2
	addq.w	#1,$390(a2)
	bra.w	.14
.13
	cmpa.l	#tmstruct,a2
	beq.s	.loop2
.14
	movem.l	d0/a2,-(sp)
	move.w	(gsp).w,d0
	add.w	d0,d0
	adda.w	d0,a2
	addq.w	#1,$37C(a2)
	movem.l	(sp)+,d0/a2
	bclr	#7,(sflags8).w
	beq.w	.15
	addq.w	#1,$398(a2)
.15
	cmpa.w	#(tmstruct-M68K_RAM),a2
	bne.w	.16
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#3,(SongIndex).w
	jsr	(ChooseSong).l
	move.w	#$78,(songdelay).w
	move.w	(SongNum).w,-(sp)
	move.w	(sp)+,(delayedsong).w
.16
	cmpi.w	#$168,(ScoreSumbytes).w
	bne.w	.sum
	subq.w	#6,(ScoreSumbytes).w
.sum
	movea.w	#(ScoreSum-M68K_RAM),a0
	adda.w	(ScoreSumbytes).w,a0
	addq.w	#6,(ScoreSumbytes).w
	bsr.w	GetPeriodTimeRemaining
	move.w	d0,(a0)+
	moveq	#2,d0
	add.w	OldZpos(a2),d0
	sub.w	OldZpos(a1),d0
	move.b	d0,(a0)+
	addi.w	#$1E,(CwdExciteLvl).w
	cmpa.w	#(tmstruct-M68K_RAM),a2
	beq.w	.home
	subi.w	#$14,(CwdExciteLvl).w
	bset	#7,-1(a0)
.home
	move.w	Zpos(a2),d0
	move.b	d0,(a0)+
	move.w	#$FFFF,(a0)
	addi.w	#$C0,d0
	addq.b	#1,(a2,d0.w)
	move.w	$1A(a2),d0
	bmi.w	.21
	cmp.w	Zpos(a2),d0
	beq.w	.21
	move.b	d0,(a0)+
	addi.w	#$DC,d0
	addq.b	#1,(a2,d0.w)
	move.w	OldXpos(a2),d0
	bmi.w	.21
	cmp.w	Zpos(a2),d0
	beq.w	.21
	move.b	d0,(a0)
	addi.w	#$DC,d0
	addq.b	#1,(a2,d0.w)
.21
	move.w	$26(a1),d0
	bmi.w	.22
	addi.w	#$C0,d0
	addq.b	#1,(a1,d0.w)
.22
	bsr.w	ChkShotStat
	bsr.w	PenGoalStuff
	bclr	#3,(BA_PS_flags).w
	bsr.w	printscores1
	move.w	#$2710,(crowdnoisedelay).w
	btst	#0,(gmode2).w
	beq.w	.24
	bra.w	.25
.24
	moveq	#7,d0
	bsr.w	AssignTeam
.25
	clr.w	(collflag).w
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	moveq	#6,d0
	tst.w	(a3)
	bpl.w	.26
	neg.w	d0
.26
	move.w	d0,(a3)
	move.w	#$126,d0
	tst.w	Ypos(a3)
	bpl.w	.27
	neg.w	d0
.27
	move.w	d0,Ypos(a3)
	move.w	#$600,Zvel(a3)
	clr.w	Zpos(a3)
	st	(puckcross2).w
	st	(puckcross6).w
	bset	#2,pflags(a3)
	move.w	#$1A,d0
	bsr.w	assreplace
	move.l	a3,-(sp)
	adda.w	#$80,a3
	move.w	#$28CE,d1
	tst.w	Ypos(a3)
	bpl.w	.29
	move.w	#$2920,d1
.29
	bsr.w	SetSPA
	movea.w	$22(a1),a3
	moveq	#$E,d0
	jsr	(AddPenalty2).l
	movea.l	(sp)+,a3
	rts

AssignTeam	;Give assignment d0 to every player of team a2 on the ice (assinsert)
	move.l	a3,-(sp)
	movea.w	$22(a2),a3
	moveq	#5,d3
.loop
	tst.w	position(a3)
	ble.w	.next
	btst	#0,pflags2(a3)
	bne.w	.next
	bclr	#2,pflags(a3)
	bclr	#3,pflags3(a3)
	beq.w	.0
	jsr	(EndOneTimer).l
.0
	bsr.w	assinsert
.next
	adda.w	#$80,a3
	dbf	d3,.loop
	movea.l	(sp)+,a3
	rts

GetPeriodTimeRemaining	;Return d0 = (gsp << 14 | PerTimeTotal) - gameclock
	move.w	(gsp).w,d0
	swap	d0
	clr.w	d0
	lsr.l	#2,d0
	or.w	(PerTimeTotal).w,d0
	sub.w	(gameclock).w,d0
	rts

checkgoalp	;Check for player a3 collision with goal/net a2. Entered from checkgoal
	btst	#5,pflags2(a3)	;pflags2 bit 5: no player coll
	bne.w	rtss2
	cmpi.w	#$A,Zpos(a3)
	bgt.w	rtss2
	cmpi.w	#$B,SCnum(a3)
	bgt.w	rtss2
	tst.w	position(a3)
	beq.w	.0
	movem.w	d2-d3,-(sp)
	sub.w	Ypos(a2),d3
	move.w	d3,d0
	sub.w	(a2),d2
	move.w	d2,d1
	neg.w	d0
	asl.w	#4,d2
	muls.w	d2,d2
	divu.w	#$400,d2
	cmp.w	#$100,d2
	bhi.w	.exit
	asl.w	#4,d3
	muls.w	d3,d3
	divu.w	#$79,d3
	add.w	d2,d3
	cmp.w	#$100,d3
	bhi.w	.exit
	movem.w	(sp)+,d2-d3
	bsr.w	CheckBump
	movem.w	d2-d3,-(sp)
	movem.w	d0-d1,-(sp)
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	bsr.w	sroot
	move.w	d0,d2
	movem.w	(sp)+,d0-d1
	addq.w	#1,d2
	asl.l	#8,d0
	divs.w	d2,d0
	asl.l	#8,d1
	divs.w	d2,d1
	bset	#4,(sflags6).w	;wallcoll: do not set the wall collision bit
	bsr.w	wallcoll
	bclr	#4,(sflags6).w
.exit
	movem.w	(sp)+,d2-d3
	rts
.0
	movem.w	d2-d3,-(sp)
	btst	#3,pflags(a3)
	bne.w	.1
	movem.w	d0,-(sp)
	move.w	Ypos(a3),d0
	btst	#7,pflags(a3)
	beq.w	.6
	neg.w	d0
.6
	cmp.w	#$11E,d0
	movem.w	(sp)+,d0
	bge.w	.1
	cmpi.w	#2,facedir(a3)
	beq.s	.exit
	cmpi.w	#6,facedir(a3)
	beq.s	.exit
.1
	sub.w	Ypos(a2),d3
	move.w	d3,d0
	sub.w	(a2),d2
	move.w	d2,d1
	neg.w	d0
	asl.w	#4,d2
	muls.w	d2,d2
	divu.w	#$384,d2
	cmp.w	#$100,d2
	bhi.s	.exit
	asl.w	#4,d3
	muls.w	d3,d3
	divu.w	#$64,d3
	add.w	d2,d3
	cmp.w	#$100,d3
	bhi.s	.exit
	movem.w	(sp)+,d2-d3
	bsr.w	CheckBump
	movem.w	d2-d3,-(sp)
	movem.w	d0-d1,-(sp)
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	bsr.w	sroot
	move.w	d0,d2
	movem.w	(sp)+,d0-d1
	addq.w	#1,d2
	asl.l	#8,d0
	divs.w	d2,d0
	asl.l	#8,d1
	divs.w	d2,d1
	bset	#4,(sflags6).w	;wallcoll: do not set the wall collision bit
	bsr.w	wallcoll
	bclr	#4,(sflags6).w
	bra.w	.exit

CheckBump	;Supply minimum separation velocity for coll with walls/goal/net. a2 = goal, a3 = player. On one frame in 32,
	;a player near the puck in y moving faster than $24CC knocks the net (a2 gets a quarter of a3's velocity, a3
	;stops, scroll lock at Vpos) and, while the clock runs, calls penalty 8. Called from checkgoalp
	movem.l	d0-d1,-(sp)
	move.w	(VDP_CNTR).l,d0
	andi.w	#$1F,d0
	bne.w	.ex
	move.w	(pucky).w,d0
	sub.w	Ypos(a2),d0
	cmp.w	#$28,d0
	bgt.w	.ex
	cmp.w	#$FFD8,d0
	blt.w	.ex
	move.w	Xvel(a3),d0
	move.w	Yvel(a3),d1
	cmp.w	#$2000,d0
	bgt.w	.0
	cmp.w	#$E000,d0
	blt.w	.0
	cmp.w	#$2000,d1
	bgt.w	.0
	cmp.w	#$E000,d1
	blt.w	.0
.ex
	movem.l	(sp)+,d0-d1
	rts
.0
	btst	#0,(gmode2).w
	bne.s	.ex
	adda.w	#$C,sp	;drop the saved d0-d1 and the return to checkgoalp: return to checkgoal's caller
	asr.w	#2,d0
	asr.w	#2,d1
	move.w	d0,Xvel(a2)
	move.w	d1,Yvel(a2)
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	bset	#6,(sflags).w
	btst	#0,(gmode).w
	bne.w	rtss2
	moveq	#8,d0
	jmp	AddPenalty2

wallcollb	;Bounce off the boards
	cmpi.w	#$E,SCnum(a3)
	bne.w	wallcoll
	cmpi.w	#$1D,Zpos(a3)
	bgt.w	.1
	cmpi.w	#$12,Zpos(a3)
	bls.w	wallcoll
	cmpi.w	#$118,Ypos(a3)
	blt.w	.1
	cmpi.w	#$46,(a3)
	blt.w	wallcoll
	cmpi.w	#$4A,(a3)
	bgt.w	wallcoll
	cmpi.w	#$FA0,Yvel(a3)
	blt.w	wallcoll
	move.l	a3,-(sp)
	asr	Yvel(a3)
	adda.w	#$80,a3
	move.w	#$48,(a3)
	move.w	#$13C,Ypos(a3)
	move.w	#$18,Zpos(a3)
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	clr.w	Xvel(a3)
	move.w	#$2B88,d1
	bsr.w	SetSPA
	movea.l	(sp)+,a3
	move.w	#$E,-(sp)
	jsr	(sfx).l
	addi.w	#$258,(crowdlevel).w
	addi.w	#$F,(CwdExciteLvl).w
.1
	bset	#6,(sflags).w
	bset	#2,pflags(a3)
	tst.w	Ypos(a3)
	bpl.w	.2
	ori.w	#$8000,attribute(a3)
.2
	clr.w	$86(a3)	;frame+SCstruct(a3)
	btst	#0,(gmode).w
	bne.w	rtss2
	move.l	a3,-(sp)
	move.w	(ltplayer).w,d0
	asl.w	#7,d0	;#scsize
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3
	moveq	#6,d0
	jsr	(AddPenalty2).l
	movea.l	(sp)+,a3
	rts

wallcoll	;d0 = cosine, d1 = sine of angle of incidence with wall, a3 = object. Bounce a3 off the wall: the puck loses
	;speed, flips and plays sfx $28-$2B; a player sets the wall collision bit (unless sflags6 bit 4) and plays
	;SFXplayerwall on a hard hit
	move.w	d0,$4E(a3)
	move.w	d1,$50(a3)
	movem.l	d2-d3,-(sp)
	movem.w	d0-d1,-(sp)
	muls.w	Yvel(a3),d0
	muls.w	Xvel(a3),d1
	sub.l	d1,d0
	asr.l	#8,d0
	move.w	d0,d2	;v1n
	movem.w	(sp),d0-d1
	muls.w	Xvel(a3),d0
	muls.w	Yvel(a3),d1
	add.l	d1,d0
	asr.l	#8,d0
	move.w	d0,d3	;v1t
	neg.w	d2
	cmpi.w	#$E,SCnum(a3)	;#puckSCnum, SCnum
	bne.w	.player
	bclr	#4,(sflags2).w
	tst.w	d2
	bpl.w	.nocoll
	asr.w	#2,d2	;reduce normal speed on puck
	cmp.w	#$FC00,d2	;#-400
	bgt.w	.pok
	move.w	#$800,d0
	bsr.w	randomd0
	neg.w	d0
	move.w	d0,Zvel(a3)
	bsr.w	puckflip
	move.w	d2,d0
	asr.w	#8,d0
	asr.w	#2,d0
	addq.w	#4,d0
	bpl.w	.sf0
	clr.w	d0
.sf0
	andi.w	#3,d0
	addi.w	#$28,d0
	move.w	d0,-(sp)
	jsr	(sfx).l
.pok
	move.w	d3,d0	;reduce tangent speed on puck
	asr.w	#6,d0
	sub.w	d0,d3
	asr.w	#1,d0
	sub.w	d0,d3
	bra.w	.noadd
.player
	cmp.w	#$3E8,d2	;#1000
	bgt.w	.nocoll
	bclr	#4,(sflags6).w
	bne.w	.3
	bset	#4,pflags3(a3)	;set wall collision bit
.3
	cmp.w	#$F000,d2	;$-1000
	bgt.w	.nosfx
	cmpi.w	#$A,impact(a3)	;impact(a3)
	blt.w	.nosfx
	move.w	#$20,-(sp)	;#SFXplayerwall
	jsr	(sfx).l
.nosfx
	asr.w	#2,d2
	cmp.w	#$FC7C,d2	;#-900
	blt.w	.noadd
	move.w	#$FC18,d2	;#-1000
.noadd
	movem.w	(sp),d0-d1
	movem.w	d2-d3,-(sp)
	muls.w	d0,d3
	muls.w	d1,d2
	sub.l	d2,d3
	asr.l	#8,d3
	tst.w	position(a3)
	bne.w	.0
	cmpi.w	#$B,SCnum(a3)
	bgt.w	.0
	cmpi.w	#$128,Ypos(a3)
	bgt.w	.0
	cmpi.w	#$FED8,Ypos(a3)
	blt.w	.0
	asr.l	#1,d3
	asr.l	#1,d3
	asr.l	#1,d3
	asr.l	#1,d3
	asr.l	#1,d3
.0
	move.w	d3,Xvel(a3)
	movem.w	(sp)+,d2-d3
	movem.w	(sp),d0-d1
	muls.w	d1,d3
	muls.w	d0,d2
	add.l	d2,d3
	asr.l	#8,d3
	tst.w	position(a3)
	bne.w	.1
	cmpi.w	#$B,SCnum(a3)
	bgt.w	.1
	cmpi.w	#$128,Ypos(a3)
	bgt.w	.1
	cmpi.w	#$FED8,Ypos(a3)
	blt.w	.1
	asr.l	#1,d3
	asr.l	#1,d3
	asr.l	#1,d3
	asr.l	#1,d3
	asr.l	#1,d3
.1
	move.w	d3,Yvel(a3)
	tst.w	Zvel(a3)
	bmi.w	.nocoll
	clr.w	Zvel(a3)
.nocoll
	addq.w	#4,sp
	movem.l	(sp)+,d2-d3
	rts
	;After wallcoll: code that nothing in the listing reaches.
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$B8,$00,$02,$C3,$42,$67,$00,$08,$5C,$3F,$3C,$00,$05,$4E,$F9
	dc.b	$00,$08,$84,$70,$0C,$6B,$01,$90,$00,$14,$6E,$00,$00,$0C,$0C,$6B
	dc.b	$FE,$70,$00,$14,$6E,$00,$00,$06,$42,$6B,$00,$2A,$0C,$6B,$00,$10
	dc.b	$00,$18,$6E,$CC,$30,$2B,$00,$52,$E3,$40,$30,$7C,$B8,$7E,$32,$7C
	dc.b	$B8,$9E,$34,$7C,$B8,$5E,$32,$30,$00,$00,$B2,$7C,$00,$0F,$67,$00
	dc.b	$00,$20,$42,$44,$18,$31,$10,$01,$3A,$32,$40,$00,$9A,$6B,$00,$14
	dc.b	$BA,$7C,$00,$18,$6E,$00,$00,$0A,$61,$00,$00,$2E,$52,$41,$60,$DA
	dc.b	$32,$30,$00,$00,$67,$00,$00,$20,$42,$44,$18,$31,$10,$FF,$3A,$2B
	dc.b	$00,$14,$9A,$72,$40,$00,$BA,$7C,$00,$18,$6E,$00,$00,$0A,$61,$00
	dc.b	$00,$08,$53,$41,$66,$E2,$4E,$75,$48,$E7,$FF,$F0,$E2,$4C,$B8,$78
	dc.b	$B7,$BE,$67,$00,$01,$06,$B8,$7C,$00,$0B,$6E,$00,$00,$FE,$EF,$44
	dc.b	$34,$7C,$B0,$5E,$D4,$C4,$08,$38,$00,$02,$C3,$40,$67,$00,$00,$14
	dc.b	$EE,$44,$B8,$78,$D2,$D4,$67,$00,$00,$0A,$B8,$78,$D2,$D6,$66,$00
	dc.b	$00,$DA,$08,$2A,$00,$02,$00,$62,$66,$00,$00,$D0,$4A,$2A,$00,$5E
	dc.b	$66,$00,$00,$C8,$08,$2A,$00,$02,$00,$63,$66,$00,$00,$6C,$0C,$6B
	dc.b	$00,$05,$00,$18,$6E,$00,$00,$62,$0C,$6B,$02,$00,$00,$2C,$6E,$00
	dc.b	$00,$58,$2F,$0A,$61,$00,$B3,$6C,$D0,$52,$90,$53,$B0,$7C,$00,$10
	dc.b	$6E,$00,$00,$46,$B0,$7C,$FF,$F0,$6D,$00,$00,$3E,$D2,$6A,$00,$14
	dc.b	$92,$6B,$00,$14,$B2,$7C,$00,$10,$6E,$00,$00,$2E,$B2,$7C,$FF,$F0
	dc.b	$6D,$00,$00,$26,$C1,$C0,$C3,$C1,$D0,$81,$22,$3C,$00,$00,$01,$00
	dc.b	$4A,$2B,$00,$5E,$6F,$00,$00,$04,$E4,$49,$B0,$81,$62,$00,$00,$0A
	dc.b	$61,$00,$02,$B4,$60,$00,$00,$54,$4A,$6A,$00,$34,$67,$00,$00,$D0
	dc.b	$08,$2A,$00,$03,$00,$64,$66,$00,$00,$42,$30,$12,$90,$53,$B0,$7C
	dc.b	$00,$08,$6E,$00,$00,$36,$B0,$7C,$FF,$F8,$6D,$00,$00,$2E,$32,$2A
	dc.b	$00,$14,$92,$6B,$00,$14,$B2,$7C,$00,$08,$6E,$00,$00,$1E,$B2,$7C
	dc.b	$FF,$F8,$6D,$00,$00,$16,$C1,$C0,$C3,$C1,$D0,$81,$B0,$BC,$00,$00
	dc.b	$00,$40,$62,$00,$00,$06,$61,$00,$06,$20,$4C,$DF,$0F,$FF,$4E,$75
	dc.b	$00,$00,$00,$03,$00,$03,$00,$04,$00,$04,$00,$04,$00,$05,$00,$05
	dc.b	$00,$05,$00,$05,$00,$05,$00,$05,$00,$05,$00,$05,$00,$05,$00,$05
	dc.b	$00,$05,$00,$05,$00,$05,$00,$05,$00,$05,$00,$00,$00,$01,$00,$01
	dc.b	$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$02,$00,$02,$00,$02
	dc.b	$00,$02,$00,$02,$00,$02,$00,$02,$00,$02,$00,$02,$00,$02,$00,$02
	dc.b	$00,$02,$00,$02,$00,$00,$00,$02,$00,$02,$00,$03,$00,$03,$00,$03
	dc.b	$00,$03,$00,$03,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04
	dc.b	$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$00,$04,$2F,$08
	dc.b	$20,$7C,$00,$01,$F1,$96,$0C,$78,$00,$01,$D2,$68,$67,$00,$00,$86
	dc.b	$0C,$78,$00,$02,$D2,$68,$66,$00,$00,$46,$30,$3C,$00,$01,$32,$3C
	dc.b	$00,$02,$08,$2A,$00,$06,$00,$62,$67,$00,$00,$0A,$30,$3C,$00,$02
	dc.b	$32,$3C,$00,$01,$B0,$78,$C3,$90,$67,$00,$00,$2E,$B0,$78,$C3,$92
	dc.b	$67,$00,$00,$26,$B0,$78,$C3,$94,$67,$00,$00,$1E,$B0,$78,$C3,$96
	dc.b	$67,$00,$00,$16,$20,$7C,$00,$01,$F1,$C0,$60,$00,$00,$38,$20,$7C
	dc.b	$00,$01,$F1,$EA,$60,$00,$00,$2E,$20,$7C,$00,$01,$F1,$C0,$B2,$78
	dc.b	$C3,$90,$67,$00,$00,$20,$B2,$78,$C3,$92,$67,$00,$00,$18,$B2,$78
	dc.b	$C3,$94,$67,$00,$00,$10,$B2,$78,$C3,$96,$67,$00,$00,$08,$20,$7C
	dc.b	$00,$01,$F1,$96,$42,$40,$42,$41,$10,$2A,$00,$74,$12,$2A,$00,$6F
	dc.b	$D0,$41,$12,$2A,$00,$71,$D0,$41,$12,$2A,$00,$73,$D0,$41,$E6,$40
	dc.b	$02,$40,$00,$0F,$D0,$40,$31,$F0,$00,$00,$BF,$9E,$20,$5F,$0C,$52
	dc.b	$00,$15,$6E,$00,$00,$42,$0C,$52,$FF,$EB,$6D,$00,$00,$3A,$08,$2A
	dc.b	$00,$07,$00,$62,$67,$00,$00,$16,$30,$38,$B7,$72,$04,$40,$FE,$E0
	dc.b	$32,$2A,$00,$14,$04,$41,$FE,$E0,$60,$00,$00,$12,$30,$38,$B7,$72
	dc.b	$04,$40,$01,$20,$32,$2A,$00,$14,$04,$41,$01,$20,$B3,$40,$6A,$00
	dc.b	$00,$06,$60,$00,$00,$AE,$31,$F8,$BF,$9E,$BF,$A4,$5E,$78,$BF,$A4
	dc.b	$30,$12,$32,$2A,$00,$14,$61,$00,$00,$7A,$6F,$00,$00,$60,$B0,$7C
	dc.b	$00,$28,$6C,$00,$00,$8E,$B2,$7C,$00,$28,$6C,$00,$00,$86,$2F,$0A
	dc.b	$4E,$B9,$00,$01,$A4,$B2,$31,$F8,$BF,$9E,$BF,$A4,$5C,$78,$BF,$A4
	dc.b	$61,$00,$00,$50,$6F,$00,$00,$36,$2F,$0A,$4E,$B9,$00,$01,$A5,$28
	dc.b	$31,$F8,$BF,$9E,$BF,$A4,$56,$78,$BF,$A4,$61,$00,$00,$36,$6F,$00
	dc.b	$00,$1C,$2F,$0A,$4E,$B9,$00,$01,$A5,$9E,$31,$F8,$BF,$9E,$BF,$A4
	dc.b	$56,$78,$BF,$A4,$61,$00,$00,$1C,$6E,$00,$00,$38,$30,$12,$90,$53
	dc.b	$32,$2A,$00,$14,$92,$6B,$00,$14,$4E,$B9,$00,$01,$F8,$4C,$60,$00
	dc.b	$FD,$EA,$90,$53,$6A,$00,$00,$04,$44,$40,$92,$6B,$00,$14,$6A,$00
	dc.b	$00,$04,$44,$41,$B0,$78,$BF,$A4,$6E,$00,$00,$06,$B2,$78,$BF,$A4
	dc.b	$4E,$75,$08,$B8,$00,$02,$C3,$42,$67,$00,$FD,$C0,$30,$38,$B7,$BE
	dc.b	$B0,$6A,$00,$52,$67,$00,$FD,$B4,$3F,$3C,$00,$05,$4E,$B9,$00,$08
	dc.b	$84,$70,$60,$00,$FD,$A6,$4A,$6A,$00,$34,$66,$00,$00,$0C,$08,$38
	dc.b	$00,$04,$C3,$38,$66,$00,$04,$4E,$08,$AA,$00,$00,$00,$62,$32,$38
	dc.b	$B7,$BE,$6B,$00,$00,$DE,$EF,$41,$30,$7C,$B0,$5E,$D0,$C1,$12,$28
	dc.b	$00,$62,$14,$2A,$00,$62,$B3,$42,$08,$02,$00,$06,$67,$00,$04,$26
	dc.b	$08,$38,$00,$05,$C3,$46,$67,$00,$00,$10,$B0,$BC,$00,$00,$00,$40
	dc.b	$62,$00,$04,$12,$60,$00,$00,$0C,$B0,$BC,$00,$00,$00,$24,$62,$00
	dc.b	$04,$04,$4A,$6A,$00,$34,$67,$00,$00,$4E,$4A,$68,$00,$34,$67,$00
	dc.b	$03,$F4,$10,$28,$00,$72,$E2,$08,$61,$00,$06,$9A,$3F,$00,$C1,$4A
	dc.b	$10,$28,$00,$72,$E2,$08,$61,$00,$06,$8C,$C1,$4A,$44,$40,$D0,$5F
	dc.b	$06,$40,$00,$24,$61,$00,$BC,$2A,$08,$38,$00,$05,$C3,$46,$67,$00
	dc.b	$00,$0E,$B0,$7C,$00,$04,$62,$00,$03,$BC,$60,$00,$00,$0A,$B0,$7C
	dc.b	$00,$02,$62,$00,$03,$B0,$10,$28,$00,$72,$E2,$08,$61,$00,$06,$56
	dc.b	$06,$40,$00,$14,$11,$40,$00,$5E,$C1,$4A,$10,$28,$00,$72,$E2,$08
	dc.b	$61,$00,$06,$42,$06,$40,$00,$14,$11,$40,$00,$5E,$C1,$4A,$31,$E8
	dc.b	$00,$52,$BF,$0C,$08,$B8,$00,$02,$C3,$3A,$08,$B8,$00,$03,$C3,$3A
	dc.b	$3F,$3C,$00,$06,$4E,$B9,$00,$08,$84,$70,$61,$00,$A8,$C0,$60,$00
	dc.b	$05,$E8,$4A,$6A,$00,$34,$66,$00,$00,$0C,$B0,$BC,$00,$00,$00,$40
	dc.b	$62,$00,$03,$52,$08,$2A,$00,$03,$00,$64,$67,$00,$00,$2C,$B0,$BC
	dc.b	$00,$00,$00,$64,$62,$00,$00,$8C,$08,$38,$00,$03,$C3,$50,$66,$00
	dc.b	$00,$12,$0C,$6A,$00,$18,$00,$5A,$6C,$00,$00,$0E,$35,$7C,$00,$18
	dc.b	$00,$5A,$08,$F8,$00,$07,$C3,$4C,$30,$38,$B7,$86,$32,$38,$B7,$88
	dc.b	$C1,$C0,$C3,$C1,$D0,$81,$42,$41,$08,$38,$00,$04,$C3,$3C,$66,$00
	dc.b	$00,$14,$08,$2A,$00,$03,$00,$64,$66,$00,$00,$3C,$12,$2A,$00,$72
	dc.b	$C2,$FC,$01,$5E,$06,$81,$00,$00,$32,$C8,$48,$A7,$20,$00,$34,$38
	dc.b	$BF,$12,$B4,$6A,$00,$52,$4C,$9F,$00,$04,$66,$00,$00,$08,$06,$81
	dc.b	$00,$00,$32,$C8,$C2,$C1,$B0,$81,$63,$00,$00,$3E,$15,$7C,$00,$08
	dc.b	$00,$5E,$60,$00,$FF,$4C,$C5,$4B,$4E,$B9,$00,$1D,$6B,$E6,$C5,$4B
	dc.b	$4E,$75,$B0,$BC,$00,$00,$01,$44,$62,$00,$00,$1C,$08,$38,$00,$03
	dc.b	$C3,$50,$66,$00,$00,$12,$0C,$6A,$00,$18,$00,$5A,$6C,$00,$00,$08
	dc.b	$35,$7C,$00,$18,$00,$5A,$4E,$75,$3F,$3C,$00,$07,$30,$2A,$00,$52
	dc.b	$31,$C0,$B7,$BE,$30,$7C,$C7,$26,$43,$E8,$03,$9E,$08,$2A,$00,$06
	dc.b	$00,$62,$66,$00,$00,$04,$C1,$49,$50,$E8,$00,$1A,$50,$E8,$00,$1C
	dc.b	$08,$E8,$00,$03,$00,$30,$08,$B8,$00,$04,$C3,$3E,$67,$00,$00,$26
	dc.b	$52,$69,$00,$0E,$06,$78,$00,$C8,$B8,$B2,$5A,$78,$C4,$C4,$3E,$BC
	dc.b	$00,$0C,$B2,$FC,$C7,$26,$66,$00,$00,$0C,$06,$78,$00,$0A,$B8,$B8
	dc.b	$3E,$BC,$00,$0B,$4E,$B9,$00,$08,$85,$86,$30,$2A,$00,$52,$B0,$78
	dc.b	$BF,$12,$66,$00,$00,$06,$52,$69,$00,$14,$50,$F8,$BF,$12,$08,$B8
	dc.b	$00,$02,$C3,$3A,$08,$B8,$00,$03,$C3,$3A,$4A,$6A,$00,$34,$66,$00
	dc.b	$00,$1C,$61,$00,$DB,$CE,$35,$7C,$00,$8C,$00,$48,$0C,$6A,$04,$9A
	dc.b	$00,$58,$66,$00,$00,$08,$35,$7C,$00,$05,$00,$48

setd0player	;Player d0 becomes the player of a pad of his team (setc1player ... setc4player), unless a pad has him already
	cmp.w	(c1playernum).w,d0
	beq.w	.0
	cmp.w	(c2playernum).w,d0
	beq.w	.0
	cmp.w	(c3playernum).w,d0
	beq.w	.0
	cmp.w	(c4playernum).w,d0
	beq.w	.0
	movem.l	d0/a3,-(sp)
	asl.w	#7,d0
	movea.l	#SortCords,a3
	tst.w	$34(a3,d0.w)
	bne.w	.1
	btst	#3,$62(a3,d0.w)
	beq.w	.1
	movem.l	(sp)+,d0/a3
.0
	rts
.1
	movem.l	(sp)+,d0/a3
	cmp.w	#6,d0
	slt	d1
	ext.w	d1
	addq.w	#2,d1
	move.w	(lastplayer).w,d2
	cmp.w	(c1playernum).w,d2
	beq.w	.13
	cmp.w	(c2playernum).w,d2
	beq.w	.9
	cmp.w	(c3playernum).w,d2
	beq.w	.5
	cmp.w	(cont4team).w,d1
	bne.w	.2
	jmp	setc4player
.2
	cmp.w	(cont1team).w,d1
	bne.w	.3
	jmp	setc1player
.3
	cmp.w	(cont2team).w,d1
	bne.w	.4
	jmp	setc2player
.4
	cmp.w	(cont3team).w,d1
	bne.s	.0
	jmp	setc3player
.5
	cmp.w	(cont3team).w,d1
	bne.w	.6
	jmp	setc3player
.6
	cmp.w	(cont1team).w,d1
	bne.w	.7
	jmp	setc1player
.7
	cmp.w	(cont2team).w,d1
	bne.w	.8
	jmp	setc2player
.8
	cmp.w	(cont4team).w,d1
	bne.w	.0
	jmp	setc4player
.9
	cmp.w	(cont2team).w,d1
	bne.w	.10
	jmp	setc2player
.10
	cmp.w	(cont1team).w,d1
	bne.w	.11
	jmp	setc1player
.11
	cmp.w	(cont3team).w,d1
	bne.w	.12
	jmp	setc3player
.12
	cmp.w	(cont4team).w,d1
	bne.w	.0
	jmp	setc4player
.13
	cmp.w	(cont1team).w,d1
	bne.w	.14
	jmp	setc1player
.14
	cmp.w	(cont2team).w,d1
	bne.w	.15
	jmp	setc2player
.15
	cmp.w	(cont3team).w,d1
	bne.w	.16
	jmp	setc3player
.16
	cmp.w	(cont4team).w,d1
	bne.w	.0
	jmp	setc4player

puckbody	;Puck hits player a2. a3 = puck. The puck bounces off; a high fast puck makes a2 fall.
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$2A,$00,$03,$00,$64,$66,$00,$00,$94,$0C,$6B,$00,$08,$00,$18
	dc.b	$6E,$00,$00,$0C,$32,$00,$02,$41,$00,$0F,$66,$00,$00,$80,$61,$00
	dc.b	$A5,$D4,$3F,$3C,$00,$24,$4E,$B9,$00,$08,$84,$70,$42,$6B,$00,$2C
	dc.b	$15,$7C,$00,$08,$00,$5E,$30,$13,$90,$52,$32,$2B,$00,$14,$92,$6A
	dc.b	$00,$14,$66,$00,$00,$08,$2F,$0A,$61,$00,$AC,$60,$34,$2B,$00,$28
	dc.b	$36,$2B,$00,$2A,$17,$40,$00,$28,$17,$41,$00,$2A,$61,$00,$A7,$32
	dc.b	$0C,$6B,$00,$08,$00,$18,$6F,$00,$00,$34,$C5,$C2,$C7,$C3,$D4,$83
	dc.b	$B4,$BC,$09,$00,$00,$00,$63,$00,$00,$0E,$0C,$6B,$00,$0C,$00,$18
	dc.b	$6E,$00,$E8,$E0,$4E,$75,$08,$EA,$00,$05,$00,$62,$66,$00,$00,$0E
	dc.b	$32,$3C,$14,$42,$C5,$4B,$61,$00,$AD,$CE,$C5,$4B

rtss2	;The shared rts many routines branch to
	rts

puckgoalie	;Puck hits goalie a2 (a3 = puck, d0 / d1 = goalie - puck x / y): a save bounces it, a slow puck is held
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$38,$00,$04,$C3,$38,$66,$F6,$42,$42,$0C,$6B,$00,$08,$00,$18
	dc.b	$6E,$00,$00,$04,$54,$42,$44,$40,$44,$41,$61,$00,$AB,$86,$90,$6A
	dc.b	$00,$54,$02,$40,$00,$07,$32,$00,$02,$41,$00,$03,$66,$00,$00,$08
	dc.b	$30,$39,$00,$C0,$00,$08,$02,$40,$00,$04,$E4,$48,$0A,$40,$00,$01
	dc.b	$D4,$40,$D4,$42,$41,$FA,$01,$68,$30,$30,$20,$00,$72,$0F,$D2,$32
	dc.b	$00,$00,$41,$FA,$01,$62,$08,$2A,$00,$03,$00,$04,$67,$00,$00,$06
	dc.b	$0A,$42,$00,$02,$30,$2A,$00,$06,$08,$B8,$00,$02,$C3,$42,$61,$00
	dc.b	$D9,$5C,$61,$00,$A4,$E2,$0C,$78,$30,$00,$B7,$88,$6E,$00,$00,$0C
	dc.b	$0C,$78,$D0,$00,$B7,$88,$6E,$00,$00,$1A,$3F,$3C,$00,$0B,$08,$2A
	dc.b	$00,$06,$00,$62,$67,$00,$00,$06,$3E,$BC,$00,$0D,$4E,$B9,$00,$08
	dc.b	$85,$86,$3F,$3C,$00,$24,$4E,$B9,$00,$08,$84,$70,$34,$38,$B7,$BE
	dc.b	$6B,$00,$00,$60,$50,$F8,$B7,$BE,$EF,$42,$30,$7C,$B0,$5E,$D0,$C2
	dc.b	$11,$7C,$00,$14,$00,$5E,$31,$E8,$00,$52,$BF,$0C,$08,$B8,$00,$02
	dc.b	$C3,$3A,$08,$B8,$00,$03,$C3,$3A,$42,$6B,$00,$2C,$15,$7C,$00,$0A
	dc.b	$00,$5E,$35,$7C,$00,$04,$00,$46,$30,$13,$90,$52,$32,$2B,$00,$14
	dc.b	$92,$6A,$00,$14,$66,$00,$00,$08,$2F,$0A,$61,$00,$AB,$10,$17,$40
	dc.b	$00,$28,$17,$41,$00,$2A,$60,$00,$A5,$EA,$08,$F8,$00,$02,$C3,$42
	dc.b	$4E,$75,$0C,$6A,$04,$9A,$00,$58,$67,$BE,$70,$02,$D0,$2A,$00,$6D
	dc.b	$E1,$40,$E3,$40,$61,$00,$B7,$34,$06,$40,$0C,$00,$D0,$40,$6A,$00
	dc.b	$00,$06,$30,$3C,$7F,$FF,$08,$2A,$00,$01,$00,$63,$66,$00,$00,$3C
	dc.b	$0C,$53,$00,$2C,$6E,$00,$00,$34,$0C,$53,$FF,$D4,$6D,$00,$00,$2C
	dc.b	$0C,$6B,$01,$24,$00,$14,$6E,$00,$00,$22,$0C,$6B,$FE,$DC,$00,$14
	dc.b	$6D,$00,$00,$18,$0C,$6B,$00,$E8,$00,$14,$6E,$00,$00,$0C,$0C,$6B
	dc.b	$FF,$18,$00,$14,$6E,$00,$00,$04,$E4,$40,$B0,$78,$B7,$86,$6D,$00
	dc.b	$FF,$58,$B0,$78,$B7,$88,$6D,$00,$FF,$50,$44,$40,$B0,$78,$B7,$86
	dc.b	$6E,$00,$FF,$46,$B0,$78,$B7,$88,$6E,$00,$FF,$3E,$08,$2A,$00,$02
	dc.b	$00,$63,$66,$00,$FF,$34,$42,$6B,$00,$2C,$60,$00,$FB,$C6,$00,$74
	dc.b	$00,$6F,$00,$71,$00,$73,$55,$9D,$67,$55,$9D,$67,$55,$9D,$67,$55
	dc.b	$9D,$67,$55,$9D,$67,$55,$9D,$67,$55,$9D,$67,$55,$9D,$67,$55,$55
	dc.b	$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$F0
	dc.b	$55,$F0,$55,$F0,$55,$F0,$55,$F0,$55,$F0,$55,$F0,$55,$F0,$55,$F0
	dc.b	$55,$F0,$55,$F0,$55,$F0,$D5,$75,$D5,$75,$D5,$75,$D5,$75,$D5,$75
	dc.b	$D5,$75,$D5,$75,$D5,$75,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	dc.b	$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	dc.b	$55,$55,$55,$55,$55,$55,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
	dc.b	$F0,$F0,$F0,$F0,$F0,$F0,$57,$57,$57,$57,$A5,$A5,$A5,$A5,$A5,$A5
	dc.b	$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5
	dc.b	$A5,$A5,$9D,$67,$9D,$67,$9D,$67,$9D,$67,$9D,$67,$9D,$67,$9D,$67
	dc.b	$9D,$67,$D5,$D5,$75,$75,$D5,$D5,$75,$75,$D5,$D5,$75,$75,$D5,$D5
	dc.b	$75,$75,$D5,$D5,$75,$75,$D5,$D5,$75,$75,$D5,$D5,$75,$75,$D5,$D5
	dc.b	$75,$75,$50,$F8,$B7,$BE,$30,$3C,$10,$00,$61,$00,$B5,$C2,$37,$40
	dc.b	$00,$2A,$30,$3C,$10,$00,$61,$00,$B5,$B6,$37,$40,$00,$28,$30,$3C
	dc.b	$10,$00,$61,$00,$B5,$B6,$37,$40,$00,$2C,$60,$00,$A4,$46

makepde	;Pass d0 as value to be scaled by player a0's energy level (full energy while sflags7 bit 4 is set). Return d0
	;as result
	ext.w	d0
	move.w	d0,-(sp)
	movem.l	d1/a2-a3,-(sp)
	movea.l	a0,a3
	bsr.w	getpde
	btst	#4,(sflags7).w
	beq.w	.0
	move.w	#$1000,d0
.0
	movem.l	(sp)+,d1/a2-a3
	muls.w	(sp)+,d0
	asl.l	#4,d0
	swap	d0
	ext.l	d0
	rts

getpde	;Get player a3's energy level into d0. Return a2 = his team struct, d1 = pnum*2
	movea.w	#(tmstruct-M68K_RAM),a2
	btst	#6,$62(a3)
	beq.w	.0
	adda.w	#$39E,a2	;team is away
.0
	move.b	$67(a3),d1
	ext.w	d1
	add.w	d1,d1
	move.w	$34(a2,d1.w),d0
	rts

setpde	;d1 = rostnum of player * 2, a2 = team struct, d0 = new energy level (0 if negative)
	tst.w	d0
	bpl.w	.0
	clr.w	d0
.0
	move.w	d0,$34(a2,d1.w)
	rts

