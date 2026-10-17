;	Segment build for front\awards96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$013EA0

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
WriteDayGames = $011226		;season96
WriteSeasonHeader = $01147E		;season96
ReadSeasonHeader = $01149E		;season96
ReadStandings = $01161E		;season96
maketree = $021CF4		;playoff96
WritePassData = $0223B0		;playoff96
WritePassBits = $0223EA		;playoff96
GetShifter = $0224E2		;playoff96
MakeSRAMChecksum = $0241AA		;sram96
ClearSRAMBytes = $024208		;sram96
ClearFreeAgentStats = $1DFA1C		;create96


; Main segment code
	include	front\awards96.asm
