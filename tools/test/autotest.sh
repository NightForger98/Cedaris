#!/usr/bin/env bash
# Run the game with a test script (see scripts/autotest) and collect its log and screenshots.
#
#   tools/test/autotest.sh tools/test/cases/gathering.txt
#
# The script should end with "quit". Results go to build/autotest/ (log.txt and <name>.png).
# Nothing is saved during a test run, so real save slots are safe.

set -u
cd "$(dirname "$0")/../.."
CASE="${1:?usage: tools/test/autotest.sh <case.txt>}"
SAVE_DIR="$LOCALAPPDATA/NewHarvest"
mkdir -p "$SAVE_DIR" build/autotest
rm -rf "$SAVE_DIR/autotest" build/autotest/*
cp "$CASE" "$SAVE_DIR/autotest.txt"

# Igor's Run returns when the game closes; stop it if a test hangs
timeout "${AUTOTEST_TIMEOUT:-300}" ./build.sh run
STATUS=$?
rm -f "$SAVE_DIR/autotest.txt"
cp -r "$SAVE_DIR/autotest/." build/autotest/ 2>/dev/null
echo "---- log"
cat build/autotest/log.txt 2>/dev/null || echo "(no log: the test didn't start)"
echo "---- screenshots"
ls build/autotest/*.png 2>/dev/null
exit $STATUS
