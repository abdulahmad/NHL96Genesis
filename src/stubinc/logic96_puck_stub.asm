;	Segment build for engine\logic96_puck.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$017C06

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
vtoa = $01A3EE						;logic96_vec
SetSPA = $01A614					;skate96
PushRef = $01C978					;penalty96
rtss2 = $01F84A						;collide96
SPA0074 = $74						;SPA value (frames96)
SPA0170 = $170						;SPA value (frames96)
SPA02C0 = $2C0						;SPA value (frames96)
SPA031A = $31A						;SPA value (frames96)
SPAgglovel = $1CA					;SPA value (frames96)
SPAgglover = $12E					;SPA value (frames96)
SPAgstackl = $3E6					;SPA value (frames96)
SPAgstackr = $440					;SPA value (frames96)
SPAgstickl = $20C					;SPA value (frames96)
SPAgstickr = $266					;SPA value (frames96)


; Main segment code
	include	engine\logic96_puck.asm
