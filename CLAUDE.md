# Harvest Valley (GameMaker LTS 2026)

This is the project's only README and handoff file. It has three parts: **README** (what the game is and how to run
it), **Handoff** (where work stands and what's next) and **Reference** (everything needed to work on it).

## README

**Harvest Valley** is a Stardew-like farming RPG. You inherit your grandmother's farm in a valley: grow crops, keep
animals, mine and fight down a generated mine, learn magic, fish, cook, craft and dye clothes, and befriend the people
of the village, the town of Brindlemoor, the coast and the vale, who live their own days.

- **Project**: `NewHarvest.yyp`. Repo: github.com/NightForger98/HarvestValley (branch `main`).
- **Run it**: open `NewHarvest.yyp` in GameMaker LTS 2026, or `./build.sh run` from Git Bash (see Reference).
- **Controls** (defaults; rebind them in Options > Controls): arrows move (Shift runs, Ctrl walks); left click or Space uses the held tool (hold to charge it);
  1-9, 0 pick the hotbar slot; E talks / uses (in a dialogue: G gives what you hold, T trades or tells you the shop's
  hours); I inventory; M world map; F casts with a staff, Q changes spell; Esc pauses; Insert toggles debug mode.
- **The world** (branch `world-rebuild`, 2026-11-05): 25 outdoor rooms on a 5 x 5 grid laid out like Beirut - the
  sea along the top and the west, the river and the eastern hills (Beacon Hill's mine, Victory Hill, Yarzeh Woods)
  in the east, Downtown in the middle, Player Farm (`rm_1`) in the bottom row with Wing Hill's market above it.
  The rooms are generated from `tools/world/world.js`; who lives where, the shops, roads and travel rules are in
  `design/world_plan.md`.
- **Art**: LPC (CC-BY-SA / GPL / OGA-BY), credited in `LPC_CREDITS.csv`, in each pack's credits file in `art/`, and
  in game.

## Handoff

Last updated 2026-11-05: **the new world prototype** on branch `world-rebuild` (not merged into `main`). See
"The new world (world-rebuild)" just below; everything after it describes `main` before the rebuild.

### The new world (world-rebuild)

The user designed a new map (Beirut as a 5 x 5 grid of 25 rooms, `harvestvalleyconceptmap.docx` on their desktop)
and agreed the plan in `design/world_plan.md` (rooms, families, shops, marriage, upgrades, roads, travel). Built
overnight while they slept, as a prototype:

- **Rooms**: `tools/world/world.js` (the grid: size, coast, river, links road/lane/rocks/trees, buildings, decor) ->
  `node tools/world/make_specs.js` writes thin specs in `tools/rooms/specs` (outdoor rooms from `tools/world/room.js`,
  18 new interiors from `interior_data.js` / `interiors.js`) and re-points the 15 reused old interiors' exits ->
  `node tools/rooms/build.js <rooms>` -> `node tools/world/world_gml.js` (writes `scripts/world_rooms`: outdoor list,
  place names, fishing water, road cells, resource areas) -> `node tools/rooms/worldmap.js` (now a grid layout).
  The farm (`rm_1`) keeps its own spec; its ways out (north to Wing Hill, west to South Beach) use `room.js`'s
  `arrive`. The old outdoor rooms are gone (copies in the desktop folder "Harvest Valley - old rooms (pre-rebuild)").
- **People**: 46 villagers (21 old, 25 new) in `villager_table` and `villager_routines`; the routines were written
  from a checked list (every "room.spot" exists). New shops in `people_trade` (`shop_list`). Honey is `a|honey`.
- **Travel and time**: `GAME_MIN_SECONDS` 1.0; the clock stands still indoors and in the mine (`clock_tick`);
  player 1.5 / 3 / 4.5 px a frame, `ROAD_BOOST` 1.25 on road cells (`world_is_road`); `WALK_SPEED` 120. Boots and
  other gear already change speed through the Speed stat (`inv_speed_multiplier`), and it stacks.
- **Story-mode creator**: gender first, matching parts only (`character_story_rules`, `player_gender()`).
- **Saves**: version 12; older saves wake on the farm with the rest of the world rolled again.
- **Fixed on the way (affects main too)**: buildings were scrambled in game because `TS_buildings.yy` said 64
  output columns while the IDE writes `output_tileset.png` 58 wide (ceil(sqrt(tiles))). Now 58, and
  `tools/rooms/output_tileset.js` (run by `build.sh`) writes any missing or mismatched sheet.
- **Doors** (2026-11-06): a door or road out (`obj_transition`) takes you through when you walk into it from any
  side, straight or diagonal, or walk on in its `PlayerFacingBefore` direction while on it (`-1`: any way); standing
  still never does, and the door you arrive on only works once you walk through or step off and back (`doorPrev` in
  `obj_plyr`). The brick hall (tavern, guild) has no door in its art: `tools/rooms/tiles.js` (`doorArt`) moves its
  way in to column 6 and `room.js` places `obj_door_art` (`spr_door_brick`, the brick market's door, depth 1100)
  there. The brick bay has no wall for a door, so the Goldcrest home and the library use brick_gable / brick_market.
  (Since the sprite houses below, no room uses the brick hall; `obj_door_art` stays for any building that needs it.)
- **Sprite houses and dressing** (2026-11-06): every building in the world is now one of the user's Meshy / PixelLab
  house sprites (`spr_house_*`), placed as `house_<name>` things (`tools/rooms/sprite_buildings.js`: door x per sprite,
  measured by eye; foot rows solid; the door cell is the way in). `build.js` turns a sprite thing into an
  `obj_building` (draws up from its y, depth-sorted by its foot) and `render.js` / the world map draw them. Small
  PixelLab props (`spr_prop_*`: bench, lamp, fountain, planter, campfire) are `prop_<name>` things the same way.
  `room.js` now also lays out: neighbours' houses you can't enter (`fill`, door cell solid) along the north side and,
  in town, a row south of the street (`fillSouth`); props beside each building; street lamps and benches in town;
  the fountain and benches on Downtown's square; and `landmarks` per room (`{is, q}` or `{ph: "Label", w, h, q}` in a
  corner "nw" | "ne" | "sw" | "se", with a lane to the street when clear). A `ph` landmark is an `obj_placeholder`
  (a labelled box) until it has art: Sea arch, Tide pools, Museum, Botanical garden, Shipwreck, Beach bar,
  Graveyard, Monastery, Ranger's cabin, Fish market, Olive grove and the rest in `world.js`. Roads now draw over a
  dirt layer (`":"` has `under: ["dirt"]`), so lanes meet roads with no grass seam.
- **No houses you can't enter** (2026-11-06, the user's call): the neighbours' houses are off (`fill` / `fillSouth`
  default 0). Instead there are five new families with a home and a workshop each (design/world_plan.md: Saba olive
  press, Brassbolt tinker, Saltwhistle boatyard, Fairglass glassworks, Hayward stables). That's 10 villagers in
  `villager_table`, `villager_routines`, `people_trade` and 7 new materials, plus 10 interiors in
  `interior_data.js`. A building can be `{key, ph: "Label", w, h, room}` until it has art: an enterable labelled box.
  The five homes are like that for now. Test case `families`.
- **Rooms sized to their contents**: `geom()` in `room.js` works each room's size out from what's in it. `w` / `h` in
  `world.js` are no longer used.
- **Coast**: 5 rows of water and 10 of sand. Every coastal room has a pier; Starsand's is stone (`pierStone`). A
  west-coast pier sits on the street's row, and the street runs across the sand to it.
- **East cliffs** (`cliffEast`: Beacon Hill, Victory Hill, Whispering Woods): high ground drawn by `highGround()` in
  `room.js` from the cliff 9-slice in TS_terrain (cols 5-7, rows 0-4): the rim, the sides, the top, and a 3-row face
  wherever the ground drops away to the south. The band's width curves (7 at the room's ends so rooms meet), with
  pines on top. **Ruins** (`{ruin: "house" | "temple", q}` landmarks) are built from TS_terrain pieces (`ruin_*`).
- **Plummet's Point is split** (`split: true`): a diagonal cliff with the high ground and the witch's tower in the
  south-east and the beach and lowland in the north-west. A `"cliff"` link (`cliffCol()`) joins its high ground to
  the top of Beacon Hill's mine cliff, which a ladder (`cliff_ladder`) climbs from the cave ledge. A `"beach"` link
  runs along the sand to Hangar 12, over a footbridge that stays broken until the Beach Bridge project is done.
  Morga and Rook keep to the high ground (`cliff_a` / `cliff_b`).
- **Coast**: the north shore is rocky (dirt with `rock_grey*` / `pebbles_*`). The west coast's sea and sand widen and
  narrow, but stay straight near the street's row and the room's ends. `corniche: true` (Manara's Light, Starsand,
  Well's Head) adds a stone promenade with lamps along the shore, like Beirut's Corniche. `pineForest: true` (Dahya)
  fills the south with a dense pine wood, after Horsh Beirut.
- **Whispering Woods** (rm_yarzeh, once Yarzeh Woods): `dense` (overlapping canopies, `woods(..., tight)`) and the
  richest forage. It has the shrine (an `obj` landmark) and night pixies and moths (`woods_room_start` in
  scripts/forest). Whisperwood (rm_forest, obj_path) is gone.
- **Two folders**: `D:\GameMakerProjects\HarvestValley-HOMEPC` is on `main`; `HarvestValley-WorldRebuild` beside it
  is a git worktree on `world-rebuild`. The user's test rooms (`testmapindoor1`, `roomtest2`) are in both, listed
  last in the room order and never committed. In the branch folder an uncommitted spec,
  `tools/rooms/specs/testmapindoor1.js`, builds the test room as a workshop with every station; build it on its own
  and keep its lines out of committed `room_layout` / `room_walk`.
- **Tests**: all 36 cases pass (`tools/test/suite.sh`, 2026-11-05). New: `new_world` (every room loads, all 70 ways
  between rooms link both ways, all 46 villagers on time - longest walk 74 min, the clock frozen indoors, the road
  boost), `creator_story`, `marriage`. The old map's tests were retired (see the commit "Tests for the new world").

**Marriage** is in (`scripts/marriage`): courting events at 2/4/6/8 hearts are placeholders built from each
candidate's own lines - real scenes still to write. House plans from Rowan's are built overnight (upgrade level in
`global.world.house`), and the farmhouse grows with them: `rm_1`'s farmhouse is an `obj_building` whose creation code
picks `spr_house_farmhouse_1`-`4` by `house_level()`, shifts it so its door stays over x 816, and makes its own
collision (two rows of `obj_col_box` under it, not the door's). The room is re-entered after the overnight build, so
the new stage shows next morning.

**PixelLab art (2026-11-05)**: the developer's Tier 1 plan (2,000 generations a month, resets on the 5th; the API key
is the user's - never commit or repeat it). Made through the API (`POST /v2/map-objects`, then poll
`GET /v2/map-objects/{id}`; canvases must be multiples of 4; about 1 generation each): every family has its own home
now (`spr_house_home_*`), the farmhouse has its 4 stages, and every landmark placeholder has art (`spr_prop_<name>`,
registered in `PROPS` in `sprite_buildings.js` with its solid rows) - no `ph:` is left in `world.js`. Prompts, picks
and retries are in `art/ai_houses/README.txt`. Words that keep a building front-on: "A long low wide building, much
wider than tall, its roof ridge running left to right"; "farmhouse" brings fences and ground, "cottage" doesn't;
"nothing around the building, plain flat grey background" for clean edges.

**Art direction (the user, 2026-11-05)**: all the map's art is to be PixelLab, in the style of these buildings; only
what comes from the LPC character generator stays (characters, clothes, equipment, held tools and their icons). No
Meshy building is placed any more (the last five were remade, the tavern and smithy use `tavern_inn` / `blacksmith`).
Monsters, farm animals and anything LPC with seasonal versions (trees, bushes, terrain) stay LPC for now. Still to
remake, in this order: inventory icons drawn with shapes and seed packets, crops, gatherable trees and rocks with
stages, then the terrain (the user will design the map with PixelLab first), interiors with the indoor-room remake.

**Not done yet**: farm buildings at Garth's; the
horse, the minecart, the sewers and the cave passage, teleporting; a different routine on shop days off per season
(most have one day-off routine all year); explosives for Fen; real stock for the bakery, flowers and furniture;
roads and lanes look the same
(both brown - a cobble tile for roads would make the boost visible); the landmarks have art but nothing to do there
yet; interiors weren't changed to match the new outsides.

### Working with the user

- On question turns, answer only: no plans or recommendations until asked. When they do ask for a recommendation,
  act on it without asking again.
- When asked to plan, they want questions first, then implementation.
- When they say "stop", stop at once.
- They always choose **Reload** in GameMaker (never Save).
- End each step with a commit and push to `main`.

### Next steps: waiting on the user

Everything Claude could do alone from the polish list is done (`docs/MILESTONES.md`, "Polish before expanding").
What's left needs the user to play or decide. When they come back with notes, turn them into the next polish pass;
until then, don't start these on Claude's own judgement.

**1. Play a first week in story mode** (new game, story mode; play days 1-7 normally, without debug mode).
Note every moment of confusion, boredom or being stuck, with the day, the place and what they were trying to do.
Things worth watching: whether the first-morning hint and the signposts get you off the farm (the farm's only way
out is the path at the top, north to Hollow Vale - the user was stuck there once); whether the hints come at the
right moments; how long it takes to reach the village, Brindlemoor and the mine; whether money and energy feel
right for the first week. *What Claude needs back*: the list of notes, rough is fine.

**2. The tuning list** - things only playing can judge. Where each lives, for when the notes come back:
- *Charging feel*: how long a level takes (`CHARGE_LEVEL_TIME`, 0.6 s, in `charging`; each tool's levels in
  `charge_max`), and whether the spin and the wide swings feel good (`CHARGE_SPIN_STEP` / `CHARGE_SPIN_TURNS`).
- *Blessing prices*: 5,000 gold to bless a cursed Mithril tool, 1,000 to lift any other curse (`curse_lift_price` in
  `status`, used by `priest_offer`; the design is in `docs/CHARGING.md`).
- *How often the witch appears*: her weight in the mine's band tables (`mine_bands` in `mine`: 12 in the Ember
  Depths, 10 in the Deep; she starts at floor 25, `monster_table` in `combat`).
- *The flame and glow looks*: `charge_fx` / `charge_draw_*` in `charging` (screenshots: tests `charge_looks`,
  `charge_spin`).
- *Walking times*: villagers walk at `WALK_SPEED` (80 px a game minute, about 2 px a frame - the player walks 2,
  runs 3); routes take the shortest way; the longest walk is 77 game minutes. If the world feels too big to cross,
  the options are faster walking for everyone or shortcuts between rooms.
*What Claude needs back*: for each, "fine" or which way it's off (too slow, too dear, too often...).

**3. Decisions only the user can make** (Claude can build any of them once decided):
- *Names and contents* for the Crossroads (`rm_cross`, a placeholder name), North Road (`rm_north`) and South
  Road (`rm_south`): what each place is for (a market, a hamlet, wild land, a quest location...) and what's in it.
  They're open country now (copses and spawn areas only). Room names live in `save_room_name`; signposts and the
  map pick them up from there.
- *Father Aldous's temple*: where it stands and how it looks (the steepled `church` is in the building library);
  his Friday sermon and hours are planned in `docs/CHARGING.md`. He stands in Brindlemoor's square for now.
- *Art direction*: keep the farmhouse as the old cottage-kit stamp or rebuild it in the library's style; keep
  colonial Brindlemoor beside the thatched villages or not; the temple's style.
- *What free mode is for*: a sandbox for testing and creativity, or a full game with easier rules? It decides
  prices, energy, knock-out penalties and what the lift allows (now: any floor) in free mode.
*What Claude needs back*: the choices, in the user's words.

**4. Sounds**: the game has none yet; the volume setting is ready. Adding them needs the user to pick a style
(and licence-safe packs, credited like the art).

**When the user plays in GameMaker**: choose **Reload**, never Save, when it says the project changed. If it has
re-saved rooms or the `.yyp` anyway (same content, re-encoded - it happened twice on 2026-10-29), `git status`
shows them; check with the user, then discard them before committing.

### Done so far (history, newest first)

- **2026-10-29 - polish before expanding**: tests that fail (`expect`, `tools/test/suite.sh`, 257 expects added),
  `tools/check_calls.js` in `build.sh`, LF line endings (`.gitattributes`), signposts by every road (`wayfinding`),
  first-time hints (`hints`), key rebinding (Options > Controls, `key_of`), routes by distance (longest walk 77 min),
  a real lift cage, rocks kept off the mine's chests, the last library props cleaned. GameMaker keeps re-saving the
  rooms and `.yyp` when it's open (same content, re-encoded): check `git status` and discard those before committing.
- **2026-10-29 - the art clean-up finished**: `library.js` fixes (`clear`, `fill`, `dropSpecks`: roof gaps on
  `brick_arch`, scraps cleared on the cottages, colonial houses, barn, the town stalls and the farm shed), tileset
  regenerated (no building changed size or door), the five outdoor rooms and the world map rebuilt. Interiors match
  their outsides (Brindlemoor: wallpaper and parquet/checker floors; cottages: stone walls and wood floors). Removed
  the 17 unused `spr_bld_*` sprites, `tools/buildings/make.js` and the unused stamps (`house_cream`, `house_thatch`,
  `house_cream_thatch`, `village_hall`), with their credit rows. GameMaker had re-saved the rooms and the `.yyp`
  (reordering only) - discarded and regenerated. `build/buildings/dec` is not in git: run
  `tools/buildings/previews.sh` before `library.js`. The unused props (`stall_green`, `stall_blue`, `obelisk`)
  were cleaned too, so every library piece is ready to place. All 44 test cases passed.
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
  functions, so `build.sh` first runs `node tools/check_calls.js`: every call must be a built-in (`GmlSpec.xml`) or a
  project function, and every `call <fn>` in a test case a project function.
- **GameMaker open while editing files**: it shows "Project Directory Modified" - choose **Reload**, never Save.
- **Testing**: `tools/test/autotest.sh tools/test/cases/<case>.txt` builds and runs the game with a test script
  (commands in `scripts/autotest`: start, pos, hold, use, give, time, room, call <function>, shot, `charge N [shot]`
  holds the use button, `snap N name` screenshots mid-action...) and copies its log and screenshots to
  `build/autotest/` - read the PNGs to check. A run fails on a failed `expect <text>` / `expectnot <text>` (checked
  against the last `call` or `inv` result), an ERROR or an unknown command, or if it never reaches `quit`; the script
  prints `---- result: PASS` or `FAIL n` and exits non-zero on a failure. Give new cases expects, not just logs.
  Full suite: `tools/test/suite.sh` (or `tools/test/suite.sh mine deep` for some) prints a pass/fail table, with each
  case's log and screenshots in `build/suite/<case>/`. It takes about an hour; don't edit game code while it runs
  (each case recompiles), and if you stop it, also kill its `suite.sh` loop, `Igor.exe` and `Runner.exe`.
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
- Rooms (world-rebuild): `rm_0` boot, `rm_menu`, `rm_creator`; the 25 outdoor rooms of `tools/world/world.js`
  (`rm_wellshead` ... `rm_abda`, the farm `rm_1`); the new interiors (`rm_hotel`, `rm_guild`, `rm_bank`, `rm_toolstore`,
  `rm_bakery`, `rm_flowershop`, `rm_furniture`, `rm_hospital`, `rm_library`, `rm_church`, `rm_lighthouse`,
  `rm_witch_tower`, `rm_home_*`); the old interiors below, in new places (`REUSED` in `interior_data.js`).
  Before the rebuild: `rm_cross` the Crossroads (the hub), `rm_2` village (east), `rm_town`
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
  out where someone is from the clock, so nothing is saved; walking routes over `room_walk`, the shortest by distance (`route_find`); `autotest_long_walks` lists the longest; `obj_villager` is a
  villager in your room, made by `villagers_update`; a shop trades only while `villager_shop_open`; doors:
  `door_lock_reason`).
- Wayfinding: `wayfinding` - `signposts_place` (game Room Start) puts an `obj_signpost` by every exit from one
  outdoor place to another, named with `save_room_name`; nothing to place by hand. Test: `signposts`.
- First-time hints: `hints` (`hint(key, text)` shows once per game, kept in `global.world.hints`; `hints_step`
  notices the farm's way out, the hoe, can and seeds, the bin, the lift, late nights, low energy; locked doors call
  it from `obj_plyr`). Off in test runs unless `call autotest_hints`. Test: `hints`.
- Keys: rebindable in Options > Controls (`obj_menu`), saved in `settings.ini` [keys]. Read a key with
  `key_of(action)` (`save_system`: `keys_default`, `keys_actions`), show it with `key_name` / `key_label` ("[E]") -
  never hard-code `ord("E")` or a "[E]" prompt. Tests always get the defaults unless `call autotest_rebind`.
  Test: `controls`.
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
- **A new outdoor room** (world-rebuild): add it to `GRID` / `ROOMS` in `tools/world/world.js`, then run
  `make_specs.js`, `build.js`, `world_gml.js` and `worldmap.js` (see "The new world"); the outdoor list, names, debug
  hop list and schedules all read `scripts/world_rooms`. A new house: a `buildings` entry in its room there, and an
  interior in `tools/world/interior_data.js` (`home(...)` / `shop(...)`).
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
