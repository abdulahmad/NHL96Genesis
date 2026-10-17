# HANDOFF (NHL96)

## Purpose
A bit-perfect SNASM68k disassembly of NHL 96 (Sega Genesis) that reads like original source, named after
the NHL95Genesis lineage. Code and data never change: every build must MATCH the retail ROM.

## Setup
See START_HERE.md. ROM `lst/nhl96.bin` (SHA-1 7204633fbb9966ac637e7966d02ba15c5acdee6b, 2 MB) and the
IDA listing `lst/nhl96.bin.lst` are in the repo for now (the listing is about 53 MB; GitHub warns above
50 MB). If they are removed later, put them back at exactly those paths; the prebuild message names
the path, SHA-1 and size.
Windows: `npm run build:retail`, `npm run seg:<name>`. Linux (wine): `tools/build_rom.sh`,
`tools/verify_segment.sh <name>`, `tools/verify_all.sh`. All logs go to `output/`.

## Tools
- `tools/prebuild.js [retail]`: ROM check, then runs `tools/extractAssets96.js` when `Extracted/` is missing or stale
  (marker `Extracted/.extract-complete.json`, written last: `rom`, `romSha1`, `extractor`, `extractorSha1`, `files`).
  A changed extractor, or a missing or resized file, extracts again. The marker does not record a map SHA-1.
  A missing or wrong ROM stops the build and names the path, SHA-1 and size, including "ROMs are not included in the repo".
- `tools/extractAssets96.js [rom]`: writes `Extracted/NHL96/`. Team pals `Graphics/Pals/*h96.pal` (also the `assets`
  array in `tools/segmap96.json`, inclusive end). Graphics `Graphics/<Label>.map.jim`, or `.bin` for Sprites,
  Spritetiles, SpritePalette, frameSprData, HotList, HotList2, RevRinkTilelist and RosterFont. A map is one file;
  the tiles are eight bytes in. Z80 program `Sound/z80_snd_drv96.bin`. Sound bank
  `Sound/Bank/snd96_{patch|sample|song|list}_{id}.bin` (168 items). Scout text `Text/ScoutTextScript.bin`.
  `npm run extractassets` calls it. Source incbins `..\Extracted\...` (paths are relative to `src/`).
- `tools/extractSegments96.js` is not part of the build. It still cuts segment slices if invoked. Do not point prebuild back at it.
- `tools/segmap96.json` is the ROM map (decimal inclusive start and end, tiled, indent 1). `find95.py` and these docs use it.
- `tools/make_segmap96.py [--lst] [--rom] [--code-cap] [--data-cap] [--out]`: made the first split. Do not
  rerun it onto `tools/segmap96.json` once segments are converted (`npm run segmap` writes to `output/`).
  When a segment's confirmed range differs, edit its entry in `tools/segmap96.json` and the neighbour's.
- `tools/find95.py <segment | start-end> [--len N] [--min-distinct N] [--refresh]`: 95G labels found in a 96 range
  by their first bytes (95G ROM and name map downloaded from GitHub into `output/ref95/`). Log in `output/`.
- `tools/fixopcodes.js`, `tools/verifyRom.js`, `tools/verifySegment.js`: as in 95G.

## Naming and comment rules
In SEGMENT_AGENT.md, "Current rules". History (renames, IDA names) lives in `docs/name_map.csv`
(address,name,ida_name,old_name,module).

## Conventions
One concern per commit, MATCH before every push; `git pull --rebase origin main` then push to main.
No force-push. Contributors: fork, branch, PR (START_HERE.md section 0).

## Setup friction fixed
- The main96 test needed the 95G ROM to find matching routines; tools/find95.py fetches it from the public repo.
- Linux: wine was not installed in a fresh cloud container (`apt-get install wine wine32` after `dpkg --add-architecture i386`).
- Linux: `buildseg.bat` stopped at `cd /d ... || exit /b 1` (wine 9 cmd takes the `||` branch even when cd works), so
  every segment build wrote no log; it now uses `if errorlevel 1 exit /b 1`.
- Matching 96 code to 95G: the 95G repo has its IDA listing (lst/nhl95.bin.lst). Aligning the two listings by
  instruction shape (addresses masked) finds renamed and moved routines that find95.py (exact bytes) misses.

## Current state / Next
- Bootstrap: 33 incbin segments, full ROM and every segment MATCH.
- main96 converted (test of the docs): 95G names for SegaInit, CHECK_VDP, RegionPrint, RegionFont, RegionOK, VBjsr, Begin, IRQ7, ValidationRoutine; the 96 region lock (hex digit country code) named from what it does. MATCH (segment and ROM).
- code96_01 ($000776-$0096E7) turned out to be data only, in the 95G order of teamdata95, credits95 and frames95, so it
  is split into three segments: teamdata96 (VBjsr in front of TeamList, the team blocks, playoffseats), credits96 (Credits,
  CreditsList) and frames96 (SPAlist and the animation tables). All three MATCH (whole range) and the ROM MATCHes.
  Source written from the ROM bytes with the 95G macros (src/macros/genesis.mac copied from 95G: String, Player).
- 96 team data: no All-Star teams (TeamList slots 26 and 27 point to Boston and Montreal), and every block ends with
  .pos, one nibble per player: the player's slot in .ls order (0 G ... 5 RW), $F padded.
- 96 rebuilt the animation tables: almost none match a 95 table by shape, and find95 finds none of the 95 animation
  code. The tables are named SPAxxxx by their SPA value (the number the code moves into SPA(a3), d1 for SetSPA,
  sub_1A614 in 96) until the code using them is converted; then rename them (name_map.csv). The 96 animation
  routine is sub_16654 (95 updateanim): it only uses attribute bit 0 (loop) and stops a direction at its first
  negative time; pairs after it are marked "past the end" (the code may still index them directly).
- RAM: dword_FFD244 is now vbint.
- code96_02 converted: the listing range as SNASM source, names from 95G where the routine matches (instruction
  alignment of the 96 and 95 IDA listings, then the 95G source for locals and comments; RAM names only where the
  address offset agrees with its neighbours or the code shows it). MATCH (segment and ROM).
- IDA's text is lossy after printz / printsmallz calls (the inline String): it shows ori.b lines with other bytes
  and even drops words. Those Strings were written from the ROM bytes; check every jsr to them in later segments.
- Code the listing leaves as dc.b (reached through tables or not referenced) stays as bytes, split at the labels the
  pointers or 95G byte matches show (assfaceoff ... puckfaceoff2, Endfaceoff, ReadJoySwapPad1-4; PrintSetupStrHi
  is 95G source, same bytes). Code bytes after sub_975A have no reference and no name.
- Kept as IDA names (no clear match): sub_AFDA, sub_B6A0, loc_AFD4, and outside loc_14D6E-loc_14D84 (doinput start
  button), loc_EE0E (95 jumps to lineinput there, but the 96 code differs), loc_1A62A, loc_16934, loc_C26C.
- RAM: about 80 IDA names renamed (ram96.asm, name_map.csv). crowdlevel and padiconchars2 share $FFFFB8B2 (the setup
  screen keeps pad icon chars in game RAM). 96 tmstruct is $FFFFC726 with size $39E (equals.inc tmsize is still 95's
  $366). The 96 cont1team ... cont4team are $FFFFC390-$FFFFC396.
- frames96: the goalie tables named from ClampTargetY's unreferenced SPA list and doinput_goaliedive (SPAgglover,
  SPAgglovel, SPAgstackr, SPAgstackl, SPAgstickr, SPAgstickl, SPAgdive).
- code96_03 converted: fighting, asstab and the penalty texts. MATCH (segment and ROM).
- 96 brings fighting back from 93: the fight routines take the 93G names (checkfight in code96_02, startfight
  for 93's checkfight .sf, SetInst, fightinput, ClearMessageLine, assfight, assfwatch). 96's player struct is not 95's
  past $60: SetInst reads the player number at $67 and the fight rating at $75 (95 / 93: $66 / $74), so the 95 names
  in equals.inc for $66-$76 (pnum, weight, ... checking, handed) are not used until 96's layout is known.
- About 11 KB of this segment is code the listing does not decode (the assignment routines behind asstab, assfight,
  assfwatch): bytes, with a label at every asstab entry (loc_<address> where nothing names the routine). Even with
  RAM addresses masked only a third of it matches 95: 96 rewrote the player AI. With the "do not disassemble" rule
  these segments stay mostly bytes; a re-analysed listing (IDA following asstab) would turn them into code.
- Penaltylist and PenShotPenalties are data: written from the bytes in the 95G layout; 95's local names where the
  penalty number and text are the same, .pXX for the rest (96 adds Boarding, Elbowing and High Sticking).
- code96_04 converted: line changes, shot and pass, roster names, the season simulation. MATCH (segment and ROM).
  Unmatched routines keep their IDA names; small unreferenced code runs stay bytes. A comment on doshot reads
  shotacc at $6E (95 $6D): more evidence that 96's player struct is shifted past $60.
- Converting a segment can change names other converted segments use (code96_02 now jumps to lineinput, defined
  here): run the full ROM build, not only the segment, before committing.
- code96_05 converted: season / save RAM code and screens, almost all new in 96 (no 95 or 93 match), so IDA names.
  MATCH (segment and ROM). sub_12B84 is DrawSetupTeamBlock (95's role in ControllerSetupScreen; the code has
  95 DrawPadIcon's shape, but code96_02 DrawPadIcon is the one with the pad icon tables).
- More inline data after calls: besides printz / printsmallz, the routines at $1BC72, $1BEC4, $1BED6, $1C11A and
  $1C12C take a String after the call (move.l a1,-(sp) / movea.l 4(sp),a1), and DecompressGraphicsWithCallback
  ($1B724) takes an 8 byte remap table. IDA decodes all of these as instructions (some do not even assemble).
- SNASM turns addi / subi #1-8 into addq / subq: the source keeps them with opt oaq- / opt osq- (osq for subi).
- macros/genesis.mac: String takes up to 40 arguments (the 96 stat screen Strings are long).
- data96_01 converted: mostly code, not data. MATCH (segment and ROM). It holds the playoff seeding (95G awards95
  names: InitPlayoffs, SeedPairings, SortSeeds, CalcSeedPoints, CopyBytes, ConferenceTeams1 / 2, SetupPlayoffs;
  96 seeds the 16 slots by conference and division, TeamDivisions), ResolveGames, the hockey95 game flow (Begin,
  StartGame, StartPer, Gameloop, DoGameFrame), ResetClock, restoreteams, RestoreBenchEnergy, updatecrowdf, clockcont,
  demoread, startpause1-4 and the pause95 menu (Pausemode, seta2, InitMenuState, HandleMenuInput,
  UpdateMenuSelection, PrintMenuItem). The 96 menu code is shorter than 95's; the names follow the 95 role.
- unk_13558 is SeasonSchedule (the 95G Day format, 191 days): written with the Day macro and the team equates.
- Byte runs with labels: GetNameandAttrib, attribjmp (written as offsets) and the Attrib column handlers
  (StatusTextTbl, InjuryGamesTbl, HandedTextTbl as Strings; 96 adds RatingToWeight / WeightTbl), TimeoutMenu and
  SelectGoalieMenu (found from the pause menu lists), RestoreSeasonHeader (95G shape, unreferenced), PrintMenuList
  (jsr from code96_05) and the vbint handler unk_12D46. Code after Pausemode has no reference and no name.
- Save RAM in 96 is byte addressed (SaveRAM+offset, odd bytes): ram96.asm has SRSeasonHeader, SRPOPairings,
  SRSeasonHeaderSave, SRPOSlots as offsets. The seeding work lists sit at the start of RAM (AwardIds, SeedStandings,
  SeedPoints, SeedGames, SeedCount, POPairingsTmp).
- RAM: 50 more names (gsp, gsstruct, bosgames, gamelevel, WinBits, menuitem, menulist, OptPlayMode, PALflag, ...).
  crowdcnt and CwdExciteLvl share $FFFFB8B6 / $FFFFB8B8 with the pad icon chars, as crowdlevel does.
  Outside routines named where this code proves them: SoundCmd, SoundOff, KillCrowd, stop_current_song, song,
  Z80Program, SoundBanks, Opening, vb2, ChooseSong, sfx, ExitToOpening, ClearPenalties, ClearPenaltyBuffer,
  LockScroll, setupice, Create_HotCold_Table.
- code96_06 converted: updatereplay, updateplayers, updateanim, checkwindow, the pad switches (chgplayer,
  setcplayer, setc1-4player, restorepl, setpads), burst, holdplayer, FindGoalie, GetGoalieCount(D7) and
  GetPlayerCount(D7) (96 reads the counts from save RAM SRTeamCounts). MATCH (segment and ROM).
- The 96 asstab uses the 94 assignment numbers (NHL94Genesis data94.asm asstab), not 95's: entry n of the 96 table
  matches the 94 routine n by bytes (RAM words masked). So the asstab entries take their 95 / 94 names by index:
  here assscore, assstanley (94 only), asseben, assepen, assbench, asspenalty, assdopen, assgoaliecpu, assgoaliectrl,
  assgoaliebreakwait. The entries in code96_03 ($1-$6: assdefo, assdefd, asswingd, asswingo, asscenterd,
  asscentero) and later segments ($F asstab entries on) can be named the same way when those files are touched.
- Undecoded entries found by masked byte comparison with the 95 / 94 ROMs (a small helper: 16-bit words equal, or
  both $A000 and up as RAM): ReplayMode and its helpers (WaitVSyncAndReadInput, ShowReplayIcon, EraseReplayIcon,
  ShowReplayBanner, EraseReplayBanner, suba4, UpdateCameraPos, RevReplayAdj, ClampReplayView), check4bench,
  donothing. A second copy of burst (unreferenced) and a dead block in updateplayers stay as unnamed bytes.
- SPA values used here renamed with their 95 names (SPAboardmidl ... SPAboardbot, SPAhook, SPAHold, SPAburst);
  the tables of every named SPA value are now <name>_table, as name_map.csv already said for the earlier ones.
- Outside routines named: getpde, setpde, PlaceBoardFall, dirtab. RAM: Vpos, Hpos, glovecords, bholdtimer34,
  yc1, yleader, PBnum, BA_Sktr_SCnum, FallXPos, replaydelay, replayend, crowdframe (shares padiconchars1).
- code96_07 converted: AdjustFacingDirection, goaliesave (saveanim written with the SPA names), chkpk2, checkob,
  EndPenaltyShotPlay, ChkGoalies, CPgoalie. MATCH (segment and ROM). Most of the segment is code the listing does
  not decode: labelled bytes at the asstab entries (assgoalietopuck, chkpuckc, asspuckc, assbreakaway, assnearest,
  asspassrec, assshoot, puckshootout, puckpenshot, pucknorm, puckunflip) and where outside jsr / jmp / movea.l
  targets match a 95 routine by masked bytes (breakaway, BreakawayOffsidesFlagSet, EvadePC, check4check,
  SelectPenaltyShotSkater, ReturnGoalies, CompLine, AssignPads, ChkOffsides, a2offsides, puckIChk); the others
  keep address names (loc_19B16, sub_19E6E).
- The listing decodes btst Dn,#imm (btst d1,#$42) as a blank mnemonic and garbage; written by hand in
  AdjustFacingDirection (code96_06 sub_16D36 has the same form).
- RAM: savednewpnum, puckz, RefCnt. Outside: PushRef, setpersonel, CountShootoutGoals.
- code96_08 converted: the player movement core (SetSPA, doplayeracc, goalieacc, playeracc, dostop, stopna2) and the
  shared low level code (vtoa, GetHot, random numbers, sroot, the pads, dma, vram, palette fades, the graphics
  decompressor, the print routines). MATCH (segment and ROM). Undecoded parts labelled from 95G bytes: the
  DecompressBytecode opcodes (jump_table written as offsets), the print control codes (ControlCodeJumpTable written
  with their names), cramfade, forceblack2, DoDMA_nd2, FormatAndPrintTime, PeriodLabelTable, PushNumber, findpc,
  puckshadow (asstab $19).
- Print routines: 96 has three String printers. printsmall ($1BA40), print ($1BBA0, a fixed font map) and the one
  with the font map at smallfontptr, which is 95's print; it is printcur / printcurz here because print and printz
  already name $1BBA0 / $1BB8E everywhere (clash rule). printbig / printbigz set bigfontptr; printbigcur /
  printbigcurz print with the font already there. All the z forms take the String after the call.
- RAM: pad4way1-4, lj1-4, callbackPtr, ThreeStars, nibblebuffer, seed, dmaram, PushWidthBuf, BigFontChars,
  bigfontptr, framercset, printa, printm, printfontset, repeatdelayframes, palfadenew, waitxpad.
- code96_09 converted: penalties and the ref window, the penalty box and power play box, line energy, shot stats,
  intermission and the other games' scores, the collision and check code. MATCH (segment and ROM).
- Inline Strings here also follow bsr.w calls (bsr.w printz), appendz, and the new printbigz1 / printbigz2: the
  scratch fixer handles bsr.w (4 byte call) now. IDA also decoded the penalty length Strings (PenaltyTimeTxt) as
  code with a bogus sub_1CBDC; written as Strings. Some instructions IDA dropped after a String were put back by
  hand from the ROM bytes (moveq, movea.l, cmpi.b, two bsr.w).
- Game code had picked up the setup-screen names of the shared crowd RAM (padiconchars2 / padcursorchars);
  it now uses crowdlevel, CwdExciteLvl, crowdcnt, crowdframe and the new crowdtblidx.
- RAM: sflags4, sflags8, Ylist, OOlist(pos), PenSum, energybarchars, EASNcset, wcradiusx/y, ltx, lty, collflag,
  msgtimer, Penaltytimer, penmsgtimer, RefStep, RefPen, TempPlOffset, TickerNum, BA_Team, BA_Goalie_Offset,
  BA_Checker_Offset, pspenalty. Outside: ResetBench, checkwallcoll, UpdateRecords, FallDown.
- code96_10 converted: FallDown, setInjuryType, the wall and goal collisions (checkwallcoll, checkgoal, checkgoalp,
  CheckBump, wallcollb, wallcoll), the player energy (makepde, getpde, setpde) and the players on the ice
  (setpersonel, SetPlList, TryAddPlayerToList, ResetBench, setplayer). MATCH (segment and ROM). puckbody,
  SetupPenaltyShot and forcepldata are labelled bytes found by masked byte comparison (SetupPenaltyShot uses
  assignment $20, the 94 number of 95's $1D).
- 95 comments that name player struct fields past $60 (or the roster bytes setplayer reads) were dropped where
  the 96 offsets differ.
- RAM: puckcross2, puckcross6, PPBonus, PlayerChked, PlayerChking, ScoreSum, PlList, ltplayer, crowdnoisedelay,
  FallYPos, homeshootgoals, awayshootgoals, shootoutteam. Outside: AttributeCalc.
- code96_11 converted: the vertical blank handlers and the sprite / display code, setupice, the team setup, the game
  flow between periods and games, the EA Sports screen, DefaultMenus, the playoff tree and FigureJoy. MATCH (segment
  and ROM).
- $201DC is VBlank (the game handler, 95 VBlank by masked bytes) and $202C4 is vb2 (the fade-only handler forcefade
  and EASportsScreen set): data96_01 had called $201DC vb2 from 95's StartGame; StartGame now sets VBlank.
- IntermissionStart ($2161E), ExitToOpening, Opening and Opening2 sit together here; StartGame (data96_01) jumps
  to IntermissionStart.
- RAM: DMAList, DMAlistend, Satt, sso, pads, padcont, fofdata2, Joy1/3/4Struct, potree, postarts, potreeteam,
  pojoy, OptNOP, Opt1team, Opt2team, animchars, faceoffvrcset, Oldrow, Hscroll, Vscroll, zamx.
- code96_12 converted: the playoff pass bits (ReadPassBits, EncodePW, WritePassBits, the 5 word arithmetic), the
  playoff team stats in save RAM, ResolveGames, the Stars of the Game box, the injury, penalty shot and goal boxes,
  the player name strings and the exception vectors (crash, the 94 handler). MATCH (segment and ROM).
- ResolveGames is $22670 (95 ResolveGames by bytes); the data96_01 routine that had the name is ResolveDayGames.
  $21CF4 (code96_11) is maketree (EncodePW calls ResolveGames then it); $14AD4 (data96_01) is CheckInjury, the
  timer head of ShowInjuryBox. The injury box ($22A2C) was undecoded in the listing and is written out by hand.
- getplayername ($101C6) is GetPlayerNamePointer as in the 95 source: SNASM labels ignore case, so it clashed
  with GetPlayerName ($22E70).
- Outside: CountGoalies, PrintPlayerGoals, PrintPlayerAssists, ShootoutModeBox (externs96).
- RAM: tpassbits, pwddatabuffer, statsbuffer, recwins, homegoalies, awaygoalies, InjCntDown, jerseynum, injurygames,
  puck_pflags2.
- data96_02 converted: the game tables, the save RAM routines, the pads, the font loaders, the sound driver, the
  Z80 program and the start of the sound bank. MATCH (segment and ROM).
- The tables are written as source: CrowdFrameTbl, bfasciicon, linelist, PlayerPositionText, PerLabels(2), sizetab,
  sublist, priolist and the attribute columns as in 95; the pause, intermission and line menus as String items with
  dc.l handlers (InitMenuState lists). code96_09's intermission table is now IntermissionMenus (dc.l of the menus).
- Menu handlers named by their item, as 95's pause menus name them: PlayGame, LineEditor, GameStatisticsScreen,
  PlayerStatsScreen, ScoringSummaryScreen, PenaltySummaryScreen, TeamRosterScreen, RecordHoldersScreen,
  PeriodStatsScreen, ManualGoalieMenu, ShootoutShooters, SaveTeamLine, LoadTeamLine (externs96), AbortGame and
  SetOriginalLines (code96_11; SetOriginalLines is the line setup tail of InitTeamStructure).
- The save RAM is $2000 bytes here (95: $8000): InitSaveRAM, ValidateSRAM, ClearSRAM, WriteSRAM, MakeSRAMChecksum
  (skipped while GameFlags bit 6), ReadSRAM, ClearSRAMBytes. nullsub_1 (code96_04) is NullSaveClear.
- The sound driver is the 95 one with 19 commands through SndJumpTable ($A queues a command, $10 SndSongControl,
  $11 SndFindSong, $12 the old SndSendZ80); its routines are labelled bytes (95 masked byte matches and the table).
  SndDriver writes its cmpi.w #$13,d0 as dc.w: tools/fixopcodes.js turns a built cmpi.w #,d0 into cmp.w.
- SoundBanks: the SndItem table (168 items), then the item data with a comment per item; the segment ends inside
  sample 16, which continues in data96_03.
- RAM: ValidSRAM, SRAMChecksum, SndDrvRAM.
- data96_03 converted: SoundBanks item data from inside sample 16 to inside song 0 (the samples, the patches), dc.b
  with one comment per item. MATCH (segment and ROM). No labels: the listing's unk_44120 was the constant
  move.l #$44120,(a1) in code96_04 (String length 4, 'A '), now written as the constant.
- data96_04 converted: the rest of the SoundBanks items (songs, the load lists; one comment per item) and the
  game's sound calls as in 95 sound95: SoundCmd, UpdateCwdExcite, updatesound, CheckLateGameSong, sfx / sfxplay with
  SfxTable, song, StartSong, stop_current_song, SoundOff, ChooseSong with TeamSongs and RandomSongs. MATCH (segment
  and ROM).
- The unreferenced 95 leftovers are labelled bytes: stop_current_song2, KillCrowd2 (a copy of code96_11's KillCrowd,
  so the name), p_initialZ80 (cut down to the Z80 reset), ClearAllTrackAndSFXSlots.
- The listing's unk_7A40A (from off_1E9028) is a number: the code at $1E9038 compares with it (cmp.l off_1E9028(pc)),
  so no label here; write that dc.l as $7A40A when its segment is converted.
- RAM: asv, periodendtime, MaxCwdExciteLvl, NumCwdExciteLvl, SumCwdExciteLvl, SndSeqPtr, SndSeqId.
- code96_13 converted: newcheck (95), then data nothing references: ScoutTextScript, the 95 scouting text lines
  (95 masked byte match; written as dc.b strings with $D), and a $68AE byte block after it with no 95 match and no
  reference (kept as dc.b). MATCH (segment and ROM). RAM: ltack.
- data96_05 converted: graphics. The maps chain one after another, each as its header (dc.l .pal-X,.map-X), the
  tile count and tiles (dc.b), the palette (.pal, dc.w) and the map (.map: width, height, the words): unk_8F2C6,
  unk_90686, unk_911B8 (used from code96_20, purpose not known yet), Framermap, FaceOffMap, Rinktilelist, RefTiles,
  RefTilesHor (95 names by use); then Sprites (header: the palette and frameSprData offsets land in data96_06) and
  the start of Spritetiles. MATCH (segment and ROM).
- The +8 references (the tiles) are written Label+8 in the other files. code96_11's sub_2109A is setupIceRinkPal.
- The listing's unk_A0000 (from data96_10, move.l #unk_A0000,d1 before a divu) is the number $A0000: no label; write
  it as #$A0000 when data96_10 is converted. data96_06 holds the sprite palette at $12F588 (Sprites + $94AEA)
  and frameSprData at $12F608 (Sprites + $94B6A).
- data96_06 converted: graphics, dc.b with labels at the resources the code uses (95 names by use): the rest of
  Spritetiles, SpritePalette and frameSprData (the Sprites header offsets), HotList, HotList2 (the GetHot variants in
  code96_08), CrowdFrameList, FaceOffSprites, EnergyBarMap and EASNmap (written as maps), EASportsMap, RevRinkTilelist
  and the start of ReplayIconMap (used by ShowReplayIcon; its tiles at +8 open data96_07). MATCH (segment and ROM).
  code96_11's sub_210B0 is setupEASNmap.
- data96_07 converted: graphics maps, each written as a map (header, tiles, .pal, .map): the rest of ReplayIconMap,
  ReplayBannerMap (ShowReplayBanner), the maps used from code96_14 / code96_15 / code96_05 (unk_ names, purpose not
  known yet), the setup team blocks, team logos and small logos, named per team from the data96_01 pointer tables
  (TeamBlockPtrs, TeamLogoPtrs, SmallLogoPtrs, now dc.l of the labels), and ControllerBgMap. One unreferenced block
  stays dc.b. MATCH (segment and ROM).
- data96_08 converted: the fonts (RosterFont, SmallFontMap, SmallFontMap2, BigFontMap, BigFontMap2) and the screen
  maps. A label at every address the code uses (unk_ names where the purpose is not known; their +8 tile references
  are written Label+8); a labelled region that parses as a map is written as a map, a further map in it as numbers
  under ";The next map", anything else dc.b. MATCH (segment and ROM).
- data96_09 converted the same way as data96_08: the screen maps (unk_ names), the controller setup pad icons,
  cursor and ControllerTitleMap, and the big fonts. The big font names follow 95 by the print routine: printbig1 uses
  BigFontMap, printbig BigFontMap2, printbig2 BigFontMap3; the font printbig takes with sflags11 bit 2 is BigFontMap4
  (data96_08's BigFontMap / BigFontMap2 renamed, old names in name_map). MATCH (segment and ROM).
- data96_10 converted: screen maps used from other code (unk_ names), then the one-timer code that 95 keeps in
  input95 / logic95: puckvzadj, OneTimerPass, OneTimerTarget and OneTimerNearTbl / FarTbl / GoalieTbl as source;
  assonetimer (asstab $23) and setonetimeranim as labelled bytes. The constant $A0000 in puckvzadj is written as a
  number. RAM: onetimertargetx, onetimertargety. MATCH (segment and ROM).
- code96_14: $1D6D10 is CheckOneTimerFacing (setonetimeranim calls it after vtoa, as in 95); PuckOnAttackHalf starts
  the segment.
- code96_14 converted: the crowd meter (InitCrowdMeter, UpdateCrowdMeter), stopfast (a stopna2 copy with step $7D0;
  stopna2 itself is code96_08's), checkcornercoll / cornercollb (95 names: the wall test without the goals;
  code96_10 keeps checkwallcoll), the hot / cold players, the team / crowd records and name log, CalcAttrib with its
  weight lists, the string helpers, the shootout code and skate paths, GetTeamNickname / GetTeamArena. Undecoded
  routines are labelled bytes by 95 masked byte matches. MATCH (segment and ROM).
- ShowCrowdFrame2 is a copy of code96_11's ShowCrowdFrame that nothing reaches.
- code96_15 converted: LoadReplayIcon, LoadHomeTeamGfx and TeamGfxList, the goal / assist counts, PlaceBoardFall,
  getFgtbyte / chkFgtBit1 (96 reads $75 / $77 of the player), HiScoreScreen, ReadGoaliePulled, EndOneTimer,
  ClearPenalties, the standings code and group tables, SetSframe; labelled bytes for TeamLogoPalettes (exact 95 bytes;
  code96_14's near copy is now TeamLogoPalettes2), LeadSong, CanBlock, LeadersScrollArrows, SortValuesUp.
  MATCH (segment and ROM). RAM: StandingsMode, StandingsBuf, StandingsList, CalTeam (= ThreeStars), CalMonth,
  StandingsOrder, onetimerflags.
- code96_16 converted (new in 96, no 95 match): WaitAnyPad, the helpers of the season playoff stats screen
  (code96_15's loc_1DB020 is now SeasonPlayoffStats; the helpers are PStats...), and the playoff menu screen
  (PlayoffMenuScreen, its routine table and ClearPlayoffSave). A few inline Strings after printcurz were written
  by hand from the ROM bytes. MATCH (segment and ROM).
- data96_11 converted: the roster menu (RosterMenuList, YesNoMenuList: Strings, then item routines that return
  their text in a1; MenuCreatePlayers / MenuSignFreeAgents / MenuReleasePlayer), the trade and create player
  screens (code the listing does not decode: labelled bytes by 95 masked byte matches and by the tables: the
  Field... / Edit... routines follow SkaterFieldList / GoalieFieldList / SkaterEditList / GoalieEditList and the
  rating labels; 96 has no Aggression row and its Checking row sits where 95 kept Aggression), the texts and tables
  written out, then CalcAttribRating (source), MinOverallRating and the weight list copies (OvrPlayerWgtList2,
  OvrGoalWgtList2, AttribWgtList2). code96_16's PlayoffMenuRoutines is now dc.l labels. MATCH (segment and ROM).
  RAM: attribsum, attribcount, CreatePoints. sub_1DFBAC / sub_1E0536 (free agents, release player) are code96_17.
- code96_17 converted: the created players list (ClearCreatedPlayers, DeleteCreatedPlayer, GetCreatedId,
  ReadCreateList, WriteCreateList), SignFreeAgents and ReleasePlayers (labelled bytes by 95 masked byte matches;
  FreeAgentMsgText / ReleaseMsgText written out), then the game options screen, new in 96: OptionsScreen,
  OptionVars, OptionsMenuList (its ...Item routines are bytes, the ...Text tables Strings), OptionsScreenSetup,
  ClearGameRAM, ReadOptions / WriteOptions (save RAM $1EC6) and SetPlayMode. MATCH (segment and ROM).
  RAM: OptGoalie, OptUserRec, OptFighting, OptSkill, OptRosters (by the menu rows and OptionVars).
- A String with more than about 32 arguments fails ("Too many parameters in macro call"): group control bytes
  as one argument, String <$8F,$03,$09>,'Play mode:',... (same bytes).
- code96_18 converted: the option helpers SetPlayMode calls (SetGoalieModes, FlipUserRec, SetLineOption,
  SetPenOption, SetSkillLevel and their tables), OptionsAnimFrame, the line editor (labelled bytes: LineEditor,
  PrintAttribHeader, DrawLineIcons, ClearLineEditorTop, ClearMenuFlags, LineIconPosTable, LineCursorTable,
  SetLineSlot, LoadTeamLine, SaveTeamLine), ReturnToGame (the tail of 95's Pausemode as its own routine),
  RestoreGameScreen, ClearOldFrames, and sub_1E2970 (bytes, called from code96_04's undecoded bytes) with
  PeriodText, DigitText and PrintDigit. MATCH (segment and ROM). word_FFD284 / word_FFD286 are set by skill level
  (SkillLevelTbl / SkillLevelPalTbl); not renamed.
- data96_12 converted: about 10 KB of code the listing does not decode, labelled bytes: the pause menu screens
  (TeamRosterScreen, ScoringSummaryScreen, PenaltySummaryScreen, PeriodStatsScreen, GameStatisticsScreen,
  RecordHoldersScreen, PlayerStatsScreen), ShootoutShooters, and 95 masked byte matches inside them
  (PeriodStatsTeam, TeamStatTextTbl, PrintShooterList, ShootersPick, PrintRecordName, CalcWinPercents,
  ReadTeamRecords; the record texts as Strings). Then PlayerStatsList (source: the game / playoff stats screen of
  a team, d7 = 0 / 1, as in 95) with ReadAnyPad and the PList... helpers. One printcurz block in PListArrows was
  written by hand from the ROM bytes. MATCH (segment and ROM).
- code96_19 converted: PListPrint / PListValue / PListMark (PlayerStatsList), the user name entry with the
  records95 names (NameEntryScreen ... UserNameEntry, CountTeamPads, SkipOtherUserName, ClearNameRecord), the
  playoff tree screen with the playoff95 names (PlayoffScreen, HandlePlayoffInput, UpdatePlayoffScroll,
  PlayoffScreenExit, PrintSeriesScore, DrawTreeArrow is an rts, DrawTeamBlocks, VBlank_Playoff, PlayoffTreeSetup),
  showclock / showclockdma / ClockDigitChar (code96_11's sub_20722 jumps to showclock), ShowBigScore /
  ClearBigScore, and SeasonAwards (96 browses the 9 awards) with its helpers and texts. The award pictures are
  labels in data96_09 now (HartPic ... PearsonPic). About 20 instructions after inline Strings were written by
  hand from the ROM bytes (the listing is lossy there). MATCH (segment and ROM). RAM: NameEntryLen, namelogsel,
  nameentryvis, pad1user ... pad4user (the 95 block layout), new namelog, NameEntryBuf.
- code96_20 converted: GetAwardWinner and two award record writers, the season injuries with the injury95 names
  (RandomInjuryGames, SetInjuryGames, SetSeasonInjuries, GetInjuryGames as labelled bytes), the opening screens
  new in 96 (kept as sub_ names with their callers), and ValidationRoutine with ChecksumLongs (the number $7A40A)
  and ChecksumValue. SegaIDTable96 has a ProductCode label for the header long the checksum leaves out. code96_13
  has a label unk_88A18 (a map code96_20 draws). MATCH (segment and ROM).
- Every row of the ROM map is matched. Left for later passes: the labelled byte runs (code the listing does not
  decode), the sub_ / unk_ names, and the RAM words still under IDA names.
- Align-with-95 audit: `docs/align95_plan.md`. 928 labels already use a 95G name. The file split started
  with `engine/fight96.asm` (checkfight through sub_C51C, $00B6A0-$00C547) and `engine/fourway96.asm`
  (Detect4WayPlay through ReadJoySwapPad4, $00B5C8-$00B69F).
  `engine/goal96.asm` is the controller setup (SetContTeams through ReadAllPads, $00B04E-$00B5C7).
  `engine/input96.asm` is the pad input (updatepadinput through PadOnTeam, $00A4DC-$00B04D).
  `engine/faceoff96.asm` is the faceoff (faceoffinput through Endfaceoff, $0099CA-$00A4DB).
  `src/srambits96.asm` is WriteSRAMBits and ReadSRAMBits ($0096E8-$0099C9). code96_02 is gone.
  `engine/logic96.asm` is asstab through the penalty texts ($00C548-$00EC2F).
  `engine/lines96.asm` is the line change box (SetLCmode through lcfound2, $00EC30-$00EEFF). code96_03 is gone.
  `engine/input96_shot.asm` is the shot and the pass (shotdiradj through sub_1008E, $00F374-$0100BF).
  `engine/lines96_set.asm` is the team line writer (NullSaveClear, GetTeamLines, $00EF00-$00F373).
  `front/trade96.asm` is the roster names (DefaultRosters through the name tables, $0100C0-$010919).
  `front/season96_sim.asm` is the season simulation (SimGameStats through PickSimGoalie, $01091A-$010CB1).
  `front/season96.asm` is code96_05 renamed (season and save screens, $010CB2-$012BFD). The routines stay `sub_` until the bodies are read.
  `src/schedule96.asm` is the season schedule (SeasonSchedule, $013558-$013E9F).
  `front/awards96.asm` is the playoff seeding (nullsub_3 through BuildPOSlots, $013EA0-$0143FD).
  `src/hockey96.asm` is the cold start and the game loop (Begin through clockcont, $01464C-$014CC7).
  `engine/pause96_list.asm` is the menu list printers (PrintMenuList, PrintMenuList2, $0143FE-$01464B).
  `engine/pause96.asm` is the demo and the pause menu (demoread through vcountwait, $014CC8-$0151F9).
  `engine/setup96.asm` is the roster attribute columns (GetNameandAttrib through WeightTbl, $0151FA-$01548F).
  `engine/pause96_menu.asm` is PlayoffStatsMenu, TimeoutMenu and SelectGoalieMenu ($015490-$015773).
  `src/teamgfx96.asm` is the team graphics pointers (TeamBlockPtrs, TeamLogoPtrs, SmallLogoPtrs, $012BFE-$013557).
  `engine/replay96.asm` is the instant replay (ReplayMode through rtss8, $01581C-$0162EF). ReadMenuJoy stays in that file.
  `engine/players96_count.asm` is the team counts and WaitVSyncAndReadInput ($015774-$01581B).
  `src/control96.asm` is the player frame update and the pad switches (updateplayers through setpads, $0162F0-$016DAD).
  `engine/logic96_ass.asm` is the assignment entries (check4bench through assgoaliecpu, $016DAE-$017C05). code96_06b is gone.
  `engine/logic96_puck.asm` is the puck assignments (AdjustFacingDirection through assshoot, $017C06-$019017).
  `front/shootout96.asm` is the penalty shot and the shootout (puckshootout through EndPenaltyShotPlay, $019018-$019781).
  `engine/logic96_pull.asm` is the goalie pull and the puck checks (ChkGoalies through puckunflip, $019782-$019F3D). code96_07b is gone.
  `engine/logic96_vec.asm` is the puck flip and the hot spots (puckflip through the GetHot variants, $019F3E-$01A613).
  `engine/skate96.asm` is the skating (SetSPA through WeightedRandomSelect, $01A614-$01AEFF).
  `engine/video96.asm` is the screen and the print routines (remap through printbigtext, $01AF00-$01BF93). code96_08 is gone.
  `engine/penalty96.asm` is the penalties, with big-print in front of AddPenalty ($01BF94-$01D14D).
  `engine/lines96_bar.asm` is the line energy bar (linebar through sub_1D3A6, $01D14E-$01D3CD).
  `src/hockey96_inter.asm` is the intermission and the ticker (Intermission through SkipStrings, $01D3CE-$01D7FD).
  `engine/collide96.asm` is the collisions across the old file boundary (checkcoll through setpde, $01D7FE-$01FB51). rtss2 stays here.
  `engine/players96.asm` is who is on the ice (setpersonel through ClampNibble, $01FB52-$0201DB). code96_09 and code96_10 are gone. code96_11 now starts at VBlank.
  `src/display96.asm` is the picture (VBlank through resetplstuff, $0201DC-$021481). The crowd stays in that file. VBlank stays here; 95 keeps it in video.
  `src/control96_team.asm` is the two team structs (clearTeamStats through setplayercolors, $021482-$0215DB).
  `src/hockey96_open.asm` is the title and the end of a period (sub_215DC through UpdatePlayoffLevel, $0215DC-$021B51).
  `engine/setup96_menu.asm` is the default menu choices (VBlank_SetOptions through defmenuoptions, $021B52-$021BAF).
  `engine/playoff96.asm` is the tree and the saved series (ContinuePlayoffs through ResolveGames, $021BB0-$02281F).
  `engine/goal96_box.asm` is the whistle boxes (ShowThreeStars through box, $022820-$022E6F). The stars, the injury and the penalty shot stay in that file.
  `engine/middle96.asm` is the player names (GetPlayerName through PushNumberWidthZero, $022E70-$023143).
  `src/crash96.asm` is the exception screen (AdrErr through crash, $023144-$023247). code96_11 and code96_12 are gone.
  `src/code96_14.asm` keeps the crowd meter, the hot and cold players, the team records and the attribute weights ($1D6B66-$1D7FA5).
  `front/shootout96_path.asm` is the shootout body and the seven skate paths (ShootoutModeBox through UnpackPicture, $1D7FA6-$1D8E5B).
  `src/code96_15.asm` keeps the replay icon, the home team graphics, the hi-score screen and the penalty clear ($1D8E5C-$1D9CC5).
  `front/season96_stand.asm` is the standings (StandingsPoints through SortStandings, $1D9CC6-$1DA6BF).
  `front/season96_menu.asm` is the season stats screen and the playoff menu (SetSframe through ClearPlayoffSave, $1DA6C0-$1DC03B). code96_16 is gone.
  `front/trade96_edit.asm` is the roster menu and the trade screen (RosterMenuList through PositionLetters, $1DC03C-$1DD915).
  `front/create96.asm` is the create-player screen and the created-player list (CreatePlayer through sub_1E0D86, $1DD916-$1E0DDD).
  `front/options96.asm` is the options screen, new in 96 (OptionsScreen through OptionsAnimFrame, $1E0DDE-$1E1B17).
  `front/stats96.asm` is the line editor (LineEditor through sub_1E2644, $1E1B18-$1E2687).
  `engine/pause96_return.asm` is the return to the game (ReturnToGame through PrintDigit, $1E2688-$1E2E75).
  `front/summary96.asm` is the pause-menu pages (the roster through the record holders, $1E2E76-$1E55B9). The shootout shooter list stays here; it is not next to the paths.
  `front/stats96_list.asm` is the player stats list (PlayerStatsScreen through PListMark, $1E55BA-$1E646B).
  `front/records96.asm` is name entry (NameEntryScreen through PrintNameLogRecords, $1E646C-$1E7009).
  `engine/playoff96_tree.asm` is the playoff tree screen (PlayoffScreen through the layout bytes, $1E700A-$1E7663).
  `engine/middle96_clock.asm` is the ice clock and the big score (showclock through ClearBigScore, $1E7664-$1E7AC3).
  `front/awards96_show.asm` is the awards show, including GetAwardWinner (SeasonAwards through the award record writers, $1E7AC4-$1E8793).
  `front/injury96.asm` is the season injuries (RandomInjuryGames through GetInjuryGames, $1E8794-$1E889B).
  `front/title96.asm` is the opening screens, new in 96 (sub_1E889C through sub_1E8F52, $1E889C-$1E9027).
  `src/checksum96.asm` is the ROM checksum (ChecksumLongs through ValidationRoutine, $1E9028-$1E90D1). data96_11, data96_12, code96_17, code96_18, code96_19 and code96_20 are gone.
  `src/display96_crowd.asm` is the crowd frames (CrowdFrameTbl, $023248-$0232C7).
  `engine/middle96_ascii.asm` is the big-font ASCII table (bfasciicon, $0232C8-$023341).
  `engine/lines96_list.asm` is the line names (linelist, $023342-$02336F).
  `engine/setup96_pos.asm` is the position names (PlayerPositionText, $023370-$023383).
  `engine/middle96_per.asm` is the period names (PerLabels and PerLabels2, $023384-$0233AB).
  `engine/video96_size.asm` is the sprite size table (sizetab, $0233AC-$0233BB).
  `engine/players96_sub.asm` is the line-slot lists (sublist and priolist, $0233BC-$02342D).
  `engine/setup96_attr.asm` is the attribute columns (PAttribColumns through GAttribOverallMask, $02342E-$0236AF).
  `engine/pause96_items.asm` is the pause, pregame, intermission and game-over menus ($0236B0-$023E53).
  `engine/lines96_menu.asm` is the line editor exit menus (LineMenu1 and LineMenu2, $023E54-$023F1B).
  `src/sram96.asm` is the save RAM (InitSaveRAM through ClearSRAMBytes, $023F1C-$024225).
  `engine/video96_pad.asm` is the pads (ReadJoyData through ResetZ80Bus, $024226-$02437F).
  `engine/logic96_do.asm` is the assignment dispatcher (doassignment, $024380-$02439F).
  `engine/video96_font.asm` is the font loaders (LoadSmallFont through sub_243DA, $0243A0-$02441D).
  `engine/logic96_crease.asm` is the crease test (GoalieInCrease, $02441E-$02447D).
  `engine/pause96_play.asm` is the resume-game item (PlayGame, $02447E-$024485).
  `src/sound96.asm` is the sound driver, the Z80 program, the bank directory, the 168 bank items, the sound calls and newcheck ($024486-$088809). The Z80 program and each bank item are incbins. The SndItem directory and the calls stay source. newcheck is the last routine.
  `front/scout96.asm` is the scouting text and the picture after it (ScoutTextScript and unk_88A18, $08880A-$08F2C5).
  `src/graphics96.asm` is the pictures, one incbin per label ($08F2C6-$1D6621). A map is one file; the tiles are eight bytes in.
  `tools/extractAssets96.js` writes those files, the team palettes included. `tools/prebuild.js` runs it. data96_02 through data96_10 and code96_13 are gone.
  Three renames, now that the files exist: getGoalieSCnum is FindGoalie (control96), ClearShootout is ShootoutInit (shootout96_path), LetterGrid is CreateLetterGrid (records96). LetterGridPos is a different routine and keeps its name.
  `code96_14` ($1D6B66-$1D7FA5) and `code96_15` ($1D8E5C-$1D9CC5) stay numbered. Each head mixes several subsystems.
  Names taken from the matching 95 body: getplayernameD7 and getnamea0 (trade96), chkpk (logic96_puck), PenShotTable and UpdatePenaltyShotEnd (shootout96), a2touchpuck (logic96_pull), SetScroll2, ClockDigitChar, DoDMAList, DumpSprites2, rtsShowCrowd and ButtonLabelCharTable (display96), setteams (control96_team), InitCreateRecord and InitCreateRecord2 (create96). The big-font clock helper in middle96_clock is BigClockDigitChar. SegaInit locals are in the name map. LoadEnergyBarTiles, LoadCrowdFrames, LoadRefTiles, LoadRefTilesHor, LoadFaceOffSprites and LoadFaceOffMap decompress those pictures. DumpPadSprites, DumpSpriteTable, SetGloveAndSetupPad and JumpToShowClock are named from what they do. VBlank_SpriteFade (summary96) is the period-summary and awards vbint. setup96_menu already owns VBlank_SetOptions.
  Next: see "Naming pass" below. Steps 1-6 of the finish plan in `docs/align95_plan.md` are done except the Unsure
  rows; then the symbols pass (step 7). Earlier text: Decoded names first (`lines96_set`, then the small leftovers, then `season96`), then `dc.b` entries, one more 95G body search, graphics `unk_` labels, RAM, then the symbols pass. A generic label is finished when it has a real name or a closed-list row. Do not guess. Do not name the lone rts at $02032C rtss2. Do not reopen a numbered graphics or sound dump.

## Naming pass (Oct 2026, second session)
Work branch `naming-pass`, one commit per file, each ALL MATCH. Names from the body; a parent name only when body and callers match.
- lines96_set: GetTeamLines (a0 = the line sets of team d7: the team data `.ls` while CheckDefaultRoster says the saved
  roster is the DefaultRosters one, else built in RAM), BuildPosList (per position slot, sorted by CalcAttribRating),
  AddBestGoalie, AddLineSkaters, AddDefensePair, AddFourForwards, AddLinePlayer, TakePosListPlayer, TakeFallbackPlayer,
  ClearUsedPlayers, ClearPosListUsed, and the three fallback list tables. No 95G body: 95G LoadTeamLines is the parent of
  96 SetOriginalLines (already named), which copies sets 0 and 2-7 (OptLine) or 1-7 of GetTeamLines' result.

- season96: the save RAM season code. 95G names where the job, arguments and callers are the same and only the storage
  changed to bit fields (ReadSeasonHeader, WriteSeasonHeader, RecordGameResult, RecordTeamResult, ReadStandings,
  TickTeamInjuries, BuildSeasonTeamList, ClearSeasonData; WriteDayGames also matches 13/16 words). New-in-96 names from
  the code: SaveGameStats, AddTeamGameStats, AddSavedStats, Read/WriteSRAMBitWords, StartNewSeason, SimSeasonDays,
  SaveUserGame, UserGamePlayed, ReadUserGameCount, FindUserGame, LoadSeasonOptions, SetupSeasonGame, the team select
  screen (TeamSelectScreen, TeamSelectGfx, the rank printers, TeamRankPtrs, the logo drawers, TeamSelectSide,
  RedrawTeamRanks), RunSeasonMenu and SeasonMenuScreen (its menu text), LoadScreenSprite / DrawScreenSprite (seven
  screens use them), SetMenuScroll, DrawTeamLogoD7. homegoalies doubles as the menu background scroll.

- playoff96: folds. maketree's six inner labels are locals now (.loop, .bypoints, .reseed2, .reseed4, .next, .nogames; the
  clashing locals renamed .final, .keep, .p1-.p3, .nofinal, .games). FigureJoy keeps its 95G locals (.9, .10, .fjnpo, .ex,
  16/16 and 20/20 words). FirstRoundSeeds (read by maketree, not SetTreeGameTeams) and NOPJoyTbl (95G, 14/14 words).
- Arena animation (shootout96_path): 94G names. The three nullsubs are 94G AddArenaAnimSprite, RunArenaAnim and
  StartArenaAnim with an rts put first (the dead bodies match 47/52, 20/20, 20/20 words, same callers); SetFaceoffAnim and
  EndArenaAnim match all their words. ShowCrowdFrame2 is the `.spr` tail of AddArenaAnimSprite (folded).
- title96: TitleScreen, CreditsScreen, PrintCreditsPage, the two wait-frame helpers, VBlank_LineScroll and its unused copy
  VBlank_LineScroll2 (nothing sets either), the Cup win scene (CupCelebration, its setup, sprites and cheer delays).
- awards96_show: DrawAwardWinnerLogo, GetAwardWinnerTeam, SetSeasonAwardWinners, SetPlayoffAwardWinners,
  CupChampionsScreen (MightyDucksTxt / OfAnaheimTxt). season96_menu: BuildPlayerLeaders and PlayerLeaderJumps (95G),
  BlankStatsRow. stats96: FormatLineName. summary96: BlankMenuBox, PeriodGoalsTxt, PeriodShotsTxt. playoff96_tree: the
  scroll tables.

- Season sim (trade96 / season96_sim): SimScore (95G: role, caller and the playoff-tie tail match), SimTeamStrength, the
  goal model tables and the sim penalties, scorers, assists and shots. SimTeamGoals, SimScorers and SimShots carry the
  95G names by role and interface (the bodies are new). GetPositionSlot, GetSeasonRosterId.
- Trade (trade96_edit): ExecuteTrade (95G, masked 18/20 and 14/16), ExtractTradedPlayer (95G, four 14-word windows),
  FixJerseyNumber (95G 11/12), DeleteStatSlot / InsertStatSlot (new: packed stat fields), WaitMenuFrame, EraseBlank.
  The old ExecuteTrade label at $1DD09A sat inside the operand of a jsr and nothing used it: removed. TradeDone moved
  six bytes later, past the blt / rts that end the routine before it (no byte moves).
- Create (create96): the field handlers and their table fold into CreatePlayer (.redraw, .fieldjumps, .namefield,
  .posfield, .handfield, .weightfield, .jerseyfield). CreateNameDone stays global (CreateListMove, closed list, sits
  between). ModifyRatings and CheckMinGoalies (95G), ClearFreeAgentStats, ReleaseGfx, PStatsPalette2.

- logic96: the asstab entries $1-$6 (assdefo, assdefd, asswingd, asswingo, asscenterd, asscentero) by the 94 numbering and
  role, not by bytes: 96 opens each with a tmap test (players on the ice) that switches to a short-handed variant, so the
  bodies no longer match 94 / 95 by masked bytes. The pairs they switch between (1-2, 3-4, 5-6), aioff / aidef and the
  helpers they call agree with 94. The variants are new: ass...5 (one man short, tmap 5) and ass...4 (two short); asswingo4
  and asswingd4 are a lone rts. DoubleMinorPenalties (the 4 minute Roughing and Cross Check).
- logic96_vec: skateto (94G, the whole $C0 bytes; 95G from +8), FacePuck, GetHot2a / 2b / 2c (HotList2 hot spots).
- collide96: the label holdcheck was on 94G Bcheck (same body line for line, CCStart's SPA216A / SPA052C entry): now
  Bcheck, and the real holdcheck (the hold / hook entry) takes the name. checkcheck (95G), checkinglist (95G),
  CheckPenalties, puckgoalie (94G, 32 words). Folds: checkcx's exits are .exit / .exit4 (95G locals) with the new
  .droppuck between; FallDown's table and tail are .23, .24, .25, .hitter (95G locals; the hitter's own .0-.7 are .h0-.h7).
  FallDown's comment said a3 falls: a2 falls and a3 is the hitter.

- Engine leftovers. Parent names by body: AddFramer, InitScores, PeriodOver, updatefaceoff, ExitStatsScreen,
  SetSflags8Bit1 (94G); reenergizeteam, Findhittype, padteams, shotsets, onetimershot, ClrHor (95G / 94G). Call-slot
  names for empty rts stubs where every caller is a 94 / 95 call site of that routine: printscores1, ScoutingReport.
  dostop: 95G dostop's body and callers are the routine that was loc_1AD6C; the old dostop label was its inner non-pad
  branch (.cpu now), with .stop / .glide. Folds: getlchoice2 .tab, ReplayMode .top, doplayeracc .ftab,
  ProcessPenaltyList .next / .5 / .coinpen, updatepwrplay .clrpwrplay, SetScore .3, JumpToShowClock .digit / .digits
  (all 95G / 94G locals). loc_10000 was not a label: setpassmode's `cmp.l #$10000,d0` is a constant (95G writes it so);
  the label and its unused `.0` are gone, and locret_10054 is sub_FFD0's .exit.
- New names from the code: JumpToDoplayeracc, SetFightingMajors, ClearTeamRoles / CheckRoles / CheckTeamRoles (the role
  byte $65), VBlank_Menus (95G VBlank_SetOptions shape; that name is taken in 96), ArmIcing, BigControlCodeJumpTable,
  DoubleMinorChk, ErasePenaltyMessage, Erase/DrawPowerPlayBox, SetGoalieFromLines, OpeningClear, TurnGoalieFromNet,
  ChecksumSkipStart / End. PauseScreenDraw takes the 95G name by role and caller (body rewritten).

- RAM (ram96): 99 of the 145 IDA names closed. 95G / 94G names where the same routine uses the variable at the same point
  (rinkvrcset, spritechars, ReplayIconChars, clockram, shotpflags, RefRamMap, the stats screen block DispAttribCtr /
  VertLineScrolling / PlayerScrollCtr / screentimer, homeplayers / awayplayers, the shootout variables, NameEntryMode,
  namelogarrows, sopathdir, the 94 crowd meter CwdChkCntr / CwdChkCnt / CrowdRecord / CrowdAvg / CrowdPeak, PuckZCntr /
  TmpPuckZ, SeasonDay with SeasonFlags = SeasonDay+2). New-in-96 variables named from their one job (the pstats... clone
  of the stats screen block, team select and award logo chars, the font char bases, options animation, skill speed,
  NextScreenPtr, simdays, fightidletimer, IntermissionTimer, ...). Labels that were only an offset into a named variable
  are written as that expression (padcont+4, tmstruct+tmap, potree+$1C, LineSetsBuf+$43, SeasonDay+8, ...) and dropped.
  LineSetsBuf is GetTeamLines' buffer (shares ThreeStars). fight96 now writes CwdExciteLvl (93G) where it had the
  setup screen alias of that address; lines96_bar writes #ScoreSum-6 (95G ChkCnt).

- Graphics (graphics96, scout96): 91 of the 95 unk_ pictures named; the extractor, incbin paths and extracted files follow
  the names. HiScoreBgMap and HiScoreImg are the 95G pictures (tiles, palette and map identical). The rest are new art,
  named by the screen whose routine draws them; each screen's 19x3 title banner was rendered and read (LEAGUE OPTIONS,
  NHL STANDINGS, GAME OPTIONS, LEAGUE / PLAYOFF LEADERS, SEASON / PLAYOFF / PLAYER STATS, SELECT TEAM, TRANSACTIONS, TRADE
  PLAYERS, CREATE PLAYER, SIGN / RELEASE PLAYERS, MAIN MENU, EDIT LINES, TEAM ROSTER, SCORING, PENALTIES, PERIOD STATS,
  GAME STATS, SHOOTOUT SETUP, RECORD HOLDERS, USER ENTRY, NHL AWARDS). The ...Sprites files are SetSframe frame lists with
  their tiles at +8. Where 95G has a picture with the same role, its name is used (TitleScreenImg, PauseBgBitmap,
  AwardsBgMap, TradeBgMap, CreateBgMap, NameEntryBgMap, PlayerStatsBgMap, PlayerStatsTitleMap, PeriodStatsMap,
  LineEditorBgMap). revframetbl is not a picture: RevReplayAdj's frame table (95G role).

- Found inside dc.b blocks, not labelled yet (a label there needs the dc.b line split at the address; no byte moves):
  avdgoal $1A110 and skatetopuck $1A24A (94G / 95G bodies match) in skateto's bytes, with a new skatetopuck entry at
  $1A210; 94G ReloadRinkGraphics at $154D8 (ExitStatsScreen + 4; ClrHor and ReplayMode call it); TagTradePositions
  $1DD19E (ExecuteTrade); PrintCreateName $1DEB4C and DrawRatings $1DECCE (ModifyRatings); BuildPlayerLeaders' exit
  after its jmp (a0); the jmp assreplace stub at $C608 and jmp donothing at $CAE4 (the assignment code's long branches);
  the screen setup code of NHL Standings (in CanBlock's bytes), Game Options (SortStandings), the leaders (after
  BlankStatsRow), the scoring summary (GoalTypeTbl), Game Stats (TeamStatTextTblNoPen), Record Holders
  (ReadTeamRecords) and League Options (after SetMenuScroll); the menu handlers after VBlank_Menus' rte.
  InitializeGameStructures' first instructions sit 6 bytes before its label, inside NOPJoyTbl's bytes (no callers).
- Possible original bugs, kept as they are: maketree's first .bypoints call sorts seed numbers as team numbers (the call
  after the loop orders the finalists correctly); SimTeamStrength reads its save RAM roster flag a goalie-count off;
  RandomInjuryGames reads the high byte of the SeasonDay word.

## Unsure

Copied from `docs/align95_plan.md`. Leave these alone.

- SetSframe versus 95G AddSpriteFrame. 95G also has SetSframe. The 96 comment matches SetSframe. Left alone.
- Which season96 routine is which season screen. No 95 byte match. Name one only when its body makes the screen obvious. Do not invent a screen name.
- 145 IDA RAM names (`word_FF` / `byte_FF` / `unk_FF`). Rename one only when a converted use matches a 95G RAM name by what the code does. Do not rename from the address alone.
- 95G `print` versus 96G `print` / `printcur`. Already decided (clash). Do not revisit.
- Dotted 95G locals (`sortValuesUp`, `createListMove`, `rtsCreate2`). Not copied.
- ClockDigitChar at $020892 is the 95 routine (offset $64, smallfontchars), named in display96. The big-font copy in middle96_clock is BigClockDigitChar.

Labels the masked search found inside bytes that are still unnamed. Do not invent one on a drive-by. The file that holds the address is in `docs/align95_plan.md`.

- $02032C rtss2 (display96; 96 already uses rtss2 for the shared rts in collide96)

Named from the matching 95 body: chkpk, UpdatePenaltyShotEnd, PenShotTable, a2touchpuck, SetScroll2, ClockDigitChar, DoDMAList, DumpSprites2, rtsShowCrowd, ButtonLabelCharTable, Goal (collide96), GoalTypeTbl (summary96), setteams, InitCreateRecord, getplayernameD7, getnamea0, InitializeGameStructures, GetRandomUnusedTeam. VBlank_SpriteFade is the summary96 vbint. setup96_menu already owns VBlank_SetOptions. rtsBigClock is the shared return of the big-font clock.

SegaInit locals exist in `src/sega/SegaInit.asm` and in `docs/name_map.csv`. Do not invent a second copy.

Unsure from the naming pass (Oct 2026). Each stays an IDA name until the evidence below is found.
- sub_11582 (season96): called last by ClearPlayoffSave (Reset Rosters). Clears the player stat totals, the injuries,
  the free agent stat words (the block ClearFreeAgentStats clears) and one more save RAM block ($DDD, 9 bytes) whose use
  is not known yet; name it once that block is identified.
- For Abdul: BlankMenuBox (summary96) has the callers and job of 95G ClearMenuBox (TimeoutMenu, SelectGoalieMenu), but
  95 calls eraser and 96 prints blank big-font rows, so it was named from the job. Rename to ClearMenuBox if role is enough.
- For Abdul: CupChampionsScreen (awards96_show) has the job of 95G StanleyCupScreen with a different body; same question.
- sub_1E0D86 (create96): clears the $41-byte save RAM block at 0 or $C39 that belongs to team d7, called where 95 called
  CheckSavedLines (ExecuteTrade, SignFreeAgents, ReleasePlayers). $41 is 95's saved line set size, but no reader of the
  blocks was found. Candidate ClearSavedLinesD7 once a reader confirms it.
- For Abdul: names kept from 95G by role and interface where the body is new: SimTeamGoals, SimScorers, SimShots
  (season sim), ClearSeasonData (season96). Swap for new names if role is not enough.
- For Abdul: the asstab entries $1-$6 are named by role and the 94 numbering, not a byte match (see the logic96 bullet).
- sub_AFDA (input96): start + dpad sets SPA288C, pflags2 bit 1 and Xvel + $64. What SPA288C is, is not known.
- loc_C068 (fight96): a fighter engages (SPA3128); the second one turns the roughing calls into fighting majors.
  Reached from assfight and fightinput, so it stays global; the meaning of SPA3128 is not proven.
- sub_FD14, sub_FD80, sub_FFD0 (input96_shot): once a second they rework the role byte $65 of each team around its last
  puck carrier by puck zone. The role scheme is not understood well enough to name them.
- nullsub_2 (teamgfx96): an rts called once, at game over after EncodePW; 94 / 95 have no call there.
- sub_14804 (hockey96): clears save RAM $E68-$ECD in StartGame (OptPlayMode above 1); what lives there is not known.
- sub_1D920A (code96_15): called before setpassmode / SetShotMode and has no effect (the movem undoes the load).
- For Abdul: PauseScreenDraw (pause96_return) has 95G's caller and job but a rewritten body.
- RAM: 46 IDA names stay. No uses at all (unk_FFB65E, unk_FFB6DE, byte_FFB7BC, unk_FFC058, unk_FFCFB4, dword_FFD234, the
  unused tmstruct / AwShots offsets word_FFC73C, word_FFC74C, byte_FFC756, word_FFCADA, word_FFCAEA, byte_FFCAF4,
  unk_FFFFF6, unk_FFFFFF). Two jobs at one address (word_FF2720, word_FFB8C4, word_FFD238). The rest have uses in code
  whose job is not known yet (the fight counters word_FFDCDE ... byte_FFDCEC, the role carriers word_FFD23A / C, the pad
  objects unk_FFBE72 / unk_FFBE8E, word_FFD036 / word_FFD038 in the stats block, byte_FFC35A, unk_FFC38C, word_FFBF88,
  word_FFBFF0, word_FFD300, word_FFD310, byte_FFD474 / byte_FFD47E (94 arenaanim / faceoffanim by the dead 94 code only),
  byte_FFDCA6, byte_FFDCF9, dword_FFDD82, word_FFDDB6, word_FFDDBE, byte_FF2710, word_FF1388). unk_FFC4C6 is ScoreSum-6 but has no uses left.
- Graphics: unk_1417B6 (a frame offset table used only by the dead arena animation), unk_17C2AE (a palette; what it
  colours is not shown), unk_1CCEE8 and unk_1D5420 (CupCelebration's sprites and banner; not identified by content).
- For Abdul: names that the pictures now contradict. OptionsScreen's banner reads MAIN MENU (the GAME OPTIONS screen is
  other code); PlayoffMenuScreen / PlayoffMenuSetup draw TRANSACTIONS and run RosterMenuList; ControllerBgMap is also the
  background of the select team, main menu and transactions screens. Left as they are (not IDA names).
