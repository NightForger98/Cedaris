# Milestones after the roadmap

The roadmap's nine steps (`docs/ROADMAP.md`) gave the valley its systems: farming, gathering, smelting, tools,
stats and food, the mine and combat, magic, villagers and requests. What it doesn't have yet is a reason to
use them all together, weather and a world beyond the farm, the village and the mine. These milestones are
ordered so each one builds on the last.

## What's missing, and why it matters

| Gap | Why it matters |
|---|---|
| No long-term goal | The loops work, but nothing asks you to combine them (crops + ore + monster drops). |
| No weather | Every day is the same; the watering can is a chore with no break. Phase 0.3 already planned a weather icon. |
| Pixie dust and moonsilk have no source | The roadmap pinned them on pixies and moths in a night forest, which doesn't exist. |
| Nowhere new to go | Three outdoor places in total. The village's east edge just ends. |
| Watering never gets easier | Stardew's sprinklers are the big mid-game upgrade; ours would come from smelted bars. |
| The Fishing Rod does nothing | It's in Brom's shop and the catalog, but there's no fishing. |

## Milestone 10: The Living Valley

| # | Step | Size | Uses |
|---|---|---|---|
| 10.1 | **Done.** **Weather**: sun, rain, storms in summer, snow in winter, rolled each new day with tomorrow's forecast (Aunt Hesta tells you). Rain waters every tilled tile; rain and snow add cold; drawn as rain and snow over outdoor rooms; a weather icon by the clock. | S | world_time, farming, food (cold), people |
| 10.2 | **Done.** **Village projects** (the "long-term goal"): a Projects page on the notice board. Each project asks for a list of things you hand in over time; finishing one rebuilds part of the valley. Mend the East Bridge -> Whisperwood opens. Raise the Old Well -> sprinklers can be crafted. Stock Aunt Hesta's Pantry -> +40 max energy for good. Light the Shrine (in Whisperwood) -> pixies come to your farm at night. | M | quests (board), items, people (friendship for helping) |
| 10.3 | **Done.** **Whisperwood**: a new forest east of the village, across the bridge. A wild place, so generated once from a fixed seed (the same every time, like a mine floor's shape - see `docs/LEVELS.md`), with paths, clearings and a pond. Hardwood trees, wild foraging (mushrooms, berries, herbs), and at night **pixies** (pixie dust) and **moths** (moonsilk) - the missing sources. An old shrine sits in its heart. | L | mine generation code, gathering, combat (creatures), weather |
| 10.4 | **Done.** **Sprinklers**: placeable objects crafted from bars (copper: the 4 cells around it; iron: 3x3; gold: 5x5), watering every morning. Placing things on the farm becomes a general system (scarecrows and chests can follow). | M | crafting table, world store, farming |
| 10.5 | **Done.** **Fishing**: cast at water with the rod, a timing minigame, fish by season, place and weather (a fish table like the crop table); fish sell well and cook into dishes. | M | actions, items, food |

## Milestone 11: Festivals and animals

- **Festivals**, one per season on a fixed day: the Seedling Fair (spring), Lantern Night on the river
  (summer), the Harvest Weigh-in (fall: your best produce is judged, quality matters), the Frost Market (winter:
  a once-a-year shop). The village is decorated, villagers gather, friendship gains are doubled.
- **Done:** festivals (`scripts/festivals`: Seedling Fair, Lantern Night, Harvest Weigh-in, Frost Market).
- **Done:** animals (below, simplified: no buildings - they roam the meadow).
- **Animals**: a coop and a barn bought from Thorne; chickens, cows and sheep (LPC farm animal art on
  OpenGameArt is CC-BY-SA - check each sheet) giving eggs, milk and wool. Wool makes the clothing chain
  complete (it's bought today).

## Milestone 12: The deep

- **Bosses**: a guardian on floors 10 and 20 and a dragon on floor 30 (the Dragon Scale's real source).
- **Ranged monsters**: watchers fire bolts, lizard warriors throw spears (the slime projectile sheet exists).
- **Below the mine**: an endless "deep" with harder floors, for players who've finished everything.

## Art we'll need

| For | What | Where to look (licence-safe) |
|---|---|---|
| Weather | none (drawn) | |
| Whisperwood | the terrain tileset has trees, bushes, mushrooms, water; pixies and moths need sprites | OpenGameArt LPC-compatible insects / fairies (CC-BY-SA, OGA-BY, CC0) |
| Sprinklers | a small sprite | draw it, or LPC farm items |
| Fishing | fish icons; the rod's casting animation (LPC `tool_rod`, not converted yet) | LPC generator (rod), CC0 fish icon packs |
| Animals | chicken, cow, sheep sheets | "LPC farm animals" on OpenGameArt |

Everything downloaded goes in `LPC_CREDITS.csv` and is regenerated into the credits (`tools/lpc/credits_gml.js`).
