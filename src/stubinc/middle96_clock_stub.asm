;	Segment build for engine\middle96_clock.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1E7664

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
printz = $01BB8E		;video96
print = $01BBA0		;video96
PushNumberWidth = $01BE1C		;video96
printbigz1 = $01C11A		;penalty96
printbigz2 = $01C12C		;penalty96
printbig1 = $01C13E		;penalty96
printbig2 = $01C15A		;penalty96
eraser = $01B976		;video96
SkipStrings = $01D7F2		;hockey96_inter
TeamList = $00077E		;teamdata96
ErasePowerPlayBox = $01CFE4		;penalty96
EASNLogo = $01D064		;penalty96
BigFontMap = $1B89C8		;graphics96


; Main segment code
	include	engine\middle96_clock.asm
