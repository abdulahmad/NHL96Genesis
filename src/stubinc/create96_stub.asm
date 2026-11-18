;	Segment build for front\create96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1DD916

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
PAttribOverallMask = $023456		;setup96_attr
GAttribOverallMask = $0235B8		;setup96_attr
ClearSRAMBytes = $024208			;sram96
ControllerBgMap = $173C7A			;graphics96
CreateLetterGrid = $1E6B04			;records96
CreateRatingsBgMap = $195086		;graphics96
CreateRatingsSprites = $1969B4		;graphics96
CreateTitleMap = $1929FA			;graphics96
DecompressGraphicsPlain = $01B730	;pause96_return_stub
DeleteStatSlot = $1DD4B6			;trade96_edit
dobitmap = $01B692					;lines96_bar_stub
eraser = $01B976					;goal96_box_stub
GetGoalieCountD7 = $015774			;playoff96_stub
GetJerseyNumber = $0102B8			;players96_stub
GetPlayerCountD7 = $0157B2			;season96_menu_stub
IceBgMap = $170B0C					;graphics96
LoadScreenSprite = $01217A			;options96_stub
MakeSRAMChecksum = $0241AA			;sram96
orjoy = $01B2C4						;hockey96_stub
printbigz = $01BED6					;season96_stub
printcur = $01BC84					;season96_menu_stub
printcurz = $01BC72					;options96_stub
printsmall = $01BA40				;title96_stub
printsmallz = $01BA2E				;pause96_stub
printz = $01BB8E					;goal96_box_stub
PStatsPal = $17C2AE					;graphics96
randomd0 = $01B0A6					;playoff96_stub
ReadSRAM = $0241E8					;sram96
ReleasePlayersSprites = $1997AE		;graphics96
ReleasePlayersTitleMap = $197A60	;graphics96
setVram = $01B57E					;title96_stub
SignReleaseBgMap = $198260			;graphics96
SPAturnl = $2020					;frames96
SPAturnr = $2052					;frames96
WriteSRAM = $024188					;sram96
BigFontMap4 = $17B680				;graphics96
CreateBgMap = $19321A				;graphics96
CreateSprites = $194C48				;graphics96
DrawScreenSprite = $01218A				;options96_stub
DrawTeamLogoD7 = $012BB2				;awards96_show_stub
ExtractTradedPlayer = $1DD212				;trade96_edit
FillTradeRosterList = $1DCEAE				;trade96_edit
FindHeldMenuPad = $01B282				;title96_stub
FormatPlayerNameD7 = $01017A				;season96_menu_stub
GAttribGloveLeft = $02367E				;setup96_attr
GAttribGloveRight = $023668				;setup96_attr
GAttribOffAwareness = $023610				;setup96_attr
GAttribSpeed = $0235CE				;setup96_attr
GAttribStickLeft = $023652				;setup96_attr
GAttribStickRight = $02363C				;setup96_attr
GAttribWeight = $023694				;setup96_attr
GetCreatedName = $0101DC				;awards96_show_stub
GetPositionSlot = $0103AA				;lines96_set_stub
InsertStatSlot = $1DD7D4				;trade96_edit
InsertTradedPlayer = $1DD516				;trade96_edit
PAttribAggressiveness = $02355E				;setup96_attr
PAttribChecking = $02358A				;setup96_attr
PAttribDefAwareness = $0234C4				;setup96_attr
PAttribEndurance = $023548				;setup96_attr
PAttribHanded = $023498				;setup96_attr
PAttribPassAccuracy = $023506				;setup96_attr
PAttribShotAccuracy = $0234F0				;setup96_attr
PAttribShotPower = $0234DA				;setup96_attr
PAttribSpeed = $023482				;setup96_attr
PAttribStickHandling = $02351C				;setup96_attr
PAttribWeight = $023532				;setup96_attr
PStatsPalette = $1DBB92				;options96_stub
PositionLetters = $1DD8FE				;trade96_edit
PrintSmallListItem = $01D7EA				;hockey96_inter
ProcessInputWithRepeat = $01B320				;pause96_stub
PushNumber = $01BDE8				;setup96_stub
PushNumberWidth = $01BE1C				;goal96_box_stub
RatingToWeight = $01545A				;setup96
ReadJoy1 = $01B348				;pause96_stub
ReadJoy2 = $01B360				;pause96_stub
ReadJoy3 = $01B378				;pause96_stub
ReadJoy4 = $01B390				;pause96_stub
RosterFont = $179168				;graphics96
SetMenuScroll = $012640				;trade96_edit_stub
SignPlayersSprites = $19762A				;graphics96
SignPlayersTitleMap = $196E0A				;graphics96
SkipStrings = $01D7F2				;hockey96_inter
SmallFontMap2 = $17A164				;graphics96
SoftClampCoord = $1D9302				;code96_15
VBlank_Menus = $012D46				;teamgfx96
WaitMenuFrame = $1DCC8A				;trade96_edit
clearTeamStats = $021482				;control96_team
forceblack = $01AF52				;pause96_stub


; Main segment code
	include	front\create96.asm
