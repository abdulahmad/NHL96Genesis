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


; Main segment code
	include	front\create96.asm
