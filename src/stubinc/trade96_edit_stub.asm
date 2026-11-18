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
eraser = $01B976					;goal96_box_stub
GetPlayerCountD7 = $0157B2			;create96_stub
MakeSRAMChecksum = $0241AA			;sram96
Opening2 = $02174A					;hockey96_open
ProcessInputWithRepeat = $01B320	;pause96_stub
ReadJoy1 = $01B348					;pause96_stub
ReadJoy2 = $01B360					;pause96_stub
ReadJoy3 = $01B378					;pause96_stub
ReadJoy4 = $01B390					;pause96_stub
ReadSRAM = $0241E8					;sram96
ReadSRAMBitWords = $010F02			;playoff96_stub
SetMenuScroll = $012640				;options96_stub
SPAboardbot = $2412					;frames96
SPAfpunchBhit1 = $35B8				;frames96
WriteSRAM = $024188					;sram96
WriteSRAMBitWords = $010F22			;playoff96_stub


; Main segment code
	include	front\trade96_edit.asm
