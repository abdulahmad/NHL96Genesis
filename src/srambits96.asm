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
	;Not decoded in the listing and not referenced from it: kept as bytes
	dc.b	$48,$E7,$BB,$6E,$3E,$03,$48,$C5,$60,$00,$00,$5A,$28,$7C,$00,$20
	dc.b	$00,$00,$36,$01,$E6,$4B,$D6,$43,$38,$01,$02,$44,$00,$07,$D8,$C3
	dc.b	$76,$FF,$3C,$3C,$00,$20,$9C,$42,$ED,$AB,$E8,$AB,$10,$2C,$00,$01
	dc.b	$E1,$48,$10,$2C,$00,$03,$48,$40,$10,$2C,$00,$05,$E1,$48,$10,$2C
	dc.b	$00,$07,$C0,$83,$E9,$A8,$EC,$A8,$BE,$79,$FF,$FF,$DD,$C0,$6C,$00
	dc.b	$00,$04,$42,$40,$4A,$40,$67,$00,$00,$08,$36,$C5,$52,$52,$30,$C0
	dc.b	$52,$85,$D2,$82,$51,$CF,$FF,$A6,$4C,$DF,$76,$DD,$4E,$75,$48,$E7
	dc.b	$BB,$6E,$3E,$03,$48,$C5,$60,$00,$00,$CA,$28,$7C,$00,$20,$00,$00
	dc.b	$36,$01,$E6,$4B,$D6,$43,$38,$01,$02,$44,$00,$07,$D8,$C3,$76,$FF
	dc.b	$3C,$3C,$00,$20,$9C,$42,$ED,$AB,$E8,$AB,$10,$2C,$00,$01,$E1,$48
	dc.b	$10,$2C,$00,$03,$48,$40,$10,$2C,$00,$05,$E1,$48,$10,$2C,$00,$07
	dc.b	$C0,$83,$E9,$A8,$EC,$A8,$BE,$79,$FF,$FF,$DD,$C0,$6C,$00,$00,$04
	dc.b	$42,$40,$48,$E7,$C0,$00,$08,$39,$00,$02,$FF,$FF,$DD,$80,$67,$00
	dc.b	$00,$0C,$06,$81,$00,$00,$0F,$00,$60,$00,$00,$08,$06,$81,$00,$00
	dc.b	$1D,$40,$28,$7C,$00,$20,$00,$00,$36,$01,$E6,$4B,$D6,$43,$38,$01
	dc.b	$02,$44,$00,$07,$D8,$C3,$76,$FF,$3C,$3C,$00,$20,$9C,$42,$ED,$AB
	dc.b	$E8,$AB,$10,$2C,$00,$01,$E1,$48,$10,$2C,$00,$03,$48,$40,$10,$2C
	dc.b	$00,$05,$E1,$48,$10,$2C,$00,$07,$C0,$83,$E9,$A8,$EC,$A8,$2C,$00
	dc.b	$BE,$79,$FF,$FF,$DD,$C0,$6C,$00,$00,$04,$42,$40,$4C,$DF,$00,$03
	dc.b	$D0,$46,$4A,$40,$67,$00,$00,$08,$36,$C5,$52,$52,$30,$C0,$52,$85
	dc.b	$D2,$82,$51,$CF,$FF,$36,$4C,$DF,$76,$DD,$4E,$75,$48,$E7,$B3,$6E
	dc.b	$3E,$03,$48,$C5,$2F,$04,$2F,$06,$60,$00,$00,$C2,$74,$0E,$28,$7C
	dc.b	$00,$20,$00,$00,$36,$01,$E6,$4B,$D6,$43,$38,$01,$02,$44,$00,$07
	dc.b	$D8,$C3,$76,$FF,$3C,$3C,$00,$20,$9C,$42,$ED,$AB,$E8,$AB,$10,$2C
	dc.b	$00,$01,$E1,$48,$10,$2C,$00,$03,$48,$40,$10,$2C,$00,$05,$E1,$48
	dc.b	$10,$2C,$00,$07,$C0,$83,$E9,$A8,$EC,$A8,$24,$17,$26,$2F,$00,$04
	dc.b	$48,$E7,$C0,$00,$22,$03,$28,$7C,$00,$20,$00,$00,$36,$01,$E6,$4B
	dc.b	$D6,$43,$38,$01,$02,$44,$00,$07,$D8,$C3,$76,$FF,$3C,$3C,$00,$20
	dc.b	$9C,$42,$ED,$AB,$E8,$AB,$10,$2C,$00,$01,$E1,$48,$10,$2C,$00,$03
	dc.b	$48,$40,$10,$2C,$00,$05,$E1,$48,$10,$2C,$00,$07,$C0,$83,$E9,$A8
	dc.b	$EC,$A8,$2C,$00,$4C,$DF,$00,$03,$4A,$46,$67,$00,$00,$22,$CC,$FC
	dc.b	$00,$0A,$8C,$FC,$00,$3C,$69,$00,$00,$16,$BC,$7C,$00,$0A,$6D,$00
	dc.b	$00,$0E,$C0,$FC,$03,$E8,$80,$C6,$36,$C5,$52,$52,$30,$C0,$52,$85
	dc.b	$06,$81,$00,$00,$00,$0E,$26,$17,$D7,$AF,$00,$04,$51,$CF,$FF,$3E
	dc.b	$58,$4F,$28,$1F,$4C,$DF,$76,$CD,$4E,$75

