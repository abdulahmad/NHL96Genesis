;	Segment build for engine\logic96_puck.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$017C06

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
vtoa = $01A3EE						;logic96_vec
SetSPA = $01A614					;skate96
PushRef = $01C978					;penalty96
rtss2 = $01F84A						;collide96
SPAgglover2 = $74					;SPA value (frames96)
SPAgcatchlow = $170					;SPA value (frames96)
SPAgglovel2 = $2C0					;SPA value (frames96)
SPAgblock = $31A					;SPA value (frames96)
SPAgglovel = $1CA					;SPA value (frames96)
SPAgglover = $12E					;SPA value (frames96)
SPAgstackl = $3E6					;SPA value (frames96)
SPAgstackr = $440					;SPA value (frames96)
SPAgstickl = $20C					;SPA value (frames96)
SPAgstickr = $266					;SPA value (frames96)
assexit = $01A3BE					;logic96_ass_stub
assreplace = $01A3DA				;collide96_stub
donothing = $01731E					;fight96_stub
PuckOnAttackHalf = $1D6B66			;code96_14
randomd0 = $01B0A6					;playoff96_stub
SetShotMode = $00F496				;input96_stub
sfx = $088470						;collide96_stub
ShotMode = $00F530					;input96_stub
skateto = $01A050					;fight96_stub
AvgCline = $01D1DE				;lines96_bar
CanBlock = $1D98EE				;code96_15
CompLine = $019868				;faceoff96_stub
GetHot = $01A458				;collide96_stub
HoldplayerImpact = $0169A6				;control96
PuckLeadPosition = $01A210				;logic96_vec
ReadGoaliePulled = $1D9352				;code96_15
ShootoutShootCheck = $1D8CF6				;shootout96_path
SkatePath = $1D8C6E				;shootout96_path
assgoaliecpu = $0175BE				;logic96_stub
assinsert = $01A3D0				;collide96_stub
burst = $016934				;control96
check4bench = $016DAE				;logic96_ass
dopass = $00F8F6				;code96_14_stub
printscores1 = $01D062				;collide96_stub
randomd0s = $01B09A				;collide96_stub
setpersonel = $01FB52				;shootout96_stub
shotdirmathAssShoot = $00F466				;input96_shot
skatetoIntercept = $01A24A				;logic96_vec


; Main segment code
	include	engine\logic96_puck.asm
