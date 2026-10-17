;	RAM map. Each variable takes its 95G name (or a name from
;	what it holds) once the code that uses it shows which it is; the rest keep their IDA names. Define each name once.
SaveRAM equ $200000	;the cartridge save RAM (header SRAM range)
SRSeasonHeader equ $82	;save RAM offset: the season header (SetupPlayoffs keeps a copy at SRSeasonHeaderSave)
SRPOPairings equ $AE	;save RAM offset: the playoff pairings, the team of each seed slot, a word each (InitPlayoffs)
SRSeasonHeaderSave equ $CE	;save RAM offset: SetupPlayoffs keeps SRSeasonHeader here
SRPOSlots equ $DE	;save RAM offset: the seed slot of each team, a word each (BuildPOSlots)
SRTeamCounts equ $3598	;save RAM offset: 4 bytes a team: +1 the player count, +3 the goalie count in the low 2 bits
M68K_RAM equ $FFFF0000
AwardIds equ $FFFF0000	;InitPlayoffs: the teams of the two conferences (ConferenceTeams1 at +0, ConferenceTeams2 at +$14), sorted by SortSeeds. Shares M68K_RAM
SeedStandings equ $FFFF0032	;InitPlayoffs: the standings, 3 bytes a team (ReadStandings)
SeedPoints equ $FFFF0080	;InitPlayoffs: 2 * wins + ties of each team (CalcSeedPoints)
SeedGames equ $FFFF009A	;InitPlayoffs: the wins of each team, the SortSeeds tie break (CalcSeedPoints)
SeedCount equ $FFFF00B4
POPairingsTmp equ $FFFF00B6	;InitPlayoffs with sflags11 bit 0: the pairings, here instead of save RAM SRPOPairings
word_FF1388 equ $FFFF1388
pstatscol equ $FFFF1EB2	;SeasonPlayoffStats: the stat column being printed
byte_FF2710 equ $FFFF2710
pstatsblockchars equ $FFFF2712	;SeasonPlayoffStats: team block chars
pstatscount equ $FFFF2714	;SeasonPlayoffStats: rows in the list
homelogochars equ $FFFF2716	;Team select: chars of the left (home / user) team logo
vislogochars equ $FFFF2718	;Team select: chars of the VisTeam logo
word_FF2720 equ $FFFF2720
CreatePoints equ $FFFF7536
replayend equ $FFFFAF64	;End of the replay buffer from M68K_RAM: updatereplay wraps recbpr there
VSCRLPM equ $FFFFB000
VSPRITES equ $FFFFB002
VmMap1 equ $FFFFB004
Map1col1 equ $FFFFB006
VmMap2 equ $FFFFB008
Map2col1 equ $FFFFB00A
VmMap3 equ $FFFFB00C
Map3col1 equ $FFFFB00E
bigfontptr equ $FFFFB010
printbigchars equ $FFFFB014	;The char base printbigtext adds: the font printbig1 / printbig2 chose
bigfont1chars equ $FFFFB016	;Chars of BigFontMap (printbig1, the clock digits)
BigFontChars equ $FFFFB018
smallfontchars equ $FFFFB01C
smallfont2chars equ $FFFFB01E	;Second small font chars (help lines and highlight)
energybarchars equ $FFFFB020
rinkvrcset equ $FFFFB022	;First vram char of the rink tiles
animchars equ $FFFFB024
faceoffvrcset equ $FFFFB026
framercset equ $FFFFB028
EASNcset equ $FFFFB02A
awardlogochars equ $FFFFB02C	;Awards: chars of the winner team logo
spritechars equ $FFFFB02E	;First vram char of the sprites (setupice)
ReplayIconChars equ $FFFFB030	;Vram char of the replay icon
gamefontchars equ $FFFFB038	;First char of the game fonts (LoadSmallFont, LoadBigFonts)
ExtraChars equ $FFFFB03A
menux equ $FFFFB03C	;PrintMenuList2: x of the item list
menuy equ $FFFFB03E	;PrintMenuList2: y of the item list
printx equ $FFFFB040
printy equ $FFFFB042
printa equ $FFFFB044
printm equ $FFFFB046
printfontset equ $FFFFB048
fodropx equ $FFFFB04A
fodropy equ $FFFFB04C
recbpr equ $FFFFB04E
vcount equ $FFFFB052
oldvcount equ $FFFFB054
repeatdelayframes equ $FFFFB056
asv equ $FFFFB058
lldisp equ $FFFFB05A
periodendtime equ $FFFFB05C
SortCords equ $FFFFB05E
unk_FFB65E equ $FFFFB65E
unk_FFB6DE equ $FFFFB6DE
puckx equ $FFFFB75E
pucky equ $FFFFB772
puckz equ $FFFFB776
puckvx equ $FFFFB786
puckvy equ $FFFFB788
puckvz equ $FFFFB78A
byte_FFB7BC equ $FFFFB7BC
puckc equ $FFFFB7BE
puck_pflags2 equ $FFFFB7C1
Ylist equ $FFFFB85E
OOlistpos equ $FFFFB87E
OOlist equ $FFFFB89E
lastpuckc equ $FFFFB8AE
padiconchars1 equ $FFFFB8B0	;ControllerSetupScreen: PadIconMap1 ... 4 chars (PadIconChars), in game RAM
crowdframe equ $FFFFB8B0	;The crowd frame (updatecrowdf; saved by updatereplay). Shares padiconchars1
crowdlevel equ $FFFFB8B2	;crowd noise level; the controller setup screen keeps padiconchars2 here
padiconchars2 equ $FFFFB8B2
padiconchars3 equ $FFFFB8B4
crowdtblidx equ $FFFFB8B4	;updatecrowdf: the crowd frame step. Shares padiconchars3
padiconchars4 equ $FFFFB8B6
crowdcnt equ $FFFFB8B6	;updatecrowdf: frames to the next crowd frame. Shares padiconchars4
padcursorchars equ $FFFFB8B8	;ControllerSetupScreen: PadCursorMap chars
CwdExciteLvl equ $FFFFB8B8	;Crowd excitement (StartPer: gamelevel * 16). Shares padcursorchars
MaxCwdExciteLvl equ $FFFFB8BA
NumCwdExciteLvl equ $FFFFB8BC
SumCwdExciteLvl equ $FFFFB8BE
zamx equ $FFFFB8C2
word_FFB8C4 equ $FFFFB8C4
optanimframe equ $FFFFB8C6	;OptionsScreen: animation frame 0-7
optanimdelay equ $FFFFB8C8	;OptionsScreen: frames to the next animation frame
DMAList equ $FFFFB8CA
DMAlistend equ $FFFFBD2A
Vpos equ $FFFFBD2E
Oldrow equ $FFFFBD30
Hpos equ $FFFFBD32
Hscroll equ $FFFFBD34
Vscroll equ $FFFFBD36
wcradiusx equ $FFFFBD38
wcradiusy equ $FFFFBD3A
palcount equ $FFFFBD3C
palfadenew equ $FFFFBD3E
fofdata2 equ $FFFFBDBE
pads equ $FFFFBDCA
Joy1Struct equ $FFFFBDE6
Joy3Struct equ $FFFFBE1E
Joy4Struct equ $FFFFBE3A
unk_FFBE72 equ $FFFFBE72
unk_FFBE8E equ $FFFFBE8E
PadControlBits equ $FFFFBEAA
padcont equ $FFFFBEAE
sso equ $FFFFBEBA
shotplayer equ $FFFFBF0A
lastplayer equ $FFFFBF0C
passdir equ $FFFFBF0E
passspeed equ $FFFFBF10
passplayer equ $FFFFBF12
glovecords equ $FFFFBF14
puckcross equ $FFFFBF1A	;puck crossing x and frames at each goal line, for the goalies
puckcross2 equ $FFFFBF1C
puckcross6 equ $FFFFBF20
lj1 equ $FFFFBF22
lj2 equ $FFFFBF24
lj3 equ $FFFFBF26
lj4 equ $FFFFBF28
pad4way1 equ $FFFFBF2A
pad4way2 equ $FFFFBF2B
pad4way3 equ $FFFFBF2C
pad4way4 equ $FFFFBF2D
bholdtimer equ $FFFFBF3A
bholdtimer34 equ $FFFFBF3C
TempWord1 equ $FFFFBF46
TempWord2 equ $FFFFBF48
TempRawSpd equ $FFFFBF4A
TempMaxSpd equ $FFFFBF4C
rosterscroll equ $FFFFBF50
TempLegSpd equ $FFFFBF52
pstatscat equ $FFFFBF56	;SeasonPlayoffStats: the stat category (BuildPlayerLeaders)
pstatstop equ $FFFFBF58	;SeasonPlayoffStats: first row shown
pstatsrow equ $FFFFBF5A	;SeasonPlayoffStats: bottom row shown
pstatsrows equ $FFFFBF5C	;SeasonPlayoffStats: rows on screen
pstatslast equ $FFFFBF5E	;SeasonPlayoffStats: last row
recwins equ $FFFFBF7C
word_FFBF88 equ $FFFFBF88
smallfontptr equ $FFFFBF8A
onetimerplayer equ $FFFFBFA6
onetimerflags equ $FFFFBFB0
disflags equ $FFFFBFB2
ltplayer equ $FFFFBFB4
ltx equ $FFFFBFB6
lty equ $FFFFBFB8
clockram equ $FFFFBFC2	;The clock chars for the dma list (showclockdma)
clockram2 equ $FFFFBFD0	;Second row of the clock chars (showclockdma)
xc1 equ $FFFFBFDC
yc1 equ $FFFFBFDE
yleader equ $FFFFBFE0
fox equ $FFFFBFE2
foy equ $FFFFBFE4
fodir1 equ $FFFFBFE6
fodir2 equ $FFFFBFE8
collflag equ $FFFFBFEE
word_FFBFF0 equ $FFFFBFF0
mesarea equ $FFFFBFF2
TextBuffer equ $FFFFBFF4
PushWidthBuf equ $FFFFC056
unk_FFC058 equ $FFFFC058
ltack equ $FFFFC062
lastsfx equ $FFFFC064
Satt equ $FFFFC066
Sattsize equ $FFFFC336
gmode equ $FFFFC338
sflags equ $FFFFC33A
sflags2 equ $FFFFC33C
sflags3 equ $FFFFC33E
BA_PS_flags equ $FFFFC340
sflags4 equ $FFFFC342
sflags5 equ $FFFFC344
sflags6 equ $FFFFC346
gmode2 equ $FFFFC348
sflags7 equ $FFFFC34A
sflags8 equ $FFFFC34C
sflags9 equ $FFFFC34E
GameFlags equ $FFFFC350	;bit 6: WriteSRAMBits skips MakeSRAMChecksum
sflags10 equ $FFFFC352
sflags11 equ $FFFFC354
sflags12 equ $FFFFC356
sflags13 equ $FFFFC358
byte_FFC35A equ $FFFFC35A
LineHoldFlag equ $FFFFC35C
shotpflags equ $FFFFC364	;pflags of the last shooter (doshot)
crowdnoisedelay equ $FFFFC368
CwdChkCntr equ $FFFFC36A	;Crowd meter frame counter
CwdChkCnt equ $FFFFC36C	;Crowd meter update count
CurCrowdMeter equ $FFFFC372
CrowdRecord equ $FFFFC374	;The crowd record threshold
CrowdAvg equ $FFFFC376	;Crowd noise off level
CrowdPeak equ $FFFFC378	;The crowd peak of the game
joypuckcarrier equ $FFFFC37C
msgtimer equ $FFFFC37E
passmodetimer equ $FFFFC380
savednewpnum equ $FFFFC382
c1playernum equ $FFFFC384
c2playernum equ $FFFFC386
c3playernum equ $FFFFC388
c4playernum equ $FFFFC38A
unk_FFC38C equ $FFFFC38C
cont1team equ $FFFFC390
cont2team equ $FFFFC392
cont3team equ $FFFFC394
cont4team equ $FFFFC396
HomeTeam equ $FFFFC3A0
VisTeam equ $FFFFC3A2
PenBuf equ $FFFFC3A6
Pencntdwn equ $FFFFC3E8
Penaltytimer equ $FFFFC3EA
PBnum equ $FFFFC3EC
InjCntDown equ $FFFFC442
penmsgtimer equ $FFFFC444
RefCnt equ $FFFFC446
RefStep equ $FFFFC448
RefPen equ $FFFFC44A
RefRamMap equ $FFFFC44C	;The ref window map in RAM (PushRef)
gsp equ $FFFFC4BC
gameclock equ $FFFFC4BE
PerTimeTotal equ $FFFFC4C2
ChkCnt equ $FFFFC4C4
unk_FFC4C6 equ $FFFFC4C6
TempPlOffset equ $FFFFC4C8
ScoreSumbytes equ $FFFFC4CA
ScoreSum equ $FFFFC4CC
PenSumLength equ $FFFFC634
PenSum equ $FFFFC636
tmstruct equ $FFFFC726	;the home team struct; AwShots the away team
HmGoals equ $FFFFC732
word_FFC73C equ $FFFFC73C
word_FFC74C equ $FFFFC74C
byte_FFC756 equ $FFFFC756
AwShots equ $FFFFCAC4
AwGoals equ $FFFFCAD0
word_FFCADA equ $FFFFCADA
word_FFCAEA equ $FFFFCAEA
byte_FFCAF4 equ $FFFFCAF4
statsbuffer equ $FFFFCE62
plistplayoff equ $FFFFCF42	;PlayerStatsList: 0 this game, 1 playoffs
gsstruct equ $FFFFCF44
unk_FFCFB4 equ $FFFFCFB4
gamenum equ $FFFFCFC4
postarts equ $FFFFCFC6
bosgames equ $FFFFCFC8
gamelevel equ $FFFFCFCA
potreeteam equ $FFFFCFCC
pojoy equ $FFFFCFCE
WinBits equ $FFFFCFD0
potree equ $FFFFCFD2
PlList equ $FFFFCFF2
menuitem equ $FFFFCFFE
menulist equ $FFFFD002
menudraw equ $FFFFD006
menurows equ $FFFFD00A	;PrintMenuList2: items shown
TickerNum equ $FFFFD026
PPBonus equ $FFFFD028
callbackPtr equ $FFFFD02C
DispAttribCtr equ $FFFFD030	;Stats screens: the column shown
VertLineScrolling equ $FFFFD032	;Stats screens: the row scroll
PlayerScrollCtr equ $FFFFD034	;Stats screens: the player row
word_FFD036 equ $FFFFD036
word_FFD038 equ $FFFFD038
screentimer equ $FFFFD03A	;Stats screens: the row count
setupvalues equ $FFFFD03C
ThreeStars equ $FFFFD130
LineSetsBuf equ $FFFFD130	;GetTeamLines builds the line sets here. Shares ThreeStars
CalTeam equ $FFFFD130	;CalendarScreen team (StandingsScreen: the group size). Shares ThreeStars
CalMonth equ $FFFFD132	;CalendarScreen month (StandingsScreen: the 26 team points table)
StandingsMode equ $FFFFD14C
StandingsOrder equ $FFFFD14E	;StandingsScreen games of the 26 teams
StandingsBuf equ $FFFFD168
StandingsList equ $FFFFD1B6
nibblebuffer equ $FFFFD230
dword_FFD234 equ $FFFFD234
word_FFD238 equ $FFFFD238
word_FFD23A equ $FFFFD23A
word_FFD23C equ $FFFFD23C
vbint equ $FFFFD244	;vertical blank handler address (VBjsr jumps through it)
pad1user equ $FFFFD248
pad2user equ $FFFFD24A
pad3user equ $FFFFD24C
pad4user equ $FFFFD24E
FourWayPlay equ $FFFFD250
menupadnum equ $FFFFD252
OptPlayMode equ $FFFFD254
OptNOP equ $FFFFD256
Opt1team equ $FFFFD258
Opt2team equ $FFFFD25A
OptPerlen equ $FFFFD25C
OptGoalie equ $FFFFD25E
OptUserRec equ $FFFFD260
OptPen equ $FFFFD262
OptLine equ $FFFFD264
OptFighting equ $FFFFD266
OptSkill equ $FFFFD268
OptRosters equ $FFFFD26A
goaliemode1 equ $FFFFD26C
goaliemode2 equ $FFFFD26E
demoflag equ $FFFFD276
seed equ $FFFFD278
dmaram equ $FFFFD27C
PalMode equ $FFFFD280
skillspeed equ $FFFFD284	;Skill level speed (SkillLevelTbl, SetSkillLevel)
skillspeedpal equ $FFFFD286	;Skill level speed for PAL (SkillLevelPalTbl)
TmpOptLine2 equ $FFFFD288
TempOptPlayMode equ $FFFFD28A
tpassbits equ $FFFFD28C
pwddatabuffer equ $FFFFD296
PlayingSong equ $FFFFD2A2
BA_Team equ $FFFFD2D2
BA_Sktr_SCnum equ $FFFFD2D4
BA_Goalie_SCnum equ $FFFFD2D6
BA_Skater_Offset equ $FFFFD2D8
BA_Goalie_Offset equ $FFFFD2DA
BA_Checker_Offset equ $FFFFD2DC
pspenalty equ $FFFFD2DE
holdreset equ $FFFFD2E0
onetimertargetx equ $FFFFD2E2
onetimertargety equ $FFFFD2E4
onetimerheight equ $FFFFD2E6
FallYPos equ $FFFFD2E8
FallXPos equ $FFFFD2EA
LineHoldTimer equ $FFFFD2EC
setuphome equ $FFFFD2FC
setupvis equ $FFFFD2FE
word_FFD300 equ $FFFFD300
word_FFD310 equ $FFFFD310
carddelay equ $FFFFD312
homegoalies equ $FFFFD31A
awaygoalies equ $FFFFD31C
homeplayers equ $FFFFD31E	;Players of the home team (CountPlayers)
awayplayers equ $FFFFD320	;Players of the away team (CountPlayers)
shootoutclock equ $FFFFD326	;The shootout clock
ValidSRAM equ $FFFFD32A
namelog equ $FFFFD32C	;The user name log, $C bytes per name
NameEntryBuf equ $FFFFD3AC	;Name entry: the name
NameEntryLen equ $FFFFD3C0
namelogsel equ $FFFFD3C2
namelogarrows equ $FFFFD3C4	;Name entry: the name log row with the arrows
nameentryvis equ $FFFFD3C6
homeshootgoals equ $FFFFD434
awayshootgoals equ $FFFFD436
shootoutround equ $FFFFD438	;Shootout round
homeshootnum equ $FFFFD446	;The shooter index of the shootout
shootoutteam equ $FFFFD454
byte_FFD474 equ $FFFFD474
byte_FFD47E equ $FFFFD47E
NameEntryMode equ $FFFFD484	;Name entry: 0 log mode, else name edit mode
userblockx equ $FFFFD488	;Playoff tree: x of the user's team block
SongNum equ $FFFFD48A
HmTeam equ $FFFFD48C
SongIndex equ $FFFFD48E
attribsum equ $FFFFD490
attribcount equ $FFFFD492
sopathdir equ $FFFFD81C	;passdir at the end of the shootout path
byte_FFDCA6 equ $FFFFDCA6
songdelay equ $FFFFDCC0
delayedsong equ $FFFFDCC2
shootoutdelay equ $FFFFDCC4	;Frames before the shootout ends
PuckZCntr equ $FFFFDCC6	;Frames the puck has hung at one height
waitxpad equ $FFFFDCC8
TmpPuckZ equ $FFFFDCCA	;puckz last frame
inputjoy equ $FFFFDCCC
PlayerChked equ $FFFFDCCE
PlayerChking equ $FFFFDCD2
word_FFDCDE equ $FFFFDCDE
dword_FFDCE0 equ $FFFFDCE0
unk_FFDCE0 equ $FFFFDCE0
dword_FFDCE4 equ $FFFFDCE4
word_FFDCE8 equ $FFFFDCE8
word_FFDCEA equ $FFFFDCEA
byte_FFDCEC equ $FFFFDCEC
replaydelay equ $FFFFDCF2
PALflag equ $FFFFDCF6
byte_FFDCF9 equ $FFFFDCF9
SeasonDay equ $FFFFDD7E	;The season header in RAM (ReadSeasonHeader / WriteSeasonHeader): the season day word first
SeasonFlags equ SeasonDay+2	;Season header flags (bit 0 regular season over, bit 1 season done, bit 2 playoffs)
dword_FFDD82 equ $FFFFDD82
jerseynum equ $FFFFDDAA
NextScreenPtr equ $FFFFDDAC	;The next season screen routine (RunSeasonMenu, PlayoffMenuScreen)
simdays equ $FFFFDDB0	;Days for SimSeasonDays to simulate
fightidletimer equ $FFFFDDB4	;Fight: frames left with no button before it ends
word_FFDDB6 equ $FFFFDDB6
injurygames equ $FFFFDDB8
SRAMChecksum equ $FFFFDDBC
word_FFDDBE equ $FFFFDDBE
IntermissionTimer equ $FFFFDDC4	;Intermission: frames before it continues by itself
varend equ $FFFFDDC6	;End of the variables Begin clears from VSCRLPM
Stack equ $FFFFFDFA
SndDrvRAM equ $FFFFFDFC	;Sound driver RAM base: word $1234 = driver on, 0 = off
SndSeqPtr equ $FFFFFDFE	;8 song slots: song data (-1 = free)
SndSeqId equ $FFFFFE3E	;8 words: the id SndStartSeq gave the slot
unk_FFFFF6 equ $FFFFFFF6
unk_FFFFFF equ $FFFFFFFF
Z80_RAM equ $A00000
Z80_YM2612 equ $A04000
; ----------------------------------




