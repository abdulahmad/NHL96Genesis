;	Segment build for engine\pause96_items.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$0236B0

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
PlayoffStatsMenu = $015490		;pause96_menu
TimeoutMenu = $015570		;pause96_menu
SelectGoalieMenu = $015604		;pause96_menu
ReplayMode = $01581C		;replay96
rtss2 = $01F84A		;collide96
AbortGame = $021A2E		;hockey96_open
ManualGoalieMenu = $1D86A4		;shootout96_path
LineEditor = $1E1B18		;stats96
TeamRosterScreen = $1E2EFC		;summary96
ScoringSummaryScreen = $1E352A		;summary96
PenaltySummaryScreen = $1E38E6		;summary96
PeriodStatsScreen = $1E3C7C		;summary96
StatsReport = $1E3FDE		;summary96
ShootoutShooters = $1E4582		;summary96
RecordHoldersScreen = $1E4DCC		;summary96
PlayerStatsScreen = $1E55BA		;stats96_list
PlayGame = $02447E		;pause96_play


; Main segment code
	include	engine\pause96_items.asm
