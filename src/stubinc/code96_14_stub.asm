;	Segment build for code96_14.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1D6B66

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
GetRosterName = $0101E6				;trade96
GetGoalieCount = $0157A2			;players96_count
GetPlayerCount = $0157F4			;players96_count
randomd0s = $01B09A					;video96
Sroot = $01B0DE						;video96
wallcollb = $01EDAE					;collide96
PAttribOverallMask = $023456		;setup96_attr
GAttribOverallMask = $0235B8		;setup96_attr
WriteSRAM = $024188					;sram96
MakeSRAMChecksum = $0241AA			;sram96
ReadSRAM = $0241E8					;sram96
MinOverallRating = $1DF9C2			;create96
a2offsides = $019D4C				;logic96_pull
appstring = $01BE80					;middle96_stub
ArmIcing = $019E6E					;logic96_pull
dopass = $00F8F6					;input96_shot
doshot = $00F5F8					;input96_shot
Findhittype = $016D36				;control96
ReadJoy1 = $01B348					;pause96_stub
ReadJoy2 = $01B360					;pause96_stub
ReadJoy3 = $01B378					;pause96_stub
ReadJoy4 = $01B390					;pause96_stub
GetTeamLines = $00EF02				;control96_team_stub
eraser = $01B976				;goal96_box_stub
printz = $01BB8E				;goal96_box_stub


; Main segment code
	include	code96_14.asm
