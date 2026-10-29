#!/usr/bin/env bash
# Rebuild the buildings in the packs' preview pictures from the packs' tiles (see decompose.js), for library.js.
#   tools/buildings/previews.sh
set -e
cd "$(dirname "$0")/../.."
O=build/buildings/dec; mkdir -p $O
C=art/lpc_thatched_cottage; W=art/lpc_windows_doors/windows-doors.png; D=art/lpc_medieval_decorations/decorations-medieval.png
K=art/lpc_colonial/colonial.png; F=art/lpc_farm/barn.png; BOX=art/lpc_containers/container.png
for p in preview-1_5 preview-2_3 preview-3_2 preview-4; do GROUND_CELLS=0 node tools/buildings/decompose.js art/lpc_colonial/previews/$p.png $O/$p.png $K $W $D; done
node tools/buildings/decompose.js art/lpc_farm/previews/farm-preview.png $O/farm-preview.png $F $D $BOX
for p in preview-market preview-cottage preview-village_0; do node tools/buildings/decompose.js art/lpc_medieval_decorations/previews/$p.png $O/$p.png $C/cottage.png $C/thatched-roof.png $W $D $BOX; done
node tools/buildings/decompose.js $C/preview_280.png $O/preview_280.png $C/cottage.png $C/thatched-roof.png $W
