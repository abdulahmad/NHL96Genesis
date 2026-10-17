;	Segment build for main96.asm: sets its origin and the outside routines and data it uses,
;	then includes main96.asm on its own for checking against the ROM.

; region code
	org	$000000

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only

; External addresses outside, read from lst/nhl96.bin.
VBjsr = $000776						;vertical blank interrupt, jumps through vbint
Begin = $01464C						;hockey96
IRQ7 = $0202E4						;display96
AdrErr = $023144					;crash96
InvOpCode = $02316C					;crash96
DivBy0 = $023196					;crash96
ValidationRoutine = $1E9038			;checksum96


; Main segment code
	include	main96.asm
