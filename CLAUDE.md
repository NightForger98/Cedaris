# Harvest Valley (GameMaker LTS 2026)

## README

**Harvest Valley** is a Stardew-like farming RPG. You inherit your grandmother's farm in a valley: grow crops, keep
animals, mine and fight down a generated mine, learn magic, fish, cook, craft and dye clothes, and befriend the people
of the village, the town of Brindlemoor, the coast and the vale, who live their own days.

- **Project**: `NewHarvest.yyp`. Repo: github.com/NightForger98/HarvestValley (branch `main`).
- **Run it**: open `NewHarvest.yyp` in GameMaker LTS 2026, or `./build.sh run` from Git Bash (see Working on it).
- **Controls**: arrows move (Shift runs, Ctrl walks); left click or Space uses the held tool; 1-9, 0 pick the hotbar
  slot; E talks / uses (in a dialogue: G gives what you hold, T trades or tells you the shop's hours); I inventory;
  M world map; F casts with a staff, Q changes spell; Esc pauses; Insert toggles debug mode.
- **The world**: the farm is the hub; Brindlemoor (north, up the ladder), the village (east, with Whisperwood beyond
  the river), the Saltmere Coast (west) and Hollow Vale (south). Layout and who lives where: `docs/LEVELS.md`.
- **Art**: LPC (CC-BY-SA / GPL / OGA-BY), credited in `LPC_CREDITS.csv` and in game.

## Working on it

- **Build / check**: `./build.sh` (Git Bash) compiles with GameMaker's Igor and prints compiler errors; `./build.sh run`
  launches the game. It needs GameMaker LTS 2026 installed and signed in once (it reads the licence from
  `%APPDATA%/GameMakerStudio2-LTS2026/<user>/licence.plist`). The compiler does not catch calls to unknown
  functions - check names against the runtime's `GmlSpec.xml` when using new built-ins.
- **GML gotchas hit before**:
  - `all`, `id`, `score`, `pi`, `floor`, `y`, `power`, `solid` are built-ins (don't use as variable names; `solid` fails as
    "malformed assignment"); `crop` is an enum
    (in the crops object); `not` is a keyword - even as a struct key it crashes the compiler with "Stack empty", and
    so does an accessor on a parenthesised `??` (`(a ?? b)[$ k]`): put the `??` in its own variable first.
  - `static` only works inside functions; JSON `null` may not load as `undefined`.
  - `f()[$ g()[i]]` (an accessor on a call, keyed by an indexed call) crashes the compiler with a bare
    NullReferenceException: split it into two lines.
  - `obj_plyr.layer` is -1 in some rooms (the farm makes the player at runtime): create instances on the
    "Instances" layer instead.
  - A runtime error shows a dialog and the test just times out with no message: wrap the suspect call in
    `try`/`catch` and `autotest_log` the exception to see it.
- **GameMaker open while editing files**: it shows "Project Directory Modified" - choose **Reload**, never Save.
- **Testing**: `tools/test/autotest.sh tools/test/cases/<case>.txt` builds and runs the game with a test script
  (commands in `scripts/autotest`: start, pos, hold, use, give, time, room, call <function>, shot...) and copies its
  log and screenshots to `build/autotest/` - read the PNGs to check. Simulated key presses don't reach
  `keyboard_check_pressed`, so keys a test needs go through `input_pressed()`. Test runs never write real saves
  (only a "test" slot). The user's settings may be fullscreen (`%LOCALAPPDATA%/NewHarvest/settings.ini`) - back it
  up and restore it if you switch to windowed for tests. Autosave must never overwrite another game's save slot.
  A new game starts on Monday at 6am: set `time` (and `call autotest_date`) so shops are open when a test needs them.
- **Debug mode in game**: Insert toggles it - PgUp/PgDn hop rooms, T skips an hour, G grows crops, position readout.

## Where things are

- `docs/ROADMAP.md` - the plan (farming, stats, combat, magic, social) with status per step. **The roadmap's 9 steps are
  done; `docs/MILESTONES.md` has what comes next.** `docs/PROGRESSION.md` - items, materials, recipes, dyes, stats,
  and the hooks for quests.
- `docs/LEVELS.md` - **the level creation plan** (agreed): towns and the farm are designed rooms; the mine is
  generated at runtime in GML, seeded per floor. Not a WFC/Python pipeline - read why before proposing one. Also the
  layout of the world, and every shop's hours and day off.
- **Built rooms**: every room but the mine and the forest comes from a spec in `tools/rooms/specs/` (text map +
  things + instances; interiors use `tools/rooms/interior.js`): `node tools/rooms/build.js <room>` rewrites the room
  file - edit the spec, never the built `.yy` (see `tools/rooms/README.md`). It also writes `scripts/room_layout`
  (named spots, read with `layout_point`/`layout_area`) and `scripts/room_walk` (where villagers can walk), and warns
  if a named spot can't be reached from the door. After changing an outdoor room, also run
  `node tools/rooms/worldmap.js` (the world map). GameMaker's `.yy` reader needs keys in alphabetical order.
- Characters: LPC art converted by `tools/lpc` (see its README); `scripts/lpc_catalog` is generated - don't edit
  by hand. Looks/races/creator: `character_look`, `character_races`. Actions (tool/weapon swings): `actions`
  (`action_hit` is the hook for effects).
- Items/inventory/crafting/shops: `items`, `inventory`, `obj_inventory` (modes: plain, `shop`, `craft`, `ship`).
- Time, sleep, energy/health, world store: `world_time`. Farming: `farming`. Saving: `save_system` (see `SAVE_VERSION` there for what each version added).
- Gathering, smelting, tool tiers and upgrades: `gathering` (resources are `obj_resource`, spawned per room area;
  the furnace is `obj_furnace`, in Brom's smithy). Art for trees, rocks and weeds is cut from `spr_tile_terrain`.
- Stats, cooking, food buffs and the cold: `food` (`stat(key)` is how to read any stat; the hearth is `obj_kitchen`).
- The mine: `mine` (seeded cave floors in `rm_mine`, bands, ladders, lift at `obj_mine_door` on the farm). Combat:
  `combat` (`weapon_table`, `monster_table`, `obj_monster`, knock-outs). Monster art: `spr_mon_*` from [LPC] Monsters,
  imported with `node tools/sprite_import.js <png> <spr_name>` (credited in `LPC_CREDITS.csv`).
  Bosses (`mine_boss`, `mine_boss_beaten`) and the endless Deep below floor 30; monsters with `ranged` in their
  table entry shoot `obj_enemy_shot` (`monster_shoot`).
- Magic: `magic` (spells, mana, scrolls `k|<spell>`).
- Weather: `weather`. Village projects: `projects` (the board's Projects page). Whisperwood: `forest` (`rm_forest`,
  generated from a fixed seed at Room Start like the mine; `obj_path` is the bridge / the way back, `obj_shrine`).
  Rooms built at runtime keep walls and water in the `global.mineWalls` tilemap (see `collision_solids`).
- Placed things (sprinklers): `placeables` (`obj_placeable`, items `o|<kind>`, saved in `world_room().placed`).
- Fishing: `fishing` (`fish_table`, `obj_fishing` is the bite minigame; the rod's hit calls `fishing_cast`).
- Animals: `animals` (`obj_animal` in the farm's meadow, crates `n|<kind>` from Wren's ranch, products `a|<product>`).
- Festivals: `festivals` (one a season in the village; the board gets a Festival page; `obj_festival_decor`).
- People: `people` (villagers, looks, everyday clothes, friendship, gifts; `obj_dialogue`; shopkeepers' stock:
  `people_trade`). Quests: `quests` (`obj_quest_board` in the village).
- Heart events: `heart_events` (`heart_event_table`; checked a few times a second, played by `obj_dialogue` in event mode).
- Charging (`docs/CHARGING.md`): `charging` (hold to charge tools and weapons: `charge_max`, `charge_kind`, the
  release in `charge_release`, how it looks in `charge_fx` / `charge_draw_*`; `obj_plyr` keeps `charge`, `actCharge`,
  `motion`). Tiers past Mithril: Cursed (6) and Blessed (7) (`TOOL_CURSED`, `TOOL_BLESSED` in `gathering`).
- Status effects: `status` (poison in `global.vitals.poison`; the curse in `global.inv.cursed` / `cursePending`; the
  witch's bolts; Father Aldous lifts curses in `priest_offer`). Autotest: `charge N [shot]` holds the button, `snap N name`
  screenshots mid-action.
- Schedules: `schedules` (`villager_routines`: homes, shop hours, days off; `villager_where` works out where someone
  is from the clock, so nothing is saved; walking routes over `room_walk`; `obj_villager` is a villager in your room,
  made by `villagers_update`; a shop trades only while `villager_shop_open`).
- The world map (M): `obj_world_map`, `scripts/world_map` and `spr_world_map` (generated by `tools/rooms/worldmap.js`);
  `building_label` names each building in the tooltip.
- Anything usable with E calls `interact_near(range)` and `interact_ready()` (`interact`): only the closest thing
  answers. `ui_blocking()` is true while any window is open (the clock stops).
- Rooms: `rm_0` boot, `rm_menu`, `rm_creator`, `rm_1` farm (the hub), `rm_2` village (east), `rm_town` (north, up the
  ladder), `rm_beach` (west), `rm_valley` (south), `rm_12` farmhouse downstairs, `rm_123` upstairs (`BED_ROOM`),
  `rm_town_*` (the town's inn, outfitter, apothecary and four homes), `rm_village_*` (smithy, general store, three
  homes), `rm_valley_ranch`, `rm_valley_carpentry`, `rm_beach_hut`, `rm_mine`, `rm_forest`. A new outdoor room also
  needs `room_is_outdoors`, `save_room_name` and the debug room list. Tilesets: `TS_terrain`, `TS_cottage` (house
  kit), `TS_town`, `TS_interior`.
- Placeholder art drawn from `spr_tile_interior`: the bed (the crafting table, shipping bin and furnace now use LPC art; replace with real
  assets).

## Conventions

- Data tables over code (crops, materials, recipes, races, shop stock, schedules).
- Comment the why, match surrounding style; commit with a clear message and push to `main` when a step is done.
- LPC art licences (CC-BY-SA / GPL / OGA-BY): keep `LPC_CREDITS.csv` and the in-game credits up to date.

## Handoff

Where things stood at the end of the last session (2026-10-28), and what to know before picking it up.

**Done that session** (all pushed to `main`):
- A new game no longer starts the player stuck in Brom's furnace.
- The room builder (`tools/rooms`): every room is written from a text spec instead of the room editor.
- The farmhouse (layering fixed, bed upstairs), and Brindlemoor, the coast and the vale around the farm.
- Brindlemoor's interiors: the inn, outfitter, apothecary and homes.
- Villagers always wear everyday clothes (`villager_wardrobe` in `people`).
- Schedules and the world map: everyone has a home, a job or routine and a day off; shops trade only in hours;
  nobody lives on the farm (Brom's smithy and Mara's store moved to the village, Wren's ranch and Thorne's carpentry
  are in the vale, Marlo has a hut, Garrick and Posy lodge at the inn); M opens the world map with building
  tooltips. All 21 test cases passed.

**How to extend it**:
- A new villager needs an entry in `villager_table` (`people`: looks, lines, gifts) and in `villager_routines`
  (`schedules`: home, work hours and day off, routine), and named spots in the room specs they use.
- A new house is a house thing in an outdoor spec with an `obj_transition` at its door, plus an interior spec; for a
  shop, add a noun in `building_label`.
- Counters are two cells tall: leave a gap so the keeper can get out (the builder's reach check catches it).

**Known gaps / ideas for next**:
- Done since: doors lock at night and out of hours (friends at 2 hearts get in), villagers step around you and
  each other, rainy days keep most people in, the map shows the real Whisperwood, and the unused `obj_npc_man`,
  `rm_3` and its label objects are gone.
- Also done: seasonal schedule variants and heart events (`scripts/heart_events`).
- Also done: milestone 13 - charged tools and weapons, the witch, poison and curses, Father Aldous. Still to come with
  the world map: his temple, its Friday sermon and hours (see `docs/CHARGING.md`).

**Working with the user**: they want recommendations acted on without asking first ("if you recommend something go
ahead with it"); they always choose Reload in GameMaker; end each step with a commit and push to `main`.
