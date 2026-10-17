# NHL 96 segment agent

This file is the queue. Do not rewrite it as a whole file. Edit it in place.

## Current rules (Oct 2026; these override older notes below)

Naming lineage is 92G -> 93G -> 94G -> 95G -> 96G.
- A routine, variable or table that matches its parent takes the parent's name. 92G is the naming root. A 96 routine that matches 95G takes the 95G name.
- Clash rule: if one name would mean two different things, the earliest game's meaning keeps the name and the later one gets a new name.
- Fix the earliest repo first, then propagate the change down the lineage (92 -> 93 -> 94 -> 95 -> 96).
- Team names: 93 uses the city names of its own data; 94, 95 and 96 use NYIslanders / NYRangers (short NYI / NYR).

Source style:
- No rename-history, provenance or origin-tag comments ("was X", "from 95G", "renamed", `IDA: loc_...`). That history lives in `docs/name_map.csv` only.
- No hardcoded ROM addresses in comments, and no hand-kept derived counts (sizes, numbers of entries, totals) that the code or the assembler can compute. The include comments in `src/nhl96.asm` (the ROM map) are the one place for addresses.
- Mark "New in 96:" only for major features (new modes, screens, systems), not for every changed routine.
- First-pass naming: a label with no 95G (or 94G / 93G / 92G) match is named from what the code clearly does when that is obvious; never guess a name.
- Local labels in 92 style: `.loop`, `.next`, `.done`, `.exit`, and plain numbers (`.0`, `.1`) for trivial jumps. A routine that matches 95G keeps its 95G locals.
- File headers are short plain-English stories of what the file does, modelled on the 95G file headers (`src/main95.asm`, `src/hockey95.asm`).

Layout: folders match 95G (https://github.com/abdulahmad/NHL95Genesis): `engine/`, `front/`, `sega/`, `stubinc/`, `macros/`, and ROM-wide files in `src/`. `src/nhl96.asm` is a flat include list in 96 ROM order. There is no `engine96.asm` or `front96.asm` (96 interleaves engine and front-end, so those runs are not one include). A second piece of a 95 file gets a suffix on the 95 name (`logic96_puck`). A guest of a few routines stays in the host. Two adjacent runs of the same subsystem are one file. Bytes cannot move into an earlier file. VBlank and the crowd stay in `display96` (95 keeps VBlank in video). Crowd frames are `display96_crowd`. Big-print stays in `penalty96`. Exceptions are `crash96`. `code96_14` and `code96_15` stay numbered: each head mixes several subsystems. Segment build stubs go in `src/stubinc`, tools in `tools/`. `tools/prebuild.js` checks the ROM (path, file name, SHA-1, size) and runs `tools/extractAssets96.js`. `tools/extractSegments96.js` is not part of the build.

Work in small steps: every change is built and checked byte for byte against the reference ROM, then committed and pushed to main (no force push; outside contributors push to their fork and open a PR, see START_HERE.md). Keep `docs/HANDOFF.md` current after each push.

## Current segment

None: every row of the ROM map is matched. Remaining work is the finish plan in `docs/align95_plan.md`. <- CURRENT

## Sources

- Listing: `lst/nhl96.bin.lst`, an IDA LST in ASM68K / MRI mode. It has no address column; a `loc_`, `sub_`, `unk_`, `byte_`, `word_`, `off_` name is the address. Do not disassemble `lst/nhl96.bin` and do not write a disassembler.
- Reference ROM: `lst/nhl96.bin` (2 MB, SHA-1 `7204633fbb9966ac637e7966d02ba15c5acdee6b`). Bytes and branch displacements come from it.
- Converted source incbins assets from `Extracted/NHL96/`, written by `tools/extractAssets96.js` (run by the prebuild check). `tools/extractSegments96.js` is not the build path. `tools/segmap96.json` is the ROM map (`find95.py` and these docs use it): decimal inclusive start and end, tiled, indent 1.
- Names: 95G `docs/name_map.csv` (address, name, IDA name, old name, module) and the 95G source. 96 reordered the code a lot against 95, so match by body, never by address. `python3 tools/find95.py <segment>` (or `<start>-<end>` in hex; options `--len`, `--min-distinct`, `--refresh`) lists the 95G labels whose first bytes are found in the range, with the 96 address, the 95G name and file. It downloads the 95G ROM and name map from GitHub into `output/ref95/` once. A hit is a hint; compare the bodies. Routines whose bytes changed (moved data, other RAM addresses) are not found by it.

## Segment files and stubs

- A segment file has no `org`. Its stub `src/stubinc/<name>_stub.asm` carries the `org`, includes `stubinc\ports.inc`, `stubinc\equals.inc`, `ram96.asm`, `externs96.asm`, then outside equates, then the segment file. Paths are relative to `src/`. Add `include macros\genesis.mac` (copy it from 95G) when the segment uses a macro.
- `src/externs96.asm`: included by `nhl96.asm` and every stub. It holds no equates; every segment is source. A duplicate symbol means an equate names a label the file already defines.
- A label another converted segment defines: an equate in your stub only (the full build has the label itself).
- `src/ram96.asm`: the RAM map, IDA names to start. Rename a variable to its 95G name when you first convert code that uses it (update every use; record it in `docs/name_map.csv`). Define each name once.

## Rules (SNASM68k, from 95G)

- Write real `cmp`, `cmpi`, and `exg`. `tools/fixopcodes.js` rewrites `cmp #imm` from SNASM's `CMPI` to EA's `CMP` opcode using the listing; a real `cmpi.l #imm,d0` stays `0C80`. Do not write a compare as `dc.w`.
- `jsr name` only when SNASM emits the same opcode. `jsr (name).l` is `4EB9`, `jsr (name).w` is `4EB8`; `bsr.w` stays `bsr.w`. IDA writes `jsr (ValidationRoutine).l`: keep the `.l`.
- A global label ends local-label scope. A local that another routine branches to stays global. SNASM symbols are case-insensitive.
- Keep each comment line under 200 characters. A longer line makes SNASM write an empty bin.
- A MATCH of 0 bytes is a failure; the byte count must be the segment's range.
- Old output can look like a pass: the scripts delete the old bin first. Only a check made this session counts.
- Data goes in the segment of the code that owns it. Graphics and sound are incbins, one file per label, named for the asset. A map is `Extracted/NHL96/Graphics/<Label>.map.jim`; the tiles are `Label+8`, not a second file. `.bin` (not `.map.jim`): Sprites, Spritetiles, SpritePalette, frameSprData, HotList, HotList2, RevRinkTilelist, RosterFont. Do not put a `dc.b` dump back.
- Team palettes are `Extracted/NHL96/Graphics/Pals/*h96.pal` and are also listed under `assets` in `tools/segmap96.json` (path, start, end, inclusive). The extractor's own table also has the graphics, `NHL96/Sound/z80_snd_drv96.bin`, the 168 bank items `NHL96/Sound/Bank/snd96_{patch|sample|song|list}_{id}.bin`, and `NHL96/Text/ScoutTextScript.bin`. Source incbins `..\Extracted\...` (paths are relative to `src/`, the assembler cwd). The marker `Extracted/.extract-complete.json` is written last (`rom`, `romSha1`, `extractor`, `extractorSha1`, `files`). It does not record a map SHA-1. A changed extractor, or a missing or resized file, extracts again.

## ROM map

Every row is matched. Rows are in ROM order and tile `$000000` up to the `$FF` fill, which `src/nhl96.asm` writes with `dcb.b`. The first split came from `python3 tools/make_segmap96.py` (see its header for the options): it cuts the listing at code / data changes and at `sub_` labels about every 8 KB of code (128 KB of data). The kind is a guess from the listing, and the 95G column lists the 95G files whose routines were found at the start of their bytes in the range (a hint, not a match). Ranges are confirmed from the listing as each segment is converted.

| File | Status | Start | End | Kind | 95G hint | Main names |
|---|---|---|---|---|---|---|
| main96 | matched, 1910 bytes | $000000 | $000775 | code | main95 | Vectors, header (sega\SegaIDTable96), SegaInit (as 95G), CHECK_VDP: the region lock reads CountryCode as a hex digit of region bits (RegionJapanNtsc ... RegionOverseasPal, PrintDeveloped ... PrintAnd, RegionPrint, RegionFont), RegionOK (ValidationRoutine, then jmp Begin), ZeroLong |
| teamdata96 | matched, 20346 bytes | $000776 | $0056EF | data | teamdata95 | VBjsr, TeamList (the ASE / ASW slots point to Boston / Montreal), the team blocks Anaheim ... Winnipeg (Player / String macros, palettes as incbin assets, .pos position nibbles), playoffseats |
| credits96 | matched, 2214 bytes | $0056F0 | $005F95 | data | credits95 | Credits (copyright lines, String -1), CreditsList (legal pages and credits, each page ended by an empty String) |
| frames96 | matched, 14162 bytes | $005F96 | $0096E7 | data | frames95 | SPAlist and the sprite animation tables, named SPAxxxx by their SPA value until the code that uses them is converted |
| srambits96 | matched, 738 bytes | $0096E8 | $0099C9 | code | - | WriteSRAMBits, ReadSRAMBits (new: bit fields in the save RAM), then bytes the listing does not decode |
| faceoff96 | matched, 2834 bytes | $0099CA | $00A4DB | code | faceoff95 | faceoffinput, the faceoff routines assfaceoff ... puckfaceoff2 and Endfaceoff (bytes: not decoded in the listing), DrawFaceoffWindow, limitfo |
| input96 | matched, 2930 bytes | $00A4DC | $00B04D | code | input95 | updatepadinput, doinput (doinput_goaliedive, doinput_cbut, ClampTargetY, doinput_chkanim, doinput_skater, doinput_ispc, doinput_islocked), PadOnTeam |
| goal96 | matched, 1402 bytes | $00B04E | $00B5C7 | code | goal95 | SetContTeams, DrawPadSetup, DrawPadIcon, ControllerSetupScreen, PrintSetupStr(Hi), ReadAllPads |
| fourway96 | matched, 216 bytes | $00B5C8 | $00B69F | code | fourway95 | Detect4WayPlay, ReadJoySwapPad1-4 |
| fight96 | matched, 3752 bytes | $00B6A0 | $00C547 | code | - | new in 96: checkfight, startfight, SetInst, fightinput, ClearMessageLine; assfight and assfwatch as bytes |
| logic96 | matched, 9960 bytes | $00C548 | $00EC2F | code | logic95, penalty95 | asstab, the assignment routines (bytes, labelled at their asstab entries), Penaltylist, PenShotPenalties, DoubleMinorPenalties |
| lines96 | matched, 720 bytes | $00EC30 | $00EEFF | code | lines95 | SetLCmode, SetLCmode2, setlccords, getlchoice, lineinput, lcfound, lcfound2 |
| lines96_set | matched, 1140 bytes | $00EF00 | $00F373 | code | lines95 | NullSaveClear, GetTeamLines (the team data lines, or lines built from the ratings: BuildPosList, AddLineSkaters, AddLinePlayer) |
| input96_shot | matched, 3404 bytes | $00F374 | $0100BF | code | input95 | shotdiradj, shotdirmath, SetShotMode, ShotMode, doshot, setpassmode, passmode, dopass, passtoa0 |
| trade96 | matched, 2138 bytes | $0100C0 | $010919 | code | trade95 | DefaultRosters, FormatPlayerNameD7, GetRosterName, GetJerseyNumber |
| season96_sim | matched, 920 bytes | $01091A | $010CB1 | code | season95 | SimGameStats, SimGoalieStats, SimGoalie, PickSimGoalie |
| season96 | matched, 8012 bytes | $010CB2 | $012BFD | code | - | SaveGameStats, TickTeamInjuries, SimSeasonDays, WriteDayGames, Read/WriteSeasonHeader, ReadStandings, TeamSelectScreen, RunSeasonMenu, SeasonMenuScreen, DrawSetupTeamBlock |
| teamgfx96 | matched, 2394 bytes | $012BFE | $013557 | data | - | TeamBlockPtrs, TeamLogoPtrs, SmallLogoPtrs, VBlank_Menus (bytes), nullsub_2 |
| schedule96 | matched, 2376 bytes | $013558 | $013E9F | data | schedule95 | SeasonSchedule (Day) |
| awards96 | matched, 1374 bytes | $013EA0 | $0143FD | code | awards95 | ScoutingReport, ResolveDayGames, BeginPlayoffs, InitPlayoffs, SeedPairings, SortSeeds, CalcSeedPoints, SetupPlayoffs, GetTeamPOSlot, BuildPOSlots |
| pause96_list | matched, 590 bytes | $0143FE | $01464B | code | pause95 | PrintMenuList, ScrollClearTxt, PrintMenuList2 |
| hockey96 | matched, 1660 bytes | $01464C | $014CC7 | code | hockey95 | Begin, StartGame, StartPer, Gameloop, DoGameFrame, DoFrameUpdates, ResetClock, restoreteams, RestoreBenchEnergy, updatecrowdf, clockcont |
| pause96 | matched, 1330 bytes | $014CC8 | $0151F9 | code | pause95 | demoread, EndDemoOnPress, startpause1-4, Pausemode, SetupPauseScreen, seta2, InitMenuState, HandleMenuInput, UpdateMenuSelection, PrintMenuItem, vcountwait |
| setup96 | matched, 662 bytes | $0151FA | $01548F | code | setup95 | GetNameandAttrib, attribjmp, AttribStatus, AttribEnergy, AttribHanded, AttribWeight, AttribFighting, AttribRating |
| pause96_menu | matched, 740 bytes | $015490 | $015773 | code | pause95 | PlayoffStatsMenu, TimeoutMenu, SelectGoalieMenu |
| players96_count | matched, 168 bytes | $015774 | $01581B | code | players95, middle95, video95 | GetGoalieCount(D7), GetPlayerCount(D7), WaitVSyncAndReadInput |
| replay96 | matched, 2772 bytes | $01581C | $0162EF | code | replay95, video95 | ReplayMode, ReadMenuJoy, ShowReplayIcon, EraseReplayIcon, ShowReplayBanner, EraseReplayBanner, suba4, UpdateCameraPos, RevReplayAdj, ClampReplayView, updatereplay, rtss8 |
| control96 | matched, 2750 bytes | $0162F0 | $016DAD | code | hockey95, display95, goal95, skate95, control95, collide95 | updateplayers, updateanim, LockScroll, checkwindow, FindGoalie, burst, holdplayer, chgplayer, setcplayer, setc1-4player, Sweepcheck, restorepl, setpads |
| logic96_ass | matched, 3672 bytes | $016DAE | $017C05 | code | logic95 | check4bench, donothing and the asstab entries (assbench, asseben, asspenalty, assdopen, assepen, assgoaliebreakwait, assstanley, assscore, assgoaliectrl, assgoaliecpu) |
| logic96_puck | matched, 5138 bytes | $017C06 | $019017 | code | logic95, penalty95 | AdjustFacingDirection, goaliesave, saveanim, assgoalietopuck, breakaway, chkpuckc, asspuckc, chkpk2, EvadePC, checkob, assbreakaway, assnearest, check4check, asspassrec, assshoot |
| shootout96 | matched, 1898 bytes | $019018 | $019781 | code | shootout95 | puckshootout, SelectPenaltyShotSkater, puckpenshot, EndPenaltyShotPlay |
| logic96_pull | matched, 1980 bytes | $019782 | $019F3D | code | logic95, lines95, penalty95 | ChkGoalies, ReturnGoalies, CPgoalie, CompLine, AssignPads, pucknorm, ChkOffsides, a2offsides, puckIChk, puckunflip |
| logic96_vec | matched, 1750 bytes | $019F3E | $01A613 | code | logic95 | puckflip, puckshadow, findpc, assexit, assinsert, assreplace, vtoa, GetHot and the GetHot variants |
| skate96 | matched, 2284 bytes | $01A614 | $01AEFF | code | skate95 | SetSPA, doplayeracc, goalieacc, noturn(0), playeracc, MaxSpeed, dostop, stopna2, dirtab(2), WeightedRandomSelect |
| video96 | matched, 4244 bytes | $01AF00 | $01BF93 | code | video95 | remap, forceblack, forcefade, cramfade, CopyPaletteToCRAM, randomd0(s), sroot, waitx, orjoy, nodiag, ReadJoy1-4, ReadJoy, DoDMA, DoFill, setVram, Vmaddr, dobitmap, DecompressGraphics, DecompressBytecode and its opcodes, xyVmMap, eraser, Framer, printsmall(z), print(z), printcur(z), PushTime, PushNumber(Width), appstring, printbig(z), printbigtext |
| penalty96 | matched, 4538 bytes | $01BF94 | $01D14D | code | penalty95, middle95 | PrintBigChar, PutBigTile, printbig1/2, AddPenalty, PenaltyManager, chkprogress, PenShotChk, InProgress, Stop4Pen, UpdatePA, prefmes, updatepentime, releasepl, updatepwrplay, EASNLogo |
| lines96_bar | matched, 640 bytes | $01D14E | $01D3CD | code | lines95 | linebar, getlinee, AvgCline, ChkShotStat, SetupTeamForIntermission, SetupTeamLine, RestoreTeamEnergy |
| hockey96_inter | matched, 1072 bytes | $01D3CE | $01D7FD | code | faceoff95, middle95 | Intermission, UpdateScores, SetScore, sctab, PrintBigListItem, PrintSmallListItem, SkipStrings |
| collide96 | matched, 9044 bytes | $01D7FE | $01FB51 | code | collide95 | checkcoll, checkplcoll, checkcx, checkint, CCStart, checkagr, holdcheck, FallDown, setInjuryType, checkwallcoll, checkgoal, wallcoll, setd0player, puckbody, rtss2, makepde, getpde, setpde |
| players96 | matched, 1674 bytes | $01FB52 | $0201DB | code | players95 | setpersonel, SetPlList, TryAddPlayerToList, SetupPenaltyShot, ResetBench, setplayer, ClampNibble |
| display96 | matched, 4774 bytes | $0201DC | $021481 | code | display95, video95 | VBlank, vb2, IRQ7, DumpSprites, DumpSprites2, DoDMAList, setvideo, updatescroll, showref, checkfo, showcrowd, checksso, setsortcords, addframe, find3d, KillCrowd, setupice, defaultsprites, SprSort, resetplstuff |
| control96_team | matched, 346 bytes | $021482 | $0215DB | code | control95 | clearTeamStats, InitTeamStructure, SetOriginalLines, setplayercolors |
| hockey96_open | matched, 1398 bytes | $0215DC | $021B51 | code | hockey95 | IntermissionStart, ExitToOpening, Opening, Opening2, AbortGame, EASportsScreen, UpdatePlayoffLevel |
| setup96_menu | matched, 94 bytes | $021B52 | $021BAF | code | setup95 | VBlank_SetOptions, DefaultMenus, defmenuoptions |
| playoff96 | matched, 3184 bytes | $021BB0 | $02281F | code | playoff95, setup95 | ContinuePlayoffs, NewPO, maketree, SetTreeGameTeams, FigureJoy, ReadPassBits, EncodePW, ResolveGames |
| goal96_box | matched, 1616 bytes | $022820 | $022E6F | code | goal95, stats95, injury95, shootout95 | ShowThreeStars, ShowInjuryBox, PenaltyShotBox, ShowGoalBox, box |
| middle96 | matched, 724 bytes | $022E70 | $023143 | code | middle95 | GetPlayerName, getname, FormatPlayerName, FormatPlayerInitial, FinalizeTextBuffer |
| crash96 | matched, 260 bytes | $023144 | $023247 | code | main95 | AdrErr, InvOpCode, DivBy0, crash |
| display96_crowd | matched, 128 bytes | $023248 | $0232C7 | data | crowd95 | CrowdFrameTbl |
| middle96_ascii | matched, 122 bytes | $0232C8 | $023341 | data | middle95 | bfasciicon |
| lines96_list | matched, 46 bytes | $023342 | $02336F | data | lines95 | linelist |
| setup96_pos | matched, 20 bytes | $023370 | $023383 | data | setup95 | PlayerPositionText |
| middle96_per | matched, 40 bytes | $023384 | $0233AB | data | middle95 | PerLabels, PerLabels2 |
| video96_size | matched, 16 bytes | $0233AC | $0233BB | data | video95 | sizetab |
| players96_sub | matched, 114 bytes | $0233BC | $02342D | data | players95 | sublist, priolist |
| setup96_attr | matched, 642 bytes | $02342E | $0236AF | data | setup95 | PAttribColumns, PAttribOverall(Mask), PAttribAggressMask, GAttribColumns, GAttribOverall(Mask) |
| pause96_items | matched, 1956 bytes | $0236B0 | $023E53 | data | pause95 | ShootoutPauseMenu, PauseMenu, PauseMenuNoTimeout, ShootoutIntermissionMenu, PregameMenu, PlayoffPregameMenu, IntermissionMenu, GameOverMenu, PlayoffGameOverMenu |
| lines96_menu | matched, 200 bytes | $023E54 | $023F1B | data | lines95 | LineMenu1, LineMenu2 |
| sram96 | matched, 778 bytes | $023F1C | $024225 | code | sram95 | InitSaveRAM, SRAMWaitVblank, VBcount, ValidateSRAM, ClearSRAM, WriteSRAM, MakeSRAMChecksum, ReadSRAM, ClearSRAMBytes |
| video96_pad | matched, 346 bytes | $024226 | $02437F | code | video95 | ReadJoyData, ReadPad4Way1-4, ReadPad1, ReadPad2, PadDirTable, ResetZ80Bus |
| logic96_do | matched, 32 bytes | $024380 | $02439F | code | logic95 | doassignment |
| video96_font | matched, 126 bytes | $0243A0 | $02441D | code | video95 | LoadSmallFont, LoadBigFonts, TurnGoalieFromNet |
| logic96_crease | matched, 96 bytes | $02441E | $02447D | code | logic95 | GoalieInCrease |
| pause96_play | matched, 8 bytes | $02447E | $024485 | code | pause95 | PlayGame |
| sound96 | matched, 410500 bytes | $024486 | $088809 | code | sound95, video95 | p_music_vblank, SndDriver, Z80Program, SoundBanks, the 168 bank items, SoundCmd, sfx, song, ChooseSong, newcheck |
| scout96 | matched, 27324 bytes | $08880A | $08F2C5 | data | scout95 | ScoutTextScript, TitleScreenImg |
| graphics96 | matched, 1340252 bytes | $08F2C6 | $1D6621 | data | graphics95 | one incbin per picture: the screen maps, Sprites, Spritetiles, the fonts, TeamBlock / TeamLogo / SmallLogo, the award pictures |
| logic96_timer | matched, 1348 bytes | $1D6622 | $1D6B65 | code | logic95, input95 | puckvzadj, OneTimerPass, OneTimerTarget, OneTimerNearTbl, OneTimerFarTbl, OneTimerGoalieTbl, assonetimer, setonetimeranim |
| code96_14 | matched, 5184 bytes | $1D6B66 | $1D7FA5 | code | middle95, scout95, collide95, records95, lines95 | PuckOnAttackHalf, InitCrowdMeter, UpdateCrowdMeter, stopfast, checkcornercoll, Create_HotCold_Table, AttributeCalc, Read/WriteTeamRecord, UpdateRecords, CountGoalies, CalcAttrib, the attribute weights |
| shootout96_path | matched, 3766 bytes | $1D7FA6 | $1D8E5B | code | shootout95 | ShootoutModeBox, ShootoutInit, CountShootoutGoals, InitShooters, ShootoutPaths 1-7, StartShootoutPath, SkatePath, UnpackPicture |
| code96_15 | matched, 3690 bytes | $1D8E5C | $1D9CC5 | code | middle95, goal95, injury95, penalty95, pause95 | LoadReplayIcon, LoadHomeTeamGfx, PrintPlayerAssists, HiScoreScreen, EndOneTimer, ClearPenalties, SetMenuPadSide |
| season96_stand | matched, 2554 bytes | $1D9CC6 | $1DA6BF | code | season95 | StandingsPoints, StandingsGroups, StandingsGroup0-4, SortStandings |
| season96_menu | matched, 6524 bytes | $1DA6C0 | $1DC03B | code | season95, playoff95 | SetSframe, LeadersScrollArrows, SortValuesUp, SeasonPlayoffStats, WaitAnyPad, PlayoffMenuScreen, ClearPlayoffSave |
| trade96_edit | matched, 6362 bytes | $1DC03C | $1DD915 | code | trade95 | RosterMenuList, YesNoMenuList, TradePlayers, CheckTrade, InvalidTradeText |
| create96 | matched, 13512 bytes | $1DD916 | $1E0DDD | code | create95 | CreatePlayer, the Field... / Edit... routines, ClearCreatedPlayers, SignFreeAgents, ReleasePlayers |
| options96 | matched, 3386 bytes | $1E0DDE | $1E1B17 | code | - | OptionsScreen, OptionsMenuList, SetGoalieModes, SetLineOption, SetPenOption, SetSkillLevel, OptionsAnimFrame |
| stats96 | matched, 2928 bytes | $1E1B18 | $1E2687 | code | stats95 | LineEditor, PrintAttribHeader, DrawLineIcons, SetLineSlot, LoadTeamLine, SaveTeamLine |
| pause96_return | matched, 2030 bytes | $1E2688 | $1E2E75 | code | pause95 | ReturnToGame, RestoreGameScreen, ClearOldFrames, PeriodText, PrintDigit |
| summary96 | matched, 10052 bytes | $1E2E76 | $1E55B9 | code | summary95, shootout95, records95 | TeamRosterScreen, ScoringSummaryScreen, PenaltySummaryScreen, PeriodStatsScreen, GameStatistics, ShootoutShooters, RecordHoldersScreen |
| stats96_list | matched, 3762 bytes | $1E55BA | $1E646B | code | stats95 | PlayerStatsScreen, PlayerStatsList, the PList... helpers, PListPrint, PListValue, PListMark |
| records96 | matched, 2974 bytes | $1E646C | $1E7009 | code | records95 | NameEntryScreen, CreateLetterGrid, UserNameEntry, PrintNameLogRecords |
| playoff96_tree | matched, 1626 bytes | $1E700A | $1E7663 | code | playoff95 | PlayoffScreen, HandlePlayoffInput, PrintSeriesScore, DrawTreeArrow |
| middle96_clock | matched, 1120 bytes | $1E7664 | $1E7AC3 | code | middle95 | showclock, showclockdma, BigClockDigitChar, ClockDigitChar2, ShowBigScore, ClearBigScore |
| awards96_show | matched, 3280 bytes | $1E7AC4 | $1E8793 | code | awards95 | SeasonAwards, DrawAwardPicture, AwardPictures, PrintAwardWinner, GetAwardWinner |
| injury96 | matched, 264 bytes | $1E8794 | $1E889B | code | injury95 | RandomInjuryGames, SetInjuryGames, SetSeasonInjuries, GetInjuryGames |
| title96 | matched, 1932 bytes | $1E889C | $1E9027 | code | - | the opening screens new in 96 (sub_ names) |
| checksum96 | matched, 170 bytes | $1E9028 | $1E90D1 | code | checksum95 | ChecksumLongs, ChecksumValue, ValidationRoutine |

## New in 96

Add a system here when the listing shows something 95 does not have.

- Fighting (`engine/fight96.asm`): back from 93 (checkfight, SetInst, fightinput, assfight, assfwatch, ClearMessageLine take the 93G names), with new fight moves (more SPAs) and a second round (word_FFDCDE).
- Save RAM bit fields (`src/srambits96.asm`): WriteSRAMBits and ReadSRAMBits pack a value into the save RAM. The later save-RAM block keeps the name sram96.
- Options screen (`front/options96.asm`), the season playoff menu (`front/season96_menu.asm`), and the opening screens (`front/title96.asm`).
