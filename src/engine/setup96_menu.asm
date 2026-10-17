;	The default menu choices for the setup screens, and the vblank that runs
;	them.

VBlank_SetOptions					;The vertical blank handler of the setup screens.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$FF,$FE,$08,$38,$00,$02,$BF,$B2,$66,$00,$00,$14,$08,$B8
	dc.b	$00,$00,$BF,$B2,$67,$00,$00,$06,$61,$00,$E7,$7E,$61,$00,$94,$66
	dc.b	$52,$78,$B0,$52,$4E,$B9,$00,$02,$44,$86,$4C,$DF,$7F,$FF,$4E,$73

DefaultMenus						;Set the default menu choices (defmenuoptions)
	st	(demoflag).w
	movea.l	#$FFFFD254,a0
	movea.l	#defmenuoptions,a1
	move.w	#8,d0
.loop
	move.w	(a1)+,(a0)+
	dbf	d0,.loop
	rts

defmenuoptions						;DefaultMenus: the default options
	dc.b	$00,$00,$00,$01,$00,$0B,$00,$0A,$00,$01,$00,$00,$00,$01,$00,$00
	dc.b	$00,$01

