;	The puck flip and the assignment exits. vtoa turns a vector into a direction,
;	and GetHot reads a hot spot.

puckflip	;Flip the puck
	andi.w	#1,d0
	eor.w	d0,facedir(a3)	;facedir
	andi.w	#3,facedir(a3)
	st	SPAcnt(a3)	;SPAcnt
	move.w	#$2BBA,d1
	bra.w	SetSPA

puckshadow	;asstab entry: the puck shadow.
	;Code the listing does not decode: kept as bytes
	dc.b	$0C,$6B,$2B,$88,$00,$58,$67,$00,$00,$2C,$0C,$6B,$02,$99,$00,$06
	dc.b	$66,$00,$00,$24,$36,$AB,$FF,$80,$37,$6B,$FF,$94,$00,$14,$42,$6B
	dc.b	$00,$18,$70,$14,$08,$38,$00,$07,$C3,$3A,$67,$00,$00,$04,$70,$00
	dc.b	$52,$73,$00,$00,$4E,$75,$4A,$6B,$00,$06,$67,$00,$58,$B6,$42,$53
	dc.b	$37,$7C,$01,$4B,$00,$14,$37,$7C,$00,$0E,$00,$18,$4A,$6B,$FF,$94
	dc.b	$6A,$00,$00,$22,$37,$7C,$80,$00,$00,$04,$08,$38,$00,$00,$C3,$5A
	dc.b	$67,$00,$00,$08,$37,$7C,$00,$00,$00,$04,$37,$7C,$FE,$B1,$00,$14
	dc.b	$53,$6B,$00,$18,$4E,$75

findpc	;Where and when the puck crosses each goal line (puckcross).
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$F8,$60,$32,$7C,$BF,$1A,$32,$3C,$00,$96,$38,$3C,$01,$1E
	dc.b	$61,$00,$00,$0E,$44,$44,$61,$00,$00,$08,$4C,$DF,$06,$1F,$4E,$75
	dc.b	$30,$04,$90,$78,$B7,$72,$4A,$78,$B7,$88,$67,$00,$00,$4C,$34,$00
	dc.b	$48,$42,$42,$42,$E8,$82,$85,$F8,$B7,$88,$6B,$00,$00,$3C,$33,$42
	dc.b	$00,$02,$C1,$F8,$B7,$86,$81,$F8,$B7,$88,$69,$00,$00,$2C,$D0,$78
	dc.b	$B7,$5E,$B0,$41,$6D,$00,$00,$0A,$44,$40,$D0,$41,$D0,$41,$D0,$41
	dc.b	$44,$41,$B0,$41,$6E,$00,$00,$0A,$44,$40,$D0,$41,$D0,$41,$D0,$41
	dc.b	$44,$41,$32,$80,$60,$00,$00,$08,$33,$7C,$FF,$FF,$00,$02,$58,$49
	dc.b	$4E,$75

skateto	;Skate a3 to d0 / d1, a0 = an extra collision routine (EvadePC); every 12 frames, then doplayeracc
	;Code the listing does not decode: kept as bytes
	dc.b	$9F,$2B,$00,$42,$6A,$00,$00,$B0,$06,$2B,$00,$0C,$00,$42,$61,$00
	dc.b	$00,$B0,$48,$A7,$C0,$00,$30,$2B,$00,$28,$E0,$40,$44,$40,$D0,$5F
	dc.b	$90,$53,$32,$2B,$00,$2A,$E0,$41,$44,$41,$D2,$5F,$92,$6B,$00,$14
	dc.b	$B0,$7C,$00,$0C,$6E,$00,$00,$20,$B0,$7C,$FF,$F4,$6D,$00,$00,$18
	dc.b	$B2,$7C,$00,$0C,$6E,$00,$00,$10,$B2,$7C,$FF,$F4,$6D,$00,$00,$08
	dc.b	$70,$09,$60,$00,$00,$06,$61,$00,$03,$46,$4E,$90,$17,$40,$00,$43
	dc.b	$B0,$7C,$00,$07,$6F,$00,$00,$50,$30,$2B,$00,$28,$80,$6B,$00,$2A
	dc.b	$66,$00,$00,$44,$30,$38,$B7,$5E,$32,$38,$B7,$72,$08,$38,$00,$00
	dc.b	$B7,$C1,$67,$00,$00,$0A,$30,$38,$BF,$DC,$32,$38,$BF,$DE,$90,$53
	dc.b	$92,$6B,$00,$14,$61,$00,$03,$08,$90,$6B,$00,$54,$67,$00,$00,$18
	dc.b	$44,$40,$02,$40,$00,$04,$E2,$48,$53,$40,$D0,$6B,$00,$54,$02,$40
	dc.b	$00,$07,$37,$40,$00,$54,$42,$40,$10,$2B,$00,$43,$60,$00,$05,$1C
	dc.b	$42,$78,$BF,$EA,$42,$78,$BF,$EC,$4A,$6B,$00,$34,$67,$00,$57,$2C
	dc.b	$34,$13,$B1,$42,$6A,$00,$00,$80,$34,$01,$94,$6B,$00,$14,$36,$13
	dc.b	$C5,$C3,$96,$40,$85,$C3,$D4,$6B,$00,$14,$B4,$7C,$01,$37,$6E,$00
	dc.b	$00,$66,$B4,$7C,$00,$F1,$6D,$00,$00,$2A,$36,$3C,$01,$5A,$B4,$7C
	dc.b	$01,$14,$6E,$00,$00,$14,$6D,$00,$00,$0C,$0C,$6B,$01,$14,$00,$14
	dc.b	$6E,$00,$00,$06,$36,$3C,$00,$CE,$96,$42,$31,$C3,$BF,$EC,$60,$00
	dc.b	$00,$36,$B4,$7C,$FF,$0F,$6E,$00,$00,$2E,$B4,$7C,$FE,$C9,$6D,$00
	dc.b	$00,$26,$36,$3C,$FF,$32,$B4,$7C,$FE,$EC,$6E,$00,$00,$14,$6D,$00
	dc.b	$00,$0C,$0C,$6B,$FE,$EC,$00,$14,$6E,$00,$00,$06,$36,$3C,$FE,$A6
	dc.b	$96,$42,$31,$C3,$BF,$EC,$36,$01,$04,$43,$01,$14,$34,$2B,$00,$14
	dc.b	$04,$42,$01,$14,$61,$00,$00,$1E,$36,$01,$06,$43,$01,$14,$34,$2B
	dc.b	$00,$14,$06,$42,$01,$14,$61,$00,$00,$0C,$D0,$78,$BF,$EA,$D2,$78
	dc.b	$BF,$EC,$4E,$75,$38,$03,$B5,$44,$6A,$00,$56,$70,$38,$00,$98,$53
	dc.b	$C9,$C2,$94,$43,$89,$C2,$D8,$53,$B8,$7C,$00,$50,$6E,$00,$56,$5C
	dc.b	$B8,$7C,$FF,$B0,$6D,$00,$56,$54,$76,$50,$4A,$44,$66,$00,$00,$04
	dc.b	$4A,$53,$6A,$00,$00,$04,$44,$43,$96,$44,$31,$C3,$BF,$EA,$4E,$75
	dc.b	$08,$2B,$00,$04,$00,$62,$66,$00,$00,$18,$30,$38,$B7,$86,$E0,$40
	dc.b	$D0,$78,$B7,$5E,$32,$38,$B7,$88,$E0,$41,$D2,$78,$B7,$72,$4E,$75
	dc.b	$10,$38,$B7,$86,$E2,$00,$48,$80,$D0,$78,$B7,$5E,$12,$38,$B7,$88
	dc.b	$E2,$01,$48,$81,$D2,$78,$B7,$72,$4E,$75,$4A,$6B,$00,$34,$66,$00
	dc.b	$00,$04,$4E,$71,$61,$BA,$9F,$2B,$00,$42,$6A,$00,$01,$02,$06,$2B
	dc.b	$00,$0A,$00,$42,$61,$00,$FE,$AA,$48,$A7,$C0,$00,$2F,$0B,$61,$00
	dc.b	$01,$E8,$44,$00,$44,$01,$90,$2B,$00,$28,$48,$80,$D0,$5F,$90,$53
	dc.b	$92,$2B,$00,$2A,$48,$81,$D2,$5F,$92,$6B,$00,$14,$61,$00,$01,$60
	dc.b	$17,$40,$00,$43,$4A,$6B,$00,$34,$67,$00,$00,$C4,$30,$38,$B7,$86
	dc.b	$32,$38,$B7,$88,$61,$00,$01,$48,$0A,$40,$00,$04,$B0,$6B,$00,$54
	dc.b	$67,$00,$00,$AC,$30,$38,$B7,$5E,$90,$53,$32,$38,$B7,$72,$92,$6B
	dc.b	$00,$14,$48,$A7,$C0,$00,$61,$00,$01,$26,$B0,$6B,$00,$54,$4C,$9F
	dc.b	$00,$03,$66,$00,$00,$8A,$C1,$C0,$C3,$C1,$D0,$81,$B0,$BC,$00,$00
	dc.b	$04,$00,$63,$00,$00,$7A,$4A,$6B,$00,$34,$67,$00,$00,$68,$48,$A7
	dc.b	$80,$00,$30,$2B,$00,$14,$08,$2B,$00,$07,$00,$62,$67,$00,$00,$04
	dc.b	$44,$40,$B0,$7C,$00,$76,$6D,$00,$00,$20,$30,$2B,$00,$2A,$08,$2B
	dc.b	$00,$07,$00,$62,$67,$00,$00,$04,$44,$40,$4A,$40,$6A,$00,$00,$0A
	dc.b	$4C,$9F,$00,$01,$60,$00,$00,$2E,$30,$3C,$00,$64,$61,$00,$0D,$78
	dc.b	$B0,$7C,$00,$4B,$4C,$9F,$00,$01,$6D,$00,$00,$1A,$B0,$BC,$00,$00
	dc.b	$09,$C4,$63,$00,$00,$10,$08,$2B,$00,$05,$00,$62,$66,$00,$00,$06
	dc.b	$61,$00,$C5,$9A,$B0,$BC,$00,$00,$05,$A4,$63,$00,$C9,$26,$10,$2B
	dc.b	$00,$43,$48,$80,$B0,$7C,$00,$07,$6E,$00,$00,$16,$B0,$6B,$00,$54
	dc.b	$67,$00,$00,$0E,$4A,$6B,$00,$34,$67,$00,$00,$06,$61,$00,$00,$06
	dc.b	$60,$00,$02,$A8

FacePuck	;Turn a3's facedir one step toward the puck (vtoa); d0 / d1 kept
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$A7,$C0,$00,$30,$38,$B7,$5E,$32,$38,$B7,$72,$90,$53,$92,$6B
	dc.b	$00,$14,$61,$00,$00,$56,$90,$6B,$00,$54,$67,$00,$00,$18,$44,$40
	dc.b	$02,$40,$00,$04,$E2,$48,$53,$40,$D0,$6B,$00,$54,$02,$40,$00,$07
	dc.b	$37,$40,$00,$54,$4C,$9F,$00,$03,$4E,$75

assexit	;Exit the current assignment of player a3
	addq.w	#1,$36(a3)	;add 1 to current assignment index
	andi.w	#7,$36(a3)	;mask passing first 3 bits
	bset	#1,$62(a3)	;signal next assignment
	rts

assinsert	;Insert assignment d0 on player a3
	subq.w	#1,$36(a3)	;$36 = assnum
	andi.w	#7,$36(a3)

assreplace	;Replace the current assignment of player a3 with d0
	move.l	d1,-(sp)	;push on stack
	move.w	$36(a3),d1	;$36 = assnum
	move.b	d0,$38(a3,d1.w)	;replace current assignment with d0 on asslist
	bset	#1,$62(a3)	;set flag to start new assignment
	move.l	(sp)+,d1	;pop on stack
	rts

vtoa	;d0/d1 = vector: return d0 = direction 0-7 (8 for no vector) through .dt
	movem.l	d2/a0,-(sp)
	move.w	d0,d2
	or.w	d1,d2
	beq.w	.nodir
	clr.w	d2
	tst.w	d0
	bpl.w	.0
	neg.w	d0
	bset	#0,d2
.0
	tst.w	d1
	bpl.w	.1
	neg.w	d1
	bset	#1,d2
.1
	asl.w	#1,d1
	cmp.w	d1,d0
	bhi.w	.2
	bset	#2,d2
.2
	lsr.w	#1,d1
	asl.w	#1,d0
	cmp.w	d0,d1
	bhi.w	.3
	bset	#3,d2
.3
	movea.l	#.dt,a0
	clr.w	d0
	move.b	(a0,d2.w),d0
	movem.l	(sp)+,d2/a0
	rts
.nodir
	moveq	#8,d0
	movem.l	(sp)+,d2/a0
	rts
.dt
	dc.b	1,7,3,5,0,0,4,4,2,6,2,6,1,7,3,5

GetHot	;Push long address of structure to get hot spot from; hot spot x/y returned in d0/d1 (HotList by
	;frame, flipped with the attribute)
	movem.l	a0-a1,-(sp)
	movea.l	$C(sp),a0	;move stored address before sub routine call into a0
	clr.w	d0	;clear d0
	clr.w	d1	;clear d1
	tst.w	frame(a0)
	ble.w	.ex
	movea.l	#HotList,a1
	move.w	frame(a0),d0
	add.w	d0,d0	;double d0
	move.b	1(a1,d0.w),d1	;SprStrHot Y byte
	ext.w	d1	;extend d1
	move.b	(a1,d0.w),d0
	ext.w	d0	;extend d0
	btst	#3,attribute(a0)
	beq.w	.0
	neg.w	d0	;negate d0 (flip)
.0
	btst	#4,attribute(a0)
	bne.w	.1
	neg.w	d1	;ngate d1 (x now)
.1
	btst	#7,(sflags).w
	beq.w	.ex
	exg	d0,d1
	neg.w	d1	;ngate d1 (x now)
.ex
	movem.l	(sp)+,a0-a1
	move.l	(sp)+,(sp)
	rts

GetHot2a	;Push a struct: d0 / d1 = rink x / y of its first HotList2 hot spot for its frame (0 / 0 with no frame)
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$00,$C0,$20,$6F,$00,$0C,$42,$40,$42,$41,$4A,$68,$00,$06
	dc.b	$6F,$00,$00,$58,$22,$7C,$00,$13,$A2,$12,$30,$28,$00,$06,$32,$19
	dc.b	$53,$41,$90,$41,$6B,$00,$00,$4C,$E5,$40,$D0,$68,$00,$06,$D0,$68
	dc.b	$00,$06,$12,$31,$00,$01,$48,$81,$10,$31,$00,$00,$48,$80,$08,$28
	dc.b	$00,$03,$00,$04,$67,$00,$00,$04,$44,$40,$08,$28,$00,$04,$00,$04
	dc.b	$66,$00,$00,$04,$44,$41,$08,$38,$00,$07,$C3,$3A,$67,$00,$00,$06
	dc.b	$C1,$41,$44,$41,$D2,$68,$00,$14,$D0,$50,$4C,$DF,$03,$00,$2E,$9F
	dc.b	$4E,$75,$4E,$71,$60,$FC

GetHot2b	;Push a struct: d0 / d1 = rink x / y of its second HotList2 hot spot for its frame
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$00,$C0,$20,$6F,$00,$0C,$42,$40,$42,$41,$4A,$68,$00,$06
	dc.b	$6F,$00,$00,$58,$22,$7C,$00,$13,$A2,$12,$30,$28,$00,$06,$32,$19
	dc.b	$53,$41,$90,$41,$6B,$00,$00,$4C,$E5,$40,$D0,$68,$00,$06,$D0,$68
	dc.b	$00,$06,$12,$31,$00,$03,$48,$81,$10,$31,$00,$02,$48,$80,$08,$28
	dc.b	$00,$03,$00,$04,$67,$00,$00,$04,$44,$40,$08,$28,$00,$04,$00,$04
	dc.b	$66,$00,$00,$04,$44,$41,$08,$38,$00,$07,$C3,$3A,$67,$00,$00,$06
	dc.b	$C1,$41,$44,$41,$D2,$68,$00,$14,$D0,$50,$4C,$DF,$03,$00,$2E,$9F
	dc.b	$4E,$75,$4E,$71,$60,$FC

GetHot2c	;Push a struct: d0 / d1 = rink x / y of its third HotList2 hot spot for its frame
	;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$00,$C0,$20,$6F,$00,$0C,$42,$40,$42,$41,$4A,$68,$00,$06
	dc.b	$6F,$00,$00,$58,$22,$7C,$00,$13,$A2,$12,$30,$28,$00,$06,$32,$19
	dc.b	$53,$41,$90,$41,$6B,$00,$00,$4C,$E5,$40,$D0,$68,$00,$06,$D0,$68
	dc.b	$00,$06,$12,$31,$00,$05,$48,$81,$10,$31,$00,$04,$48,$80,$08,$28
	dc.b	$00,$03,$00,$04,$67,$00,$00,$04,$44,$40,$08,$28,$00,$04,$00,$04
	dc.b	$66,$00,$00,$04,$44,$41,$08,$38,$00,$07,$C3,$3A,$67,$00,$00,$06
	dc.b	$C1,$41,$44,$41,$D2,$68,$00,$14,$D0,$50,$4C,$DF,$03,$00,$2E,$9F
	dc.b	$4E,$75,$4E,$71,$60,$FC
