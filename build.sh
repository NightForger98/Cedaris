#!/usr/bin/env bash
# Build the project from the command line with GameMaker's Igor tool.
#
#   ./build.sh          compile + package a Windows zip (checks the code compiles)
#   ./build.sh run      compile and launch the game
#   ./build.sh clean    delete the build cache
#
# Overrides: GM_RUNTIME (runtime folder), GM_USER (user folder holding licence.plist)
# Output goes to build/ (git-ignored); the full log is build/last_build.log.

set -u
cd "$(dirname "$0")"

PROJECT="$(ls *.yyp | head -n1)"
GM_DATA="${GM_DATA:-/c/ProgramData/GameMakerStudio2-LTS2026}"
GM_APPDATA="${GM_APPDATA:-$APPDATA/GameMakerStudio2-LTS2026}"

# Newest installed runtime
RUNTIME="${GM_RUNTIME:-$(ls -d "$GM_DATA"/Cache/runtimes/runtime-* 2>/dev/null | sort -V | tail -n1)}"
IGOR="$RUNTIME/bin/igor/windows/x64/Igor.exe"
[ -f "$IGOR" ] || { echo "Igor not found under $RUNTIME"; exit 2; }

# A signed-in user folder (has a non-empty licence.plist)
USER_DIR="${GM_USER:-}"
if [ -z "$USER_DIR" ]; then
  for d in "$GM_APPDATA"/*/; do
    [ -s "$d/licence.plist" ] && { USER_DIR="${d%/}"; break; }
  done
fi
[ -n "$USER_DIR" ] || { echo "No licence found in $GM_APPDATA - sign in to GameMaker once, then retry."; exit 2; }

win() { cygpath -w "$1"; }
# Igor packages everything in the output folder, so keep the log and cache out of it
rm -rf build/out
mkdir -p build/out
LOG=build/last_build.log

case "${1:-check}" in
  clean) rm -rf build/cache build/temp; echo "Cache cleared."; exit 0 ;;
  # Run must not get a target file, or the game tries to load it as its data file
  run)   CMD="Run"; OUT=() ;;
  check) CMD="PackageZip"; OUT=(--of="$(win "$PWD/build/out/HarvestValley.zip")" --tf="HarvestValley.zip") ;;
  *)     echo "Usage: ./build.sh [check|run|clean]"; exit 2 ;;
esac

# The tilesets' padded sheets must match their .yy (the IDE writes them; a fresh clone has none)
node tools/rooms/output_tileset.js || { echo "BUILD FAILED: tileset sheets"; exit 1; }

# The compiler lets calls to missing functions through (they fail only when the line runs): catch them first
node tools/check_calls.js "$(win "$RUNTIME")" || { echo "BUILD FAILED: unknown functions (see above)"; exit 1; }

echo "Runtime: $(basename "$RUNTIME")   Command: Windows $CMD"
"$IGOR" -j=8 \
  --project="$(win "$PWD/$PROJECT")" \
  --user="$(win "$USER_DIR")" \
  --runtimePath="$(win "$RUNTIME")" \
  --cache="$(win "$PWD/build/cache")" \
  --temp="$(win "$PWD/build/temp")" \
  "${OUT[@]}" \
  -- Windows "$CMD" > "$LOG" 2>&1
STATUS=$?

# Compiler errors look like "Error : gml_Object_x_Step_0(12) : ..." or "... FAILED"
ERRORS="$(grep -iE 'error|failed|exception' "$LOG" | grep -viE '^\s*(options|loaded)|0 error' )"
WARNINGS="$(grep -E '^Warning' "$LOG")"
[ -n "$WARNINGS" ] && { echo "Warnings:"; echo "$WARNINGS"; }
if [ -n "$ERRORS" ] || [ $STATUS -ne 0 ]; then
  echo "BUILD FAILED (exit $STATUS):"
  echo "${ERRORS:-$(tail -n 30 "$LOG")}"
  exit 1
fi
echo "BUILD OK - see $LOG"
