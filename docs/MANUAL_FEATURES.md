# NHL 96 Genesis: the manual's features and where they are in the code

Pages are the page of the archive.org scan (SEGAGenesisMegaDriveManuals), PDF p.N; other copies may be a page off.
"Open" means the code for it has not been located yet. Written 2026-11-24.

## New features for 96 (PDF p.4)

| Manual line | Code |
| --- | --- |
| Skill levels Rookie, Pro, All-Star | `OptSkill`, see docs/difficulty_skill.md |
| Fighting option | src/engine/fight96.asm, `SetFightingMajors` |
| One-Timer Pass, Give-and-Go | Open |
| Spin-o-Rama | Open |
| New graphics and animations | new `SPA` entries in src/frames96.asm |
| Advanced goalie and defense AI | see below |
| Multiple injuries | Open |

"Improved Gameplay and Computer AI—Advanced goalie and defense intelligence; faster overall gameflow" is in code as:

- short-handed variants of the role routines, `asstab` $24-$2F (`assdefo5` .. `asscenterd4`) in
  src/engine/logic/logic96.asm, picked by the team's skater count (`tmap`);
- `SetRoles` / `SetTeamRoles` / `RoleTable` (src/engine/input/shot.asm), run once a second for a full-strength team;
- the `goaliesave` changes in src/engine/logic/puck.asm (new `SPAgblock`, `SPAgcatchlow` and reach saves).

None of these is power-play only. 95G has none of them.

## Modes (PDF p.4-5)

| Mode | Manual |
| --- | --- |
| Regular game | single-game exhibition |
| New Playoffs | single-game elimination |
| New Playoffs Best of 7 | best-of-7 series |
| Season | with best-of-7 playoffs, awards |
| Shootout | any two teams (PDF p.12) |
| Transactions | create, trade, sign |

Overtime is 5 minutes after regular and season games and 20 minutes after playoff games (PDF p.5).

## Options and scoreboard

- Goalie: Manual or Auto control (PDF p.5); hold B to take the goalie (PDF p.3). RAM: `OptGoalie`.
- Change the starting goalie, bring in a replacement, or pull him for an extra attacker (PDF p.7):
  `SelectGoalieMenu` (src/engine/pause/menu.asm).
- One timeout per team per game; it refreshes the lines (PDF p.8): `TimeoutMenu` and `PauseMenuNoTimeout`
  (src/engine/pause/), team struct $30 bit 2.
- User records for up to seven players (PDF p.5): src/front/records.

## Players and lines

- Up to four players with the EA SPORTS 4 Way Play adapter (PDF p.6): `Detect4WayPlay` (src/engine/fourway96.asm).
- On the power play or penalty kill only two lines are available, PP1 and PP2 or PK1 and PK2 (PDF p.10).
- A fight is not a coincidental penalty: both players get majors and their teams play short (PDF p.10); after four
  seconds the referee steps in. Code: `SetFightingMajors`.

## Shootout, trades and created players

- Shootout mode (PDF p.12): src/front/shootout. The manual adds that spin-o-rama is not allowed in the shootout.
- Trades (PDF p.13): several players may move, but no more than three from a team. "NHL 96 has the final word on all
  trades": stacking a team is rejected, and the player can press C to overrule the rejection. Code: src/front/trade.
- Up to 19 created players (PDF p.13): src/front/create96.asm.
