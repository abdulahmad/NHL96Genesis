;	Load the small font and the big fonts.

LoadSmallFont	;Load the small font tiles (SmallFontMap+8) at char d4 (smallfontchars) with the remap below; d4 = next char
	move.w	d4,(smallfontchars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$A1,$23,$2F,$AB,$D1,$AA,$CD,$EF	;remap table
	rts

LoadBigFonts	;Load the fonts at char d4: BigFontMap+8 (bigfont1chars), then the big font BigFontMap3+8 (BigFontChars); d4 =
	;next char
	move.w	d4,(bigfont1chars).w
	movea.l	#BigFontMap+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap3+8,a2
	jmp	DecompressGraphicsPlain

TurnGoalieFromNet	;A pad goalie in his crease facing back at his net turns one step to the side
	;Code the listing does not decode: kept as bytes
	dc.b	$08,$2B,$00,$07,$00,$62,$67,$00,$00,$2A,$0C,$6B,$00,$03,$00,$54
	dc.b	$67,$00,$00,$10,$0C,$6B,$00,$05,$00,$54,$67,$00,$00,$0E,$60,$00
	dc.b	$00,$22,$53,$6B,$00,$54,$60,$00,$00,$1A,$52,$6B,$00,$54,$60,$00
	dc.b	$00,$12,$0C,$6B,$00,$07,$00,$54,$67,$E8,$0C,$6B,$00,$01,$00,$54
	dc.b	$67,$E8,$4E,$75
