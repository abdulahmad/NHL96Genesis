;	Segment build for engine\playoff96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$021BB0

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
ReadSRAMBits = $00975A		;srambits96
BeginPlayoffs = $014026		;awards96
randomd0 = $01B0A6		;video96
rtss2 = $01F84A		;collide96
MakeSRAMChecksum = $0241AA		;sram96
ReadSRAM = $0241E8		;sram96
ClearSRAMBytes = $024208		;sram96
ReadSRAMBitWords = $010F02		;season96
WriteSRAMBitWords = $010F22		;season96
GetGoalieCountD7 = $015774		;players96_count
WriteSRAM = $024188		;sram96


; Main segment code
	include	engine\playoff96.asm
