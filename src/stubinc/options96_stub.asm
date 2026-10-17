;	Segment build for front\options96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1E0DDE

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
printz = $01BB8E		;video96
WriteSRAM = $024188		;sram96
MakeSRAMChecksum = $0241AA		;sram96
ReadSRAM = $0241E8		;sram96
DrawScreenSprite = $01218A		;season96
SetMenuScroll = $012640		;season96
dobitmap = $01B692		;video96
DecompressGraphicsPlain = $01B730		;video96
LoadScreenSprite = $01217A		;season96
VBlank_Menus = $012D46		;teamgfx96
PrintMenuList2 = $01455A		;pause96_list
FindHeldMenuPad = $01B282		;video96
orjoy = $01B2C4		;video96
ProcessInputWithRepeat = $01B320		;video96
setVram = $01B57E		;video96
eraser = $01B976		;video96
printsmallz = $01BA2E		;video96
printcurz = $01BC72		;video96
maketree = $021CF4		;playoff96
ReadPassBits = $0221D4		;playoff96
ReadPassData = $022386		;playoff96
ControllerBgMap = $173C7A		;graphics96
RosterFont = $179168		;graphics96
SmallFontMap2 = $17A164		;graphics96
ReadSeasonHeader = $01149E		;season96
NewPO = $021C28		;playoff96
MainMenuTitleMap = $199BE4		;graphics96
MainMenuBgMap = $19A3E4		;graphics96
MainMenuSprites = $19C232		;graphics96
PuckAnimMap = $1C4C4E		;graphics96
ShootoutInit = $1D8180		;shootout96_path
PStatsPalette = $1DBB92		;season96_menu
PlayoffMenuScreen = $1DBBB2		;season96_menu


; Main segment code
	include	front\options96.asm
