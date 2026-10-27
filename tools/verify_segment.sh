#!/bin/bash
# verify_segment.sh: build and check one segment under wine (Linux / macOS).
# Usage: tools/verify_segment.sh <name>      e.g. tools/verify_segment.sh main96
# Same steps as npm run seg:<name> on Windows: prebuild check, buildseg.bat, fixopcodes, verifySegment.
# Logs: output/seg_<name>.log and the assembler log output/Build_<name>.log. Last line MATCH or MISMATCH.
cd "$(cd "$(dirname "$0")/.." && pwd)" || exit 1
s=$1; [ -n "$s" ] || { echo "Usage: tools/verify_segment.sh <name>"; exit 1; }
org=$(node -e "const c=require('./package.json').scripts['seg:$s']; if(!c){console.error('no seg:$s in package.json');process.exit(1)} console.log(c.match(/verifySegment.js \S+ (\S+)/)[1])") || exit 1
export WINEDEBUG=-all NHL_PREBUILD_DONE=1
mkdir -p output; log=output/seg_$s.log
node tools/prebuild.js retail >$log 2>&1 || { cat $log; exit 1; }
rm -f output/$s.bin output/modified_$s.bin
wine cmd /c "buildseg.bat $s" >>$log 2>&1
if [ ! -s output/$s.bin ] || grep -qP '^[1-9]\d* error' output/Build_$s.log; then
  echo "ASSEMBLY FAILED: see output/Build_$s.log"; grep -iE 'error' output/Build_$s.log | head -20; exit 1; fi
node tools/fixopcodes.js "output/$s .lst" output/$s.bin >>$log 2>&1
node tools/verifySegment.js $s $org retail 2>&1 | tee -a $log
exit ${PIPESTATUS[0]}
