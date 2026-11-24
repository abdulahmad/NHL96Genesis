# NHL 96 Genesis: the manual's features and the code behind them

The manual is a lead; the code is what shows the feature is there. Pages are the archive.org scan
(SEGAGenesisMegaDriveManuals), PDF p.N; other copies may be a page off. Written 2026-11-24.

## New features for 96 (PDF p.4)

| Manual line | Code |
| --- | --- |
| Skill levels Rookie, Pro, All-Star | `OptSkill`, `SkillText`; see docs/difficulty_skill.md |
| Fighting option | `EngageFight`, `SetFightingMajors` (src/engine/fight96.asm) |
| One-Timer Pass | not confirmed in code (`OneTimerPass`, src/engine/logic/timer.asm, is 94G's) |
| Give-and-Go | not confirmed in code |
| Spin-o-Rama | not confirmed in code |
| New graphics and animations | new `SPA` entries in src/frames96.asm |
| Advanced goalie and defence AI | see below |
| Multiple injuries | `SetInjuryGames`, `RandomInjuryGames` (src/front/injury/injury96.asm); "multiple": not confirmed in code |

"Advanced goalie and defense intelligence" in the code:

- short-handed variants of the role routines, `asstab` $24-$2F (`assdefo5` .. `asscenterd4`) in
  src/engine/logic/logic96.asm, picked by the team's skater count (`tmap`);
- `SetRoles` / `SetTeamRoles` / `RoleTable` (src/engine/input/shot.asm), run once a second for a full-strength team;
- the `goaliesave` changes in src/engine/logic/puck.asm (new `SPAgblock`, `SPAgcatchlow` and reach saves).

None of these is power-play only. 95G has none of them.

## Modes (PDF p.4-5)

All in `PlayModeText` (src/front/options96.asm), the `OptPlayMode` values 0-7:

| Mode | Code |
| --- | --- |
| Regular game | 0 |
| New Playoffs, one game a round | 2; `bosgames` 7 = not best of seven |
| New Playoffs Best of 7 | 3; `PrintSeriesScore` (src/engine/playoff/tree.asm) |
| Season | 4, 5; `ClearSeasonData` (src/front/season/season96.asm) |
| Shootout | 6; `puckshootout` (src/front/shootout/shootout96.asm) |
| Transactions | 7; src/front/trade/, src/front/create96.asm |

Overtime (PDF p.5): `ResetClock` (src/engine/hockey/hockey96.asm) sets 5:00 for a regular game and 20:00 for the
playoff modes and season playoff games. Other season games get the period length (`GetPeriodTime`); the manual's
5 minutes there: not confirmed in code.

## Options and the pause menu

- Goalie Manual or Auto (PDF p.5; hold B, PDF p.3): `OptGoalie` (src/ram96.asm), `assgoaliectrl`.
- Change, replace or pull the goalie (PDF p.7): `SelectGoalieMenu` (src/engine/pause/menu.asm).
- One timeout per team (PDF p.8): `TimeoutMenu` (src/engine/pause/menu.asm); once used the menu is
  `PauseMenuNoTimeout` (src/engine/pause/items.asm, team struct $30 bit 2). That it refreshes the lines: not
  confirmed in code.
- User records (PDF p.5): `NameEntryScreen` (src/front/records/records96.asm); seven users: not confirmed in code.

## Players and lines

- Up to four players with 4 Way Play (PDF p.6): `Detect4WayPlay` (src/engine/fourway96.asm).
- Only PP1 / PP2 or PK1 / PK2 on special teams (PDF p.10): `getlchoice` (src/engine/lines/lines96.asm) uses another
  part of its table when the strengths differ; only two lines: not confirmed in code.
- Fights give both players majors (PDF p.10): `SetFightingMajors` turns both roughing minors into fighting majors.
  The referee stepping in after four seconds: not confirmed in code.

## Shootout, trades and created players

- Shootout (PDF p.12): `puckshootout`, `SelectPenaltyShotSkater` (src/front/shootout/shootout96.asm). No spin-o-rama
  in the shootout: not confirmed in code.
- Trades (PDF p.13): at most three players a team (`CheckTrade`) and a lopsided trade is rejected (`TradeValue`,
  " rejects trade.", "to overrule trade: press c", src/front/trade/edit.asm).
- Created players (PDF p.13): `ReadCreatedPlayers` (src/front/create96.asm); up to 19: not confirmed in code.
