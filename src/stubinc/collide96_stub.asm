;	Segment build for engine\collide96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$01D7FE

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
checkfight = $00B6A0		;fight96
assinsert = $01A3D0		;logic96_vec
assreplace = $01A3DA		;logic96_vec
vtoa = $01A3EE		;logic96_vec
GetHot = $01A458		;logic96_vec
SetSPA = $01A614		;skate96
randomd0 = $01B0A6		;video96
sfx = $088470		;sound96
song = $088586		;sound96
stop_current_song = $0885FC		;sound96
newcheck = $0887E4		;sound96
wallcollduringcheck = $1D72F6		;code96_14
LockScroll = $016786		;control96
setc1player = $016C52		;control96
setc2player = $016C5C		;control96
setc3player = $016C68		;control96
setc4player = $016C74		;control96
EndPenaltyShotPlay = $01971A		;shootout96
puckflip = $019F3E		;logic96_vec
randomd0s = $01B09A		;video96
sroot = $01B0DE		;video96
AddPenalty2 = $01C1D2		;penalty96
Stop4Pen = $01C784		;penalty96
PenGoalStuff = $01CC52		;penalty96
printscores1 = $01D062		;penalty96
ChkShotStat = $01D218		;lines96_bar
ChooseSong = $088688		;sound96
StartArenaAnim = $1D8A86		;shootout96_path
getFgtbyte = $1D9062		;code96_15
chkFgtBit1 = $1D906C		;code96_15
EndOneTimer = $1D9376		;code96_15
RandomInjuryGames = $1E8794		;injury96
SPA0F14 = $F14		;SPA value (frames96)
SPA12EC = $12EC		;SPA value (frames96)
SPA15B8 = $15B8		;SPA value (frames96)
SPA17E4 = $17E4		;SPA value (frames96)
SPA1F76 = $1F76		;SPA value (frames96)
SPA2576 = $2576		;SPA value (frames96)
SPA26C8 = $26C8		;SPA value (frames96)
SPAboardleft = $2360		;SPA value (frames96)
SPAboardmidl = $2084		;SPA value (frames96)
SPAboardmidr = $24C4		;SPA value (frames96)
AddPenalty = $01C192		;penalty96
PenShotChk = $01C3E0		;penalty96
DoubleMinorChk = $01C3C6		;penalty96


; Main segment code
	include	engine\collide96.asm
