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
  - Interiors are built from specs too (`tools/rooms/interior.js`); only the mine and Whisperwood are generated.
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

- **Farm** (`rm_1`, 60x40): the cliff along the north with the ladder up to town and the mine's cave, a yard with
  your workbench by it; farmhouse in the west; the field in the middle; pond in the north-east; fenced pasture in
  the south-east; woods along the south with a path through them. Roads east (village) and west (coast). Only you
  live here; villagers cross it on their way between places.
- **Farmhouse** (`rm_12` downstairs: kitchen, dining room, the hearth; `rm_123` upstairs: your bedroom -
  `BED_ROOM`, you wake up there). Furnished stamps from the first versions; all furniture is under the player and
  solid over its art.
- **Village** (`rm_2`, 56x50): the hall on a cobbled square (notice board), the river with the bridge to
  Whisperwood. Houses (`rm_village_*`): Elda's (north-west, potion sign), Brom's smithy (sword sign; the furnace is
  inside) and Mara's general store on the lane south of the square, and on a second lane below, Aunt Hesta and
  Tobin's house and Rowan's.
- **Brindlemoor** (`rm_town`, 64x44): the town hall over a big market square, six houses; Garrick the watchman.
  Every door leads inside (`rm_town_*`, built with `tools/rooms/interior.js`): the hall is the Brindle Inn (Lysa sells
  a daily menu of meals), the sword sign Bryn's Outfitters (clothes and armour that fit you), the potion sign Morga's
  Apothecary (Heal and Fireball scrolls, staves, forage, tonics); the other four are homes.
- **Saltmere Coast** (`rm_beach`, 48x40): sea, a beach, a pier to fish from (sea fish); Old Marlo's hut by the
  road (`rm_beach_hut`).
- **Hollow Vale** (`rm_valley`, 60x44): Wren's ranch at the top of the path (`rm_valley_ranch`: livestock; Pip
  works and lives there too), Thorne's carpentry in the woods east of the path (`rm_valley_carpentry`: timber and
  stone; Rowan works its yard), a river with a bridge, a lake (river fish), wood and forage on both banks.
- The world map (M in game) is `spr_world_map` and `scripts/world_map`, made by `node tools/rooms/worldmap.js` from
  the built rooms (run it again after changing an outdoor room): rooms laid out as their exits join, every building
  with a door, and where each indoor room's door is.

### People and their days

Everyone lives somewhere and goes about a day (`villager_routines` in `scripts/schedules`), as in Stardew Valley and
Harvest Moon. Each stop is an hour and a named spot; they set off at that hour and walk there through the rooms'
doors (routes found at runtime over `scripts/room_walk`, which the room builder writes), so a shopkeeper who opens
at 9 leaves home at 8 and gets in around 9. A shop only trades while its keeper is behind the counter, in hours;
otherwise T in their dialogue gives the hours. Each has a day off with its own routine. On a festival day everyone
is in the village crowd instead. On a rainy day most stay in (anything outdoors becomes home), except
the `rainproof`: Marlo fishes, Garrick keeps watch, Pip minds the sheep, Hask hunts, and Elda loves the rain.
Seasons change some weeks (`seasons` in `villager_routines`): summer days at the beach for the children, Thorne's
evening swims, Elda mushrooming in the vale in fall, Posy's winter flower stall at the inn, Marlo by the inn's fire in
winter, Aunt Hesta's spring seed shopping - and in winter nobody lingers outdoors after 5pm.
Heart events (`scripts/heart_events`): ten short scenes with a friend, met in the right place and hours with enough
hearts; some end with a choice that matters to them, some with a gift.
Doors lock: homes while their people sleep (9pm - 8am), shops outside hours and on their day off - unless you have
2 hearts with someone who lives or works there (`door_lock_reason`). Villagers step around you and each other.

| Shop | Keeper (lives) | Hours | Closed | Day off |
| --- | --- | --- | --- | --- |
| Wren's Ranch (livestock) | Wren (the ranch) | 8am - 4pm | Tuesday | groceries at Mara's, the village square |
| Brom's Smithy (tools, upgrades, furnace) | Brom (the smithy) | 9am - 5pm | Thursday | fishing off the pier, the inn |
| Thorne's Carpentry (timber, stone) | Thorne (the carpentry) | 9am - 5pm | Sunday | the river, the square, Brom's |
| Mara's General Store (seeds) | Mara (the store) | 9am - 6pm | Wednesday | Bryn's, the town square, Elda's |
| Morga's Apothecary | Morga (the apothecary) | 10am - 6pm | Friday | herbs in the vale, Elda's, the inn |
| Bryn's Outfitters | Bryn (the outfitter) | 10am - 7pm | Saturday | Brom's, the square, Wren's ranch |
| The Brindle Inn (meals) | Lysa (the inn) | 10am - 10pm | Monday | Mara's, Wren's ranch, the squares |

Jobs without a counter: Ida bakes at the inn (6am - 1pm), Marlo fishes off the pier (6am - noon), Pip minds Wren's
sheep (7am - 4pm), Hask hunts across the vale's river (7am - 3pm), Garrick keeps watch at the top of the town's
street (8am - 6pm), Nell weaves at home (8am - 2pm, then takes cloth to Bryn), Posy sells flowers in the town square
(9am - 5pm), Edwin keeps the village notices (9am - 3pm), Rowan works Thorne's yard (9am - 5pm). Elda (herbs by the
river and in the vale), Aunt Hesta (Mara's, then the square) and the children Tobin and Fen (the squares, together
after noon) keep the same day every day. Evenings, many end up at the inn; Lysa, Posy and Garrick lodge there.

## Generated rooms: the mine (roadmap phase 4)

- **Bosses and the Deep** (milestone 12): floors 10, 20 and 30 have a boss (`mine_boss`); the ladder down appears
  where it falls. Below 30, once the Ember Drake is beaten, the Deep goes on for ever (band 4 in `mine_bands`).

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
