LPC Revised exterior tilesets, downloaded 2026-11-06 from
https://opengameart.org/content/lpc-revised-fully-configured-4-seasons-tilesets-for-tiled-map-editor (JaidynReiman's
compilation of Eliza Wyatt's LPC Revised, https://github.com/ElizaWy/LPC). OGA-BY 3.0 / CC-BY 3.0; every artist is
credited in LPC_CREDITS.csv.
- lpc-tileset-terrain-<season>.png: 2048 x 2048, 64 x 64 tiles of 32 px, the same layout every season -> TS_lpcr_<season>
  (tools/rooms/tileset_import.js); the game swaps them with the season (scripts/ground)
- *.tsx: their Tiled data; tools/map/lpcr_wang.js turns the "Summer Terrain" corner set into wang.json, which
  tools/rooms/build.js (lpcrGround) uses to draw the outdoor ground
- cut/waterfall_<down|left|right>.png: the waterfall animations (4 frames x 4 seasons) cut from the sheets ->
  spr_waterfall_* (obj_waterfall)
- lpc-tileset-buildings.png: not used yet (reference)
Used in the game: grass, dirt, sand, shallow and deep water (the ground), plank bridges (river crossings), the wooden
fence (the north-west coast), waterfalls (the mountain stream).
