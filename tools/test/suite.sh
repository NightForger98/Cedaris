#!/usr/bin/env bash
# Run every test case (or the ones named) and print a pass/fail table. Each case's log and screenshots are kept in
# build/suite/<case>/. Don't edit game code while it runs - each case recompiles.
#
#   tools/test/suite.sh                 all of tools/test/cases
#   tools/test/suite.sh mine deep       just these
set -u
cd "$(dirname "$0")/../.."
if [ $# -gt 0 ]; then CASES=("$@"); else CASES=($(ls tools/test/cases/*.txt | xargs -n1 basename | sed 's/\.txt$//')); fi
rm -rf build/suite; mkdir -p build/suite
PASS=0; FAILED=()
for n in "${CASES[@]}"; do
	tools/test/autotest.sh "tools/test/cases/$n.txt" > "build/suite/$n.out" 2>&1
	mkdir -p "build/suite/$n"; cp build/autotest/* "build/suite/$n/" 2>/dev/null
	R=$(tail -n 1 "build/suite/$n.out" | sed 's/^---- result: //')
	printf '%-22s %s\n' "$n" "$R"
	if [ "$R" = "PASS" ]; then PASS=$((PASS + 1)); else FAILED+=("$n"); grep -a 'FAIL\|ERROR' "build/suite/$n/log.txt" 2>/dev/null | head -5 | sed 's/^/    /'; fi
done
echo "---- $PASS / ${#CASES[@]} passed${FAILED[*]:+ - failed: ${FAILED[*]}}"
[ ${#FAILED[@]} -eq 0 ]
