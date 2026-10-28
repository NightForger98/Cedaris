# Charged tools and weapons (plan)

Hold the use button to charge a tool or weapon, then let go for a stronger action, like Harvest Moon: Friends of
Mineral Town (the look) and Stardew Valley (the timing). Status: **planned**. Reference frames are in for right
(left mirrors it), up and down.

## What the player sees

**Charging** (hold Left click / Space with a tool or weapon in hand):
1. The swing starts and freezes on its wind-up pose.
2. Every **0.6 s** (Stardew's timing) the charge goes up a level, to the item's maximum. Each level:
   - pulls the tool a little further back and down (the held layer moves about 2 px and tilts about 8° per level);
   - makes the tool glow brighter (the tool's metal colour; white-green for weapons);
   - flashes once when the level is reached.
3. At the second-to-last level the face goes red. At full charge an **anger mark** appears on the head
   (frames 4 and 5 of the reference).
4. While charging you can walk at half speed, but you keep facing the same way (Stardew 1.6 strafing). The cells that
   will be hit are outlined on the ground.
5. **Letting go** plays the release. Letting go before the first level fills is the normal tap action, as now.

**Max levels:**
- Upgradable tools: one level per tier (Basic 0, Copper 1 ... Mithril 5, Cursed/Blessed 6; see below). A Basic tool
  can't charge.
- Weapons: a fixed 2 levels, since weapons can't be upgraded.

**Energy:** a charged tool costs `tool_energy_cost × (1 + level)`. A charged weapon release costs 2 energy per level
(a tap is still free).

**Getting hit** (`player_hurt`) cancels the charge.

## Charge stages (the same in every direction)

From the reference frames for facing right, up and down. Left is the mirror of right, including the flames. Every
direction goes through the same stages in the same order; only where the tool sits changes.

| Stage | Level | Down | Up | Right (left mirrored) |
|---|---|---|---|---|
| Wind-up 1 | press | blade raised above the head, tipped back-left | back of head; blade held across the waist in front | blade raised upright |
| Wind-up 2 | 1 | blade tips further back behind the head | blade drops lower, out to the side | blade tilts back and down |
| Wind-up 3 | 2 | blade swings upright over the right shoulder | blade further back and lower | blade pulled furthest back |
| Red face | 3 | face tinted red | ears and neck red (the face can't be seen) | face and cheek red |
| Anger mark | 4 | on the front of the cap | on the back of the cap | on the side of the head |
| Full glow | 5 (Mithril) | the tool glows at its brightest | | |
| Yellow outline | 6 (Cursed) | a thin yellow outline round the whole character, pulsing while held | | |
| Flames | 6 (Blessed) | the outline for about 0.3 s, then two golden flame frames swapped to flicker | | |

- A tool stops at its own maximum. A Copper tool only reaches wind-up 2, only Cursed tools get the outline, and only
  Blessed tools get the flames.
- **Weapons** (2 levels) use the wind-up, then red face at level 1 and the anger mark at level 2.
- **Flames:**
  - One flame frame is drawn by hand (small tongues around the body outline).
  - The second is the same with the tongues shifted slightly, since the down reference only shows one frame.
  - At the moment of release the two frames play twice, then the spin starts.
  - Flame sprites for left are the right ones mirrored.
- **The outline** is the character's own sprite drawn 4 times, offset 1 px, flat yellow (`gpu_set_fog`), behind the
  character, so it fits any look.
- **Spin order:** the spin always starts from the way you're facing, then turns through the other facings. The frame
  it started on is added again at the end, so it finishes facing the way it began. For example, facing up: up, right,
  down, left, up.

## Releases

| Item | Tap (level 0) | Charged release |
|---|---|---|
| Scythe | front sweep (as now) | **Spin**: cuts everything within a radius of `1 + level` cells around you |
| Watering Can | waters 1 cell (refills at water) | **Spin**: waters every tilled cell within a radius of `level` cells, 1 water each |
| Axe | one chop | **Large swing**: hits every tree/stump in a wide arc in front; damage grows with level up to the full-charge share in the Cursed and blessed section; screen shake at level 3+ |
| Pickaxe | one strike | **Large swing**: the same for rocks and ores (it still can't break rock harder than its tier) |
| Hoe | tills 1 cell | Stardew area in front: L1 3×1, L2 5×1, L3 3×3, L4 6×3, L5 9×3 |
| Swords | slash | **Spin slash**: hits all around you, ×1.5 / ×2 damage |
| Spears, Halberd | thrust | **Lunge**: dash up to 2 cells forward (stops at walls), reach ×1.5, ×1.5 / ×2 damage |
| Club, Mace, Flail, Waraxe | swing | **Ground slam**: hits all around you, double knockback, monsters stunned for 1 s |
| Dagger | stab | **Flurry**: 3 quick stabs (2 at level 1) |
| Slingshot, Crossbow, Boomerang | shot | **Draw**: shot speed, range and damage ×(1 + 0.35 × level) |
| Staffs | spell (F) | no charge |

- **Tap changes:** today a tap of the hoe, watering can or scythe already reaches further with each tier
  (`tool_row_length`, the scythe's `reach`). The charge takes that over, so a tap becomes 1 cell, as in Stardew.
  Upgrade descriptions in `tool_upgradable` change to match ("Charges one level further").
- **Spin:** the body goes through the swing frame for each facing (down, right, up, left), about **3 turns in
  0.75 s** (measured from the video). Each facing is shown for about 4 game frames. A white-green oval trail is drawn
  round the feet. Its far half is drawn behind the character and its near half in front, and it fades as it goes;
  the watering can uses blue droplets instead. The area is cleared or watered as the trail passes, then the character
  stops facing down with the tool held low.
- **Large swing:** the normal swing at 0.8× speed, with an arc trail and small impact particles.

## How it's built

New script **`scripts/charge/charge.gml`**:
- `charge_max(item)`: the item's maximum level (from the tier, the weapon list, or 0).
- `charge_kind(item)`: one of `spin`, `water_spin`, `big_swing`, `hoe_area`, `spin_slash`, `lunge`, `slam`, `flurry`,
  `draw`, `none`. Weapon types come from a name list beside `weapon_table` (`scripts/combat/combat.gml`).
- `charge_cells(item, level, x, y, dir)`: the cells the release affects. The outline and the release both use this,
  so they always agree.
- `charge_release(user, item, level, dir)`: the effect. It reuses `farm_till`, `farm_water`, `gather_damage` and
  `monster_damage`, and covers areas and arcs that `gather_hit` and `combat_player_hit` don't.
- `charge_draw_ring(...)`, `charge_draw_glow(...)`, `charge_draw_face(...)`: the visuals.

**`objects/obj_plyr`:**
- `Create`: `charge = undefined` (`{item, t, level, dir}`).
- `Step_0`:
  - Pressing use with a chargeable item (`charge_max > 0`) starts the charge instead of `act`.
  - While the button is held, it counts up levels, allows half-speed strafing and charges energy at release.
  - Releasing builds the release `act` with `act.charge = level`.
  - The hit step calls `action_hit(..., level)`. It gets an extra `_level = 0` argument, and above 0 it hands over
    to `charge_release`.
- `Draw_0`: frozen wind-up during the charge, cycling facings for a spin, then the ring/trail.

**`scripts/character_look/character_look.gml`, `character_draw`:**
- The `_action` struct gains optional `heldDx`, `heldDy`, `heldAng`, `glow` and `blush` fields.
- The held layer uses `draw_sprite_general` so it can rotate.
- `glow` redraws the held layer additively.
- `blush` tints the head layer red. Step one is to test whether a draw colour survives the Lorikeet palette shader;
  if it doesn't, draw a red face overlay instead.

**Other changes:**
- **Art:** a small anger mark sprite, `spr_fx_anger` (hand-drawn, about 9×9, so no credit needed; or a CC0 emote
  credited in `LPC_CREDITS.csv`). The trail and particles are drawn in code.
- **Wind-up poses:** one table, `charge_pose`, holds the freeze frame for each animation (tool_axe, slash_oversize,
  thrust, watering...) and the offsets for each direction. Right is from the video, left mirrors it (`dx` flipped),
  and up and down come from the user's reference frames.
- **Fishing Rod:** Stardew's charge sets how far you cast. The power fills over about 1 s and sets the reach in
  `fishing_cast` (1–5 cells instead of the current first-water-within-3).
- **Autotest:** add a `charge <level>` command that charges the held item to that level and releases it, so a test
  doesn't need a real held button. Add new case **`tools/test/cases/charging.txt`** covering:
  - for each tool at each level in all 4 directions, a `shot` mid-charge and one mid-release;
  - checks that the hoe tills the right number of cells, the can waters the ring and uses that much water, the
    scythe clears its radius, and the axe/pickaxe arc breaks what it should;
  - weapons: spin and slam hit monsters behind you, the lunge stops at walls, and a hit cancels the charge.

## Steps

1. The charge state, levels, timing, energy, strafing, the ground outline and tap vs release, with releases for the
   hoe, can, scythe, axe and pickaxe (plain visuals).
2. Wind-up poses, glow, level flash, red face, anger mark (right/left; up/down placeholders).
3. Spin animation and trail (scythe, can), then the large swing trail and particles (axe, pickaxe).
4. Weapons: spin slash, lunge, slam, flurry, draw.
5. Fishing Rod cast power.
6. Up/down poses from the reference frames.
7. The test case, the full suite, and doc updates (`MILESTONES.md` and the upgrade text at Brom's).

## Cursed and blessed tools

Based on Friends of Mineral Town's cursed and blessed tools. These are the reference frames for their charge, after
the normal full-charge pose (red face, anger mark):
1. A thin **yellow glow outline** traces the whole character.
2. It grows into **small golden flames** licking up around the body. They get taller and fuller over a few frames
   until the character stands in a fire aura with sparks above the head.
3. The release is the normal spin with no flames, but it **cuts a larger area**.

**Tiers:** two new tiers after Mithril in `tool_tiers`: **Cursed** and **Blessed**.
- Both charge **6 levels**, with the same wind-up, red face and anger mark.
- **Level 6 looks different:**
  - **Cursed** gets the **yellow glow outline**, pulsing for as long as you hold it. No flames.
  - **Blessed** shows the outline briefly, then the **flames** (the two flickering frames).
- **Blessed is stronger than Cursed.** Each step up gives a bigger area, or more damage for tools that hit a single
  target:

  | Full charge (top level) | Mithril (L5) | Cursed (L6) | Blessed (L6) |
  |---|---|---|---|
  | Scythe spin radius | 6 cells | 7 cells | 9 cells |
  | Watering can spin radius | 5 cells | 6 cells | 8 cells |
  | Hoe area | 9×3 | 9×5 | 11×7 |
  | Axe / Pickaxe arc | 150° | 180° | 240° |
  | Axe / Pickaxe damage on the **biggest** tree or rock | 3 swings | **2 swings** | **1 swing** |

- **Axe and pickaxe damage at full charge** is set as a share of the biggest thing that tool breaks:
  - The table today: trees are 10 hp (axe), and a void node is 16 hp (pickaxe).
  - Blessed does 100% of that, so one swing. Cursed does 50%, so two swings. Mithril does 35%, so three swings.
  - Lower tiers do at least their tap damage plus their level.
  - It's worked out from the resource table, so a bigger tree or rock added later keeps the same rule.
- Only a **Mithril** tool (the last tier) can become Cursed. A Cursed tool can only become Blessed. Brom can't
  upgrade either one.

**The curse:**
- The tool **can't be unequipped**: it stays in your hand and blocks the hotbar keys and scroll, inventory moves,
  chests, selling and the bin (see open questions).
- It **drains energy faster**: `tool_energy_cost × 2`, so a charged swing costs `× 2 × (1 + level)`.
- Its icon gets a purple dot and a purple glint in the hand. A Blessed tool's icon dot is gold.
- Saved as `global.inv.tools[name] = 6` (Cursed) or `7` (Blessed). Save version goes to 10, and older saves load
  unchanged.

**The temple and the priest:**
- **The temple:** a new building. Outside, a room spec in `tools/rooms/specs/` (a plot in `rm_town` or `rm_2`),
  then `node tools/rooms/worldmap.js`. Inside, `rm_town_temple` with pews, an altar and a door; built with
  `node tools/rooms/build.js`. The temple is open 8am–6pm, and its doors lock outside those hours through
  `door_lock_reason`, like the shops.
- **The priest:** a new villager in `people.gml`, with an LPC look, dialogue, gifts and hearts. Their routine in
  `villager_routines`:
  - every day at the temple, working at the altar;
  - **Friday sermon from 9am to 10am**, with a few villagers' Friday routines sending them to the pews.
- **Blessing:** talk to the priest **on a Friday after the sermon (10am) and before the temple closes (6pm)**,
  holding a Cursed tool. A choice offers to bless it for **gold** (amount to be decided). The priest prays with the
  altar glowing, and the tool becomes Blessed.
  - At any other time the priest says when to come back: "Come on Friday, after the sermon."
  - Uses `obj_dialogue`'s existing choice mode, as heart events do.

**Built in** `scripts/gathering/gathering.gml` (tiers, `tool_cursed`, `tool_bless`), the hotbar and inventory code
(the lock), `scripts/people` and `scripts/schedules` (the priest and the sermon), the room specs, and
`tools/test/cases/curse.txt`. That test case covers: cursing a Mithril tool, the lock, the double energy, a blessing
refused on a Thursday or before the sermon, a Friday blessing working and taking the gold, and the 6th level's spin
radius.

**Build order:** this goes after step 3 of the steps above, since it needs the spin and level visuals; the temple
and priest can be built any time.

## Still to decide
- **How a tool becomes cursed.** The plan says only Mithril tools can be, but not how. One option is a cursed altar
  or chest in the Deep (past the bottom of the mine) that curses the Mithril tool you offer it, in exchange for the
  6th level.
- **What "can't be unequipped" means here.** Our held item is whichever hotbar slot is selected.
  - Stricter: the hotbar can't move off the cursed tool at all, so you can't eat, plant or use another tool until
    it's blessed.
  - Looser: the tool can't leave its slot or the bag (no storing, selling, binning), but you can still switch slots.
- **The blessing's price**, and **where the temple goes** (the town, by the inn, or the village).
- **Hammer and Shovel:** these aren't upgradable and don't do anything of their own yet. Should they charge like
  weapons (fixed 2 levels, a large swing), or not charge?
