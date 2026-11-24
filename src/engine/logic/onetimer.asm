;	The one-timer shot: which half the puck is on, the shot and its facing check.

PuckOnAttackHalf					;d0 = 1 when the puck is on the half of the goal player a3 shoots at, else
									;0 (the code after the bra is never
									;used). Called from doinput and asspassrec
	movem.w	d0-d1,-(sp)
	btst	#3,(GameFlags).w
	bne.w	.0
	move.w	(pucky).w,d0
	btst	#pfgoal,pflags(a3)		;pfgoal - check which goal shooting at
	bne.w	.cont					;branch if top goal
	neg.w	d0
.cont
	tst.w	d0						;check if d0 is 0
	bpl.w	.0						;branch if higher
	bra.w	.playerabovetopgoalline
	;In PuckOnAttackHalf after its bra: code nothing reaches.
	move.w	(passdir).w,d0
	addq.w	#4,d0
	andi.w	#7,d0
	move.w	facedir(a3),d1
	cmp.w	d0,d1
	bra.w	PuckOnAttackHalfYes
	dc.w	$6700,$0038,$5241,$0241,$0007,$B240,$6700,$002C
	dc.w	$5241,$0241,$0007,$B240,$6700,$0020,$5741,$0241
	dc.w	$0007,$B240,$6700,$0014,$5341,$0241,$0007,$6700
	dc.w	$000A
.playerabovetopgoalline
	move.w	#0,d0
	bra.w	.1
PuckOnAttackHalfYes	equ	*			;Result 1: the puck is on the attack half
.0
	move.w	#1,d0
.1
	movem.w	(sp)+,d0-d1
	rts

onetimershot						;Do the one-timer: a pass with GameFlags bit 3, else a shot; offsides,
									;icing, assists and the crowd
	btst	#3,(GameFlags).w
	beq.w	.6
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(onetimerplayer).w,d0
	cmp.w	(c1playernum).w,d0
	beq.w	.1
	cmp.w	(c2playernum).w,d0
	beq.w	.2
	cmp.w	(c3playernum).w,d0
	beq.w	.3
	cmp.w	(c4playernum).w,d0
	beq.w	.4
.loop
	move.w	facedir(a3),(passdir).w
	andi.w	#7,(passdir).w
	bset	#4,(GameFlags).w
	bra.w	.5
.1
	jsr	(ReadJoy1).l
.loop2
	btst	#3,d0
	bne.s	.loop
	move.w	d0,(passdir).w
	bra.w	.5
.2
	jsr	(ReadJoy2).l
	bra.s	.loop2
.3
	jsr	(ReadJoy3).l
	bra.s	.loop2
.4
	jsr	(ReadJoy4).l
	bra.s	.loop2
.5
	jsr	(dopass).l
	bclr	#4,(GameFlags).w
	movem.l	(sp)+,d0-d7/a0-a6
	bra.w	.7
.6
	move.w	#4,(passdir).w
	jsr	(doshot).l
.7
	movem.l	d0/a0,-(sp)
	movea.l	#tmstruct,a0			;Home Stats
	btst	#pfteam,pflags(a3)		;check if home or away
	beq.w	.8						;branch if home
	lea	$39E(a0),a0
.8
	move.w	SCnum(a3),d0
	addq.w	#1,$14(a0)
	movem.l	d0/a0-a3,-(sp)
	exg	a2,a3
	jsr	(a2offsides).l
	movem.l	(sp)+,d0/a0-a3
	exg	a2,a3
	jsr	(ArmIcing).l
	exg	a2,a3
	;team struct chosen
	clr.w	d0
	move.b	pnum(a3),d0
	move.w	$1A(a0),$1C(a0)			;move assist 1 player to assist 2
	move.w	$18(a0),$1A(a0)			;move last player to touch puck to assist 1
	move.w	d0,$18(a0)				;move d0 into player touching puck
	bset	#7,(sflags8).w			;set bit 7
	addi.w	#$96,(Crowdlevel).w		;add to Crowdlevel
	addi.w	#$A,(CwdExciteLvl).w	;add to Excite Level
	btst	#3,(GameFlags).w
	beq.w	.9
	bra.w	.10
.9
	addq.w	#1,$396(a0)
.10
	movem.l	(sp)+,d0/a0
	bset	#0,(onetimerflags).w
	btst	#3,(GameFlags).w
	bne.w	.11
	bset	#pf2aip,pflags2(a3)
	bset	#1,(sflags6).w
.11
	rts

CheckOneTimerFacing					;Findhittype on direction d0 (the angle to the goal), d0 kept. The Z flag
									;picks the one-timer animation in
									;setonetimeranim.
	movem.w	d0,-(sp)
	jsr	(Findhittype).l
	movem.w	(sp)+,d0
	rts
	rts

