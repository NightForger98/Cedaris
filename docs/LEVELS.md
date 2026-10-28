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

- Designed, not generated: each room is a spec in `tools/rooms/specs/` (a text map of the ground, plus the
  buildings, trees, props and instances placed on it) that `node tools/rooms/build.js <room>` turns into the room
  file. See `tools/rooms/README.md`. The farm (`rm_1`) and the village (`rm_2`) are built this way.
  - **Why a spec rather than the room editor**: a layout is reviewable text, the builder does the fiddly parts
    (autotiled edges, collision boxes that match the art, water zones, roofs and tree tops over the player), and
    Claude can design and change rooms without the editor. The ground is still placed by hand, cell by cell:
    the builder only picks which edge tile each cell needs.
  - The room editor is still fine for a room that isn't built from a spec (interiors so far).
- Before a room is built: a short brief (size, exits, who lives there, what spawns where, what it's for), then the
  map. Named spots go in the spec's `points`/`areas` (`scripts/room_layout`), so scripts never hard-code positions.
- Every built room gets an autotest (`tools/test/cases/built_rooms.txt`): walk it, use its exits, screenshot it.
- Life comes from runtime systems, not more rooms: trees, rocks and weeds spawn in each room's areas
  (`resource_areas()` in `scripts/gathering`), crops grow, NPCs walk about.

### The world so far

The farm is the middle of the map; a way out on each side:

```
                     Brindlemoor (rm_town)
                            | ladder up the cliff
  Saltmere Coast  ----   The Farm (rm_1)   ----  Village (rm_2)  ----  Whisperwood (rm_forest)
   (rm_beach)    road       |  door  \ cave         road            bridge (a village project)
                            |   rm_12 <-> rm_123   rm_mine
                     Hollow Vale (rm_valley)
                         path through the woods
```

- **Farm** (`rm_1`, 60x40): the cliff along the north with the ladder up to town and the mine's cave, Brom's
  smithy yard by it; farmhouse in the west; the field in the middle; pond in the north-east; fenced pasture in the
  south-east; woods along the south with a path through them. Roads east (village) and west (coast).
- **Farmhouse** (`rm_12` downstairs: kitchen, dining room, the hearth, Hesta and Tobin; `rm_123` upstairs: your
  bedroom - `BED_ROOM`, you wake up there). Furnished stamps from the first versions; all furniture is under the
  player and solid over its art.
- **Village** (`rm_2`, 56x36): the hall on a cobbled square (notice board), Elda's and Thorne's houses, the river
  with the bridge to Whisperwood.
- **Brindlemoor** (`rm_town`, 64x44): the town hall over a big market square, six houses; Garrick the watchman.
  Every door leads inside (`rm_town_*`, built with `tools/rooms/interior.js`): the hall is the Brindle Inn (Lysa sells
  a daily menu of meals), the sword sign Bryn's Outfitters (clothes and armour that fit you), the potion sign Morga's
  Apothecary (Heal and Fireball scrolls, staves, forage, tonics); the other four are homes.
- **Saltmere Coast** (`rm_beach`, 48x40): sea, a beach, a pier to fish from (sea fish); Old Marlo the fisher.
- **Hollow Vale** (`rm_valley`, 60x44): Wren the shepherd's hut, a river with a bridge, a lake (river fish), wood
  and forage on both banks.
- Next: people living in the town's homes. `rm_3` is an empty test room nothing leads to.

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
