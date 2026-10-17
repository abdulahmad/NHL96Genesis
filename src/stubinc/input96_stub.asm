;	Segment build for engine\input96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$00A4DC

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
faceoffinput = $0099CA				;faceoff96
rtss7 = $00A3DA						;faceoff96
SetShotMode = $00F496				;input96_shot
ShotMode = $00F530					;input96_shot
lineinput = $00EE0E					;lines96
passmode = $00F8D2					;input96_shot
setpassmode = $00F898				;input96_shot
fightinput = $00C26C				;fight96
SetLCmode = $00EC30					;lines96
SPAlist = $005F96					;frames96
SPAgdive = $49A						;SPA value (frames96)
SPAgglover = $12E					;SPA value (frames96)
SPAgglovel = $1CA					;SPA value (frames96)
SPAgstackr = $440					;SPA value (frames96)
SPAgstackl = $3E6					;SPA value (frames96)
SPAgstickr = $266					;SPA value (frames96)
SPAgstickl = $20C					;SPA value (frames96)
SPA099A = $99A						;SPA value (frames96)
SPAhook = $1792						;SPA value (frames96)
SPA288C = $288C						;SPA value (frames96)
startpause1 = $014D6E				;pause96
startpause2 = $014D74				;pause96
startpause3 = $014D7C				;pause96
startpause4 = $014D84				;pause96
FindGoalie = $0168B8				;control96
burst = $016934						;control96
holdplayer = $016988				;control96
chgplayer = $016A46					;control96
setc1player = $016C52				;control96
setc2player = $016C5C				;control96
setc3player = $016C68				;control96
setc4player = $016C74				;control96
setpads = $016D6A					;control96
goaliesave = $017C58				;logic96_puck
checkob = $0187D4					;logic96_puck
assreplace = $01A3DA				;logic96_vec
vtoa = $01A3EE						;logic96_vec
SetSPA = $01A614					;skate96
doplayeracc = $01A62A				;skate96
sroot = $01B0DE						;video96
ReadJoy1 = $01B348					;video96
ReadJoy2 = $01B360					;video96
ReadJoy3 = $01B378					;video96
ReadJoy4 = $01B390					;video96
checkcoll = $01D7FE					;collide96
doassignment = $024380				;logic96_do
PuckOnAttackHalf = $1D6B66			;code96_14
ShortenMsgTimer = $1D8676			;shootout96_path
sub_1D920A = $1D920A				;code96_15


; Main segment code
	include	engine\input96.asm
