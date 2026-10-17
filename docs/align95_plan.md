# Align 96G with 95G

Audit only. No source bytes were moved in this commit. 95G was read on GitHub
(`SEGMENT_AGENT.md`, `PROMPT.md`, `docs/HANDOFF.md`, `src/nhl95.asm`, the include lists,
`docs/name_map.csv`, `tools/extractAssets95.js`). 95G has no `START_HERE.md`.

95G is one file per subsystem, in folders, included in ROM order. The 96 file
split and the asset extraction are done. `src/nhl96.asm` includes each file in
96 ROM order, and the folders match 95G. What is left is the symbols pass and
the Unsure list at the bottom of this file (also in `docs/HANDOFF.md`).
`code96_14` and `code96_15` stay numbered. Names already follow 95G where an
earlier pass matched the body.

Matching used three checks:

- 96 `docs/name_map.csv` joined to the 95G name map by name (case-insensitive).
  1902 labels: 928 already wear a 95G name, 260 are still `sub_` / `loc_` / `unk_` /
  `word_` / `byte_`, 714 are descriptive names 95G does not have (296 of those are RAM,
  107 are SPA tables named by their SPA value).
- Exact first-20-bytes search, the same test as `tools/find95.py`. 163 unique hits.
  Most 96 routines differ in the first bytes because RAM addresses moved, so a miss
  is not "different code".
- Masked words (a 16-bit word at or above `$A000` matches any such word), 12 words,
  one unique hit. That is how the earlier passes matched bodies. 62 extra hits;
  the ones that change a name are listed below.

95G keeps a routine that moved in from another 94 file inside the host file.
96G will do the same: a couple of guests stay in the host. A file is split only
when two subsystems each own a real contiguous run. A 95G module that the 96 ROM
splits into two places becomes two includes. The first and largest piece gets the
95G file name with 96 instead of 95. A later piece gets a short suffix
(`logic96_ai.asm`) because one file cannot be assembled twice. That suffix is a
ROM-order limit, recorded here, not a second naming scheme.

`src/nhl96.asm` stays the ROM-order include list. 95G's `engine95.asm` and
`front95.asm` exist because those runs are contiguous and branches cross the
files. 96G's engine and front-end code are interleaved across the whole ROM, so
there is no single engine list to include once. Folders still match: `engine/`,
`front/`, `sound/`, `sega/`, `stubinc/`, `macros/`.

## File map

| 96 file | Range | 95G modules in it (named labels) | Action |
|---|---|---|---|
| main96 | `$000000-$000775` | main95 | Keep `src/main96.asm`. Sega header and `SegaInit` already live in `src/sega/`. |
| teamdata96 | `$000776-$0056EF` | teamdata95 | Keep `src/teamdata96.asm`. Palettes are already incbins. |
| credits96 | `$0056F0-$005F95` | credits95 | Keep the name. 95G puts credits after graphics; 96G's ROM puts them here. Do not move the bytes. |
| frames96 | `$005F96-$0096E7` | frames95 | Keep `src/frames96.asm`. SPA tables that 95G names are already renamed; the rest stay `SPAxxxx` until a routine uses them. |
| code96_02 | `$0096E8-$00B85D` | faceoff95, input95, skate95 (inside doinput), goal95 (controller setup), fourway95, plus new SRAM bit routines and `checkfight` | Split, in ROM order, into the files in the work queue. |
| code96_03 | `$00B85E-$00EC6D` | fight (new), logic95 (`asstab`), penalty95, lines95 (`SetLCmode` only) | Split off `engine/fight96.asm`. `asstab` through the assignment bytes becomes `engine/logic96.asm`. Penalty texts stay with logic until `penalty96` exists, or move with the penalty run if the boundary is clean. `SetLCmode` is the start of the next file. |
| code96_04 | `$00EC6E-$010CB1` | lines95, input95 (shot and pass), trade95, season95 | Split into `engine/lines96.asm`, `engine/input96_shot.asm` (shot/pass; `input96.asm` is doinput), `front/trade96.asm`, `front/season96_sim.asm`. |
| code96_05 | `$010CB2-$012BFD` | new season / save screens (source is `sub_` names, almost none in the name map) | `front/season96.asm` once the bodies are read. Until then the file is renamed, not re-split. |
| data96_01 | `$012BFE-$015773` | awards95, setup95, hockey95, pause95, schedule95 (`SeasonSchedule`), crowd, injury | Split into `src/schedule96.asm` (the schedule table only), `front/awards96.asm` (seeding), `src/hockey96.asm` (Begin through the frame loop), `engine/pause96.asm`, `engine/setup96.asm` (attribute columns and the roster helpers). Pointer tables at the top stay with the first of these. |
| code96_06 | `$015774-$017C05` | replay95, control95, logic95 (more `asstab` entries), players95 | Split into `engine/replay96.asm`, `src/control96.asm`, and `engine/logic96_ass.asm` for the assignment entries. The two count helpers at the top stay with control (they are called from the replay / bench path). |
| code96_07 | `$017C06-$019F3D` | logic95, shootout95, penalty95, lines95 | The logic run joins the logic story as `engine/logic96_puck.asm`. Shootout and penalty runs become `front/shootout96.asm` and `engine/penalty96.asm` only where the run is more than a guest; a single routine stays in the host. |
| code96_08 | `$019F3E-$01BF93` | video95, middle95, skate95, logic95 (a few assignment tails) | Done. `engine/logic96_vec.asm` (puckflip through the GetHot variants), `engine/skate96.asm` (SetSPA through WeightedRandomSelect), `engine/video96.asm` (remap through printbigtext). Print stays with video. `middle96` is the name formatters in code96_12. |
| code96_09 | `$01BF94-$01E10F` | penalty95, middle95 (big print), lines95, collide95, faceoff95, shootout95 | Done with code96_10. `engine/penalty96.asm` (big-print included), `engine/lines96_bar.asm`, `src/hockey96_inter.asm`, and the start of `engine/collide96.asm`. |
| code96_10 | `$01E110-$0201C5` | collide95, players95, middle95 (energy) | Done. `collide96` runs through setpde. `engine/players96.asm` is setpersonel through setplayer, plus ClampNibble. |
| code96_11 | `$0201DC-$0221D3` | video95 (vblank), display95, crowd95, control95, hockey95, setup95 | Done with code96_12. `src/display96.asm` (VBlank stays here; 95 keeps it in video, and the crowd stays in this file), `src/control96_team.asm`, `src/hockey96_open.asm`, `engine/setup96_menu.asm`, and the start of `engine/playoff96.asm`. |
| code96_12 | `$0221D4-$023247` | setup95 (pass bits), stats95, goal95, middle95 (names), main95 (exceptions) | Done. `playoff96` runs through ResolveGames. `engine/goal96_box.asm` holds the stars, the injury, the penalty shot and the goal box. `engine/middle96.asm` is the name formatters. `src/crash96.asm` is AdrErr through crash. |
| data96_02 | `$023248-$04411F` | tables, sram95, video95 pads, sound95 driver, start of the bank | Done. Tables are second pieces at this address (`display96_crowd`, `middle96_ascii`, `lines96_list`, `setup96_pos`, `middle96_per`, `video96_size`, `players96_sub`, `setup96_attr`, `pause96_items`, `lines96_menu`). `src/sram96.asm`, `engine/video96_pad.asm`, `engine/logic96_do.asm`, `engine/video96_font.asm`, `engine/logic96_crease.asm`, `engine/pause96_play.asm`, `src/sound96.asm` (driver, Z80 program, bank directory). The bank bytes were incbinned into `sound96`. |
| data96_03 | `$044120-$07A409` | sound95 bank data | Done. Incbins inside `sound96`. |
| data96_04 | `$07A40A-$0887E3` | sound95 bank tail and the sound calls | Done. The tail of the bank is incbins. The calls are source in `sound96`. |
| code96_13 | `$0887E4-$08F2C5` | sound95 `newcheck`, scout95 text | Done. `newcheck` is the end of `sound96`. `front/scout96.asm` incbins `ScoutTextScript` and the picture after it. |
| data96_05 to data96_10 | `$08F2C6-$1D6621` | graphics95 | Done. `src/graphics96.asm`, one incbin per label. |
| data96_10 | `$1BDCDC-$1D6621` | graphics95 | Done. Its pictures are the tail of `graphics96`. `engine/logic96_timer.asm` is puckvzadj through setonetimeranim. |
| code96_14 | `$1D6B66-$1D7FA5` | middle95, scout95, records95, collide95 | Done. The head stays numbered: crowd meter, hot/cold, team records, attribute weights. `front/shootout96_path.asm` is ShootoutModeBox through UnpackPicture. |
| code96_15 | `$1D8E5C-$1D9CC5` | goal95, injury95, penalty95, pause95 | Done. The head stays numbered (replay icon, hi-score, penalty clear). `front/season96_stand.asm` is StandingsPoints through SortStandings. |
| code96_16 | `$1DA6C0-$1DC03B` | new in 96 (no 95G name) | Done. `front/season96_menu.asm` joins SetSframe and the leaders with the playoff menu. code96_16 is gone. |
| data96_11 | `$1DC03C-$1DD915` | trade95 | Done. `front/trade96_edit.asm` is the roster menu and TradePlayers. `front/create96.asm` starts at CreatePlayer. |
| code96_17 | `$1DD916-$1E1B17` | create95, then the options screen (new) | Done. `create96` runs through the created-player list. `front/options96.asm` is OptionsScreen through OptionsAnimFrame. |
| code96_18 | `$1E1A3C-$1E2E75` | stats95 line editor, pause95 return-to-game | Done. The option setters joined `options96`. `front/stats96.asm` is the line editor. `engine/pause96_return.asm` is ReturnToGame through PrintDigit. |
| data96_12 | `$1E2E76-$1E646B` | summary95, stats95, shootout95, records95 | Done. `front/summary96.asm` holds the pause pages, including the shootout shooters and the record holders. `front/stats96_list.asm` is PlayerStatsScreen through PListMark. |
| code96_19 | `$1E646C-$1E824B` | records95, playoff95, awards95, middle95 clock | Done. `front/records96.asm` is name entry. `engine/playoff96_tree.asm` is the tree screen. `engine/middle96_clock.asm` is the ice clock. `front/awards96_show.asm` starts at SeasonAwards. |
| code96_20 | `$1E7AC4-$1E90D1` | awards95, injury95, new opening screens, checksum95 | Done. `awards96_show` includes GetAwardWinner. `front/injury96.asm`, `front/title96.asm`, `src/checksum96.asm`. |

`src/ram96.asm`, `src/externs96.asm`, `src/stubinc/`, `src/macros/genesis.mac` stay where 95G puts them.

## Work queue (file split)

One module per commit. After each move: `tools/verify_all.sh` ends in `ALL MATCH`, then commit and push, then `docs/HANDOFF.md`. A split is a new file, its stub, its `seg:` script, the `nhl96.asm` include, the ROM map row, and the `module` column in `docs/name_map.csv`. Segment builds already branch to equates in other files (`bne.w faceoffinput` from input96), so a split on a label boundary is safe when every cross-edge is a branch to a global label or a `jsr` / `jmp`.

1. `engine/fight96.asm` — done. `checkfight` through `SetFightingMajors`.
2. `engine/fourway96.asm` — done. `Detect4WayPlay` through `ReadJoySwapPad4`.
3. `engine/goal96.asm` — done. `SetContTeams` through `ReadAllPads`.
4. `engine/input96.asm` — done. `updatepadinput` through `PadOnTeam` (doinput, including the goalie parts that 95G kept in skate95; they are inside doinput here). `PadOnTeam` follows `sub_AFDA` and `doinput` branches to it, so it stays in this file.
5. `engine/faceoff96.asm` — done. `faceoffinput` through `Endfaceoff`. What remains of code96_02 is `WriteSRAMBits` / `ReadSRAMBits` and the unreferenced bytes between them and the faceoff.
6. `src/srambits96.asm` — done. `WriteSRAMBits` / `ReadSRAMBits` and the unreferenced bytes that follow them. The 95G save-RAM block is later and is the file that gets the name `src/sram96.asm`.
7. `engine/logic96.asm` — done. `asstab` through `DoubleMinorPenalties`. The penalty texts sit at the end of that run and stay in the file until penalty96 is the next include. `SetLCmode` is what remains of code96_03.
8. `engine/lines96.asm` — done. `SetLCmode` through `lcfound2`. `lcfound` branches to `rtss`, which moved with the pass.
8b. `engine/input96_shot.asm` — done. `shotdiradj` through `CheckTeamRoles` (the helpers after `passtoa0`). `GetTeamLines`, the team line writer, stays in code96_04 with `NullSaveClear`.
8c. `front/trade96.asm` and `front/season96_sim.asm` — done. Roster names through the tables before `SimGameStats`, then the simulation. The sim reads `SimTeamDefense` from the roster file.
8d. `front/season96.asm` — done as a rename of code96_05, not a split. The routines stay `sub_` until the bodies are read.
8e. `src/schedule96.asm` — done. The `SeasonSchedule` table only. The team graphics pointers stay in data96_01. The rest of that file is `src/data96_01b.asm` until it splits into hockey, pause and setup.
8f. `front/awards96.asm` — done. `ScoutingReport` through `BuildPOSlots`. `ScoutingReport` is the rts in front of `ResolveDayGames`.
8g. `src/hockey96.asm` — done. `Begin` through `clockcont`. The menu list printers stay in data96_01b.
8h. `engine/pause96.asm` — done. `demoread` through `vcountwait`. It branches to `TimeoutMenu` and `SelectGoalieMenu`, which stay after the attribute columns.
8i. `engine/setup96.asm` — done. `GetNameandAttrib` through `WeightTbl`.
8j. `engine/pause96_menu.asm` — done. `PlayoffStatsMenu`, `TimeoutMenu` and `SelectGoalieMenu`. data96_01b still holds `PrintMenuList` and `PrintMenuList2`, which sit before `Begin`.
9a. `engine/replay96.asm` — done. `ReplayMode` through `rtss8` ($01581C-$0162EF). `ReadMenuJoy` sits in that run. The count helpers and `WaitVSyncAndReadInput` stay in code96_06, ahead of the replay. The rest of the old file is `src/code96_06b.asm`.
9b. `src/control96.asm` and `engine/logic96_ass.asm` — done. updateplayers through setpads, then check4bench through the assignment entries. code96_06b is gone. The count helpers stay in code96_06 because the replay sits between them and the pad switches.
9c. `engine/logic96_puck.asm` — done. AdjustFacingDirection through assshoot ($017C06-$019017). checkob stays in that run. The penalty shot and the shootout start the remainder, `src/code96_07b.asm`.
9d. `front/shootout96.asm` and `engine/logic96_pull.asm` — done. puckshootout through EndPenaltyShotPlay, then ChkGoalies through puckunflip. code96_07b is gone. CompLine, ChkOffsides and puckIChk stay in the goalie-pull file.
10. Renames of files that were already one subsystem: `engine/lines96_set.asm` (code96_04), `engine/players96_count.asm` (code96_06), `src/teamgfx96.asm` (data96_01), `engine/pause96_list.asm` (data96_01b).
11. code96_08 split — done. `engine/logic96_vec.asm` ($019F3E-$01A613), `engine/skate96.asm` ($01A614-$01AEFF), `engine/video96.asm` ($01AF00-$01BF93).
12. code96_09 and code96_10 split — done. `engine/penalty96.asm`, `engine/lines96_bar.asm`, `src/hockey96_inter.asm`, `engine/collide96.asm` (through setpde), `engine/players96.asm` (through ClampNibble). code96_11 now starts at VBlank.
13. code96_11 and code96_12 split — done. `src/display96.asm`, `src/control96_team.asm`, `src/hockey96_open.asm`, `engine/setup96_menu.asm`, `engine/playoff96.asm`, `engine/goal96_box.asm`, `engine/middle96.asm`, `src/crash96.asm`.
14. Front end — done. `front/shootout96_path.asm`, `front/season96_stand.asm`, `front/season96_menu.asm`, `front/trade96_edit.asm`, `front/create96.asm`, `front/options96.asm`, `front/stats96.asm`, `engine/pause96_return.asm`, `front/summary96.asm`, `front/stats96_list.asm`, `front/records96.asm`, `engine/playoff96_tree.asm`, `engine/middle96_clock.asm`, `front/awards96_show.asm`, `front/injury96.asm`, `front/title96.asm`, `src/checksum96.asm`. code96_14 and code96_15 keep the mixed heads. code96_16, data96_11, code96_17, code96_18, data96_12, code96_19 and code96_20 are gone.
15. data96_02 — done. The tables, `src/sram96.asm`, the pads, `logic96_do`, the font loaders, `logic96_crease`, `pause96_play` and `src/sound96.asm`. The bank dumps were replaced by incbins in the extraction step.
16. `engine/logic96_timer.asm` — done. puckvzadj through setonetimeranim. The pictures ahead of it are in `graphics96`.
17. Extraction — done. `tools/extractAssets96.js`. `sound96` incbins the Z80 program and the 168 bank items and keeps the calls plus `newcheck`. `front/scout96.asm` and `src/graphics96.asm` incbin the pictures and the scout text. The team palettes stay.
18. Renames and docs — done. FindGoalie, ShootoutInit, CreateLetterGrid. `START_HERE.md`, the rules prose in `SEGMENT_AGENT.md`, `PROMPT.md` and `docs/HANDOFF.md` follow the folders and `extractAssets96.js`. The Unsure list stays below and is copied into the handoff.

## Names that differ

Already the 95G name: 931 labels. Leave them. Three were renamed once the files that hold them existed: `getGoalieSCnum` is `FindGoalie` in control96 (d0 = the goalie's SCnum), `ClearShootout` is `ShootoutInit` in shootout96_path, and `LetterGrid` is `CreateLetterGrid` in records96. `LetterGridPos` is a different routine and keeps its name.

Labels the masked search found inside bytes, where 96 has no name at that address (the 95G name is a global, not a `GatherAndSort.something` local). Confirm the body, then name them. Skip any that land in the middle of a routine that already has a name.

| 96 address | 95G name | 95G file | In |
|---|---|---|---|
| `$02032C` | rtss2 | video95 | display96 |

Named from the 95 body: chkpk (logic96_puck), UpdatePenaltyShotEnd and PenShotTable (shootout96), a2touchpuck (logic96_pull), SetScroll2, ClockDigitChar, DoDMAList, DumpSprites2, rtsShowCrowd and ButtonLabelCharTable (display96; the big-font clock copy in middle96_clock is BigClockDigitChar), Goal (collide96), GoalTypeTbl (summary96), setteams (control96_team), InitCreateRecord (create96), getplayernameD7 and getnamea0 (trade96), InitializeGameStructures and GetRandomUnusedTeam (playoff96). `$02032C` stays unnamed: 96 already uses rtss2 for the shared rts in collide96. VBlank_SpriteFade is the summary96 vbint. setup96_menu already owns VBlank_SetOptions. rtsBigClock is the shared return of the big-font clock.

`code96_05` is `front/season96.asm`. `SortBytesByWords`, `PrintOrdinal` and `OrdinalSuffix` are in the name map. The rest of its `sub_` / `unk_` names are finish-plan step 2: name one only when the body makes the job obvious.

SegaInit locals (`h_s`, `cold_start`, `clr_wk`, ...) already exist in `src/sega/SegaInit.asm` and are in `docs/name_map.csv`. Do not invent a second copy.

RAM: 294 names are shared with `src/ram95.asm`. 286 of those sit at a different address, which is expected (the RAM map moved). 145 RAM names are still `word_FF` / `byte_FF` / `unk_FF`. Rename one when a converted use matches a 95G RAM name by what the code does, and record it in `docs/name_map.csv`. Do not rename from the address alone.

### Do not rename (checked, not a 95G match)

| 96 name | Why it stays |
|---|---|
| stopfast | Same shape as 95G `stopna2` with step `$7D0`. 96G already has `stopna2` in skate96. Clash rule. |
| StandingsPoints | Same shape as `CalcSeedPoints`. 96G already has `CalcSeedPoints` in awards96. |
| PrintCurLetter | 95G `PrintGridLetter` is already the create-player label in create96. This one is name entry. |
| DoFrameUpdates | The first words match `CheckNewCarrier`; the routine then does the crowd, the clock and the one-second work. |
| SetSframe | Masked hit is 95G `AddSpriteFrame`. 95G also has `SetSframe`. The 96 comment matches `SetSframe`. Left alone until the two 95G bodies are compared side by side. |
| SortValuesUp, CreateListMove, rtsNameCursor | The 95G hit is a local (`GatherAndSort.sortValuesUp`, `CreatePlayer.createListMove`, `rtsCreate2`), not a global to copy. |
| Start / SegaInit | Both names already sit on `$000200`, as in 95G. |

## New in 96

| What | Where now | Home |
|---|---|---|
| Fighting (`checkfight`, `startfight`, `SetInst`, `fightinput`, `assfight`, `assfwatch`) | code96_02 tail, code96_03 head | `engine/fight96.asm` |
| Save RAM bit fields (`WriteSRAMBits`, `ReadSRAMBits`) | code96_02 head | `src/srambits96.asm` |
| Season screens and the playoff menu (`sub_` in code96_05, code96_16) | code96_05, code96_16 | `front/season96.asm`, `front/season96_menu.asm` |
| Options screen (`OptionsScreen` and the menu after the create-player list) | code96_17 | `front/options96.asm` |
| Opening screens after the injuries (`TitleScreen` through `CupCelebrationSprites`) | code96_20 | `front/title96.asm` |
| Region lock as a hex digit of region bits | main96 | stays in `main96` (95G's lock is the same file, different test) |
| `.pos` nibble per player, no All-Star teams | teamdata96 | stays in `teamdata96` |
| Player struct fields past `$60` shifted by one | equals.inc, readers in the fight and goalie code | a later equals pass, not a new file |

## Asset extraction

95G: `tools/extractAssets95.js` writes `Extracted/NHL95/...` (team pals, `*.map.jim`, sprite and font bins, arena graphics, `z80_snd_drv95.bin`, `snd95_patch_XX.bin` / `sample` / `song` / `list`, `ScoutTextScript.bin`) and `Extracted/.extract-complete.json`. `tools/prebuild.js` runs it. Source incbins those files. `npm run assets` and `npm run extractassets` are the entry points.

96G: `tools/extractAssets96.js` does the same for `Extracted/NHL96/`. `prebuild.js` and `npm run extractassets` call it. The marker is written last (`rom`, `romSha1`, `extractor`, `extractorSha1`, `files`) and does not record a map SHA-1. `tools/extractSegments96.js` is not part of the build. `tools/segmap96.json` remains the ROM map the docs and `find95.py` use. A missing ROM still stops in prebuild, including "ROMs are not included in the repo".

- Team pals stay at `NHL96/Graphics/Pals/*h96.pal` (also the `assets` array in the ROM map, inclusive end).
- Graphics: `NHL96/Graphics/<Label>.map.jim` or `.bin`, one file per label whose body is data. `.bin`: Sprites, Spritetiles, SpritePalette, frameSprData, HotList, HotList2, RevRinkTilelist, RosterFont. A map stays one incbin; tiles are `Label+8`.
- Z80 program `NHL96/Sound/z80_snd_drv96.bin`, each sound-bank item `NHL96/Sound/Bank/snd96_{patch|sample|song|list}_{id}.bin` (168), and `NHL96/Text/ScoutTextScript.bin`.
- `graphics96`, `sound96` and `front/scout96.asm` incbin those files. Paths are relative to `src/` (`..\Extracted\...`). Do not put a `dc.b` dump back.

## Symbols, comments, docs

Where 95G writes `SPA*` / `SPF*`, a RAM field, a team equate or an `SFX_*` id, 96G still has the hex in places (the frames file defines tables by SPA value; immediates in the code are only partly converted). Do that pass after the file that owns the symbol exists, and only where the bytes do not change.

File headers are already short stories in most converted files. When a file is split, each new file gets a header in that style. No rename history, no ROM addresses, no "from 95G".

`START_HERE.md`, `SEGMENT_AGENT.md`, `PROMPT.md` and `docs/HANDOFF.md` follow the folders and `extractAssets96.js`. The remaining work is the finish plan below. The symbols pass is step 7 of that plan, after the names.

## Finish plan

The file split, the asset extraction, and the names that already match 95G are done. What is left is inside those files. A generic label is finished when it has a real name in the source and in `docs/name_map.csv`, or a closed-list row with the reason. The symbols pass is finished when every hex immediate that already has an equate uses that equate and the ROM still matches.

Status after the October 2026 naming pass (branch `naming-pass`, see `docs/HANDOFF.md`): 60 generic labels remain, each on the Unsure list with its reason. 46 RAM (`src/ram96.asm`; 14 of them have no uses), 4 graphics `unk_` incbins in `src/graphics96.asm`, and 10 code labels (`sub_AFDA`, `loc_C068`, `sub_FD14`, `sub_FD80`, `sub_FFD0`, `sub_11582`, `nullsub_2`, `sub_14804`, `sub_1D920A`, `sub_1E0D86`). Steps 1-6 below are done except for those; step 7 (symbols) and step 8 (docs) remain.

A routine that matches 95G takes the 95G name. The clash rule stays: the earlier meaning keeps the name. A label with no parent match is named from what the code does, and only when that is obvious. A name that would be a guess is a closed-list row. One file per commit. `tools/verify_all.sh` ends in `ALL MATCH` before the commit. Push to main. No force-push.

These stay as they are: the "Do not rename" table above, `print` / `printcur`, the dotted 95G locals, and the lone `rts` at `$02032C` (96G already uses `rtss2` for the shared rts in collide96). `code96_14` and `code96_15` stay numbered. Graphics and sound stay incbins. Bytes do not move into an earlier file.

1. Decoded routines. `lines96_set` first. Its routines already build a team's lines, and there is no 95G body to copy, so each name comes from the job (return the line block, fill one position list, mark a player used, write the best goalie). Then the leftovers in `display96`, `title96`, `penalty96`, `playoff96`, `trade96` (checked against trade95), and the files that have one or two labels. A `nullsub_` is named only when its callers share one job. When they do not, close it as a shared empty return.
2. `front/season96.asm`. New in 96, no 95G byte match. `SortBytesByWords` and `PrintOrdinal` are already named. Name a screen only when the text, the vblank, or the menu shows which screen it is. A routine that is still just a season screen stays on the closed list.
3. `dc.b` entries (`logic96`, `create96`, `logic96_vec`, `trade96_edit`, and the remaining blobs in `collide96` and `playoff96`). Name the entry when the caller or a 95G body identifies it. Decode an instruction only when each opcode is checked against the ROM. Leave the rest as bytes under that name.
4. One more 95G body search. A long masked compare on the labels that are still generic, and on interior points the way `Goal` was found. Take a name only when the body matches. `$02032C` stays unnamed.
5. Graphics `unk_` labels, including the scout96 picture (now `TitleScreenImg`). Rename one only when the picture is the same asset as a 95G picture, judged by more than the map header, or when one caller already says what the picture is. A rename also changes `tools/extractAssets96.js`, the incbin path, and the extracted file, then the ROM is rebuilt and matched. A header-only lookalike stays `unk_` and is closed.
6. RAM. Rename a `word_FF` / `byte_FF` / `unk_FF` only when converted code shows the 95G variable, or the use is obvious. Update every use and `docs/name_map.csv`. An address match alone is not a rename. The rest are closed.
7. Symbols and immediates. Replace hex with an existing equate where 95G writes `SPA*` / `SPF*`, a RAM field, a team equate, or an `SFX_*` id, and only where the bytes do not change. The player-struct fields past `$60` are their own step: confirm the one-byte shift against 95G before any offset becomes a name.
8. Docs. Shrink the Unsure list as each item closes. `SEGMENT_AGENT.md` name cells change when a file's main names change. `SetSframe` is the one reopen on the old list: compare it with 95G `SetSframe` and `AddSpriteFrame`. If it is `SetSframe`, close it. If it is `AddSpriteFrame` and that name is free, rename it.

## Unsure

- `SetSframe` versus 95G `AddSpriteFrame` (see the table above).
- Which `season96` routine is which season screen. No 95G byte match. Name one only when the body makes the screen obvious (finish plan step 2). `SortBytesByWords`, `PrintOrdinal` and `OrdinalSuffix` are already named and are in the name map.
- 145 IDA RAM names. No rename until a use shows the 95G variable.
- 95G `print` versus 96G `print` / `printcur`. Already decided (clash). Do not revisit.
- Dotted 95G locals reported by the masked search (`sortValuesUp`, `createListMove`, `rtsCreate2`). Not copied.
- Whether `ClockDigitChar` at `$020892` is the same routine as middle95 or a second copy. Resolved: `$020892` is the 95 routine (offset `$64`, smallfontchars) and is `ClockDigitChar` in display96. The big-font copy in middle96_clock is `BigClockDigitChar`.
