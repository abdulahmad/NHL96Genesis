;	Segment build for front\shootout96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$019018

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
LockScroll = $016786				;control96
CountShootoutGoals = $1D8208		;shootout96_path
AssignPads = $019966				;logic96_pull
assinsert = $01A3D0					;collide96_stub
assreplace = $01A3DA				;collide96_stub
checkwindow = $01679A				;control96
ChooseSong = $088688				;collide96_stub
ClrHor = $01D01E					;pause96_stub
DecompressGraphicsPlain = $01B730	;create96_stub
forceblack = $01AF52				;pause96_stub
GetPlayerCountD7 = $0157B2			;create96_stub
GetRosterName = $0101E6				;players96_stub
NextShooter = $1D81B2				;shootout96_path
ResetBench = $01FDF4				;lines96_bar_stub
resetplstuff = $021430				;display96
ReturnGoalies = $0197EA				;logic96_pull
setc1player = $016C52				;control96
setc2player = $016C5C				;control96
setpersonel = $01FB52				;logic96_pull_stub
setplayer = $01FEA0					;shootout96_path_stub
SetSPA = $01A614					;collide96_stub
SetupPenaltyShot = $01FD06			;players96
song = $088586						;goal96_box_stub
SPAglide = $856						;frames96
SprSort = $0213AE					;display96
StartShootoutPath = $1D8B60			;shootout96_path
Stop4Pen = $01C784					;collide96_stub
vtoa = $01A3EE						;collide96_stub
AddPenalty2 = $01C1D2				;collide96_stub


; Main segment code
	include	front\shootout96.asm
