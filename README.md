# NHL 96 Genesis

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

## Credits

Thanks to chaos, StaticEck, McMarkis and Drezz for their help with the disassembly.

Special thanks to smozoma and kingraph, whose past contributions to the NHL modding community made this work easier.
