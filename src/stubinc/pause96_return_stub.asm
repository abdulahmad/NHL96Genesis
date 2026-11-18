;	Segment build for engine\pause96_return.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1E2688

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
forceblack = $01AF52				;video96
setVram_0 = $01B594					;video96
DecompressGraphicsPlain = $01B730	;video96
DrawFaceoffWindow = $00A2A0			;faceoff96
DoFill = $01B52E					;video96
AddFramer = $01C184					;penalty96
printscores1 = $01D062				;penalty96
VBlank = $0201DC					;display96
setvideo = $02034A					;display96
DumpPadSprites = $021046			;display96
setupIceRinkPal = $02109A			;display96
setupEASNmap = $0210B0				;display96
SprSort = $0213AE					;display96
setplayercolors = $0215B2			;control96_team
LoadSmallFont = $0243A0				;video96_font
LoadBigFonts = $0243BA				;video96_font
Z80Program = $025500				;sound96
SoundBanks = $027026				;sound96
SoundCmd = $08839E					;sound96
stop_current_song = $0885FC			;sound96
FaceOffMap = $091D46				;graphics96
Rinktilelist = $0923E4				;graphics96
RefTiles = $097E72					;graphics96
RefTilesHor = $098F30				;graphics96
Crowdframelist = $13AA96			;graphics96
FaceOffSprites = $13BCB0			;graphics96
EnergyBarMap = $13D290				;graphics96
ReplayBannerMap = $141228			;graphics96
LoadReplayIcon = $1D8E5C			;code96_15
LoadHomeTeamGfx = $1D8E6C			;code96_15
printbigcur = $01BEE8				;pause96_stub
SkipStrings = $01D7F2				;hockey96_inter
BigFontMap = $1B89C8				;graphics96
BigFontMap3 = $1B9416				;graphics96
ClearMenuBox = $1E2EAA				;summary96
ConvertByteToDigits = $0230C4				;trade96_stub
DigitFontMap = $1B9ED8				;graphics96
DrawScreenSprite = $01218A				;options96_stub
FoxBannerMap = $1BCF78				;graphics96
GetRosterName = $0101E6				;players96_stub
HockeyNewsBannerMap = $1BD5E6				;graphics96
LoadScreenSprite = $01217A				;create96_stub
PauseBgBitmap = $1BBBEC				;graphics96
PauseRinkMap = $1BA4BE				;graphics96
PauseSprites = $1BCBFA				;graphics96
PushNumberWidth = $01BE1C				;goal96_box_stub
PushTime = $01BD84				;penalty96_stub
RosterFont = $179168				;graphics96
SmallLogoPtrs = $012CDE				;teamgfx96
VBlank_SpriteFade = $1E2E76				;awards96_show_stub
Vmaddr = $01B678				;season96_stub
dobitmap = $01B692				;lines96_bar_stub
eraser = $01B976				;goal96_box_stub
orjoy = $01B2C4				;hockey96_stub
printbigcurz = $01BEC4				;video96
printcur = $01BC84				;create96_stub
printsmallz = $01BA2E				;pause96_stub
printz = $01BB8E				;goal96_box_stub
setVram = $01B57E				;create96_stub
song = $088586				;goal96_box_stub


; Main segment code
	include	engine\pause96_return.asm
