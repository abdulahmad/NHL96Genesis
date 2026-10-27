# NHL 96 Genesis

> **Making a mod, hack, port or other derivative work from this repo? You must credit me (abdulahmad) and everyone credited in this repo, clearly, in your own repo and in every release. See [Credits and derivative works](#credits-and-derivative-works).**

See [CONTRIBUTING.md](CONTRIBUTING.md) for how changes are made (names, comments, layout, verification).

> **Work in progress:** this disassembly is unfinished and unpolished, and is being actively worked on. Expect labels, file layout and docs to change.

## 🚧 Current Status

- Still very raw.
- StaticEck is taking it on and cleaning it up.

Bitwise rebuild of NHL 96 for the Sega Genesis, in the style of [NHL95Genesis](https://github.com/abdulahmad/NHL95Genesis). The full build is byte for byte the retail ROM (SHA-1 `7204633fbb9966ac637e7966d02ba15c5acdee6b`); each segment also builds and verifies on its own. Every segment is source. Pictures, the sound bank and the scout text are `incbin`s of `Extracted/NHL96/`, written by `tools/extractAssets96.js` (`SEGMENT_AGENT.md`).

Start with `START_HERE.md` (setup, build, contributor workflow), then `SEGMENT_AGENT.md` (rules and the ROM map queue) and `PROMPT.md` (the per-segment prompt).

| Path | What it is |
| --- | --- |
| `lst/nhl96.bin`, `lst/nhl96.bin.lst` | The reference ROM (2 MB) and its IDA listing (ASM68K / MRI mode, no address column). |
| `src/nhl96.asm` | Top level: the equates, `org 0`, every segment in ROM order with its start address, the `$FF` fill. |
| `src/<segment>.asm`, `src/engine/`, `src/front/` | One file per segment, no `org`. A second piece of a 95 file has a suffix. |
| `src/stubinc/` | `<segment>_stub.asm` (org, equates, outside addresses, the segment) plus `ports.inc` and `equals.inc` (from 95G). |
| `src/ram96.asm`, `src/externs96.asm` | RAM map. `externs96.asm` is included by the build and holds no equates. |
| `tools/` | `prebuild.js`, `extractAssets96.js`, `segmap96.json`, `make_segmap96.py`, `find95.py`, `fixopcodes.js`, `verifyRom.js`, `verifySegment.js`, `build_rom.sh`, `verify_segment.sh`, `verify_all.sh`. |
| `docs/` | `HANDOFF.md`, `name_map.csv`. |

Build: Windows `npm run build:retail` / `npm run seg:<name>`; Linux with wine `tools/build_rom.sh` / `tools/verify_segment.sh <name>` / `tools/verify_all.sh`. Logs go to `output/`.

## AI assistance

This project is AI-assisted. The work is directed by a strict ruleset and curated by hand, with the aim of producing correctly labelled and commented code that matches the spirit of what the original source code would have been. We can't guarantee it's perfect, and ultimately this will always be a work in progress. If you see something that needs fixing, raise an issue, or even better, raise a PR.

## Credits and derivative works

Thanks to chaos, StaticEck, McMarkis and Drezz for their help with the disassembly.

Special thanks to smozoma and kingraph, whose past contributions to the NHL modding community made this work easier.

This project is the result of my work (abdulahmad) and the work of the people credited above. If you build anything from it, including mods, ROM or EXE hacks, ports, released forks, tools, or any other derivative work, you must credit us:

- Put the credit in your repo's README, near the top and not buried in a footer, and in the notes of every release you publish, including any text file shipped inside a release archive.
- Name me (abdulahmad) and link to this repository.
- Name everyone credited here: chaos, StaticEck, McMarkis (Mhopkinsinc) and Drezz, with special thanks to smozoma and kingraph.
- If you only use part of this repo (docs, a tool, labels, a file format description), the credit still applies.
- If you are unsure, over-credit.

Credit is the condition for using this work. Please do not release a derivative without it.
