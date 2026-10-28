# Room builder

The farm (`rm_1`) and the village (`rm_2`) are built from specs in `tools/rooms/specs/`: a text map of the ground
plus the things placed on it. One command writes the room file, so a layout change is a text edit and a rebuild:

    node tools/rooms/build.js rm_1          (or several names, or "all")

It writes:

- `rooms/<room>/<room>.yy`: tile layers, merged `obj_col_box` collision boxes (plus a wall around the room),
  `obj_water_zone`s over water, and the spec's instances. Exits (`obj_transition`) go on the hidden Collisions layer.
- `scripts/room_layout/room_layout.gml`: every spec's named `points` and `areas`, read by scripts with
  `layout_point("rm_1", "cave")`, `layout_cells(...)` and `layout_area(...)` instead of hard-coded coordinates.
- `build/rooms/<room>.png`: a render of the room (blue: collision, cyan: water, yellow: exits, red: instances).

If GameMaker is open it will say "Project Directory Modified": choose **Reload**. Edits made to these rooms in the
room editor are overwritten by the next build, so change the spec instead (or stop building that room).

## A spec

```js
module.exports = {
	seed: 11,                  // the same seed always gives the same room
	map: ["....,,,,", ...],    // one character per 32px cell, see "legend" in tiles.js
	things: [{is: "farmhouse", at: [2, 7]}, {is: "pine", at: [0, 34]}],
	scatter: [{on: ".", density: 0.05, pieces: [{is: "leaves"}, {is: "mushrooms"}]}],
	instances: [{obj: "obj_plyr", x: 272, y: 592}, {obj: "obj_transition", x: 8, y: 576, sx: 1, sy: 4, code: "..."}],
	points: {start: [272, 592]},             // pixels
	areas: {pasture: [44, 22, 56, 30]},      // cells, inclusive
};
```

- **Map characters** (`tiles.js` legend): `.` grass, `,` dirt, `:` cobbles, `_` sand, `~` water (solid), `=` field
  soil (the `T_Soil` layer farming reads), `x`/`X` grass/dirt you can't walk on. A spec can add its own `legend`.
- **Terrains** are autotiled from LPC terrain blocks (3x6 cells: inner corners, the outer 3x3, fills): a cell picks
  its edge from its 8 neighbours. Keep areas at least 2 cells thick, or the edges look odd.
- **Things** (`tiles.js`): a rectangle of a tileset (`src`), or a **stamp** (`stamp`, a multi-layer piece in
  `stamps/`). `above` rows draw over the player (roofs, tree tops), `solid` cells block walking, `swap` recolours a
  stamp (the cottage kit repeats its walls and roofs in other colours). Overlapping things stack on extra layers.
- **Scatter** sprinkles walk-over decorations on free cells of the given map characters.

## Tools

- `node tools/rooms/render.js <room> [out.png] [--no-instances] [--scale 0.5]`: render any room, built or not.
- `node tools/rooms/capture.js <room> <name> <col> <row> <w> <h> [layers]`: save part of a room's tiles as a stamp
  (that's how the farmhouse and village hall were taken from the first test rooms).
- `node tools/rooms/tileset_import.js <png> <name>`: turn a 32px spritesheet into `spr_tile_<name>` + `TS_<name>`.
  Credit new art in `LPC_CREDITS.csv` and run `node tools/lpc/credits_gml.js` for the in-game credits.

To find a tile's coordinates, look at the sheet in a viewer with a 32px grid; `[col, row]` is pixel / 32.

## Art

- `TS_terrain`: the LPC Tile Atlas terrain sheet (its crops corner changed for this game).
- `TS_town`: the LPC Tile Atlas base sheet (`art/lpc_tile_atlas/`, with its attribution file).
- `TS_cottage`: the timber-framed cottage kit used for the houses.
