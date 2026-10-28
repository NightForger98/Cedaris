# Level creation plan

How Harvest Valley's places get made. In short: the places people live in are designed by hand, and the
mine is generated while the game runs.

## Considered and not chosen: generating rooms ahead of time

One proposal was a tile-rules pipeline: Claude plans a layout, a Python WaveFunctionCollapse script fills it
with tiles from adjacency rules, and the result is written into `.yy` room files through the GameMaker CLI.
We're not doing that, because:

- **Towns and the farm need design, not texture.** Houses, doors, NPC spots and fields are deliberate. WFC
  gives believable surfaces, not places, so its output would be redrawn by hand anyway.
- **The place that needs generation is the mine**, and it should be different on every visit. Rooms baked
  into the project are always the same, and many of them bloat it.
- **This tileset doesn't suit adjacency rules.** `spr_tile_terrain` is mostly large multi-tile pieces
  (cliffs, houses, ponds, bridges), not a small interlocking edge set. WFC also can't promise a walkable
  path from entrance to exit without a repair step.
- **It adds Python** (not installed on the dev PC) for something GML can do.

## Hand-built rooms: farm, village, town, interiors

- Designed in the GameMaker room editor. Once the GameMaker MCP (`gm-cli resourcetool mcp`) is loaded in a
  session, Claude can place instances and tiles through it instead of hand-editing `.yy` files.
- Life comes from runtime systems, not more rooms: trees, rocks and weeds spawn in each room's areas
  (`resource_areas()` in `scripts/gathering`), crops grow, NPCs walk about.

## Generated rooms: the mine (roadmap phase 4)

- **One mine room**, rebuilt for each floor while the game runs. The entrance is the cave under the cliff
  on the farm (`rm_1`).
- **Layout**: a cave carved by cellular automata (random fill, then a few smoothing passes), or stitched
  from small hand-drawn chunks written as text grids. Then a flood fill checks the entrance can reach the
  ladder down; unreachable pockets are filled in or opened up.
- **Tiles** drawn with `tilemap_set` on tile layers made at Room Start: a wall with open floor below shows a
  cliff face, other walls dark rock, so there are no adjacency rules to maintain. An invisible tilemap of the
  walls is what the player and monsters collide with.
- **Contents** reuse what exists: rocks and ore veins from the gathering system (mine floors are just
  another kind of spawn area, with harder veins deeper down, which ties into the pickaxe tiers; mithril
  near the bottom), and monsters from the LPC look system (goblins, skeletons, trolls...).
- **Bands of floors** change the look and the finds: earth, ice (frost crystals), lava (ember cores), with
  a lift every 5 floors.
- **Seeded per floor**: the layout comes from the save's seed plus the floor number, so a floor looks the
  same when you come back. Its contents (rocks, ore, monsters) are rolled fresh on every visit, like Stardew,
  so nothing per floor is saved: only the seed, the deepest floor reached and the floor you're on.
- **Built** (step 7): `scripts/mine` (generation, bands, the lift), `scripts/combat` (weapons, monsters,
  knock-outs), `rm_mine`; entered from the cave on the farm (`obj_mine_door`).

## If WFC is wanted later

Run it in GML at runtime, on a small purpose-drawn set of 10-20 tiles, for organic cave floors inside the
generator above. It's an option for variety, not the pipeline.

## How Claude helps

Designing chunks and spawn tables, tuning numbers, and testing floors with `tools/test/autotest.sh` and
screenshots. Not a step in making every level.
