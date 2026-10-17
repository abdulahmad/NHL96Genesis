;	Segment build for front\season96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$010CB2

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String


; External addresses outside, read from lst/nhl96.bin.
WriteSRAMBits = $0096E8		;srambits96
ReadSRAMBits = $00975A		;srambits96
SimScore = $01051A		;trade96
SimGameStats = $01091A		;season96_sim
TeamBlockPtrs = $012BFE		;teamgfx96
TeamLogoPtrs = $012C6E		;teamgfx96
VBlank_Menus = $012D46		;teamgfx96
SeasonSchedule = $013558		;schedule96
ResolveDayGames = $013EA2		;awards96
GetTeamPOSlot = $0143A8		;awards96
GetGoalieCountD7 = $015774		;players96_count
randomd0 = $01B0A6		;video96
FindHeldMenuPad = $01B282		;video96
orjoy = $01B2C4		;video96
ProcessInputWithRepeat = $01B320		;video96
setVram = $01B57E		;video96
Vmaddr = $01B678		;video96
dobitmap = $01B692		;video96
DecompressGraphicsWithCallback = $01B724		;video96
DecompressGraphicsPlain = $01B730		;video96
eraser = $01B976		;video96
printsmallz = $01BA2E		;video96
printz = $01BB8E		;video96
PushNumberWidth = $01BE1C		;video96
printbigz = $01BED6		;video96
printbig = $01BEEC		;video96
NewPO = $021C28		;playoff96
GetShifter = $0224E2		;playoff96
WriteSRAM = $024188		;sram96
MakeSRAMChecksum = $0241AA		;sram96
ReadSRAM = $0241E8		;sram96
ClearSRAMBytes = $024208		;sram96
song = $088586		;sound96
ControllerBgMap = $173C7A		;graphics96
BigFontMap2 = $17AA72		;graphics96
SelectTeamSeasonBgMap = $17ECEA		;graphics96
SelectTeamSeasonSprites = $1808B8		;graphics96
SelectTeamTitleMap = $18C136		;graphics96
SelectTeamBgMap = $18C936		;graphics96
SelectTeamSprites = $18DE04		;graphics96
Create_HotCold_Table = $1D6F24		;code96_14
InitShooters = $1D8262		;shootout96_path
SetSframe = $1DA6C0		;season96_menu


; Main segment code
	include	front\season96.asm
