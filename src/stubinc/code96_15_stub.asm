;	Segment build for code96_15.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1D8E5C

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
assexit = $01A3BE		;logic96_vec
SetSPA = $01A614		;skate96
forceblack = $01AF52		;video96
waitx = $01B152		;video96
setVram_0 = $01B594		;video96
dobitmap = $01B692		;video96
DecompressGraphicsPlain = $01B730		;video96
AssignBySavedPos = $01FE78		;players96
vb2 = $0202C4		;display96
ReplayIconMap = $140AFE		;graphics96
HiScoreBgMap = $1468D6		;graphics96
HiScoreImg = $147896		;graphics96


; Main segment code
	include	code96_15.asm
