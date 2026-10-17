;	Segment build for engine\pause96_return.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1E2688

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
forceblack = $01AF52		;video96
setVram_0 = $01B594		;video96
DecompressGraphicsPlain = $01B730		;video96
DrawFaceoffWindow = $00A2A0		;faceoff96
DoFill = $01B52E		;video96
AddFramer = $01C184		;penalty96
printscores1 = $01D062		;penalty96
VBlank = $0201DC		;display96
setvideo = $02034A		;display96
DumpPadSprites = $021046		;display96
setupIceRinkPal = $02109A		;display96
setupEASNmap = $0210B0		;display96
SprSort = $0213AE		;display96
setplayercolors = $0215B2		;control96_team
LoadSmallFont = $0243A0		;video96_font
LoadBigFonts = $0243BA		;video96_font
Z80Program = $025500		;sound96
SoundBanks = $027026		;sound96
SoundCmd = $08839E		;sound96
stop_current_song = $0885FC		;sound96
FaceOffMap = $091D46		;graphics96
Rinktilelist = $0923E4		;graphics96
RefTiles = $097E72		;graphics96
RefTilesHor = $098F30		;graphics96
CrowdFrameList = $13AA96		;graphics96
FaceOffSprites = $13BCB0		;graphics96
EnergyBarMap = $13D290		;graphics96
ReplayBannerMap = $141228		;graphics96
LoadReplayIcon = $1D8E5C		;code96_15
LoadHomeTeamGfx = $1D8E6C		;code96_15


; Main segment code
	include	engine\pause96_return.asm
