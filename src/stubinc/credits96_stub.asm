;	Segment build for credits96.asm: sets its origin and the outside routines and data it uses,
;	then includes credits96.asm on its own for checking against the ROM.

; region code
	org	$0056F0

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside: none.
print = $01BBA0						;video96

; Main segment code
	include	credits96.asm
