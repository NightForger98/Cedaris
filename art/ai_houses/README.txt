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
No fisherman's hut: three tries (the last with the wording above) all came out at an angle.
