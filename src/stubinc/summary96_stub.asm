;	Segment build for front\summary96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1E2E76

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
DumpSpriteTable = $02031C			;display96
cramfade = $01AFD6					;video96
p_music_vblank = $024486			;sound96
AppendUserName = $1D7D62			;code96_14
GAttribOverall = $0235A6			;setup96_attr
GetNameandAttrib = $0151FA			;stats96_stub
PAttribOverall = $023444			;setup96_attr
printbig = $01BEEC					;stats96_stub
printsmallz = $01BA2E				;pause96_stub
printz = $01BB8E					;goal96_box_stub
ReadSRAM = $0241E8					;sram96


; Main segment code
	include	front\summary96.asm
