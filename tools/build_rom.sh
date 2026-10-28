#!/bin/bash
# build_rom.sh: full ROM build under wine (Linux / macOS), the same steps as npm run build:retail.
# Usage: tools/build_rom.sh          Logs: output/build_rom.log, output/obj/Build96.log. Last line MATCH or MISMATCH.
cd "$(cd "$(dirname "$0")/.." && pwd)" || exit 1
export WINEDEBUG=-all NHL_PREBUILD_DONE=1
mkdir -p output; log=output/build_rom.log
node tools/prebuild.js retail >$log 2>&1 || { cat $log; exit 1; }
rm -f output/obj/nhl96.bin output/obj/modified_nhl96.bin output/modified_nhl96.bin
wine cmd /c "set checksum=1&& build96.bat" >>$log 2>&1
if [ ! -s output/obj/nhl96.bin ] || grep -qP '^[1-9]\d* error' output/obj/Build96.log; then
  echo "ASSEMBLY FAILED: see output/obj/Build96.log"; grep -i error output/obj/Build96.log | head -20; exit 1; fi
node tools/fixopcodes.js "output/obj/nhl96 .lst" output/obj/nhl96.bin >>$log 2>&1
mv -f output/obj/modified_nhl96.bin output/
node tools/verifyRom.js output/modified_nhl96.bin retail 2>&1 | tee -a $log
exit ${PIPESTATUS[0]}
