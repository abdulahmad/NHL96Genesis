;	Segment build for engine\goal96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$00B04E

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
DrawSetupTeamBlock = $012B84		;season96
ZeroLong = $000772		;main96
vcountwait = $0151E0		;pause96
orjoy = $01B2C4		;video96
nodiag = $01B2F8		;video96
ReadJoy1 = $01B348		;video96
ReadJoy2 = $01B360		;video96
ReadJoy3 = $01B378		;video96
ReadJoy4 = $01B390		;video96
setVram = $01B57E		;video96
Vmaddr = $01B678		;video96
dobitmap = $01B692		;video96
DecompressGraphicsPlain = $01B730		;video96
eraser = $01B976		;video96
printsmallz = $01BA2E		;video96
printsmall = $01BA40		;video96
printz = $01BB8E		;video96
VBlank_SetOptions = $021B52		;setup96_menu
ControllerBgMap = $173C7A		;graphics96
RosterFont = $179168		;graphics96
PadIconMap1 = $1B53C4		;graphics96
PadIconMap2 = $1B5942		;graphics96
PadIconMap3 = $1B5EC0		;graphics96
PadIconMap4 = $1B643E		;graphics96
PadCursorMap = $1B69BC		;graphics96
ControllerTitleMap = $1B6F3A		;graphics96
ControllerFrameMap = $1B773A		;graphics96

; Main segment code
	include	engine\goal96.asm
