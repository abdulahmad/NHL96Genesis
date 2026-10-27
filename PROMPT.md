> **Agents:** read [AGENTS.md](AGENTS.md) first. Any derivative work built from this repo must credit me (abdulahmad) and everyone credited in the README.

# Segment prompt

Paste this into a new agent session. Do not edit this prompt.

```text
Read START_HERE.md and SEGMENT_AGENT.md before you write any asm. Every row of the ROM map is matched. This session works inside files that already exist: names, symbols, comments. Do not replace an incbin with a dc.b dump, and do not add a numbered code96 or data96 file.

NHL 96 Genesis follows NHL 95 Genesis. Folders match 95G (engine/, front/, sega/, stubinc/, macros/, and ROM-wide files in src/). src/nhl96.asm is a flat include list in 96 ROM order. There is no engine96.asm or front96.asm. A second piece of a 95 file has a suffix on the 95 name. A guest of a few routines stays in the host file. Bytes do not move into an earlier file.

Names follow the lineage in the Current rules section of SEGMENT_AGENT.md: a routine that matches 95G takes its 95G name (clash rule applies), else 94G, else 93G, else 92G, else a name from what the code does. The reference repos are public GitHub repos listed in START_HERE.md (read them on GitHub; no clone needed). The Unsure list in docs/HANDOFF.md and docs/align95_plan.md is closed: do not rename those, and do not invent a name for an address that has none.

tools/prebuild.js runs tools/extractAssets96.js. Graphics, the Z80 program, each sound-bank item and the scout text are incbins of Extracted/NHL96/. Paths in source are relative to src/ (..\Extracted\...). A map is one incbin; the tiles are the label plus eight. tools/extractSegments96.js is not part of the build. tools/segmap96.json is the ROM map.

What is left is the finish plan in docs/align95_plan.md, in this order. A generic label is finished when it has a real name in the source and in docs/name_map.csv, or a closed-list row with the reason.
1. Decoded routines, one file per commit. lines96_set first (name each routine from the job; there is no 95G body). Then display96, title96, penalty96, playoff96, trade96 (check trade95), and the files with one or two labels. Name a nullsub_ only when its callers share one job.
2. season96. New in 96, no 95G byte match. Name a screen only when the text, the vblank, or the menu shows which screen it is.
3. dc.b entries (logic96, create96, logic96_vec, trade96_edit, and the remaining blobs). Name the entry from the caller or a 95G body. Decode an instruction only when each opcode is checked against the ROM.
4. One more 95G body search on the labels that are still generic. Take a name only when the body matches. $02032C stays unnamed: rtss2 is already the shared rts in collide96.
5. Graphics unk_ labels, including unk_88A18. Rename one only when the picture matches a 95G asset by more than the map header, or one caller already says what it is. Update extractAssets96.js, the incbin, and the extracted file, then MATCH. A header-only lookalike stays unk_.
6. A RAM name still word_FF / byte_FF / unk_FF, only when a converted use matches a 95G RAM name by what the code does. Do not rename from the address alone.
7. Symbols and immediates that 95G writes as a name (SPA* / SPF*, a RAM field, a team equate, an SFX_* id) and 96G still has as hex. Only where the bytes do not change. The player-struct fields past $60 are a separate step: confirm the one-byte shift against 95G first.
8. Docs, as each item closes. SegaInit locals are already in src/sega/SegaInit.asm and in docs/name_map.csv. Do not invent a second copy. code96_14 and code96_15 stay numbered. SetSframe stays until it is compared with 95G SetSframe and AddSpriteFrame.

1. Build first (Windows: npm run build:retail; Linux: tools/build_rom.sh). It must print MATCH before you change anything. If it does not, stop and report.
2. Open the file you are editing and lst/nhl96.bin.lst for that range. Do not disassemble lst/nhl96.bin yourself and do not write a disassembler.
3. Find the matching 95G code: python3 tools/find95.py <segment> lists the 95G labels found in the range by their bytes; 95G docs/name_map.csv has every 95 label and address; compare with the 95G source. Where the 96 routine matches, take the 95G names, comments and local labels; where it does not, name it from what it does.
4. A label in another file is an equate in your stub, src/stubinc/<segment>_stub.asm. RAM names go in src/ram96.asm. src/externs96.asm holds no equates: every segment is source.
5. Follow the style rules (no history, provenance or origin-tag comments, no ROM addresses in comments, no derived counts; history goes in docs/name_map.csv).
6. Build after each batch of edits: the segment (npm run seg:<segment> / tools/verify_segment.sh <segment>) and the full ROM, or tools/verify_all.sh when a file, a stub, the ROM map or an include changes. Both must print MATCH, and a segment MATCH must cover its whole range. A docs-only edit does not change bytes; still do not commit Extracted/ or output/.
7. Record a rename in docs/name_map.csv (address, name, ida_name, old_name, module). Update docs/HANDOFF.md. Commit (one concern, MATCH in the message) and push to main (outside contributors: push to your fork and open a PR, see START_HERE.md).

Stop after 5 failed builds in a row. Report the file, the first differing ROM offset, the built byte, the retail byte, and the line you wrote. Do not continue.
```
