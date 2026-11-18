;	Segment build for front\season96_stand.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1D9CC6

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
PushNumberWidth = $01BE1C				;goal96_box_stub
SPAfweaveend = $003230				;frames96
SPAturnl = $002020				;frames96
SkipStrings = $01D7F2				;hockey96_inter
TeamBlockPtrs = $012BFE				;teamgfx96
dobitmap = $01B692				;lines96_bar_stub
eraser = $01B976				;goal96_box_stub
printbig = $01BEEC				;stats96_stub
printz = $01BB8E				;goal96_box_stub


; Main segment code
	include	front\season96_stand.asm
