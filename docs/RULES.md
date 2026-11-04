# Rules (96G)

The rules for this repo's part of the alignment, then the learned rules. Read before every unit. Any tool adds a learned
rule in the same commit as the fix that confirmed it, newest last: `- YYYY-MM-DD <area>: <rule>. (<evidence>)`.

## Who decides what (all games)

| Category | Decided by |
|---|---|
| Name of a routine several games share | the earliest game that has it (92G is the root); a fix goes to the earliest repo first, then down the lineage |
| Name of a feature new in year N | that year's Genesis game (94G for 94S and 94PC, 95G for 95S and 95PC) |
| Name of a platform-only job | the earlier repo on that platform (93S for 94S, 94PC for 95PC), else what the code does |
| Same name, different job | the earlier meaning keeps the name |
| Top folder or file | the same-year Genesis file |
| RAM order | the merged order (92G, 93G, 94G, 93S, 94S, then 95G, 96G) |
| Data, assets, banks | the earlier repo on the same platform |
| Order inside a file | ROM order (the report re-sorts for display) |
| History | `docs/name_map.csv` only, never source comments |

## This repo

- Names: the 95G name when the body is the same routine, then 94G, 93G, 92G.
- Files: follow 95G's folders. A file is split only when two subsystems each own a real contiguous run (`logic96_ass`).

## Learned

- 2026-11-03 names: the pause menu routines keep the 92G-95G names (Pausemode_pall, Pausemode_top, Pausemode_Pmenu), not new 96 names; the bodies match 95G line for line. (owner spotted SetupPauseScreen in the report)
- 2026-11-04 contributing: CONTRIBUTING.md must not contradict History: lineage lives only in the name history file, never in source comments. (CONTRIBUTING rewrite vs RULES History row)
- 2026-11-04 D6: remaining generic labels and role-only 95G matches stay on the Unsure list; 95G wins only when the body is the same. (align95_plan.md Unsure; leftovers D6 parked)
- 2026-11-04 D6 names: same job + new body takes the 95G name; leftover sub_/loc_/unk_ are named from job, callers, SRAM or role. input96_shot: SetRoles / SetTeamRoles / ClearRolesIfGoalie (no 95G parent). (owner)
- 2026-11-04 D6 names: input96 StartDpadBoost (start + dpad on a skater: SPA288C, pf2aip, Xvel+$64). No 95G parent. (owner)
- 2026-11-04 D6 names: fight96 EngageFight (A/B/C during SPAfight: SPA3128, second fighter SetFightingMajors). No 93G parent. (owner)
- 2026-11-04 D6 names: season96 ClearRosterSave (Reset Rosters: stats, $DDD, injuries, FA stats). No 95G parent. (owner)
- 2026-11-04 D6 names: create96 CheckTeamLines is the 95G name (team d7 saved lines); 96 clears the $41-byte block instead of fixing slots. (owner)
- 2026-11-04 D6 names: hockey96 ClearSavedPlayoffs (StartGame OptPlayMode>1: SRAM $E68-$ECD). Not 95G ClearShotData. (owner)
- 2026-11-04 D6 names: code96_15 PrepShotPass (before setpassmode/SetShotMode; movem undoes the TempWord1 load). (owner)
- 2026-11-04 D6 names: teamgfx96 rtsPlayoffOver (empty return after EncodePW at playoff over). Not 95G StanleyCupScreen. (owner)
- 2026-11-04 D6 names: graphics96 ArenaAnimGfx, PStatsPal, CupCelebrationSpr, CupCelebrationMap; extractor incbin names follow the labels. (owner)
- 2026-11-04 D6 names: ram96 unk_FF named from job/layout (glovestruct from 94G; SetupPadStruct, PadChanged, FightMash). (owner)
- 2026-11-04 D6 names: ram96 leftover word_FF / byte_FF / dword_FF named from job, 94G/95G RAM, or layout; two jobs at one address keep both names (TeamSelectHome/pstatsteam, puckanimchars/PlayoffHpos, DumpPassSc/PListCol). Unused slots get a layout name. (owner)
- 2026-11-04 D6 names: For-Abdul same-job 95G names: BlankMenuBox→ClearMenuBox, CupChampionsScreen→StanleyCupScreen; PauseScreenDraw, SimTeamGoals, SimScorers, SimShots, ClearSeasonData kept. (owner)
