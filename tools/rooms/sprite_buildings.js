// Buildings drawn as one sprite each (Sprites/Houses: the Meshy houses in art/meshy_houses and the PixelLab ones in
// art/ai_houses), as things for the room builder: "house_<name>" for spr_house_<name>.
//
// A sprite building isn't tiles: build.js places an obj_building (its sprite in the creation code) whose depth sorts
// by its foot, so you're drawn behind it north of its front wall and in front of it south of it. Its cells are a box
// of whole tiles; the sprite's bottom sits on the box's bottom edge and it is shifted (by under half a tile) so its
// door's middle is over the middle of a cell: the door cell, in the box's bottom row, is the way in. The bottom
// `foot` rows are solid except the door cell (3 for tall buildings, 2 for the rest).
//
// door: the x of the door's middle in the sprite's pixels (measured by eye from build/door_sheet - its foot).
const fs = require("fs");
const path = require("path");
const {readPng} = require("./png.js");
const root = path.join(__dirname, "..", "..");

const DOORS = {
	alchemist: 42, bakery: 50, barn: 98, blacksmith: 97, brewery: 146, carpentry: 71, church: 106, cottage: 64,
	family_house: 93, farmhouse: 140, fisherman_hut: 48, lighthouse: 97, lodge: 201, market: 160, market_small: 97,
	mill: 182, ranch_barn: 142, silo: 60, small_house: 84, smithy: 112, tavern: 115, tavern_inn: 92, townhouse: 84,
	town_hall: 165, weaver: 161, windmill: 83,
	witch_tower: 75, guild_hall: 150, tool_shop: 50, hospital: 130, library: 150,
	olive_press: 117, tinker_workshop: 82, boatyard: 112, glassworks: 132, stables: 79, barn_ranch: 124,
	oakhart_farmhouse: 132,
	home_saba: 120, home_brassbolt: 120, home_saltwhistle: 82, home_fairglass: 107, home_hayward: 117,
	home_larkspun: 89, home_silverbough: 114, home_frere: 143, home_quill: 75, home_ward: 91, home_tawil: 113, home_kassar: 86, home_night: 82, farmhouse_1: 78, farmhouse_2: 78, farmhouse_3: 96, farmhouse_4: 62,
};

// Props drawn as one sprite (spr_prop_<name>, PixelLab): "prop_<name>", centred in a box of whole tiles, standing on
// its bottom edge; solid: how many of its bottom rows block you (0: you can walk over it).
const PROPS = {bench: 1, lamp: 1, fountain: 2, planter: 1, campfire: 1,
	museum: 2, monastery: 2, old_hangar: 2, beach_bar: 1, lifeguard_hut: 1, rangers_cabin: 2, fish_market: 1, ferry_dock: 2, cafe_terrace: 1, roadside_shrine: 1, merchant_cart: 1, cliff_lookout: 2, olive_tree: 1, grapevine: 1, gravestones: 1, shipwreck: 1, sea_arch: 2, tide_pools: 0, herb_bed: 1, swing: 1, flower_bed: 1, beach_umbrella: 0,
	keeper_garden: 1, miners_camp: 1, botanical: 2, overlook: 1, turtle_nests: 0,
	exhibition_hall: 2, port_silos: 2, marina_club: 2, bourj_market: 2, stadium: 2, sursock_gallery: 2, gemmayzeh_bar: 2, old_station: 2,
	cable_car_station: 2, tram_stop: 1, bunny_burrow: 2,
	town_hallhouse: 2, town_hallhouse2: 2, town_hallhouse3: 2, town_apartments: 2, town_yellowhouse: 2, town_yellowhouse2: 2, town_villa: 2, town_villa2: 2,
	town_shop: 2, town_shop2: 2, town_cafe: 2, town_cafe2: 2, town_bakery: 2, town_bakery2: 2,
	farm_barn_1: 2, farm_barn_2: 2, farm_barn_3: 2, farm_coop_1: 2, farm_coop_2: 2, farm_coop_3: 2, farm_shed_1: 2, farm_shed_2: 2, farm_shed_3: 2,
	farm_silo_1: 1, farm_silo_2: 1, farm_silo_3: 2, farm_bee_shed: 1, farm_granary: 2, farm_outhouse: 1, barn_stone: 2, stables_b: 2};

function spriteSize(name){
	const dir = path.join(root, "sprites", name);
	if(!fs.existsSync(dir)) return null;
	const png = fs.readdirSync(dir).find(f => f.endsWith(".png"));
	const img = readPng(path.join(dir, png));
	return [img.w, img.h];
}

const things = {};
for(const [n, doorPx] of Object.entries(DOORS)){
	const sprite = "spr_house_" + n, sz = spriteSize(sprite);
	if(!sz) continue;
	const [pw, ph] = sz;
	const dc = Math.floor(doorPx / 32), ox = dc * 32 + 16 - doorPx;   // shift so the door is over cell dc's middle
	const w = Math.ceil((Math.max(0, ox) + pw) / 32), h = Math.ceil(ph / 32), foot = ph >= 250 ? 3 : 2;
	const solid = [[0, h - foot, w, foot - 1], [0, h - 1, dc, 1], [dc + 1, h - 1, w - dc - 1, 1]].filter(s => s[2] > 0 && s[3] > 0);
	// src: the box in cells, for code that only asks a thing its size (no tiles are drawn from it)
	things["house_" + n] = {sprite, pw, ph, ox, src: [0, 0, w, h], door: [dc, h - 1], solid, above: 0};
}

for(const [n, rows] of Object.entries(PROPS)){
	const sprite = "spr_prop_" + n, sz = spriteSize(sprite);
	if(!sz) continue;
	const [pw, ph] = sz, w = Math.ceil(pw / 32), h = Math.ceil(ph / 32);
	things["prop_" + n] = {sprite, pw, ph, ox: Math.floor((w * 32 - pw) / 2), src: [0, 0, w, h],
		solid: rows ? [[0, h - rows, w, rows]] : [], above: 0};
}

module.exports = {things, DOORS, PROPS};
