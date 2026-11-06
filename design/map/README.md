# The new world's blueprint (draft 4, 2026-11-06: Beirut's topography, roads, landmarks and history)

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
| 92,78,64 | rails (the tram along the Corniche and Damascus Road; the old coast railway) |
| 190,178,150 | ruins (the Roman Baths, the Cardo, the temple at Beit Mery) |
| 214,204,184 | stairs (the Saint Nicholas Stairs) |

Areas (the old rooms they replace): **Beirut** (Well's Head with the Riviera hotel on the bay in its north-west corner,
Red Street, Downtown, Grace Tower, Verdun Street, Uptown, Oven's Window - each a district with its old name on a
signpost), **Phoenix Bay** (Manara's Light, Starsand Pier, Hangar 12 - rocky, running into the cliffs), **Sunset Coast**
(Olive Bay, Pigeon Rocks, White Sand Beach, South Beach), **The Mountain** (Plummet's Point, Beacon Hill, Victory Hill -
the mine, a road up to the peak), **The Outskirts** (Wing Hill, Dahya with its pine wood, Resolve's Rise - between the
farm and the town), **Whispering Woods**, **The Countryside** (Saint Thereza, Frere's Fray, Abda's Ascent), **The Farm**,
and **Bunny Island** (by ferry from Starsand Pier).

Draft 2 follows Beirut's real shape: the town on a low peninsula (sea to the north and west, its north-west corner
rounded), the port with Starsand's piers, the coast turning north-east past it to meet the mountain (Phoenix Bay), the
long straight Sunset Coast to the south, the land rising east in steps (cliff faces where it steps down to the west or
south), and the Beirut River coming down from the south-east mountains and running north past the town's east edge into
the sea. Horsh Beirut's pines are in the Outskirts, south of the town.

Draft 3: the roads follow Beirut's real ones, simplified and widened for the game (main roads 3 tiles, streets 2): the
Corniche round the coast and on down the Sunset Coast, the port road and the coast highway north-east, Hamra Street (Red
Street), the Ring, the Mazraa boulevard, Damascus Road south to Baabda (Abda), Bechara el-Khoury and the airport road to
the farm, the Mansourieh road over the river and up the mountain, and smaller streets (Verdun, Achrafieh, Basta, the old
Saida road to the Tayouneh roundabout). Buildings slide clear of the roads by themselves.
Landmarks: Zaitunay Bay's marina, Biel (Starsand Pier, the stone pier) and the port with its silos on Phoenix Bay; the
Ain el-Mreisseh fishermen's harbour; the Hippodrome by the Horsh pines; Sports City's stadium at Jnah (Wing Hill); the
National Museum at the Museum crossing; Sanayeh Garden; the Bourj Hammoud market over the river; palms on the Corniche.

## For moving things over later

- `world_layout.json`: the new roads and lanes by name (points in world tiles) and every building's footprint.
- `old_rooms.json` and `old_rooms_on_new.png`: where each of the 25 old rooms' ground lies on the new map, so their
  named spots and the villagers' routes (tools/rooms/specs, scripts/room_layout, scripts/schedules) can be moved over.
- `old_world_map.png`: the game's world map as it is now (the old 25 rooms).

Draft 4 adds, from what Beirut has and what makes a game map work:
- **Ways through** (`areas_proposal.png`, red rings; `areas.json` "ways"): every place a road, lane, bridge, rail,
  square or beach crosses from one new room into the next. Paths must match the map - exactly these, nowhere else.
  Room edges follow cliffs, the river, the sea or forest, with the way through at a road.
- **Unlockable links**: the ferry to Bunny Island; a **cable car** (like Jounieh-Harissa's) from the coast by Hangar 12
  up to the peak, a town project; Beirut's **old tram** (it ran until the 1960s) restored along the Corniche and down
  Damascus Road to Baabda, a town project giving fast travel between its stops.
- **History and art**: the **Roman Baths** and the **Cardo**'s columns downtown (the Wardens' ruins story, and a dig site
  whose finds go to the Museum), the **temple ruins at Beit Mery** on the mountain, the **Saint Nicholas Stairs** (the
  stairs of art, for an art festival), **Gemmayzeh**'s street of bars east of downtown, the **Sursock** gallery, and the
  **old Mar Mikhael station** on a disused coast railway (our Railroad).
- Landmarks to see from every room: the lighthouse, the port's silos, Biel's breakwater, the peak, the witch's tower,
  the cable car.
