;	Segment build for hockey96.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$01464C

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
Detect4WayPlay = $00B5C8		;fourway96
sub_FD14 = $00FD14		;input96_shot
sub_FFD0 = $00FFD0		;input96_shot
updatereplay = $0161E2		;replay96
rtss8 = $0162EE		;replay96
updateplayers = $0162F0		;control96
LockScroll = $016786		;control96
checkwindow = $01679A		;control96
ChkGoalies = $019782		;logic96_pull
assinsert = $01A3D0		;logic96_vec
assreplace = $01A3DA		;logic96_vec
randomd0 = $01B0A6		;video96
orjoy = $01B2C4		;video96
ReadJoy1 = $01B348		;video96
AddPenalty2 = $01C1D2		;penalty96
PenaltyManager = $01C272		;penalty96
ClearPenaltyBuffer = $01CCB0		;penalty96
updatepwrplay = $01CE8A		;penalty96
InitScores = $01D4CE		;hockey96_inter
VBlank = $0201DC		;display96
setvideo = $02034A		;display96
KillCrowd = $020E28		;display96
setupice = $020E52		;display96
clearTeamStats = $021482		;control96_team
IntermissionStart = $02161E		;hockey96_open
Opening = $0216F2		;hockey96_open
EASportsScreen = $021A4C		;hockey96_open
DefaultMenus = $021B82		;setup96_menu
ShowInjuryBox = $022A2C		;goal96_box
CrowdFrameTbl = $023248		;display96_crowd
InitSaveRAM = $023F1C		;sram96
MakeSRAMChecksum = $0241AA		;sram96
ClearSRAMBytes = $024208		;sram96
Z80Program = $025500		;sound96
SoundBanks = $027026		;sound96
SoundCmd = $08839E		;sound96
UpdateCwdExcite = $0883AC		;sound96
updatesound = $0883D4		;sound96
CheckLateGameSong = $08842E		;sound96
sfx = $088470		;sound96
song = $088586		;sound96
stop_current_song = $0885FC		;sound96
SoundOff = $088676		;sound96
ChooseSong = $088688		;sound96
InitCrowdMeter = $1D6D22		;code96_14
Create_HotCold_Table = $1D6F24		;code96_14
setSlotBit = $1D733C		;code96_14
RunArenaAnim = $1D8782		;shootout96_path
HiScoreScreen = $1D9114		;code96_15
ClearPenalties = $1D97F4		;code96_15
demoread = $014CC8		;pause96
Pausemode = $014D8C		;pause96


; Main segment code
	include	hockey96.asm
