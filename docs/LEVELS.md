# Level creation plan

> **2026-11-05: the world was rebuilt** (branch `world-rebuild`): 25 outdoor rooms on a 5 x 5 grid laid out like Beirut,
> generated from data in `tools/world/world.js` (see `design/world_plan.md` for who lives where, the shops, the roads
> and the travel rules). The rooms, map and "who lives where" sections below describe the old world (the village,
> Brindlemoor, Hollow Vale, the coast, North/South Road, the Crossroads), which is archived on the developer's
> desktop. The approach below - designed rooms, a generated mine - still holds: the rooms are designed as data and
> laid out by a deterministic generator, not by tile rules.

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
  file. See "Room builder" in `CLAUDE.md`. Every room but the mine and Whisperwood is built this way.
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

The Crossroads sits in the middle of the map, where the farm used to be; the farm is at the foot of Hollow Vale:

```
 Saltmere       Brindlemoor (rm_town)  ----  North Road (rm_north): the cliff, the mine's cave (rm_mine)
  Coast               | main street      lane    | road, and the village river
 (rm_beach,           |                          |
  all the   ----  Crossroads (rm_cross) ----  Village (rm_2)  ----  Whisperwood (rm_forest)
  west     road       |                road      | road and river   bridge (a village project)
  side)               |                          |
    |          Hollow Vale (rm_valley)  -------  South Road (rm_south)
    |                 | path            lane above the river; the rivers join
    +---------- road below the river (the only way to the far south of the coast)
                      |
               The Farm (rm_1)   door: rm_12 <-> rm_123
```

Every road from one outdoor place to another has a signpost naming where it leads (`wayfinding`; placed at
Room Start from the rooms' exits, so a new road gets one by itself).

Buildings come from the building library (`tools/buildings`, tileset `TS_buildings`): the packs' preview pictures
rebuilt from the packs' own tiles, placed in a spec with `tools/rooms/house.js` (the thing, its door and the
interior's exit; `tools/rooms/sync_exits.js` points the interiors at their doorsteps).

- **Farm** (`rm_1`, 77x40), at the foot of the vale; a path comes down to the lane across it. The farmhouse in the
  west and the field in the middle (where they always were), the barn and silo in the north-east with the coop and
  granary round the pasture, the windmill and a beehive shed in the north-west, the pond in the west meadow, woods
  along the south. Farm pack buildings ([LPC] Farm). Only you live here.
- **Farmhouse** (`rm_12` downstairs: kitchen, dining room, the hearth; `rm_123` upstairs: your bedroom -
  `BED_ROOM`, you wake up there). Furnished stamps from the first versions; all furniture is under the player and
  solid over its art.
- **Crossroads** (`rm_cross`, 77x40): empty so far; the roads between the coast, the village, Brindlemoor and the
  vale. Villagers cross it on their way between places.
- **Village** (`rm_2`, 56x50): thatched cottages dressed with the medieval village decorations. The hall (twin
  cottages joined by a gateway) on a cobbled square (notice board, well), the river with the bridge to Whisperwood.
  Houses (`rm_village_*`): Elda's little cottage (north-west, potion sign), Brom's smithy (the long cottage with
  double doors, torches and a banner; the furnace is inside) and Mara's general store (market awnings) on the lane
  south of the square, and on a second lane below, Aunt Hesta and Tobin's L-shaped cottage and Rowan's.
- **Brindlemoor** (`rm_town`, 64x44): a colonial town ([LPC] Colonial Buildings) round a big cobbled square with a
  clock tower; Garrick the watchman. Every door leads inside (`rm_town_*`, built with `tools/rooms/interior.js`):
  the long brick hall with the clock tower is the Brindle Inn (Lysa sells a daily menu of meals), the bay-windowed
  shop Bryn's Outfitters (clothes and armour that fit you), the small brick house with the potion sign Morga's
  Apothecary (Heal and Fireball scrolls, staves, forage, tonics); the homes are Edwin's arched hall, Nell's
  clapboard house, Hask's brick house and Ida and Fen's gabled one. Posy's flower stall is in the square.
- **Saltmere Coast** (`rm_beach`, 48x153, the whole west side of the map): sea, a beach, a pier to fish from (sea
  fish); Old Marlo's cottage by the road to the Crossroads (`rm_beach_hut`). Woods line its east edge, open only for
  that road, the vale's river (which crosses the coast into the sea and cuts it in two) and the road from the vale's
  meadow below the river - the only way onto the far south of the coast.
- **Hollow Vale** (`rm_valley`, 77x65, its river running across): the path comes down from the Crossroads past
  Wren's ranch on the right (`rm_valley_ranch`, a long cottage with a wagon: livestock; Pip works and lives there
  too) and Thorne's carpentry on the left (`rm_valley_carpentry`, the L-shaped cottage: timber and stone; Rowan works
  its yard), over the river on a plank bridge to the wildflower meadow and on through the woods to the farm; a lake in
  the north-west (river fish), wood and forage on both banks. A lane east above the river to South Road; from the
  meadow below it, a road west to the far south of the coast.
- **North Road** (`rm_north`, 68x44): the cliff along its north edge (the ladder is scenery) with the cave into the
  mine, rocks and ore under it; a road from Brindlemoor's east lane down to the village's north road, and the village
  river coming up and bending away east (river fish).
- **South Road** (`rm_south`, 56x55): empty so far. The village's south road comes down and turns west into the vale's
  lane; the village river comes down the east side and turns west under it into the vale's river (river fish).
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
Doors lock: homes while their people sleep (9pm - 8am), shops outside hours and on their day off (roads and outdoor
places never lock) - unless you have 2 hearts with someone who lives or works there (`door_lock_reason`). Villagers step around you and each other.

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
  a lift car every 5 floors. The lift (at the cave, and in those cars) is an elevator like Stardew's: in story
  mode it goes to any floor you've reached, in free mode to any floor.
- **Seeded per floor**: the layout comes from the save's seed plus the floor number, so a floor looks the
  same when you come back. Its contents (rocks, ore, monsters) are rolled fresh on every visit, like Stardew,
  so nothing per floor is saved: only the seed, the deepest floor reached and the floor you're on.
- **Built** (step 7): `scripts/mine` (generation, bands, the lift), `scripts/combat` (weapons, monsters,
  knock-outs), `rm_mine`; entered from the cave on North Road (`obj_mine_door`, which is also the lift).

## If WFC is wanted later

Run it in GML at runtime, on a small purpose-drawn set of 10-20 tiles, for organic cave floors inside the
generator above. It's an option for variety, not the pipeline.

## How Claude helps

Designing chunks and spawn tables, tuning numbers, and testing floors with `tools/test/autotest.sh` and
screenshots. Not a step in making every level.
