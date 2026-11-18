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
									;Code the listing does not decode: kept as bytes
	dc.b	$34,$7C,$C7,$26,$43,$EA,$03,$9E,$70,$01,$61,$00,$00,$06,$70,$02
	dc.b	$C3,$4A,$0C,$6A,$FF,$FF,$00,$26,$67,$00,$60,$46,$42,$2A,$00,$26
	dc.b	$B0,$78,$C3,$90,$67,$00,$60,$3A,$B0,$78,$C3,$92,$67,$00,$60,$32
	dc.b	$32,$38,$BF,$E4

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
									;Code the listing does not decode: kept as bytes
	dc.b	$08,$38,$00,$02,$C3,$40,$67,$00,$00,$06,$61,$00,$FB,$16,$08,$AB
	dc.b	$00,$01,$00,$62,$67,$00,$00,$0C,$42,$6B,$00,$40,$37,$7C,$00,$78
	dc.b	$00,$42,$32,$7C,$BF,$1A,$9F,$69,$00,$02,$9F,$69,$00,$06,$9F,$6B
	dc.b	$00,$40,$6A,$00,$00,$0A,$5A,$6B,$00,$40,$61,$00,$04,$22,$30,$38
	dc.b	$B7,$BE,$6B,$00,$00,$36,$EF,$40,$34,$7C,$B0,$5E,$D4,$C0,$61,$00
	dc.b	$01,$E2,$2F,$0A,$61,$00,$08,$92,$D0,$52,$90,$53,$E4,$40,$D1,$53
	dc.b	$D2,$6A,$00,$14,$92,$6B,$00,$14,$E4,$41,$D3,$6B,$00,$14,$37,$6A
	dc.b	$00,$28,$00,$28,$37,$6A,$00,$2A,$00,$2A,$4E,$B9,$00,$01,$9E,$B2
	dc.b	$4E,$B9,$00,$01,$9C,$50,$08,$38,$00,$00,$C3,$38,$66,$00,$00,$3A
	dc.b	$4A,$78,$B7,$BE,$6A,$00,$00,$2C,$30,$13,$B0,$6B,$00,$1C,$66,$00
	dc.b	$00,$22,$30,$2B,$00,$14,$B0,$6B,$00,$20,$66,$00,$00,$16,$70,$06
	dc.b	$53,$6B,$00,$42,$6A,$00,$00,$08,$4E,$B9,$00,$01,$C1,$D2,$60,$00
	dc.b	$00,$08,$37,$7C,$00,$78,$00,$42,$4A,$2B,$00,$2C,$66,$00,$53,$BC
	dc.b	$4A,$6B,$00,$18,$66,$00,$53,$B4,$61,$00,$02,$CA,$60,$00,$53,$AC

ChkOffsides							;Offsides.
									;Code the listing does not decode: kept as bytes
	dc.b	$08,$38,$00,$05,$C3,$38,$67,$00,$5B,$F2,$08,$38,$00,$02,$C3,$40
	dc.b	$66,$00,$5B,$E8,$32,$7C,$C7,$26,$45,$E9,$03,$9E,$61,$00,$00,$9E
	dc.b	$C3,$4A,$61,$00,$00,$98,$30,$3C,$00,$72,$B0,$6B,$00,$14,$6E,$00
	dc.b	$00,$42,$B0,$6B,$00,$20,$6F,$00,$5B,$C2,$06,$40,$00,$0A,$08,$38
	dc.b	$00,$01,$C3,$38,$67,$00,$00,$04,$C5,$49,$74,$05,$30,$6A,$00,$22
	dc.b	$4A,$68,$00,$34,$6B,$00,$00,$12,$B0,$68,$00,$14,$6C,$00,$00,$0A
	dc.b	$08,$EA,$00,$04,$00,$30,$4E,$75,$D0,$FC,$00,$80,$51,$CA,$FF,$E2
	dc.b	$4E,$75,$44,$40,$B0,$6B,$00,$14,$6D,$00,$5B,$80,$B0,$6B,$00,$20
	dc.b	$6C,$00,$5B,$78,$04,$40,$00,$0A,$08,$38,$00,$01,$C3,$38,$66,$00
	dc.b	$00,$04,$C5,$49,$74,$05,$30,$6A,$00,$22,$4A,$68,$00,$34,$6B,$00
	dc.b	$00,$12,$B0,$68,$00,$14,$6F,$00,$00,$0A,$08,$EA,$00,$04,$00,$30
	dc.b	$4E,$75,$D0,$FC,$00,$80,$51,$CA,$FF,$E2,$4E,$75,$08,$2A,$00,$04
	dc.b	$00,$30,$67,$00,$5B,$36,$30,$6A,$00,$22,$72,$05,$4A,$68,$00,$34
	dc.b	$6B,$00,$00,$12,$30,$28,$00,$14,$08,$28,$00,$07,$00,$62,$66,$00
	dc.b	$00,$04,$44,$40,$D0,$FC,$00,$80,$B0,$7C,$00,$76,$5E,$C9,$FF,$DE
	dc.b	$6E,$00,$5B,$08,$08,$AA,$00,$04,$00,$30,$4E,$75

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
