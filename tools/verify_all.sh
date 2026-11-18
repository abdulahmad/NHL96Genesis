#!/bin/bash
# verify_all.sh: clean check under wine: fresh extract, the full ROM.
# Usage: tools/verify_all.sh [-q|--quiet]   (from anywhere; works in the repo root)
# -q: print only failures and the final ALL MATCH line.
# Writes every log to output/: verify_all.log (this summary), prebuild.log, top.log,
# and the assembler log Build96.log. Exit status 1 if anything is not MATCH.
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
n=$(python3 tools/check_code_as_data.py --rom output/obj/nhl96.bin 2>&1 | tail -1); say "code as data (not a failure yet): $n"
say "$( [ $fail = 0 ] && echo 'ALL MATCH' || echo 'FAILURES: see above')"
exit $fail
