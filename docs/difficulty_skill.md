# Skill level (difficulty) — NHL 96

NHL **96** adds a **skill level** option on the game options screen. NHL **95G** has no matching menu row or `OptSkill` RAM field; this is new in 96.

This option is **not** the playoff round counter **`gamelevel`** (`$FFFFCFCA`), which season and playoff code use for bracket progress. Skill level only affects on-ice physics constants derived from the player’s menu choice.

## Names in this doc (generic IDA labels vs source names)

This disassembly started from an IDA Pro listing (`lst/nhl96.bin.lst`). Many symbols still use IDA’s automatic prefixes. Renames live in source and in `docs/name_map.csv` (columns: address, current name, `ida_name`, old name, module). When reading code or the listing, the same address may appear under two names.

| Pattern | Meaning | Skill-level examples |
| --- | --- | --- |
| `sub_XXXXXX` | IDA “subroutine at address” | `SetSkillLevel` was `sub_1E1AA8` |
| `unk_XXXXXX` | IDA “unknown data” | `SkillLevelTbl` / `SkillLevelPalTbl` were `unk_1E1AC8` / `unk_1E1ACE` |
| `word_FFFFFFXX` | IDA RAM word at `$FFFFxxxx` (no semantic name yet) | `word_FFD284`, `word_FFD286` — still only `equ` lines in `src/ram96.asm`, **not** rows in `name_map.csv` yet |
| `word_FFD268` | Same pattern; this one **was** renamed | Source: **`OptSkill`** (`ida_name` = `word_FFD268` in the map) |
| `loc_XXXXXX` | IDA local label inside a function | Options screen still has internal `.0` / `.16` labels; no skill-specific `loc_` |
| `dc.b` under a named label | Listing did not decode as instructions; bytes kept verbatim | **`SkillItem`** (and sibling `FightingItem`, `PenaltyItem`, …) |
| `byte_FF…` / `dword_FF…` | Same as `word_FF…` for other sizes | Not used on the skill path |

**Already named in source** (safe to use in new comments): `OptSkill`, `SetSkillLevel`, `SkillLevelTbl`, `SkillLevelPalTbl`, `SkillText`, `SkillItem` (label only; body is still bytes), `OptionsScreen`, `SetPlayMode`, `puckvzadj`, `updateplayers`, `pfjoycon`.

**Still generic in source** (describe by role until a symbols pass renames them): `word_FFD284` / `word_FFD286` — runtime NTSC/PAL gravity multipliers filled by `SetSkillLevel`. Comments in `logic96_timer.asm` call them “Gravity”.

**Easy to confuse (not difficulty):**

- **`SkaterSkillLabels` / `GoalieSkillLabels`** (`create96.asm`) — create-a-player **attribute** row titles (shot, passing, etc.), not the options “skill level”.
- **`PrintRecordName`** (`summary96.asm`) — record holders screen; **not** what `SkillItem` calls.
- **`SkipStrings`** (`$01D7F2`, `hockey96_inter.asm`) — walks a `String` table: given `a1` = base and `d0` = index, advance `a1` to the chosen line and return. Every `*Item` row in `options96.asm` ends with `jsr SkipStrings` after loading `a1` = `SkillText` (or `FightingText`, …) and `d0` = `OptSkill`.

## Does the switch actually do anything?

**Yes, but only through physics tuning** — not through separate goalie, save, or AI difficulty logic.

A full-tree search of converted source shows:

- **`OptSkill`** is read in: options UI, SRAM defaults, `SetSkillLevel`, and one branch in **`updateplayers`** (rookie + human skater).
- **`word_FFD284` / `word_FFD286`** are read in exactly **`puckvzadj`** and **`updateplayers`** (plus written in `OptionsScreen` / `SetSkillLevel`).

There is **no** reference that ties skill level to goalie save probability, reaction time, AI aggression, line logic, pass/shot accuracy tables, or player ratings. Those systems use other RAM and tables.

What **does** change:

| Effect | Where | What changes |
| --- | --- | --- |
| Top-shelf shot **vertical puck speed** (`puckvz`) | `doshot` → `puckvzadj` | Uses the gravity word in a distance/height formula; not general `puckvx`/`pucky` speed for every shot |
| **Skater** friction and velocity integration | `updateplayers` in `control96.asm` | Ice damping, multiply `Xvel`/`Yvel` by the gravity word, Z fall while airborne / on ice |
| **Rookie only**, **your** skaters | Same block | If `OptSkill` = 2 and `pfjoycon`, add **+2** to the multiplier before those integrators |

**Pro vs all-star:** `SkillLevelTbl` and `SkillLevelPalTbl` store **identical** values for indices 0 and 1. In this ROM, those two menu labels are **the same difficulty**; only **rookie** (index 2) changes the table, plus the extra human-only +2 on rookie.

**Goals and saves:** There is no “rookie goalie” flag. Any difference in scoring or saves would be **indirect** (puck arcs, skater speed/turning on ice), not a dedicated goal/save difficulty mode.

**Shootout:** `SetSkillLevel` is **not** called when starting shootout from options, so `OptSkill` does not refresh the gravity words on that path (they stay at whatever `OptionsScreen` set on entry — default pro/all-star constants).

**Confidence:** This is complete for **all labelled references in `src/`**. Undecoded `dc.b` elsewhere could in theory touch the same RAM words without using the symbol names; nothing in the listing grep for those addresses suggests extra readers. If a future decode finds another use, this doc should be updated.

## Where it appears

| Piece | Location |
| --- | --- |
| Options UI | `src/front/options96.asm` — `OptionsScreen`, `OptionsMenuList`, row label in the header `String` (`'skill level:'`) |
| Menu variable | `OptionVars` last entry → `OptSkill` |
| Display strings | `SkillText` — three choices, in index order |
| Row handler | `SkillItem` (still `dc.b`; clamps `OptSkill` and returns the active `SkillText` line in `a1`, same pattern as `FightingItem` / `PenaltyItem`) |
| RAM | `OptSkill equ $FFFFD268` in `src/ram96.asm` |
| Apply at game start | `SetSkillLevel` in `options96.asm` (called from `SetPlayMode` on most play modes) |
| Runtime gravity words | `word_FFD284` (NTSC), `word_FFD286` (PAL via `PalMode`) in `src/ram96.asm` |

### Menu values and labels

Left/right on the highlighted row increments or decrements the word pointed to by `OptionVars` (`OptionsScreen` `.14` / `.15`). `SkillItem` keeps the stored value in **0–2** and picks the label:

| `OptSkill` | Menu text (`SkillText`) |
| ---: | --- |
| 0 | `pro` |
| 1 | `all-star` |
| 2 | `rookie` |

`SkillItem` also checks `OptPlayMode` (like `GoalieItem`): for some play modes the row is treated as not applicable (`NotApplicableText`) instead of the three skill strings.

### Defaults and save data

- **SRAM init** (`ClearSRAM` in `src/sram96.asm`): `OptSkill` = **1** (all-star).
- **Options idle timeout** (`OptionsScreen` `.16`, ~30 s on the menu): resets options to defaults, including `OptSkill` = **1**.
- **Persistence**: `ReadOptions` / `WriteOptions` read or write **`$18` bytes** from save RAM offset **`$1EC6`** starting at `OptPlayMode`. `OptSkill` lies in that block (after `OptFighting`; before `OptRosters`). The gravity words `word_FFD284` / `word_FFD286` are **not** stored in SRAM; they are filled when a game mode is applied.

On entering `OptionsScreen`, the code sets `word_FFD284` = `$15` and `word_FFD286` = `$1D` before `ReadOptions`. Those are the same numbers **pro** and **all-star** use in the tables below; they stay in RAM until `SetSkillLevel` runs or the screen is entered again.

## Applying skill when play starts

`SetPlayMode` (`options96.asm`) configures season, playoff, shootout, and normal game paths.

- **Shootout** (`OptPlayMode` = 6): branches to `ShootoutInit` **without** calling `SetSkillLevel`. Gravity stays at the values left from `OptionsScreen` entry (defaults above), regardless of `OptSkill`.
- **Other modes** that start a game (path `.4` → `.5`): after `SetLineOption` and `SetPenOption`, calls **`SetSkillLevel`**.

`SetSkillLevel` indexes by `OptSkill` (word index × 2) into two parallel tables:

```asm
SkillLevelTbl    dc.w $15,$15,$14   ; → word_FFD284 (NTSC)
SkillLevelPalTbl dc.w $1D,$1D,$1C   ; → word_FFD286 (PAL)
```

| `OptSkill` | Label | NTSC (`word_FFD284`) | PAL (`word_FFD286`) |
| ---: | --- | ---: | ---: |
| 0 | pro | 21 (`$15`) | 29 (`$1D`) |
| 1 | all-star | 21 | 29 |
| 2 | rookie | 20 (`$14`) | 28 (`$1C`) |

Pro and all-star share the same gravity constants; only **rookie** uses the slightly lower table entries (weaker “gravity” multiplier in the formulas below).

`SetSkillLevel` is the **only** call site in the tree (`grep`); there is no separate path that reapplies skill mid-period except returning to options and starting again.

## Gameplay effect (physics, not AI difficulty)

The skill tables do **not** rename AI scripts or roster ratings. They only feed two routines that already treat `word_FFD284` / `word_FFD286` as a **gravity scale** (comments in source use “Gravity”).

### Puck vertical speed (`puckvzadj`)

`src/engine/logic96_timer.asm` — `puckvzadj` runs from the shot path (`doshot`) for top-shelf shots. It loads `word_FFD284`, or `word_FFD286` when `PalMode` is set, and uses that value when deriving `puckvz` from horizontal distance to the goal line (`$11E`) and `puckvy`.

### Skater movement (`updateplayers`)

`src/control96.asm` — inside the per-player loop in `updateplayers`, after animation/state checks:

1. Load the same gravity word into `d4` (PAL swap as above).
2. Skip this block for some `SPA` ranges (`SPA17E4`–`SPA1F76`, and `SPA2B88`).
3. On ice (`Zpos` = 0), apply extra damping to `Xvel` / `Yvel` (shift 6 or 9 depending on `pflags` bit 0, home vs away).
4. Multiply velocities by `d4` and integrate into `Xpos` / `Ypos`; apply extra Z terms when airborne or on the ice surface.

**Rookie-only tweak** (human-controlled skaters):

```asm
cmpi.w  #2,(OptSkill).w    ; rookie
btst    #3,pflags(a3)      ; pfjoycon — joystick-controlled player
addq.w  #2,d4              ; stronger effective gravity for that player only
```

So on **rookie**, user-controlled skaters get **+2** added to the gravity multiplier before the multiply/integrate step. AI skaters on rookie still use the base rookie table value (`$14` / `$1C`). Bit 3 of `pflags` is **`pfjoycon`** (`src/stubinc/equals.inc`), not `pfteam` (bit 6).

No other source references to `OptSkill` were found besides options UI, SRAM defaults, and this rookie branch.

## Related symbols (rename status)

| Address | Source name | IDA / generic | Notes |
| ---: | --- | --- | --- |
| `$FFFFD268` | `OptSkill` | `word_FFD268` | In `name_map.csv` |
| `$FFFFD284` | `word_FFD284` | (no map row) | NTSC gravity multiplier |
| `$FFFFD286` | `word_FFD286` | (no map row) | PAL gravity multiplier |
| `$1E13CA` | `SkillItem` | — | Body still `dc.b` |
| `$1E1AA8` | `SetSkillLevel` | `sub_1E1AA8` | |
| `$1E1AC8` | `SkillLevelTbl` | `unk_1E1AC8` | |
| `$1E1ACE` | `SkillLevelPalTbl` | `unk_1E1ACE` | |
| `$01D7F2` | `SkipStrings` | `sub_1D7F2` | Index into `SkillText` for menu display |

Finish plan step 7 in `docs/align95_plan.md` may rename `word_FFD284` / `word_FFD286` once every use is converted to a shared equate.

## Quick contrast: skill vs playoff round

| | Skill level | Playoff round |
| --- | --- | --- |
| RAM | `OptSkill` `$FFFFD268` | `gamelevel` `$FFFFCFCA` |
| User-facing | Options → “skill level” | Season / playoff progression |
| 95G | New in 96 | Present in 95G |
| Effect | Gravity / movement tuning | Bracket and season logic |
