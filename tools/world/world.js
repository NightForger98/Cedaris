// The new world (design/world_plan.md): 25 outdoor rooms on a 5 x 5 grid, laid out like Beirut, joined by roads,
// lanes and trails. Every outdoor room but the farm (rm_1, its own spec) is generated from this data by
// tools/world/room.js; the new interiors by tools/world/interiors.js. Change the world here, then:
//   node tools/world/make_specs.js && node tools/rooms/build.js all && node tools/rooms/worldmap.js
//
// links: for each side (l, r, t, b), the kind of way out: "road" (cobbles, the player's road boost), "lane" (dirt or
// sand, no boost) or "rocks" / "trees" (blocked - scenery for a later quest). A side not listed has no way out.
// Two neighbours must agree (checked by make_specs.js).
// buildings: library buildings (tools/rooms/buildings.json) with a door into an interior room; decor: buildings and
// big props without a way in. sea: "t" and/or "l" (the coast); river: the Beirut-like river down the room's west side.

const GRID = [
	["rm_wellshead", "rm_manara", "rm_starsand", "rm_hangar", "rm_plummet"],
	["rm_olivebay", "rm_redstreet", "rm_downtown", "rm_gracetower", "rm_beaconhill"],
	["rm_pigeonrocks", "rm_verdun", "rm_uptown", "rm_ovenswindow", "rm_victoryhill"],
	["rm_whitesand", "rm_winghill", "rm_dahya", "rm_resolve", "rm_yarzeh"],
	["rm_southbeach", "rm_1", "rm_sthereza", "rm_frere", "rm_abda"],
];

// kind: "town" (few trees), "rural", "wild" (woods) - how thick the trees are
const ROOMS = {
	rm_wellshead: {name: "Well's Head", w: 52, h: 40, sea: "tl", kind: "rural", links: {r: "lane", b: "lane"}, landmarks: [{ruin: "house", q: "se"}],
		buildings: [{key: "hotel", is: "house_lodge", room: "rm_hotel"},
			{key: "glassworks", is: "house_glassworks", room: "rm_glassworks"}, {key: "fairglass", ph: "Fairglass home", w: 7, h: 6, room: "rm_home_fairglass"}],
		decor: [{is: "well"}, {is: "fruit_table"}]},
	rm_manara: {name: "Manara's Light", w: 44, h: 36, sea: "t", kind: "rural", links: {l: "lane", r: "lane", b: "road"}, landmarks: [{ph: "Lookout point", w: 4, h: 3, q: "se"}, {ph: "Keeper's garden", w: 5, h: 3, q: "sw"}],
		buildings: [{key: "lighthouse", is: "house_lighthouse", room: "rm_lighthouse"}]},
	rm_starsand: {name: "Starsand Pier", w: 56, h: 40, sea: "t", kind: "town", links: {l: "lane", r: "lane", b: "road"}, landmarks: [{ph: "Fish market", w: 6, h: 3, q: "se"}, {ph: "Ferry to the island", w: 5, h: 3, q: "sw"}],
		buildings: [{key: "guild", is: "house_guild_hall", room: "rm_guild"}], pier: "t", pierStone: true,
		decor: [{is: "obelisk"}, {is: "stall_stripe"}]},
	rm_hangar: {name: "Hangar 12", buildings: [{key: "tinker", is: "house_tinker_workshop", room: "rm_tinker"},
			{key: "brassbolt", ph: "Brassbolt home", w: 7, h: 6, room: "rm_home_brassbolt"}], w: 52, h: 38, sea: "t", kind: "town", links: {l: "lane", r: "beach", b: "road"}, landmarks: [{ph: "Old hangar", w: 9, h: 5, q: "se"}],
		decor: [{is: "barn"}, {is: "shed"}, {is: "wagon"}, {is: "stall_cart"}], pier: "t"},
	// The witch's tower on the cliff top (plateau), a ladder up from the street; the beach runs west to Hangar 12
	// over the river by a footbridge (the Beach Bridge project mends it)
	rm_plummet: {name: "Plummet's Point", cliffEast: true, plateau: true, sea: "t", river: true, kind: "wild", links: {b: "lane", l: "beach"}, landmarks: [{ruin: "temple", q: "sw"}, {ph: "Cliff lookout", w: 4, h: 3, q: "se"}],
		buildings: [{key: "tower", is: "house_witch_tower", room: "rm_witch_tower", plateau: true}]},

	rm_olivebay: {name: "Olive Bay", w: 48, h: 36, sea: "l", kind: "town", links: {t: "lane", r: "road", b: "lane"}, landmarks: [{ph: "Olive grove", w: 8, h: 5, q: "se"}],
		buildings: [{key: "olivepress", is: "house_olive_press", room: "rm_olive_press"}, {key: "saba", ph: "Saba home", w: 7, h: 6, room: "rm_home_saba"}],
		decor: [{is: "stall_white"}, {is: "stall_stripe"}, {is: "fruit_table"}, {is: "well"}], pier: "l"},
	rm_redstreet: {name: "Red Street", w: 46, h: 36, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"}, landmarks: [{ph: "Cafe terrace", w: 6, h: 3, q: "se"}, {is: "prop_fountain", q: "sw"}],
		buildings: [{key: "goldcrest", is: "house_townhouse", room: "rm_home_goldcrest"}]},
	rm_downtown: {name: "Downtown", w: 64, h: 44, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"}, landmarks: [{is: "house_brewery", q: "nw"}],
		buildings: [{key: "tavern", is: "house_tavern", room: "rm_town_inn"}, {key: "bank", is: "house_town_hall", room: "rm_bank"},
			{key: "tools", is: "house_tool_shop", room: "rm_toolstore"}],
		plaza: true, decor: [{is: "well"}, {is: "stall_green"}]},
	rm_gracetower: {name: "Grace Tower", w: 52, h: 38, kind: "town", links: {t: "road", l: "road", b: "road"}, landmarks: [{ph: "Shrine", w: 3, h: 3, q: "se"}],
		buildings: [{key: "smithy", is: "house_smithy", room: "rm_village_smithy"}, {key: "whitlow", is: "house_family_house", room: "rm_home_whitlow"}],
		decor: [{is: "clock_tower"}]},
	rm_beaconhill: {name: "Beacon Hill", cliffEast: true, w: 50, h: 40, river: true, kind: "rural", links: {t: "lane", b: "lane"}, landmarks: [{is: "prop_campfire", q: "sw"}, {ph: "Miners' camp", w: 5, h: 3, q: "se"}],
		buildings: [{key: "ironvein", is: "house_cottage", room: "rm_town_home_se"}], mine: true,
		decor: [{is: "stall_cart"}]},

	rm_pigeonrocks: {name: "Pigeon Rocks", w: 44, h: 36, sea: "l", kind: "rural", links: {t: "lane", r: "road", b: "lane"}, landmarks: [{ph: "Sea arch", w: 5, h: 4, q: "nw"}, {ph: "Tide pools", w: 5, h: 3, q: "sw"}],
		buildings: [{key: "gullwater", is: "house_small_house", room: "rm_home_gullwater"}]},
	rm_verdun: {name: "Verdun Street", w: 56, h: 36, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"}, landmarks: [{ph: "Flower beds", w: 5, h: 2, q: "se"}],
		buildings: [{key: "bakery", is: "house_bakery", room: "rm_bakery"}, {key: "flowers", is: "house_market_small", room: "rm_flowershop"},
			{key: "furniture", is: "house_carpentry", room: "rm_furniture"}]},
	rm_uptown: {name: "Uptown", w: 56, h: 38, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"}, landmarks: [{ph: "Museum", w: 8, h: 5, q: "se"}, {ph: "Botanical garden", w: 8, h: 5, q: "sw"}],
		buildings: [{key: "hospital", is: "house_hospital", room: "rm_hospital"}, {key: "library", is: "house_library", room: "rm_library"}]},
	rm_ovenswindow: {name: "Oven's Window", w: 60, h: 40, kind: "rural", links: {t: "road", l: "road", r: "lane", b: "lane"}, landmarks: [{is: "house_silo", q: "ne"}],
		buildings: [{key: "quill", is: "house_small_house", room: "rm_town_home_nw"}, {key: "meadowlark", is: "house_ranch_barn", room: "rm_valley_ranch"}],
		decor: [{is: "barn"}, {is: "coop"}, {is: "hay_roll"}]},
	rm_victoryhill: {name: "Victory Hill", cliffEast: true, w: 54, h: 40, river: true, kind: "rural", links: {l: "lane", t: "lane", b: "lane"}, landmarks: [{is: "house_windmill", q: "ne"}, {ph: "Scenic overlook", w: 4, h: 3, q: "se"}],
		buildings: [{key: "oakhart", is: "house_farmhouse", room: "rm_village_rowan"}, {key: "mill", is: "house_mill", room: "rm_valley_carpentry"}],
		decor: [{is: "hay_roll"}, {is: "wagon"}]},

	rm_whitesand: {name: "White Sand Beach", w: 46, h: 38, sea: "l", kind: "rural", links: {t: "lane", r: "road", b: "lane"}, landmarks: [{ph: "Beach bar", w: 5, h: 3, q: "se"}, {ph: "Lifeguard hut", w: 2, h: 3, q: "sw"}],
		buildings: [{key: "shack", is: "house_fisherman_hut", room: "rm_beach_hut"}], pier: "l"},
	rm_winghill: {name: "Wing Hill", w: 54, h: 38, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"}, landmarks: [{ph: "Travelling merchant", w: 3, h: 2, q: "se"}],
		buildings: [{key: "kassar", is: "house_family_house", room: "rm_home_kassar"}],
		decor: [{is: "stall_stripe"}, {is: "stall_white"}, {is: "stall_green"}, {is: "stall_blue"}, {is: "fruit_table"}, {is: "stall_cart"}]},
	rm_dahya: {name: "Dahya", w: 56, h: 38, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"}, landmarks: [{ph: "Playground", w: 6, h: 4, q: "se"}],
		buildings: [{key: "larkspun", is: "house_cottage", room: "rm_town_home_e"}, {key: "clothes", is: "house_weaver", room: "rm_town_outfitter"},
			{key: "tawil", is: "house_townhouse", room: "rm_home_tawil"}], pines: true},
	rm_resolve: {name: "Resolve's Rise", w: 50, h: 38, kind: "rural", links: {t: "lane", l: "road", b: "road"}, landmarks: [{ph: "Herb garden", w: 6, h: 4, q: "se"}],
		buildings: [{key: "silverbough", is: "house_cottage", room: "rm_town_home_sw"}, {key: "potions", is: "house_alchemist", room: "rm_town_apothecary"}]},
	// Whispering Woods (once Yarzeh Woods): the deep wood itself now (Whisperwood, the generated forest east of it,
	// is gone), its shrine in a clearing; pixies and moths come out at night (scripts/forest)
	rm_yarzeh: {name: "Whispering Woods", cliffEast: true, dense: true, river: true, kind: "wild", links: {t: "lane", b: "trees"}, landmarks: [{ph: "Ranger's cabin", w: 5, h: 4, q: "nw"}, {ruin: "temple", q: "sw"}, {obj: "obj_shrine", w: 2, h: 3, q: "se"}]},

	rm_southbeach: {name: "South Beach", buildings: [{key: "boatyard", is: "house_boatyard", room: "rm_boatyard"},
			{key: "saltwhistle", ph: "Saltwhistle home", w: 7, h: 6, room: "rm_home_saltwhistle"}], w: 48, h: 38, sea: "l", kind: "rural", links: {t: "lane", r: "lane"}, landmarks: [{ph: "Shipwreck", w: 7, h: 4, q: "se"}, {ph: "Turtle nests", w: 4, h: 2, q: "sw"}]},
	rm_1: {name: "Player Farm", farm: true, links: {t: "road", l: "lane"}},
	rm_sthereza: {name: "Saint Thereza", w: 60, h: 40, kind: "rural", links: {t: "road", r: "road"}, landmarks: [{ph: "Vineyard", w: 8, h: 4, q: "nw"}],
		buildings: [{key: "nighthome", is: "house_farmhouse", room: "rm_village_hesta"}, {key: "seeds", is: "house_market", room: "rm_village_store"}],
		decor: [{is: "barn"}, {is: "coop"}, {is: "bee_shed"}, {is: "silo"}]},
	rm_frere: {name: "Frere's Fray", w: 46, h: 36, kind: "rural", links: {t: "road", l: "road", r: "road"}, landmarks: [{ph: "Monastery", w: 7, h: 6, q: "ne"}],
		buildings: [{key: "frere", is: "house_cottage", room: "rm_village_elda"},
			{key: "stables", is: "house_stables", room: "rm_stables"}, {key: "hayward", ph: "Hayward home", w: 7, h: 6, room: "rm_home_hayward"}]},
	rm_abda: {name: "Abda's Ascent", w: 54, h: 50, river: "spring", kind: "rural", links: {l: "road", t: "trees"}, landmarks: [{ph: "Graveyard", w: 6, h: 4, q: "se"}, {ruin: "house", q: "ne"}],
		buildings: [{key: "church", is: "house_church", room: "rm_church"}, {key: "ward", is: "house_small_house", room: "rm_home_ward"}]},
};

// The farm's ways out are in its own spec (tools/rooms/specs/rm_1.js); where you arrive there:
const FARM = {w: 77, h: 40, arrive: {t: [1296, 72], l: [64, 576]}};

// Where each grid cell is
const CELL = {};
GRID.forEach((row, r) => row.forEach((id, c) => { CELL[id] = [r, c]; }));

module.exports = {GRID, ROOMS, FARM, CELL};
