;	Segment build for front\trade96_edit.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1DC03C

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
SignFreeAgents = $1DFBAC			;create96
ReleasePlayers = $1E0536			;create96
CreatePlayer = $1DD916				;create96


; Main segment code
	include	front\trade96_edit.asm
