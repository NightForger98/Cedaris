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
	rm_wellshead: {name: "Well's Head", corniche: true, w: 52, h: 40, sea: "tl", kind: "rural", links: {r: "lane", b: "lane"}, landmarks: [{ruin: "house", q: "se"}],
		buildings: [{key: "hotel", is: "house_lodge", room: "rm_hotel"},
			{key: "glassworks", is: "house_glassworks", room: "rm_glassworks"}, {key: "fairglass", is: "house_home_fairglass", room: "rm_home_fairglass"}],
		decor: [{is: "well"}, {is: "fruit_table"}]},
	rm_manara: {name: "Manara's Light", corniche: true, w: 44, h: 36, sea: "t", kind: "rural", links: {l: "lane", r: "lane", b: "road"}, landmarks: [{is: "prop_cliff_lookout", q: "se"}, {is: "prop_keeper_garden", q: "sw"}],
		buildings: [{key: "lighthouse", is: "house_lighthouse", room: "rm_lighthouse"}]},
	rm_starsand: {name: "Starsand Pier", corniche: true, w: 56, h: 40, sea: "t", kind: "town", links: {l: "lane", r: "lane", b: "road"}, landmarks: [{is: "prop_fish_market", q: "se"}, {is: "prop_ferry_dock", q: "sw"}],
		buildings: [{key: "guild", is: "house_guild_hall", room: "rm_guild"}], pier: "t", pierStone: true,
		decor: [{is: "obelisk"}, {is: "stall_stripe"}]},
	rm_hangar: {name: "Hangar 12", buildings: [{key: "tinker", is: "house_tinker_workshop", room: "rm_tinker"},
			{key: "brassbolt", is: "house_home_brassbolt", room: "rm_home_brassbolt"}], w: 52, h: 38, sea: "t", kind: "town", links: {l: "lane", r: "beach", b: "road"}, landmarks: [{is: "prop_old_hangar", q: "se"}],
		decor: [{is: "barn"}, {is: "shed"}, {is: "wagon"}, {is: "stall_cart"}], pier: "t"},
	// Split diagonally by a cliff: the witch's tower on the high ground to the south-east, reached over the cliff tops
	// from Beacon Hill's ladder; the beach and lowland to the north-west, reached along the beach from Hangar 12 over
	// the river by a footbridge (the Beach Bridge project mends it)
	rm_plummet: {name: "Plummet's Point", split: true, sea: "t", river: true, kind: "wild", links: {b: "cliff", l: "beach"}, landmarks: [{ruin: "temple", q: "nw"}],
		buildings: [{key: "tower", is: "house_witch_tower", room: "rm_witch_tower", plateau: true}]},

	rm_olivebay: {name: "Olive Bay", w: 48, h: 36, sea: "l", kind: "town", links: {t: "lane", r: "road", b: "lane"}, landmarks: [{is: "prop_olive_tree", q: "se"}],
		buildings: [{key: "olivepress", is: "house_olive_press", room: "rm_olive_press"}, {key: "saba", is: "house_home_saba", room: "rm_home_saba"}],
		decor: [{is: "stall_white"}, {is: "stall_stripe"}, {is: "fruit_table"}, {is: "well"}], pier: "l"},
	rm_redstreet: {name: "Red Street", w: 46, h: 36, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"}, landmarks: [{is: "prop_cafe_terrace", q: "se"}, {is: "prop_fountain", q: "sw"}],
		buildings: [{key: "goldcrest", is: "house_townhouse", room: "rm_home_goldcrest"}]},
	rm_downtown: {name: "Downtown", w: 64, h: 44, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"}, landmarks: [{is: "house_brewery", q: "nw"}],
		buildings: [{key: "tavern", is: "house_tavern_inn", room: "rm_town_inn"}, {key: "bank", is: "house_town_hall", room: "rm_bank"},
			{key: "tools", is: "house_tool_shop", room: "rm_toolstore"}],
		plaza: true, decor: [{is: "well"}, {is: "stall_green"}]},
	rm_gracetower: {name: "Grace Tower", w: 52, h: 38, kind: "town", links: {t: "road", l: "road", b: "road"}, landmarks: [{is: "prop_roadside_shrine", q: "se"}],
		buildings: [{key: "smithy", is: "house_blacksmith", room: "rm_village_smithy"}, {key: "whitlow", is: "house_family_house", room: "rm_home_whitlow"}],
		decor: [{is: "clock_tower"}]},
	rm_beaconhill: {name: "Beacon Hill", cliffEast: true, w: 50, h: 40, river: true, kind: "rural", links: {t: "cliff", b: "lane"}, landmarks: [{is: "prop_campfire", q: "sw"}, {is: "prop_miners_camp", q: "se"}],
		buildings: [{key: "ironvein", is: "house_cottage", room: "rm_town_home_se"}], mine: true,
		decor: [{is: "stall_cart"}]},

	rm_pigeonrocks: {name: "Pigeon Rocks", w: 44, h: 36, sea: "l", kind: "rural", links: {t: "lane", r: "road", b: "lane"}, landmarks: [{is: "prop_sea_arch", q: "nw"}, {is: "prop_tide_pools", q: "sw"}],
		buildings: [{key: "gullwater", is: "house_small_house", room: "rm_home_gullwater"}]},
	rm_verdun: {name: "Verdun Street", w: 56, h: 36, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"}, landmarks: [{is: "prop_flower_bed", q: "se"}],
		buildings: [{key: "bakery", is: "house_bakery", room: "rm_bakery"}, {key: "flowers", is: "house_market_small", room: "rm_flowershop"},
			{key: "furniture", is: "house_carpentry", room: "rm_furniture"}]},
	rm_uptown: {name: "Uptown", w: 56, h: 38, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"}, landmarks: [{is: "prop_museum", q: "se"}, {is: "prop_botanical", q: "sw"}],
		buildings: [{key: "hospital", is: "house_hospital", room: "rm_hospital"}, {key: "library", is: "house_library", room: "rm_library"}]},
	rm_ovenswindow: {name: "Oven's Window", w: 60, h: 40, kind: "rural", links: {t: "road", l: "road", r: "lane", b: "lane"}, landmarks: [{is: "house_silo", q: "ne"}],
		buildings: [{key: "quill", is: "house_home_quill", room: "rm_town_home_nw"}, {key: "meadowlark", is: "house_ranch_barn", room: "rm_valley_ranch"}],
		decor: [{is: "barn"}, {is: "coop"}, {is: "hay_roll"}]},
	rm_victoryhill: {name: "Victory Hill", cliffEast: true, w: 54, h: 40, river: true, kind: "rural", links: {l: "lane", t: "lane", b: "lane"}, landmarks: [{is: "house_windmill", q: "ne"}, {is: "prop_overlook", q: "se"}],
		buildings: [{key: "oakhart", is: "house_oakhart_farmhouse", room: "rm_village_rowan"}, {key: "mill", is: "house_mill", room: "rm_valley_carpentry"}],
		decor: [{is: "hay_roll"}, {is: "wagon"}]},

	rm_whitesand: {name: "White Sand Beach", w: 46, h: 38, sea: "l", kind: "rural", links: {t: "lane", r: "road", b: "lane"}, landmarks: [{is: "prop_beach_bar", q: "se"}, {is: "prop_lifeguard_hut", q: "sw"}],
		buildings: [{key: "shack", is: "house_fisherman_hut", room: "rm_beach_hut"}], pier: "l"},
	rm_winghill: {name: "Wing Hill", w: 54, h: 38, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"}, landmarks: [{is: "prop_merchant_cart", q: "se"}],
		buildings: [{key: "kassar", is: "house_home_kassar", room: "rm_home_kassar"}],
		decor: [{is: "stall_stripe"}, {is: "stall_white"}, {is: "stall_green"}, {is: "stall_blue"}, {is: "fruit_table"}, {is: "stall_cart"}]},
	rm_dahya: {name: "Dahya", pineForest: true, w: 56, h: 38, kind: "town", links: {t: "road", l: "road", r: "road", b: "road"}, landmarks: [{is: "prop_swing", q: "se"}],
		buildings: [{key: "larkspun", is: "house_home_larkspun", room: "rm_town_home_e"}, {key: "clothes", is: "house_weaver", room: "rm_town_outfitter"},
			{key: "tawil", is: "house_home_tawil", room: "rm_home_tawil"}], pines: true},
	rm_resolve: {name: "Resolve's Rise", w: 50, h: 38, kind: "rural", links: {t: "lane", l: "road", b: "road"}, landmarks: [{is: "prop_herb_bed", q: "se"}],
		buildings: [{key: "silverbough", is: "house_home_silverbough", room: "rm_town_home_sw"}, {key: "potions", is: "house_alchemist", room: "rm_town_apothecary"}]},
	// Whispering Woods (once Yarzeh Woods): the deep wood itself now (Whisperwood, the generated forest east of it,
	// is gone), its shrine in a clearing; pixies and moths come out at night (scripts/forest)
	rm_yarzeh: {name: "Whispering Woods", cliffEast: true, dense: true, river: true, kind: "wild", links: {t: "lane", b: "trees"}, landmarks: [{is: "prop_rangers_cabin", q: "nw"}, {ruin: "temple", q: "sw"}, {obj: "obj_shrine", w: 2, h: 3, q: "se"}]},

	rm_southbeach: {name: "South Beach", buildings: [{key: "boatyard", is: "house_boatyard", room: "rm_boatyard"},
			{key: "saltwhistle", is: "house_home_saltwhistle", room: "rm_home_saltwhistle"}], w: 48, h: 38, sea: "l", kind: "rural", links: {t: "lane", r: "lane"}, landmarks: [{is: "prop_shipwreck", q: "se"}, {is: "prop_turtle_nests", q: "sw"}]},
	rm_1: {name: "Player Farm", farm: true, links: {t: "road", l: "lane"}},
	rm_sthereza: {name: "Saint Thereza", w: 60, h: 40, kind: "rural", links: {t: "road", r: "road"}, landmarks: [{is: "prop_grapevine", q: "nw"}],
		buildings: [{key: "nighthome", is: "house_home_night", room: "rm_village_hesta"}, {key: "seeds", is: "house_market", room: "rm_village_store"}],
		decor: [{is: "barn"}, {is: "coop"}, {is: "bee_shed"}, {is: "silo"}]},
	rm_frere: {name: "Frere's Fray", w: 46, h: 36, kind: "rural", links: {t: "road", l: "road", r: "road"}, landmarks: [{is: "prop_monastery", q: "ne"}],
		buildings: [{key: "frere", is: "house_home_frere", room: "rm_village_elda"},
			{key: "stables", is: "house_stables", room: "rm_stables"}, {key: "hayward", is: "house_home_hayward", room: "rm_home_hayward"}]},
	rm_abda: {name: "Abda's Ascent", w: 54, h: 50, river: "spring", kind: "rural", links: {l: "road", t: "trees"}, landmarks: [{is: "prop_gravestones", q: "se"}, {ruin: "house", q: "ne"}],
		buildings: [{key: "church", is: "house_church", room: "rm_church"}, {key: "ward", is: "house_home_ward", room: "rm_home_ward"}]},
};

// The farm's ways out are in its own spec (tools/rooms/specs/rm_1.js); where you arrive there:
const FARM = {w: 77, h: 40, arrive: {t: [1296, 72], l: [64, 576]}};

// Where each grid cell is
const CELL = {};
GRID.forEach((row, r) => row.forEach((id, c) => { CELL[id] = [r, c]; }));

module.exports = {GRID, ROOMS, FARM, CELL};
