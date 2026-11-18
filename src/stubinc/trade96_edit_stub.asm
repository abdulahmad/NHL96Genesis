;	Segment build for front\trade96_edit.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1DC03C

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
SignFreeAgents = $1DFBAC			;create96
ReleasePlayers = $1E0536			;create96
CreatePlayer = $1DD916				;create96
eraser = $01B976					;goal96_box_stub
GetPlayerCountD7 = $0157B2			;create96_stub
MakeSRAMChecksum = $0241AA			;sram96
Opening2 = $02174A					;hockey96_open
ProcessInputWithRepeat = $01B320	;pause96_stub
ReadJoy1 = $01B348					;pause96_stub
ReadJoy2 = $01B360					;pause96_stub
ReadJoy3 = $01B378					;pause96_stub
ReadJoy4 = $01B390					;pause96_stub
ReadSRAM = $0241E8					;sram96
ReadSRAMBitWords = $010F02			;playoff96_stub
SetMenuScroll = $012640				;options96_stub
SPAboardbot = $2412					;frames96
SPAfpunchBhit1 = $35B8				;frames96
WriteSRAM = $024188					;sram96
WriteSRAMBitWords = $010F22			;playoff96_stub
BigFontMap4 = $17B680				;graphics96
CalcAttrib = $1D7DF8				;code96_14
CheckTeamLines = $1E0D86				;create96
DecompressGraphicsPlain = $01B730				;create96_stub
DrawScreenSprite = $01218A				;options96_stub
FormatPlayerNameD7 = $01017A				;season96_menu_stub
GAttribOverallMask = $0235B8				;create96_stub
GetGoalieCountD7 = $015774				;playoff96_stub
GetJerseyNumber = $0102B8				;create96_stub
GetJerseyNumberRead = $010378				;trade96
GetPositionSlot = $0103AA				;lines96_set_stub
IceBgMap = $170B0C				;graphics96
LoadScreenSprite = $01217A				;create96_stub
PAttribOverallMask = $023456				;create96_stub
PStatsPalette = $1DBB92				;options96_stub
PrintSmallListItem = $01D7EA				;hockey96_inter
PushNumberWidth = $01BE1C				;goal96_box_stub
ReadCreatedPlayerSRAM = $0104AC				;trade96
ReadSeasonHeader = $01149E				;awards96_stub
RosterFont = $179168				;graphics96
SmallFontMap2 = $17A164				;graphics96
SoftClampCoord = $1D9302				;code96_15
TeamBlockPtrs = $012BFE				;teamgfx96
TradeBgMap = $190EFE				;graphics96
TradeSprites = $19262C				;graphics96
TradeTitleMap = $1906FE				;graphics96
VBlank_Menus = $012D46				;teamgfx96
WriteCreatedPlayerSRAM = $0104CA				;trade96
clearTeamStats = $021482				;control96_team
dobitmap = $01B692				;lines96_bar_stub
orjoy = $01B2C4				;hockey96_stub
printbigz = $01BED6				;create96_stub
printcurz = $01BC72				;create96_stub
printsmall = $01BA40				;create96_stub
printsmallz = $01BA2E				;pause96_stub
printz = $01BB8E				;goal96_box_stub
setVram = $01B57E				;create96_stub


; Main segment code
	include	front\trade96_edit.asm
