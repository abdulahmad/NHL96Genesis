;	Shot and pass preparation.

PrepShotPass						;Called before setpassmode / SetShotMode. Loads TempWord1 to d1 when the
									;clock is running, then the movem restores d1 so it has no effect.
	movem.l	d1-d7/a0,-(sp)
	btst	#gmclock,(gmode).w
	bne.w	.0
	move.w	(TempWord1).w,d1
.0
	movem.l	(sp)+,d1-d7/a0
	rts
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#OptPad+8,a1
	jsr	(GetLogName).l
	move.w	(NameEntryLen).w,d0
	move.b	#0,(a1,d0.w)
	addq.w	#1,d0
	andi.w	#$FFFE,d0
	move.w	d0,-$2(a1)
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	movem.l	d0-d7/a0/a2-a6,-(sp)
	move.w	(pad1user).w,d0
.loop
	tst.w	d0
	beq.w	.1
	movea.l	#NameEntryBuf+2,a1
	move.w	d0,(namelogsel).w
	jsr	(GetLogName).l
	adda.w	(NameEntryLen).w,a1
	move.b	#0,(a1)
	addq.w	#1,(NameEntryLen).w
	andi.w	#$FFFE,(NameEntryLen).w
	addq.w	#2,(NameEntryLen).w
	move.w	(NameEntryLen).w,(NameEntryBuf).w
	movea.l	#NameEntryBuf,a1
	move.l	a1,-(sp)
	movea.l	#TempLegSpd+2,a3
	movea.l	#$1D92C8,a1
	bsr.w	CopyString
	movea.l	(sp)+,a1
	movea.l	#TempLegSpd+2,a3
	jsr	(appstring).l
	movea.l	#TempLegSpd+2,a3
	jsr	(appendz).l
	String	')'
	movea.l	#TempLegSpd+2,a1
.loop2
	movem.l	(sp)+,d0-d7/a0/a2-a6
	rts
	dc.w	$000E,$2870,$6C61,$7965,$6420,$6279,$2000,$0002
.1
	movea.l	#$1D92D6,a1
	bra.s	.loop2
	movem.l	d0-d7/a0/a2-a6,-(sp)
	move.w	(pad2user).w,d0
	bra.w	.loop

SetSflags8Bit1						;Always sets sflags8 bit 1 (the bclr is skipped)
	bra.w	.0
	dc.b	$08,$B8,$00,$01,$C3,$4C,$60,$00,$00,$08
.0
	bset	#1,(sflags8).w
	rts
SoftClampCoord	equ	*			;d0 = d0 (or d0 / 2 + $28 when under $50)
	cmp.w	#$50,d0
	bge.w	.exit
	asr.w	#1,d0
	addi.w	#$28,d0
.exit
	rts
	movem.w	d0-d1,-(sp)
	move.w	(puckx).w,d0
	sub.w	(a3),d0
	cmp.w	#$1E,d0
	bgt.w	.next
	move.w	(puckvx).w,d1
	eor.w	d1,d0
	andi.w	#$8000,d0
	beq.w	.next
	move.w	(pucky).w,d0
	sub.w	Ypos(a3),d0
	cmp.w	#$1E,d0
	bgt.w	.next
	move.w	(puckvy).w,d1
	eor.w	d1,d0
	andi.w	#$8000,d0
.next
	movem.w	(sp)+,d0-d1
	rts
