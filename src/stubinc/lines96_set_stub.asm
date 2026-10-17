;	Segment build for engine\lines96_set.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$00EF00

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
TeamList = $00077E		;teamdata96
GetPlayerCountD7 = $0157B2		;players96_count
PAttribOverallMask = $023456		;setup96_attr
GAttribOverallMask = $0235B8		;setup96_attr
CalcAttribRating = $1DF8AC		;create96
OvrPlayerWgtList2 = $1DF9EC		;create96
OvrGoalWgtList2 = $1DF9FC		;create96
GetRosterName = $0101E6		;trade96
GetPositionSlot = $0103AA		;trade96


; Main segment code
	include	engine\lines96_set.asm
