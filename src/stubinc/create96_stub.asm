;	Segment build for front\create96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1DD916

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
PAttribOverallMask = $023456		;setup96_attr
GAttribOverallMask = $0235B8		;setup96_attr
ClearSRAMBytes = $024208			;sram96


; Main segment code
	include	front\create96.asm
