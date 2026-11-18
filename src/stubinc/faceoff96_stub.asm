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
SPAfaceoff = $2126					;SPA value (frames96)
SPAfaceoffr = $2150					;SPA value (frames96)
SetSPA = $01A614					;skate96
dobitmap = $01B692					;video96
Framer = $01B9B0					;video96
printsmallz = $01BA2E				;video96
printz = $01BB8E					;video96
print = $01BBA0						;video96
SkipStrings = $01D7F2				;hockey96_inter
linelist = $023342					;lines96_list
FaceOffMap = $091D46				;graphics96
assexit = $01A3BE					;code96_15_stub
assreplace = $01A3DA				;collide96_stub
DecompressGraphicsPlain = $01B730	;pause96_return_stub
dirtab = $01AE60					;input96_shot_stub
randomd0 = $01B0A6					;playoff96_stub
sfx = $088470						;collide96_stub


; Main segment code
	include	engine\faceoff96.asm
