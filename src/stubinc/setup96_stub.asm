;	Segment build for engine\setup96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$0151FA

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String
CalcAttrib = $1D7DF8				;code96_14
GetInjuryGames = $1E887A			;injury96
getname = $022E92					;goal96_box_stub
GetPositionSlot = $0103AA			;lines96_set_stub
PosText = $1DE74C					;create96
printcur = $01BC84					;season96_menu_stub
printcurz = $01BC72					;options96_stub
PrintSmallListItem = $01D7EA		;hockey96_inter
PushNumber = $01BDE8				;video96
PushNumberWidth = $01BE1C			;goal96_box_stub
PushTime = $01BD84					;penalty96_stub
SkipStrings = $01D7F2				;hockey96_inter
SoftClampCoord = $1D9302				;code96_15


; Main segment code
	include	engine\setup96.asm
