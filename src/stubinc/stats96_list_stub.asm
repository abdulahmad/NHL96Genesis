;	Segment build for front\stats96_list.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1E55BA

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
printz = $01BB8E		;video96
PushNumberWidth = $01BE1C		;video96
DrawScreenSprite = $01218A		;season96
SeasonMenuScreen = $0122A4		;season96
SetMenuScroll = $012640		;season96
GetGoalieCountD7 = $015774		;players96_count
GetPlayerCountD7 = $0157B2		;players96_count
dobitmap = $01B692		;video96
DecompressGraphicsPlain = $01B730		;video96
Opening2 = $02174A		;hockey96_open
PlayerStatsSprites = $18B4F8		;graphics96
PStatsClearList = $1DB364		;season96_menu
FormatPlayerNameD7 = $01017A		;trade96
LoadScreenSprite = $01217A		;season96
DrawSetupTeamBlock = $012B84		;season96
VBlank_Menus = $012D46		;teamgfx96
orjoy = $01B2C4		;video96
ProcessInputWithRepeat = $01B320		;video96
ReadJoy1 = $01B348		;video96
ReadJoy2 = $01B360		;video96
ReadJoy3 = $01B378		;video96
ReadJoy4 = $01B390		;video96
setVram = $01B57E		;video96
eraser = $01B976		;video96
printsmallz = $01BA2E		;video96
printcurz = $01BC72		;video96
printcur = $01BC84		;video96
printbigz = $01BED6		;video96
printbig = $01BEEC		;video96
SkipStrings = $01D7F2		;hockey96_inter
IceBgMap = $170B0C		;graphics96
RosterFont = $179168		;graphics96
SmallFontMap2 = $17A164		;graphics96
BigFontMap4 = $17B680		;graphics96
PlayerStatsBgMap = $18948A		;graphics96
PlayoffStatsTitleMap = $18B916		;graphics96
BlankStatsRow = $1DAE32		;season96_menu
PStatsPalette = $1DBB92		;season96_menu
PlayerStatsTitleMap = $1AC7C6		;graphics96


; Main segment code
	include	front\stats96_list.asm
