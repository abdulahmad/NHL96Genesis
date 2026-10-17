;	Season injuries. How many games a player misses.

RandomInjuryGames	;setInjuryType in a season: a random games count (SetInjuryGames), not when sflags13 bit 2 is set
	btst	#2,(sflags13).w
	bne.w	.0
	move.w	#$64,d0
	jsr	(randomd0).l
	cmp.w	#$1E,d0
	blt.w	.0
	movem.w	d1,-(sp)
	clr.w	d0
	move.b	#$50,d0
	clr.w	d1
	move.b	(SeasonDay).w,d1
	sub.w	d1,d0
	movem.w	(sp)+,d1
	cmp.w	#2,d0
	blt.w	.0
	subq.w	#1,d0
	cmp.w	#5,d0
	ble.w	.3
	move.w	#5,d0
.3
	jsr	(randomd0).l
	addq.w	#1,d0
	movem.l	d1/d7,-(sp)
	move.w	$28(a0),d7
	move.w	(TempPlOffset).w,d1
	andi.w	#$FF,d1
	bset	#2,(sflags13).w
	jsr	(SetInjuryGames).l
	movem.l	(sp)+,d1/d7
.0
	rts

SetInjuryGames	;Injury games d0 for player d1 of team d7 (save RAM bits); sflags13 bit 3 and injurygames
	movem.l	d0-d7/a0-a7,-(sp)
	bset	#3,(sflags13).w
	move.w	d0,(injurygames).w
	ext.l	d0
	mulu.w	#$51,d7
	mulu.w	#3,d1
	addi.l	#$EDF0,d1
	add.l	d7,d1
	moveq	#3,d2
	jsr	(WriteSRAMBits).l
	bclr	#6,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a7
	rts

SetSeasonInjuries	;The players of team a2 with injury games left (save RAM bits) are out ($FFFC)
	movem.l	d0-d4/a0/a2,-(sp)
	move.w	$28(a2),d1
	mulu.w	#$51,d1
	addi.l	#$EDF0,d1
	moveq	#3,d2
	adda.w	#$6C,a2
	move.w	#$1A,d3
.0
	jsr	(ReadSRAMBits).l
	tst.w	d0
	beq.w	.1
	move.w	#$FFFC,(a2)
.1
	addq.w	#2,a2
	addq.l	#3,d1
	dbf	d3,.0
	movem.l	(sp)+,d0-d4/a0/a2
	rts

GetInjuryGames	;d0 = the injury games of player d1 of team d7 (save RAM bits)
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$61,$00,$CE,$FC,$00,$51,$C2,$FC,$00,$03,$06,$81,$00,$00
	dc.b	$ED,$F0,$D2,$87,$74,$03,$4E,$B9,$00,$00,$97,$5A,$4C,$DF,$00,$86
	dc.b	$4E,$75

