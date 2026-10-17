;	Segment build for engine\middle96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$022E70

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
GetPlayerNamePointer = $0101C6		;trade96
GetJerseyNumber = $0102B8			;trade96
appendz = $01BE78					;video96
appstring = $01BE80					;video96


; Main segment code
	include	engine\middle96.asm
