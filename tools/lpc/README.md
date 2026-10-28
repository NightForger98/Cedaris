# LPC character art pipeline

Rebuilds the `lpc_*` sprites, the `lpc_pal_*` palettes and `scripts/lpc_catalog` from the
[Universal LPC Spritesheet Character Generator](https://github.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator).

Art is stored the way the palette shader (`shd_lorikeet`) expects: each pixel's grey level is a position
along a palette strip, so one sprite can be drawn in any colour. Pixels that aren't part of a colour ramp
(eye whites, gems, outlines) go on a separate `_fix` sprite that is drawn in its original colours.

## Steps

Run from Git Bash. Work in a scratch folder (`$W` below), not inside the project.

1. Get the generator's definitions (about 7 MB):
   ```bash
   git clone --filter=blob:none --no-checkout --depth 1 https://github.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator.git $W/lpc
   cd $W/lpc && MSYS_NO_PATHCONV=1 git sparse-checkout set --no-cone '/sheet_definitions/' '/palette_definitions/' '/CREDITS.csv' && git checkout master
   git ls-tree -r --name-only HEAD spritesheets > $W/tree.txt
   ```
2. Map items to creator slots and list the art needed: `python -I plan.py $W/lpc $W/tree.txt $W/out`
   (slot mapping is the `SLOT` table at the top of `plan.py`).
3. Download only that art (about 20 MB):
   ```bash
   (printf '/sheet_definitions/\n/palette_definitions/\n'; cat $W/out/files.txt) | MSYS_NO_PATHCONV=1 git -C $W/lpc sparse-checkout set --no-cone --stdin
   ```
4. Parse the custom (oversized) tool and weapon animations, then write the conversion jobs:
   ```bash
   git -C $W/lpc show HEAD:sources/custom-animations.ts > $W/custom-animations.ts
   python -I custom_anims.py $W/custom-animations.ts $W/out
   python -I jobs.py $W/out $W/lpc
   ```
5. Convert (assembles universal sheets and palette-indexes them):
   `powershell -File convert.ps1 -Jobs $W/out/jobs.txt -OutDir $W/sheets > $W/convert_log.txt`
6. Write everything into the project (close GameMaker first):
   `python -I finalize.py $W <project folder> $W/lpc`
   (`finalize.py` expects `out/`, `sheets/` and `convert_log.txt` inside `$W`. It reuses existing sprite ids, so
   unchanged sprites produce no git changes.)

Then run `./build.sh` from the project folder.

## Licences

LPC art is CC-BY-SA 3.0, GPL 3.0 and/or OGA-BY 3.0, depending on the piece. `LPC_CREDITS.csv` in the
project root lists the authors and licences for every piece used; the game's credits must include them.
After adding rows to it (e.g. art from outside the generator, like the mine monsters), regenerate the credits
screen's list with `python -I tools/lpc/credits_gml.py .` or, without Python, `node tools/lpc/credits_gml.js .`.
