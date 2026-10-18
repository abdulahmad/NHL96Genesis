;	Segment build for engine\lines96_bar.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$01D14E

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
dobitmap = $01B692					;video96
rtss2 = $01F84A						;collide96
ResetBench = $01FDF4				;players96
priolist = $023426					;players96_sub
EnergyBarMap = $13D290				;graphics96
ZeroLong = $000772					;main96


; Main segment code
	include	engine\lines96_bar.asm
