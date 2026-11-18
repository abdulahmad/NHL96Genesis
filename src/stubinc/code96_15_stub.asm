;	Segment build for code96_15.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1D8E5C

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
printz = $01BB8E					;video96
print = $01BBA0						;video96
PushNumberWidth = $01BE1C			;video96
assexit = $01A3BE					;logic96_vec
SetSPA = $01A614					;skate96
forceblack = $01AF52				;video96
waitx = $01B152						;video96
setVram_0 = $01B594					;video96
dobitmap = $01B692					;video96
DecompressGraphicsPlain = $01B730	;video96
AssignBySavedPos = $01FE78			;players96
vb2 = $0202C4						;display96
ReplayIconMap = $140AFE				;graphics96
HiScoreBgMap = $1468D6				;graphics96
HiScoreImg = $147896				;graphics96
SPAboardbot = $2412					;SPA value (frames96)
SPAboardleft = $2360				;SPA value (frames96)
SPAboardmidl = $2084				;SPA value (frames96)
SPAboardmidr = $24C4				;SPA value (frames96)
SPAboardtop = $22AE					;SPA value (frames96)
SPAglide = $856						;SPA value (frames96)
vtoa = $01A3EE						;collide96_stub
GetLogName = $1E6B24				;records96
randomd0 = $01B0A6					;playoff96_stub
BigFontMap2 = $17AA72				;graphics96
BigFontMap4 = $17B680				;graphics96
ChooseSong = $088688				;collide96_stub
CopyString = $1D7A90				;code96_14
DrawScreenSprite = $01218A				;options96_stub
IceBgMap = $170B0C				;graphics96
LoadScreenSprite = $01217A				;create96_stub
ProcessInputWithRepeat = $01B320				;pause96_stub
ReadStandings = $01161E				;awards96_stub
SeasonMenuScreen = $0122A4				;season96_menu_stub
SetMenuScroll = $012640				;trade96_edit_stub
SmallFontMap2 = $17A164				;graphics96
SortStandings = $1D9D92				;awards96_show_stub
SortStandingsHeaders = $1D9E12				;season96_stand
StandingsBgMap = $181456				;graphics96
StandingsGroups = $1D9D12				;awards96_show_stub
StandingsPoints = $1D9CC6				;awards96_show_stub
StandingsSprites = $183024				;graphics96
StandingsTitleMap = $180C36				;graphics96
TeamBlockPtrs = $012BFE				;teamgfx96
VBlank_Menus = $012D46				;teamgfx96
appendz = $01BE78				;middle96_stub
appstring = $01BE80				;middle96_stub
eraser = $01B976				;goal96_box_stub
orjoy = $01B2C4				;hockey96_stub
printbigz = $01BED6				;create96_stub
printcurz = $01BC72				;create96_stub
printsmallz = $01BA2E				;pause96_stub
setVram = $01B57E				;create96_stub


; Main segment code
	include	code96_15.asm
