;	Load the small font and the big fonts.

LoadSmallFont						;Load the small font tiles (SmallFontMap+8) at char d4 (smallfontchars)
									;with the remap below; d4 = next char
	move.w	d4,(smallfontchars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$A1,$23,$2F,$AB,$D1,$AA,$CD,$EF	;remap table
	rts

LoadBigFonts						;Load the fonts at char d4: BigFontMap+8 (bigfont1chars), then the big
									;font BigFontMap3+8 (BigFontchars); d4 =
									;next char
	move.w	d4,(bigfont1chars).w
	movea.l	#BigFontMap+8,a2
	jsr	(DecompressGraphicsPlain).l
	move.w	d4,(BigFontchars).w
	movea.l	#BigFontMap3+8,a2
	jmp	DecompressGraphicsPlain

TurnGoalieFromNet					;A pad goalie in his crease facing back at his net turns one step to the
									;side
	btst	#pfgoal,pflags(a3)
	beq.w	.1
	cmpi.w	#3,facedir(a3)
	beq.w	.loop
	cmpi.w	#5,facedir(a3)
	beq.w	.loop2
	bra.w	.2
.loop
	subq.w	#1,facedir(a3)
	bra.w	.2
.loop2
	addq.w	#1,facedir(a3)
	bra.w	.2
.1
	cmpi.w	#7,facedir(a3)
	beq.s	.loop
	cmpi.w	#1,facedir(a3)
	beq.s	.loop2
.2
	rts
