;	Segment build for engine\logic96_pull.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$019782

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
rtss2 = $01F84A						;collide96
setpersonel = $01FB52				;players96
AddPenalty = $01C192				;collide96_stub
chgplayer = $016A46					;control96
eraser = $01B976					;goal96_box_stub
FindGoalie = $0168B8				;control96
getlinee = $01D19C					;lines96_bar
printz = $01BB8E					;goal96_box_stub
setc1player = $016C52				;control96
setc2player = $016C5C				;control96
setc3player = $016C68				;control96
setc4player = $016C74				;control96
AddPenalty2 = $01C1D2				;collide96_stub
GetHot = $01A458				;collide96_stub
UpdatePenaltyShotEnd = $019692				;shootout96
findpc = $019FCE				;logic96_vec
wallcollcheck = $01EFFA				;collide96


; Main segment code
	include	engine\logic96_pull.asm
