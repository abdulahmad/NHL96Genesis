;	Segment build for engine\pause96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$014CC8

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
ReadMenuJoy = $015CD8				;replay96
rtss8 = $0162EE						;replay96
forceblack = $01AF52				;video96
ProcessInputWithRepeat = $01B320	;video96
ReadJoy1 = $01B348					;video96
ReadJoy2 = $01B360					;video96
ReadJoy3 = $01B378					;video96
ReadJoy4 = $01B390					;video96
printsmallz = $01BA2E				;video96
printbigcur = $01BEE8				;video96
ExitToOpening = $0216EE				;hockey96_open
ShootoutPauseMenu = $0236B0			;pause96_items
PauseMenu = $023734					;pause96_items
PauseMenuNoTimeout = $023890		;pause96_items
Z80Program = $025500				;sound96
SoundBanks = $027026				;sound96
SoundCmd = $08839E					;sound96
stop_current_song = $0885FC			;sound96
SoundOff = $088676					;sound96
ManualGoalieMenu = $1D86A4			;shootout96_path
SetMenuPadSide = $1D9844			;code96_15
ReturnToGame = $1E2688				;pause96_return
TimeoutMenu = $015570				;pause96_menu
SelectGoalieMenu = $015604			;pause96_menu


; Main segment code
	include	engine\pause96.asm
