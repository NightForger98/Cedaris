# Charged tools and weapons (plan)

Hold the use button to charge a tool or weapon, then let go for a stronger action, like Harvest Moon: Friends of
Mineral Town (the look) and Stardew Valley (the timing). Status: **planned, waiting on the up/down reference
frames** for the wind-up poses (right is from the video; left mirrors it).

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
- Upgradable tools: one level per tier (Basic 0, Copper 1 ... Mithril 5). A Basic tool can't charge.
- Weapons: a fixed 2 levels, since weapons can't be upgraded.

**Energy:** a charged tool costs `tool_energy_cost × (1 + level)`. A charged weapon release costs 2 energy per level
(a tap is still free).

**Getting hit** (`player_hurt`) cancels the charge.

## Releases

| Item | Tap (level 0) | Charged release |
|---|---|---|
| Scythe | front sweep (as now) | **Spin**: cuts everything within a radius of `1 + level` cells around you |
| Watering Can | waters 1 cell (refills at water) | **Spin**: waters every tilled cell within a radius of `level` cells, 1 water each |
| Axe | one chop | **Large swing**: hits every tree/stump in a wide arc in front; damage `(1 + tier) × (1 + 0.5 × level)`; screen shake at level 3+ |
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

## Still to decide
- **Hammer and Shovel:** these aren't upgradable and don't do anything of their own yet. Should they charge like
  weapons (fixed 2 levels, a large swing), or not charge?
- **Up/down reference frames** (the user is fetching them).
