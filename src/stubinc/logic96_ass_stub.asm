;	Segment build for engine\logic96_ass.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$016DAE

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String
assexit = $01A3BE					;faceoff96_stub
AddPenalty2 = $01C1D2				;collide96_stub
AdjustFacingDirection = $017C06				;skate96_stub
AssignByPosition = $01FE58				;penalty96_stub
EvadePC = $01873A				;logic96_puck
GoalieInCrease = $02441E				;skate96_stub
SPAcelebrate = $000C7E				;frames96
SPAgdive = $00049A				;frames96
SPAglide = $000856				;frames96
SPAgready = $000712				;frames96
SPAstanley = $000CA0				;frames96
SPAwallleft = $000DBC				;frames96
SetSPA = $01A614				;collide96_stub
SprSort = $0213AE				;display96
Sroot = $01B0DE				;collide96_stub
TurnGoalieFromNet = $0243DA				;video96_font
assinsert = $01A3D0				;collide96_stub
assreplace = $01A3DA				;collide96_stub
chgplayer = $016A46				;control96
chk4pass = $0185E8				;logic96_puck
doplayeracc = $01A62A				;lines96_stub
goaliesave = $017C58				;input96_stub
playeracc = $01AB56				;fight96_stub
randomd0 = $01B0A6				;playoff96_stub
rtss2 = $01F84A				;playoff96_stub
setpads = $016D6A				;control96
setpadsExit = $016DAC				;control96
setplayer = $01FEA0				;shootout96_path_stub
sfx = $088470				;collide96_stub
skateto = $01A050				;logic96_puck_stub
stopna2 = $01AE16				;skate96
vtoa = $01A3EE				;collide96_stub


; Main segment code
	include	engine\logic96_ass.asm
