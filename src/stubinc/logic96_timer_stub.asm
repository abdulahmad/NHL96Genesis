;	Segment build for engine\logic96_timer.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$1D6622

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
puckflip = $019F3E					;logic96_vec
randomd0 = $01B0A6					;video96
Sroot = $01B0DE						;video96
CheckOneTimerFacing = $1D6D10		;code96_14
EndOneTimer = $1D9376				;code96_15
setc1player = $016C52				;control96
setc2player = $016C5C				;control96
setc3player = $016C68				;control96
setc4player = $016C74				;control96
SetSPA = $01A614					;collide96_stub
SPAshotb = $FB6						;frames96
SPAshotf = $11BA					;frames96
vtoa = $01A3EE						;collide96_stub


; Main segment code
	include	engine\logic96_timer.asm
