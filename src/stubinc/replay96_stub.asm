;	Segment build for engine\replay96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$01581C

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
ReadJoy1 = $01B348					;video96
ReadJoy2 = $01B360					;video96
ReadJoy3 = $01B378					;video96
ReadJoy4 = $01B390					;video96


; Main segment code
	include	engine\replay96.asm
