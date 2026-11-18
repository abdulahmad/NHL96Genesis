;	User and team name appending, attribute calc and weight lists, TrimSpaces.

AppendUserName						;Append user name d2 (12 bytes of the name log at namelog, spaces for 0)
									;to a1, or NoNameTxt when d2 is 0
									;trailing spaces trimmed (TrimSpaces).
	movem.l	d0-d3/a0-a3,-(sp)
	movea.l	a1,a2
	tst.w	d2
	beq.w	.3
	move.w	#9,d0
	clr.w	d3
	movea.l	#namelog,a0
	mulu.w	#$A,d2
	adda.l	d2,a0
.loop
	move.b	(a0,d3.w),d1
	bne.w	.1
	move.b	#$20,d1
.1
	move.b	d1,2(a1)
	tst.b	(a1)+
	addq.w	#1,d3
	dbf	d0,.loop
	move.w	#$C,(a2)
	btst	#7,(sflags6).w
	beq.w	.2
	bsr.w	TrimSpaces
.2
	bra.w	.4
.3
	movea.l	a1,a3
	move.l	a3,-(sp)
	movea.l	#$1D7DCA,a1
	jsr	(CopyString).l
	movea.l	(sp)+,a2
	bsr.w	TrimSpaces
.4
	movem.l	(sp)+,d0-d3/a0-a3
	rts
	dc.w	$0002

AppendTeamName						;Append the city name of team d0 (TeamList block Strings) to a1
									;(appstring).
	movem.l	d0/a0-a3,-(sp)
	ext.w	d0
	asl.w	#2,d0
	movea.l	#$77E,a0
	movea.l	(a0,d0.w),a0
	move.w	4(a0),d0
	ext.l	d0
	adda.l	d0,a0
	adda.w	(a0),a0
	movea.l	a1,a3
	movea.l	a0,a1
	jsr	(appstring).l
	movem.l	(sp)+,d0/a0-a3
	rts

CalcAttrib							;The overall rating of player d0: his attributes weighted by
									;OvrPlayerWgtList (skaters) or OvrGoalWgtList
									;(goalies), and by AttribWgtList. Called from getNameandAttrib and
									;PrintOverallRating
	move.l	a6,-(sp)				;push a6 to stack
	clr.w	(attribsum).w
	clr.w	(attribcount).w
	movea.l	#AttribWgtList,a6
	cmp.l	(PAttribOverallMask).l,d4	;compare long word (1FBA000A) to d4
	bne.w	.0
	movea.l	#OvrPlayerWgtList,a6
.0
	cmp.l	(GAttribOverallMask).l,d4	;compare long word 130F000A to d4
	bne.w	.2
	movea.l	#OvrGoalWgtList,a6
.2
	movea.l	$1E(a2),a0
	lea	$1BC(a2),a4
	clr.l	d1						;clear d1
	move.w	d0,d1					;move d0 into d1. d0 is the offset of the player
	asl.w	#4,d1					;mult d1 by 16
	adda.l	d1,a4					;add d1 to a4
	adda.l	#$10,a4					;add 16 dec to a4. Move to start of Hot/Cold for player.
	movem.l	d7/a1,-(sp)
	move.w	$28(a2),d7
	jsr	(GetRosterName).l
	adda.w	(a1),a1
	addq.w	#8,a1
	movea.l	a1,a0
	movem.l	(sp)+,d7/a1
	clr.w	d0
	clr.w	d1
	moveq	#$F,d2
	swap	d4
.bit
	btst	d2,d4
	beq.w	.next
	move.w	d2,d3
	lsr.w	#1,d3
	neg.w	d3
	move.b	-1(a0,d3.w),d3
	btst	#0,d2
	beq.w	.1
	lsr.w	#4,d3
.1
	andi.w	#$F,d3
	cmp.w	#$D,d2
	bne.w	.4
	bra.w	.add
.4
	tst.w	d2
	bne.w	.3
	btst	#4,(sflags13).w
	beq.w	.6
	asr.b	#1,d3
	bra.w	.3
.6
	cmp.b	#6,d3
	ble.w	.3
	subq.b	#6,d3
.3
	cmp.w	#6,d2
	beq.w	.add
	movem.l	d5-d7,-(sp)
	move.b	(a6,d2.w),d5
	ext.w	d5
	cmp.w	#2,d5
	beq.w	.5
	move.w	d3,-(sp)
	subq.w	#2,d5
.attribadd
	add.w	(sp),d3
	dbf	d5,.attribadd
	asr.w	#1,d3
	tst.w	(sp)+
.5
	movem.l	(sp)+,d5-d7
	cmpa.l	#AttribWgtList,a6
	beq.w	.create
	neg.w	d2
	move.w	d7,-(sp)
	move.b	-1(a4,d2.w),d7
	ext.w	d7
	add.w	d7,(attribsum).w
	addq.w	#1,(attribcount).w
	move.w	(sp)+,d7
	neg.w	d2
	bra.w	.add
.create
	move.w	d3,-(sp)
	asl.w	#4,d3
	add.w	(sp),d3
	add.w	(sp)+,d3
	neg.w	d2
	add.b	-1(a4,d2.w),d3
	bpl.w	.pos
	clr.b	d3
.pos
	neg.w	d2
.add
	add.w	d3,d0
	addi.w	#$64,d1
.next
	dbf	d2,.bit
	cmpa.l	#AttribWgtList,a6
	beq.w	.11
	move.w	#$64,d1
	movem.l	d6-d7,-(sp)
	move.w	(attribsum).w,d6
	ext.l	d6
	move.w	(attribcount).w,d7
	divs.w	d7,d6
	add.w	d6,d0
	movem.l	(sp)+,d6-d7
.11
	cmp.w	d1,d0
	blt.w	.7
	move.w	d0,d1
	subq.w	#1,d0
.7
	jsr	(MinOverallRating).l
	movea.l	(sp)+,a6
	rts

OvrPlayerWgtList					;Skater attribute weights for the overall rating (CalcAttrib)
	dc.b	$02,$02,$02,$02,$04,$06,$02,$04,$02,$04,$06,$06,$04,$02,$02,$02

OvrGoalWgtList						;Goalie attribute weights
	dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$09,$09,$02,$02,$09,$02,$02,$02

AttribWgtList						;Single attribute weights
	dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02

TrimSpaces							;Trim the trailing spaces of String a2 and pad it to an even length.
	movem.l	a3,-(sp)
	movea.l	a2,a3
	adda.w	(a2),a3
.loop
	move.b	-(a3),d0
	cmp.b	#$20,d0
	bne.w	.1
	move.b	#0,(a3)
	subq.w	#1,(a2)
	bra.s	.loop
.1
	addq.w	#1,(a2)
	andi.w	#$FE,(a2)
	movem.l	(sp)+,a3
	rts

