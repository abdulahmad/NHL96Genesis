;	Collisions. checkcoll tests the players and the boards, checkgoal scores,
;	and wallcoll bounces an object off the boards.

checkcoll							;d2 = new x coord, d3 = new y coord, a3 = struct of object. Check wall
									;collision (around the hot spot and the
									;end of the stick) and player collisions, then move a3 in the OOlist sort
									;order by its y. If a player collision set collflag, restore the old x/y
									;instead. Called from updateplayers.
	clr.w	(collflag).w
	btst	#sfhor,(sflags).w
	beq.w	.0
	exg	d2,d3
.0
	btst	#pfnc,pflags(a3)
	bne.w	.ex
	movem.l	d0-d7,-(sp)
	move.w	(a3),d2
	move.w	Ypos(a3),d3
	move.w	radiusx(a3),(wcradiusx).w
	move.w	radiusy(a3),(wcradiusy).w
	bsr.w	checkwallcoll
	move.w	Wallcos(a3),d0
	or.w	Wallsin(a3),d0
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
	move.w	OldXpos(a3),(a3)
	move.w	OldYpos(a3),Ypos(a3)
	rts

checkplcoll							;Check collision with other players. d2/d3 = x/y cords, a3 = struct. Walk
									;up and down the OOlist from a3 and
									;call checkcx for each object within $10 in y. Called from checkcoll
	btst	#pf2npc,pflags2(a3)
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

checkcx								;d4 = obj. # * 2 for possible collision so check x range and distance for
									;collision. d2 = x, d5 = delta y, a3
									;= moving object.
	movem.l	d0-d7/a0-a3,-(sp)
	asl.w	#6,d4
	movea.l	#SortCords,a2
	adda.w	d4,a2
	btst	#pfnc,pflags(a2)
	bne.w	.exit
	btst	#pf2npc,pflags2(a2)
	bne.w	.exit
	cmpi.w	#$B,SCnum(a2)
	bgt.w	.exit
	move.w	(a2),d0
	btst	#sfhor,(sflags).w
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
	move.w	#0,(collscale).w
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
	btst	#pf2fight,pflags2(a2)
	bne.w	.2
	move.w	SCnum(a3),impactp(a2)
.2
	btst	#pf2fight,pflags2(a3)
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
	move.b	legstr(a3),d0
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
	move.b	legstr(a2),d1
	tst.w	position(a2)
	bne.w	.7
	move.b	#$78,d1
.7
	tst.w	position(a3)
	bne.w	.8
	clr.b	d1
.8
	addi.w	#$8C,d1
	move.w	(collscale).w,d7
	mulu.w	d1,d7
	lsr.w	#4,d7
	add.w	d0,d1
	sub.w	d7,d0
	muls.w	d4,d0
	divs.w	d1,d0
	move.w	(collscale).w,d1
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

.droppuck							;A pad controlled puck carrier a0 at speed 2 or less loses the puck (puckc
									;-1, nopuck $1E)
	tst.w	position(a0)
	beq.w	.done
	btst	#pfjoycon,pflags(a0)
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

checkint							;Check for interference penalty. player a2 interferes with a3 or
									;vice-versa; goalie is only player who can
									;cause an interference call. Called from checkcx. .ci (checkint .1): a2 =
									;goalie, a3 = player interfering with goalie. a3 falls. The penalty ($22)
									;needs a3 in the crease area, a CPU player or a pad player's joystick
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
	btst	#gmclock,(gmode).w
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
	btst	#pf2pen,pflags2(a3)
	bne.w	rtss2
	cmpi.w	#3,(gsp).w
	beq.w	rtss2
	tst.w	position(a2)
	bne.w	rtss2
	move.w	#1,d0
	btst	#pfteam,pflags(a3)
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
	btst	#pfjoycon,pflags(a3)
	beq.w	rtss2
.5
	move.w	Ypos(a2),d0
	btst	#pfgoal,pflags(a2)
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
	sub.b	fighting(a3),d0
	bsr.w	randomd0
	cmp.w	#4,d0
	bhi.w	rtss2
	btst	#gmhl,(gmode).w
	bne.w	rtss2
	moveq	#$22,d0
	jmp	AddPenalty

checkcheck							;Contact: a stopped pad controlled puck carrier a2 loses the puck, then
									;CCStart for a3 on a2 and for a2 on a3
	movem.l	d0-d4/a0-a3,-(sp)
	btst	#pfjoycon,pflags(a2)
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

CCStart								;Player a3 is checking player a2
	cmpi.w	#SPAHold,SPA(a2)
	beq.w	holdcheck
	cmpi.w	#SPAHold3,SPA(a2)
	beq.w	holdcheck
	cmpi.w	#SPAhook,SPA(a2)
	beq.w	holdcheck
	cmpi.w	#SPAsweepchk,SPA(a2)
	beq.w	Bcheck
	cmpi.w	#SPAgsweepchk,SPA(a2)
	beq.w	Bcheck
	cmpi.w	#SPAburst,SPA(a3)
	bne.w	rtss2
	btst	#gmclock,(gmode).w
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
	bset	#pfalock,pflags(a3)
	bsr.w	SetSPA
	tst.w	position(a2)
	beq.w	rtss2
	cmp.w	#$14,d4
	blt.w	rtss2
	moveq	#$78,d0
	btst	#pfjoycon,pflags(a3)
	beq.w	*+4
.0
	sub.b	legstr(a3),d0
	add.b	legstr(a2),d0
	lsr.w	#1,d0
	exg	a2,a3
	jsr	(wallcollduringcheck).l
	exg	a2,a3
	sub.w	impact(a2),d0
	beq.w	.2
	bmi.w	.2
	btst	#pf3wall,pflags3(a3)
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
	btst	#gmhl,(gmode).w
	bne.w	rtss2
	move.b	(HVcount).l,d0
	andi.w	#2,d0
	addi.w	#$16,d0
	jsr	(PenShotChk).l
	jmp	AddPenalty
.2
	bsr.w	checkagr
	cmp.w	#3,d0
	bhi.w	.4
	btst	#gmhl,(gmode).w
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

checkinglist						;Check animation by the direction from a3 to a2 (CCStart)
	dc.b	$15,$26,$14,$94,$14,$94,$14,$94,$14,$94,$15,$26,$15,$26,$15,$26

CheckPenalties						;Penalties a check can draw: Roughing, Cross Check, Elbowing, High
									;Sticking (one picked by seed)
	dc.b	$00,$1A,$00,$1C,$00,$30,$00,$32

checkagr							;Aggression check
	move.w	#$28,d0
	sub.b	fighting(a3),d0
	lsr.b	#1,d0
	mulu.w	#$D,d0
	btst	#pfjoycon,pflags(a3)
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
	btst	#pf3break,pflags3(a2)
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
	btst	#pfteam,pflags(a3)
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

holdcheck							;Player a2 in a hold or hook animation holds a3 (within 1 direction of
									;where a2 faces): both get the average
									;velocity, the hold animations, and checkagr rolls penalty $24 or $1E
	btst	#pfalock,pflags(a3)
	bne.w	rtss2
	tst.w	position(a3)
	beq.w	rtss2
	btst	#pf2fight,pflags2(a3)
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
	bclr	#sfssdir,(sflags).w
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
	bset	#pfalock,pflags(a3)
	move.w	#SPAflail,d1
	cmpi.w	#SPAHold3,SPA(a2)
	bne.w	.0
	move.w	#SPAflailpuck,d1
	move.w	(puckc).w,d0
	cmp.w	SCnum(a3),d0
	bne.w	.0
	st	(puckc).w
	move.b	#$20,nopuck(a3)
.0
	bsr.w	SetSPA
	exg	a2,a3
	bset	#pfalock,pflags(a3)
	move.w	#SPAHold3,d1
	cmpi.w	#SPAHold3,SPA(a3)
	beq.w	.1
	move.w	#SPAHold2,d1
	cmpi.w	#SPAHold,SPA(a3)
	beq.w	.1
	move.w	#SPAhook2,d1
.1
	bsr.w	SetSPA
	bsr.w	checkagr
	cmp.w	#3,d0
	bhi.w	.exit
	btst	#gmhl,(gmode).w
	bne.w	.exit
	move.w	#$24,d0
	cmpi.w	#SPAHold2,SPA(a3)
	beq.w	.2
	move.w	#$1E,d0
.2
	jsr	(PenShotChk).l
	jsr	(AddPenalty).l
.exit
	exg	a2,a3
	st	(collflag).w
	rts

Bcheck								;a2 B-checks a3 (CCStart, sweep checks). With OptPen off and a pad
									;controlled a2 it needs randomd0($20 +
									;a2 checking - a3 legstr) >= $18; a3 within 1 direction of where a2 faces
									;falls (FallDown) and checkagr may call tripping ($20). Sets collflag
	btst	#pfalock,pflags(a3)
	bne.w	rtss2
	tst.w	position(a3)
	beq.w	rtss2
	btst	#pf2fight,pflags2(a3)
	bne.w	rtss2
	tst.w	(OptPen).w
	bne.w	.checkdir
	btst	#pfjoycon,pflags(a2)
	beq.w	.checkdir
	move.w	#$20,d0
	add.b	$76(a2),d0
	sub.b	legspd(a3),d0
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

FallDown							;Player a2 falls down (hit by a3, or the puck): the fall animation, the
									;injury chance, the penalty
	cmpi.w	#$B,SCnum(a2)
	bgt.w	rtss2
	cmpi.w	#SPAinjuryfall,SPA(a2)
	blt.w	.0
	cmpi.w	#SPAinjury1,SPA(a2)
	ble.w	rtss2
.0
	cmpi.w	#SPAstumble,SPA(a2)
	beq.w	rtss2
	cmpi.w	#SPAfallfwd,SPA(a2)
	beq.w	rtss2
	cmpi.w	#SPAfallback,SPA(a2)
	beq.w	rtss2
	cmpi.w	#SPAflip,SPA(a2)
	beq.w	rtss2
	cmpa.l	(PlayerChked).w,a2
	bne.w	.1
	cmpa.l	(PlayerChking).w,a3
	bne.w	.1
	rts
.1
	move.l	a2,(PlayerChked).w		;player checked
	move.l	a3,(PlayerChking).w		;player checking
	btst	#pf3onetimer,pflags3(a2)	;is player a2 doing a one-timer
	bne.w	rtss2
	btst	#pf3onetimer,pflags3(a3)	;Is player a3 doing a one-timer
	bne.w	rtss2
	move.w	#SPAstumble,d1
	btst	#pf3wall,pflags3(a3)	;wall collision bit
	bne.w	.cont2
	cmpi.b	#$18,endurance(a2)
	blt.w	.cont2
	tst.b	nopuck+1(a2)			;check if puck collision possible
	bne.w	.cont2
	move.w	(HVcount).l,d0			;frame counter
	andi.w	#$F,d0					;pass 1st byte of d0
	addi.w	#$10,d0
	cmp.w	impact(a2),d0			;compare impact value to d0.
	ble.w	.cont2
	move.b	#$3C,nopuck+1(a2)		;move 3C (60 decimal) into nopuck
	bra.w	.hitter
.cont2
	tst.w	position(a3)			;check for goalie
	beq.w	.chkpos
	movea.w	#(tmstruct-M68K_RAM),a0	;Start of Home Team Stats Struct
	btst	#pfteam,pflags(a3)
	beq.w	.AddChktoPlayerStats
	adda.w	#$39E,a0				;Change to Away Team Stats
.AddChktoPlayerStats
	addq.w	#1,$10(a0)				;Add 1 Chk to Team Total
	clr.w	d0
	move.b	weight(a3),d0
	adda.w	d0,a0
	addq.b	#1,$130(a0)
	addq.w	#1,(ChkCnt).w			;Add 1 to ChkCnt
	tst.b	checking(a3)
	bne.w	.chkpos
	addq.w	#2,(ChkCnt).w			;add 2 to ChkCnt
.chkpos
	move.b	#$78,nopuck(a2)
	move.w	(a3),d0					;Xpos
	sub.w	(a2),d0					;sub Xpos
	move.w	Ypos(a3),d1
	sub.w	Ypos(a2),d1				;sub Ypos
	bsr.w	vtoa
	tst.w	position(a2)
	beq.w	.24
	jsr	(wallcollduringcheck).l		;check for wall collision
	btst	#pf3wall,pflags3(a2)	;check wall collision bit
	beq.w	.24
	movem.l	d1-d4,-(sp)
	move.w	Xvel(a2),d1
	bpl.w	.yvel
	neg.w	d1						;negate d1
.yvel
	move.w	Yvel(a2),d2
	bpl.w	.chkpos2
	neg.w	d2						;negate d2
.chkpos2
	move.w	(a2),d3					;Xpos of player into d3
	sub.w	(a3),d3					;sub Xpos of checker
	move.w	Ypos(a2),d4
	sub.w	Ypos(a3),d4
	cmpi.w	#$11E,Ypos(a3)
	bgt.w	.bnet1
	cmpi.w	#$FEE2,Ypos(a3)
	blt.w	.bnet2
	tst.w	(a3)					;In between goal lines
	bpl.w	.posx
	tst.w	d3						;check diff of Xpos
	bpl.w	.chktowardcenterice
	cmp.w	#$FFFD,d3				;comp diff of Xpos with -3
	bgt.w	.chktowardcenterice
	bra.w	.chkawayfromcenterice
.posx
	tst.w	d3						;check diff of Xpos
	bmi.w	.chktowardcenterice
	cmp.w	#3,d3					;comp diff of Xpos with 3
	blt.w	.chktowardcenterice
	bra.w	.chkawayfromcenterice
.bnet2
	tst.w	d4						;check diff of Ypos
	bpl.w	.chktowardcenterice
	bra.w	.chkawayfromcenterice
.bnet1
	tst.w	d4						;check diff of Ypos
	bmi.w	.chktowardcenterice
	bra.w	.chkawayfromcenterice
.chktowardcenterice
	movem.l	(sp)+,d1-d4
	bra.w	.24
.chkawayfromcenterice
	movem.l	(sp)+,d1-d4				;pop from stack
	bra.w	*+4						;to the next instruction (.playerpos)
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
	addi.w	#$96,(Crowdlevel).w
	move.w	d1,-(sp)				;push to stack
	move.b	#0,temp1(a3)
	move.b	#0,pnum(a3)
	move.w	#SPAcrosscheck,d1
	jsr	(SetSPA).l					;set animation
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	move.w	(sp)+,d1				;pop from stack
.12
	movem.l	d0/a0,-(sp)				;push to stack
	cmpi.w	#$122,Ypos(a2)
	bgt.w	.playerabovetopgoalline
	cmpi.w	#$FEDE,Ypos(a2)
	blt.w	.playerbelowbottomgoalline
	tst.w	(a2)					;test player Xpos
	bmi.w	.playerleftofcenter
	move.w	#2,d0					;player right of center
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
	btst	#pf3fall,pflags3(a2)
	bne.w	.22
	move.w	#$C,-(sp)
	btst	#pfteam,pflags(a2)
	beq.w	.21
	move.w	#$B,(sp)
.21
	jsr	(sfx).l
.22
	bset	#pf3fall,pflags3(a2)	;set falldown bit
	bset	#pfdoff,pflags(a2)
	movem.l	(sp)+,d0/a0				;pop from stack
	bra.w	.25

.23									;Board check animation by side of the rink (two words a side)
	dc.b	$22,$AE,$22,$AE,$23,$60,$23,$60,$24,$12,$24,$12,$24,$C4,$24,$C4

.24
	move.w	#SPAfallback,d1
	sub.w	facedir(a2),d0
	addq.w	#1,d0
	andi.w	#7,d0
	cmp.w	#2,d0
	bls.w	.hitter
	move.w	#SPAfallfwd,d1

.25
	move.w	facedir(a2),d0
	andi.w	#3,d0
	bne.w	.hitter
	cmpi.b	#$14,$76(a3)
	blt.w	.hitter
	cmpi.w	#$B,SCnum(a3)			;check if SCNum of checker is a player
	bgt.w	.hitter
	btst	#5,pflags3(a2)			;check if falldown bit is set for player
	bne.w	.hitter
	move.w	#SPAflip,d1

.hitter
	exg	a2,a3						;swap a2 and a3
	bset	#5,pflags(a3)
	bsr.w	SetSPA
	exg	a2,a3
	tst.w	position(a3)
	beq.w	.h0
	tst.w	position(a2)
	beq.w	.h0
	addi.w	#$12C,(Crowdlevel).w
	addi.w	#$F,(CwdExciteLvl).w
.h0
	move.w	(puckc).w,d0			;move puck carrier SCNum into d0
	bmi.w	.h6
	cmp.w	SCnum(a2),d0			;check if puck carrier is a2
	bne.w	.h6
	st	(puckc).w					;clear out puck carrier
	btst	#gmhl,(gmode).w			;check if highlight
	bne.w	.h4
	cmpi.w	#SPAfallback,SPA(a2)
	bne.w	.h4
	move.w	facedir(a2),d0			;facedir into d0
	andi.w	#3,d0					;pass first 2 bits of d0
	bne.w	.h4
	btst	#4,pflags2(a2)			;check if player is unavailable
	bne.w	.h4
	move.w	#$DC,d0
	bsr.w	randomd0
	cmp.w	impact(a2),d0			;compare impact to d0
	bgt.w	.h4
	btst	#gmclock,(gmode).w		;check if clock running
	bne.w	.h4
	exg	a2,a3
	move.w	#SPAinjuryfall,d1
	btst	#0,(seed+1).w
	beq.w	.h1
	move.w	#SPAinjuryfall2,d1
.h1
	bsr.w	SetSPA
	exg	a2,a3
	bsr.w	setInjuryType
	btst	#5,(sflags7).w			;check if clock running
	bne.w	.h3
	exg	a2,a3
	move.w	#SPAinjury2,d1
	btst	#0,(seed+1).w
	bne.w	.h2
	move.w	#SPAinjury1,d1
.h2
	bsr.w	SetSPA
	exg	a2,a3
.h3
	move.w	#4,(InjCntDown).w
	moveq	#$14,d0
	tst.w	position(a3)
	beq.w	.h7
	tst.w	(OptPen).w
	beq.w	.h7
	moveq	#$12,d0
	jsr	(AddPenalty2).l
	jmp	Stop4Pen
.h4
	addq.w	#5,(ChkCnt).w
	move.w	#$B,-(sp)
	btst	#6,pflags(a2)
	bne.w	.h5
	move.w	#$C,(sp)
.h5
	jsr	(song).l
	rts
.h6
	jmp	newcheck
.h7
	jmp	AddPenalty2

setInjuryType						;a2 injured: out for the period ($FFFD) or the game ($FFFC); in a season a
									;random games count (SetInjuryGames)
	bclr	#2,(sflags13).w
	addq.w	#5,(ChkCnt).w
	move.w	d0,-(sp)
	bset	#pf2unav,pflags2(a2)
	addi.w	#$12C,(Crowdlevel).w
	addi.w	#$1E,(CwdExciteLvl).w
	move.w	#$D,-(sp)				;sound effect
	jsr	(sfx).l
	move.w	(a2),(xc1).w			;move Xpos to scroll center
	move.w	Ypos(a2),(yc1).w
	bset	#sfslock,(sflags).w
	clr.w	d1						;clear d1
	movea.w	#(tmstruct-M68K_RAM),a0	;move Home team Struct to a0
	btst	#pfteam,pflags(a2)
	beq.w	.0						;branch if home
	move.w	#$8000,d1
	adda.w	#$39E,a0				;add $364 to a0 (Away Team Struct start)
.0
	move.b	weight(a2),d1
	move.w	d1,(TempPlOffset).w
	ext.w	d1						;sign extend - in this case just makes upper bye of word 00
	add.w	d1,d1					;add d1 to itself
	exg	a2,a3						;swap a2 and a3
	jsr	(getFgtbyte).l				;get the Fgt byte (divided by 4)
	exg	a2,a3						;swap back
	tst.w	d0						;check if d0 is zero
	bne.w	.not0
	bclr	#5,(sflags7).w			;clear injury game bit
	move.w	#$FFFD,$6C(a0,d1.w)
	bra.w	.1
.not0
	cmp.w	#3,d0					;compare d0 to 3 (if H/F was 12, d0 = 3)
	beq.w	.2
	bclr	#5,(sflags7).w
	move.w	#$FFFD,$6C(a0,d1.w)
	jsr	(chkFgtBit1).l				;check Fgt bit 1 of player.
	beq.w	.1
.2
	bset	#5,(sflags7).w			;set injury game bit
	move.w	#$FFFC,$6C(a0,d1.w)
	btst	#7,(GameFlags).w
	beq.w	.1
	jsr	(RandomInjuryGames).l
.1
	move.w	(sp)+,d0
	rts

checkwallcoll						;d2/d3 = x/y to test, a3 = object, wcradiusx/wcradiusy = radius. Check the
									;corner circles, the goals (checkgoal with a2 = SortCords+(13*SCstruct)
									;top, SortCords+(12*SCstruct) bottom) and then the side and end boards.
									;Calls wallcollb on a hit, with d0/d1 = cos/sin of the wall.
	bclr	#pf3wall,pflags3(a3)	;wall collision bit
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
	bsr.w	Sroot
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
	move.w	Wallcos(a3),d0
	or.w	Wallsin(a3),d0
	bne.w	rtss2
	move.w	#$100,d0				;now check side walls
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

checkgoal							;Check object a3 against the goal / net a2: the puck scores (Goal), a
									;player collides (checkgoalp)
	cmpi.w	#$D,Zpos(a3)
	bgt.w	rtss2
	cmpi.w	#$E,SCnum(a3)
	bne.w	checkgoalp				;coll with player not puck
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
	sub.w	(a2),d2					;Xpos
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
	st	(collflag).w				;inside goal area now
	cmpi.w	#$D,OldZpos(a3)			;compare OldZpos to zside
	blt.w	.nod
	move.w	OldZpos(a3),Zpos(a3)
	bra.w	.7
.nod
	bclr	#pfgoal,pflags(a3)
	move.w	(puckc).w,d0
	bmi.w	.nocon
	st	(puckc).w
	asl.w	#7,d0
	movea.w	#(SortCords-M68K_RAM),a0
	move.b	#8,nopuck(a0,d0.w)
	move.w	(pucky).w,d1
	btst	#pfgoal,pflags(a0,d0.w)
	bne.w	.an
	neg.w	d1
.an
	tst.w	d1
	bpl.w	.nocon
	bset	#pfgoal,pflags(a3)
.nocon
	move.w	#$FF00,d0
	move.l	Ypos(a3),d1
	sub.l	OldYpos(a3),d1
	asr.l	#8,d1
	beq.w	.sideentry
	bmi.w	.3
	neg.w	d0						;check top entry
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
	btst	#pfgoal,pflags(a3)
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
	move.w	#$25,-(sp)				;sfx $25 when the clock is stopped
	btst	#gmclock,(gmode).w		;gmclock: no goal after the whistle
	bne.w	.5
	move.w	#8,(sp)					;sfx 8 and crowd
	addi.w	#$12C,(Crowdlevel).w
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
Goal								;A goal: the shootout count, EndPenaltyShotPlay, the score and both teams
	btst	#2,(BA_PS_flags).w
	beq.w	.6
	btst	#0,(gmode2).w
	bne.w	.0
	movem.l	d0/a0,-(sp)
	move.w	(BA_Sktr_SCnum).w,d0
	asl.w	#7,d0
	movea.l	#SortCords,a0
	adda.w	d0,a0
	btst	#pfgoal,pflags(a0)
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
	btst	#gmclock,(gmode).w
	bne.w	rtss2
.20
	bset	#0,(sflags4).w
	bclr	#3,(sflags8).w
	bsr.w	ChkShotStat
	jsr	(stop_current_song).l
	move.w	d0,-(sp)
	move.w	(Vcount).w,d0
.loop
	cmp.w	(Vcount).w,d0
	beq.s	.loop
	move.w	(sp)+,d0
	addq.w	#5,(ChkCnt).w
	move.w	#0,-(sp)
	jsr	(sfx).l
	jsr	(LockScroll).l
	addi.w	#$1F4,(Crowdlevel).w
	movea.w	#(tmstruct-M68K_RAM),a2
	lea	$39E(a2),a1
	tst.w	Ypos(a3)
	bpl.w	.9
	exg	a2,a1
.9
	btst	#gmdir,(gmode).w
	beq.w	.23
	exg	a2,a1
.23
	cmpi.w	#$7D,tmscore(a2)
	bge.w	.28
	addq.w	#1,tmscore(a2)
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
	btst	#sf2pwrplay,(sflags2).w
	beq.w	.14
	btst	#sf2pwrtm,(sflags2).w
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
	add.w	tmap(a2),d0
	sub.w	OldZpos(a1),d0
	move.b	d0,(a0)+
	addi.w	#$1E,(CwdExciteLvl).w
	cmpa.w	#(tmstruct-M68K_RAM),a2
	beq.w	.home
	subi.w	#$14,(CwdExciteLvl).w
	bset	#7,-1(a0)
.home
	move.w	tmtouch1(a2),d0
	move.b	d0,(a0)+
	move.w	#$FFFF,(a0)
	addi.w	#$C0,d0
	addq.b	#1,(a2,d0.w)
	move.w	tmtouch2(a2),d0
	bmi.w	.21
	cmp.w	tmtouch1(a2),d0
	beq.w	.21
	move.b	d0,(a0)+
	addi.w	#$DC,d0
	addq.b	#1,(a2,d0.w)
	move.w	tmtouch3(a2),d0
	bmi.w	.21
	cmp.w	tmtouch1(a2),d0
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
	bset	#pfnc,pflags(a3)
	move.w	#$1A,d0
	bsr.w	assreplace
	move.l	a3,-(sp)
	adda.w	#$80,a3
	move.w	#SPAsiren,d1
	tst.w	Ypos(a3)
	bpl.w	.29
	move.w	#SPAsiren2,d1
.29
	bsr.w	SetSPA
	movea.w	$22(a1),a3
	moveq	#$E,d0
	jsr	(AddPenalty2).l
	movea.l	(sp)+,a3
	rts

AssignTeam							;Give assignment d0 to every player of team a2 on the ice (assinsert)
	move.l	a3,-(sp)
	movea.w	tmsort(a2),a3
	moveq	#5,d3
.loop
	tst.w	position(a3)
	ble.w	.next
	btst	#pf2fight,pflags2(a3)
	bne.w	.next
	bclr	#pfnc,pflags(a3)
	bclr	#pf3onetimer,pflags3(a3)
	beq.w	.0
	jsr	(EndOneTimer).l
.0
	bsr.w	assinsert
.next
	adda.w	#$80,a3
	dbf	d3,.loop
	movea.l	(sp)+,a3
	rts

GetPeriodTimeRemaining				;Return d0 = (gsp << 14 | PerTimeTotal) - gameclock
	move.w	(gsp).w,d0
	swap	d0
	clr.w	d0
	lsr.l	#2,d0
	or.w	(PerTimeTotal).w,d0
	sub.w	(gameclock).w,d0
	rts

checkgoalp							;Check for player a3 collision with goal/net a2. Entered from checkgoal
	btst	#pf2npc,pflags2(a3)		;pflags2 bit 5: no player coll
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
	bsr.w	Sroot
	move.w	d0,d2
	movem.w	(sp)+,d0-d1
	addq.w	#1,d2
	asl.l	#8,d0
	divs.w	d2,d0
	asl.l	#8,d1
	divs.w	d2,d1
	bset	#4,(sflags6).w			;wallcoll: do not set the wall collision bit
	bsr.w	wallcoll
	bclr	#4,(sflags6).w
.exit
	movem.w	(sp)+,d2-d3
	rts
.0
	movem.w	d2-d3,-(sp)
	btst	#pfjoycon,pflags(a3)
	bne.w	.1
	movem.w	d0,-(sp)
	move.w	Ypos(a3),d0
	btst	#pfgoal,pflags(a3)
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
	bsr.w	Sroot
	move.w	d0,d2
	movem.w	(sp)+,d0-d1
	addq.w	#1,d2
	asl.l	#8,d0
	divs.w	d2,d0
	asl.l	#8,d1
	divs.w	d2,d1
	bset	#4,(sflags6).w			;wallcoll: do not set the wall collision bit
	bsr.w	wallcoll
	bclr	#4,(sflags6).w
	bra.w	.exit

CheckBump							;Supply minimum separation velocity for coll with walls/goal/net. a2 =
									;goal, a3 = player. On one frame in 32,
									;a player near the puck in y moving faster than $24CC knocks the net (a2
									;gets a quarter of a3's velocity, a3 stops, scroll lock at Vpos) and,
									;while the clock runs, calls penalty 8. Called from checkgoalp
	movem.l	d0-d1,-(sp)
	move.w	(HVcount).l,d0
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
	adda.w	#$C,sp					;drop the saved d0-d1 and the return to checkgoalp:
	;return to checkgoal's caller
	asr.w	#2,d0
	asr.w	#2,d1
	move.w	d0,Xvel(a2)
	move.w	d1,Yvel(a2)
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	bset	#sfslock,(sflags).w
	btst	#gmclock,(gmode).w
	bne.w	rtss2
	moveq	#8,d0
	jmp	AddPenalty2

wallcollb							;Bounce off the boards
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
	move.w	#SPAbglass,d1
	bsr.w	SetSPA
	movea.l	(sp)+,a3
	move.w	#$E,-(sp)
	jsr	(sfx).l
	addi.w	#$258,(Crowdlevel).w
	addi.w	#$F,(CwdExciteLvl).w
.1
	bset	#sfslock,(sflags).w
	bset	#pfnc,pflags(a3)
	tst.w	Ypos(a3)
	bpl.w	.2
	ori.w	#$8000,attribute(a3)
.2
	clr.w	SCstruct+frame(a3)		;frame+SCstruct(a3)
	btst	#gmclock,(gmode).w
	bne.w	rtss2
	move.l	a3,-(sp)
	move.w	(ltplayer).w,d0
	asl.w	#scsize,d0				;#scsize
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3
	moveq	#6,d0
	jsr	(AddPenalty2).l
	movea.l	(sp)+,a3
	rts

wallcoll							;d0 = cosine, d1 = sine of angle of incidence with wall, a3 = object.
									;Bounce a3 off the wall: the puck loses
									;speed, flips and plays sfx $28-$2B; a player sets the wall collision bit
									;(unless sflags6 bit 4) and plays SFXplayerwall on a hard hit
	move.w	d0,Wallcos(a3)
	move.w	d1,Wallsin(a3)
	movem.l	d2-d3,-(sp)
	movem.w	d0-d1,-(sp)
	muls.w	Yvel(a3),d0
	muls.w	Xvel(a3),d1
	sub.l	d1,d0
	asr.l	#8,d0
	move.w	d0,d2					;v1n
	movem.w	(sp),d0-d1
	muls.w	Xvel(a3),d0
	muls.w	Yvel(a3),d1
	add.l	d1,d0
	asr.l	#8,d0
	move.w	d0,d3					;v1t
	neg.w	d2
	cmpi.w	#puckscnum,SCnum(a3)	;#puckSCnum, SCnum
	bne.w	.player
	bclr	#sf2shot,(sflags2).w
	tst.w	d2
	bpl.w	.nocoll
	asr.w	#2,d2					;reduce normal speed on puck
	cmp.w	#$FC00,d2				;#-400
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
	move.w	d3,d0					;reduce tangent speed on puck
	asr.w	#6,d0
	sub.w	d0,d3
	asr.w	#1,d0
	sub.w	d0,d3
	bra.w	.noadd
.player
	cmp.w	#$3E8,d2				;#1000
	bgt.w	.nocoll
	bclr	#4,(sflags6).w
	bne.w	.3
	bset	#pf3wall,pflags3(a3)	;set wall collision bit
.3
	cmp.w	#$F000,d2				;$-1000
	bgt.w	.nosfx
	cmpi.w	#$A,impact(a3)			;impact(a3)
	blt.w	.nosfx
	move.w	#SFXplayerwall,-(sp)	;#SFXplayerwall
	jsr	(sfx).l
.nosfx
	asr.w	#2,d2
	cmp.w	#$FC7C,d2				;#-900
	blt.w	.noadd
	move.w	#$FC18,d2				;#-1000
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
wallcollsfx	equ	*			;Play the board hit sound when the flag was set
	bclr	#2,(sflags4).w
	beq.w	rtss2
	move.w	#5,-(sp)
	jmp	(sfx).l
wallcollcheck	equ	*	;Wall collision: clip a skater's y velocity and check the crease height
	cmpi.w	#$190,Ypos(a3)			;compare 190 hex to Ypos (back board?)
	bgt.w	.2						;branch if greater than
	cmpi.w	#$FE70,Ypos(a3)			;compare -190 to Ypos (back board?)
	bgt.w	.4						;branch if greater than
	;behind the boards: stop the y movement
.2
	clr.w	Yvel(a3)
	;puck on the ice (z 16 or less): check it against the players
.4
	cmpi.w	#$10,Zpos(a3)			;compare 10 hex to Zpos (feet in air)
	bgt.s	wallcollsfx
	move.w	SCnum(a3),d0			;move SCnum into d0
	asl.w	#1,d0					;current obj number
	movea.w	#(OOlistpos-M68K_RAM),a0
	movea.w	#(OOlist-M68K_RAM),a1
	movea.w	#(Ylist-M68K_RAM),a2
	move.w	(a0,d0.w),d1			;current obj position in OOlist
	;loop
.loop
	cmp.w	#$F,d1					;15 = Total sprites -1
	beq.w	.5						;it is top sprite on screen
	clr.w	d4
	move.b	1(a1,d1.w),d4			;next higher object number
	move.w	(a2,d4.w),d5			;Y pos of next higher object
	sub.w	Ypos(a3),d5				;sub Ypos from d5
	cmp.w	#$18,d5
	bgt.w	.5						;no higher sprite coll
	bsr.w	wallcollskater
	addq.w	#1,d1
	bra.s	.loop
	;d1 = $F or d5 > $16
.5
	move.w	(a0,d0.w),d1
	beq.w	.6
	;loop
.loop2
	clr.w	d4						;loop: examine the next lower object
	move.b	-$1(a1,d1.w),d4			;next lower object number
	move.w	Ypos(a3),d5				;move Ypos into d5
	sub.w	(a2,d4.w),d5			;sub Y pos of next lower object
	cmp.w	#$18,d5
	bgt.w	.6
	bsr.w	wallcollskater
	subq.w	#1,d1
	bne.s	.loop2
	;exit (also the end of the code above)
.6
	rts
wallcollskater	equ	*	;Wall collision of one skater against the others (low confidence)
	;local subroutine
	movem.l	d0-d7/a0-a3,-(sp)		;d4 = object number * 2
	lsr.w	#1,d4
	cmp.w	(puckc).w,d4			;compare puckc to d4
	beq.w	.loop3					;puck carrier
	cmp.w	#$B,d4					;compare 11 to d4
	bgt.w	.loop3
	asl.w	#scsize,d4
	movea.w	#(SortCords-M68K_RAM),a2
	adda.w	d4,a2					;a2 now has address of player struct
	btst	#2,(BA_PS_flags).w
	beq.w	.7						;branch if not set
	asr.w	#7,d4					;change d4 back to SCnum of puckc
	cmp.w	(BA_Sktr_SCnum).w,d4	;check d4 with SCnum of breakaway skater
	beq.w	.7						;branch if the same
	cmp.w	(BA_Goalie_SCnum).w,d4	;check d4 with SCnum of breakaway goalie
	bne.w	.loop3					;exit if not equal
	;check the collision
.7
	btst	#pfnc,pflags(a2)		;check if no player collision
	bne.w	.loop3
	tst.b	nopuck(a2)				;check if nopuck collision
	bne.w	.loop3					;branch if nopuck
	btst	#pf2unav,pflags2(a2)	;check if player unavailable
	bne.w	.9
	cmpi.w	#5,Zpos(a3)				;compare 5 to Zpos
	bgt.w	.9
	cmpi.w	#$200,Zvel(a3)			;compare 200 hex to Zvel
	bgt.w	.9
	move.l	a2,-(sp)
	bsr.w	GetHot					;Get Hot Spot d0/d1 = x/y
	add.w	(a2),d0					;add Xpos a2
	sub.w	(a3),d0					;sub Xpos a3
	cmp.w	#$10,d0
	bgt.w	.9
	cmp.w	#$FFF0,d0
	blt.w	.9						;branch if less than
	add.w	Ypos(a2),d1
	sub.w	Ypos(a3),d1
	cmp.w	#$10,d1
	bgt.w	.9
	cmp.w	#$FFF0,d1
	blt.w	.9						;branch if less than
	muls.w	d0,d0
	muls.w	d1,d1					;puck within stick reach (smaller while nopuck counts down): puckstick
	add.l	d1,d0					;add d1 to d0
	move.l	#$100,d1
	tst.b	nopuck(a3)				;check nopuck - puck not ready to be caught
	ble.w	.8						;branch if less than or equal
	lsr.w	#2,d1					;not in stick reach: try the body (goalies use their own reach)
	;stick reach check
.8
	cmp.l	d1,d0					;compare d1 to d0
	bhi.w	.9
	bsr.w	wallcollpuck
	bra.w	.loop3
	;body check
.9
	tst.w	position(a2)
	beq.w	.10
	btst	#pf3onetimer,pflags3(a2)	;check if doing one timer
	bne.w	.loop3
	move.w	(a2),d0					;Xpos into d0
	sub.w	(a3),d0					;sub Xpos a3
	cmp.w	#8,d0
	bgt.w	.loop3
	cmp.w	#$FFF8,d0
	blt.w	.loop3					;exit if less than
	move.w	Ypos(a2),d1
	sub.w	Ypos(a3),d1
	cmp.w	#8,d1
	bgt.w	.loop3
	cmp.w	#$FFF8,d1
	blt.w	.loop3					;exit if less than
	muls.w	d0,d0					;done with this player
	muls.w	d1,d1
	add.l	d1,d0					;add d1 to d0
	cmp.l	#$40,d0					;compare cbody squared to d0
	bhi.w	.loop3
	bsr.w	puckbody
	;(not branched to)
	;exit: restore the registers
.loop3
	movem.l	(sp)+,d0-d7/a0-a3
	rts
	dc.w	$0000,$0003,$0003,$0004,$0004,$0004,$0005,$0005
	dc.w	$0005,$0005,$0005,$0005,$0005,$0005,$0005,$0005
	dc.w	$0005,$0005,$0005,$0005,$0005,$0000,$0001,$0001
	dc.w	$0001,$0001,$0001,$0001,$0001,$0002,$0002,$0002
	dc.w	$0002,$0002,$0002,$0002,$0002,$0002,$0002,$0002
	dc.w	$0002,$0002,$0000,$0002,$0002,$0003,$0003,$0003
	dc.w	$0003,$0003,$0004,$0004,$0004,$0004,$0004,$0004
	dc.w	$0004,$0004,$0004,$0004,$0004,$0004,$0004
	;goalie: body reach from agility
.10
	move.l	a0,-(sp)
	movea.l	#$1F196,a0
	cmpi.w	#1,(OptSkill).w
	beq.w	.14
	cmpi.w	#2,(OptSkill).w
	bne.w	.12
	move.w	#1,d0
	move.w	#2,d1
	btst	#pfteam,pflags(a2)
	beq.w	.11
	move.w	#2,d0
	move.w	#1,d1
.11
	cmp.w	(cont1team).w,d0
	beq.w	.13
	cmp.w	(cont2team).w,d0
	beq.w	.13
	cmp.w	(cont3team).w,d0
	beq.w	.13
	cmp.w	(cont4team).w,d0
	beq.w	.13
	movea.l	#$1F1C0,a0
	bra.w	.14
.12
	movea.l	#$1F1EA,a0
	bra.w	.14
.13
	movea.l	#$1F1C0,a0
	cmp.w	(cont1team).w,d1
	beq.w	.14
	cmp.w	(cont2team).w,d1
	beq.w	.14
	cmp.w	(cont3team).w,d1
	beq.w	.14
	cmp.w	(cont4team).w,d1
	beq.w	.14
	movea.l	#$1F196,a0
.14
	clr.w	d0
	clr.w	d1
	move.b	$74(a2),d0
	move.b	$6F(a2),d1
	add.w	d1,d0
	move.b	$71(a2),d1
	add.w	d1,d0
	move.b	$73(a2),d1
	add.w	d1,d0
	asr.w	#3,d0
	andi.w	#$F,d0
	add.w	d0,d0
	move.w	(a0,d0.w),($FFFFBF9E).w
	movea.l	(sp)+,a0
	cmpi.w	#$15,(a2)
	bgt.w	.17
	cmpi.w	#$FFEB,(a2)
	blt.w	.17
	btst	#pfgoal,pflags(a2)
	beq.w	.15
	move.w	(pucky).w,d0
	subi.w	#$FEE0,d0
	move.w	$14(a2),d1
	subi.w	#$FEE0,d1
	bra.w	.16
.15
	move.w	(pucky).w,d0
	subi.w	#$120,d0
	move.w	$14(a2),d1
	subi.w	#$120,d1
.16
	eor.w	d1,d0
	bpl.w	.17
	bra.w	.22
.17
	move.w	($FFFFBF9E).w,($FFFFBFA4).w
	addq.w	#7,($FFFFBFA4).w
	move.w	(a2),d0
	move.w	$14(a2),d1
	bsr.w	wallcolldist
	ble.w	.18
	cmp.w	#$28,d0
	bge.w	.22
	cmp.w	#$28,d1
	bge.w	.22
	move.l	a2,-(sp)
	jsr	(GetHot2a).l
	move.w	($FFFFBF9E).w,($FFFFBFA4).w
	addq.w	#6,($FFFFBFA4).w
	bsr.w	wallcolldist
	ble.w	.18
	move.l	a2,-(sp)
	jsr	(GetHot2b).l
	move.w	($FFFFBF9E).w,($FFFFBFA4).w
	addq.w	#3,($FFFFBFA4).w
	bsr.w	wallcolldist
	ble.w	.18
	move.l	a2,-(sp)
	jsr	(GetHot2c).l
	move.w	($FFFFBF9E).w,($FFFFBFA4).w
	addq.w	#3,($FFFFBFA4).w
	bsr.w	wallcolldist
	bgt.w	.22
.18
	move.w	(a2),d0
	sub.w	(a3),d0
	move.w	$14(a2),d1
	sub.w	$14(a3),d1
	jsr	(puckgoalie).l
	bra.w	.loop3
wallcolldist	equ	*	;Distance check between two skaters (low confidence)
	sub.w	(a3),d0
	bpl.w	.19
	neg.w	d0
.19
	sub.w	$14(a3),d1
	bpl.w	.20
	neg.w	d1
.20
	cmp.w	($FFFFBFA4).w,d0
	bgt.w	.21
	cmp.w	($FFFFBFA4).w,d1
.21
	rts
	;missed the goalie
.22
	bclr	#2,(sflags4).w
	beq.w	.loop3					;exit if it was cleared already
	move.w	(puckc).w,d0			;move puckc into d0
	cmp.w	$52(a2),d0				;compare SCnum to d0
	beq.w	.loop3
	move.w	#SFXshotwiff,-(sp)
	jsr	(sfx).l
	bra.w	.loop3
wallcollpuck	equ	*	;Skater and puck contact check
	tst.w	$34(a2)					;a2 = player who collided
	bne.w	.23						;branch if not goalie
	btst	#gmhl,(gmode).w
	bne.w	rtss2					;exit if so (goalie always lets the shot in)
	;clear offside
.23
	bclr	#pfdoff,$62(a2)
	move.w	(puckc).w,d1			;move puckc into d1
	bmi.w	.28						;branch if no puck carrier
	asl.w	#7,d1
	movea.w	#(SortCords-M68K_RAM),a0
	adda.w	d1,a0					;a0 = Struct of puck carrier
	move.b	pflags(a0),d1
	move.b	$62(a2),d2
	eor.w	d1,d2					;compare pflags of each player
	btst	#pfteam,d2				;check if on same team
	beq.w	rtss2					;no stealing from teammate
	btst	#5,(sflags6).w			;check if puckc is in slot
	beq.w	.24
	cmp.l	#$40,d0					;steal range met: goalies always steal, nobody steals from a goalie
	bhi.w	rtss2
	bra.w	.25
	;bit 5 of sflags6 clear
.24
	cmp.l	#$24,d0
	bhi.w	rtss2
	;in range: goalie or skater
.25
	tst.w	$34(a2)					;check if colliding player is goalie
	beq.w	.27
	tst.w	position(a0)
	beq.w	rtss2					;no stealing from goalie
	move.b	endurance(a0),d0
	lsr.b	#1,d0
	bsr.w	makepde					;adjust for energy level
	move.w	d0,-(sp)
	exg	a0,a2						;swap a2 and a0 (a0 now collider)
	move.b	$72(a0),d0
	lsr.b	#1,d0					;divie by 2
	bsr.w	makepde					;adjust for energy
	exg	a0,a2						;swap back (a0 now puckc)
	neg.w	d0
	add.w	(sp)+,d0				;add puckc modified Stk
	addi.w	#$24,d0					;add 24 hex (36 decimal)
	bsr.w	randomd0
	btst	#5,(sflags6).w			;check if puckc is in slot
	beq.w	.26
	cmp.w	#4,d0					;steal: the carrier cannot touch the puck for a while (stick handling,
	bhi.w	rtss2					;exit if higher (not losing puck)
	bra.w	.27
	;bit 5 of sflags6 clear
.26
	cmp.w	#2,d0					;compare 2 to d0
	bhi.w	rtss2					;exit if higher (not losing puck)
.27
	move.b	endurance(a0),d0
	lsr.b	#1,d0
	bsr.w	makepde					;adj for energy
	addi.w	#$14,d0					;add 14 hex (20 dec)
	move.b	d0,nopuck(a0)			;move result into nopuck (cant get puck timer)
	exg	a0,a2						;swap a0 and a2 (a0 now collider)
	move.b	$72(a0),d0
	lsr.b	#1,d0
	bsr.w	makepde					;adj for energy
	addi.w	#$14,d0					;add 14 hex (20 dec)
	move.b	d0,$5E(a0)				;move result into nopuck
	exg	a0,a2
	move.w	SCnum(a0),(lastplayer).w	;SCNum of puckc into lastplayer
	bclr	#sfspdir,(sflags).w		;clear pass dir mode
	bclr	#sfssdir,(sflags).w		;clear shot dir mode
	;loop
.loop4
	move.w	#SFXstdef,-(sp)
	jsr	(sfx).l
	bsr.w	a2touchpuck				;deflect
	bra.w	puckgoaliescatter		;no carrier (goalie in the smaller range): one-timer check
	;d1 negative
.28
	tst.w	$34(a2)
	bne.w	.29
	cmp.l	#$40,d0
	bhi.w	rtss2					;smaller range for stealing puck
	;one timer?
.29
	btst	#pf3onetimer,$64(a2)
	beq.w	.31
	cmp.l	#$64,d0					;not a one-timer, or past its frame: catch or deflect by puck speed
	bhi.w	.35
	btst	#3,(GameFlags).w
	bne.w	.30
	cmpi.w	#$18,$5A(a2)
	bge.w	.31
	move.w	#$18,$5A(a2)
.30
	bset	#7,(sflags8).w
	;no steal: catch check
.31
	move.w	(puckvx).w,d0			;d0 = puck speed^2, d1 = catch limit
	move.w	(puckvy).w,d1
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	clr.w	d1
	btst	#sf2shot,(sflags2).w	;check if shot was taken
	bne.w	.32
	btst	#pf3onetimer,$64(a2)	;check if one timer
	bne.w	.34
	move.b	$72(a2),d1
	mulu.w	#$15E,d1
.32
	addi.l	#$32C8,d1
	movem.w	d2,-(sp)
	move.w	(passplayer).w,d2
	cmp.w	$52(a2),d2
	movem.w	(sp)+,d2
	bne.w	.33
	addi.l	#$32C8,d1
.33
	mulu.w	d1,d1
	cmp.l	d1,d0
	bls.w	wallcollhit
	move.b	#8,$5E(a2)
	bra.w	.loop4
	;pf3onetimer set
.34
	exg	a2,a3
	jsr	(onetimershot).l
	exg	a2,a3
	rts
	;d0 > $64
.35
	cmp.l	#$144,d0
	bhi.w	.36
	btst	#3,(GameFlags).w
	bne.w	.36
	cmpi.w	#$18,$5A(a2)
	bge.w	.36
	move.w	#$18,$5A(a2)
	;exit (also the end of the code above)
.36
	rts
wallcollhit	equ	*	;A skater hits the puck: take the puck and flag the hit
	move.w	#SFXpuckget,-(sp)
	move.w	$52(a2),d0
	move.w	d0,(puckc).w
	movea.w	#(tmstruct-M68K_RAM),a0
	lea	$39E(a0),a1
	btst	#pfteam,$62(a2)
	bne.w	.tm
	exg	a0,a1
.tm
	st	$1A(a0)						;a0 = other team, a1 = a2's team
	st	$1C(a0)
	bset	#3,$30(a0)				;tmflast: other team did not touch it last
	bclr	#4,(sflags3).w
	beq.w	.snd					;no
	addq.w	#1,tmfowon(a1)			;tmfowon + 1
	addi.w	#$C8,(Crowdlevel).w
	addq.w	#5,(ChkCnt).w
	move.w	#SFXcrowdboo,(sp)
	cmpa.w	#(tmstruct-M68K_RAM),a1
	bne.w	.snd					;away team
	addi.w	#$A,(CwdExciteLvl).w
	move.w	#SFXcrowdcheer,(sp)		;home team
.snd
	jsr	(song).l					;play the chosen sound effect
	move.w	$52(a2),d0
	cmp.w	(passplayer).w,d0
	bne.w	.nrec
	addq.w	#1,tmpasscomp(a1)		;pass reached its receiver: tmpasscomp + 1
.nrec
	st	(passplayer).w				;no pass pending any more
	bclr	#sfspdir,(sflags).w
	bclr	#sfssdir,(sflags).w
	tst.w	$34(a2)
	bne.w	setd0player
	bsr.w	ChkShotStat
	move.w	#$8C,$48(a2)			;temp5 = 140, count down for faceoff (92 120)
	cmpi.w	#SPAgdive,SPA(a2)
	bne.w	setd0player
	move.w	#5,$48(a2)				;temp5 = 5 for SPAgdive

setd0player							;Player d0 becomes the player of a pad of his team (setc1player ...
									;setc4player), unless a pad has him already
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

puckbody							;Puck hits player a2. a3 = puck. The puck bounces off; a high fast puck
									;makes a2 fall.
	btst	#pf3onetimer,pflags3(a2)
	bne.w	rtss2
	cmpi.w	#8,Zpos(a3)
	bgt.w	.1
	move.w	d0,d1
	andi.w	#$F,d1
	bne.w	rtss2
.1
	bsr.w	a2touchpuck
	move.w	#SFXpuckbody,-(sp)		;SFXpuckbody
	jsr	(sfx).l
	clr.w	Zvel(a3)
	move.b	#8,nopuck(a2)
	move.w	(a3),d0
	sub.w	(a2),d0
	move.w	Ypos(a3),d1
	sub.w	Ypos(a2),d1
	bne.w	.2
	move.l	a2,-(sp)
	bsr.w	GetHot
.2
	move.w	Xvel(a3),d2
	move.w	Yvel(a3),d3
	move.b	d0,Xvel(a3)
	move.b	d1,Yvel(a3)
	bsr.w	puckflip
	cmpi.w	#8,Zpos(a3)
	ble.w	rtss2
	muls.w	d2,d2
	muls.w	d3,d3
	add.l	d3,d2
	cmp.l	#$9000000,d2			;fast puck
	bls.w	.3
	cmpi.w	#$C,Zpos(a3)
	bgt.w	FallDown
	rts
.3
	bset	#pfalock,pflags(a2)
	bne.w	rtss2
	move.w	#SPAcatch,d1
	exg	a2,a3
	bsr.w	SetSPA
	exg	a2,a3

rtss2								;The shared rts many routines branch to
	rts

puckgoalie							;Puck hits goalie a2 (a3 = puck, d0 / d1 = goalie - puck x / y): a save
									;bounces it, a slow puck is held
	btst	#gmhl,(gmode).w			;check if highlight
	bne.s	rtss2					;exit if highlight
	clr.w	d2						;puck region
	cmpi.w	#8,Zpos(a3)				;compare to Zpos
	bgt.w	.1
	addq.w	#2,d2					;add 2 to d2
.1
	neg.w	d0						;negate d0
	neg.w	d1						;negate d1
	bsr.w	vtoa					;convert directions
	sub.w	facedir(a2),d0			;sub facedir into d0
	andi.w	#7,d0					;pass first 3 bits to d0
	;0 = puck straight in front of G
	;1-3 = puck to G right
	;4 = puck straight behind G
	;5-7 = puck to G left
	move.w	d0,d1					;move d0 into d1
	andi.w	#3,d1					;pass first 2 bits of d1
	bne.w	.2						;will branch if puck is to the left or right of G
	move.w	(HVcount).l,d0			;just for random bit
.2
	andi.w	#4,d0					;pass 3rd bit of d0. d0 will be either 4 (left) or 0 (right)
	lsr.w	#2,d0					;divide by 4. d0 will be either 1 (left) or 0 (right)
	eori.w	#1,d0					;XOR d0 - will make 1 a 0 (left), and 0 a 1 (right)
	add.w	d0,d2					;add to d2. d2 will now be 0 or 1 (Zpos > 8) or 2 or 3 (Zpos <= 8)
	add.w	d2,d2					;add d2 to itself. 0 Glove L, 2 Glove R, 4 Stick L, 6 Stick R
	lea	.table(pc),a0				;contains offsets for save attributes
	move.w	(a0,d2.w),d0			;move from list into d0
	moveq	#$F,d1					;move F into d1
	add.b	(a2,d0.w),d1			;save odds = save attribute + F (15 dec)
	lea	.table2(pc),a0
	btst	#3,attribute(a2)		;attribute a2 - x flip?
	beq.w	.3
	eori.w	#2,d2					;XOR d2 with 2
.3
	move.w	frame(a2),d0			;move frame into d0 (95: not used)
	bclr	#2,(sflags4).w			;clear bit 2 - this is not used anywhere, might have been a debug flag
	bsr.w	ChkShotStat
	bsr.w	a2touchpuck
	cmpi.w	#$3000,(puckvy).w		;compare with puck velocity y
	bgt.w	.4						;branch if greater
	cmpi.w	#$D000,(puckvy).w		;compare -3000 with puckvy
	bgt.w	.6						;branch if greater
.4
	move.w	#$B,-(sp)				;home song
	btst	#pfteam,pflags(a2)		;check home or away
	beq.w	.5						;branch if home
	move.w	#$D,(sp)				;away song
.5
	jsr	(song).l
.6
	move.w	#SFXpuckbody,-(sp)		;#SFXpuckbody
	jsr	(sfx).l
	move.w	(puckc).w,d2			;move puckc into d2
	bmi.w	.8						;branch if no puckc
	st	(puckc).w
	asl.w	#7,d2
	movea.w	#(SortCords-M68K_RAM),a0
	adda.w	d2,a0
	move.b	#$14,nopuck(a0)
	move.w	SCnum(a0),(lastplayer).w
	bclr	#sfspdir,(sflags).w
	bclr	#sfssdir,(sflags).w
.loop
	clr.w	Zvel(a3)				;clear puck Zvel
	move.b	#$A,nopuck(a2)			;move A into nopuck collision
	move.w	#4,temp4(a2)			;move 4 into temp4
	move.w	(a3),d0					;move puck Xpos into d0
	sub.w	(a2),d0					;sub Xpos of goalie from d0
	move.w	Ypos(a3),d1				;move puck Ypos into d1
	sub.w	Ypos(a2),d1				;sub Ypos of goalie from d1
	bne.w	.7						;branch if not equal
	move.l	a2,-(sp)				;pop onto stack
	bsr.w	GetHot
.7
	move.b	d0,Xvel(a3)				;move d0 into puck Xvel
	move.b	d1,Yvel(a3)				;move d1 into puck Yvel
	bra.w	puckflip				;flip puck
	bset	#2,(sflags4).w			;not reached (after jmp puckflip)
	rts
.8
	cmpi.w	#SPAgdive,SPA(a2)		;goalie dive animation
	beq.s	.loop					;branch if equal
	moveq	#2,d0					;move 2 into d0
	add.b	shotacc(a2),d0
	asl.w	#8,d0					;mult by 256
	asl.w	#1,d0					;mult by 2
	bsr.w	randomd0				;random
	addi.w	#$C00,d0
	add.w	d0,d0					;double d0
	bpl.w	.9						;branch if positive
	move.w	#$7FFF,d0				;make max positive
.9
	btst	#pf2aip,pflags2(a2)		;check if in animation
	bne.w	.11						;branch if so
	cmpi.w	#$2C,(a3)				;compare 2C to Xpos of puck
	bgt.w	.11						;branch if greater than
	cmpi.w	#$FFD4,(a3)
	blt.w	.11						;branch if less than -2C
	cmpi.w	#$124,Ypos(a3)
	bgt.w	.11						;branch if greater than
	cmpi.w	#$FEDC,Ypos(a3)
	blt.w	.11						;branch if less than
	cmpi.w	#$E8,Ypos(a3)
	bgt.w	.10						;branch if greater than
	cmpi.w	#$FF18,Ypos(a3)
	bgt.w	.11						;branch if greater than
.10
	asr.w	#2,d0					;divide by 4
.11
	cmp.w	(puckvx).w,d0			;compare puckvx with d0
	blt.w	.loop					;branch if less than
	cmp.w	(puckvy).w,d0			;compare puckvy to d0
	blt.w	.loop					;branch if less than
	neg.w	d0						;negate d0, compare if shot going down
	cmp.w	(puckvx).w,d0
	bgt.w	.loop					;branch if greater than
	cmp.w	(puckvy).w,d0
	bgt.w	.loop					;branch if greater than
	btst	#pf2unav,pflags2(a2)	;check if player unavailable
	bne.w	.loop					;branch if so
	clr.w	Zvel(a3)				;clear puck Zvel
	bra.w	wallcollhit
.table
	dc.w	$0074,$006F,$0071,$0073
.table2
	dc.w	$559D,$6755,$9D67,$559D,$6755,$9D67,$559D,$6755
	dc.w	$9D67,$559D,$6755,$9D67,$5555,$5555,$5555,$5555
	dc.w	$5555,$5555,$5555,$5555,$55F0,$55F0,$55F0,$55F0
	dc.w	$55F0,$55F0,$55F0,$55F0,$55F0,$55F0,$55F0,$55F0
	dc.w	$D575,$D575,$D575,$D575,$D575,$D575,$D575,$D575
	dc.w	$5555,$5555,$5555,$5555,$5555,$5555,$5555,$5555
	dc.w	$5555,$5555,$5555,$5555,$5555,$5555,$5555,$5555
	dc.w	$F0F0,$F0F0,$F0F0,$F0F0,$F0F0,$F0F0,$F0F0,$F0F0
	dc.w	$5757,$5757,$A5A5,$A5A5,$A5A5,$A5A5,$A5A5,$A5A5
	dc.w	$A5A5,$A5A5,$A5A5,$A5A5,$A5A5,$A5A5,$9D67,$9D67
	dc.w	$9D67,$9D67,$9D67,$9D67,$9D67,$9D67,$D5D5,$7575
	dc.w	$D5D5,$7575,$D5D5,$7575,$D5D5,$7575,$D5D5,$7575
	dc.w	$D5D5,$7575,$D5D5,$7575,$D5D5,$7575
puckgoaliescatter	equ	*	;Scatter the puck in random directions after a goalie hit
	dc.w	$50F8,$B7BE,$303C,$1000,$6100,$B5C2,$3740,$002A
	dc.w	$303C,$1000,$6100,$B5B6,$3740,$0028,$303C,$1000
	dc.w	$6100,$B5B6,$3740,$002C,$6000,$A446

makepde								;Pass d0 as value to be scaled by player a0's energy level (full energy
									;while sflags7 bit 4 is set). Return d0
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

getpde								;Get player a3's energy level into d0. Return a2 = his team struct, d1 =
									;pnum*2
	movea.w	#(tmstruct-M68K_RAM),a2
	btst	#6,pflags(a3)
	beq.w	.0
	adda.w	#$39E,a2				;team is away
.0
	move.b	weight(a3),d1
	ext.w	d1
	add.w	d1,d1
	move.w	$34(a2,d1.w),d0
	rts

setpde								;d1 = rostnum of player * 2, a2 = team struct, d0 = new energy level (0 if
									;negative)
	tst.w	d0
	bpl.w	.0
	clr.w	d0
.0
	move.w	d0,$34(a2,d1.w)
	rts

