;	Segment build for engine\replay96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$01581C

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
ReadJoy1 = $01B348					;video96
ReadJoy2 = $01B360					;video96
ReadJoy3 = $01B378					;video96
ReadJoy4 = $01B390					;video96
dobitmap = $01B692					;lines96_bar_stub
eraser = $01B976					;goal96_box_stub
forceblack = $01AF52				;pause96_stub
printz = $01BB8E					;goal96_box_stub
ReplayIconMap = $140AFE				;graphics96
RestoreGameScreen = $1E2742			;pause96_return
revframetbl = $1D579E				;graphics96
setvideo = $02034A					;display96
SoundBanks = $027026				;pause96_stub
SoundCmd = $08839E					;pause96_stub
SprSort = $0213AE					;display96
stop_current_song = $0885FC			;collide96_stub
Z80Program = $025500				;pause96_stub


; Main segment code
	include	engine\replay96.asm
