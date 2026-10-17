;	Segment build for sram96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$023F1C

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
WriteSRAMBits = $0096E8		;srambits96
NullSaveClear = $00EF00		;lines96_set
DefaultRosters = $0100C0		;trade96
WriteSeasonHeader = $01147E		;season96
vcountwait = $0151E0		;pause96
ReadJoy1 = $01B348		;video96
ClearCreatedPlayers = $1DFA34		;create96


; Main segment code
	include	sram96.asm
