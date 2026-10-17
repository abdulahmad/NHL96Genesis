;	Segment build for engine\skate96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$01A614

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
AdjustFacingDirection = $017C06		;logic96_puck
rtss2 = $01F84A						;collide96
getpde = $01FB24					;collide96
setpde = $01FB44					;collide96
GoalieInCrease = $02441E			;logic96_crease
stopfast = $1D6E0E					;code96_14
vtoa = $01A3EE						;logic96_vec
randomd0 = $01B0A6					;video96


; Main segment code
	include	engine\skate96.asm
