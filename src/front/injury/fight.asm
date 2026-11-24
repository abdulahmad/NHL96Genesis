;	Fight byte and bit helpers.

getFgtbyte							;d0 = fighting(a2) / 4
	clr.w	d0						;clear d0
	move.b	fighting(a2),d0			;fight rating (0-9) into d0
	lsr.w	#2,d0					;shift 2 right (divide by 4)
	rts

chkFgtBit1							;Z set when handed(a2) is 2 or less (d0 kept)
	cmpi.b	#2,handed(a2)
	ble.w	.0
	movem.w	d0,-(sp)
	move.w	#1,d0
	movem.w	(sp)+,d0
	bra.w	.1
.0
	movem.w	d0,-(sp)
	move.w	#0,d0
	movem.w	(sp)+,d0
.1
	rts
PickFaceoffDirection	equ	*			;d0 = a random direction word from the table at $1D90D0; 6 near the center
	movem.l	a0,-(sp)
	movea.l	#$1D90D0,a0
	move.w	#$64,d0
	jsr	(randomd0).l
	andi.w	#7,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	cmpi.w	#$FFC0,(fox).w
	bgt.w	.2
	cmpi.w	#$C0,(foy).w
	bgt.w	.2
	move.w	#6,d0
.2
	movem.l	(sp)+,a0
	rts
	dc.b	$00,$03,$00,$05,$00,$03,$00,$01,$00,$05,$00,$02,$00,$03,$00,$03
	dc.b	$FF,$FF
chkFgtBit1ShotsLead	equ	*
	movem.l	d0-d2/a0-a2,-(sp)
	movea.l	#tmstruct,a0
	movea.l	#AwShots,a1
	move.w	tmap(a0),d0				;home players on ice
	sub.w	tmap(a1),d0
	beq.w	.4						;same number on the ice: done
	bpl.w	.3						;home has more: test home
	exg	a0,a1						;away has more: test the away team
.3
	cmpi.w	#6,tmteam(a0)
	bne.w	.4						;(the branch goes to the next line either way)
	;exit: restore the registers
.4
	movem.l	(sp)+,d0-d2/a0-a2
	rts
