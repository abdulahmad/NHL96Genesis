;	Segment build for engine\fight96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$00B6A0

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
assinsert = $01A3D0					;logic96_vec
SetSPA = $01A614					;skate96
playeracc = $01AB56					;skate96
eraser = $01B976					;video96
printz = $01BB8E					;video96
AddPenalty2 = $01C1D2				;penalty96
setd0player = $01F662				;collide96
SPA3128 = $3128						;SPA value (frames96)
SPA3182 = $3182						;SPA value (frames96)
SPA3252 = $3252						;SPA value (frames96)
SPA3300 = $3300						;SPA value (frames96)
SPA333A = $333A						;SPA value (frames96)
SPA34D0 = $34D0						;SPA value (frames96)
SPAfgrab = $328C					;SPA value (frames96)
SPAfhigh = $31BC					;SPA value (frames96)
SPAfight = $30A4					;SPA value (frames96)
SPAflow = $32C6						;SPA value (frames96)

; Main segment code
	include	engine\fight96.asm
