;	Segment build for engine\collide96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$01D7FE

; includes for stubs to replace removed code
	include	stubinc\ports.inc		;IO_* / VDP_* ports
	include	stubinc\equals.inc		;VDP status bits
	include	ram96.asm				;RAM map
	include	externs96.asm			;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac		;String

; External addresses outside, read from lst/nhl96.bin.
checkfight = $00B6A0				;fight96
assinsert = $01A3D0					;logic96_vec
assreplace = $01A3DA				;logic96_vec
vtoa = $01A3EE						;logic96_vec
GetHot = $01A458					;logic96_vec
SetSPA = $01A614					;skate96
randomd0 = $01B0A6					;video96
sfx = $088470						;sound96
song = $088586						;sound96
stop_current_song = $0885FC			;sound96
newcheck = $0887E4					;sound96
wallcollduringcheck = $1D72F6		;code96_14
LockScroll = $016786				;control96
setc1player = $016C52				;control96
setc2player = $016C5C				;control96
setc3player = $016C68				;control96
setc4player = $016C74				;control96
EndPenaltyShotPlay = $01971A		;shootout96
puckflip = $019F3E					;logic96_vec
randomd0s = $01B09A					;video96
Sroot = $01B0DE						;video96
AddPenalty2 = $01C1D2				;penalty96
Stop4Pen = $01C784					;penalty96
PenGoalStuff = $01CC52				;penalty96
printscores1 = $01D062				;penalty96
ChkShotStat = $01D218				;lines96_bar
ChooseSong = $088688				;sound96
StartArenaAnim = $1D8A86			;shootout96_path
getFgtbyte = $1D9062				;code96_15
chkFgtBit1 = $1D906C				;code96_15
EndOneTimer = $1D9376				;code96_15
RandomInjuryGames = $1E8794			;injury96
SPAflip = $F14						;SPA value (frames96)
SPAstumble = $12EC					;SPA value (frames96)
SPAcrosscheck = $15B8				;SPA value (frames96)
SPAinjuryfall = $17E4				;SPA value (frames96)
SPAinjury1 = $1F76					;SPA value (frames96)
SPAfallfwd = $2576					;SPA value (frames96)
SPAfallback = $26C8					;SPA value (frames96)
SPAboardleft = $2360				;SPA value (frames96)
SPAboardmidl = $2084				;SPA value (frames96)
SPAboardmidr = $24C4				;SPA value (frames96)
SPAHold = $169C						;SPA value (frames96)
SPAHold2 = $164A					;SPA value (frames96)
SPAHold3 = $16EE					;SPA value (frames96)
SPAbglass = $2B88					;SPA value (frames96)
SPAburst = $2C5C					;SPA value (frames96)
SPAflail = $139E					;SPA value (frames96)
SPAflailpuck = $BBE					;SPA value (frames96)
SPAgsweepchk = $52C					;SPA value (frames96)
SPAhook = $1792						;SPA value (frames96)
SPAhook2 = $1740					;SPA value (frames96)
SPAinjury2 = $188E					;SPA value (frames96)
SPAinjuryfall2 = $1EAC				;SPA value (frames96)
SPAsiren = $28CE					;SPA value (frames96)
SPAsiren2 = $2920					;SPA value (frames96)
SPAsweepchk = $216A					;SPA value (frames96)
AddPenalty = $01C192				;penalty96
PenShotChk = $01C3E0				;penalty96
DoubleMinorChk = $01C3C6			;penalty96
a2touchpuck = $019DA2				;logic96_pull
SPA03BC = $3BC						;frames96
SPAcatch = $1442					;frames96
SPAfweaveend = $3230				;frames96
SPAgdive = $49A						;frames96
SPAgskate = $640					;frames96
SPAgstackr = $440					;frames96
GetHot2a = $01A4B2				;logic96_vec
GetHot2b = $01A528				;logic96_vec
GetHot2c = $01A59E				;logic96_vec
onetimershot = $1D6BE6				;code96_14


; Main segment code
	include	engine\collide96.asm
