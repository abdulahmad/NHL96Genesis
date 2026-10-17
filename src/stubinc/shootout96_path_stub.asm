;	Segment build for front\shootout96_path.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1D7FA6

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
GetTeamLines = $00EF02		;lines96_set
LockScroll = $016786		;control96
assinsert = $01A3D0		;logic96_vec
Framer = $01B9B0		;video96
printz = $01BB8E		;video96
print = $01BBA0		;video96
PushNumberWidth = $01BE1C		;video96
printbigz1 = $01C11A		;penalty96
printbigz2 = $01C12C		;penalty96
printbig1 = $01C13E		;penalty96
printbig2 = $01C15A		;penalty96
prefmes = $01C9FA		;penalty96
setplayer = $01FEA0		;players96
FormatPlayerNumInitial = $022F44		;middle96


; Main segment code
	include	front\shootout96_path.asm
