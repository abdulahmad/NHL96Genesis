;	Segment build for engine\faceoff96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$0099CA

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
SPAfaceoff = $2126					;SPA value (frames96)
SPAfaceoffr = $2150					;SPA value (frames96)
SetSPA = $01A614					;skate96
dobitmap = $01B692					;video96
Framer = $01B9B0					;video96
printsmallz = $01BA2E				;video96
printz = $01BB8E					;video96
print = $01BBA0						;video96
SkipStrings = $01D7F2				;hockey96_inter
linelist = $023342					;lines96_list
FaceOffMap = $091D46				;graphics96
assexit = $01A3BE					;code96_15_stub
assreplace = $01A3DA				;collide96_stub
DecompressGraphicsPlain = $01B730	;pause96_return_stub
dirtab = $01AE60					;input96_shot_stub
randomd0 = $01B0A6					;playoff96_stub
sfx = $088470						;collide96_stub
AssignPads = $019966				;shootout96_stub
assinsert = $01A3D0					;collide96_stub
checkwindow = $01679A				;control96
ClearBigScore = $1E7A78				;goal96_box_stub
ClrHor = $01D01E					;pause96_stub
CompLine = $019868					;logic96_pull
EndArenaAnim = $1D8AC0				;shootout96_path
forceblack = $01AF52				;pause96_stub
forcepldata = $01FD82				;players96
LeadSong = $1D9748					;code96_15
printscores1 = $01D062				;collide96_stub
ResetBench = $01FDF4				;lines96_bar_stub
resetplstuff = $021430				;display96
SetLCmode = $00EC30					;input96_stub
setpersonel = $01FB52				;shootout96_stub
ShowBigScore = $1E78C4				;goal96_box_stub
song = $088586						;goal96_box_stub
SPAglide = $856						;frames96
SprSort = $0213AE					;display96
StartArenaAnim = $1D8A86			;goal96_box_stub
updatefaceoff = $019B16				;logic96_pull
vtoa = $01A3EE						;collide96_stub
ChooseSong = $088688				;collide96_stub
PeriodOver = $0215DC				;hockey96_open
PickFaceoffDirection = $1D9094				;code96_15
ReturnGoalies = $0197EA				;shootout96_stub
SetFaceoffAnim = $1D8AB4				;shootout96_path
SetLCmode2 = $00EC6E				;lines96
Stop4Pen = $01C784				;collide96_stub
chkFgtBit1ShotsLead = $1D90E2				;code96_15
clockcontPuckAssignments = $014BDC				;hockey96
lcfound = $00EE92				;lines96


; Main segment code
	include	engine\faceoff96.asm
