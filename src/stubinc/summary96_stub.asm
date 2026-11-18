;	Segment build for front\summary96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1E2E76

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
DumpSpriteTable = $02031C			;display96
cramfade = $01AFD6					;video96
p_music_vblank = $024486			;sound96
AppendUserName = $1D7D62			;code96_14
GAttribOverall = $0235A6			;setup96_attr
GetNameandAttrib = $0151FA			;stats96_stub
PAttribOverall = $023444			;setup96_attr
printbig = $01BEEC					;stats96_stub
printsmallz = $01BA2E				;pause96_stub
printz = $01BB8E					;goal96_box_stub
ReadSRAM = $0241E8					;sram96
AppendTeamName = $1D7DCC				;code96_14
BigFontMap2 = $17AA72				;graphics96
BigFontMap4 = $17B680				;graphics96
ClearAttribDeltas = $1DF572				;create96
ClearWinRecords = $1D8ACE				;shootout96_path
ControllerBgMap = $173C7A				;graphics96
CopyStatsPalette = $1E2624				;stats96
CopyString = $1D7A90				;code96_14
DecompressGraphicsPlain = $01B730				;create96_stub
DrawScreenSprite = $01218A				;options96_stub
DrawSetupTeamBlock = $012B84				;season96_menu_stub
DrawTeamLogoD7 = $012BB2				;awards96_show_stub
EditLinesTitleMap = $19C628				;graphics96
FormatAndPrintTime = $01BD54				;video96
FormatPlayerName = $022FB2				;goal96_box_stub
FormatPlayerNameShort = $02300A				;middle96
FormatPlayerNumInitial = $022F44				;goal96_box_stub
FormatPlayerNumInitialShort = $022EF8				;middle96
GAttribColumns = $023590				;setup96_attr
GameStatsBgMap = $1A7ED6				;graphics96
GameStatsSprites = $1A98A4				;graphics96
GameStatsTitleMap = $1A76B6				;graphics96
GetGoalieCount = $0157A2				;goal96_box_stub
GetPlayerCount = $0157F4				;players96_stub
GetPositionSlot = $0103AA				;lines96_set_stub
IceBgMap = $170B0C				;graphics96
LineEditorBgMap = $19E7F6				;graphics96
LineEditorBgMap2 = $19CE08				;graphics96
LineEditorSprites = $1A0632				;graphics96
LineEditorSprites2 = $1A0244				;graphics96
LoadScreenSprite = $01217A				;create96_stub
PAttribColumns = $02342E				;stats96_stub
PStatsPalette = $1DBB92				;options96_stub
PenaltiesTitleMap = $1A5148				;graphics96
Penaltylist = $00E818				;goal96_box_stub
PeriodStatsMap = $1A6148				;graphics96
PeriodStatsTitleMap = $1A5928				;graphics96
PrintSmallListItem = $01D7EA				;hockey96_inter
ProcessInputWithRepeat = $01B320				;pause96_stub
PushNumber = $01BDE8				;setup96_stub
PushNumberWidth = $01BE1C				;goal96_box_stub
PushTime = $01BD84				;penalty96_stub
ReadMenuJoy = $015CD8				;pause96_stub
ReadNameLog = $1D7B50				;code96_14
RecordHoldersBgMap = $1AAC72				;graphics96
RecordHoldersSprites = $1AC3A0				;graphics96
RecordHoldersTitleMap = $1AA452				;graphics96
RosterFont = $179168				;graphics96
ScoringTitleMap = $1A4968				;graphics96
SeasonMenuScreen = $0122A4				;season96_menu_stub
SelectTeamSprites = $18DE04				;graphics96
SetMenuScroll = $012640				;trade96_edit_stub
ShootoutSetupTitleMap = $1A9C72				;graphics96
SmallFontMap2 = $17A164				;graphics96
SummaryBgMap = $1A2B1C				;graphics96
SummarySprites = $1A454A				;graphics96
TeamRosterBgMap = $1A0A58				;graphics96
TeamRosterSprites = $1A1EC6				;graphics96
TeamRosterTitleMap = $1A22FC				;graphics96
VBlank_Menus = $012D46				;teamgfx96
appendz = $01BE78				;middle96_stub
appstring = $01BE80				;middle96_stub
dobitmap = $01B692				;lines96_bar_stub
eraser = $01B976				;goal96_box_stub
orjoy = $01B2C4				;hockey96_stub
printbigcurz = $01BEC4				;video96
printbigz = $01BED6				;create96_stub
printcur = $01BC84				;create96_stub
printcurz = $01BC72				;create96_stub
printsmall = $01BA40				;create96_stub
restoreteams = $01481A				;hockey96
setVram = $01B57E				;create96_stub
vcountwait = $0151E0				;hockey96_inter_stub


; Main segment code
	include	front\summary96.asm
