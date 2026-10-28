;	Segment build for front\trade96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$0100C0

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
SortBytesByWords = $010CB2			;season96
TeamList = $00077E					;teamdata96
GetGoalieCount = $0157A2			;players96_count
GetPlayerCount = $0157F4			;players96_count
randomd0 = $01B0A6					;video96
FinalizeTextBuffer = $0230AA		;middle96
ConvertByteToDigits = $0230C4		;middle96
PAttribOverallMask = $023456		;setup96_attr
GAttribOverallMask = $0235B8		;setup96_attr
ReadSRAM = $0241E8					;sram96
CalcAttrib = $1D7DF8				;code96_14


; Main segment code
	include	front\trade96.asm
