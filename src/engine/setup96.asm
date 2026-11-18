;	Roster attribute columns. GetNameandAttrib prints a player's name, then the column the
;	cursor is on: status, energy, handedness, weight, fighting, or a rating.

GetNameandAttrib					;Print player d0's name, then the column d4 picks (attribjmp; above 2 a
									;rating, the jump offset in the low word).
	movem.l	d0-d4/d7/a0-a1/a4-a5,-(sp)
	move.w	(printx).w,-(sp)
	pea	.table(pc)
	jsr	(getname).l
	jsr	(printcur).l
	move.w	(sp),(printx).w
	addi.w	#$18,(printx).w
	move.w	Xvel(a2),d7
	move.w	d0,-(sp)
	jsr	(GetPositionSlot).l
	movea.l	#PosText,a1
	jsr	(SkipStrings).l
	jsr	(printcur).l
	move.w	(sp)+,d0
	move.w	(sp),(printx).w
	addi.w	#$1C,(printx).w
	cmp.w	#2,d4
	bls.w	.1
	jsr	(CalcAttrib).l
	swap	d4
.1
	lea	attribjmp(pc),a0
	adda.w	(a0,d4.w),a0
	jmp	(a0)
.table
	dc.w	$301F,$4CDF,$339F,$4E75,$48E7,$F8CC,$487A,$002E
	dc.w	$4EB9,$0002,$2E92,$4EB9,$0001,$BC84,$31FC,$001E
	dc.w	$B040,$B87C,$0002,$6300,$000A,$4EB9,$001D,$7DF8
	dc.w	$4844,$41FA,$000E,$D0F0,$4000,$4ED0,$4CDF,$331F
	dc.w	$4E75

attribjmp							;GetNameandAttrib column handlers, offsets from attribjmp: status, energy,
									;handed, weight, fighting, rating
	dc.w	AttribStatus-attribjmp
	dc.w	AttribEnergy-attribjmp
	dc.w	AttribHanded-attribjmp
	dc.w	AttribWeight-attribjmp
	dc.w	AttribFighting-attribjmp
	dc.w	AttribRating-attribjmp

AttribStatus						;Player d0's status word: Ice, Bench, Inj. P, Inj. G, the games out of an
									;injured player, or penalty time.
	move.w	d0,(injurygames+2).w
	add.w	d0,d0					;jump for status
	move.w	$6C(a2,d0.w),d0
	bpl.w	.3
	not.w	d0
	cmp.w	#3,d0
	bls.w	.1
	moveq	#1,d0
	bra.w	.1
.loop
	moveq	#3,d0
.1
	cmp.w	#3,d0
	bne.w	.2
	movem.l	d0-d1/d7,-(sp)
	move.w	(injurygames+2).w,d1
	move.w	Xvel(a2),d7
	jsr	(GetInjuryGames).l
	lea	InjuryGamesTbl(pc),a1
	jsr	(PrintSmallListItem).l
	movem.l	(sp)+,d0-d1/d7
	rts
.2
	lea	StatusTextTbl(pc),a1
	jmp	(PrintSmallListItem).l
.3
	btst	#$C,d0
	bne.s	.loop
	subq.w	#1,(printx).w
	move.w	d0,d1
	andi.w	#$FFF,d0
	jsr	(PushTime).l
	jsr	(printcur).l
	moveq	#4,d0
	bclr	#$E,d1
	beq.w	.4
	moveq	#5,d0
.4
	lea	StatusTextTbl(pc),a1
	jmp	(PrintSmallListItem).l

StatusTextTbl						;AttribStatus Strings
	String	'Ice     '
	String	'Bench   '
	String	'Injury P'
	String	'Injury G'
	String	'    '
	String	' C  '

InjuryGamesTbl						;AttribStatus Strings for an injury of 0-9 games
	String	'Inj. G  '
	String	'Inj.1G  '
	String	'Inj.2G  '
	String	'Inj.3G  '
	String	'Inj.4G  '
	String	'Inj.5G  '
	String	'Inj.6G  '
	String	'Inj.7G  '
	String	'Inj.8G  '
	String	'Inj.9G  '

AttribEnergy						;Energy / 40, at most 100 (AttribPrintPct).
	add.w	d0,d0					;jump for energy
	move.w	$34(a2,d0.w),d0
	ext.l	d0
	divu.w	#$28,d0
	cmp.w	#$64,d0
	ble.w	AttribPrintPct
	moveq	#$64,d0
	bra.w	AttribPrintPct

AttribFighting						;Bit 0 of the nibble is the handedness: drop it, then a rating out of d1 -
									;1.
	andi.w	#$E,d0
	subq.w	#1,d1

AttribRating						;d0 * 100 / d1. Falls into AttribPrintPct.
									;Code the listing does not decode: kept as bytes
	dc.b	$C0,$FC,$00,$64,$80,$C1,$4E,$B9,$00,$1D,$93,$02

AttribPrintPct						;Print d0 4 wide, then 4 blanks.
	moveq	#4,d1
	jsr	(PushNumberWidth).l
	jsr	(printcur).l
	jsr	(printcurz).l
	String	'    '
	rts

AttribHanded						;Bit 0 of d0, flipped: Righty / Lefty (HandedTextTbl).
	andi.w	#1,d0
	eori.w	#1,d0
	lea	HandedTextTbl(pc),a1
	jmp	(PrintSmallListItem).l

HandedTextTbl						;AttribHanded Strings
	String	'Righty  '
	String	'Lefty   '

AttribWeight						;Weight in lb (RatingToWeight).
	bsr.w	RatingToWeight
	jsr	(PushNumber).l
	jsr	(printcur).l
	jsr	(printcurz).l
	String	' lb  '
	rts

RatingToWeight						;d0 = the weight of rating d0 (WeightTbl).
	movem.l	a0,-(sp)
	movea.l	#WeightTbl,a0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	movem.l	(sp)+,a0
	rts

WeightTbl							;RatingToWeight: the weight in lb of each rating
	dc.w	140,148,152,164,172,180,188,196
	dc.w	204,212,220,228,236,244,252,260

