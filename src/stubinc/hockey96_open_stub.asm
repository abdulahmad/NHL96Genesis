;	Segment build for hockey96_open.asm: sets its origin and the outside routines and data it uses,
;	then includes the file on its own for checking against the ROM.

; region code
	org	$0215DC

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	ram96.asm		;RAM map
	include	externs96.asm		;outside addresses still in incbin segments. Equates only
	include	macros\genesis.mac	;String

; External addresses outside, read from lst/nhl96.bin.
SetContTeams = $00B04E		;goal96
StartNewSeason = $010FB4		;season96
SimSeasonDays = $011024		;season96
BuildSeasonTeamList = $01116A		;season96
UserGamePlayed = $0113C2		;season96
WriteSeasonHeader = $01147E		;season96
ReadSeasonHeader = $01149E		;season96
FindUserGame = $011510		;season96
LoadSeasonOptions = $0115EA		;season96
SetupSeasonGame = $01169C		;season96
TeamSelectScreen = $011814		;season96
RunSeasonMenu = $01223E		;season96
SeasonMenuScreen = $0122A4		;season96
nullsub_2 = $013556		;teamgfx96
ScoutingReport = $013EA0		;awards96
StartGame = $014702		;hockey96
ResetClock = $01483A		;hockey96
StartPer = $0148BA		;hockey96
PlayoffStatsMenu = $015490		;pause96_menu
CopyPaletteToCRAM = $01B064		;video96
waitx = $01B152		;video96
setVram_0 = $01B594		;video96
dobitmap = $01B692		;video96
printz = $01BB8E		;video96
Intermission = $01D3CE		;hockey96_inter
UpdateScores = $01D518		;hockey96_inter
EncodePW = $02229C		;playoff96
ReadPassData = $022386		;playoff96
WritePassData = $0223B0		;playoff96
WritePassBits = $0223EA		;playoff96
AddPlayoffTeamStats = $0224FA		;playoff96
Z80Program = $025500		;sound96
SoundBanks = $027026		;sound96
SoundCmd = $08839E		;sound96
song = $088586		;sound96
stop_current_song = $0885FC		;sound96
SoundOff = $088676		;sound96
EASportsMap = $13DA74		;graphics96
OptionsScreen = $1E0DDE		;options96
ReturnToGame = $1E2688		;pause96_return
UserNameEntry = $1E6C4C		;records96
PlayoffScreen = $1E700A		;playoff96_tree
SeasonAwards = $1E7AC4		;awards96_show
SetSeasonAwardWinners = $1E827A		;awards96_show
CupChampionsScreen = $1E8544		;awards96_show
TitleScreen = $1E889C		;title96
CreditsScreen = $1E89FC		;title96
CupCelebration = $1E8C5E		;title96
maketree = $021CF4		;playoff96
KillCrowd = $020E28		;display96
vb2 = $0202C4		;display96
ContinuePlayoffs = $021BB0		;playoff96
NewPO = $021C28		;playoff96


; Main segment code
	include	hockey96_open.asm
