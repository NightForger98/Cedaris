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
	rm_wellshead: {name: "Well's Head", w: 52, h: 40, sea: "tl", kind: "rural", links: {r: "lane", b: "lane"},
		buildings: [{key: "hotel", is: "brick_arch", room: "rm_hotel"}],
		decor: [{is: "well"}, {is: "fruit_table"}]},
	rm_manara: {name: "Manara's Light", w: 44, h: 36, sea: "t", kind: "rural", links: {l: "lane", r: "lane", b: "road"},
		buildings: [{key: "lighthouse", is: "clock_tower", room: "rm_lighthouse"}]},
	rm_starsand: {name: "Starsand Pier", w: 56, h: 40, sea: "t", kind: "town", links: {l: "lane", r: "lane", b: "road"},
		buildings: [{key: "guild", is: "brick_hall", room: "rm_guild"}], pier: "t",
		decor: [{is: "obelisk"}, {is: "stall_stripe"}]},
	rm_hangar: {name: "Hangar 12", w: 52, h: 38, sea: "t", kind: "town", links: {l: "lane", r: "rocks", b: "road"},
		decor: [{is: "barn"}, {is: "shed"}, {is: "wagon"}, {is: "stall_cart"}], pier: "t"},
	rm_plummet: {name: "Plummet's Point", w: 44, h: 40, sea: "t", river: true, kind: "wild", links: {b: "lane"},
		buildings: [{key: "tower", is: "brick_gable", room: "rm_witch_tower"}]},

	rm_olivebay: {name: "Olive Bay", w: 48, h: 36, sea: "l", kind: "town", links: {t: "lane", r: "road", b: "lane"},
		decor: [{is: "stall_white"}, {is: "stall_stripe"}, {is: "fruit_table"}, {is: "well"}], pier: "l"},
	rm_redstreet: {name: "Red Street", w: 46, h: 36, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"},
		buildings: [{key: "goldcrest", is: "brick_bay", room: "rm_home_goldcrest"}]},
	rm_downtown: {name: "Downtown", w: 64, h: 44, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"},
		buildings: [{key: "tavern", is: "brick_hall", room: "rm_town_inn"}, {key: "bank", is: "brick_market", room: "rm_bank"},
			{key: "tools", is: "brick_hip", room: "rm_toolstore"}],
		plaza: true, decor: [{is: "well"}, {is: "stall_green"}]},
	rm_gracetower: {name: "Grace Tower", w: 52, h: 38, kind: "town", links: {t: "road", l: "road", b: "road"},
		buildings: [{key: "smithy", is: "cottage_long", room: "rm_village_smithy"}, {key: "whitlow", is: "plain_L", room: "rm_home_whitlow"}],
		decor: [{is: "clock_tower"}]},
	rm_beaconhill: {name: "Beacon Hill", w: 50, h: 40, river: true, kind: "rural", links: {t: "lane", b: "lane"},
		buildings: [{key: "ironvein", is: "cottage_small", room: "rm_town_home_se"}], mine: true,
		decor: [{is: "stall_cart"}]},

	rm_pigeonrocks: {name: "Pigeon Rocks", w: 44, h: 36, sea: "l", kind: "rural", links: {t: "lane", r: "road", b: "lane"},
		buildings: [{key: "gullwater", is: "cottage_small", room: "rm_home_gullwater"}]},
	rm_verdun: {name: "Verdun Street", w: 56, h: 36, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"},
		buildings: [{key: "bakery", is: "plain_tall", room: "rm_bakery"}, {key: "flowers", is: "plain_small", room: "rm_flowershop"},
			{key: "furniture", is: "clapboard", room: "rm_furniture"}]},
	rm_uptown: {name: "Uptown", w: 56, h: 38, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"},
		buildings: [{key: "hospital", is: "brick_hip", room: "rm_hospital"}, {key: "library", is: "brick_bay", room: "rm_library"}]},
	rm_ovenswindow: {name: "Oven's Window", w: 60, h: 40, kind: "rural", links: {t: "road", l: "road", r: "lane", b: "lane"},
		buildings: [{key: "quill", is: "plain_small", room: "rm_town_home_nw"}, {key: "meadowlark", is: "cottage_L", room: "rm_valley_ranch"}],
		decor: [{is: "barn"}, {is: "coop"}, {is: "hay_roll"}]},
	rm_victoryhill: {name: "Victory Hill", w: 54, h: 40, river: true, kind: "rural", links: {l: "lane", t: "lane", b: "lane"},
		buildings: [{key: "oakhart", is: "cottage_long", room: "rm_village_rowan"}, {key: "mill", is: "barn", room: "rm_valley_carpentry"}],
		decor: [{is: "hay_roll"}, {is: "wagon"}]},

	rm_whitesand: {name: "White Sand Beach", w: 46, h: 38, sea: "l", kind: "rural", links: {t: "lane", r: "road", b: "lane"},
		buildings: [{key: "shack", is: "cottage_small", room: "rm_beach_hut"}], pier: "l"},
	rm_winghill: {name: "Wing Hill", w: 54, h: 38, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"},
		buildings: [{key: "kassar", is: "cottage_small", room: "rm_home_kassar"}],
		decor: [{is: "stall_stripe"}, {is: "stall_white"}, {is: "stall_green"}, {is: "stall_blue"}, {is: "fruit_table"}, {is: "stall_cart"}]},
	rm_dahya: {name: "Dahya", w: 56, h: 38, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"},
		buildings: [{key: "larkspun", is: "plain_L", room: "rm_town_home_e"}, {key: "clothes", is: "cottage_shop", room: "rm_town_outfitter"},
			{key: "tawil", is: "plain_tall", room: "rm_home_tawil"}], pines: true},
	rm_resolve: {name: "Resolve's Rise", w: 50, h: 38, kind: "rural", links: {t: "lane", l: "road", b: "road"},
		buildings: [{key: "silverbough", is: "cottage_L", room: "rm_town_home_sw"}, {key: "potions", is: "brick_small", room: "rm_town_apothecary"}]},
	rm_yarzeh: {name: "Yarzeh Woods", w: 54, h: 44, river: true, kind: "wild", links: {t: "lane", b: "trees"}, whisperwood: true},

	rm_southbeach: {name: "South Beach", w: 48, h: 38, sea: "l", kind: "rural", links: {t: "lane", r: "lane"}},
	rm_1: {name: "Player Farm", farm: true, links: {t: "road", l: "lane"}},
	rm_sthereza: {name: "Saint Thereza", w: 60, h: 40, kind: "rural", links: {t: "road", r: "road"},
		buildings: [{key: "nighthome", is: "cottage_twin", room: "rm_village_hesta"}, {key: "seeds", is: "cottage_shop", room: "rm_village_store"}],
		decor: [{is: "barn"}, {is: "coop"}, {is: "bee_shed"}, {is: "silo"}]},
	rm_frere: {name: "Frere's Fray", w: 46, h: 36, kind: "rural", links: {t: "road", l: "road", r: "road"},
		buildings: [{key: "frere", is: "cottage_small", room: "rm_village_elda"}]},
	rm_abda: {name: "Abda's Ascent", w: 54, h: 50, river: "spring", kind: "rural", links: {l: "road", t: "trees"},
		buildings: [{key: "church", is: "church", room: "rm_church"}, {key: "ward", is: "plain_small", room: "rm_home_ward"}]},
};

// The farm's ways out are in its own spec (tools/rooms/specs/rm_1.js); where you arrive there:
const FARM = {w: 77, h: 40, arrive: {t: [1296, 72], l: [64, 576]}};

// Where each grid cell is
const CELL = {};
GRID.forEach((row, r) => row.forEach((id, c) => { CELL[id] = [r, c]; }));

module.exports = {GRID, ROOMS, FARM, CELL};
