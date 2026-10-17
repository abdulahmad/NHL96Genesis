;	Segment build for teamdata96.asm: sets its origin and the outside routines and data it uses,
;	then includes teamdata96.asm on its own for checking against the ROM.

; region code
	org	$000776

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String, Player

; External addresses outside: none.

; Main segment code
	include	teamdata96.asm
