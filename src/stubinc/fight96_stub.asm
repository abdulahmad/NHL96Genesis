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
SPAfightstance = $3128				;SPA value (frames96)
SPAfmash = $3182					;SPA value (frames96)
SPAfpunchA = $3252					;SPA value (frames96)
SPAfpunchfinal = $3300				;SPA value (frames96)
SPAfpunchB = $333A					;SPA value (frames96)
SPAfmashwin = $34D0					;SPA value (frames96)
SPAfgrab = $328C					;SPA value (frames96)
SPAfhigh = $31BC					;SPA value (frames96)
SPAfight = $30A4					;SPA value (frames96)
SPAflow = $32C6						;SPA value (frames96)
appendz = $01BE78					;middle96_stub
appstring = $01BE80					;middle96_stub
box = $022E58						;lines96_stub
check4check = $018D32				;logic96_puck
donothing = $01731E					;logic96_ass
Framer = $01B9B0					;goal96_box_stub
getname = $022E92					;goal96_box_stub
lcfound2 = $00EEC4					;goal96_box_stub
print = $01BBA0						;goal96_box_stub
randomd0 = $01B0A6					;playoff96_stub
sfx = $088470						;collide96_stub
skateto = $01A050					;logic96_vec
song = $088586						;goal96_box_stub
SPAfgrabhit1 = $3374				;frames96
SPAfgrabhit2 = $33AE				;frames96
SPAfgrabhit3 = $33E8				;frames96
SPAflowhit1 = $3422					;frames96
SPAflowhit2 = $345C					;frames96
SPAflowhit3 = $3496					;frames96
SPAfpunchAhit1 = $350A				;frames96
SPAfpunchAhit2 = $3544				;frames96
SPAfpunchAhit3 = $357E				;frames96
SPAfpunchBhit1 = $35B8				;frames96
SPAfpunchBhit2 = $35F2				;frames96
SPAfpunchBhit3 = $362C				;frames96
Sroot = $01B0DE						;collide96_stub


; Main segment code
	include	engine\fight96.asm
