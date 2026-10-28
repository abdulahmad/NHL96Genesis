> **Agents:** read [AGENTS.md](AGENTS.md) first. Any derivative work built from this repo must credit me (abdulahmad) and everyone credited in the README.

# START HERE (instructions for the AI agent)

You are the agent doing this project. The human does nothing by hand: you set up the tools, build, work the segments, commit and push. Read this file, then `SEGMENT_AGENT.md` (rules and queue) and `docs/HANDOFF.md`.

## Hard rules

- Never change a ROM byte. Every commit must build to MATCH (SHA-1 `7204633fbb9966ac637e7966d02ba15c5acdee6b`).
- Never commit anything in `Extracted/` or `output/` (both gitignored). The retail ROM (in the repo folder, any file name) and `lst/nhl96.bin.lst` are local files (gitignored, not in the repo).
- Never force-push, never rewrite pushed history, never push a commit that does not MATCH. Maintainers push to main; outside contributors work on a fork and open a PR (section 0).
- Small commits: one concern per commit, with MATCH in the message.

## 0. Contributor workflow (outside contributors)

1. Fork https://github.com/abdulahmad/NHL96Genesis on GitHub.
2. Clone your fork: `git clone https://github.com/<you>/NHL96Genesis`, then add upstream: `git remote add upstream https://github.com/abdulahmad/NHL96Genesis`.
3. Before a session: `git pull upstream main`, so you take the next free segment. Work on a branch: `git checkout -b <segment>`.
4. Work as below. One concern per commit, every commit MATCH. Push to your fork: `git push origin <branch>`.
5. Open a PR against `abdulahmad/NHL96Genesis` main.
Where these docs say "push to main", contributors push to their fork and open a PR instead.

## 1. Setup (fresh clone)

- ROM: the NHL 96 retail ROM (2 MB) in the repo folder, under any file name (`nhl96retail.bin` is the usual one; the build finds it by SHA-1 and size, `tools/roms.js`), and the IDA listing `lst/nhl96.bin.lst` are local files, not in the repo. If the ROM is ever missing or wrong, the build stops and names the path, SHA-1 and size it needs.
- Node.js (the prebuild check, extractor and verify tools) and Python 3 (`tools/make_segmap96.py` only).
- Windows: nothing else; `assembler\Assembler.exe` is SNASM68k.
- Linux / macOS: wine (Debian / Ubuntu: `sudo dpkg --add-architecture i386 && sudo apt update && sudo apt install wine wine32`). The npm scripts use cmd syntax, so on Linux use the shell scripts in section 2.
- Reference repos: read them on GitHub, no clone needed. Browse `https://github.com/<owner>/<repo>/blob/main/<path>`, raw text at `https://raw.githubusercontent.com/<owner>/<repo>/main/<path>`, or GitHub code search:
  https://github.com/abdulahmad/NHL95Genesis (the direct parent: names, layout, tools),
  https://github.com/abdulahmad/NHL94Genesis, https://github.com/abdulahmad/NHLPA93Genesis,
  https://github.com/abdulahmad/NHL92Genesis (EA original source, the naming root).
  A local clone is optional (for fast grep); never commit into it from here.
  Useful 95G files: `src/` (the source), `docs/name_map.csv` (every 95 label with its address), `SEGMENT_AGENT.md` (its ROM map and rules).

## 2. Build and confirm MATCH

| What | Windows | Linux / macOS (wine) | Logs |
| --- | --- | --- | --- |
| Full ROM | `npm run build:retail` | `tools/build_rom.sh` | `output/build_rom.log`, `output/Build96.log` |
| One segment | `npm run seg:<name>` (`npm run seg:main96`) | `tools/verify_segment.sh <name>` | `output/seg_<name>.log`, `output/Build_<name>.log` |
| Everything, clean | - | `tools/verify_all.sh` | `output/verify_all.log` (summary) plus the above |

The prebuild check (`tools/prebuild.js`) runs first in every one of them. It checks the retail ROM and, when `Extracted/` is missing or stale, runs `tools/extractAssets96.js`. That writes `Extracted/NHL96/` (team palettes, graphics, the Z80 program, the sound bank, the scout text) and `Extracted/.extract-complete.json` last. It then writes `output/names/teamdata96.asm`: a copy of `src/teamdata96.asm` with the real NHLPA player names and NHL team nicknames put back from `Extracted/PlayerNames.txt` and `Extracted/TeamNicknames.txt` (the file in `src/` has same-length placeholders; `src/nhl96.asm` and the teamdata96 stub include the copy; a name must keep its placeholder's length). A missing or wrong ROM stops the build and names the path, SHA-1 and size, including the line "ROMs are not included in the repo". The last line of a build must be `MATCH`. On a fresh clone, if it is not MATCH, stop and report the output. `tools/verify_all.sh` deletes old output, extracts again, builds the ROM and checks every segment; it ends with `ALL MATCH`.

## 3. Work loop

Every row of the ROM map is matched. The next work is the finish plan in `docs/align95_plan.md`: names, then symbols and comments, inside the files that already exist (`PROMPT.md`). Do not put a `dc.b` dump back in place of an `incbin`, and do not add a numbered `code96` or `data96` file. After a change: MATCH, commit, push, update `docs/HANDOFF.md`. Game-mechanics notes: `docs/difficulty_skill.md` (96 options skill level).

## 4. When stuck

- A name or change that cannot be made without changing bytes: leave it and list it with the reason in `docs/HANDOFF.md`.
- 5 failed builds in a row: `git checkout -- <file>` back to the last MATCH state and note what was tried.
