# NHL 96 Genesis

> **📀 Game data is not included.** This repository has the assembly code only. The graphics, team palettes, sound samples, music and the NHLPA player names and NHL team nicknames are extracted from your own copy of the original ROM when you build, and are not in the repo. You need the NHL 96 Genesis ROM in the repo folder (any file name; it is found by SHA-1 `7204633fbb9966ac637e7966d02ba15c5acdee6b` and size), or the build stops.

> **🤝 Making a mod, hack, port or other derivative work from this repo? You must credit me and everyone credited in this repo, clearly, in your own repo and in every release. See [Credits and derivative works](#credits-and-derivative-works).**

See [CONTRIBUTING.md](CONTRIBUTING.md) for how changes are made (names, comments, layout, verification).

> **Work in progress:** this disassembly is unfinished and unpolished, and is being actively worked on. Expect labels, file layout and docs to change.

## 🚧 Current Status

- Still very raw.
- StaticEck is taking it on and cleaning it up.

Reverse engineered source of NHL 96 for the Sega Genesis, in the style of [NHL95Genesis](https://github.com/abdulahmad/NHL95Genesis). The full build is byte for byte the retail ROM (SHA-1 `7204633fbb9966ac637e7966d02ba15c5acdee6b`); every segment is source. Pictures, the sound bank and the scout text are `incbin`s of `Extracted/NHL96/`, written by `tools/extractAssets96.js`.

Start with `AGENTS.md` (working rules), then `docs/RULES.md` and the Now block of `docs/HANDOFF.md`. Outside contributors: fork the repo, work on a branch (every commit must MATCH) and open a PR against `main`.

| Path | What it is |
| --- | --- |
| `nhl96retail.bin` (any file name), `lst/nhl96.bin.lst` | The reference ROM (2 MB, in the repo folder, found by its SHA-1 and size) and its IDA listing (ASM68K / MRI mode, no address column). Local files: neither is in the repo (gitignored). |
| `src/nhl96.asm` | Top level: the equates, `org 0`, every segment in ROM order with its start address, the `$FF` fill. |
| `src/engine/`, `src/front/` | Gameplay and in-game code in `engine/`, everything outside a game in `front/`. A file with several pieces has its own folder (`engine/logic/logic96.asm`, `engine/logic/puck.asm`). One file per segment, no `org`. |
| `src/*.asm` | Glue at the root: `nhl96.asm` (the ROM map), `main96`, `ram96`, `sram96`, `frames96`, `teamdata96`, `checksum96`, `graphics96`. |
| `src/inc/` | `ports.inc` and `equals.inc` (from 95G). |
| `src/ram96.asm`, `src/externs96.asm` | RAM map. `externs96.asm` is included by the build and holds no equates. |
| `tools/` | `build.js`, `roms.js`, `prebuild.js`, `extractAssets96.js`, `segmap96.json`, `make_segmap96.py`, `find95.py`, `fixopcodes.js`, `verifyRom.js`, `build_rom.sh`, `verify_all.sh`; code-as-data checks `check_code_as_data.py` and `decode_code.py`. |
| `docs/` | `HANDOFF.md`, `RULES.md`, `name_map.csv`, `difficulty_skill.md`, `EXPANDING_THE_ROM.md`; finished plans in `docs/archive/`. |

Build: Windows `npm run build:retail` (`assembler\Assembler.exe` is SNASM68k). Linux / macOS with wine (Debian / Ubuntu:
`sudo dpkg --add-architecture i386 && sudo apt update && sudo apt install wine wine32`): `tools/build_rom.sh`, or `tools/verify_all.sh`
for a clean extract, build and check that ends with `ALL MATCH`. Node.js is needed for the prebuild check, extractor and verify tools,
Python 3 for `tools/make_segmap96.py`. The prebuild check (`tools/prebuild.js`) checks the ROM and extracts `Extracted/NHL96/` when it
is missing or stale. The last line of a build must be `MATCH`; on a fresh clone, if it is not, stop and report the output. Logs go to
`output/`.

## AI assistance

This project is AI-assisted. The work is directed by a strict ruleset and curated by hand, with the aim of producing correctly labelled and commented code that matches the spirit of what the original source code would have been. We can't guarantee it's perfect, and ultimately this will always be a work in progress. If you see something that needs fixing, raise an issue, or even better, raise a PR.

## Credits and derivative works

Thanks to chaos, StaticEck, McMarkis and Drezz for their help with the disassembly.

Special thanks to smozoma and kingraph, whose past contributions to the NHL modding community made this work easier.

And thank you to the [original developers of the game](https://www.mobygames.com/game/59995/nhl-96/credits/genesis/).

This project is the result of my work and the work of the people credited above. If you build anything from it, including mods, ROM or EXE hacks, ports, released forks, tools, or any other derivative work, you must credit us:

- Put the credit in your repo's README, near the top and not buried in a footer, and in the notes of every release you publish, including any text file shipped inside a release archive.
- Name me and link to this repository.
- Name everyone credited here: chaos, StaticEck, McMarkis (Mhopkinsinc) and Drezz, with special thanks to smozoma and kingraph.
- If you only use part of this repo (docs, a tool, labels, a file format description), the credit still applies.
- If you are unsure, over-credit.

Credit is the condition for using this work. Please do not release a derivative without it.
