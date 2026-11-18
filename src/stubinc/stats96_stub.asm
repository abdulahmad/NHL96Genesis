;	Segment build for front\stats96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1E1B18

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
eraser = $01B976					;goal96_box_stub
FinalizeTextBuffer = $0230AA		;trade96_stub
GetNameandAttrib = $0151FA			;setup96
GetPlayerNamePointer = $0101C6		;middle96_stub
MakeSRAMChecksum = $0241AA			;sram96
PAttribColumns = $02342E			;setup96_attr
printbig = $01BEEC					;season96_stub
printsmallz = $01BA2E				;pause96_stub
printz = $01BB8E					;goal96_box_stub


; Main segment code
	include	front\stats96.asm
