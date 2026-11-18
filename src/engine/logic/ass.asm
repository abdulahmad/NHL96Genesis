;	Assignment entries. check4bench sends a player to the bench. The other entries
;	cover the bench, the penalty box, a goal celebration and the goalies.

check4bench							;Check if player a3 should go to the bench (called from the assignment
									;code).
	btst	#2,(BA_PS_flags).w
	bne.s	setpadsExit
	btst	#pfjoycon,$62(a3)
	bne.s	setpadsExit
	btst	#pf2pen,$63(a3)
	bne.s	setpadsExit
	tst.b	$60(a3)
	bpl.w	.1
	tst.b	$61(a3)
	bmi.s	setpadsExit
.1
	move.b	$61(a3),d0
	cmp.b	$67(a3),d0
	beq.w	.2
	move.w	$36(a3),d0
	cmpi.b	#$B,$38(a3,d0.w)
	beq.s	setpadsExit
	move.w	$52(a3),d0
	cmp.w	(puckc).w,d0
	beq.s	setpadsExit
	addq.w	#4,sp
	bset	#pf2unav,$63(a3)		;set player unavailable (pf2unav)
	clr.w	$40(a3)
	moveq	#$B,d0
	bra.w	assreplace
.2
	addq.w	#4,sp
	bclr	#pf2unav,$63(a3)
	bclr	#pfnc,$62(a3)
	st	$61(a3)
	st	$60(a3)
	move.w	$34(a3),d0
	tst.b	$60(a3)
	bpl.w	.3
	jmp	(AssignByPosition).l
.3
	move.b	$60(a3),d0
	ext.w	d0
	move.w	d0,$34(a3)
	jmp	(AssignByPosition).l

assbench							;asstab entry: player a3 should go to the bench.
	btst	#pfalock,$62(a3)
	bne.w	setpadsExit
	cmpi.w	#$64,$40(a3)			;temp1 = 100 flag: at the bench door
	beq.w	.done
	;may switch to a position change or reassign to abench
	bsr.w	check4bench
	btst	#pf2pen,$63(a3)			;pf2pen
	bne.w	assexit
	;first time: target = bench spot, x = -(Sideline+8), y = +-80 by team
	bclr	#pfna,$62(a3)
	beq.w	.nna
	move.w	#8,$42(a3)
	moveq	#$50,d0					;80
	btst	#pfteam,$62(a3)
	bne.w	.1
	neg.w	d0
.1
	move.w	d0,$46(a3)				;temp4 = bench y
	move.w	#$96,$44(a3)
	neg.w	$44(a3)
	subq.w	#8,$44(a3)				;temp3 = bench x
	clr.w	$40(a3)
.nna
	move.b	$61(a3),d0				;same player? just change position
	cmp.b	$67(a3),d0
	beq.w	.nobench				;same player, just change position
	;temp1 counts frames; re-check arrival every 8
	sub.w	d7,$40(a3)
	bpl.w	.nodec
	addq.w	#8,$40(a3)
	;within 40 px of bench y and 32 px of bench x?
	move.w	$14(a3),d0
	sub.w	$46(a3),d0
	cmp.w	#$28,d0
	bgt.w	.nodec
	cmp.w	#$FFD8,d0
	blt.w	.nodec
	move.w	(a3),d0
	sub.w	$44(a3),d0
	cmp.w	#$20,d0
	bgt.w	.nodec
	move.w	#SPAglide,d1
	tst.w	$34(a3)
	bne.w	.gli
	move.w	#$640,d1
.gli
	bsr.w	SetSPA					;glide (goalie: ready) animation
	;no collisions; turn step by step toward facedir 4
	bset	#pfnc,$62(a3)
	cmpi.w	#4,$54(a3)
	beq.w	.ok
	addq.w	#1,$54(a3)				;turn toward the bench
	andi.w	#7,$54(a3)
.ok
	clr.w	$2A(a3)					;drift left (Xvel -$800)
	move.w	#$F800,$28(a3)			;-$800
	;within 16 px of the wall: stop and climb over (SPAwallleft)
	cmp.w	#$10,d0
	bgt.w	.loop
	clr.w	$28(a3)
	cmpi.w	#4,$54(a3)
	bne.w	.loop
	move.w	#$F800,$28(a3)
	move.w	#2,$54(a3)
	move.w	#SPAwallleft,d1
	move.w	#$FF62,(a3)
	clr.w	$28(a3)
	tst.w	$34(a3)
	bne.w	.5
	move.w	#$E40,d1
	move.w	#$FF62,(a3)
	clr.w	$28(a3)
.5
	bsr.w	SetSPA
	bset	#pfalock,$62(a3)
	move.w	#$64,$40(a3)			;100
.loop
	rts
.done
	clr.w	6(a3)					;at the bench door: mark this roster slot on the bench (tmpdst -2),
	clr.w	d0
	move.b	$67(a3),d0
	add.w	d0,d0
	movea.l	#tmstruct,a0
	btst	#pfteam,$62(a3)
	beq.w	.t0
	adda.w	#$39E,a0
.t0
	move.w	#$FFFE,$6C(a0,d0.w)		;tmpdst: put used player on bench
	move.b	$61(a3),d3
	bsr.w	assbenchTakeNewPos
	jmp	(setplayer).l
.nodec
	btst	#pfnc,$62(a3)			;skate toward bench spot (temp3,temp4), unless already over the wall
	bne.s	.loop
	move.w	$44(a3),d0
	move.w	$46(a3),d1
	movea.l	#EvadePC,a0
	bra.w	skateto
.nobench
	bclr	#pf2unav,$63(a3)		;pf2unav
assbenchTakeNewPos					;Set position from newpos, assign by position, clear newpos and newpnum
	move.b	$60(a3),d0				;position = newpos; clear newpos and newpnum
	ext.w	d0
	move.w	d0,$34(a3)
	jsr	(AssignByPosition).l
	st	$61(a3)
	st	$60(a3)
assbenchExit	equ	*	;Shared return of assbench
	rts

asseben								;asstab entry: player a3 should exit the bench area.
	btst	#pfalock,$62(a3)
	bne.s	assbenchExit
	bclr	#pfna,$62(a3)
	beq.w	.3
	clr.w	$28(a3)
	clr.w	$2A(a3)
	move.w	$52(a3),d0
	subq.w	#6,d0
	bmi.w	.1
	addq.w	#1,d0
.1
	muls.w	#$E,d0
	move.w	d0,$14(a3)
	move.w	#$96,(a3)
	neg.w	(a3)
	move.w	#2,$54(a3)
	bset	#pfalock,$62(a3)
	move.w	#$D7A,d1
	move.w	#$FF62,(a3)
	clr.w	$28(a3)
	tst.w	$34(a3)
	bne.w	.2
	move.w	#$DFE,d1
	move.w	#$FF62,(a3)
	clr.w	$28(a3)
.2
	bra.w	SetSPA
.3
	move.w	#4,$54(a3)
	bclr	#pfnc,$62(a3)
	bclr	#pf2npc,$63(a3)
	bclr	#pf2unav,$63(a3)
	clr.w	$58(a3)
	move.w	#$1000,$28(a3)
	bra.w	assexit

asspenalty							;asstab entry: player a3 goes to the penalty box.
	btst	#pfalock,$62(a3)
	bne.w	assbenchExit
	bclr	#pfna,$62(a3)
	beq.w	.4
	bset	#pf2unav,$63(a3)		;set player unavailable (pf2unav)
	bsr.w	ReleasePadFromPlayer
	moveq	#-$2,d4					;move -2 into d4
	bsr.w	setpads					;moves player number into a temp value so graphics know who it is
	move.w	#8,$42(a3)				;move 8 into temp2
	moveq	#$B,d0					;move 11 dec into d0
	move.b	(PBnum).w,d1			;gets number of players in PB. 00HV (H=Home, V=Visitors)
	btst	#pfteam,$62(a3)			;checks if player is home or away
	bne.w	.1						;branch if away
	lsr.w	#4,d1					;shift 4 bits to get Home players in PB
	neg.w	d0						;make d0 negative (different box)
.1
	andi.w	#$F,d1					;pass the first 4 bits of d1 (the team's player total in PB)
	cmp.w	#2,d1					;compare to 2
	bls.w	.2						;branch if less than (1 player in box or less)
	moveq	#2,d1					;add 2 if more than 1 player in box
.2
	addq.w	#3,d1					;add 3 to d1
	muls.w	d0,d1					;mult d0 with d1, store result in d1
	move.w	d1,$46(a3)
	move.w	#$26,d1
	btst	#pfteam,pflags(a3)
	bne.w	.3
	move.w	#$FFBE,d1
.3
	move.w	d1,$46(a3)				;move d1 into temp4 (skateto YPos)
	move.w	#$8E,$44(a3)
	clr.w	$40(a3)					;clear temp1
	bset	#pf2npc,$63(a3)			;set bit for no player collision
	clr.w	$4E(a3)					;clear wallCos (angle of last collision)
	clr.w	$50(a3)					;clear wallSin (angle of last collision)
.4
	move.w	$14(a3),d0				;Current Ypos of player
	sub.w	$46(a3),d0				;sub temp4 (Y pos to skate to) from Ypos
	cmp.w	#$C,d0					;compare to 13 decimal
	bgt.w	.8						;branch if greater than (still skateto)
	;If its within 13 decimal, it will start the animation for hopping over the board
	cmp.w	#$FFF4,d0
	blt.w	.8
	move.w	(a3),d0
	sub.w	$44(a3),d0
	cmp.w	#$FFE8,d0
	blt.w	.8
	sub.w	d7,$40(a3)
	bpl.w	assbenchExit
	addq.w	#8,$40(a3)
	bset	#pfnc,$62(a3)
	move.w	#SPAglide,d1			;94 $50C
	bsr.w	SetSPA
	moveq	#6,d2
	btst	#0,$77(a3)
	beq.w	.5
	moveq	#2,d2
.5
	cmp.w	$54(a3),d2
	beq.w	.6
	addq.w	#1,$54(a3)
	andi.w	#7,$54(a3)
.6
	clr.w	$2A(a3)
	move.w	#$1000,$28(a3)
	cmp.w	#$FFF8,d0
	blt.w	assbenchExit
	clr.w	$28(a3)
	cmp.w	$54(a3),d2
	bne.w	assbenchExit
	bset	#pfalock,$62(a3)
	move.w	#2,$54(a3)
	move.w	#$8E,(a3)
	move.w	#$26,$14(a3)
	btst	#pfteam,pflags(a3)
	bne.w	.7
	move.w	#$FFBE,$14(a3)
.7
	bclr	#3,4(a3)
	move.w	#$AA2,d1
	bsr.w	SetSPA
	bclr	#pf2pen,$63(a3)
	moveq	#$D,d0
	bra.w	assreplace
.8
	move.w	$44(a3),d0
	move.w	$46(a3),d1
	movea.l	#rtss2,a0
	bra.w	skateto
ReleasePadFromPlayer				;Take the joystick off player a3 (chgplayer for the pad that controls it)
	;Take the joystick off player a3
	btst	#pfjoycon,$62(a3)
	beq.w	assbenchExit
	clr.w	d4
	move.w	$52(a3),d0
	cmp.w	(c1playernum).w,d0
	beq.w	chgplayer
	moveq	#2,d4
	cmp.w	(c2playernum).w,d0		;pads 3 and 4 too
	beq.w	chgplayer
	move.w	#4,d4
	cmp.w	(c3playernum).w,d0
	beq.w	chgplayer
	move.w	#6,d4
	bra.w	chgplayer

assdopen							;asstab entry: player a3 serves his penalty.
	btst	#pfalock,pflags(a3)
	bne.w	.2
	bclr	#pfna,pflags(a3)
	beq.w	.2
	moveq	#$10,d0
	btst	#pfteam,pflags(a3)
	beq.w	.1
	moveq	#1,d0
.1
	add.b	d0,(PBnum).w
	st	position(a3)
	clr.w	frame(a3)
.2
	rts

assepen								;asstab entry: player a3 leaves the penalty box.
	btst	#pfalock,$62(a3)
	bne.w	assbenchExit
	bclr	#pfna,$62(a3)
	beq.w	.3
	bset	#pfnc,$62(a3)			;set player in no collision mode
	bset	#pf2unav,$63(a3)		;set player unavailable
	moveq	#$10,d0
	moveq	#-$3C,d1
	btst	#pfteam,$62(a3)
	beq.w	.1
	moveq	#1,d0
	neg.w	d1
.1
	sub.b	d0,(PBnum).w
	move.w	d1,$14(a3)
	clr.w	$28(a3)
	clr.w	$2A(a3)
	move.w	#$94,(a3)
	move.w	#$8E,(a3)
	move.w	#$26,$14(a3)
	btst	#pfteam,pflags(a3)
	bne.w	.2
	move.w	#$FFBE,$14(a3)
.2
	move.w	#4,$54(a3)
	bset	#pfalock,$62(a3)
	move.w	#$AF4,d1
	bsr.w	SetSPA
	jmp	(SprSort).l
.3
	move.w	#$856,d1
	bsr.w	SetSPA
	move.w	#4,$54(a3)
	st	$61(a3)
	st	$60(a3)
	bclr	#pfjoycon,$62(a3)
	bclr	#pfnc,$62(a3)
	bclr	#pf2npc,$63(a3)
	bclr	#pf2unav,$63(a3)
	move.w	#$F000,$28(a3)
	bra.w	assexit

assgoaliebreakwait					;asstab entry: in a shootout or penalty shot park the idle goalie off the
									;ice.
	btst	#pfalock,pflags(a3)		;check if animation locked
	bne.w	.3						;exit if so
	btst	#2,(BA_PS_flags).w		;check if pen shot
	bne.w	.1						;branch if so
	btst	#0,(gmode2).w			;check for shootout
	bne.w	.1						;branch if so
	nop
	bra.w	assexit
.1
	clr.w	Xvel(a3)				;clear Xvel
	clr.w	Yvel(a3)				;clear Yvel
	movem.l	d0/a0,-(sp)				;push d0 and a0 on stack
	movea.l	#SortCords,a0			;Home SC Sctruct start
	move.w	(BA_Goalie_SCnum).w,d0	;move Goalie SCNum into d0
	asl.w	#7,d0					;shift d0 7 bits left
	adda.w	d0,a0					;add d0 to address a0
	move.w	#$191,Ypos(a3)			;move 401 decimal into Ypos
	btst	#pfgoal,$62(a0)			;check if shooting up or down (a0 is goalie being shot on)
	bne.w	.2						;branch if shooting up
	move.w	#$FE6F,Ypos(a3)			;move -191 decimal into Ypos (goalie not being shot on)
.2
	movem.l	(sp)+,d0/a0
.3
	rts
assgoaliebreakwaitEnd	equ	*
	rts

donothing							;Unless locked or pad controlled, player a3 just skates (jumped to from
									;the fight and assignment code).
	btst	#pfalock,$62(a3)		;#pfalock
	bne.s	assgoaliebreakwaitEnd
	btst	#pfjoycon,$62(a3)		;#pfjoycon
	bne.s	assgoaliebreakwaitEnd
	moveq	#8,d0
	bra.w	doplayeracc

assstanley							;asstab entry: player a3 skates with the Stanley Cup overhead.
	btst	#pfalock,$62(a3)
	bne.s	assgoaliebreakwaitEnd
	bclr	#pfna,$62(a3)
	beq.w	.2
	move.w	#$5A,$44(a3)			;90
	tst.w	(Hpos).w
	bpl.w	.1
	neg.w	$44(a3)
	;target Y from Vpos
.1
	move.w	(Vpos).w,$46(a3)		;temp4 = y from Vpos
	move.w	#SPAstanley,d1
	bsr.w	SetSPA
	;skate toward the target
.2
	move.w	$44(a3),d0				;face and accelerate toward the target
	sub.w	(a3),d0
	move.w	$46(a3),d1
	sub.w	$14(a3),d1
	bsr.w	vtoa
	cmp.w	#7,d0
	bgt.s	assgoaliebreakwaitEnd
	move.w	d0,d2
	move.w	d2,$54(a3)
	bra.w	playeracc

assscore							;asstab entry: player a3 celebrates a goal.
	btst	#pfalock,$62(a3)
	bne.s	assgoaliebreakwaitEnd
	bclr	#pfna,$62(a3)
	beq.w	.2
	bsr.w	assscoreRandomTemp1
	move.w	#8,$42(a3)
	move.w	#$5A,$44(a3)
	tst.w	(Hpos).w
	bpl.w	.1
	neg.w	$44(a3)
.1
	move.w	(Vpos).w,$46(a3)
.2
	movea.l	#rtss2,a0
	move.w	$44(a3),d0
	move.w	$46(a3),d1
	btst	#0,(gmode2).w			;shootout? count down the shootout delay and keep the players near center
	beq.w	.5
	tst.w	(shootoutdelay).w
	beq.w	.3
	subq.w	#1,(shootoutdelay).w
	bne.w	.3
	bset	#sf2drec,(sflags2).w
.3
	cmpi.w	#$96,(a3)
	bgt.w	.4
	cmpi.w	#$FF6A,(a3)
	bgt.w	.5
.4
	clr.w	d1
.5
	sub.w	d7,$40(a3)
	bpl.w	assscoreSkateOrReturn
	bset	#pfalock,$62(a3)
	move.w	#SPAcelebrate,d1		;94 $E8A
	btst	#0,(seed+1).w
	beq.w	.6
	move.w	#$D0E,d1
.6
	move.w	(shotplayer).w,d0
	cmp.w	$52(a3),d0
	bne.w	.7
	move.w	#$C30,d1
	btst	#3,(seed+1).w
	bne.w	.7
	move.w	#$D28,d1
.7
	bsr.w	SetSPA
assscoreRandomTemp1					;temp1 = random 0..$77 (wait time before the player moves)
	moveq	#$78,d0
	bsr.w	randomd0
	move.w	d0,$40(a3)
	rts
assscoreSkateOrReturn	equ	*	;Part of assscore: when pflags bit 3 is clear go to skateto, else return
	btst	#pfjoycon,$62(a3)
	beq.w	skateto
	rts
	rts
	rts

assgoaliectrl						;asstab entry: the goalie of a pad.
	btst	#pfjoycon,$62(a3)		;is player joystick controlled?
	bne.w	.1						;branch is so
	bra.w	assexit
.1
	btst	#pfna,$62(a3)			;check if new assignment
	bne.w	.7						;branch if new assignment
	movem.w	d0-d1,-(sp)				;push to stack
	move.w	(a3),d0					;Xpos
	move.w	$14(a3),d1				;Ypos
	cmp.w	#$AA,d1					;compare $AA to Ypos
	bgt.w	.2
	cmp.w	#$FF56,d1				;check -$AA to Ypos
	blt.w	.2						;branch if less than
	btst	#gmclock,(gmode).w		;check if clock stopped
	bne.w	.2						;branch if so
	move.w	d0,-(sp)				;push to stack
	move.w	#8,d0					;clock stoppage due to goalie out of range
	jsr	(AddPenalty2).l
	move.w	(sp)+,d0				;pop from stack
.2
	sub.w	(Hpos).w,d0				;sub ice rink horiz position from Xpos
	sub.w	(Vpos).w,d1				;sub ice rink vert position from Ypos
	bclr	#pf3gctrl,$64(a3)		;clear goalie control bit?
	cmp.w	#$74,d0					;'t'   ; compare $74 to Xpos diff
	blt.w	.3						;branch if less than
	bset	#pf3gctrl,$64(a3)		;set goalie control bit?
	bra.w	.6
.3
	cmp.w	#$FF8C,d0				;compare -$74 to Xpos diff
	bgt.w	.4						;branch if greater than
	bset	#pf3gctrl,$64(a3)		;set goalie control bit?
	bra.w	.6
.4
	cmp.w	#$64,d1					;'d'   ; compare $64 to Ypos diff
	blt.w	.5						;branch if less than
	bset	#pf3gctrl,$64(a3)		;set goalie control bit?
	bra.w	.6
.5
	cmp.w	#$FF9C,d1				;compare -$64 to Ypos diff
	bgt.w	.6						;branch if greater than
	bset	#pf3gctrl,$64(a3)		;set goalie control bit?
.6
	movem.w	(sp)+,d0-d1				;pop from stack
	btst	#pf3gctrl,$64(a3)		;check goalie ctrl bit
	bne.w	assgoaliepuckx			;branch if set
.7
	btst	#pfalock,$62(a3)		;check if anim lock
	bne.w	.14						;exit if so
	bsr.w	check4bench
	bclr	#pfna,$62(a3)			;clear new assignment bit
	beq.w	.8						;branch if already cleared
	clr.w	$40(a3)					;clear temp1
	move.w	#8,$42(a3)				;move 8 into temp2
	st	$46(a3)						;FFFF to temp4
.8
	jsr	(GoalieInCrease).l
	bne.w	.9
	jsr	(TurnGoalieFromNet).l
.9
	btst	#pf2aip,$63(a3)			;check if anim in progress
	bne.w	.14						;exit if so
	btst	#gmclock,(gmode).w		;check if clock stopped
	bne.w	.14						;exit if so
	tst.w	$48(a3)					;test temp5
	bmi.w	.12						;branch if less than 0
	move.w	$52(a3),d0				;move SCnum into d0
	cmp.w	(puckc).w,d0			;check if puckc is goalie
	beq.w	.10						;branch if equal
	st	$48(a3)						;set temp5 to -1
	bra.w	.12
.10
	sub.w	d7,$48(a3)				;subtract d7(frames elapsed) from temp5
	bpl.w	.12						;branch if more than 0
	btst	#2,(BA_PS_flags).w		;check bit 2
	beq.w	.11						;branch if not set
	bset	#4,(BA_PS_flags).w
	bra.w	.12
.11
	moveq	#8,d0
	jsr	(AddPenalty2).l
.12
	sub.b	d7,$40(a3)				;sub d7(frames elapsed) from temp1
	bpl.w	.14						;branch if positive
	move.b	$6C(a3),d0
	beq.w	.13						;branch if value was 0
	btst	#6,(sflags7).w			;check if crowd meter broken
	beq.w	.13						;jump if not
	subq.b	#1,d0					;sub 1 from d0
.13
	lsr.b	#2,d0					;divide by 4
	move.b	d0,$40(a3)				;move d0 into temp1
	move.w	$52(a3),d0				;move SCnum into d0
	cmp.w	(puckc).w,d0			;compare puckc to d0
	beq.w	.14						;jump to assgoaliecpu if the same
.14
	rts

assgoaliecpu						;asstab entry: the computer goalie.
	btst	#pfjoycon,pflags(a3)
	bne.w	assgoaliectrl
assgoaliepuckx	equ	*	;Goalie AI: use the puck x position (low confidence)
	move.w	(puckx).w,(OptPad+4).w
	btst	#0,(sflags4).w			;test bit 0
	beq.w	.2
	btst	#pf2aip,$63(a3)			;check if animation in progress
	bne.w	.2						;branch if so
	btst	#1,(sflags4).w			;test bit 1
	beq.w	.1						;branch if 0
	btst	#3,(sflags4).w			;test bit 3
	bne.w	.2						;branch if set
	cmpi.w	#$89,6(a3)				;compare to alice frame number
	bne.w	.2						;branch if not equal
	cmpi.w	#$8D,6(a3)				;compare to alice frame number
	bne.w	.2						;branch if not equal
	bset	#3,(sflags4).w			;set bit 3
	move.w	#SFXcheck,-(sp)			;SFX
	jsr	(sfx).l
	bra.w	.2						;set bit 3
.1
	move.w	#$37A,d1
	btst	#1,(sflags12).w
	bne.w	.2
	;slam animation set
	bsr.w	SetSPA					;set animation of d1
	bset	#pf2aip,$63(a3)			;set anim in progress
	;goalie assignment proper: bench check and new assignment setup
.2
	btst	#pfalock,$62(a3)		;check if locked in animation
	bne.w	.loop					;exit if so
	bsr.w	check4bench
	bclr	#pfna,$62(a3)			;clear new assignment
	beq.w	.3						;jump if it was cleared already
	clr.w	$40(a3)					;clear temp1
	move.w	#8,$42(a3)				;move 8 into temp2
	st	$46(a3)						;set temp5 (FFFF)
	;count down the timer
.3
	cmpi.w	#$34,(a3)				;compare 34 hex with Xpos
	bgt.w	.4						;branch if greater
	cmpi.w	#$FFCC,(a3)				;compare -34 hex with Xpos
	blt.w	.4						;branch if less than
	cmpi.w	#$124,$14(a3)
	bgt.w	.4
	cmpi.w	#$FEDC,$14(a3)
	blt.w	.4
	cmpi.w	#$E8,$14(a3)
	bgt.w	.6
	cmpi.w	#$FF18,$14(a3)
	blt.w	.6
	;near the net: skate back to the middle of the crease
.4
	lea	.loop(pc),a0				;goalie will skate back to middle position
	moveq	#4,d0
	tst.w	(a3)					;test Xpos
	bpl.w	.5						;branch if positive
	neg.w	d0
.5
	move.w	#$FA,d1
	btst	#pfgoal,$62(a3)			;check what goal shooting at
	beq.w	skateto					;branch if bottom
	neg.w	d1
	bra.w	skateto
.loop
	rts
	;in position: ready stance, facing up or down the ice
.6
	btst	#pf2aip,$63(a3)			;check if anim in progress
	bne.s	.loop					;exit if so
	btst	#0,(sflags4).w			;check bit 0
	beq.w	.8						;branch if not set
	cmpi.w	#$8A,6(a3)				;check alice frame
	beq.w	.7						;branch if equal
	cmpi.w	#$8E,6(a3)				;check alice frame
	bne.w	.8						;branch if not equal
	move.w	#4,$54(a3)				;set 4 to facedir - face down
	bra.w	.8
	;facing the top net
.7
	move.w	#0,$54(a3)				;set 0 to facedir - face up
	;ready stance; a penalty shot keeps the goalie set
.8
	move.w	#SPAgready,d1
	movem.w	d0,-(sp)
	move.w	(pucky).w,d0
	sub.w	$14(a3),d0
	bpl.w	.9
	neg.w	d0
.9
	cmp.w	#$194,d0
	bgt.w	.11
	cmp.w	#$A8,d0
	bgt.w	.10
	bra.w	.12
.10
	move.w	#$57E,d1
	bra.w	.12
.11
	move.w	#$CE,d1
.12
	movem.w	(sp)+,d0
	bsr.w	SetSPA
	btst	#2,(BA_PS_flags).w		;check bit 2
	bne.w	.13						;branch if set
	btst	#gmclock,(gmode).w		;check if clock
	bne.w	.loop					;exit if clock stopped
	;skate to the spot
.13
	tst.w	$48(a3)					;temp5
	bmi.w	.16						;branch if minus
	move.w	$52(a3),d0				;move SCnum to d0
	cmp.w	(puckc).w,d0			;check if puckc
	beq.w	.14						;branch if so
	st	$48(a3)						;set temp5 to FFFF
	bra.w	.16
	;d0 = puckc
.14
	sub.w	d7,$48(a3)				;subtract frames from temp5
	bpl.w	.16						;branch if positive
	btst	#2,(BA_PS_flags).w		;check if bit 2 set
	beq.w	.15						;branch if not
	bset	#4,(BA_PS_flags).w		;set bit 4
	bra.w	.16
	;bit 2 of BA_PS_flags clear
.15
	moveq	#PenGhold,d0
	jsr	(AddPenalty2).l				;blow whistle for FO
	;no faceoff: count down the reaction timer
.16
	sub.b	d7,$40(a3)				;sub d7 from temp1
	bpl.w	.42						;branch if still positive
	move.b	$6C(a3),d0
	beq.w	.17						;branch if 0
	btst	#6,(sflags7).w			;check if crowd meter broken
	beq.w	.17						;branch if not
	subq.b	#1,d0					;sub from d0
	;faceoff odds
.17
	lsr.b	#2,d0					;divide by 4
	move.b	d0,$40(a3)				;move d0 into temp1
	btst	#pfjoycon,$62(a3)		;check if joy controlled
	beq.w	.18						;branch if not
	btst	#pf3gctrl,$64(a3)		;check bit 2
	bne.w	.18						;branch if set
	moveq	#$1D,d0					;assignment assgoaliectrl
	bra.w	assinsert
	;pfjoycon clear or pf3gctrl set
.18
	move.w	(pucky).w,d0			;move pucky into d0
	move.w	$14(a3),d1				;move Ypos into d1
	eor.w	d0,d1					;XOR
	bpl.w	.19						;branch if positive
	clr.w	d0
	move.w	#$10A,d2
	btst	#pfgoal,$62(a3)			;check which net shooting at
	beq.w	.loop3					;branch if bottom
	neg.w	d2
	bra.w	.loop3
	;timer out: count temp4 down to -1
.19
	subq.w	#1,$46(a3)				;sub 1 from temp4
	bpl.w	.20						;branch if positive
	move.w	#$FFFF,$46(a3)			;move -1 into temp4
	;is the goalie the puck carrier?
.20
	move.w	$52(a3),d0				;SCnum into d0
	cmp.w	(puckc).w,d0			;check if puckc
	bne.w	.23						;branch if not
	tst.w	$48(a3)					;check temp5
	bpl.w	.21						;branch if positive
	move.w	#$5A,$48(a3)			;move 5A into temp5
	;goalie holding the puck: freeze timer at 90, then pass or whistle
.21
	st	$46(a3)						;FFFF into temp4
	cmpi.w	#$5A,$48(a3)			;compare to temp5
	bgt.w	.26						;branch if greater
	move.w	(HVcount).l,d0
	andi.w	#3,d0					;pass first 2 bits
	bne.w	.26						;branch if not 0
	moveq	#5,d0
	movea.w	#(SortCords-M68K_RAM),a0
	btst	#pfteam,$62(a3)			;check home or away
	bne.w	.loop2					;branch if away
	adda.w	#$300,a0
	;each player of the other team
.loop2
	btst	#pf2unav,$63(a0)		;check if player unavailable
	bne.w	.22						;branch if so
	move.w	(pucky).w,d1			;pucky into d1
	sub.w	$14(a0),d1				;sub Ypos a0 from d1
	cmp.w	#$1C,d1					;compare 1C to difference
	bgt.w	.22						;branch if greater
	cmp.w	#$FFE4,d1				;compare -1C
	blt.w	.22						;branch if less than
	move.w	(puckx).w,d1			;puckx into d1
	sub.w	(a0),d1					;sub Xpos a0 from d1
	cmp.w	#$19,d1					;compare 19 to difference
	bgt.w	.22						;branch if greater
	cmp.w	#$FFE7,d1				;compare -19 to diff
	bgt.w	.26						;branch if greater
	;next opponent; none close: look for a pass
.22
	adda.w	#$80,a0					;move to next struct
	dbf	d0,.loop2
	move.w	#1,(glovecords+4).w		;dir of threat on puck handler
	bsr.w	chk4pass
	bra.w	.26
	;d0 <> puckc
.23
	tst.w	$46(a3)					;check temp4
	bne.w	.26						;branch if not 0
	tst.w	(puckc).w				;check puckc
	bpl.w	.26						;branch if there is a puckc
	move.w	(puckx).w,d0
	sub.w	(a3),d0					;sub Xpos
	cmp.w	#$14,d0					;compare 14 to diff
	bgt.w	.26						;branch if greater
	cmp.w	#$FFEC,d0				;-14
	blt.w	.26						;branch if less
	move.w	(pucky).w,d1
	cmp.w	#$11E,d1
	bgt.w	.26						;branch if past goalline
	cmp.w	#$FEE2,d1
	blt.w	.26						;branch if past
	sub.w	$14(a3),d1				;sub Ypos from d1
	cmp.w	#$1E,d1					;compare to 1E
	bgt.w	.26						;branch if greater
	cmp.w	#$FFE2,d1				;compare to -1E
	blt.w	.26						;branch if less
	movem.w	d0-d1,-(sp)
	move.w	(puckvx).w,d0
	bpl.w	.24
	neg.w	d0
	;|puckvx|
.24
	move.w	(puckvy).w,d1
	bpl.w	.25
	neg.w	d1
	;|puckvy|
.25
	add.w	d1,d0					;add puckvx and vy
	cmp.w	#$1000,d0				;compare to 1000
	movem.w	(sp)+,d0-d1
	bgt.w	.26						;branch if greater
	bsr.w	vtoa
	move.w	d0,$54(a3)				;d0 into facedir. Goalie will face puck
	move.b	#8,$5E(a3)				;move 8 to nopuck collision
	move.w	#SPAgdive,d1			;goalie dive anim.
	bsr.w	SetSPA					;set animation
	bset	#pf2aip,$63(a3)			;set anim in progress
	addi.w	#$96,(Crowdlevel).w
	rts
	;not holding the puck: play the shot (puckcross at the goal line)
.26
	movea.w	#(puckcross-M68K_RAM),a0	;puckcross = xcord/frames top to bottom for goalies to react to
	move.w	#$11A,d3
	btst	#pfgoal,$62(a3)			;check what net shooting at
	beq.w	.27						;branch if bottom
	addq.w	#4,a0
	neg.w	d3
.27
	cmpi.w	#$11A,$14(a3)
	bgt.w	.28
	cmpi.w	#$FEE6,$14(a3)
	bgt.w	.29
	;far from the goal line: stand in the crease middle
.28
	clr.w	d2
	clr.w	d0
	cmpi.w	#$2C,(a3)
	bgt.w	.loop3
	cmpi.w	#$FFD4,(a3)
	blt.w	.loop3
	move.w	#$96,d0
	tst.w	(a3)
	bpl.w	.loop3
	neg.w	d0
	bra.w	.loop3
	;near the goal line: follow the puck
.29
	tst.w	(puckc).w
	bmi.w	.30
	move.w	$52(a3),d0
	cmp.w	(puckc).w,d0
	beq.w	.30
	move.l	a0,-(sp)
	movea.l	#SortCords,a0
	move.w	(puckc).w,d0
	asl.w	#7,d0
	adda.w	d0,a0
	move.w	(puckx).w,d0
	sub.w	(a0),d0
	asr.w	#1,d0
	add.w	(a0),d0
	move.w	d0,(OptPad+4).w
	movea.l	(sp)+,a0
	;target X set
.30
	move.w	(OptPad+4).w,d0
	move.w	(pucky).w,d1
	bsr.w	ClampYPosition
	bsr.w	vtoa
	bsr.w	AdjustFacingDirection
	move.w	(gameclock).w,d0
	andi.w	#7,d0
	asl.w	#4,d0
	addi.w	#$A0,d0
	cmpi.w	#$F1,(pucky).w
	bgt.w	.31
	cmpi.w	#$FF0F,(pucky).w
	bgt.w	.32
	;puck outside the zone
.31
	subi.w	#$40,d0
	;d0 = lead time (shorter near the ends): where the puck will be
.32
	move.w	d0,d1
	muls.w	(puckvx).w,d0
	swap	d0
	add.w	(OptPad+4).w,d0
	muls.w	(puckvy).w,d1
	swap	d1
	add.w	(pucky).w,d1
	bsr.w	ClampYPosition
	movem.w	d0-d1,-(sp)
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	cmp.l	#$384,d0
	bhi.w	.33
	movem.w	(sp)+,d0-d1
	bra.w	.35
	;d0 > $384
.33
	bsr.w	Sroot
	moveq	#1,d2
	add.w	d0,d2
	moveq	#$12,d4
	btst	#sfssdir,(sflags).w
	beq.w	.34
	addq.w	#8,d4
	;pop the d0-d1 saved above
.34
	movem.w	(sp)+,d0-d1
	muls.w	d4,d1
	addq.w	#8,d4
	muls.w	d4,d0
	divs.w	d2,d0
	divs.w	d2,d1
	;target set: d2 = goal line; shootouts skip the next test
.35
	add.w	d3,d1
	move.w	d1,d2
	btst	#0,(gmode2).w
	bne.w	.37
	btst	#2,(BA_PS_flags).w
	bne.w	.37
	bra.w	.37
	btst	#sfssdir,(sflags).w
	beq.w	.37
	cmpi.w	#$D0,(pucky).w
	bgt.w	.36
	cmpi.w	#$FF30,(pucky).w
	blt.w	.36
	bra.w	.37
	;puck in front of the net: stay in the crease width
.36
	cmpi.w	#$14,(a3)
	bgt.w	.37
	cmpi.w	#$FFEC,(a3)
	blt.w	.37
	btst	#1,(gameclock+1).w
	bne.w	.37
	bra.w	.38
	;crossing point near enough: try a save
.37
	cmpi.w	#$22,2(a0)
	bhi.w	.loop3
	cmpi.w	#$18,(a0)
	bgt.w	.43
	cmpi.w	#$FFE8,(a0)
	blt.w	.43
	cmpi.w	#$C,2(a0)
	bhi.w	.39
.38
	cmpi.w	#$11E,(pucky).w
	bgt.w	.39
	cmpi.w	#$FEE2,(pucky).w
	blt.w	.39
	bset	#pf2aip,$63(a3)
	bne.w	.39
	jsr	(goaliesave).l
	;follow the crossing x along the goal line
.39
	move.w	(a0),d0
	cmpi.w	#$112,(pucky).w
	bgt.w	.40
	cmpi.w	#$FEEE,(pucky).w
	bgt.w	.loop3
	;puck in the zone
.40
	moveq	#$18,d0
	tst.w	(OptPad+4).w
	bpl.w	.loop3
	neg.w	d0
	;d0/d1 = the spot; turn the goalie toward it
.loop3
	move.w	d2,d1
	movem.w	d0-d1,-(sp)
	move.b	$28(a3),d0
	ext.w	d0
	neg.w	d0
	add.w	(sp)+,d0
	sub.w	(a3),d0
	move.b	$2A(a3),d1
	ext.w	d1
	neg.w	d1
	add.w	(sp)+,d1
	sub.w	$14(a3),d1
	cmp.w	#4,d0
	bgt.w	.41
	cmp.w	#$FFFC,d0
	blt.w	.41
	cmp.w	#4,d1
	bgt.w	.41
	cmp.w	#$FFFC,d1
	blt.w	.41
	clr.w	d0
	clr.w	d1
	;direction to the spot (zero when close)
.41
	bsr.w	vtoa
	move.b	d0,$43(a3)				;move d0 into temp2+1
	;d2 = wanted direction: accelerate (or stop for 8)
.42
	move.b	$43(a3),d2				;temp2+1
	ext.w	d2
	cmp.w	#7,d2
	ble.w	playeracc
	bra.w	stopna2
	;nobody has the puck and no icing: follow it
.43
	tst.w	(puckc).w
	bpl.s	.loop3
	btst	#ifok,(lty+2).w
	bne.s	.loop3
	movea.w	#(tmstruct-M68K_RAM),a1
	lea	$39E(a1),a2
	btst	#pfteam,$62(a3)
	beq.w	.44
	exg	a1,a2
	;team structs chosen
.44
	cmpi.l	#$1324,$2A(a1)
	blt.w	.loop3
	cmpi.l	#$9C4,$2A(a2)
	blt.w	.loop3
	cmpi.w	#$F6,(pucky).w
	bgt.w	.45
	cmpi.w	#$FF0A,(pucky).w
	bgt.w	.loop3
	;puck past the circles
.45
	tst.w	(puckvy).w
	btst	#pfgoal,$62(a3)
	beq.w	.46
	eori.b	#8,ccr
	;puck direction check
.46
	bmi.w	.loop3
	move.w	(puckvx).w,d0
	bpl.w	.47
	neg.w	d0
	;|puckvx|
.47
	move.w	(puckvy).w,d1
	bpl.w	.48
	neg.w	d1
	;|puckvy|
.48
	cmp.w	d0,d1
	blt.w	.loop3
	moveq	#$F,d0					;assignment DD2E?
	bra.w	assinsert
ClampYPosition						;Clamp d1 to the goal line range ($FEE7..$119) and subtract d3
	move.w	(puckc).w,d2
	cmp.w	$52(a3),d2
	bne.w	.1
	clr.w	d0
.1
	cmp.w	#$119,d1
	blt.w	.2
	move.w	#$119,d1
.2
	cmp.w	#$FEE7,d1
	bgt.w	.3
	move.w	#$FEE7,d1
.3
	sub.w	d3,d1
	rts
