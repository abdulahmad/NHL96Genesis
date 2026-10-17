;	Segment build for front\season96_sim.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$01091A

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
SortBytesByWords = $010CB2		;season96
SaveGameStats = $010CF2		;season96
TeamList = $00077E		;teamdata96
GetGoalieCountD7 = $015774		;players96_count
randomd0 = $01B0A6		;video96
PAttribAggressMask = $023574		;setup96_attr
CalcAttrib = $1D7DF8		;code96_14
SetSeasonInjuries = $1E8840		;injury96
SimTeamDefense = $0107F9		;trade96


; Main segment code
	include	front\season96_sim.asm
