;	The computer goalie pull. ChkGoalies pulls him on a delayed penalty, and CPgoalie
;	pulls him late in a game the computer is losing. The puck checks follow.

ChkGoalies							;A computer team down with its goalie in: pull him on a delayed penalty,
									;else CPgoalie
	btst	#gmclock,(gmode).w		;check if clock running
	bne.w	rtss2
	movea.w	#(tmstruct-M68K_RAM),a2
	lea	$39E(a2),a1
	moveq	#1,d0
	bsr.w	.chkgoalie
	moveq	#2,d0
	exg	a1,a2
.chkgoalie
	tst.w	$26(a2)					;check for goalie
	bmi.w	rtss2
	move.w	(puckc).w,d1			;move puck carrier SCnum into d1
	bmi.w	rtss2
	subq.w	#6,d1
	cmpa.w	#(tmstruct-M68K_RAM),a2
	beq.w	.chkpen
	not.w	d1						;makes d1 negative if away team
.chkpen
	tst.w	d1
	bpl.w	rtss2
	btst	#gmpendel,(gmode).w		;#gmpendel - delayed penalty called
	beq.w	.nopen
	st	$26(a2)						;sets to FFFF (no goalie)
	bra.w	setpersonel
.nopen
	cmp.w	(cont1team).w,d0
	beq.w	rtss2
	cmp.w	(cont2team).w,d0
	beq.w	rtss2
	move.w	(pucky).w,d1
	bra.w	CPgoalie

ReturnGoalies						;If the computer pulled its goalie, see if it should return him.
	movea.w	#(tmstruct-M68K_RAM),a2
	lea	$39E(a2),a1
	moveq	#1,d0
	bsr.w	ReturnGoaliesTeam
	moveq	#2,d0
	exg	a1,a2
ReturnGoaliesTeam
	cmpi.w	#$FFFF,$26(a2)
	beq.w	rtss2					;still no goalie
	clr.b	$26(a2)					;clear for goalie return
	cmp.w	(cont1team).w,d0
	beq.w	rtss2					;exit if team is joy controlled
	cmp.w	(cont2team).w,d0
	beq.w	rtss2					;exit if team is joy controlled
	move.w	(foy).w,d1

CPgoalie							;See if the computer should pull its goalie: third period, behind by 1, a
									;minute left, the puck in the other end
	cmpi.w	#2,(gsp).w				;check if 3rd period
	bne.w	rtss2
	move.w	tmscore(a1),d0			;tmscore
	sub.w	$C(a2),d0
	bmi.w	rtss2
	cmp.w	#1,d0
	bne.w	rtss2
	cmpi.w	#$3C,(gameclock).w		;#60
	bgt.w	rtss2
	move.l	a0,-(sp)
	movea.w	$22(a2),a0				;moves a player struct address into a0
	btst	#pfgoal,$62(a0)			;#pfgoal
	movea.l	(sp)+,a0
	bne.w	.0
	neg.w	d1						;if shooting on bottom goal, make d1 negative
.0
	tst.w	d1
	bmi.w	rtss2
	st	$26(a2)						;set to FFFF (no goalie)
	bra.w	setpersonel

CompLine							;The computer picks a line for team a2 (a1 = other team).
	movem.l	d0-d2/a0,-(sp)
	moveq	#3,d0
	move.w	OldZpos(a2),d1
	sub.w	$24(a1),d1
	beq.w	.3
	bpl.w	.1
	addq.w	#2,d0
.1
	move.w	d0,-(sp)				;find pk/pp line
	bsr.w	getlinee
	move.w	d0,d1
	move.w	(sp),d0
	addq.w	#1,d0
	bsr.w	getlinee
	cmp.w	d0,d1
	bge.w	.2
	addq.w	#1,(sp)
.2
	move.w	(sp)+,$16(a2)
.loop
	movem.l	(sp)+,d0-d2/a0
	rts
.3
	cmpa.w	#(tmstruct-M68K_RAM),a2
	bne.w	.5
	moveq	#2,d1
	lea	.table(pc),a0
	cmpi.w	#2,(gsp).w
	bne.w	.4
	move.w	$C(a2),d2
	cmp.w	$C(a1),d2
	beq.w	.4
	adda.w	#$E,a0
	bgt.w	.4
	adda.w	#$E,a0
.4
	move.w	$16(a1),d1
	asl.w	#1,d1
	move.w	(a0,d1.w),d0
	bsr.w	getlinee
	cmp.w	#$C00,d0
	bls.w	.5
	move.w	(a0,d1.w),$16(a2)
	bra.s	.loop
.table
	dc.w	$0000,$0001,$0002,$0000,$0001,$0000,$0001,$0002
	dc.w	$0000,$0001,$0002,$0000,$0002,$0000,$0000,$0001
	dc.w	$0000,$0000,$0001,$0000,$0001
.5
	moveq	#2,d1
	lea	.table2(pc),a0
	cmpi.w	#2,(gsp).w
	bne.w	.loop2
	move.w	$C(a2),d2
	cmp.w	$C(a1),d2
	beq.w	.loop2
	addq.w	#6,a0
	bgt.w	.loop2
	addq.w	#6,a0
.loop2
	move.w	(a0)+,d0
	bsr.w	getlinee
	cmp.w	#$C00,d0
	dbhi	d1,.loop2
	move.w	-(a0),$16(a2)
	bra.w	.loop
.table2
	dc.w	$0000,$0001,$0002,$0000,$0002,$0001,$0000,$0001
	dc.w	$0000

AssignPads							;Give each pad on a team a player.
	move.w	#$FFFF,(c1playernum).w
	move.w	#$FFFF,(c2playernum).w
	move.w	#$FFFF,(c3playernum).w
	move.w	#$FFFF,(c4playernum).w
	tst.w	(cont1team).w
	beq.w	.5
	btst	#3,(sflags9).w
	beq.w	.4
	cmpi.w	#1,(cont1team).w
	beq.w	.1
	tst.w	(cont4team+4).w
	bne.w	.4
	beq.w	.2
.1
	tst.w	(cont4team+2).w
	bne.w	.4
.2
	movem.l	d0/a0/a3,-(sp)
	move.w	#5,d0
	cmpi.w	#1,(cont1team).w
	beq.w	.3
	move.w	#$B,d0
.3
	jsr	(FindGoalie).l
	clr.w	d4
	jsr	(setc1player).l
	movem.l	(sp)+,d0/a0/a3
	bra.w	.5
.4
	clr.w	d4
	jsr	(chgplayer).l
.5
	tst.w	(cont2team).w
	beq.w	.10
	btst	#3,(sflags9).w
	beq.w	.9
	cmpi.w	#2,(cont2team).w
	beq.w	.6
	tst.w	(cont4team+2).w
	bne.w	.9
	bra.w	.7
.6
	tst.w	(cont4team+4).w
	bne.w	.9
.7
	movem.l	d0/a0/a3,-(sp)
	move.w	#$B,d0
	cmpi.w	#2,(cont2team).w
	beq.w	.8
	move.w	#5,d0
.8
	jsr	(FindGoalie).l
	move.w	#2,d4
	jsr	(setc2player).l
	movem.l	(sp)+,d0/a0/a3
	bra.w	.10
.9
	moveq	#2,d4
	jsr	(chgplayer).l
.10
	tst.w	(cont3team).w
	beq.w	.15
	btst	#3,(sflags9).w
	beq.w	.14
	cmpi.w	#2,(cont3team).w
	beq.w	.11
	tst.w	(cont4team+2).w
	bne.w	.14
	bra.w	.12
.11
	tst.w	(cont4team+4).w
	bne.w	.14
.12
	movem.l	d0/a0/a3,-(sp)
	move.w	#$B,d0
	cmpi.w	#2,(cont3team).w
	beq.w	.13
	move.w	#5,d0
.13
	jsr	(FindGoalie).l
	move.w	#4,d4
	jsr	(setc3player).l
	movem.l	(sp)+,d0/a0/a3
	bra.w	.15
.14
	moveq	#4,d4
	jsr	(chgplayer).l
.15
	tst.w	(cont4team).w
	beq.w	.20
	btst	#3,(sflags9).w
	beq.w	.19
	cmpi.w	#2,(cont4team).w
	beq.w	.16
	tst.w	(cont4team+2).w
	bne.w	.19
	bra.w	.17
.16
	tst.w	(cont4team+4).w
	bne.w	.19
.17
	movem.l	d0/a0/a3,-(sp)
	move.w	#$B,d0
	cmpi.w	#2,(cont4team).w
	beq.w	.18
	move.w	#5,d0
.18
	jsr	(FindGoalie).l
	move.w	#6,d4
	jsr	(setc4player).l
	movem.l	(sp)+,d0/a0/a3
	bra.w	.20
.19
	moveq	#6,d4
	jsr	(chgplayer).l
.20
	rts

updatefaceoff						;Faceoff drop countdown: the fofdata frame from temp1; at 0 erase the
									;faceoff box at fodropx / fodropy
	move.w	temp1(a3),d0			;frames left until the drop
	beq.w	.1						;0: remove the face off box
	addq.w	#6,d0
	lsr.w	#3,d0					;(temp1 + 6) / 8
	cmp.w	#2,d0
	bgt.w	rtss2
	neg.w	d0
	addi.w	#$A,d0					;frame $A - d0 (8 to 10) as the drop approaches
	move.w	d0,(fofdata2+8).w		;+8
	rts
	;d0 = 0
.1
	bclr	#dffaceoff,(disflags).w
	bsr.w	printz
	String	-(TXPRI+TXMAP1),0,0
	move.w	(fodropx).w,d0
	subi.w	#$2E,d0
	asr.w	#3,d0
	move.w	d0,(printx).w			;same print column as in puckfaceoff2
	moveq	#$64,d0					;(4*8)+68, overwritten (as in 92)
	move.w	(fodropy).w,d0
	subi.w	#$44,d0
	asr.w	#3,d0
	move.w	d0,(printy).w
	moveq	#$C,d0					;eraser: d0/d1 = x/y size, d2 = fill char word
	moveq	#$D,d1
	move.w	#$7FF,d2
	bra.w	eraser

pucknorm							;asstab entry: the puck: follow the carrier, icing / offsides checks.
	btst	#2,(BA_PS_flags).w		;check if flag is clear (normal play)
	beq.w	.1
	bsr.w	UpdatePenaltyShotEnd
.1
	bclr	#pfna,$62(a3)			;#pfna clear
	beq.w	.2
	clr.w	$40(a3)					;temp1
	move.w	#$78,$42(a3)			;'x' ; temp2
.2
	movea.w	#(puckcross-M68K_RAM),a1	;table for puck crossing lines
	sub.w	d7,2(a1)				;sub elapse frames from time til crossing
	sub.w	d7,6(a1)
	sub.w	d7,$40(a3)				;temp1
	bpl.w	.3
	addq.w	#5,$40(a3)
	bsr.w	findpc
.3
	move.w	(puckc).w,d0
	bmi.w	.4
	asl.w	#scsize,d0				;#scsize
	movea.w	#(SortCords-M68K_RAM),a2
	adda.w	d0,a2
	bsr.w	a2touchpuck
	move.l	a2,-(sp)
	bsr.w	GetHot
	add.w	(a2),d0					;Xpos - bungie the puck towards the hot spot on player a2
	sub.w	(a3),d0
	asr.w	#2,d0
	add.w	d0,(a3)
	add.w	$14(a2),d1				;Ypos
	sub.w	$14(a3),d1
	asr.w	#2,d1
	add.w	d1,$14(a3)
	move.w	$28(a2),$28(a3)			;Xvel
	move.w	$2A(a2),$2A(a3)			;Yvel
.4
	jsr	(PuckIChk).l
	jsr	(ChkOffsides).l
	btst	#gmclock,(gmode).w		;check for play stoppage
	bne.w	.7
	tst.w	(puckc).w
	bpl.w	.6
	move.w	(a3),d0					;Xpos
	cmp.w	$1C(a3),d0				;oldXpos
	bne.w	.6
	move.w	$14(a3),d0				;Ypos
	cmp.w	$20(a3),d0				;oldYpos
	bne.w	.6
	moveq	#6,d0
	subq.w	#1,$42(a3)				;temp3
	bpl.w	.5
	jsr	(AddPenalty2).l
.5
	bra.w	.7
.6
	move.w	#$78,$42(a3)			;'x' ; move 78 hex into temp2
.7
	tst.b	$2C(a3)					;Zvel
	bne.w	wallcollcheck
	tst.w	$18(a3)					;Zpos
	bne.w	wallcollcheck
	bsr.w	puckunflip
	bra.w	wallcollcheck

ChkOffsides							;Offsides.
	btst	#gmoffs,(gmode).w
	beq.w	rtss2
	btst	#2,(BA_PS_flags).w
	bne.w	rtss2
	movea.w	#(tmstruct-M68K_RAM),a1
	lea	$39E(a1),a2
	bsr.w	CheckAttackersOffside
	exg	a1,a2
	bsr.w	CheckAttackersOffside
	move.w	#$72,d0
	cmp.w	$14(a3),d0
	bgt.w	.3
	cmp.w	$20(a3),d0
	ble.w	rtss2
	addi.w	#$A,d0
	btst	#gmdir,(gmode).w
	beq.w	.1
	exg	a2,a1
.1
	moveq	#5,d2
	movea.w	$22(a2),a0
.loop
	tst.w	$34(a0)
	bmi.w	.2
	cmp.w	$14(a0),d0
	bge.w	.2
	bset	#4,$30(a2)
	rts
.2
	adda.w	#SCstruct,a0
	dbf	d2,.loop
	rts
.3
	neg.w	d0
	cmp.w	$14(a3),d0
	blt.w	rtss2
	cmp.w	$20(a3),d0
	bge.w	rtss2
	subi.w	#$A,d0
	btst	#gmdir,(gmode).w
	bne.w	.4
	exg	a2,a1
.4
	moveq	#5,d2
	movea.w	$22(a2),a0
.loop2
	tst.w	$34(a0)
	bmi.w	.5
	cmp.w	$14(a0),d0
	ble.w	.5
	bset	#4,$30(a2)
	rts
.5
	adda.w	#SCstruct,a0
	dbf	d2,.loop2
	rts
CheckAttackersOffside				;Team a2: offside bit for the attackers beyond the blue line
	btst	#4,$30(a2)
	beq.w	rtss2
	movea.w	$22(a2),a0
	moveq	#5,d1
.loop
	tst.w	$34(a0)
	bmi.w	.1
	move.w	$14(a0),d0
	btst	#pfgoal,$62(a0)
	bne.w	.1
	neg.w	d0
.1
	adda.w	#SCstruct,a0
	cmp.w	#$76,d0
	dbgt	d1,.loop
	bgt.w	rtss2
	bclr	#4,$30(a2)
	rts

a2offsides							;Offsides on a2 when his team is offside and the puck is past the blue
									;line.
	btst	#gmoffs,(gmode).w
	beq.w	rtss2
	move.w	(pucky).w,d0
	btst	#pfgoal,pflags(a2)
	bne.w	.1
	neg.w	d0
.1
	cmp.w	#$86,d0
	blt.w	rtss2
	movea.w	#(tmstruct-M68K_RAM),a0
	btst	#pfteam,pflags(a2)
	beq.w	.2
	adda.w	#$39E,a0
.2
	btst	#4,$30(a0)
	beq.w	rtss2
	btst	#gmhl,(gmode).w
	bne.w	rtss2
	exg	a2,a3
	moveq	#$10,d0
	jsr	(AddPenalty).l
	exg	a2,a3
	rts

a2touchpuck							;Player a2 touched the puck: last touch, scorer / assist slots, offsides,
									;icing
	move.w	(a2),(ltx).w			;move Xpos to last touch X
	move.w	Ypos(a2),(lty).w		;move Ypos to last touch Y
	move.w	SCnum(a2),(ltplayer).w	;move SCnum to last touch player
	movea.w	#(tmstruct-M68K_RAM),a0	;move Home Shots into a0
	btst	#pfteam,pflags(a2)		;check if home or away
	beq.w	.1						;branch if home
	lea	$39E(a0),a0
.1
	clr.w	d0
	move.b	weight(a2),d0
	btst	#pf3onetimer,pflags3(a2)	;check if one timer
	beq.w	.2						;branch if not
	bset	#7,(sflags8).w			;set if one timer
.2
	cmp.w	$18(a0),d0				;compare value in C6E6 (home) to d0
	beq.w	.4						;branch if equal
	bclr	#3,$30(a0)				;clear bit 3
	bne.w	.3						;branch if not cleared before
	move.w	$1A(a0),$1C(a0)			;move current player to assist slot
	move.w	$18(a0),$1A(a0)			;move current player to last player slot
.3
	move.w	d0,$18(a0)				;move pnum into current player
	cmp.w	$1C(a0),d0				;compare if same player as assist slot
	bne.w	.4						;branch if not
	st	$1C(a0)						;set FFFF to assist slot
.4
	bclr	#sf2shot,(sflags2).w	;clear shot taken
	bsr.w	a2offsides
	btst	#ifok,(lty+2).w			;check if icing
	beq.w	.6						;branch if not
	btst	#ifcgl,(lty+2).w		;test if crossed goalline
	beq.w	.6						;branch if not
	tst.w	position(a2)			;check if goalie
	beq.w	.6						;branch if so
	btst	#ifdir,(lty+2).w		;check if must cross top line
	bne.w	.5						;branch if so
	btst	#pfgoal,pflags(a2)		;check if top or bottom shooting goal
	beq.w	.6						;branch if bottom
.loop
	clr.w	d0
	move.b	(lty+3).w,d0			;move iflags+1 into d0
	asl.w	#7,d0
	move.l	a3,-(sp)				;push on stack
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3					;a3 now player struct
	move.w	#PenIcing,d0
	jsr	(AddPenalty).l
	movea.l	(sp)+,a3
	rts
.5
	btst	#pfgoal,pflags(a2)		;check top or bottom shooting goal
	beq.s	.loop					;branch if bottom
.6
	bsr.w	ArmIcing
	rts

ArmIcing							;Icing start for a2: iflags cleared, icingPlayer, direction; bit 2 when
									;shot from his own half and not short
									;handed
	clr.b	(lty+2).w
	move.b	$53(a2),(lty+3).w
	move.w	(pucky).w,d0
	btst	#pfgoal,pflags(a2)
	beq.w	.1
	bset	#1,(lty+2).w
	neg.w	d0
.1
	bmi.w	rtss2
	move.w	($FFFFC74A).w,d0
	sub.w	($FFFFCAE8).w,d0
	btst	#pfteam,pflags(a2)
	beq.w	.2
	neg.w	d0
.2
	bmi.w	rtss2
	bset	#2,(lty+2).w
	rts

PuckIChk							;Icing check.
	btst	#ifok,(lty+2).w			;#ifok
	beq.w	rtss2
	btst	#ifcgl,(lty+2).w		;#ifcgl - if crossed goal line
	bne.w	rtss2
	tst.w	(puckc).w
	bpl.w	rtss2
	move.w	#$11E,d0
	btst	#ifdir,(lty+2).w
	bne.w	.1
	neg.w	d0
	cmp.w	(pucky).w,d0			;check other goalline
	bgt.w	.2
	rts
.1
	cmp.w	(pucky).w,d0
	bgt.w	rtss2
.2
	cmpi.w	#$2C,(puckx).w			;',' ; 2C - edge of crease
	bgt.w	.3
	cmpi.w	#$FFD4,(puckx).w		;-$2C, the edge of the crease
	blt.w	.3
	bclr	#ifok,(lty+2).w			;#ifok cleared
	rts
.3
	bset	#ifcgl,(lty+2).w		;#ifcgl
	rts

puckunflip							;asstab entry: stop the spinning puck.
	cmpi.w	#8,SPAnum(a3)
	blt.w	.1
	cmpi.w	#$18,SPAnum(a3)
	bge.w	.1
	eori.w	#2,facedir(a3)			;facedir
.1
	ori.w	#4,facedir(a3)
	clr.w	SPAnum(a3)				;SPAnum
	st	SPAcnt(a3)					;SPAcnt
	rts
