# Harvest Valley (GameMaker LTS 2026)

This is the project's only README and handoff file. It has three parts: **README** (what the game is and how to run
it), **Handoff** (where work stands and what's next) and **Reference** (everything needed to work on it).

## README

**Harvest Valley** is a Stardew-like farming RPG. You inherit your grandmother's farm in a valley: grow crops, keep
animals, mine and fight down a generated mine, learn magic, fish, cook, craft and dye clothes, and befriend the people
of the village, the town of Brindlemoor, the coast and the vale, who live their own days.

- **Project**: `NewHarvest.yyp`. Repo: github.com/NightForger98/HarvestValley (branch `main`).
- **Run it**: open `NewHarvest.yyp` in GameMaker LTS 2026, or `./build.sh run` from Git Bash (see Reference).
- **Controls**: arrows move (Shift runs, Ctrl walks); left click or Space uses the held tool (hold to charge it);
  1-9, 0 pick the hotbar slot; E talks / uses (in a dialogue: G gives what you hold, T trades or tells you the shop's
  hours); I inventory; M world map; F casts with a staff, Q changes spell; Esc pauses; Insert toggles debug mode.
- **The world**: the Crossroads (`rm_cross`, a placeholder name) is the hub in the middle, where the farm used to be.
  Brindlemoor is north, the village east (Whisperwood beyond the river), the Saltmere Coast down the whole west side,
  Hollow Vale south, and the farm at the foot of the vale. North Road (the cliff and the mine's cave) is east of the
  town, South Road east of the vale. Map, layout and who lives where: `docs/LEVELS.md`.
- **Art**: LPC (CC-BY-SA / GPL / OGA-BY), credited in `LPC_CREDITS.csv`, in each pack's credits file in `art/`, and
  in game.

## Handoff

Last updated 2026-10-29: the world rebuild, the mine elevator and the art clean-up are done; all 44 test cases pass.

### Working with the user

- On question turns, answer only: no plans or recommendations until asked. When they do ask for a recommendation,
  act on it without asking again.
- When asked to plan, they want questions first, then implementation.
- When they say "stop", stop at once.
- They always choose **Reload** in GameMaker (never Save).
- End each step with a commit and push to `main`.

### Next steps

1. From the improvement list agreed with the user: quality of life (a real name for the Crossroads, settings such as
   volume and key rebinding, first-day hints, clear messages at locked doors), and normalising line endings (files
   mix LF and CRLF, which breaks exact-match edit scripts - strip `\r` before replacing).
2. The user hand-plays: charging feel, blessing prices, witch frequency, flame looks, walking times (the longest
   villager walk is 91 minutes; the world is much bigger now).
3. Deferred by the user: the temple for Father Aldous (the steepled `church` is in the library; its Friday sermon and
   hours are in `docs/CHARGING.md`), names and contents for North Road, South Road and the Crossroads.

### Done so far (history, newest first)

- **2026-10-29 - the art clean-up finished**: `library.js` fixes (`clear`, `fill`, `dropSpecks`: roof gaps on
  `brick_arch`, scraps cleared on the cottages, colonial houses, barn, the town stalls and the farm shed), tileset
  regenerated (no building changed size or door), the five outdoor rooms and the world map rebuilt. Interiors match
  their outsides (Brindlemoor: wallpaper and parquet/checker floors; cottages: stone walls and wood floors). Removed
  the 17 unused `spr_bld_*` sprites, `tools/buildings/make.js` and the unused stamps (`house_cream`, `house_thatch`,
  `house_cream_thatch`, `village_hall`), with their credit rows. GameMaker had re-saved the rooms and the `.yyp`
  (reordering only) - discarded and regenerated. `build/buildings/dec` is not in git: run
  `tools/buildings/previews.sh` before `library.js`. Unused props with leftover specks: `stall_green`, `stall_blue`,
  `obelisk` (clean them before placing one). All 44 test cases passed.
- **2026-10-29 (later)**: the mine's lift became an elevator like Stardew's - a floor picker at the cave, a lift car
  on every 5th floor (with Surface), story mode to floors you've reached, free mode anywhere (`mine_lift`). The user
  reported being stuck on the farm in free mode: `free_rooms` walks from the farmhouse out of every exit and round
  the Crossroads in free mode, and it all works - the farm's only way out is the path at the top (north to Hollow
  Vale), since the farm moved. The `mine` test now starts at the North Road cave.

- **2026-10-29 - the world rebuild** (pushed, up to "Open country in the Crossroads, North Road and South Road"):
  - Doors: outdoor rooms never lock (`door_lock_reason`); only houses and shops keep hours.
  - The world grew and moved: the coast runs the whole west side (48x153, a tree line, the vale's river crossing it
    into the sea, the far south reached only from the vale's road below the river); Hollow Vale is 77x65; South Road
    (`rm_south`) is new; the farm moved below Hollow Vale and was rebuilt with the farm pack (same farmhouse and
    field); the Crossroads sits in the farm's old place; the old farm cliff, ladder (scenery) and the mine's cave are
    on North Road's north edge.
  - Buildings come from the building library (see Reference). Brindlemoor is colonial; the village, vale and coast
    are thatched cottages with the medieval decorations.
  - Saves: versions 10 (rooms grew) and 11 (farm moved) upgrade old saves; loading onto a now-blocked spot steps out
    to the nearest free one (game Room Start).
  - Schedules: routes go through a room's walkable parts (`walk_region`), villagers set off to be at work 10 minutes
    early, `sched_problem` records unwalkable routes for the tests.
  - Tests: all 41 cases passed before the clean-up. New: `schedule_check`, `old_saves`, `perf`, `open_country`,
    `farm_moved`, `town_colonial`, `houses_rebuilt`, and `tools/test/check_areas.js` (spawn areas vs roads).
  - Open country: copses (`tools/rooms/woods.js`) and spawn areas in the Crossroads, North Road and South Road.
  - Credits for the house kit, the interior tileset, Base Assets, Farm, Medieval Village Decorations and Colonial
    Buildings - each pack with its credits file (and images where used) in `art/`.
- **Between the two handoffs**: doors lock at night and out of hours (friends at 2 hearts get in), villagers step
  around you and each other, rainy days keep most people in, the map shows the real Whisperwood, the unused
  `obj_npc_man` and `rm_3` are gone; seasonal schedule variants and heart events; milestone 12 (mine bosses, ranged
  monsters, the Deep); milestone 13 (charged tools and weapons, the witch, poison and curses, Father Aldous).
- **2026-10-28**: a new game no longer starts in Brom's furnace; the room builder; the farmhouse (bed upstairs),
  Brindlemoor and its interiors; villagers in everyday clothes; schedules (homes, jobs, days off, shop hours) and the
  world map. 21 test cases passed.

## Reference

### Build and test

- **Build / check**: `./build.sh` (Git Bash) compiles with GameMaker's Igor and prints compiler errors; `./build.sh run`
  launches the game. It needs GameMaker LTS 2026 installed and signed in once (it reads the licence from
  `%APPDATA%/GameMakerStudio2-LTS2026/<user>/licence.plist`). The compiler does not catch calls to unknown
  functions - check names against the runtime's `GmlSpec.xml` when using new built-ins.
- **GameMaker open while editing files**: it shows "Project Directory Modified" - choose **Reload**, never Save.
- **Testing**: `tools/test/autotest.sh tools/test/cases/<case>.txt` builds and runs the game with a test script
  (commands in `scripts/autotest`: start, pos, hold, use, give, time, room, call <function>, shot, `charge N [shot]`
  holds the use button, `snap N name` screenshots mid-action...) and copies its log and screenshots to
  `build/autotest/` - read the PNGs to check. Full suite:
  `for c in tools/test/cases/*.txt; do tools/test/autotest.sh $c; done` (don't edit game code while it runs - each
  case recompiles).
  - Simulated key presses don't reach `keyboard_check_pressed`, so keys a test needs go through `input_pressed()`;
    held keys (keydown / keyup, walking) go through `input_held()`, so they work even when the window lacks focus.
  - Test runs never write real saves (only a "test" slot). Autosave must never overwrite another game's save slot.
  - The user's settings may be fullscreen (`%LOCALAPPDATA%/NewHarvest/settings.ini`) - back it up and restore it if
    you switch to windowed for tests.
  - A new game starts on Monday at 6am: set `time` (and `call autotest_date`) so shops are open when a test needs them.
  - A runtime error shows a dialog and the test just times out with no message: wrap the suspect call in
    `try`/`catch` and `autotest_log` the exception to see it.
- **Debug mode in game**: Insert toggles it - PgUp/PgDn hop rooms, T skips an hour, G grows crops, position readout.

### GML gotchas hit before

- `all`, `id`, `score`, `pi`, `floor`, `y`, `power`, `solid` are built-ins (don't use as variable names; `solid` fails
  as "malformed assignment"); `crop` is an enum (in the crops object).
- `not` is a keyword - even as a struct key it crashes the compiler with "Stack empty", and so does an accessor on a
  parenthesised `??` (`(a ?? b)[$ k]`): put the `??` in its own variable first.
- `f()[$ g()[i]]` (an accessor on a call, keyed by an indexed call) crashes the compiler with a bare
  NullReferenceException: split it into two lines.
- `static` only works inside functions; JSON `null` may not load as `undefined`.
- `obj_plyr.layer` is -1 in some rooms (some rooms make the player at runtime): create instances on the "Instances"
  layer instead.

### Conventions

- Data tables over code (crops, materials, recipes, races, shop stock, schedules).
- Comment the why, match surrounding style; commit with a clear message and push to `main` when a step is done.
- LPC art licences (CC-BY-SA / GPL / OGA-BY): keep `LPC_CREDITS.csv`, the packs' credits files in `art/` and the
  in-game credits up to date (regenerate them with `node tools/lpc/credits_gml.js .` or
  `python -I tools/lpc/credits_gml.py .` after adding rows).
- Resource areas: new ones always go at the END of `resource_areas` (saves count regrowth by position).
- GameMaker's `.yy` reader needs keys in alphabetical order.

### Where things are

- `docs/ROADMAP.md` - the plan (farming, stats, combat, magic, social) with status per step; its 9 steps are done.
  `docs/MILESTONES.md` has what comes next. `docs/PROGRESSION.md` - items, materials, recipes, dyes, stats, and the
  hooks for quests. `docs/CHARGING.md` - charging, cursed and blessed tools, the witch, the priest and his temple.
- `docs/LEVELS.md` - **the level creation plan** (agreed): towns and the farm are designed rooms; the mine is
  generated at runtime in GML, seeded per floor. Not a WFC/Python pipeline - read why before proposing one. Also the
  world map, who lives where, and every shop's hours and day off.
- Rooms: `rm_0` boot, `rm_menu`, `rm_creator`, `rm_cross` the Crossroads (the hub), `rm_2` village (east), `rm_town`
  Brindlemoor (north), `rm_beach` (west), `rm_valley` Hollow Vale (south), `rm_1` the farm (below the vale),
  `rm_north` (North Road: east of the town, north of the village; the cliff and the mine's cave), `rm_south` (South
  Road: south of the village, east of the vale), `rm_12` farmhouse downstairs, `rm_123` upstairs (`BED_ROOM`),
  `rm_town_*` (the town's inn, outfitter, apothecary and four homes), `rm_village_*` (smithy, general store, three
  homes), `rm_valley_ranch`, `rm_valley_carpentry`, `rm_beach_hut`, `rm_mine`, `rm_forest`. Tilesets: `TS_terrain`,
  `TS_cottage` (house kit), `TS_town`, `TS_interior`, `TS_buildings` (the building library).
- Characters: LPC art converted by `tools/lpc` (see "LPC character art pipeline"); `scripts/lpc_catalog` is
  generated - don't edit by hand. Looks/races/creator: `character_look`, `character_races`. Actions (tool/weapon
  swings): `actions` (`action_hit` is the hook for effects).
- Items/inventory/crafting/shops: `items`, `inventory`, `obj_inventory` (modes: plain, `shop`, `craft`, `ship`).
- Time, sleep, energy/health, world store: `world_time`. Farming: `farming`. Saving: `save_system` (see
  `SAVE_VERSION` there for what each version added).
- Gathering, smelting, tool tiers and upgrades: `gathering` (resources are `obj_resource`, spawned per room area;
  the furnace is `obj_furnace`, in Brom's smithy). Art for trees, rocks and weeds is cut from `spr_tile_terrain`.
- Stats, cooking, food buffs and the cold: `food` (`stat(key)` is how to read any stat; the hearth is `obj_kitchen`).
- The mine: `mine` (seeded cave floors in `rm_mine`, bands, ladders). The lift is `obj_mine_door`: at the cave on
  North Road, and a lift car (`inMine`) by the ladder up on every 5th floor; story mode goes to any floor you've
  reached, free mode to any floor (`mine_lift_top`, `mine_lift_free`). Tests: `mine`, `mine_lift`. Bosses (`mine_boss`, `mine_boss_beaten`) and the endless Deep below floor 30; monsters with `ranged` in
  their table entry shoot `obj_enemy_shot` (`monster_shoot`).
- Combat: `combat` (`weapon_table`, `monster_table`, `obj_monster`, knock-outs). Monster art: `spr_mon_*` from [LPC]
  Monsters, imported with `node tools/sprite_import.js <png> <spr_name>` (credited in `LPC_CREDITS.csv`).
- Charging (`docs/CHARGING.md`): `charging` (hold to charge tools and weapons: `charge_max`, `charge_kind`, the
  release in `charge_release`, how it looks in `charge_fx` / `charge_draw_*`; `obj_plyr` keeps `charge`, `actCharge`,
  `motion`). Tiers past Mithril: Cursed (6) and Blessed (7) (`TOOL_CURSED`, `TOOL_BLESSED` in `gathering`).
- Status effects: `status` (poison in `global.vitals.poison`; the curse in `global.inv.cursed` / `cursePending`; the
  witch's bolts; Father Aldous lifts curses in `priest_offer`).
- Magic: `magic` (spells, mana, scrolls `k|<spell>`).
- Weather: `weather`. Village projects: `projects` (the board's Projects page).
- Whisperwood: `forest` (`rm_forest`, generated from a fixed seed at Room Start like the mine; `obj_path` is the
  bridge / the way back, `obj_shrine`). Rooms built at runtime keep walls and water in the `global.mineWalls` tilemap
  (see `collision_solids`).
- Placed things (sprinklers): `placeables` (`obj_placeable`, items `o|<kind>`, saved in `world_room().placed`).
- Fishing: `fishing` (`fish_table`, `obj_fishing` is the bite minigame; the rod's hit calls `fishing_cast`).
- Animals: `animals` (`obj_animal` in the farm's meadow, crates `n|<kind>` from Wren's ranch, products `a|<product>`).
- Festivals: `festivals` (one a season in the village; the board gets a Festival page; `obj_festival_decor`).
- People: `people` (villagers, looks, everyday clothes via `villager_wardrobe`, friendship, gifts; `obj_dialogue`;
  shopkeepers' stock: `people_trade`). Quests: `quests` (`obj_quest_board` in the village).
- Heart events: `heart_events` (`heart_event_table`; checked a few times a second, played by `obj_dialogue` in event
  mode).
- Schedules: `schedules` (`villager_routines`: homes, shop hours, days off, seasonal variants; `villager_where` works
  out where someone is from the clock, so nothing is saved; walking routes over `room_walk`; `obj_villager` is a
  villager in your room, made by `villagers_update`; a shop trades only while `villager_shop_open`; doors:
  `door_lock_reason`).
- The world map (M): `obj_world_map`, `scripts/world_map` and `spr_world_map` (generated by `tools/rooms/worldmap.js`);
  `building_label` names each building in the tooltip.
- Anything usable with E calls `interact_near(range)` and `interact_ready()` (`interact`): only the closest thing
  answers. `ui_blocking()` is true while any window is open (the clock stops).
- The bed (`obj_bed`) draws the red bed from `spr_tile_interior` (LPC Interior Castle Tiles); the crafting table,
  shipping bin and furnace use LPC art too.

### How to extend it

- **A new villager**: an entry in `villager_table` (`people`: looks, lines, gifts) and in `villager_routines`
  (`schedules`: home, work hours and day off, routine), and named spots in the room specs they use.
- **A new house**: a building in an outdoor spec placed with `tools/rooms/house.js` (the thing, its door and the
  interior's exit), plus an interior spec; run `node tools/rooms/sync_exits.js <room>`. For a shop, add a noun in
  `building_label`.
- **A new outdoor room**: also add it to `room_is_outdoors`, `save_room_name`, the schedules' outdoor lists, the
  debug room list and `OUTDOORS` in `tools/rooms/worldmap.js`.
- Counters are two cells tall: leave a gap so the keeper can get out (the builder's reach check catches it).

### Room builder (`tools/rooms`)

Every room but the mine and the forest is built from a spec in `tools/rooms/specs/`: a text map of the ground plus
the things placed on it. One command writes the room file, so a layout change is a text edit and a rebuild:
`node tools/rooms/build.js <room>` (or several names, or `all`). Edit the spec, never the built `.yy` - room-editor
edits are overwritten by the next build. A spec for a room that doesn't exist yet creates it and adds it to
`NewHarvest.yyp`. It writes:

- `rooms/<room>/<room>.yy`: tile layers, merged `obj_col_box` collision boxes (plus a wall around the room),
  `obj_water_zone`s over water, and the spec's instances. Exits (`obj_transition`) go on the hidden Collisions layer.
- `scripts/room_layout/room_layout.gml`: every spec's named `points` and `areas`, read with
  `layout_point("rm_1", "cave")`, `layout_cells(...)` and `layout_area(...)` instead of hard-coded coordinates.
- `scripts/room_walk/room_walk.gml` (`walk.js`): where villagers can walk in every built room (a cost per cell:
  roads cheap, grass dearer, field soil dearest, solid blocked) and its exits, for their schedules. It warns about
  named points that can't be reached from the room's door.
- `build/rooms/<room>.png`: a render of the room (blue: collision, cyan: water, yellow: exits, red: instances).

After changing an outdoor room, also run `node tools/rooms/worldmap.js` (the world map).

A spec:

```js
module.exports = {
	seed: 11,                  // the same seed always gives the same room
	map: ["....,,,,", ...],    // one character per 32px cell, see "legend" in tiles.js
	things: [{is: "farmhouse", at: [2, 7]}, {is: "pine", at: [0, 34]}],
	scatter: [{on: ".", density: 0.05, pieces: [{is: "leaves"}, {is: "mushrooms"}]}],
	instances: [{obj: "obj_plyr", x: 272, y: 592}, {obj: "obj_transition", x: 8, y: 576, sx: 1, sy: 4, code: "..."}],
	points: {start: [272, 592]},             // pixels
	areas: {pasture: [44, 22, 56, 30]},      // cells, inclusive
};
```

- **Map characters** (`tiles.js` legend): `.` grass, `,` dirt, `:` cobbles, `_` sand, `~` water (solid), `=` field
  soil (the `T_Soil` layer farming reads), `x`/`X` grass/dirt you can't walk on. A spec can add its own `legend`.
- **Terrains** are autotiled from LPC terrain blocks (3x6 cells: inner corners, the outer 3x3, fills): a cell picks
  its edge from its 8 neighbours. Keep areas at least 2 cells thick, or the edges look odd.
- **Things** (`tiles.js`): a rectangle of a tileset (`src`), or a **stamp** (`stamp`, a multi-layer piece in
  `stamps/`). `above` rows draw over the player (roofs, tree tops), `solid` cells block walking, `swap` recolours a
  stamp. Overlapping things stack on extra layers.
- **Scatter** sprinkles walk-over decorations on free cells of the given map characters.
- **Interiors** use `base: "none"` and a furnished stamp, or `interior.js`: `interior({w, h, wall, floor, door, exit,
  furniture})` gives a spec with a border, a back wall, a floor, a doorway in the bottom edge (and its exit), and
  furniture from its `pieces` table of `TS_interior` tiles (counters, shelves, beds, tables, wall and counter-top
  things). Every piece draws under the player and is solid over its art. `spots: {name: [col, row]}` names the places
  villagers stand (schedules use them as `"room.name"`). A spec's `view: [w, h]` sets the camera (interiors use
  375 x 210).
- **Open country**: copses come from `tools/rooms/woods.js`.

Tools:
- `node tools/rooms/render.js <room> [out.png] [--no-instances] [--scale 0.5]`: render any room, built or not.
- `node tools/rooms/capture.js <room> <name> <col> <row> <w> <h> [layers]`: save part of a room's tiles as a stamp.
- `node tools/rooms/tileset_import.js <png> <name>`: turn a 32px spritesheet into `spr_tile_<name>` + `TS_<name>`.
  Credit new art in `LPC_CREDITS.csv` and regenerate the in-game credits.
- `node tools/rooms/paint.js`: paints rectangles of a character into a spec's map.
- To find a tile's coordinates, look at the sheet in a viewer with a 32px grid; `[col, row]` is pixel / 32.

Tileset art: `TS_terrain` is the LPC Tile Atlas terrain sheet (its crops corner changed for this game); `TS_town` the
LPC Tile Atlas base sheet (`art/lpc_tile_atlas/`, with its attribution file); `TS_cottage` the cottage kit (the
farmhouse stamp); `TS_interior` the interior tiles; `TS_buildings` the building library.

### Building library (`tools/buildings`)

Buildings in the outdoor rooms come from the library: `tools/buildings/previews.sh` rebuilds the packs' preview
pictures from their own tiles without the ground (`decompose.js`); `node tools/buildings/library.js --tileset` cuts
the buildings (`B` in library.js: box, door, foot, fixes such as `clear` and `fill`; `dropSpecks` removes detached
specks) into `spr_tile_buildings` / `TS_buildings` and `tools/rooms/buildings.json`. A spec places one with
`tools/rooms/house.js`, and `node tools/rooms/sync_exits.js <room>` points the interiors' exits at their doorsteps.
Look at them all in `build/buildings/library.png`. The farmhouse is still the cottage-kit stamp.

### LPC character art pipeline (`tools/lpc`)

Rebuilds the `lpc_*` sprites, the `lpc_pal_*` palettes and `scripts/lpc_catalog` from the
[Universal LPC Spritesheet Character Generator](https://github.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator).
Art is stored the way the palette shader (`shd_lorikeet`) expects: each pixel's grey level is a position along a
palette strip, so one sprite can be drawn in any colour. Pixels that aren't part of a colour ramp (eye whites, gems,
outlines) go on a separate `_fix` sprite drawn in its original colours.

Run from Git Bash in a scratch folder (`$W`), not inside the project; the scripts are in `tools/lpc`:

1. Get the generator's definitions (about 7 MB):
   ```bash
   git clone --filter=blob:none --no-checkout --depth 1 https://github.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator.git $W/lpc
   cd $W/lpc && MSYS_NO_PATHCONV=1 git sparse-checkout set --no-cone '/sheet_definitions/' '/palette_definitions/' '/CREDITS.csv' && git checkout master
   git ls-tree -r --name-only HEAD spritesheets > $W/tree.txt
   ```
2. Map items to creator slots and list the art needed: `python -I plan.py $W/lpc $W/tree.txt $W/out`
   (the slot mapping is the `SLOT` table at the top of `plan.py`).
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
6. Write everything into the project (close GameMaker first): `python -I finalize.py $W <project folder> $W/lpc`
   (expects `out/`, `sheets/` and `convert_log.txt` inside `$W`; it reuses existing sprite ids, so unchanged sprites
   produce no git changes). Then run `./build.sh`.

LPC art is CC-BY-SA 3.0, GPL 3.0 and/or OGA-BY 3.0, depending on the piece; `LPC_CREDITS.csv` lists the authors and
licences for every piece used, and the game's credits must include them.
