;	The hot and cold table and the attribute calculation.

Create_HotCold_Table				;Fill the hot / cold table at $1A4 of team struct a0 with random values
	movem.l	d0-d7,-(sp)
	move.w	#$1BF,d1				;$1C0 values
.0
	move.w	#9,d0					;sets RNG limit (-9 - +8)
	jsr	(randomd0s).l
	move.l	a0,-(sp)
	adda.l	#$1BC,a0
	move.b	d0,(a0,d1.w)
	movea.l	(sp)+,a0
	dbf	d1,.0
	movem.l	(sp)+,d0-d7
	rts
	dc.b	$4A,$43,$6A,$00,$00,$06,$42,$43,$4E,$75,$B6,$7C,$00,$64,$6F,$00
	dc.b	$00,$06,$36,$3C,$00,$64,$4E,$75

AttributeCalc						;Attribute d3 of player a3 * 5 plus his hot / cold value / 3 limited to 0
									;... $1E
	movem.l	d0-d2/a1,-(sp)
	move.w	(TempWord2).w,d1
	movea.l	#tmstruct,a1			;Start of Home Team struct
	btst	#pfteam,pflags(a3)
	beq.w	.attribmath
	adda.l	#$39E,a1
.attribmath
	clr.w	d1
	move.b	pnum(a3),d1
	asl.w	#4,d1					;shifts d1 4 bits left, moving the values over 1 nibble
	adda.l	#$1BC,a1
	move.b	(a1,d1.w),d1
	ext.w	d1						;sign-extend word. Ex: F5 (-5) -> FFF5
	ext.l	d1						;sign-extend long word. Ex: FFF5 -> FFFFFFF5
	divs.w	#3,d1					;Signed-Div D1 by 3 (FFFFFFF5 / 3, or -5 / 3 = -1r2, or FFFEFFFF
	move.w	d3,-(sp)				;push d3 onto stack
	asl.w	#2,d3					;shift left 2 bits (mult. by 4)
	add.w	(sp)+,d3				;Pop off d3 value and add to d3 (attrib X 5)
	add.w	d1,d3					;add d1 (H/C value) to d3
	bmi.w	.LowerLimit
	cmp.w	#$1E,d3
	blt.w	.MaskAttribMathResult
	move.w	#$1E,d3
	bra.w	.MaskAttribMathResult
.LowerLimit
	clr.w	d3						;if below lower limit (0), set to 0
.MaskAttribMathResult
	andi.w	#$FF,d3
	movem.l	(sp)+,d0-d2/a1
	rts

