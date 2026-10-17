;	Segment build for engine\lines96_menu.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$023E54

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
rtss2 = $01F84A						;collide96
SetOriginalLines = $02154E			;control96_team
LoadTeamLine = $1E2310				;stats96
SaveTeamLine = $1E239E				;stats96


; Main segment code
	include	engine\lines96_menu.asm
