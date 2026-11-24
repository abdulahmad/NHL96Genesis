;	The hi-score screen.

HiScoreScreen						;vb2, the HiScoreBgMap and HiScoreImg bitmaps, then wait up to $50 * 4
									;frames or a button (waitx)
	move.l	#vb2,(VBint).w
	bclr	#df32c,(disflags).w
	move.w	#5,(Map3col1).w
	move.w	#$A000,(VmMAP2).w
	move.w	#7,(Map2col).w
	move.w	#$C000,(VmMAP1).w
	move.w	#7,(Map1col).w
	move.w	#$F000,(VmMAP3).w
	move.w	#$F800,(VSPRITES).w
	move.w	#$FC00,(VSCRLPM).w
	jsr	(forceblack).l
	movea.w	#(palfadenew-M68K_RAM),a0
	moveq	#$1F,d1
.loop
	clr.l	(a0)+
	dbf	d1,.loop
	jsr	(setVram_0).l
	jsr	(printz).l
	String	CC_Font2Pri,$0E,$03
	movea.l	#HiScoreBgMap,a2
	movea.l	a2,a0
	movea.l	a2,a1
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	clr.w	d4
	moveq	#$F,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	CC_Font2Pri,$10,$10
	movea.l	#HiScoreImg,a2
	movea.l	a2,a0
	movea.l	a2,a1
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	jsr	(dobitmap).l
	move.w	#$18,(palcount).w
	move	#$2500,sr
	move.w	#$50,(seed).w
.loop2
	moveq	#4,d0
	jsr	(waitx).l
	tst.w	d1
	bne.w	.0
	subq.w	#1,(seed).w
	bpl.s	.loop2
.0
	jsr	(forceblack).l
	move	#$2700,sr
	rts
	movea.l	#tmstruct,a2
	cmp.w	Xvel(a2),d2
	beq.w	.1
	movea.l	#AwShots,a2
.1
	rts
