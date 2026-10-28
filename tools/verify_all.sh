#!/bin/bash
# verify_all.sh: clean check under wine: fresh extract, the full ROM, then every seg:* segment.
# Usage: tools/verify_all.sh [-q|--quiet]   (from anywhere; works in the repo root)
# -q: print only failures and the final ALL MATCH line (the full per-segment summary still goes to output/verify_all.log).
# Writes every log to output/: verify_all.log (this summary), prebuild.log, top.log, seg_<name>.log,
# and the assembler logs Build96.log / Build_<name>.log. Exit status 1 if anything is not MATCH.
cd "$(cd "$(dirname "$0")/.." && pwd)" || exit 1
export WINEDEBUG=-all
mkdir -p output
quiet=0; case "$1" in -q|--quiet) quiet=1;; esac
sum=output/verify_all.log; : > $sum; fail=0
# say logs everything; in quiet mode it echoes only lines that are not "<name>: MATCH..." (ALL MATCH is printed by the last line).
say() { echo "$*" >>$sum; [ $quiet = 1 ] && [[ "$*" == *": MATCH"* ]] || echo "$*"; }
# tools/prebuild.js runs here with Linux node (fresh extract, ROM check); the .bat files skip it (no node under wine).
export NHL_PREBUILD_DONE=1
rm -rf Extracted; node tools/prebuild.js retail >output/prebuild.log 2>&1 || { say "PREBUILD FAIL (output/prebuild.log)"; cat output/prebuild.log; exit 1; }
rm -f output/obj/nhl96.bin output/obj/modified_nhl96.bin output/modified_nhl96.bin
wine cmd /c "set checksum=1&& build96.bat" >output/top.log 2>&1
grep -qP '^[1-9]\d* error' output/obj/Build96.log && { say "TOP ERRORS in output/obj/Build96.log"; fail=1; }
[ -s output/obj/nhl96.bin ] || { say "TOP NO BIN"; fail=1; }
node tools/fixopcodes.js "output/obj/nhl96 .lst" output/obj/nhl96.bin >>output/top.log 2>&1
mv -f output/obj/modified_nhl96.bin output/
r=$(node tools/verifyRom.js output/modified_nhl96.bin retail 2>&1 | head -1); say "ROM: $r"; [[ $r == MATCH* ]] || fail=1
for s in $(node -e 'for(const k in require("./package.json").scripts) if(/^seg:/.test(k)) console.log(k.slice(4))'); do
  org=$(node -e "console.log(require('./package.json').scripts['seg:$s'].match(/verifySegment.js \S+ (\S+)/)[1])")
  log=output/seg_$s.log; rm -f output/$s.bin output/modified_$s.bin
  wine cmd /c "buildseg.bat $s" >$log 2>&1
  if [ ! -s output/$s.bin ] || grep -qP '^[1-9]\d* error' output/Build_$s.log; then say "$s: ASSEMBLY FAILED (output/Build_$s.log)"; fail=1; continue; fi
  node tools/fixopcodes.js "output/$s .lst" output/$s.bin >>$log 2>&1
  r=$(node tools/verifySegment.js $s $org retail 2>&1 | tee -a $log | head -1); say "$s: $r"; [[ $r == MATCH* ]] || fail=1
done
say "$( [ $fail = 0 ] && echo 'ALL MATCH' || echo 'FAILURES: see above')"
exit $fail
