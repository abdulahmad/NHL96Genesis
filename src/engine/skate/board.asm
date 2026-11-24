;	Board fall placement.

PlaceBoardFall						;places a player falling at the boards (tests the position word at $58)
	cmpi.w	#SPAboardmidl,SPA(a3)
	beq.w	.10
	cmpi.w	#SPAboardmidr,SPA(a3)
	beq.w	.8
	cmpi.w	#SPAboardleft,SPA(a3)
	beq.w	.6
	cmpi.w	#SPAboardtop,SPA(a3)
	beq.w	.0
	cmpi.w	#SPAboardbot,SPA(a3)
	beq.w	.3
	bra.w	.11
.0
	move.w	#$124,d0
	cmpi.w	#$56,(FallXPos).w
	bgt.w	.1
	cmpi.w	#$FFAA,(FallXPos).w
	bgt.w	.2
.1
	move.w	#$116,d0
.2
	sub.w	Ypos(a3),d0
	bmi.w	.11
	asr.w	#1,d0
	add.w	d0,Ypos(a3)
	bra.w	.11
.3
	move.w	#$FEDC,d0
	cmpi.w	#$56,(FallXPos).w
	bgt.w	.4
	cmpi.w	#$FFAA,(FallXPos).w
	bgt.w	.5
.4
	move.w	#$FEEA,d0
.5
	sub.w	Ypos(a3),d0
	bpl.w	.11
	asr.w	#1,d0
	add.w	d0,Ypos(a3)
	bra.w	.11
.6
	move.w	#$90,d0
	btst	#3,attribute(a3)
	beq.w	.7
	move.w	#$FF70,d0
.7
	sub.w	(a3),d0
	asr.w	#1,d0
	add.w	d0,(a3)
	bra.w	.11
	move.w	#$96,d0
	btst	#3,attribute(a3)
	beq.w	.12
	move.w	#$FF6A,d0
.12
	sub.w	(a3),d0
	asr.w	#1,d0
	add.w	d0,(a3)
	bra.w	PlaceBoardFallExit
.8
	move.w	#$FF70,d0
	btst	#3,attribute(a3)
	beq.w	.9
	move.w	#$90,d0
.9
	sub.w	(a3),d0
	asr.w	#1,d0
	add.w	d0,(a3)
	bra.w	.11
.10
	move.w	#$FF6A,d0
	btst	#3,attribute(a3)
	beq.w	*+4
.13
	sub.w	(a3),d0
	asr.w	#1,d0
	add.w	d0,(a3)
PlaceBoardFallExit	equ	*			;Shared return of PlaceBoardFall
.11
	rts
