/// Quests (roadmap phase 6): requests from the villagers on the notice board in the village (obj_quest_board).
///
/// Each day the board offers 3 requests; you can carry up to 3 at once. A delivery is handed in at the board when
/// you have the items; a hunt counts the monsters you beat after taking it. Rewards: gold, friendship with whoever
/// asked, and often a dye or a material - in story mode, quests are where dyes come from.
/// global.world.quests = {day, offers: [quest], active: [quest], done}
/// A quest is {kind: "deliver" | "slay", who, item (a cost key: "wood", "p|carrot"), monster, n, got, gold, reward}.

#macro QUESTS_ACTIVE_MAX 3

/// @description What villagers ask for. n: [min, max] wanted; gold: paid per item or per monster;
/// deepest: only once you've been that far down the mine.
function quest_templates(){
	static t = [
		{kind: "deliver", who: "thorne", item: "wood",         n: [15, 30], gold: 6,   text: "Wood for the new bridge"},
		{kind: "deliver", who: "thorne", item: "stone",        n: [10, 25], gold: 5,   text: "Stone for the well"},
		{kind: "deliver", who: "elda",   item: "fibre",        n: [10, 20], gold: 6,   text: "Fibre for weaving charms"},
		{kind: "deliver", who: "mara",   item: "p|carrot",     n: [3, 8],   gold: 45,  text: "Carrots for the market stall"},
		{kind: "deliver", who: "mara",   item: "p|potato",     n: [3, 6],   gold: 90,  text: "Potatoes, any size"},
		{kind: "deliver", who: "hesta",  item: "p|tomato",     n: [3, 6],   gold: 70,  text: "Tomatoes for a sauce"},
		{kind: "deliver", who: "brom",   item: "copper_ore",   n: [10, 20], gold: 6,   text: "Copper ore for the forge"},
		{kind: "deliver", who: "brom",   item: "coal",         n: [5, 12],  gold: 9,   text: "Coal, the forge is hungry"},
		{kind: "deliver", who: "brom",   item: "iron_ore",     n: [5, 15],  gold: 10,  text: "Iron ore for horseshoes", deepest: 5},
		{kind: "deliver", who: "elda",   item: "frost_crystal", n: [1, 2],  gold: 160, text: "A frost crystal from the deep", deepest: 10},
		{kind: "deliver", who: "tobin",  item: "feather",      n: [2, 5],   gold: 30,  text: "Feathers for a hat"},
		{kind: "slay",    who: "rowan",  monster: "slime",     n: [3, 6],   gold: 25,  text: "Slimes keep oozing out of the cave"},
		{kind: "slay",    who: "rowan",  monster: "goblin",    n: [2, 5],   gold: 40,  text: "Goblins stole my fence posts"},
		{kind: "slay",    who: "pip",    monster: "bat",       n: [3, 6],   gold: 30,  text: "Bats in the barn - well, the mine"},
		{kind: "slay",    who: "thorne", monster: "skeleton",  n: [3, 5],   gold: 60,  text: "Skeletons rattling under the village", deepest: 10},
		{kind: "slay",    who: "tobin",  monster: "troll",     n: [1, 2],   gold: 150, text: "A troll! A real one!", deepest: 15},
	];
	return t;
}

function quests_state(){
	if(!is_struct(global.world[$ "quests"])) global.world.quests = {day: -1, offers: [], active: [], done: 0};
	return global.world.quests;
}

/// @description Make one quest from a template: how many, the pay, and maybe a dye or material on top.
function quest_make(_t){
	var n = irandom_range(_t.n[0], _t.n[1]);
	var q = {kind: _t.kind, who: _t.who, text: _t.text, n: n, got: 0, gold: n * _t.gold, reward: undefined,
	         item: _t[$ "item"] ?? "", monster: _t[$ "monster"] ?? ""};
	var r = random(1);
	if(r < 0.45){
		var cols = lpc_catalog().palettes.cloth_names;
		q.reward = ["d|cloth|" + string_replace_all(cols[irandom(array_length(cols) - 1)], " ", "_"), 1];
	} else if(r < 0.7){
		q.reward = [choose("m|silk", "m|wool", "m|leather", "m|gem", "m|feather"), irandom_range(1, 3)];
	}
	return q;
}

/// @description Today's offers (new ones each day; the ones you took stay in active).
function quests_offers(){
	var st = quests_state();
	if(st.day != day_index()){
		st.day = day_index();
		st.offers = [];
		var pool = [], t = quest_templates(), deep = mine_state().deepest;
		for(var i = 0; i < array_length(t); i++) if(deep >= (t[i][$ "deepest"] ?? 0)) array_push(pool, t[i]);
		repeat(3){
			if(array_length(pool) == 0) break;
			var k = irandom(array_length(pool) - 1);
			array_push(st.offers, quest_make(pool[k]));
			array_delete(pool, k, 1);
		}
	}
	return st.offers;
}

/// @description What a quest wants, e.g. "12 Wood" or "Beat 4 Slimes (2/4)".
function quest_goal_text(_q){
	if(_q.kind == "slay") return "Beat " + string(_q.n) + " " + monster_table()[$ _q.monster].name + ((_q.n > 1) ? "s" : "") + "  (" + string(min(_q.got, _q.n)) + "/" + string(_q.n) + ")";
	return "Bring " + string(_q.n) + " " + item_def(cost_item_id(_q.item)).name + ((string_pos("p|", _q.item) == 1) ? " (any quality)" : "")
	       + "  (" + string(min(cost_count(_q.item), _q.n)) + "/" + string(_q.n) + ")";
}

function quest_reward_text(_q){
	var s = string(_q.gold) + " gold";
	if(_q.reward != undefined) s += ", " + ((_q.reward[1] > 1) ? string(_q.reward[1]) + " " : "") + item_def(_q.reward[0]).name;
	return s;
}

function quest_ready(_q){
	return (_q.kind == "slay") ? _q.got >= _q.n : cost_count(_q.item) >= _q.n;
}

/// @description Take offer _i. Returns "" or why not.
function quest_accept(_i){
	var st = quests_state(), offers = quests_offers();
	if(_i < 0 || _i >= array_length(offers)) return "No such request";
	if(array_length(st.active) >= QUESTS_ACTIVE_MAX) return "You can only take " + string(QUESTS_ACTIVE_MAX) + " requests at a time";
	array_push(st.active, offers[_i]);
	array_delete(offers, _i, 1);
	return "";
}

/// @description Hand in active quest _i: takes the items, pays out, and the villager likes you more. Returns a message.
function quest_hand_in(_i){
	var st = quests_state();
	if(_i < 0 || _i >= array_length(st.active)) return "No such request";
	var q = st.active[_i];
	if(!quest_ready(q)) return "Not done yet: " + quest_goal_text(q);
	if(q.kind == "deliver") cost_take(q.item, q.n);
	if(!inv_is_free()) global.inv.gold += q.gold;
	if(q.reward != undefined) inv_add(item_stack(q.reward[0], q.reward[1]));
	people_add(q.who, 60);
	array_delete(st.active, _i, 1);
	st.done += 1;
	return villager_def(q.who).name + " thanks you!  +" + quest_reward_text(q);
}

/// @description A monster was beaten: hunts for its kind count it.
function quests_on_kill(_kind){
	var act = quests_state().active;
	for(var i = 0; i < array_length(act); i++) if(act[i].kind == "slay" && act[i].monster == _kind) act[i].got += 1;
}
