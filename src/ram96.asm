;	RAM map. Each variable takes its 95G name (or a name from
;	what it holds) once the code that uses it shows which it is. Define each
;	name once.
AwardIds			equ	$FFFF0000	;InitPlayoffs: the teams of the two conferences (ConferenceTeams1 at +0,
									;ConferenceTeams2 at +$14), sorted by SortSeeds. Shares M68K_RAM
Z80_RAM				equ	$A00000		; Z80 RAM as seen from the 68000 (Z80_RAM+$8E is the PCM rate byte)
Z80_YM2612			equ	$A04000		; YM2612 as seen from the Z80 bus (used by the Z80 driver only)
Stack				equ	$FFFFFDFA	; game stack (Begin, StartPer, Opening2)
M68K_RAM			equ	$FFFF0000	; start of the 68000 work RAM, the same as replaystart
LeaderIds			equ	$FFFF1388	;BuildPlayerLeaders: sorted player ids (team*$1B+slot). Not 95G TradeBuf
pstatscol			equ	$FFFF1EB2	;SeasonPlayoffStats: the stat column being printed
TeamSelectRedraw	equ	$FFFF2710	;Team select: bit 0 ranks, bit 1 home logo, bit 2 vis logo
pstatsblockchars	equ	$FFFF2712	;SeasonPlayoffStats: team block chars
pstatscount			equ	$FFFF2714	;SeasonPlayoffStats: rows in the list
homelogochars		equ	$FFFF2716	;Team select: chars of the left (home / user) team logo
vislogochars		equ	$FFFF2718	;Team select: chars of the VisTeam logo
TeamSelectHome		equ	$FFFF2720	;Team select: 1 home side, 0 visitors. Shares pstatsteam
pstatsteam			equ	$FFFF2720	;SeasonPlayoffStats: the team shown
CreatePoints		equ	$FFFF7536	; Create player: unallocated attribute points
replayend			equ	$FFFFAF64	;End of the replay buffer from M68K_RAM: updatereplay wraps recbpr there
VSCRLPM				equ	$FFFFB000	; location in vram of scroll parameters
VSPRITES			equ	$FFFFB002	; location in vram of sprite attributes
VmMAP1				equ	$FFFFB004	; location in vram of playfield 1
Map1col1			equ	$FFFFB006	; map 1 first column
VmMAP2				equ	$FFFFB008	; location in vram of playfield 2
Map2col1			equ	$FFFFB00A	; map 2 first column
VmMAP3				equ	$FFFFB00C	; location in vram of playfield 3
Map3col1			equ	$FFFFB00E	; map 3 first column
bigfontptr			equ	$FFFFB010	; Address of the big font map printbig uses
printbigchars		equ	$FFFFB014	;The char base printbigtext adds: the font printbig1 / printbig2 chose
bigfont1chars		equ	$FFFFB016	;Chars of BigFontMap (printbig1, the clock digits)
BigFontchars		equ	$FFFFB018	; vram tiles for BigFont.map
smallfontchars		equ	$FFFFB01C	; vram tiles for SmallFont.map
smallfont2chars		equ	$FFFFB01E	;Second small font chars (help lines and highlight)
smallfontptr		equ	$FFFFBF8A	; Address of the small font map AddSmallFont loads
energybarchars		equ	$FFFFB020	; vram tiles for the energy bar
rinkvrcset			equ	$FFFFB022	;First vram char of the rink tiles
animchars			equ	$FFFFB024	; animation character base
faceoffvrcset		equ	$FFFFB026	; vram tiles for FaceOff graphics
framercset			equ	$FFFFB028	; vram tiles for framer.map
EASNcset			equ	$FFFFB02A	; vram tiles for EASN.map
awardlogochars		equ	$FFFFB02C	;Awards: chars of the winner team logo
spritechars			equ	$FFFFB02E	;First vram char of the sprites (setupice)
ExtraChars			equ	$FFFFB03A	; vram tiles for extra graphics
ReplayIconChars		equ	$FFFFB030	;Vram char of the replay icon
gamefontchars		equ	$FFFFB038	;First char of the game fonts (LoadSmallFont, LoadBigFonts)
menux				equ	$FFFFB03C	;PrintMenuList2: x of the item list
menuy				equ	$FFFFB03E	;PrintMenuList2: y of the item list
printx				equ	$FFFFB040	; x cordinate for printing
printy				equ	$FFFFB042	; y cordinate for printing
printa				equ	$FFFFB044	; attribute for print characters
printm				equ	$FFFFB046	; map to use (0 = map 1, 4 = map 2, 8 = map 3)
printfontset		equ	$FFFFB048	; printsmall char set (index*2 into smallfontchars).
fodropx				equ	$FFFFB04A	; face off drop spot x/y
fodropy				equ	$FFFFB04C	; face off drop spot y (see fodropx)
recbpr				equ	$FFFFB04E	; replay record buffer pointer: the frame being recorded
VBint				equ	$FFFFD244	;vertical blank handler address (VBjsr jumps through it)
Vcount				equ	$FFFFB052	; counter for vblank
OldVcount			equ	$FFFFB054	; Vcount at the last game frame: the frame loop waits d7 frames from it
repeatdelayframes	equ	$FFFFB056	; frames until the menu cursor repeats (first delay $F, then 4)
asv					equ	$FFFFB058	; analog sound volume (crowd noise)
periodendtime		equ	$FFFFB05C	; CheckLateGameSong trigger time.
SortCords			equ	$FFFFB05E	; sort objects, SCstruct bytes each; the puck is object puckscnum
SortObj12			equ	$FFFFB65E	;SortCords+12*SCstruct
SortObj13			equ	$FFFFB6DE	;SortCords+13*SCstruct
puckx				equ	$FFFFB75E	; puck x position in its sort object
puckvx				equ	$FFFFB786	; puck x velocity
pucky				equ	$FFFFB772	; puck y position
puckvy				equ	$FFFFB788	; puck y velocity
puckz				equ	$FFFFB776	; puck height above the ice
puckvz				equ	$FFFFB78A	; puck z velocity
pucknopuck			equ	$FFFFB7BC	;puckx+nopuck (layout; unused as a label)
puckc				equ	$FFFFB7BE	; puck carrier
puck_pflags2		equ	$FFFFB7C1	; puck object pflags2
Ylist				equ	$FFFFB85E	; list of y cords for each sortobj
OOlistpos			equ	$FFFFB87E	; objects pos in OOlist
OOlist				equ	$FFFFB89E	; object order list for sort objs
Crowdframe			equ	$FFFFB8B0	;The crowd frame (updatecrowdf; saved by
									;updatereplay). Shares padiconchars1
Crowdlevel			equ	$FFFFB8B2	;crowd noise level; the controller setup screen keeps padiconchars2 here
Crowdcnt			equ	$FFFFB8B6	;updatecrowdf: frames to the next crowd frame. Shares padiconchars4
CwdExciteLvl		equ	$FFFFB8B8	;Crowd excitement (StartPer: gamelevel * 16). Shares padcursorchars
MaxCwdExciteLvl		equ	$FFFFB8BA	; peak crowd level.
NumCwdExciteLvl		equ	$FFFFB8BC	; crowd level sample count.
SumCwdExciteLvl		equ	$FFFFB8BE	; crowd level running total.
crowdtblidx			equ	$FFFFB8B4	;updatecrowdf: the crowd frame step. Shares padiconchars3
Zamx				equ	$FFFFB8C2	; zamboni x cord
puckanimchars		equ	$FFFFB8C4	;OptionsScreen: vram char of PuckAnimMap. Shares PlayoffHpos
PlayoffHpos			equ	$FFFFB8C4	;Playoff tree: scroll+$100 when in $40..$200
optanimframe		equ	$FFFFB8C6	;OptionsScreen: animation frame 0-7
optanimdelay		equ	$FFFFB8C8	;OptionsScreen: frames to the next animation frame
DMAList				equ	$FFFFB8CA	; dma transfer list
Vpos				equ	$FFFFBD2E	; ice rink vertical position
Oldrow				equ	$FFFFBD30	; last row (used in vertical scrolling of the map data)
Hpos				equ	$FFFFBD32	; ice rink horizontal position
Hscroll				equ	$FFFFBD34	; horizontal scroll value
Vscroll				equ	$FFFFBD36	; vertical scroll value
wcradiusx			equ	$FFFFBD38	; variables used in wall collisions
wcradiusy			equ	$FFFFBD3A	; wall collision radius y (see wcradiusx)
palcount			equ	$FFFFBD3C	; counter for fading in color palettes
palfadenew			equ	$FFFFBD3E	; palettes to fade into (+$20 the title palette, +$40 palettes 2-3)
fofdata2			equ	$FFFFBDBE	; faceoff sprite data, second set
ffonum				equ	8			;objects tied to the rink scroll
pads				equ	$FFFFBDCA	; face-off ice pad object. Not joypads
Joy1Struct			equ	$FFFFBDE6	; controller 1 and 2 arrow objects
Joy3Struct			equ	$FFFFBE1E	; controller 3 state
Joy4Struct			equ	$FFFFBE3A	; controller 4 arrow object (4 Way Play)
SetupPadStruct		equ	$FFFFBE72	;controller-setup pad object (glovecords+2)
glovestruct			equ	$FFFFBE8E	;glove object (glovecords)
PadControlBits		equ	$FFFFBEAA	; pad assignment bits ($FFFF = no assignments, set at game setup)
padcont				equ	$FFFFBEAE	; pad assignment data (4 words), cleared together with PadControlBits
ssonum				equ	4			;screen objects not tied to the rink scroll
ssosize				equ	$14			;bytes per sso object
sso					equ	$FFFFBEBA	; screen objects not tied to the rink scroll: 2 arrows for off screen
shotplayer			equ	$FFFFBF0A	; player who shot last
lastplayer			equ	$FFFFBF0C	; last player who touched puck
passdir				equ	$FFFFBF0E	; direction for pass/shot
passspeed			equ	$FFFFBF10	; speed of pass/shot
passplayer			equ	$FFFFBF12	; player a pass is aimed at
glovecords			equ	$FFFFBF14	; cordinates of glove/sticks (fighting)
puckcross			equ	$FFFFBF1A	;puck crossing x and frames at each goal line, for the goalies
puckcross2			equ	$FFFFBF1C	; top entry frames
puckcross6			equ	$FFFFBF20	; bottom entry frames
lj1					equ	$FFFFBF22	; used in joystick debounce
lj2					equ	$FFFFBF24	; joystick debounce for pad 2 (see lj1)
lj3					equ	$FFFFBF26	; controller 3 joystick state
lj4					equ	$FFFFBF28	; controller 4 joystick state
pad4way1			equ	$FFFFBF2A	; four way adapter pad 1
pad4way2			equ	$FFFFBF2B	; four way adapter pad 2
pad4way3			equ	$FFFFBF2C	; four way adapter pad 3
pad4way4			equ	$FFFFBF2D	; four way adapter pad 4
bholdtimer			equ	$FFFFBF3A	; B button hold timer
bholdtimer34		equ	$FFFFBF3C	; B button hold timers, controllers 3 and 4
TempWord1			equ	$FFFFBF46	; a scratch word (hot / cold totals, record page, button direction ...)
TempWord2			equ	$FFFFBF48	; a scratch word (hot / cold totals, attribute number, credits step ...)
TempRawSpd			equ	$FFFFBF4A	; temporary: raw speed
TempMaxSpd			equ	$FFFFBF4C	; temporary: maximum speed
rosterscroll		equ	$FFFFBF50	; First player row shown by DisplayPlayerList
TempLegSpd			equ	$FFFFBF52	; temporary: leg speed
pstatscat			equ	$FFFFBF56	;SeasonPlayoffStats: the stat category (BuildPlayerLeaders)
pstatstop			equ	$FFFFBF58	;SeasonPlayoffStats: first row shown
pstatsrow			equ	$FFFFBF5A	;SeasonPlayoffStats: bottom row shown
pstatsrows			equ	$FFFFBF5C	;SeasonPlayoffStats: rows on screen
pstatslast			equ	$FFFFBF5E	;SeasonPlayoffStats: last row
recwins				equ	$FFFFBF7C	; team record: wins
smallfontalt		equ	$FFFFBF88	;printsmall / printcur: char base when sflags6 bit 3
onetimerplayer		equ	$FFFFBFA6	; player taking a one timer
onetimerflags		equ	$FFFFBFB0	; one timer flags
disflags			equ	$FFFFBFB2	; display flags
ltplayer			equ	$FFFFBFB4	; last touch player
ltx					equ	$FFFFBFB6	; last touch x cord
lty					equ	$FFFFBFB8	; last touch y cord
clockram			equ	$FFFFBFC2	;The clock chars for the dma list (showclockdma)
clockram2			equ	$FFFFBFD0	;Second row of the clock chars (showclockdma)
xc1					equ	$FFFFBFDC	; scroll lock x cord
yc1					equ	$FFFFBFDE	; scroll lock y cord
yleader				equ	$FFFFBFE0	; lead distance on scrolling
fox					equ	$FFFFBFE2	; faceoff spot x/y
foy					equ	$FFFFBFE4	; face off spot y (see fox)
fodir1				equ	$FFFFBFE6	; pull directions for each player on face off
fodir2				equ	$FFFFBFE8	; pull direction for the visiting player on the face off (see fodir1)
collflag			equ	$FFFFBFEE	; collision has occured
lldisp				equ	$FFFFB05A	; line level disp update counter
collscale			equ	$FFFFBFF0	;checkplcoll: collision scale (96 stores 0, then multiplies)
mesarea				equ	$FFFFBFF2	; temp area for mes chars
TextBuffer			equ	$FFFFBFF4	; to mesarea+100
PushWidthBuf		equ	$FFFFC056	; PushNumberWidth string: length word, then digits.
PushWidthBuf2		equ	$FFFFC058	;PushWidthBuf+2
ltack				equ	$FFFFC062	; last tackle sound.
lastsfx				equ	$FFFFC064	; last sound played
Satt				equ	$FFFFC066	; sprite attribute table (for dma transfer
Sattsize			equ	$FFFFC336	; size of transfer
DMAlistend			equ	$FFFFBD2A	; end of the DMA list: where the next entry is written
gmode				equ	$FFFFC338	; game mode flag
sflags				equ	$FFFFC33A	; game state flags
sflags2				equ	$FFFFC33C	; game state flags, second word
sflags3				equ	$FFFFC33E	; game state flags, third word
BA_PS_flags			equ	$FFFFC340	; breakaway / penalty shot / shootout flags
sflags4				equ	$FFFFC342	; game state flags, fourth word
sflags5				equ	$FFFFC344	; game state flags, fifth word
sflags6				equ	$FFFFC346	; game state flags, sixth word
gmode2				equ	$FFFFC348	; game mode, second word
sflags7				equ	$FFFFC34A	; game state flags, seventh word
sflags8				equ	$FFFFC34C	; game state flags, eighth word
sflags9				equ	$FFFFC34E	; Bit 7 Practice Mode (main menu item 2)
GameFlags			equ	$FFFFC350	;bit 6: WriteSRAMBits skips MakeSRAMChecksum
sflags10			equ	$FFFFC352	; Main menu: bit 2 Trade Players, bit 4 Create Player, bit 5 Sign Free
sflags11			equ	$FFFFC354	; game state flags, eleventh word
sflags12			equ	$FFFFC356	; Bit 7 Opening2 skips the sound restart (set by Opening), bit 6
sflags13			equ	$FFFFC358	; Bit 2: the Stanley Cup was won (clockcont_0;
sflags14			equ	$FFFFC35A	;bit 0 big score on (ShowBigScore); bit 1 skip season menu song
LineHoldFlag		equ	$FFFFC35C	; Per pad (a word each): set when LineHoldTimer runs out (SetLCmode);
lastpuckc			equ	$FFFFB8AE	; The puck carrier CheckNewCarrier saw last
menupadnum			equ	$FFFFD252	; Pad (0-3) ReadMenuJoy reads
crowdnoisedelay		equ	$FFFFC368	; frames until the next crowd noise
CwdChkCntr			equ	$FFFFC36A	;Crowd meter frame counter
CwdChkCnt			equ	$FFFFC36C	;Crowd meter update count
CurCrowdMeter		equ	$FFFFC372	; current crowd meter level
CrowdRecord			equ	$FFFFC374	;The crowd record threshold
CrowdAvg			equ	$FFFFC376	;Crowd noise off level
CrowdPeak			equ	$FFFFC378	;The crowd peak of the game
joypuckcarrier		equ	$FFFFC37C	; player with the puck controlled by the joypad
msgtimer			equ	$FFFFC37E	; on screen message timer
passmodetimer		equ	$FFFFC380	; pass mode timer
savednewpnum		equ	$FFFFC382	; saved new player number
c1playernum			equ	$FFFFC384	; player in control or neg for none
c2playernum			equ	$FFFFC386	; player controlled by pad 2, negative = none (see c1playernum)
c3playernum			equ	$FFFFC388	; controller 3 player number
c4playernum			equ	$FFFFC38A	; controller 4 player number
PadChanged			equ	$FFFFC38C	;one byte a pad: $FF after setcplayer, cleared when C is not held
cont1team			equ	$FFFFC390	; cont1 team 0=none 1=team1 2=team2
cont2team			equ	$FFFFC392	; team of controller 2: 0 = none (see cont1team)
cont3team			equ	$FFFFC394	; team of controller 3
cont4team			equ	$FFFFC396	; team of controller 4
HomeTeam			equ	$FFFFC3A0	; number 0-24
VisTeam				equ	$FFFFC3A2	; visiting team number (0-24, see HomeTeam)
PenBuf				equ	$FFFFC3A6	; upto x penalties saved
; Penalty numbers (word offsets into Penaltylist) for AddPenalty
PenEOP			equ	$2				; period over
PenEOG			equ	$4				; game over
PenOOP			equ	$6				; out of play: puck too long without a touch, over the glass
PenGhold		equ	$8				; goalie held the puck
PenWhistle		equ	$A				; whistle
PenIcing		equ	$C				; icing
PenGoal			equ	$E				; goal
PenOffsides		equ	$10				; offside
PenRoughing2	equ	$12				; roughing, with slow down time $A
PenNoText		equ	$14				; penalty with no text
PenCharging		equ	$16				; charging
PenSlashing		equ	$18				; slashing
PenRoughing		equ	$1A				; roughing
PenCrossChk		equ	$1C				; cross checking
PenHooking		equ	$1E				; hooking
PenTripping		equ	$20				; tripping
PenInterference	equ	$22				; interference
PenHolding		equ	$24				; holding
PenFighting		equ	$26				; fighting
PenFighting2	equ	$28				; fighting, second variant
PenInst			equ	$2A				; instigator
PenDelay		equ	$2C				; delay of game
; Sprite object counts and sizes (92 names)
PenCntDwn			equ	$FFFFC3E8	; frames until the penalty or stoppage message ends (fights 60, an injury
Penaltytimer		equ	$FFFFC3EA	; counts down the second for the penalty clocks (jps frames)
PBnum				equ	$FFFFC3EC	; $HV00 h=home players in pb
InjCntDown			equ	$FFFFC442	; frames until the injury box is shown after an injury
penmsgtimer			equ	$FFFFC444	; penalty message timer
RefCnt				equ	$FFFFC446	; ref graphics control
RefStep				equ	$FFFFC448	; ref animation step: word offset into the ref frames, -1 = ref idle
RefPen				equ	$FFFFC44A	; penalty number the ref is calling (4 = game over)
RefRamMap			equ	$FFFFC44C	;The ref window map in RAM (PushRef)
gsp					equ	$FFFFC4BC	; game period
gameclock			equ	$FFFFC4BE	; game clock
PerTimeTotal		equ	$FFFFC4C2	; total time of the period
ChkCnt				equ	$FFFFC4C4	; check counter for the player check stat
ChkCnt2				equ	$FFFFC4C6	;ChkCnt+2
TempPlOffset		equ	$FFFFC4C8	; roster offset of the player to print (bit 15 =
ScoreSumbytes		equ	$FFFFC4CA	; bytes used in ScoreSum (6 per goal)
ScoreSum			equ	$FFFFC4CC	; scoring summary: 6 bytes per goal (scorer, assists, time)
PenSumLength		equ	$FFFFC634	; bytes used in PenSum (4 per penalty).
PenSum				equ	$FFFFC636	; penalty summary log, 4 bytes per penalty.
tmstruct			equ	$FFFFC726	;the home team struct; AwShots the away team
HmGoals				equ	$FFFFC732	; home score
HomeTmLine			equ	$FFFFC73C	;tmstruct+tmline
HomeTmGoalie		equ	$FFFFC74C	;tmstruct+tmgoalie
HomeTmFlags			equ	$FFFFC756	;tmstruct+tmflags
AwShots				equ	$FFFFCAC4	; away team shots
AwGoals				equ	$FFFFCAD0	; away score
AwayTmLine			equ	$FFFFCADA	;AwShots+tmline
AwayTmGoalie		equ	$FFFFCAEA	;AwShots+tmgoalie
AwayTmFlags			equ	$FFFFCAF4	;AwShots+tmflags
statsbuffer			equ	$FFFFCE62	; playoff team stat totals, summed from the stat bytes
plistplayoff		equ	$FFFFCF42	;PlayerStatsList: 0 this game, 1 playoffs
gsstruct			equ	$FFFFCF44	; game stats structure
gsstruct7			equ	$FFFFCFB4	;gsstruct+7*$10
gamenum				equ	$FFFFCFC4	; index for current game in game struct
postarts			equ	$FFFFCFC6	; 0-31 for which playoff tree to use as frame
bosgames			equ	$FFFFCFC8	; 0-6 game of series or 7 if not in best of seven
gamelevel			equ	$FFFFCFCA	; 0-3 for the depth into the play off tree
potreeteam			equ	$FFFFCFCC	; which team you are on the intial playoff tree
pojoy				equ	$FFFFCFCE	; playoff joystick indicator
WinBits				equ	$FFFFCFD0	; bits which indicat the continuing teams on the playoff tree
potree				equ	$FFFFCFD2	; team in the tree
PlList				equ	$FFFFCFF2	; list of players used differently
menuitem			equ	$FFFFCFFE	; menu state: selected item, then (+2) first item shown
menulist			equ	$FFFFD002	; menu item list.
menudraw			equ	$FFFFD006	; menu screen draw routine.
menurows			equ	$FFFFD00A	;PrintMenuList2: items shown
TickerNum			equ	$FFFFD026	; intermission ticker: index of the game being shown, negative = no more
PPBonus				equ	$FFFFD028	; check bonuses, cleared together by clr.l.
callbackPtr			equ	$FFFFD02C	; pointer to the routine called back
PListRows			equ	$FFFFD036	;PlayerStatsList: rows on screen
PListMax			equ	$FFFFD038	;PlayerStatsList: last row index
CalTeam				equ	$FFFFD130	;CalendarScreen team (StandingsScreen: the group size). Shares ThreeStars
SeedCount			equ	$FFFF00B4	; SortSeeds: the teams in the list. Shares ThreeStars
ThreeStars			equ	$FFFFD130	; three stars of the game data
LineSetsBuf			equ	$FFFFD130	;GetTeamLines builds the line sets here. Shares ThreeStars
CalMonth			equ	$FFFFD132	;CalendarScreen month (StandingsScreen: the 26 team points table)
SeedPoints			equ	$FFFF0080	;InitPlayoffs: 2 * wins + ties of each team (CalcSeedPoints)
StandingsMode		equ	$FFFFD14C	; StandingsScreen group: bit 0 conference, bit 1 division
SeedGames			equ	$FFFF009A	;InitPlayoffs: the wins of each team, the SortSeeds tie break
									;(CalcSeedPoints)
SeedStandings		equ	$FFFF0032	;InitPlayoffs: the standings, 3 bytes a team (ReadStandings)
POPairingsTmp		equ	$FFFF00B6	;InitPlayoffs with sflags11 bit 0: the pairings, here instead of save RAM
									;SRPOPairings
StandingsOrder		equ	$FFFFD14E	;StandingsScreen games of the 26 teams
StandingsBuf		equ	$FFFFD168	; StandingsScreen records (ReadStandings, 3 bytes a team)
StandingsList		equ	$FFFFD1B6	; StandingsScreen teams of the group, sorted
DispAttribCtr		equ	$FFFFD030	;Stats screens: the column shown
VertLineScrolling	equ	$FFFFD032	;Stats screens: the row scroll
PlayerScrollCtr		equ	$FFFFD034	;Stats screens: the player row
screentimer			equ	$FFFFD03A	;Stats screens: the row count
nibblebuffer		equ	$FFFFD230	; UnpackNibbles words, WeightedRandomSelect weights.
nibblebuffer4		equ	$FFFFD234	;nibblebuffer+4
DumpPassSc			equ	$FFFFD238	;dump-pass: SCnum of the passer, or -1 if passed to a player. Shares PListCol
PListCol			equ	$FFFFD238	;PlayerStatsList: the stat column being printed (PListValue)
LastCarrierHome		equ	$FFFFD23A	;SetRoles: last puck carrier SCnum, home (negative: none)
LastCarrierAway		equ	$FFFFD23C	;SetRoles: last puck carrier SCnum, away
pad1user			equ	$FFFFD248	; $FFFFD042. Name log entry picked by pad 1
pad2user			equ	$FFFFD24A	; $FFFFD044. Name log entry picked by pad 2
pad3user			equ	$FFFFD24C	; Name log entry picked by pad 3
pad4user			equ	$FFFFD24E	; Name log entry picked by pad 4
FourWayPlay			equ	$FFFFD250	; EA 4 Way Play adaptor present (Detect4WayPlay). With the Opt* setup
varend				equ	$FFFFDDC6	;End of the variables Begin clears from VSCRLPM
OptPlayMode			equ	$FFFFD254	; play mode
OptNOP				equ	$FFFFD256	; number of players
Opt1team			equ	$FFFFD258	; team 1
Opt2team			equ	$FFFFD25A	; team 2
Optperlen			equ	$FFFFD25C	; period length index.
OptGoalie			equ	$FFFFD25E	; option: goalie
OptUserRec			equ	$FFFFD260	; option: user records
OptPen				equ	$FFFFD262	; penalties 1 for off
OptLine				equ	$FFFFD264	; line changes option
OptFighting			equ	$FFFFD266	; option: fighting
OptSkill			equ	$FFFFD268	; option: skill level
OptRosters			equ	$FFFFD26A	; option: rosters
goaliemode1			equ	$FFFFD26C	; goalie mode, home
goaliemode2			equ	$FFFFD26E	; goalie mode, away
demoflag			equ	$FFFFD276	; demo flag
seed				equ	$FFFFD278	; seed for the random number generator
dmaram				equ	$FFFFD27C	; dma ram area.
PalMode				equ	$FFFFD280	; Rev A only: VDP PAL bit (Begin). Set = 50 Hz: faster skating
skillspeed			equ	$FFFFD284	;Skill level speed (SkillLevelTbl, SetSkillLevel)
skillspeedpal		equ	$FFFFD286	;Skill level speed for PAL (SkillLevelPalTbl)
TmpOptLine2			equ	$FFFFD288	; temporary option: line changes, second
TempOptPlayMode		equ	$FFFFD28A	; temporary option: play mode
pwddatabuffer		equ	$FFFFD296	; password data buffer
tpassbits			equ	$FFFFD28C	; temporary storage of passbits.
PlayingSong			equ	$FFFFD2A2	; Song the sound driver is playing ($32-$55), -1 = none
BA_Team				equ	$FFFFD2D2	; breakaway / penalty shot / shootout: which team (with BA_PS_flags)
BA_Sktr_SCnum		equ	$FFFFD2D4	; SCnum of the breakaway / penalty-shot / shootout skater
BA_Goalie_SCnum		equ	$FFFFD2D6	; SCnum of that play's goalie
BA_Skater_Offset	equ	$FFFFD2D8	; that skater's team position offset
BA_Goalie_Offset	equ	$FFFFD2DA	; that goalie's team position offset
BA_Checker_Offset	equ	$FFFFD2DC	; the checker's team position offset (penalty shot)
pspenalty			equ	$FFFFD2DE	; penalty summary: penalty number
holdreset			equ	$FFFFD2E0	; hold reset countdown
onetimertargetx		equ	$FFFFD2E2	; one timer target x
onetimertargety		equ	$FFFFD2E4	; one timer target y
onetimerheight		equ	$FFFFD2E6	; one timer puck height
FallYPos			equ	$FFFFD2E8	; falling player y position
FallXPos			equ	$FFFFD2EA	; falling player x position
LineHoldTimer		equ	$FFFFD2EC	; frames A must stay held before doinput starts a pass
setuphome			equ	$FFFFD2FC	; setup screen: home team
setupvis			equ	$FFFFD2FE	; setup screen: visiting team
SetupSpare			equ	$FFFFD300	;ClearGameRAM leftover between setupvis and carddelay
SetupSpare16		equ	$FFFFD310	;SetupSpare+$10
carddelay			equ	$FFFFD312	; player card delay
homegoalies			equ	$FFFFD31A	; home team goalies
awaygoalies			equ	$FFFFD31C	; away team goalies
homeplayers			equ	$FFFFD31E	;Players of the home team (CountPlayers)
awayplayers			equ	$FFFFD320	;Players of the away team (CountPlayers)
shootoutclock		equ	$FFFFD326	;The shootout clock
ValidSRAM			equ	$FFFFD32A	; nonzero when the save RAM is valid
namelog				equ	$FFFFD32C	;The user name log, $C bytes per name
NameEntryBuf		equ	$FFFFD3AC	;Name entry: the name
NameEntryLen		equ	$FFFFD3C0	; Name entry: name length
namelogsel			equ	$FFFFD3C2	; selected name log entry
namelogarrows		equ	$FFFFD3C4	;Name entry: the name log row with the arrows
nameentryvis		equ	$FFFFD3C6	; name entry cursor visible
homeshootgoals		equ	$FFFFD434	; Shootout goals, home
awayshootgoals		equ	$FFFFD436	; Shootout goals, away
shootoutround		equ	$FFFFD438	;Shootout round
homeshootnum		equ	$FFFFD446	;The shooter index of the shootout
shootoutteam		equ	$FFFFD454	; Shootout: 0 home shoots, 1 away
arenaanim			equ	$FFFFD474	;94G arenaanim (StartGame st; RunArenaAnim is rts-disabled)
faceoffanim			equ	$FFFFD47E	;94G faceoffanim (StartPer st; SetFaceoffAnim)
SeasonDay			equ	$FFFFDD7E	;The season header in RAM (ReadSeasonHeader / WriteSeasonHeader):
									;the season day word first
SeasonFlags			equ	SeasonDay+2	;Season header flags (bit 0 regular season over, bit 1 season done, bit 2
									;playoffs)
injurygames			equ	$FFFFDDB8	; Season: the games of the last injury (SetInjuryGames, CheckInjury)
padcursorchars		equ	$FFFFB8B8	;ControllerSetupScreen: PadCursorMap chars
padiconchars1		equ	$FFFFB8B0	;ControllerSetupScreen: PadIconMap1 ... 4 chars
									;(PadIconChars), in game RAM
padiconchars2		equ	$FFFFB8B2	; pad icon characters, controller 2
padiconchars3		equ	$FFFFB8B4	; pad icon characters, controller 3
padiconchars4		equ	$FFFFB8B6	; pad icon characters, controller 4
setupvalues			equ	$FFFFD03C	; 8 setup line values (mode, teams, ...)
NameEntryMode		equ	$FFFFD484	;Name entry: 0 log mode, else name edit mode
userblockx			equ	$FFFFD488	;Playoff tree: x of the user's team block
SongNum				equ	$FFFFD48A	; current song number
HmTeam				equ	$FFFFD48C	; home team
SongIndex			equ	$FFFFD48E	; song index
attribsum			equ	$FFFFD490	; CalcAttribRating: sum of the attribute bytes
attribcount			equ	$FFFFD492	; CalcAttribRating: count of them
sopathdir			equ	$FFFFD81C	;passdir at the end of the shootout path
OptPad				equ	$FFFFDCA6	;OptionsScreen: last pad bits from ProcessInputWithRepeat
songdelay			equ	$FFFFDCC0	; frames until the delayed song starts
delayedsong			equ	$FFFFDCC2	; song waiting to start
shootoutdelay		equ	$FFFFDCC4	;Frames before the shootout ends
PuckZCntr			equ	$FFFFDCC6	;Frames the puck has hung at one height
waitxpad			equ	$FFFFDCC8	; pad used by the wait routine
TmpPuckZ			equ	$FFFFDCCA	;puckz last frame
inputjoy			equ	$FFFFDCCC	; joypad input
PlayerChked			equ	$FFFFDCCE	; player being checked
PlayerChking		equ	$FFFFDCD2	; player checking
FightEngageCount	equ	$FFFFDCDE	;EngageFight: fighters who have pressed A/B/C
FightMash			equ	$FFFFDCE0	;fight button-mash count, one word a pad
FightMash34			equ	$FFFFDCE4	;FightMash+4 (pads 3-4)
FightMasher			equ	$FFFFDCE8	;fightinput: SCnum of the pad that reached the mash limit
FightSpare			equ	$FFFFDCEA	;startfight leftover (cleared)
FightFaceBits		equ	$FFFFDCEC	;fightinput: bit 0/1 facing (facedir 2 vs the other)
replaydelay			equ	$FFFFDCF2	; replay delay
PALflag				equ	$FFFFDCF6	; nonzero on a PAL console
DayGameCount		equ	$FFFFDCF9	;games in today's list at DayGameCount+1 (5 bytes each)
SeasonPen			equ	$FFFFDD82	;season header: OptPen, OptLine at +1
SeasonTeam			equ	$FFFFDD84	;season header: the user's team ($FF none)
jerseynum			equ	$FFFFDDAA	; Jersey number byte from GetJerseyNumber
NextScreenPtr		equ	$FFFFDDAC	;The next season screen routine (RunSeasonMenu, PlayoffMenuScreen)
simdays				equ	$FFFFDDB0	;Days for SimSeasonDays to simulate
fightidletimer		equ	$FFFFDDB4	;Fight: frames left with no button before it ends
TeamSelSide			equ	$FFFFDDB6	;Team select: highlighted side (0 season, 1 home, 2 visitors)
SRAMChecksum		equ	$FFFFDDBC	; The complement and sum bytes MakeSRAMChecksum
shotpflags			equ	$FFFFC364	;pflags of the last shooter (doshot)
PlayoffMenuTeam		equ	$FFFFDDBE	;PlayoffMenuScreen: the user's tree team ($FFFF none)
IntermissionTimer	equ	$FFFFDDC4	;Intermission: frames before it continues by itself
SndDrvRAM			equ	$FFFFFDFC	;Sound driver RAM base: word $1234 = driver on, 0 = off
SndSeqPtr			equ	$FFFFFDFE	;8 song slots: song data (-1 = free)
SndSeqId			equ	$FFFFFE3E	;8 words: the id SndStartSeq gave the slot
RamTop				equ	$FFFFFFF6	; top of work RAM
RamLast				equ	$FFFFFFFF	; last byte of work RAM
SaveRAM				equ	$200000		;the cartridge save RAM (header SRAM range)
SRSeasonHeader		equ	$82			;save RAM offset: the season header (SetupPlayoffs keeps a copy at
									;SRSeasonHeaderSave)
SRSeasonHeaderSave	equ	$CE			;save RAM offset: SetupPlayoffs keeps SRSeasonHeader here
SRPOPairings		equ	$AE			;save RAM offset: the playoff pairings, the team of each seed slot, a word
									;each (InitPlayoffs)
SRPOSlots			equ	$DE			;save RAM offset: the seed slot of each team, a word each (BuildPOSlots)
SRTeamCounts		equ	$3598		;save RAM offset: 4 bytes a team: +1 the player count, +3 the goalie count
									;in the low 2 bits
; ----------------------------------




