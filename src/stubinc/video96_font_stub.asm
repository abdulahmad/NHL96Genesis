;	Segment build for engine\video96_font.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$0243A0

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
DecompressGraphicsWithCallback = $01B724	;video96
DecompressGraphicsPlain = $01B730	;video96
SmallFontMap = $179A76				;graphics96
BigFontMap = $1B89C8				;graphics96
BigFontMap3 = $1B9416				;graphics96


; Main segment code
	include	engine\video96_font.asm
