;	Save RAM bit fields, new in 96. WriteSRAMBits writes a bit field into the save RAM and
;	ReadSRAMBits reads one back. Bytes the listing does not decode, and that nothing
;	references, stay where they are.

WriteSRAMBits						;Write the d2-bit value d0 to the save RAM at bit d1 (bit 0 is the top bit
									;of the first odd byte at SaveRAM), then MakeSRAMChecksum unless GameFlags
									;bit 6 is set
	movem.l	d0-d6/a0,-(sp)
	movea.l	#SaveRAM,a0
	move.w	d1,d3
	lsr.w	#3,d3
	add.w	d3,d3
	move.w	d1,d4
	andi.w	#7,d4
	adda.w	d3,a0
	moveq	#-1,d5
	move.w	#$20,d6
	sub.w	d2,d6
	lsl.l	d6,d5
	lsr.l	d4,d5
	not.l	d5
	lsl.l	d6,d0
	lsr.l	d4,d0
	move.b	1(a0),d6
	lsl.w	#8,d6
	move.b	3(a0),d6
	swap	d6
	move.b	5(a0),d6
	lsl.w	#8,d6
	move.b	7(a0),d6
	and.l	d5,d6
	or.l	d0,d6
	move.b	d6,7(a0)
	lsr.w	#8,d6
	move.b	d6,5(a0)
	swap	d6
	move.b	d6,3(a0)
	lsr.w	#8,d6
	move.b	d6,1(a0)
	btst	#6,(GameFlags).l
	bne.w	.0
	jsr	(MakeSRAMChecksum).l
.0
	movem.l	(sp)+,d0-d6/a0
	rts

ReadSRAMBits						;d0 = the d2-bit value at bit d1 of the save RAM (see WriteSRAMBits)
	movem.l	d1-d6/a0,-(sp)
	movea.l	#SaveRAM,a0
	move.w	d1,d3
	lsr.w	#3,d3
	add.w	d3,d3
	move.w	d1,d4
	andi.w	#7,d4
	adda.w	d3,a0
	moveq	#-1,d5
	move.w	#$20,d6
	sub.w	d2,d6
	lsl.l	d6,d5
	lsr.l	d4,d5
	move.b	1(a0),d0
	lsl.w	#8,d0
	move.b	3(a0),d0
	swap	d0
	move.b	5(a0),d0
	lsl.w	#8,d0
	move.b	7(a0),d0
	and.l	d5,d0
	lsl.l	d4,d0
	lsr.l	d6,d0
	movem.l	(sp)+,d1-d6/a0
	rts
ReadSRAMBitsSkip1	equ	*			;Entry after the register save when the bit field is skipped (low confidence)
	movem.l	d0/d2-d4/d6-d7/a1-a2/a4-a6,-(sp)
	move.w	d3,d7
	ext.l	d5
	bra.w	.3
.loop
	movea.l	#$200000,a4
	move.w	d1,d3
	lsr.w	#3,d3
	add.w	d3,d3
	move.w	d1,d4
	andi.w	#7,d4
	adda.w	d3,a4
	moveq	#-$1,d3
	move.w	#$20,d6
	sub.w	d2,d6
	lsl.l	d6,d3
	lsr.l	d4,d3
	move.b	1(a4),d0
	lsl.w	#8,d0
	move.b	3(a4),d0
	swap	d0
	move.b	5(a4),d0
	lsl.w	#8,d0
	move.b	7(a4),d0
	and.l	d3,d0
	lsl.l	d4,d0
	lsr.l	d6,d0
	cmp.w	(PlayoffMenuTeam+2).l,d7
	bge.w	.1
	clr.w	d0
.1
	tst.w	d0
	beq.w	.2
	move.w	d5,(a3)+
	addq.w	#1,(a2)
	move.w	d0,(a0)+
.2
	addq.l	#1,d5
	add.l	d2,d1
.3
	dbf	d7,.loop
	movem.l	(sp)+,d0/d2-d4/d6-d7/a1-a2/a4-a6
	rts
ReadSRAMBitsSkip2	equ	*			;Second skip entry of ReadSRAMBits (low confidence)
	movem.l	d0/d2-d4/d6-d7/a1-a2/a4-a6,-(sp)
	move.w	d3,d7
	ext.l	d5
	bra.w	.9
.loop2
	movea.l	#$200000,a4
	move.w	d1,d3
	lsr.w	#3,d3
	add.w	d3,d3
	move.w	d1,d4
	andi.w	#7,d4
	adda.w	d3,a4
	moveq	#-$1,d3
	move.w	#$20,d6
	sub.w	d2,d6
	lsl.l	d6,d3
	lsr.l	d4,d3
	move.b	1(a4),d0
	lsl.w	#8,d0
	move.b	3(a4),d0
	swap	d0
	move.b	5(a4),d0
	lsl.w	#8,d0
	move.b	7(a4),d0
	and.l	d3,d0
	lsl.l	d4,d0
	lsr.l	d6,d0
	cmp.w	(PlayoffMenuTeam+2).l,d7
	bge.w	.4
	clr.w	d0
.4
	movem.l	d0-d1,-(sp)
	btst	#2,(SeasonDay+2).l
	beq.w	.5
	addi.l	#$F00,d1
	bra.w	.6
.5
	addi.l	#$1D40,d1
.6
	movea.l	#$200000,a4
	move.w	d1,d3
	lsr.w	#3,d3
	add.w	d3,d3
	move.w	d1,d4
	andi.w	#7,d4
	adda.w	d3,a4
	moveq	#-$1,d3
	move.w	#$20,d6
	sub.w	d2,d6
	lsl.l	d6,d3
	lsr.l	d4,d3
	move.b	1(a4),d0
	lsl.w	#8,d0
	move.b	3(a4),d0
	swap	d0
	move.b	5(a4),d0
	lsl.w	#8,d0
	move.b	7(a4),d0
	and.l	d3,d0
	lsl.l	d4,d0
	lsr.l	d6,d0
	move.l	d0,d6
	cmp.w	(PlayoffMenuTeam+2).l,d7
	bge.w	.7
	clr.w	d0
.7
	movem.l	(sp)+,d0-d1
	add.w	d6,d0
	tst.w	d0
	beq.w	.8
	move.w	d5,(a3)+
	addq.w	#1,(a2)
	move.w	d0,(a0)+
.8
	addq.l	#1,d5
	add.l	d2,d1
.9
	dbf	d7,.loop2
	movem.l	(sp)+,d0/d2-d4/d6-d7/a1-a2/a4-a6
	rts
ReadSRAMBitsSkip3	equ	*			;Third skip entry of ReadSRAMBits (low confidence)
	movem.l	d0/d2-d3/d6-d7/a1-a2/a4-a6,-(sp)
	move.w	d3,d7
	ext.l	d5
	move.l	d4,-(sp)
	move.l	d6,-(sp)
	bra.w	.11
.loop3
	moveq	#$E,d2
	movea.l	#$200000,a4
	move.w	d1,d3
	lsr.w	#3,d3
	add.w	d3,d3
	move.w	d1,d4
	andi.w	#7,d4
	adda.w	d3,a4
	moveq	#-$1,d3
	move.w	#$20,d6
	sub.w	d2,d6
	lsl.l	d6,d3
	lsr.l	d4,d3
	move.b	1(a4),d0
	lsl.w	#8,d0
	move.b	3(a4),d0
	swap	d0
	move.b	5(a4),d0
	lsl.w	#8,d0
	move.b	7(a4),d0
	and.l	d3,d0
	lsl.l	d4,d0
	lsr.l	d6,d0
	move.l	(sp),d2
	move.l	4(sp),d3
	movem.l	d0-d1,-(sp)
	move.l	d3,d1
	movea.l	#$200000,a4
	move.w	d1,d3
	lsr.w	#3,d3
	add.w	d3,d3
	move.w	d1,d4
	andi.w	#7,d4
	adda.w	d3,a4
	moveq	#-$1,d3
	move.w	#$20,d6
	sub.w	d2,d6
	lsl.l	d6,d3
	lsr.l	d4,d3
	move.b	1(a4),d0
	lsl.w	#8,d0
	move.b	3(a4),d0
	swap	d0
	move.b	5(a4),d0
	lsl.w	#8,d0
	move.b	7(a4),d0
	and.l	d3,d0
	lsl.l	d4,d0
	lsr.l	d6,d0
	move.l	d0,d6
	movem.l	(sp)+,d0-d1
	tst.w	d6
	beq.w	.10
	mulu.w	#$A,d6
	divu.w	#$3C,d6
	bvs.w	.10
	cmp.w	#$A,d6
	blt.w	.10
	mulu.w	#$3E8,d0
	divu.w	d6,d0
	move.w	d5,(a3)+
	addq.w	#1,(a2)
	move.w	d0,(a0)+
.10
	addq.l	#1,d5
	addi.l	#$E,d1
	move.l	(sp),d3
	add.l	d3,4(sp)
.11
	dbf	d7,.loop3
	addq.w	#4,sp
	move.l	(sp)+,d4
	movem.l	(sp)+,d0/d2-d3/d6-d7/a1-a2/a4-a6
	rts

