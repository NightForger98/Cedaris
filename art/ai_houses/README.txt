Buildings made by the game's developer with PixelLab (AI pixel-art generation, pixellab.ai, create_map_object),
from the developer's own Meshy concept pictures (content only, not style), 2026-11-04.
originals/<name>.png: the picture as made (objects over 200x200 come on a flat background colour).
<name>.png: game-ready (background cleared, trimmed to the building) by tools/buildings/ai_house.js.
Sprites in the project (Sprites/Houses): spr_house_<name>.

Settings for all: view "low top-down", detail "medium detail", shading "basic shading", outline "single color outline".

tavern_inn (256x224 canvas, 184x178 building): "pixel art tavern and inn building for a top-down 2D farming RPG in
the Liberated Pixel Cup (LPC) style. Straight-on front view: the front wall faces the camera, the dark slate roof is
seen from above, no isometric or perspective angle, symmetrical. Two storeys: red brick ground floor, cream
half-timbered upper floor with dark brown beams, small shuttered windows, one brick chimney. One centred arched
wooden door at the bottom middle. One hanging wooden sign with a beer mug beside the door, two barrels by the wall.
Crisp pixels, no anti-aliasing, 1px dark outline, light from the top left, soft muted palette. No ground, no
scenery, no text, simple and readable."

Each prompt below ends like the tavern's: "Crisp pixels, no anti-aliasing, 1px dark outline, light from the top
left, soft muted palette. No ground, no scenery, no text, simple and readable." The buildings fill about 70-85% of
the canvas.

blacksmith (352x320 canvas, 290x230): "pixel art blacksmith forge and armory building ... A wide two-storey building
with a large footprint that fills the whole canvas edge to edge. Straight-on front view ... dark slate roof ... Red
brick ground floor, cream half-timbered upper floor ... a tall brick chimney. One arched wooden door in stone at the
bottom centre. On the right, an open lean-to workshop under a slate roof with a glowing brick forge and an anvil. One
hanging shield-shaped sign with crossed hammers." (also "no smoke")
market (400x320 canvas, 324x187): "pixel art merchant market hall ... A long low wide two-storey building, much wider
than tall, its roof ridge running left to right, filling the whole canvas edge to edge ... golden thatched roof ...
Cream half-timbered upper floor ... three windows, a small gable over the middle. Ground floor: a wide open shop
front with striped green and white awnings on both sides, a few crates and sacks of produce under them. One centred
wooden double door at the bottom middle. One hanging sign with a coin sack."
market_small (352x320 canvas, 196x262): the first try at the market (gable front, narrower), same prompt without
"long low ... much wider than tall, its roof ridge running left to right" and with two windows.
town_hall (384x384 canvas, 328x338): "pixel art town hall with a central clock tower ... A wide two-storey civic
building with a large footprint that fills the whole canvas edge to edge, a square red brick clock tower in the
middle with a round white clock face and a small slate spire ... symmetrical. Red brick ground floor with pale stone
corners, cream half-timbered upper wings ... arched windows. One centred arched wooden double door with stone steps
at the bottom middle, two red banners."
alchemist (320x384 canvas, 260x320): "pixel art alchemist shop and library with a tall round red brick tower ... A
two-storey cream half-timbered house ... on the left and a tall round brick tower on the right topped by a dark slate
dome ... Arched windows, one with books behind it. One centred arched wooden door with a stone step ... One hanging
sign with a green potion flask, a small green and white awning over a potion shelf."
mill (384x320 canvas, 295x184): the second try. "pixel art watermill ... A long wide two-storey building, much wider
than tall, its roof ridge running left to right ... golden thatched roof ... Grey stone base, red brick and cream
half-timbered walls ... a stone chimney. A big wooden water wheel fixed to the left side wall of the building, its
bottom dipping into a narrow strip of blue water (a mill race) along the bottom edge under the wheel only. On the
upper floor, an open loft door with a small wooden hoist beam and a hanging sack. One centred wooden double door at
the bottom middle, a few crates and sacks beside it." The hoist didn't come. originals/mill_first_try.png is the
first (the wheel in a stone basin).

Second batch, from the developer's concept sheets (content only), chosen for the villagers. The words that keep a
building front-on: "wider than tall, its roof ridge running left to right ... no side walls visible".
ranch_barn (352x320, 286x311): ranch barn and stable - red-brown planks, white trim, hay loft door, X-braced double door,
  a hay bale and a trough.
carpentry (352x320, 312x167): second try - "One single connected long wide building ... under one continuous golden
  thatched roof ... Left half: cream half-timbered walls ... one wooden door. Right half: the same roof continues
  over an open workshop bay with stacked lumber planks, logs and a sawhorse. A small hanging sign showing only a
  picture of a saw, no letters." (the first try was two buildings with letters on the sign)
bakery (352x320, 244x238): red clay tile roof, cream plaster and beams, a round brick oven chimney, bread under a red
  and white awning, a bread sign.
church (352x384, 210x324): grey stone chapel, a square bell tower in the middle with a bronze bell and a slate spire,
  pointed arched windows, a rose window, an arched double door with steps.
weaver (352x320, 318x240): thatched, half-timbered, flower boxes, bolts of red, blue and green cloth, yarn, a spool
  sign.
small_house (256x224, 168x173): one-storey thatched cottage, two shuttered windows with flower boxes.
family_house (288x288, 196x233): two storeys, brick below and half-timbered above, slate roof, four windows, a porch,
  a bench.
brewery (352x320, 283x167): stone below, slate roof, kiln chimney, barrels by an arched double door. Its smoke is
  cut off by ai_house.js (FIX).
silo (256x352, 210x261): round stone silo with a slate cone and a small plank grain shed.
lighthouse (256x384, 168x322): second try - "stand directly on the bottom edge of the canvas, on no platform, no
  grass, no dirt, no rocks ... the bottom edge of the building is a straight horizontal line"; the thin grass strip
  it still had is cut off by ai_house.js (FIX). The first try stood on an angled slab of ground.
Three plain tries at a fisherman's hut all came out at an angle; see fisherman_hut below for the one that worked.

fisherman_hut (168x163), Marlo's - made a different way, since plain prompts always drew huts at an angle:
1. originals/fisherman_hut_base.png: small_house on a 192x192 grey canvas, its golden thatch recoloured to weathered
   grey-brown (by script, no generation).
2. PixelLab create_map_object in style-matching mode (background_image = the base, a custom mask =
   originals/fisherman_hut_mask.png, white over the walls only), 1 generation: "weathered fisherman's hut front wall:
   flat front elevation, the front wall parallel to the screen, no side wall visible, no perspective, no isometric.
   Weathered grey-brown wooden plank walls with dark beams on a low grey stone base, a small shuttered window on each
   side, one plain wooden door in the middle. A fishing net hung on the front wall, a coil of rope, a wooden crate of
   fish and two oars leaning by the door, a small lantern by the door. Crisp pixels, 1px dark outline, soft muted
   palette, LPC style". It returned only the new wall strip (originals/fisherman_hut_walls.png, rows 125-166).
3. originals/fisherman_hut.png: stitched by hand on magenta - the recoloured roof, the new walls, and the base's stone
   footing moved up 10 rows (the old door's bottom in it replaced by stone from beside it). ai_house.js clears the
   magenta (FIX). No net or lantern came out; the fish in the crate read as white blobs.

Third batch, 2026-11-05 (same settings and ending as above):
witch_tower (256x400 canvas, 151x336): "pixel art witch's tower ... A tall slightly crooked round dark grey stone tower,
  much taller than wide, filling the whole canvas edge to edge, topped by a tall pointed purple slate cone roof that
  leans a little. Straight-on front view ... no side walls visible ... Small windows glowing green, ivy climbing up the
  stone. One arched wooden door at the bottom middle, a black iron cauldron and clay herb pots beside the door."
guild_hall (384x320, 300x197): "pixel art adventurers' guild hall ... A long low wide two-storey building, much wider
  than tall, its roof ridge running left to right ... dark slate roof ... Grey stone ground floor, brown timber-framed
  upper floor with small windows. One big arched wooden double door at the bottom middle, above it a hanging red
  banner showing a crossed sword and bow. A wooden weapon rack ... a wooden notice board with pinned papers ..."
  The banner came out as crossed swords; the timber upper floor is only a thin band under the roof.
tool_shop (288x288, 200x214): "pixel art tool shop building ... A wide two-storey half-timbered shop, wider than tall,
  its roof ridge running left to right ... red clay tile roof ... Cream plaster with dark brown beams, small shuttered
  upper windows. One wooden door at the bottom middle, a big shop window beside it showing hoes, axes, watering cans
  and pickaxes. One hanging wooden sign showing only a picture of a hammer and wrench, no letters." The door came out
  on the left, not in the middle.
hospital (352x320, 260x210): "pixel art small town clinic building ... A long low wide two-storey building ... blue
  slate roof ... White plaster walls with pale stone corners and a pale stone base, tall narrow windows with white
  frames. One wooden double door at the bottom middle with two pale stone steps, above the door a white sign with a
  red cross, no letters." It wrote "CLINIC" on the sign anyway: originals/hospital_with_text.png is as made;
  originals/hospital.png has the letters painted out with the sign's white and the cross moved to the sign's middle
  (by script, no generation).
library (352x320, 299x240): "pixel art stately town library building ... A long low wide two-storey building ... dark
  slate roof ... with a small round green copper dome in the middle ... Red brick walls with pale stone trim, tall
  arched windows showing bookshelves inside. A pale stone portico at the bottom middle with two white columns and a
  triangular pediment, under it one wooden double door with stone steps." The dome came out tiny, on a chimney.

Street props (canvases under 200x200 come transparent; ai_house.js only trims them). Each ends "Crisp pixels, 1px
dark outline, light from the top left, soft muted palette. No ground, no shadow, no text, simple and readable."
prop_bench (80x56, 62x34): "wooden park bench with black iron legs and armrests ... Straight-on front view ... long and
  low, symmetrical. Brown wooden slats for the seat and backrest."
prop_lamp (48x104, 22x99): "black iron street lamp post with a warm glowing lantern on top ... a tall thin post on a
  small square base, the lit lantern glass warm yellow-orange, symmetrical."
prop_fountain (128x128, 110x117): "round stone town fountain ... Seen from the front and slightly above: a wide round
  grey stone basin full of blue water, a central stone pillar with a small top bowl, water spouting up ..." It came
  out seen from a corner a little, with the spout off-centre.
prop_planter (80x56, 60x43): "rectangular grey stone flower planter box full of red and yellow flowers with green
  leaves ... the long front face of the box parallel to the screen ..."
prop_campfire (64x56): "small campfire ... a ring of grey stones around a few crossed brown logs, with warm orange and
  yellow flames rising from the middle ... no smoke".

Fourth batch, 2026-11-05: workshops for five new families (352x320 canvases, same settings and ending as above,
"... no smoke" where there's a chimney). One try each - the trial's last 5 generations.
olive_press (263x152): "pixel art olive press house ... A long low wide building ... terracotta clay tile roof ... Rough
  pale stone walls. One wooden door at the bottom middle with clay oil jars and woven baskets of olives beside it. On
  the right, under the same roof, an open bay showing a big round stone olive mill wheel. A small hanging wooden sign
  showing only a picture of an olive branch, no letters." The wheel came out as a wooden cart wheel, the baskets as
  potted plants, the sign as a framed picture on the wall, and the door a little left of the middle.
tinker_workshop (173x274): "pixel art inventor's workshop ... A long low wide red brick building ... the big grey
  corrugated tin sheet roof ... One wide wooden garage-style double door at the bottom middle. Brass gears and copper
  pipes fixed on the brick wall, a small brass chimney on the roof. On one side a small lean-to over a wooden
  workbench with tools. A hanging sign shaped like a gear, no letters." It came out gable-front (ridge front to back)
  and narrow; the gears are small, and there are no pipes.
boatyard (304x148): "pixel art boatyard shed ... A long low wide weathered grey-brown timber plank shed ... weathered
  wooden shingle roof ... A wide open front at the bottom middle showing a half-built wooden rowing boat on two
  trestles inside. Oars leaning on the wall, coiled ropes, a small lantern hanging by the opening. A hanging wooden
  sign shaped like an anchor, no letters." The wood is purple-grey; the sign is square, with an anchor on it.
glassworks (234x152): "pixel art glassblower's workshop ... A long low wide building ... dark slate roof ... Pale stone
  walls. One wooden door at the bottom middle. On one side a big shop window with shelves of colourful glass bottles
  and jars in blue, green and amber. On the other side a round red brick furnace chimney rising above the roof, with
  a small arched opening at its foot glowing warm orange." originals/glassworks_with_mark.png is as made: it had a
  small signature-like mark in the bottom right corner, painted over in originals/glassworks.png. Bottles in both
  windows; the glow is in the chimney top; a bit of fence was added on the left.
stables (304x271): "pixel art horse stable barn ... A long low wide barn ... brown wooden shingle roof ... with a small
  wooden cupola in the middle of the ridge ... Dark timber frame with white plaster panels. One big wooden double door
  at the bottom middle, on each side a row of wooden stall half doors, a brown horse's head looking out over one of
  them. Hay bales by the wall, a leather saddle on a wooden rail. A hanging sign shaped like a horseshoe, no letters."
  It came out gable-front, with "HARSE" on the sign and a grey drop shadow on the right. originals/stables_with_text.png
  is as made; in originals/stables.png the letters are painted over with the sign's brown, a small horseshoe is
  drawn by hand in their place, and the shadow is cleared. No saddle; one stall rail with the horse, one hay bale.

Third batch, 2026-11-05, made through the PixelLab API (POST /v2/map-objects) on the developer's Tier 1 plan, from the
prompts in design/PixelLab_Asset_Brief.docx (tools/docs/pixellab_brief.js), each with "A long low wide building, much
wider than tall, its roof ridge running left to right." added before "Straight-on front view", the brief's style
reference as color_image (a forced palette), canvases rounded to multiples of 4 (the API needs it), 3 tries each and the
best kept. Settings as above.
Retried with other wording (no color_image, "cottage" not "farmhouse", "nothing around the building, plain flat grey
background, no signs") where the first tries came out at an angle or on a patch of ground: home_hayward, home_frere,
home_night, rangers_cabin, prop_beach_umbrella (the bench palette had taken its stripes), prop_sea_arch ("plain flat dark
grey background", so its pale rock doesn't melt into the background).
- homes: home_saba, home_brassbolt, home_saltwhistle, home_fairglass, home_hayward (the five families), home_larkspun,
  home_silverbough, home_frere, home_quill, home_ward, home_tawil, home_kassar, home_night (families that shared a house)
- farmhouse_1-4: the player's farmhouse for each upgrade (house_level 0-3). farmhouse_1 from the brief's prompt; 2-4
  with farmhouse_1 / farmhouse_2 as color_image (an init_image kept the old house unchanged at any strength)
- landmarks (spr_prop_<name>): museum, monastery, old_hangar, beach_bar, lifeguard_hut, rangers_cabin, fish_market,
  ferry_dock, cafe_terrace, roadside_shrine, merchant_cart, cliff_lookout
- props: prop_olive_tree, prop_grapevine, prop_gravestones, prop_shipwreck, prop_sea_arch, prop_tide_pools,
  prop_herb_bed, prop_swing, prop_flower_bed, prop_beach_umbrella, and for the last placeholders prop_keeper_garden,
  prop_miners_camp, prop_botanical, prop_overlook, prop_turtle_nests
Cleaning options added to tools/buildings/ai_house.js for these: tol (a speckled background), holes (background seen
through an arch), cutBottom for a path drawn down from the door.

Fourth batch, 2026-11-05: PixelLab remakes of the Meshy buildings still in the world (their finer detail and darker
palette didn't sit with the rest), same settings, the prompts' usual ending plus "nothing around the building, plain
flat grey background", a PixelLab building of the same kind as color_image, 3 tries each:
- lodge (the hotel, Well's Head; color tavern_inn), townhouse (the Goldcrests, Red Street; family_house), cottage (the
  Ironveins, Beacon Hill: a dwarf miners' stone cottage; blacksmith), windmill (Victory Hill; mill - retried without
  color_image, "fills the whole canvas, no ground, no base", its grass patch cleaned off), oakhart_farmhouse (Rowan's
  family of builders, Victory Hill; carpentry - a faint signature in a corner dropped as specks)
- the tavern now uses tavern_inn and the smithy blacksmith (PixelLab ones made earlier for them and never placed)
The Meshy sprites spr_house_barn, spr_house_farmhouse, spr_house_smithy and spr_house_tavern are no longer placed.
