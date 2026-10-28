# Harvest Valley (GameMaker LTS 2026)

A Stardew-like farming game. Project file: `NewHarvest.yyp`. Repo: github.com/NightForger98/HarvestValley (branch `main`).

## Working on it

- **Build / check**: `./build.sh` (Git Bash) compiles with GameMaker's Igor and prints compiler errors; `./build.sh run`
  launches the game. It needs GameMaker LTS 2026 installed and signed in once (it reads the licence from
  `%APPDATA%/GameMakerStudio2-LTS2026/<user>/licence.plist`). The compiler does not catch calls to unknown
  functions - check names against the runtime's `GmlSpec.xml` when using new built-ins.
- **GML gotchas hit before**: `all`, `id`, `score`, `pi` are built-ins (don't use as variable names); `crop` is an
  enum (in the crops object); `static` only works inside functions; JSON `null` may not load as `undefined`.
- **GameMaker open while editing files**: it shows "Project Directory Modified" - choose **Reload**, never Save.
- **Testing**: `tools/test/autotest.sh tools/test/cases/<case>.txt` builds and runs the game with a test script
  (commands in `scripts/autotest`: start, pos, hold, use, give, call <function>, shot...) and copies its log and
  screenshots to `build/autotest/` - read the PNGs to check. Simulated key presses don't reach
  `keyboard_check_pressed`, so keys a test needs go through `input_pressed()`. Test runs never write real saves
  (only a "test" slot). The user's settings may be fullscreen (`%LOCALAPPDATA%/NewHarvest/settings.ini`) - back it
  up and restore it if you switch to windowed for tests. Autosave must never overwrite another game's save slot.
- **Debug mode in game**: Insert toggles it - PgUp/PgDn hop rooms, T skips an hour, G grows crops, position readout.

## Where things are

- `docs/ROADMAP.md` - the plan (farming, stats, combat, magic, social) with status per step. **Next: step 9,
  people, quests and Charm (friendship, dialogue, a quest board).**
- `docs/PROGRESSION.md` - items, materials, recipes, dyes, stats, and the hooks for quests.
- `docs/LEVELS.md` - **the level creation plan** (agreed): towns and the farm are hand-built rooms; the mine is
  generated at runtime in GML, seeded per floor. Not a WFC/Python pipeline - read why before proposing one.
- Characters: LPC art converted by `tools/lpc` (see its README); `scripts/lpc_catalog` is generated - don't edit
  by hand. Looks/races/creator: `character_look`, `character_races`. Actions (tool/weapon swings): `actions`
  (`action_hit` is the hook for effects).
- Items/inventory/crafting/shops: `items`, `inventory`, `obj_inventory` (modes: plain, `shop`, `craft`, `ship`).
- Time, sleep, energy/health, world store: `world_time`. Farming: `farming`. Saving: `save_system` (SAVE_VERSION 3).
- Gathering, smelting, tool tiers and upgrades: `gathering` (resources are `obj_resource`, spawned per room area;
  Brom's furnace is `obj_furnace`). Art for trees, rocks and weeds is cut from `spr_tile_terrain`.
- Stats, cooking, food buffs and the cold: `food` (`stat(key)` is how to read any stat; the hearth is `obj_kitchen`).
- The mine: `mine` (seeded cave floors in `rm_mine`, bands, ladders, lift at `obj_mine_door` on the farm). Combat:
  `combat` (`weapon_table`, `monster_table`, `obj_monster`, knock-outs). Monster art: `spr_mon_*` from [LPC] Monsters,
  imported with `node tools/sprite_import.js <png> <spr_name>` (credited in `LPC_CREDITS.csv`).
- Magic: `magic` (spells, mana, scrolls `k|<spell>`; the player casts with F holding a staff, Q changes spell).
- Rooms: `rm_0` boot, `rm_menu`, `rm_creator`, `rm_1` farm, `rm_2` village, `rm_12` house (bed), `rm_3`, `rm_123`, `rm_mine`.
- Placeholder art drawn from `spr_tile_interior`: crafting table, bed, shipping bin, furnace (to be replaced with real assets).

## Conventions

- Data tables over code (crops, materials, recipes, races, shop stock).
- Comment the why, match surrounding style; commit with a clear message and push to `main` when a step is done.
- LPC art licences (CC-BY-SA / GPL / OGA-BY): keep `LPC_CREDITS.csv` and the in-game credits up to date.
