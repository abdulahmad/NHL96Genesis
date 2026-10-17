;	Segment build for front\awards96_show.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1E7AC4

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
printz = $01BB8E		;video96
MakeSRAMChecksum = $0241AA		;sram96
ReadSRAM = $0241E8		;sram96
DrawScreenSprite = $01218A		;season96
SetMenuScroll = $012640		;season96
GetGoalieCountD7 = $015774		;players96_count
forceblack = $01AF52		;video96
dobitmap = $01B692		;video96
DecompressGraphicsPlain = $01B730		;video96
LoadScreenSprite = $01217A		;season96
VBlank_Menus = $012D46		;teamgfx96
orjoy = $01B2C4		;video96
setVram = $01B57E		;video96
eraser = $01B976		;video96
printsmallz = $01BA2E		;video96
printcurz = $01BC72		;video96
printcur = $01BC84		;video96
printbigz = $01BED6		;video96
printbig = $01BEEC		;video96
SkipStrings = $01D7F2		;hockey96_inter
maketree = $021CF4		;playoff96
IceBgMap = $170B0C		;graphics96
SmallFontMap2 = $17A164		;graphics96
BigFontMap4 = $17B680		;graphics96
TeamList = $00077E		;teamdata96
GetCreatedName = $0101DC		;trade96
DrawTeamLogoD7 = $012BB2		;season96
Vmaddr = $01B678		;video96
DecompressGraphicsWithCallback = $01B724		;video96
FinalizeTextBuffer = $0230AA		;middle96
AwardsTitleMap = $1AEF62		;graphics96
AwardsBgMap = $1AF782		;graphics96
AwardsSprites = $1B11B0		;graphics96
PresidentsPic = $1B14DE		;graphics96
ArtRossPic = $1B1B34		;graphics96
NorrisPic = $1B244A		;graphics96
VezinaPic = $1B2BC0		;graphics96
CampbellPic = $1B32B6		;graphics96
WalesPic = $1B3A0C		;graphics96
HartPic = $1B3F82		;graphics96
ConnSmythePic = $1B4538		;graphics96
PearsonPic = $1B4D4E		;graphics96
BigFontMap = $1B89C8		;graphics96
GetPositionSlot = $0103AA		;trade96
GetSeasonRosterId = $0104EE		;trade96
ReadStandings = $01161E		;season96
SmallLogoPtrs = $012CDE		;teamgfx96
randomd0 = $01B0A6		;video96
printbigcur = $01BEE8		;video96
CupChampsMap = $1C6C4C		;graphics96
CupChampsMap2 = $1CAEFA		;graphics96
CupChampsPals = $1CCBA8		;graphics96
StandingsPoints = $1D9CC6		;season96_stand
StandingsGroups = $1D9D12		;season96_stand
StandingsGroup4 = $1D9D76		;season96_stand
SortStandings = $1D9D92		;season96_stand
BuildPlayerLeaders = $1DA9EA		;season96_menu
VBlank_SpriteFade = $1E2E76		;summary96


; Main segment code
	include	front\awards96_show.asm
