;	The pads, read every vblank.

ReadJoyData							;Read the pads every vblank. With FourWayPlay, pads 1-4 through the 4 way
									;adaptor (ReadPad4Way1 ...
									;ReadPad4Way4) to pad4way1-pad4way4, else pads 1 and 2 (ReadPad1,
									;ReadPad2).
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$40,$80,$4A,$78,$D2,$50,$67,$00,$00,$2A,$4E,$B9,$00,$02
	dc.b	$42,$70,$11,$C0,$BF,$2A,$4E,$B9,$00,$02,$42,$8A,$11,$C0,$BF,$2B
	dc.b	$61,$00,$00,$5C,$11,$C0,$BF,$2C,$61,$00,$00,$6E,$11,$C0,$BF,$2D
	dc.b	$60,$00,$00,$12,$61,$00,$00,$94,$11,$C0,$BF,$2A,$61,$00,$00,$7E
	dc.b	$11,$C0,$BF,$2B,$4C,$DF,$01,$02,$4E,$75

ReadPad4Way1						;4 way play pad 1: pause the sound driver (SoundCmd $D), select pad 1 on
									;port 2 and read it on port 1.
									;Code the listing does not decode: kept as bytes
	dc.b	$3F,$00,$30,$3C,$00,$0D,$4E,$B9,$00,$08,$83,$9E,$30,$1F,$13,$FC
	dc.b	$00,$0C,$00,$A1,$00,$05,$60,$00,$00,$4C

ReadPad4Way2						;4 way play pad 2, as ReadPad4Way1.
									;Code the listing does not decode: kept as bytes
	dc.b	$3F,$00,$30,$3C,$00,$0D,$4E,$B9,$00,$08,$83,$9E,$30,$1F,$13,$FC
	dc.b	$00,$1C,$00,$A1,$00,$05,$60,$00,$00,$32

ReadPad4Way3						;4 way play pad 3, as ReadPad4Way1.
									;Code the listing does not decode: kept as bytes
	dc.b	$3F,$00,$30,$3C,$00,$0D,$4E,$B9,$00,$08,$83,$9E,$30,$1F,$13,$FC
	dc.b	$00,$2C,$00,$A1,$00,$05,$60,$00,$00,$18

ReadPad4Way4						;4 way play pad 4, as ReadPad4Way1. Falls into ReadPad4WayPort1.
									;Code the listing does not decode: kept as bytes
	dc.b	$3F,$00,$30,$3C,$00,$0D,$4E,$B9,$00,$08,$83,$9E,$30,$1F,$13,$FC
	dc.b	$00,$3C,$00,$A1,$00,$05

ReadPad4WayPort1					;Read the pad on port 1; branched to from ReadPad4Way1 ... ReadPad4Way4.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$40,$80,$41,$F9,$00,$A1,$00,$03,$60,$00,$00,$28

ReadPad2							;Read pad 2 (port 2). Falls into ReadPadA0.
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$40,$80,$41,$F9,$00,$A1,$00,$05,$60,$00,$00,$0C

ReadPad1							;Read pad 1 (port 1).
									;Code the listing does not decode: kept as bytes
	dc.b	$48,$E7,$40,$80,$41,$F9,$00,$A1,$00,$03

ReadPadA0							;Pause the sound driver (SoundCmd $D), then ReadPad3Button.
									;Code the listing does not decode: kept as bytes
	dc.b	$3F,$00,$30,$3C,$00,$0D,$4E,$B9,$00,$08,$83,$9E,$30,$1F

ReadPad3Button						;Read a 3 button pad at a0 (TH low, then high), resume the sound driver
									;(SoundCmd $E) and return d0 = the
									;buttons, the directions through PadDirTable.
									;Code the listing does not decode: kept as bytes
	dc.b	$70,$00,$10,$BC,$00,$00,$4E,$71,$4E,$71,$10,$10,$10,$BC,$00,$40
	dc.b	$4E,$71,$4E,$71,$12,$10,$3F,$00,$30,$3C,$00,$0E,$4E,$B9,$00,$08
	dc.b	$83,$9E,$30,$1F,$E5,$00,$02,$00,$00,$C0,$02,$01,$00,$3F,$80,$01
	dc.b	$46,$00,$46,$01,$02,$41,$00,$0F,$41,$FA,$00,$12,$02,$00,$00,$F0
	dc.b	$80,$30,$10,$00,$46,$00,$4C,$DF,$01,$02,$4E,$75

PadDirTable							;Direction nibble table for ReadPad3Button: remaps the nibble when
									;opposite directions are pressed together
	dc.b	$00,$01,$02,$01,$04,$05,$06,$06,$08,$09,$0A,$0A,$08,$09,$0A,$00

ResetZ80Bus							;Reset the Z80 and wait for its bus.
									;Code the listing does not decode: kept as bytes
	dc.b	$33,$FC,$01,$00,$00,$A1,$12,$00,$33,$FC,$01,$00,$00,$A1,$11,$00
	dc.b	$08,$39,$00,$00,$00,$A1,$11,$00,$66,$F6,$4E,$75
