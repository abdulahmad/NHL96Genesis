;	Segment build for engine\lines96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$00EC30

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
rtss7 = $00A3DA		;faceoff96
loadTeamStruct = $01D328		;lines96_bar
doplayeracc = $01A62A		;skate96
eraser = $01B976		;video96
Framer = $01B9B0		;video96
printz = $01BB8E		;video96
print = $01BBA0		;video96
ErasePowerPlayBox = $01CFE4		;penalty96
printscores1 = $01D062		;penalty96
linebar = $01D14E		;lines96_bar
SkipStrings = $01D7F2		;hockey96_inter
setpersonel = $01FB52		;players96
box = $022E58		;goal96_box
linelist = $023342		;lines96_list
ClearBigScore = $1E7A78		;middle96_clock
rtss = $00F8D0		;input96_shot


; Main segment code
	include	engine\lines96.asm
