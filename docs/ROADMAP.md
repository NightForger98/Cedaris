# Roadmap: farming, stats, combat and magic

Implementation plan for the systems the equipment stats are waiting for. Stardew Valley is the reference
for how the loops feel (mechanics only, all content our own). Ordered so each phase builds on the last
and nothing gets built twice.

## Where we are

| Have | Missing |
|---|---|
| Player, NPCs, rooms, transitions, save slots | Time, days, seasons, sleeping |
| LPC characters (6 bodies, races), inventory, hotbar, dyes, crafting, Brom's shop | Using a held item: no tool or weapon actions |
| Equipment stats (Speed and Charm working) | Energy, health, damage, crop quality, cold |
| Crop prototype (plant with P, grow with G, 7 crops in `spr_crops`) | Tilling, watering, harvesting, selling, seeds |
| Universal LPC sheets: walk, thrust, slash, shoot, spellcast, hurt, watering rows | Tool/weapon swing art (LPC's custom oversized animations) |

## The animation data (from the LPC generator)

What each tool and weapon actually ships with, from the generator's `sheet_definitions`:

| Item | Player animation | Notes |
|---|---|---|
| Hoe, Shovel | `thrust` (64 px) | already in our sheets |
| Watering Can | `watering` (64 px) | already in our sheets (rows 21-24) |
| Axe, Pickaxe | `tool_axe` (128 px) | custom |
| Hammer | `tool_hammer` (128 px) | custom |
| Fishing Rod | `tool_rod` (128 px) | custom, not converted yet |
| Dagger, Spear, Cane, Crossbow, Simple staff | `slash` / `thrust` / `shoot` (64 px) | already in our sheets |
| Arming Sword, Katana, Scimitar | `slash_128`, `backslash_128`, `halfslash_128` | custom |
| Saber, Rapier, Glowsword, Longsword, Mace, Flail, Waraxe, Scythe | `slash_oversize` (192 px) | custom |
| Staffs, Halberd, long spears | `thrust_oversize` (192 px) | custom |
| Bows, Slingshot | `shoot` (64 px) | already in our sheets |

**Watering isn't separate art**: the generator's own table (`sources/state/constants.ts`) plays it as
thrust frames 0, 1, 4, 4, 4, 4, 5, so it works for every body that can thrust.

**How LPC custom animations work** (`sources/custom-animations.ts`): each is a frame size plus, per
direction, a list of frames taken from the body's standard animations, e.g. `tool_axe` = slash frames
5, 5, 4, 4, 3, 1, 0, 0, 0, 0 at 128 px. So:

- **Bodies and clothes need no new art.** They replay frames from the slash/thrust rows we already have.
- **Only the tool or weapon layer** needs a new, larger sprite sheet, drawn centred on the 64 px body.

This makes every tool and weapon swing one renderer feature plus a pipeline step, not 1000 new sheets.

## Principles (to keep it efficient)

1. **One action system for everything you do with the held item.** Hoeing, watering, chopping, mining,
   attacking and casting are all "play an animation, do something on the action frame, cost energy".
   Tools, weapons and spells become rows in a data table.
2. **Data tables over code**, like `items`: crops, resources, monsters, weapons and spells each get a
   table, so content is added without touching systems.
3. **Reuse the character system for enemies.** Goblins, orcs, skeletons, zombies, trolls and wolfkin
   are already LPC races; humanoid monsters are looks plus AI, with no new art.
4. **One world-state store per room** (tiles, crops, resources), saved with the game, replacing the
   crops object's ds_grids.
5. **Bump `SAVE_VERSION` with every phase** and migrate old saves in `load_game`.
6. **Test with the automated run** (`tools/test/autotest.sh` with a case from `tools/test/cases`) at the end of each phase.

---

## Phase 0: Foundations (everything else needs these)

### 0.1 Action system and animation state
- Player state machine: `idle`, `walk`, `act` (tool/weapon/spell), `hurt`, `dead`. Movement locked during `act`.
- Animation table: `{row, frames, fps, actionFrame, frameSize, sequence}`, where `sequence` covers LPC custom animations.
- `character_draw` gains an optional *action layer*: body/clothes draw frame `sequence[i]` from their
  normal row; the held item draws frame `i` from its oversized sheet, offset by `(frameSize - 64) / 2`.
- Input: left click or **C** uses the held item. Target = the tile in front of you (Stardew style), or
  the tile under the mouse when it's within one tile.
- **Done when:** the hoe thrusts, the watering can pours and the axe swings with correct art in all 4 directions.

### 0.2 Pipeline: custom animations
- `plan.py`: keep layers with `custom_animation` instead of skipping them; record each item's animation list.
- `convert.ps1`: assemble custom layers at their frame size (128 or 192) into separate `lpc_*_<anim>` sprites.
- Catalog: per item `actions: {tool_axe: {frameSize, sprite per body, sequence}}`; copy sequences
  from `custom-animations.ts` into a generated `lpc_custom_animations` script.
- Also convert **Fishing Rod** and **Whip** (skipped so far) and the oversized-only weapons
  (Katana, Longsword alt, Scimitar, long spears, bows' `walk_128`).
- **Memory:** split each item into a *base* sprite (walk, idle, hurt) and an *action* sprite (thrust,
  slash, shoot, spellcast, watering). GameMaker loads texture pages when first drawn, so most action art
  stays unloaded until used. Put LPC art in its own texture group.

### 0.3 Time, calendar and sleep
- Clock: 6:00 to 2:00, 10 game minutes every ~7 real seconds (paused in menus and the inventory).
  4 seasons x 28 days, then years.
- Day/night tint over the world (light layer); shops keep hours.
- Bed in the house: sleep ends the day. At 2:00 you pass out and lose some gold.
- **New-day event** (one function, called in order): crops grow, resources respawn, shipping payout,
  daily luck roll, energy/health refill, **autosave**. Every later system hooks in here.
- HUD: clock, day, season, weather icon.

### 0.4 Energy and health (HUD bars)
- Energy (Stardew-like 270 base): tools cost energy; at 0 you're exhausted (slow, can't use tools).
- Health (100 base) for combat.
- **Stamina stat** raises max energy and lowers tool energy cost; food restores both (Phase 1 crops become food).

### 0.5 World state and save v2
- `world` struct per room: `tiles[x][y] = {tilled, watered, crop, object}` plus `objects` (rocks, trees, weeds).
- Replace the crops object's grids and room-end saving with this; save/load all rooms' world state.
- Remove the debug G key (growth is daily now).

## Phase 1: Farming loop (Stardew core)

| Step | What | Uses |
|---|---|---|
| Till | Hoe on soil marks the tile tilled (soil tile changes) | `thrust`, energy |
| Seeds | Seed items per crop, sold at a new **general store** (shopkeeper NPC, same shop UI as Brom) | inventory, shop |
| Plant | Use seeds on tilled soil | hotbar item use |
| Water | Watering can: capacity, refill at the pond, watered soil darkens until morning | `watering` |
| Grow | Each new day: watered crops advance a stage; crops have seasons and die out of season | new-day event |
| Harvest | Interact with a ripe crop, get produce; some crops regrow | |
| Quality | Normal / silver / gold stars, chance from **Luck** stat plus daily luck | Luck |
| Sell | Shipping bin: drop produce in, paid overnight | gold |
| Eat | Produce restores energy (and later gives buffs) | Stamina |

- Crop table: `{name, seasons, stageDays[], regrowDays, seedPrice, sellPrice, energy}`; the 7 crops in `spr_crops` first.
- Scarecrows and sprinklers come later as craftable placeables (the crafting table already exists).

## Phase 2: Gathering, smelting and tool upgrades

- Resource objects in the world: trees and stumps (**axe**, `tool_axe`), rocks and ore veins
  (**pickaxe**, `tool_axe`), weeds and grass (**scythe**, `slash_oversize`). Each has HP, drops and a respawn time.
- New materials: wood, stone, fibre, copper/iron/gold/mithril **ore**, coal.
- **Smelting** at Brom's furnace: ore + coal turn into the bars our recipes already use (copper, iron, steel = iron + coal, gold, mithril).
- **Tool upgrades** at Brom, using our bars as tiers: copper, iron, steel, gold, mithril.
  Higher tiers hit bigger areas or harder rocks and cost less energy (as in Stardew).
- Fibre can become linen and cotton at a loom (crafting station), so clothing gets a full supply chain.
  (Done at the crafting table for now; a loom can take it over once there's art for one.)

## Phase 3: Stats come alive

| Stat | Effect | Hooks into |
|---|---|---|
| Speed | done | |
| Charm | done: buying (-1%/point) and selling (+1%/point, up to 20%); friendship gain still to come | Phase 6 |
| Stamina | done: +max energy, -tool energy cost | Phase 0.4 |
| Luck | done for crop quality and gem/coal chance; monster drops and crit chance to come | Phases 1, 2, 4 |
| Warmth | done: outdoors, cold (spring 1, summer 0, fall 2, winter 5, +2 after 8 pm) beyond your Warmth drains energy; `climate_cold()` can go negative for heat zones later | Phase 0.3 seasons |
| Defence | damage taken = damage - Defence (minimum 1), as in Stardew | Phase 4 |
| Magic | mana pool and spell power | Phase 5 |

- One function `stat(key)` = equipment + food buffs (`scripts/food`). Race perks are still an optional idea.
- Food buffs: 8 dishes cooked at the hearth in the house (`obj_kitchen`) from produce of any quality; one buff at a time, timed `{stat: amount}` until a time of day or sleep, shown under the clock.

## Phase 4: Combat and the mine

- **Player:** health, invulnerability frames, knockback, death (wake at home, lose some items and gold).
- **Weapons:** add to the weapon item defs `{type, damage[min, max], speed, knockback, crit, anim}`.
  - Sword: slash, balanced. Dagger: fast stab. Club, mace, waraxe: slow, heavy, wide.
  - Spear and halberd: long thrust. Bow and slingshot: projectiles (`shoot`). Staff: magic focus (Phase 5).
  - The hitbox is active on the animation's action frames only.
- **Monsters:** one parent object `{hp, damage, defence, speed, xp, drops, ai}`. AI states are wander, chase, attack, hurt, dead.
  - Humanoids reuse LPC looks: goblins, orcs, skeletons, zombies, trolls, wolfkin. They're random looks from the race table.
  - Creatures (slimes, bats, pixies, dragons) need other art. LPC-compatible monster sets exist on
    OpenGameArt; check each licence and add it to `LPC_CREDITS.csv`.
- **The mine:** generated while the game runs, one seeded layout per floor (see `docs/LEVELS.md`): floors with rocks (ore), monsters and a ladder down, a lift every 5 floors, deeper floors
  with tougher monsters. This is the main source of the **rare and legendary materials**:

| Material | Source |
|---|---|
| Troll Hide | trolls, mid floors |
| Frost Crystal | ice floors' rocks |
| Ember Core | lava floors' rocks |
| Pixie Dust | pixies (creature art) |
| Moonsilk | moth monsters, or a night-only forest event |
| Mithril ore | deepest floors |
| Dragon Scale | dragon boss, or very rare |
| Phoenix Feather, Unicorn Hair, Void Pearl | quest rewards and events (Phase 6) |

## Phase 5: Magic

- Mana pool from the **Magic** stat; it regenerates slowly and refills on sleep.
- Spells cast with a staff held, using `spellcast` (64 px) or `thrust_oversize` for staffs.
  - Farm spells first: **Grow** (advance one crop a stage), **Rain** (water an area).
  - Then Light (mine darkness), Fireball (projectile) and Heal.
- Spell table `{name, mana, anim, effect, unlock}`; spells learned from quests or scrolls.
- Built (step 8): `scripts/magic`. Scrolls are items `k|<spell>`; hold one and use it to learn the spell.

## Phase 6: People, quests and Charm

- Friendship hearts per NPC: talk daily, gifts with loved/liked/disliked tables. **Charm** speeds up friendship gain.
- Dialogue boxes with portraits (an LPC look drawn large) and simple per-day and per-heart lines.
- Quest board and requests, rewarding the materials and dyes already planned (`docs/PROGRESSION.md`).
- Villagers get saved looks and homes, so the village stays the same people (they're random today).

---

## Order, size and why

| # | Phase | Size | Status |
|---|---|---|---|
| 1 | 0.2 Pipeline custom animations | M | **done** (27 items, 87 swing sprites) |
| 2 | 0.1 Action system | M | **done**: click/Space uses the held item; `action_hit` is the hook for effects |
| 3 | 0.3 Time + 0.4 Energy/Health + 0.5 World state | L | **done**: clock, seasons, night tint, bed and passing out, new-day event with autosave, energy/health HUD, per-room world store (save v2) |
| 4 | 1 Farming loop | L | **done**: till, seeds (Mara), plant, water (pond refill), watered-only growth, seasons, harvest with Luck quality, regrowing crops, eating, shipping bin |
| 5 | 2 Gathering + smelting + upgrades | M | **done**: trees/stumps (axe), rocks and ore veins (pickaxe, hardness by tier), weeds and bushes (scythe) spawning in farm areas and regrowing daily; wood, stone, fibre, coal, 5 ores; smelting at Brom's furnace, weaving fibre at the crafting table; Copper to Mithril tool upgrades at Brom's (save v3) |
| 6 | 3 Stats wiring (Warmth, buffs) | S | **done**: `stat()` with food buffs, cooking at the hearth (8 dishes), winter/night cold vs Warmth, Charm selling bonus |
| 7 | 4 Combat + mine | XL | **done (core)**: 30-floor mine generated at runtime (earth, ice, lava bands; lift every 5), weapons table, 11 monsters (LPC humanoids + [LPC] Monsters creatures), Defence, Luck crits/drops, heat and cold, knock-outs; still to come: dragon boss, pixies and moths, ranged monsters (save v4) |
| 8 | 5 Magic | M | **done**: mana (30 + 10/Magic), 5 spells from scrolls (Grow, Rain from Mara; Light from Brom; Fireball, Heal from the mine), cast with a staff (F, Q to change), staff power; treasure chests on mine lift floors (save v5) |
| 9 | 6 Social and quests | L | Charm, rewards; ties progression together |

S = a session, M = 1-2 sessions, L = 2-4 sessions, XL = 4+ sessions.

## Risks to watch

- **Animation gaps by body:** in LPC, the muscular body has no `shoot` or `watering` rows, the child body
  has almost no tool art, and teen has fewer weapons (13 of 26). Plan: allow an action only if the
  body has it, else fall back to the closest row (e.g. `thrust` for watering) and show a hint.
- **Memory:** 1016 sheets plus action sheets. The base/action split and a texture group for LPC art keep it in check.
- **Save migration:** each phase changes the save; keep `SAVE_VERSION` checks and upgrade old saves.
- **Licences:** creature art from outside the LPC generator must be CC-BY-SA/GPL/OGA-BY compatible and credited.
