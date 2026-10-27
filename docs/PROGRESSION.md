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
  an item while trading to sell it.

## Materials, recipes and stats

- **24 materials in four rarities**: common (linen, cotton, wool, leather, fur, feather, bone, copper,
  iron), uncommon (silk, silver, steel, gold, gemstone), rare (troll hide, frost crystal, ember core,
  moonsilk, pixie dust) and legendary (mithril, dragon scale, phoenix feather, unicorn hair, void pearl).
  Brom sells the metal bars; rare and legendary ones are meant as quest and event rewards.
- **Recipes** follow what the item is: `item_recipe_named()` for specific items (the Crown needs a void
  pearl), then keyword rules in `item_recipe_rules()` (anything with "chain" or "mail" takes iron, plate
  and great helms take steel, wizard hats take moonsilk and pixie dust), then a default per slot.
- **Stats** come from the recipe: each material adds its per-unit stats (iron: +2 Defence, -0.25 Speed;
  fur: +2.5 Warmth; pixie dust: +2.5 Luck, +1 Speed...). An item's rarity is its rarest ingredient.
  Everything equipped adds up (`inv_stats()`), shown under the character in the inventory.
- **Stats in use now**: Speed changes walking speed (+5% per point, -30% to +40%); Charm lowers Brom's
  prices (1% per point, up to 30%). Defence, Warmth, Stamina, Luck and Magic are ready for combat,
  seasons, energy, crop quality and spells.

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
