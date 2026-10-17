;	The one-timer. The shot height, the pass, the target and the animation.

puckvzadj	;Set puckvz for a top shelf shot from the distance to the goal line ($11E) over puckvy, at most $7FFF.
	;Gravity skillspeed (skillspeedpal with PalMode). Called from doshot
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(pucky).w,d0
	bpl.w	.0
	neg.w	d0
.0
	subi.w	#$11E,d0
	bpl.w	.1
	neg.w	d0
.1
	swap	d0
	andi.l	#$FFFF0000,d0
	move.w	(puckvy).w,d1
	beq.w	.7
	bpl.w	.2
	neg.w	d1
.2
	move.w	(skillspeed).w,d2
	tst.w	(PalMode).w
	beq.w	.3
	move.w	(skillspeedpal).w,d2
.3
	divu.w	d1,d0
	andi.l	#$FFFF,d0
	divu.w	d2,d0
	tst.w	d0
	bne.w	.4
	move.w	#1,d0
.4
	move.l	#$A0000,d1
	move.w	d0,d3
	mulu.w	d2,d0
	divu.w	d0,d1
	move.w	d2,d4
	add.w	d2,d2
	add.w	d4,d2
	mulu.w	d3,d2
	cmp.l	#$7FFF,d2
	blt.w	.5
	move.w	#$7FFF,d2
.5
	add.w	d2,d1
	tst.w	d1
	bpl.w	.6
	move.w	#$7FFF,d1
.6
	move.w	d1,(puckvz).w
.7
	movem.l	(sp)+,d0-d7/a0-a6
	rts

OneTimerPass	;One-timer pass: puckvz = sqrt(12 * onetimerheight), then puckvx / puckvy toward the target onetimertargetx /
	;onetimertargety in puckvz / 3 frames
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$C,d0
	move.w	(onetimerheight).w,d1
	mulu.w	d1,d0
	swap	d0
	andi.l	#$FFFF0000,d0
	jsr	(sroot).l
	move.w	d0,(puckvz).w
	ext.l	d0
	move.w	#3,d4
	divu.w	d4,d0
	clr.l	d1
	move.w	(onetimertargetx).w,d1
	sub.w	(puckx).w,d1
	swap	d1
	tst.w	d0
	bne.w	.0
	move.w	#1,d0
.0
	divs.w	d0,d1
	move.w	d1,(puckvx).w
	clr.l	d1
	move.w	(onetimertargety).w,d1
	sub.w	(pucky).w,d1
	swap	d1
	divs.w	d0,d1
	move.w	d1,(puckvy).w
	movea.l	#puckx,a3
	move.w	(puckvz).w,d0
	jsr	(puckflip).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

OneTimerTarget	;One-timer pass target for receiver a3: an offset by facing from OneTimerNearTbl / OneTimerFarTbl (skater,
	;near or far from the goal) or OneTimerGoalieTbl, plus a random 0-9 on each axis
	movem.l	d0-d7/a0-a6,-(sp)
	bclr	#2,(sflags6).w
	tst.w	$34(a3)
	bne.w	.0
	movea.l	#OneTimerGoalieTbl,a0
	bra.w	.2
.0
	move.w	Ypos(a3),d0
	btst	#7,pflags(a3)
	bne.w	.1
	neg.w	d0
.1
	bset	#2,(sflags6).w
	movea.l	#OneTimerNearTbl,a0
	cmp.w	#$76,d0
	blt.w	.2
	movea.l	#OneTimerFarTbl,a0
	bclr	#2,(sflags6).w
.2
	move.w	$54(a3),d0
	btst	#7,pflags(a3)
	bne.w	.3
	addq.w	#4,d0
	andi.w	#7,d0
.3
	asl.w	#2,d0
	move.w	(a0,d0.w),d1
	move.w	2(a0,d0.w),d2
	cmpa.l	#OneTimerFarTbl,a0
	bne.w	.6
	move.w	Ypos(a3),d0
	bpl.w	.4
	neg.w	d0
.4
	cmp.w	#$A8,d0
	blt.w	.6
	move.w	(a3),d0
	bpl.w	.5
	neg.w	d0
.5
	cmp.w	#$37,d0
	bgt.w	.6
	move.w	#$119,d2
.6
	btst	#7,pflags(a3)
	bne.w	.7
	neg.w	d1
	neg.w	d2
.7
	move.w	#$A,d0
	jsr	(randomd0).l
	add.w	d0,d1
	move.w	#$A,d0
	jsr	(randomd0).l
	add.w	d0,d2
	move.w	d1,(onetimertargetx).w
	tst.w	$34(a3)
	beq.w	.9
	sub.w	(a3),d1
	bmi.w	.8
	subi.w	#$3C,d1
	bpl.w	.9
	neg.w	d1
	add.w	d1,(onetimertargetx).w
	bra.w	.9
.8
	addi.w	#$3C,d1
	bmi.w	.9
	sub.w	d1,(onetimertargetx).w
.9
	move.w	d2,(onetimertargety).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

OneTimerNearTbl	;OneTimerTarget target offsets (x, y) by facing, receiver near the goal
	dc.w	110,216,110,216,110,216,110,216
	dc.w	-110,216,-110,216,-110,216,-110,216

OneTimerFarTbl	;OneTimerTarget target offsets (x, y) by facing, receiver far from the goal
	dc.w	-5,197,-5,197,-5,197,-5,197
	dc.w	-5,197,-5,197,-5,197,-5,197

OneTimerGoalieTbl	;OneTimerTarget target offsets (x, y) by facing, goalie
	dc.w	-5,-31,50,-31,50,-31,50,-31
	dc.w	-5,-31,-50,-31,-50,-31,-50,-31

assonetimer	;Assignment $23 (asstab), player a3 shooting a one-timer: take control of him.
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$AB,$00,$01,$00,$62,$67,$00,$00,$AE,$08,$EB,$00,$03,$00,$64
	dc.b	$66,$00,$00,$A4,$31,$FC,$00,$2D,$DC,$F4,$08,$B8,$00,$00,$BF,$B0
	dc.b	$08,$B8,$00,$05,$C3,$4C,$42,$78,$BF,$B0,$42,$78,$BF,$A8,$50,$F8
	dc.b	$BF,$12,$48,$E7,$FF,$FE,$30,$2B,$00,$52,$31,$C0,$BF,$A6,$08,$2B
	dc.b	$00,$03,$00,$62,$66,$00,$00,$4A,$4A,$78,$DC,$CC,$6B,$00,$00,$42
	dc.b	$67,$00,$00,$20,$0C,$78,$00,$02,$DC,$CC,$67,$00,$00,$20,$0C,$78
	dc.b	$00,$04,$DC,$CC,$67,$00,$00,$20,$4E,$B9,$00,$01,$6C,$74,$60,$00
	dc.b	$00,$20,$4E,$B9,$00,$01,$6C,$52,$60,$00,$00,$16,$4E,$B9,$00,$01
	dc.b	$6C,$5C,$60,$00,$00,$0C,$4E,$B9,$00,$01,$6C,$68,$60,$00,$00,$02
	dc.b	$3F,$00,$61,$00,$02,$14,$42,$6B,$00,$5A,$4E,$B9,$00,$01,$A6,$14
	dc.b	$08,$EB,$00,$05,$00,$62,$08,$EB,$00,$01,$00,$63,$30,$1F,$4C,$DF
	dc.b	$7F,$FF,$60,$00,$01,$F2,$08,$38,$00,$00,$BF,$B0,$66,$00,$00,$52
	dc.b	$48,$A7,$C0,$00,$30,$38,$B7,$5E,$90,$53,$B0,$7C,$00,$3C,$6E,$00
	dc.b	$00,$0A,$B0,$7C,$FF,$C4,$6E,$00,$00,$14,$32,$38,$B7,$86,$B3,$40
	dc.b	$6B,$00,$00,$0A,$4C,$9F,$00,$03,$60,$00,$00,$2E,$30,$38,$B7,$72
	dc.b	$90,$6B,$00,$14,$B0,$7C,$00,$3C,$6E,$00,$00,$0A,$B0,$7C,$FF,$C4
	dc.b	$6E,$00,$00,$0A,$32,$38,$B7,$88,$B3,$40,$6A,$D8,$4C,$9F,$00,$03
	dc.b	$4A,$78,$B7,$BE,$6B,$00,$00,$0C,$08,$B8,$00,$07,$C3,$4C,$60,$00
	dc.b	$01,$80,$08,$38,$00,$00,$C3,$38,$66,$00,$01,$76,$48,$E7,$C0,$00
	dc.b	$08,$38,$00,$03,$C3,$50,$66,$00,$01,$2A,$0C,$6B,$00,$10,$00,$5A
	dc.b	$6C,$00,$00,$9A,$08,$38,$00,$02,$BF,$B0,$66,$00,$00,$90,$30,$13
	dc.b	$32,$38,$B7,$5E,$90,$41,$6A,$00,$00,$04,$44,$40,$32,$2B,$00,$14
	dc.b	$34,$38,$B7,$72,$92,$42,$6A,$00,$00,$04,$44,$41,$34,$38,$B7,$86
	dc.b	$67,$00,$00,$08,$B2,$40,$6F,$00,$00,$08,$34,$38,$B7,$88,$30,$01
	dc.b	$48,$40,$02,$80,$FF,$FF,$00,$00,$4A,$42,$6A,$00,$00,$04,$44,$42
	dc.b	$32,$38,$D2,$84,$4A,$78,$D2,$80,$67,$00,$00,$06,$32,$38,$D2,$86
	dc.b	$4A,$42,$66,$00,$00,$06,$34,$3C,$00,$01,$80,$C2,$02,$80,$00,$00
	dc.b	$FF,$FF,$80,$C1,$34,$2B,$00,$5A,$E4,$4A,$5D,$42,$44,$42,$E5,$42
	dc.b	$B0,$42,$6E,$00,$00,$10,$44,$6B,$00,$5A,$06,$6B,$00,$18,$00,$5A
	dc.b	$60,$00,$00,$7A,$DF,$78,$BF,$A8,$60,$00,$00,$28,$08,$F8,$00,$02
	dc.b	$BF,$B0,$08,$38,$00,$01,$BF,$B0,$66,$00,$00,$18,$0C,$6B,$00,$18
	dc.b	$00,$5A,$66,$00,$00,$0E,$06,$6B,$00,$30,$00,$5C,$08,$F8,$00,$01
	dc.b	$BF,$B0,$08,$38,$00,$01,$BF,$B0,$67,$00,$00,$1E,$0C,$6B,$00,$18
	dc.b	$00,$5A,$6F,$00,$00,$14,$08,$38,$00,$00,$BF,$B0,$66,$00,$00,$0A
	dc.b	$4C,$DF,$00,$03,$60,$00,$00,$7A,$08,$38,$00,$00,$BF,$B0,$67,$00
	dc.b	$00,$1C,$0C,$6B,$00,$18,$00,$5A,$66,$00,$00,$12,$0C,$6B,$00,$01
	dc.b	$00,$5C,$6F,$00,$00,$08,$37,$7C,$00,$01,$00,$5C,$08,$2B,$00,$01
	dc.b	$00,$63,$66,$00,$00,$0A,$4C,$DF,$00,$03,$60,$00,$00,$3A,$30,$2B
	dc.b	$00,$5A,$4C,$DF,$00,$03,$08,$38,$00,$00,$BF,$B0,$67,$00,$00,$0C
	dc.b	$08,$AB,$00,$05,$00,$62,$60,$00,$00,$1E,$4E,$71,$08,$38,$00,$03
	dc.b	$C3,$50,$67,$00,$00,$12,$4A,$78,$DC,$F4,$6B,$00,$00,$0A,$53,$78
	dc.b	$DC,$F4,$60,$00,$00,$12,$08,$2B,$00,$01,$00,$63,$66,$00,$00,$08
	dc.b	$4E,$B9,$00,$1D,$93,$76,$4E,$75

setonetimeranim	;The one-timer animation: d1 = $856 or $11BA from the angle to the goal (vtoa, CheckOneTimerFacing).
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$38,$00,$03,$C3,$50,$67,$00,$00,$0A,$32,$3C,$08,$56,$60,$00
	dc.b	$00,$3A,$32,$3C,$11,$BA,$48,$A7,$C0,$00,$30,$13,$44,$40,$32,$3C
	dc.b	$01,$1E,$08,$2B,$00,$07,$00,$62,$66,$00,$00,$04,$44,$41,$92,$6B
	dc.b	$00,$14,$4E,$B9,$00,$01,$A3,$EE,$4E,$B9,$00,$1D,$6D,$10,$4C,$9F
	dc.b	$00,$03,$67,$00,$00,$06,$32,$3C,$0F,$B6,$4E,$75
