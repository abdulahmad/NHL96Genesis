;	Segment build for engine\goal96_box.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$022820

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
printz = $01BB8E		;video96
rtss2 = $01F84A		;collide96
song = $088586		;sound96
Penaltylist = $00E818		;logic96
lcfound2 = $00EEC4		;lines96
eraser = $01B976		;video96
Framer = $01B9B0		;video96
print = $01BBA0		;video96
PushNumberWidth = $01BE1C		;video96
printbigz2 = $01C12C		;penalty96
printbig2 = $01C15A		;penalty96
prefmes = $01C9FA		;penalty96
ErasePowerPlayBox = $01CFE4		;penalty96
CountGoalies = $1D7D0E		;code96_14
ShootoutModeBox = $1D7FA6		;shootout96_path
StartArenaAnim = $1D8A86		;shootout96_path
PrintPlayerAssists = $1D8EF6		;code96_15
PrintPlayerGoals = $1D8F0C		;code96_15
ShowBigScore = $1E78C4		;middle96_clock
ClearBigScore = $1E7A78		;middle96_clock
FormatPlayerName = $022FB2		;middle96
FormatPlayerNumInitial = $022F44		;middle96
GetPlayerNumInitial = $022ED6		;middle96
getname = $022E92		;middle96


; Main segment code
	include	engine\goal96_box.asm
