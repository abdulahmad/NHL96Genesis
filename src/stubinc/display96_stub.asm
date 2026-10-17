;	Segment build for display96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$0201DC

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
jdtab = $01B3C8		;video96
Vmaddr = $01B678		;video96
DoDMA = $01B3EC		;video96
DoFill = $01B52E		;video96
setVram = $01B57E		;video96
DecompressGraphicsPlain = $01B730		;video96
AddFramer = $01C184		;penalty96
rtss2 = $01F84A		;collide96
sizetab = $0233AC		;video96_size
LoadSmallFont = $0243A0		;video96_font
LoadBigFonts = $0243BA		;video96_font
Rinktilelist = $0923E4		;graphics96
Sprites = $09AA9E		;graphics96
CrowdFrameList = $13AA96		;graphics96
FaceOffSprites = $13BCB0		;graphics96
FaceOffMap = $091D46		;graphics96
RefTiles = $097E72		;graphics96
RefTilesHor = $098F30		;graphics96
EnergyBarMap = $13D290		;graphics96
EASNmap = $13D59E		;graphics96
RevRinkTilelist = $13E99A		;graphics96
SmallFontMap = $179A76		;graphics96
UpdateCrowdMeter = $1D6D40		;code96_14
AddArenaAnimSprite = $1D84D4		;shootout96_path
LoadReplayIcon = $1D8E5C		;code96_15
LoadHomeTeamGfx = $1D8E6C		;code96_15
showclock = $1E7664		;middle96_clock
setplayercolors = $0215B2		;control96_team


; Main segment code
	include	display96.asm
