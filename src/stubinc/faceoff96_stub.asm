;	Segment build for engine\faceoff96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$0099CA

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
SPA2126 = $2126						;SPA value (frames96)
SPA2150 = $2150						;SPA value (frames96)
SetSPA = $01A614					;skate96
dobitmap = $01B692					;video96
Framer = $01B9B0					;video96
printsmallz = $01BA2E				;video96
printz = $01BB8E					;video96
print = $01BBA0						;video96
SkipStrings = $01D7F2				;hockey96_inter
linelist = $023342					;lines96_list
FaceOffMap = $091D46				;graphics96


; Main segment code
	include	engine\faceoff96.asm
