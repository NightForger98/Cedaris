PixelLab terrain tilesets (2026-11-06, paid Tier 1 plan, commercial use allowed), made with tools/map/pl_tileset_gen.js:
each is a Wang corner set of 16 tiles, 32 px, of two terrains (lower / upper); <name>.json lists each tile's corners
(index k in the 4 x 4 sheet <name>.png).
- t_<season>_<ground> for spring, summer, autumn, winter: grass (snow in winter) with dirt lane, stone-brick road,
  sand, flagstone trail, concrete paving
- t_water_shore (shallow sea / sand), t_water_deep (deep / shallow), t_mountain_rock (grass / bare rock),
  t_mountain_snow (rock / snow)
NOT IN THE GAME YET: the rooms still use the LPC terrain. tools/world2/terrain_preview.js draws the ground with these
(dual grid) as a picture only; it needs more tile variety (one tile per terrain repeats), its gaps filled (corner
combinations without a tile draw black) and three-terrain corners handled before build.js can use it.
