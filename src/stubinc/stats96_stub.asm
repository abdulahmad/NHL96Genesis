;	Segment build for front\stats96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1E1B18

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
eraser = $01B976					;goal96_box_stub
FinalizeTextBuffer = $0230AA		;trade96_stub
GetNameandAttrib = $0151FA			;setup96
GetPlayerNamePointer = $0101C6		;middle96_stub
MakeSRAMChecksum = $0241AA			;sram96
PAttribColumns = $02342E			;setup96_attr
printbig = $01BEEC					;season96_stub
printsmallz = $01BA2E				;pause96_stub
printz = $01BB8E					;goal96_box_stub
BigFontMap4 = $17B680				;graphics96
DecompressGraphicsPlain = $01B730				;create96_stub
DrawScreenSprite = $01218A				;options96_stub
DrawTeamLogoD7 = $012BB2				;awards96_show_stub
EditLinesTitleMap = $19C628				;graphics96
ExitStatsScreen = $0154D4				;pause96_menu
FormatPlayerName = $022FB2				;goal96_box_stub
GetGoalieCount = $0157A2				;goal96_box_stub
GetPlayerCount = $0157F4				;players96_stub
IceBgMap = $170B0C				;graphics96
LineEditorBgMap = $19E7F6				;graphics96
LineEditorBgMap2 = $19CE08				;graphics96
LineEditorSprites = $1A0632				;graphics96
LineEditorSprites2 = $1A0244				;graphics96
LoadScreenSprite = $01217A				;create96_stub
PStatsPal = $17C2AE				;graphics96
ProcessInputWithRepeat = $01B320				;pause96_stub
ReadMenuJoy = $015CD8				;pause96_stub
RosterFont = $179168				;graphics96
SetMenuScroll = $012640				;trade96_edit_stub
SetOriginalLines = $02154E				;control96_team
SkipStrings = $01D7F2				;hockey96_inter
SmallFontMap2 = $17A164				;graphics96
VBlank_Menus = $012D46				;teamgfx96
dobitmap = $01B692				;lines96_bar_stub
linelist = $023342				;lines96_stub
orjoy = $01B2C4				;hockey96_stub
printbigz = $01BED6				;create96_stub
printcurz = $01BC72				;create96_stub
printsmall = $01BA40				;create96_stub
setVram = $01B57E				;create96_stub
vcountwait = $0151E0				;hockey96_inter_stub


; Main segment code
	include	front\stats96.asm
