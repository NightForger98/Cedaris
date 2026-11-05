# Harvest Valley - the new world

> **Status (2026-11-05, branch `world-rebuild`):** prototype built:
> - the 25 rooms, roads, lanes and blocked ways;
> - every building and household below, the shops (Guild, mine stall, bakery, flowers, hospital and so on);
> - schedules for all 46 villagers;
> - the speeds, road boost and time freeze;
> - the story-mode gender creator.
>
> Marriage is being added. Not built yet: house/farm upgrades as buildings, the horse, minecart, sewers, cave passage
> and teleporting.
> Generated from `tools/world/world.js` (see CLAUDE.md, "The new world").

Based on `harvestvalleyconceptmap.docx`. The map is a 5x5 grid of rooms laid out like Beirut, and each room is sized to what's in it.
(M) = marriageable. Each person is shown as name - race - job. Current villagers are **bold**; everyone else is new.

## The map

| | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| **1** | Well's Head | Manara's Light | Starsand Pier | Hangar 12 | Plummet's Point |
| **2** | Olive Bay | Red Street | Downtown | Grace Tower | Beacon Hill |
| **3** | Pigeon Rocks | Verdun Street | Uptown | Oven's Window | Victory Hill |
| **4** | White Sand Beach | Wing Hill | Dahya | Resolve's Rise | Yarzeh Woods |
| **5** | South Beach | Player Farm | Saint Thereza | Frere's Fray | Abda's Ascent |

## Where the work happens (suggested)

| Room | Workplaces | Who works there |
|---|---|---|
| Olive Bay | The marina: a café or market stalls (to be decided) | - |
| Downtown | **Tavern & Inn** (food, drinks, rooms), **Bank**, **Tool store**, the town square (festivals, notice board) | **Lysa** runs the tavern, Sanji cooks, **Ida** serves, Ayla dances on weekends; Cassius (bank); **Mara** and Zenya (tools) |
| Wing Hill | **Market**, one room north of the farm (what it sells is undecided; one idea is stalls from the far-away shops on market days) | - |
| Verdun Street | **Bakery**, **Flower shop**, **Furniture shop** (furniture, house upgrades) | Sera (bakery), **Posy** (flowers), **Rowan** (furniture and house upgrades) |
| Uptown | **Hospital**, **Library** | Dr. Alban and Marigold (hospital, herbs); **Edwin** (library) |
| Starsand Pier | **Adventurers' Guild** in the seaside arena | **Hask** (ranged weapons), Sir Alaric (close-range weapons), quest board |
| Hangar 12 | The port: shipping, a ferry later. No villagers | - |
| Grace Tower | **Smithy** | **Brom** (buys ore, sells ingots, upgrades tools), Kael |
| Beacon Hill | **Mine** and the mine stall | **Garrick** mines; **Fen** sells ore and explosives at the stall |
| Victory Hill | **Lumber mill** (sells wood, builds farm buildings) | Garth runs the mill, sells wood and builds; **Thorne** fells the trees |
| Oven's Window | **Poupry's farm** (milk, wool, eggs, animals) | Poupry, **Wren** and **Pip** (farmhands) |
| Saint Thereza | **Night farm** (seeds and honey; it has animals but doesn't sell their produce) | Soren, **Hesta** |
| Dahya | **Clothes store** | **Nell** (owner), **Bryn** (leatherwork) |
| Resolve's Rise | **Potion shop** | **Elda** |
| White Sand Beach | **Fisherman's shack** and pier (rods, bait, buys fish) | **Marlo** |
| Well's Head | **Riviera Hotel** | Yubaba |
| Manara's Light | Lighthouse | Coralie |
| Abda's Ascent | The old church | **Father Aldous** |
| Plummet's Point | The witch tower (for now reached only from Beacon Hill) | **Morga** |
| Yarzeh Woods | The deep woods: foraging, hunting, monsters | - |
| South Beach | Empty beach the player can build on later | - |
| Red Street, Pigeon Rocks, Frere's Fray | Homes only | - |

## The households

| Room | Family | People |
|---|---|---|
| Well's Head | Vantelle | Yubaba - human - runs the hotel; Boh (M) - human - her son |
| Manara's Light | Lanternby | Coralie (M) - human - lighthouse keeper, lives alone |
| Plummet's Point | Thornwick | **Morga** - orc - the witch; Rook - half-orc - her son (Sir Alaric's, which nobody knows yet) |
| Red Street | Goldcrest | Cassius - human - banker; Liora (M) - human - his daughter |
| Grace Tower, house 1 | Ashford | **Brom** - human - blacksmith; Kael - human - his son, apprentice at the smithy (not marriageable) |
| Grace Tower, house 2 | Whitlow | **Mara** - human - older woman, owns the tool store; Clara (M) - human - her daughter |
| Beacon Hill | Ironvein (dwarves) | **Garrick** - miner; **Ida** - his wife, serves at the inn; **Fen** (M) - their son, grown up |
| Pigeon Rocks | Gullwater | **Old Marlo** - human - fisherman; Nerissa (M) - human - his daughter |
| Oven's Window, house 1 | Quill (elves) | **Edwin** (M) - librarian; Wynn - his teenage sister |
| Oven's Window, house 2 | Meadowlark | Poupry - human - runs the animal farm; Sanji - human - her husband, the tavern cook; Tauriel (M) - human - their daughter, an artist. Farmhands **Wren** and **Pip** (Bramble, halfling siblings) live in the farm bunkhouse |
| Victory Hill | Oakhart (orcs) | **Thorne** - lumberjack; **Rowan** - his wife, runs the furniture shop and does house upgrades; Garth (M) - their son, runs the lumber mill and builds |
| Wing Hill | Kassar | Zenya (M) - human - rebel, works at the tool store; Ayla - human - her sister, weekend dancer at the tavern |
| Dahya, house 1 | Larkspun | **Nell** - human - owns the clothes store; Mira (M) - human - her daughter |
| Dahya, house 2 | Tawil (beastkin) | **Bryn** (M) - brother; Dikhaj (M) - sister |
| Resolve's Rise | Silverbough (elves) | **Elda** - sells potions; **Hask** - her husband, the huntsman; Sylva (M) - their daughter |
| Saint Thereza | Night | Soren - human - farmer; Sera - human - his wife, works at the bakery; Jul - baby. **Aunt Hesta** is Soren's mother and **Tobin** his younger brother, so the player's cousins farm next door |
| Frere's Fray | Frere (halflings) | Dr. Alban - doctor; Marigold - his wife, the herbalist; **Posy** (M) - their daughter, the flower shop keeper |
| Abda's Ascent | Ward | **Father Aldous** - human - priest; Sir Alaric (M) - human - his son, the knight |

There are 16 marriage candidates: 6 men (Boh, Fen, Edwin, Garth, Bryn, Sir Alaric) and 10 women (Coralie, Liora, Clara,
Nerissa, Tauriel, Zenya, Mira, Dikhaj, Sylva, Posy).

### Changes to current villagers
- **Fen** grows up, from teen to adult, so he can be a candidate.
- **Hask** becomes an elf.
- **Bryn** and **Posy** become candidates.
- **Garrick** goes from watchman to miner.
- **Ida** moves from baking to serving at the inn.
- **Mara**'s seed shop becomes the tool store. Seeds now come only from the Night farm.
- **Morga** goes from apothecary to witch. Potions move to Elda.
- **Edwin** goes from scribe to librarian.
- **Rowan** goes from fence-mender to running the furniture shop.
- **Hesta** and **Tobin** stay the player's aunt and cousin.

All 21 current villagers are kept.

## Marriage (based on Friends of Mineral Town)

How FoMT works: courting means talking and giving gifts every day, with birthdays counting extra. A candidate has
four heart events at rising heart levels. You need a red heart, all four events seen, the house upgraded with the big
bed, and the **Blue Feather**, which is sold once the candidate reaches orange. Then you propose with the feather.

Mapped onto our 10 hearts (250 points each):
- Candidate heart events at **2, 4, 6 and 8 hearts**, using the heart events the game already has.
- The **Blue Feather** goes on sale at the tool store after a candidate's 8-heart event.
- To propose: **10 hearts**, all four events seen, the first house upgrade (it comes with the big bed) from Rowan's
  furniture shop, and the feather.
- Only candidates of the opposite gender. The player picks male or female in story mode.
- Wedding at the church in Abda's Ascent. The spouse then moves to the farm.

## House and farm upgrades (based on Stardew Valley)

Stardew's carpenter sells three house upgrades, each taking 3 days: a kitchen (10,000g + 450 wood), extra rooms
including a nursery (65,000g + 100 hardwood since version 1.6; it was 50,000g + 150 hardwood before), and a cellar
(100,000g). After the second upgrade there are renovations, which are instant and refundable. Farm buildings come in
tiers: coop, then big coop, then deluxe coop; barn, then big barn, then deluxe barn. There are also the silo, well,
stable and shed.

Split for us:
- **Rowan's furniture shop (Verdun Street)** sells furniture and the house upgrades:
  - first, a bigger house with a kitchen and the big bed (needed for marriage);
  - second, extra rooms and a nursery;
  - third, a cellar;
  - after that, renovations.
  
  Each upgrade costs gold and wood and takes 3 days.
- **Garth at the lumber mill (Victory Hill)** sells wood and builds the farm buildings and their upgrades: coop, big
  coop and deluxe coop; barn, big barn and deluxe barn; silo; well; stable; shed.
- Prices are set later, scaled to our economy rather than copied from Stardew.

## Roads and paths (proposal)

Each link between two rooms is one of three kinds:
- **Road:** cobbled, with the player's speed boost. Villagers' routes stick to roads.
- **Lane or trail:** dirt, sand or forest path, with no boost.
- **Blocked.**

Main roads (they have no names yet; the descriptions are just for this document):
- **Farm Road**, running north up column 2: Player Farm, Wing Hill (the market), Verdun Street, Red Street,
  Manara's Light.
- **The central road**, running north up column 3: Saint Thereza, Dahya, Uptown, Downtown, Starsand Pier. Column 3 is
  the town's spine.
- **Row 2**, the old town across the top: Olive Bay, Red Street, Downtown, Grace Tower.
- **Row 3**, across the middle: Pigeon Rocks, Verdun Street, Uptown, Oven's Window.
- **Row 4**: White Sand Beach, Wing Hill, Dahya, Resolve's Rise.
- **The south road**: Saint Thereza, Frere's Fray, Abda's Ascent (the church).
- **Other road links:** Hangar 12 to Grace Tower (the port road), Grace Tower to Oven's Window, and Resolve's Rise to
  Frere's Fray.

Lanes and trails:
- **the coast**, every link between two seaside rooms: Well's Head, Manara's Light, Starsand Pier and Hangar 12 on top;
  Well's Head, Olive Bay, Pigeon Rocks, White Sand Beach and South Beach down the west;
- the farm track from Player Farm to South Beach;
- the riverside trail from Oven's Window to Resolve's Rise;
- **the way into the eastern hills**: Oven's Window to Victory Hill over the one bridge, then Victory Hill to Beacon
  Hill (the mine) and Victory Hill to Yarzeh Woods;
- the steep path from Beacon Hill up to the witch tower at Plummet's Point.

No link at all:
- Player Farm and Saint Thereza;
- Grace Tower and Beacon Hill;
- Resolve's Rise and Yarzeh Woods.

Blocked:
- the cliff road from Hangar 12 to Plummet's Point, by rocks;
- the trail from Abda's Ascent to Yarzeh Woods, by trees.

Both are for later quests.

**The river** (like the Beirut River) runs from the hills at Abda's Ascent north between columns 4 and 5 and into the sea
by Hangar 12. It splits the map into the town and the eastern hills (Beacon Hill, Victory Hill, Yarzeh Woods). There is
one bridge, on row 3, from Oven's Window to Victory Hill. A single bridge reached only by lanes makes the east feel
remote, and the minecart and the cave passage much more worth having.

**Shortcuts on top of the roads:**
- the minecart, unlocked mid game, with stops at Wing Hill, Downtown, Beacon Hill and Victory Hill;
- the sewers, with entrances at Wing Hill, Verdun Street, Downtown and Dahya;
- the cave passage from Yarzeh Woods to Beacon Hill;
- teleporting later.

**Time on shortcuts:** the clock must keep running in the sewers, the cave passage and on the minecart, otherwise
freezing time indoors would make those trips instant. Each shortcut costs a short, fixed amount of time instead.

**Roads inside rooms:**
- Every road enters a room at the middle of the edge it uses and runs fairly straight to the far side, ideally no more
  than about 2,500 px across the room.
- Homes and shops sit along the roads.
- Lanes are where foraging spots, fishing spots and secrets go, so leaving the road trades speed for finds.

**Distances from the farm** (number of rooms crossed):
- the market: 1;
- seeds at Saint Thereza: 3, by Wing Hill and Dahya;
- the tavern and tools: 4;
- the smithy: 5;
- the church: 5, by Wing Hill, Dahya, Saint Thereza and Frere's Fray;
- the mine: 6, with the last 2 on lanes; or 2 stops on the minecart.

## Travel, time and seasons (agreed)

- **Speed:**
  - The player gets a road speed boost (about +25%) from day 1.
  - Better boots raise overall speed, and the bonuses stack.
  - No road boost for villagers. They walk at one steady speed everywhere, so their position, which is worked out
    from the clock, never jumps.
- **Getting around faster, as the game goes on:**
  - early game: a horse from Garth's stable;
  - mid game: a mine rail (minecart) to Player Farm or Wing Hill, Downtown, Beacon Hill and Victory Hill, repaired in a
    quest;
  - mid to late game: teleporting, with one-use totems first and permanent obelisks later. One idea is that the witch
    teaches it.
- **Shortcuts like Stardew's:**
  - the sewers under Downtown, connecting Downtown, Verdun Street and Dahya;
  - a cave passage from Yarzeh Woods to Beacon Hill.
- **Time freezes** indoors (the farmhouse included) and in the mine, as in Harvest Moon. Stamina and health limit the
  day, not the clock.
- **Starting numbers, to tune by playtesting:**
  - clock at 1.0 s per game minute (a day is about 20 real minutes);
  - player walk 3 px per frame, sprint 4.5, horse 6;
  - villagers at about 120 px per game minute.
  
  Once the rooms exist, an automated test times the real routes.
- **Seasons, as in Stardew and Harvest Moon:** each villager has a schedule per season, plus a different routine on
  the day their shop is closed. The schedules already support seasonal versions and a day off each week.

## Other work in the rebuild
- **Character creator, story mode only:** pick male or female first. Heads, bodies and other parts then only offer
  options that match. I'll go through the creator for any other mix-ups and list them. Free mode stays as it is.
- **Current rooms:** copied to a labelled desktop folder ("Harvest Valley - old rooms (pre-rebuild)"), then removed
  once the rebuild no longer needs them.
- **Plummet's Point:** the witch tower is reached from Beacon Hill. The rocks on the cliff road stay closed for now.
