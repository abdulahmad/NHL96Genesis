;	Roster attribute columns. GetNameandAttrib prints a player's name, then the column the
;	cursor is on: status, energy, handedness, weight, fighting, or a rating.

GetNameandAttrib					;Print player d0's name, then the column d4 picks (attribjmp; above 2 a
									;rating, the jump offset in the low word).
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$F9,$CC,$3F,$38,$B0,$40,$48,$7A,$00,$5C,$4E,$B9,$00,$02
	dc.b	$2E,$92,$4E,$B9,$00,$01,$BC,$84,$31,$D7,$B0,$40,$06,$78,$00,$18
	dc.b	$B0,$40,$3E,$2A,$00,$28,$3F,$00,$4E,$B9,$00,$01,$03,$AA,$22,$7C
	dc.b	$00,$1D,$E7,$4C,$4E,$B9,$00,$01,$D7,$F2,$4E,$B9,$00,$01,$BC,$84
	dc.b	$30,$1F,$31,$D7,$B0,$40,$06,$78,$00,$1C,$B0,$40,$B8,$7C,$00,$02
	dc.b	$63,$00,$00,$0A,$4E,$B9,$00,$1D,$7D,$F8,$48,$44,$41,$FA,$00,$4A
	dc.b	$D0,$F0,$40,$00,$4E,$D0,$30,$1F,$4C,$DF,$33,$9F,$4E,$75,$48,$E7
	dc.b	$F8,$CC,$48,$7A,$00,$2E,$4E,$B9,$00,$02,$2E,$92,$4E,$B9,$00,$01
	dc.b	$BC,$84,$31,$FC,$00,$1E,$B0,$40,$B8,$7C,$00,$02,$63,$00,$00,$0A
	dc.b	$4E,$B9,$00,$1D,$7D,$F8,$48,$44,$41,$FA,$00,$0E,$D0,$F0,$40,$00
	dc.b	$4E,$D0,$4C,$DF,$33,$1F,$4E,$75

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
									;Code the listing does not decode: kept as bytes
	dc.b	$31,$C0,$DD,$BA,$D0,$40,$30,$32,$00,$6C,$6A,$00,$00,$48,$46,$40
	dc.b	$B0,$7C,$00,$03,$63,$00,$00,$0A,$70,$01,$60,$00,$00,$04,$70,$03
	dc.b	$B0,$7C,$00,$03,$66,$00,$00,$24,$48,$E7,$C1,$00,$32,$38,$DD,$BA
	dc.b	$3E,$2A,$00,$28,$4E,$B9,$00,$1E,$88,$7A,$43,$FA,$00,$7E,$4E,$B9
	dc.b	$00,$01,$D7,$EA,$4C,$DF,$00,$83,$4E,$75,$43,$FA,$00,$3A,$4E,$F9
	dc.b	$00,$01,$D7,$EA,$08,$00,$00,$0C,$66,$C4,$53,$78,$B0,$40,$32,$00
	dc.b	$02,$40,$0F,$FF,$4E,$B9,$00,$01,$BD,$84,$4E,$B9,$00,$01,$BC,$84
	dc.b	$70,$04,$08,$81,$00,$0E,$67,$00,$00,$04,$70,$05,$43,$FA,$00,$08
	dc.b	$4E,$F9,$00,$01,$D7,$EA

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
									;Code the listing does not decode: kept as bytes
	dc.b	$D0,$40,$30,$32,$00,$34,$48,$C0,$80,$FC,$00,$28,$B0,$7C,$00,$64
	dc.b	$6F,$00,$00,$1A,$70,$64,$60,$00,$00,$14

AttribFighting						;Bit 0 of the nibble is the handedness: drop it, then a rating out of d1 -
									;1.
									;Code the listing does not decode: kept as bytes
	dc.b	$02,$40,$00,$0E,$53,$41

AttribRating						;d0 * 100 / d1. Falls into AttribPrintPct.
									;Code the listing does not decode: kept as bytes
	dc.b	$C0,$FC,$00,$64,$80,$C1,$4E,$B9,$00,$1D,$93,$02

AttribPrintPct						;Print d0 4 wide, then 4 blanks.
									;Code the listing does not decode: kept as bytes
	dc.b	$72,$04,$4E,$B9,$00,$01,$BE,$1C,$4E,$B9,$00,$01,$BC,$84,$4E,$B9
	dc.b	$00,$01,$BC,$72,$00,$06,$20,$20,$20,$20,$4E,$75

AttribHanded						;Bit 0 of d0, flipped: Righty / Lefty (HandedTextTbl).
									;Code the listing does not decode: kept as bytes
	dc.b	$02,$40,$00,$01,$0A,$40,$00,$01,$43,$FA,$00,$08,$4E,$F9,$00,$01
	dc.b	$D7,$EA

HandedTextTbl						;AttribHanded Strings
	String	'Righty  '
	String	'Lefty   '

AttribWeight						;Weight in lb (RatingToWeight).
									;Code the listing does not decode: kept as bytes
	dc.b	$61,$00,$00,$1E,$4E,$B9,$00,$01,$BD,$E8,$4E,$B9,$00,$01,$BC,$84
	dc.b	$4E,$B9,$00,$01,$BC,$72,$00,$08,$20,$6C,$62,$20,$20,$00,$4E,$75

RatingToWeight						;d0 = the weight of rating d0 (WeightTbl).
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$00,$80,$20,$7C,$00,$01,$54,$70,$D0,$40,$30,$30,$00,$00
	dc.b	$4C,$DF,$01,$00,$4E,$75

WeightTbl							;RatingToWeight: the weight in lb of each rating
	dc.w	140,148,152,164,172,180,188,196
	dc.w	204,212,220,228,236,244,252,260

