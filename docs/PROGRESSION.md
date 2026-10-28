# Progression: items, dyes, crafting and shops

How Story mode unlocks clothing, colours and tools. Modelled on Terraria's inventory.

## Modes

- **Story**: human only; the creator edits body features only. You start in a red shirt, blue
  trousers and brown shoes (male, female or teen body, since that outfit exists for those bodies in
  the LPC art). Everything else is earned.
- **Free**: the full creator; crafting and Brom's shop cost nothing, and every dye can be crafted.

`global.inv.mode` holds the mode; `inv_is_free()` checks it.

## Items (`scripts/items`)

Item ids are strings, so saves and quest data can name them directly:

| id | what |
|---|---|
| `c|shirt|Longsleeve` | clothing from the LPC catalog (`c|<slot>|<catalog name>`) |
| `c|held|Hoe` | tool or weapon; held when selected on the hotbar |
| `m|linen`, `m|dragon_scale` | crafting material (`item_materials()` lists all 24 with rarity and stats) |
| `d|cloth|red`, `d|metal|gold` | dye or metal polish, put in a dye slot to recolour that piece |

A stack is `{id, count, pal}`. `pal` gives a clothing piece its own colour (the starter outfit uses it);
a dye in the matching dye slot overrides it when the dye suits the piece's material.

## How things unlock

- **Clothing** is crafted from materials at a crafting table (`obj_crafting_table`, press E). `item_recipe_cost()` sets the cost by slot (metal pieces use
  iron). The crafting list shows what you can make right now; clicking an equipment slot shows every
  recipe for that slot, dimmed until you have the materials.
- **Colours** come from dyes. Story mode has no dye recipes: dyes are quest and event rewards.
- **Tools and weapons** are bought from Brom (`item_shop_stock()` sets stock and prices). Right-click
  an item while trading to sell it. Every new game starts with a hoe, watering can, axe, pickaxe and scythe.
- **Gathering** (`scripts/gathering`): trees, stumps, rocks, ore veins, weeds and bushes spawn in areas
  of a room (`resource_areas()`), a few more each day up to a cap. The axe fells trees (they leave stumps
  that grow back in 7 days), the pickaxe breaks rocks and veins, and the scythe (or any swing) clears
  weeds. Drops go straight into the bag; Luck adds to the gem and coal chances.
- **Smelting** at Brom's furnace (`obj_furnace`, press E): 5 ore and a coal make a bar (copper, iron,
  silver, gold; mithril takes 2 coal); steel is an iron bar and 2 coal. **Weaving** at the crafting table
  (the Weave button): fibre into linen (4) or cotton (6). Recipes: `station_recipes()`.
- **Tool upgrades** at Brom's (the Upgrades tab): Copper, Iron, Steel, Gold and Mithril (`tool_tiers()`),
  each costing bars of that metal plus gold. Each tier does +1 damage and costs 10% less energy; the hoe
  and watering can work a row of 1 + tier cells (the can also holds 15 more water per tier), the scythe
  sweeps wider, and harder veins need a better pickaxe (iron needs Copper, silver Iron, gold Steel, mithril Gold).

## Materials, recipes and stats

- **24 materials in four rarities**: common (linen, cotton, wool, leather, fur, feather, bone, copper,
  iron), uncommon (silk, silver, steel, gold, gemstone), rare (troll hide, frost crystal, ember core,
  moonsilk, pixie dust) and legendary (mithril, dragon scale, phoenix feather, unicorn hair, void pearl).
  Brom sells the metal bars; rare and legendary ones are meant as quest and event rewards.
- **Gathered materials** (no stats; they feed smelting, weaving and later building): wood, stone,
  fibre, coal and copper, iron, silver, gold and mithril ore. Mithril ore isn't on the surface: it waits
  for the mine's deepest floors (phase 4).
- **Recipes** follow what the item is: `item_recipe_named()` for specific items (the Crown needs a void
  pearl), then keyword rules in `item_recipe_rules()` (anything with "chain" or "mail" takes iron, plate
  and great helms take steel, wizard hats take moonsilk and pixie dust), then a default per slot.
- **Stats** come from the recipe: each material adds its per-unit stats (iron: +2 Defence, -0.25 Speed;
  fur: +2.5 Warmth; pixie dust: +2.5 Luck, +1 Speed...). An item's rarity is its rarest ingredient.
  Everything equipped adds up (`inv_stats()`), shown under the character in the inventory.
- **Stats in use now** (`stat()` = what you wear plus your food buff): Speed changes walking speed (+5% per
  point, -30% to +40%); Charm lowers shop prices (1% per point, up to 30%) and raises selling prices (1% per
  point, up to 20%); Stamina adds max energy and lowers tool energy cost; Luck improves crop quality and gem
  and coal chances; Warmth keeps the cold off outdoors (cold beyond it drains energy). Defence and Magic wait
  for combat and spells.
- **Cooking** at the hearth in the house (`obj_kitchen`, press E): 8 dishes from produce of any quality (the
  lowest quality is used first), in `dish_table()` (`scripts/food`). Eating one gives energy and a timed buff
  (e.g. Carrot Soup: +4 Warmth for 6 hours); one buff at a time, and it ends when you sleep.

- **Magic**: hold a staff and press F to cast the selected spell (Q changes it). Mana is 30 + 10 per point of Magic,
  trickles back during the day and fills when you sleep. Spells come from scrolls (`k|<spell>`): Grow and Rain
  from Mara, Light from Brom, Fireball and Heal from the mine (lift-floor chests, rare drops). Better staffs
  (Simple, Gnarled, Loop, S, Diamond) add spell power.
- **The mine's treasure**: a chest on each lift floor (5, 10 ... 30) the first time you get there
  (`mine_chest_loot()`): bars, gems, staffs, the Fireball and Heal scrolls, and legendary materials at 30.

- **People**: 8 villagers (Brom, Mara, Pip and Rowan on the farm, Elda and Thorne in the village, Aunt Hesta and
  Tobin at home), each with a fixed look (`villager_table()` in `scripts/people`). E talks (+20 friendship once a
  day); G gives what you're holding (once a day: loved +80, liked +45, neutral +20, disliked -20, hated -40;
  better produce counts more). Charm adds 3% per point. Every 2 hearts (250 points each) they give you something:
  dyes, materials, a scroll, and a legendary material at 10 hearts. Brom and Mara trade from the dialogue (T).
- **Requests**: the notice board in the village offers 3 a day (`quest_templates()` in `scripts/quests`); carry up
  to 3. Deliveries are handed in at the board; hunts count monsters beaten after you take them. Rewards: gold,
  +60 friendship with whoever asked, and often a dye (story mode's main source of dyes) or a material.

- **Village projects** (the notice board's Projects page, `scripts/projects`): hand things in bit by bit. The East
  Bridge (wood, stone, iron) opens Whisperwood; the Old Well (stone, copper, a frost crystal) unlocks sprinklers;
  Aunt Hesta's Pantry (five dishes) gives +40 max energy; the Forest Shrine (moonsilk, gems, a frost crystal, an
  ember core) brings pixies to bless your crops at night.
- **Whisperwood** (`scripts/forest`): the same generated wood every visit, east across the bridge. Trees, bushes and
  forage come back daily: wild mushrooms and herbs (eat or cook them: Forest Stew gives +3 Magic) and red
  toadstools (Elda loves them). At night, pixies (pixie dust) and moon moths (moonsilk) - catch them with a swing.

## Hooks for quests and events

```gml
inv_add(item_stack("m|silk", 3));        // reward materials; returns how many didn't fit
inv_add(item_stack("d|cloth|purple"));   // reward a dye
inv_add(item_stack("c|hat|Crown"));      // reward a finished item directly
global.inv.gold += 50;                   // reward gold
inv_count("m|gem") >= 2                  // check a quest requirement
inv_take("m|gem", 2);                    // hand items in
```

Call `inv_apply_look(global.look)` after changing what's equipped from code.

## Ideas for later

- More crafting stations (a tailor's loom, Brom's anvil), each offering its own recipes.
- Recipes that need a specific collection (e.g. "Celestial Wizard Hat" needs silk + gems + a quest item).
- Dye mixing: combine two dyes into a new colour.
- Selling crops to a general store for gold.
