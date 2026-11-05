# The new world's blueprint (draft 3, 2026-11-06: Beirut's topography, roads and landmarks)

`world_blueprint.png` is the whole outdoor world, **one pixel = one tile** (282 x 232, the world itself 250 x 200 with
the sea to the west and north). Paint over it in any paint program to change the world, keeping to the colours below;
it gets turned into the real rooms. `world_blueprint_preview.png` is the same at 4x with names on it.
Made by `node tools/map/blueprint.js`.

| Colour (RGB) | Means |
|---|---|
| 36,92,158 / 64,140,204 / 110,180,225 | deep sea / sea / shallows |
| 236,214,140 | sand beach |
| 176,162,136 | rocky shore |
| 104,172,76 | grass |
| 128,186,88 | park or lawn (Sanayeh Garden, the Hippodrome's infield) |
| 40,112,52 | forest (broadleaf) |
| 30,92,58 | pine wood |
| 120,150,84 | hills, one step up (on top of a cliff) |
| 96,124,70 | highland, two steps up |
| 134,92,60 | cliff face |
| 150,138,124 / 240,244,248 | the summit, three steps up: bare rock / snow (the peak) |
| 170,168,160 | road (cobbles) |
| 196,164,106 | lane (dirt path) |
| 210,200,180 | town square |
| 138,104,62 | field (tilled) |
| 82,158,214 | river or pond |
| 120,84,52 | pier or bridge |
| 250,250,250 | a building's footprint |
| 40,34,32 | a cave mouth (the mine) |

Areas (the old rooms they replace): **Beirut** (Well's Head with the Riviera hotel on the bay in its north-west corner,
Red Street, Downtown, Grace Tower, Verdun Street, Uptown, Oven's Window - each a district with its old name on a
signpost), **North Beach** (Manara's Light, Starsand Pier, Hangar 12 - rocky, running into the cliffs), **West Beach**
(Olive Bay, Pigeon Rocks, White Sand Beach, South Beach), **The Mountain** (Plummet's Point, Beacon Hill, Victory Hill -
the mine, a road up to the peak), **The Outskirts** (Wing Hill, Dahya with its pine wood, Resolve's Rise - between the
farm and the town), **Whispering Woods**, **The Countryside** (Saint Thereza, Frere's Fray, Abda's Ascent), **The Farm**,
and **Bunny Island** (by ferry from Starsand Pier).

Draft 2 follows Beirut's real shape: the town on a low peninsula (sea to the north and west, its north-west corner
rounded), the port with Starsand's piers, the coast turning north-east past it to meet the mountain (North Beach), the
long straight West Beach to the south, the land rising east in steps (cliff faces where it steps down to the west or
south), and the Beirut River coming down from the south-east mountains and running north past the town's east edge into
the sea. Horsh Beirut's pines are in the Outskirts, south of the town.

Draft 3: the roads follow Beirut's real ones, simplified and widened for the game (main roads 3 tiles, streets 2): the
Corniche round the coast and on down the West Beach, the port road and the coast highway north-east, Hamra Street (Red
Street), the Ring, the Mazraa boulevard, Damascus Road south to Baabda (Abda), Bechara el-Khoury and the airport road to
the farm, the Mansourieh road over the river and up the mountain, and smaller streets (Verdun, Achrafieh, Basta, the old
Saida road to the Tayouneh roundabout). Buildings slide clear of the roads by themselves.
Landmarks: Zaitunay Bay's marina, Biel (Starsand Pier, the stone pier) and the port with its silos on North Beach; the
Ain el-Mreisseh fishermen's harbour; the Hippodrome by the Horsh pines; Sports City's stadium at Jnah (Wing Hill); the
National Museum at the Museum crossing; Sanayeh Garden; the Bourj Hammoud market over the river; palms on the Corniche.

## For moving things over later

- `world_layout.json`: the new roads and lanes by name (points in world tiles) and every building's footprint.
- `old_rooms.json` and `old_rooms_on_new.png`: where each of the 25 old rooms' ground lies on the new map, so their
  named spots and the villagers' routes (tools/rooms/specs, scripts/room_layout, scripts/schedules) can be moved over.
- `old_world_map.png`: the game's world map as it is now (the old 25 rooms).
