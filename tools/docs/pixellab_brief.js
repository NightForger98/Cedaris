// Write design/PixelLab_Asset_Brief.docx: every asset still needed for Harvest Valley, with the reference image to give
// PixelLab and the prompt to paste, so it can be made on any PixelLab account and sent back.
//   node tools/docs/pixellab_brief.js
const fs = require("fs");
const path = require("path");
const {Document, Packer, Paragraph, TextRun, ImageRun, HeadingLevel, Table, TableRow, TableCell, WidthType,
	BorderStyle, ShadingType, AlignmentType, LevelFormat, PageBreak} = require("docx");
const {readPng} = require("../rooms/png.js");

const ROOT = path.join(__dirname, "..", "..");
const AI = f => path.join(ROOT, "art", "ai_houses", f + ".png");
const MESHY = f => path.join(ROOT, "art", "meshy_houses", f + ".png");

const ENDING = "Crisp pixels, no anti-aliasing, 1px dark outline, light from the top left, soft muted palette. No ground, no scenery, no text, no letters, simple and readable.";
const FRONT = "Straight-on front view: the front wall faces the camera, the roof seen from above, its ridge running left to right, no side walls visible, no isometric or perspective angle.";

// ---------------------------------------------------------------- the assets
// ref: the style reference to upload (an existing PixelLab house of a similar kind); size: the canvas
const SECTIONS = [
	{title: "1. Homes for the five new families", intro: "Each family has its workshop already (shown as the reference). The home should look like it belongs with it: same materials, same family.",
	 items: [
		{name: "home_saba", ref: AI("olive_press"), size: "256x224", who: "Rami and Noor Saba, olive pressers in Olive Bay",
		 prompt: `pixel art family home for a top-down 2D farming RPG in the Liberated Pixel Cup (LPC) style. ${FRONT} A one-storey whitewashed stone house with a terracotta tile roof, green wooden shutters, a small olive tree in a clay pot and a bench by one centred wooden door, a string of drying herbs under the eaves. ${ENDING}`},
		{name: "home_brassbolt", ref: AI("tinker_workshop"), size: "256x256", who: "Ottilie and Gus Brassbolt, dwarf tinkers at Hangar 12",
		 prompt: `pixel art family home for a top-down 2D farming RPG in the LPC style. ${FRONT} A sturdy two-storey red brick dwarf house with a grey tin-sheet roof, round porthole windows, a little brass weathervane, copper pipes on the wall and a small gear above one centred heavy wooden door. ${ENDING}`},
		{name: "home_saltwhistle", ref: AI("boatyard"), size: "256x224", who: "Captain Hal and Marina Saltwhistle, boatwrights on South Beach",
		 prompt: `pixel art family home for a top-down 2D farming RPG in the LPC style. ${FRONT} A weathered blue-grey clapboard seaside cottage on a low stone base, a slate roof, a round ship's window, a life ring and a coil of rope by one centred wooden door, a lantern. ${ENDING}`},
		{name: "home_fairglass", ref: AI("glassworks"), size: "256x224", who: "Iris and Tomas Fairglass, glassblowers at Well's Head",
		 prompt: `pixel art family home for a top-down 2D farming RPG in the LPC style. ${FRONT} A pale stone cottage with a dark slate roof and tall windows of coloured glass panes (blue, green, amber), glass bottles on the window sill, one centred arched wooden door. ${ENDING}`},
		{name: "home_hayward", ref: AI("stables"), size: "256x224", who: "Bram and Della Hayward, stablemasters at Frere's Fray",
		 prompt: `pixel art family home for a top-down 2D farming RPG in the LPC style. ${FRONT} A dark timber and white plaster farmhouse with a wooden shingle roof, a horseshoe over one centred door, a hay bale and a saddle on a rail by the wall, flower boxes. ${ENDING}`},
	]},
	{title: "2. Homes that share a house today", intro: "These families live in a house the same as another family's. One new house each makes every home in the valley unique.",
	 items: [
		{name: "home_larkspun", ref: AI("weaver"), size: "256x224", who: "the Larkspun family, weavers and outfitters in Dahya",
		 prompt: `pixel art family home for a top-down 2D farming RPG in the LPC style. ${FRONT} A cosy half-timbered cottage with a golden thatched roof, bolts of coloured cloth airing on a line beside it, a spinning wheel by the window, one centred wooden door. ${ENDING}`},
		{name: "home_silverbough", ref: AI("alchemist"), size: "256x256", who: "the Silverbough elves at Resolve's Rise (Elda the potion-seller's family)",
		 prompt: `pixel art elven family home for a top-down 2D farming RPG in the LPC style. ${FRONT} A graceful pale wood house with a curved green-shingled roof shaped like leaves, vines climbing the walls, round windows, lanterns, one centred arched door with carved leaf patterns. ${ENDING}`},
		{name: "home_frere", ref: AI("small_house"), size: "224x208", who: "the Frere family at Frere's Fray",
		 prompt: `pixel art small family home for a top-down 2D farming RPG in the LPC style. ${FRONT} A small grey fieldstone cottage with a moss-covered slate roof, a vegetable patch fence, a beehive, one centred wooden door with a little porch roof. ${ENDING}`},
		{name: "home_quill", ref: AI("family_house"), size: "224x256", who: "the Quill family at Oven's Window (Edwin the librarian, Wynn)",
		 prompt: `pixel art narrow family home for a top-down 2D farming RPG in the LPC style. ${FRONT} A tall narrow two-storey townhouse, cream plaster and dark beams, a blue slate roof, stacks of books visible in the windows, a quill-shaped weathervane, one centred door. ${ENDING}`},
		{name: "home_ward", ref: AI("church"), size: "224x208", who: "the Ward household at Abda's Ascent (Father Aldous, Sir Alaric)",
		 prompt: `pixel art small house for a top-down 2D farming RPG in the LPC style. ${FRONT} A modest grey stone house with a dark slate roof and a small stone cross on its gable, a pointed arched window, a rose bush, one centred arched wooden door. ${ENDING}`},
		{name: "home_tawil", ref: MESHY("house_4"), size: "256x256", who: "the Tawil family in Dahya (Bryn, Dikhaj)",
		 prompt: `pixel art family home for a top-down 2D farming RPG in the LPC style. ${FRONT} A two-storey sandstone house with a flat roof terrace edged by a low parapet, potted plants and a striped awning on the terrace, arched windows with wooden shutters, one centred arched door. ${ENDING}`},
		{name: "home_kassar", ref: AI("family_house"), size: "256x256", who: "the Kassar family at Wing Hill (Zenya, Ayla)",
		 prompt: `pixel art family home for a top-down 2D farming RPG in the LPC style. ${FRONT} A two-storey house of yellow-ochre plaster with a red tile roof, a wooden balcony with flower pots on the upper floor, green shutters, one centred wooden door under the balcony. ${ENDING}`},
		{name: "home_night", ref: MESHY("house_6"), size: "288x256", who: "the Night family's farmhouse at Saint Thereza (seeds and honey)",
		 prompt: `pixel art farmhouse for a top-down 2D farming RPG in the LPC style. ${FRONT} A long low farmhouse of honey-coloured stone with a thatched roof, beehives and a honey jar sign by the wall, sacks of seed, one centred wooden double door. ${ENDING}`},
	]},
	{title: "3. Your farmhouse, as it grows", intro: "One house in four stages, for the house upgrades. Make the first, then use it as the reference for the next three so they match.",
	 items: [
		{name: "farmhouse_1", ref: MESHY("house_6"), size: "256x224", who: "the farmhouse you start with",
		 prompt: `pixel art small farmhouse for a top-down 2D farming RPG in the LPC style. ${FRONT} A small one-storey timber farmhouse with a thatched roof, one window either side of one centred wooden door, a stone chimney, a little worn but loved. ${ENDING}`},
		{name: "farmhouse_2", ref: null, refNote: "use farmhouse_1 as the reference", size: "288x240", who: "after the first upgrade (kitchen and big bed)",
		 prompt: `the same farmhouse, a little bigger: a kitchen wing added on the right with its own small chimney and a window, fresh thatch, flower boxes. ${FRONT} ${ENDING}`},
		{name: "farmhouse_3", ref: null, refNote: "use farmhouse_2 as the reference", size: "320x272", who: "after the second upgrade (rooms and a nursery)",
		 prompt: `the same farmhouse with a second storey added: half-timbered upper floor with two windows, a covered porch over the door. ${FRONT} ${ENDING}`},
		{name: "farmhouse_4", ref: null, refNote: "use farmhouse_3 as the reference", size: "320x288", who: "after the third upgrade (a cellar)",
		 prompt: `the same farmhouse at its finest: a stone cellar door at the side, a bench and potted plants on the porch, a weathervane on the roof. ${FRONT} ${ENDING}`},
	]},
	{title: "4. Landmark buildings", intro: "These stand in the rooms as labelled placeholders today.",
	 items: [
		{name: "museum", ref: AI("library"), size: "320x256", who: "Uptown",
		 prompt: `pixel art town museum for a top-down 2D farming RPG in the LPC style. ${FRONT} A pale stone museum with four columns at the front, a triangular pediment, tall windows, a dinosaur skeleton visible through the glass of the central doors, banners. ${ENDING}`},
		{name: "monastery", ref: AI("church"), size: "320x288", who: "Frere's Fray",
		 prompt: `pixel art small monastery for a top-down 2D farming RPG in the LPC style. ${FRONT} A long grey stone monastery with a red tile roof, a small bell tower at one end, a row of arched windows, a herb garden and beehives along the wall, one centred arched wooden door. ${ENDING}`},
		{name: "old_hangar", ref: AI("tinker_workshop"), size: "352x256", who: "Hangar 12",
		 prompt: `pixel art old airship hangar for a top-down 2D farming RPG in the LPC style. ${FRONT} A big curved corrugated-metal hangar, rusty, one huge sliding door half open showing the ribs of a broken wooden airship inside, a faded painted number 12 shape (no letters), weeds. ${ENDING}`},
		{name: "beach_bar", ref: AI("boatyard"), size: "256x192", who: "White Sand Beach",
		 prompt: `pixel art beach bar shack for a top-down 2D farming RPG in the LPC style. ${FRONT} A small bamboo and driftwood beach bar with a palm-leaf thatched roof, a counter with stools, coconuts and colourful drinks, a hanging lantern, a surfboard leaning on it. ${ENDING}`},
		{name: "lifeguard_hut", ref: AI("boatyard"), size: "128x192", who: "White Sand Beach",
		 prompt: `pixel art lifeguard tower for a top-down 2D farming RPG in the LPC style. Straight-on front view. A small white and red wooden lifeguard hut on tall stilts with a ladder, a red flag, a life ring. ${ENDING}`},
		{name: "rangers_cabin", ref: AI("small_house"), size: "224x208", who: "Whispering Woods",
		 prompt: `pixel art forest ranger's log cabin for a top-down 2D farming RPG in the LPC style. ${FRONT} A small log cabin with a mossy shingle roof, a stone chimney, stacked firewood, an axe in a stump, a lantern by one centred door. ${ENDING}`},
		{name: "fish_market", ref: AI("market"), size: "288x192", who: "Starsand Pier",
		 prompt: `pixel art fish market stall for a top-down 2D farming RPG in the LPC style. Straight-on front view. A long wooden market stall with a blue and white striped awning, crates of fish on ice, hanging nets, a scale. ${ENDING}`},
		{name: "ferry_dock", ref: AI("boatyard"), size: "256x192", who: "Starsand Pier",
		 prompt: `pixel art ferry ticket booth and boathouse for a top-down 2D farming RPG in the LPC style. ${FRONT} A small wooden harbour booth with a slate roof, a ship's bell, a timetable board (no letters), ropes and a small moored rowing boat beside it. ${ENDING}`},
		{name: "cafe_terrace", ref: AI("bakery"), size: "256x192", who: "Red Street",
		 prompt: `pixel art cafe for a top-down 2D farming RPG in the LPC style. ${FRONT} A small cafe with a red and white striped awning over a terrace of round tables and chairs, flower pots, a coffee cup sign (no letters), one centred glass door. ${ENDING}`},
		{name: "roadside_shrine", ref: AI("church"), size: "128x160", who: "Grace Tower",
		 prompt: `pixel art small roadside shrine for a top-down 2D farming RPG in the LPC style. Straight-on front view. A small stone shrine with a little peaked roof, candles and flowers at its base, a carved figure inside. ${ENDING}`},
		{name: "merchant_cart", ref: AI("market"), size: "224x160", who: "Wing Hill (the travelling merchant)",
		 prompt: `pixel art travelling merchant's wagon for a top-down 2D farming RPG in the LPC style. Straight-on side view. A colourful covered wooden wagon with a purple canvas top, open side showing goods, hanging lanterns and pots, a sleepy pony. ${ENDING}`},
		{name: "cliff_lookout", ref: AI("lighthouse"), size: "160x288", who: "Plummet's Point",
		 prompt: `pixel art old stone watchtower for a top-down 2D farming RPG in the LPC style. Straight-on front view. A narrow round ruined stone lookout tower, partly crumbled at the top, ivy, a wooden ladder, a spyglass on the ledge. ${ENDING}`},
	]},
	{title: "5. Props for the open places", intro: "Small things that fill the landmark areas (groves, gardens, beaches). Canvas sizes are small; make several of a kind if one comes out well.",
	 items: [
		{name: "prop_olive_tree", ref: AI("prop_planter"), size: "128x128", who: "Olive Bay's grove", prompt: `pixel art olive tree for a top-down 2D farming RPG in the LPC style. Front view. A gnarled olive tree with silvery-green leaves and small dark olives, a twisted trunk. ${ENDING}`},
		{name: "prop_grapevine", ref: AI("prop_planter"), size: "96x96", who: "Saint Thereza's vineyard", prompt: `pixel art grapevine trellis for a top-down 2D farming RPG in the LPC style. Front view. A wooden trellis with leafy grapevines and bunches of purple grapes. ${ENDING}`},
		{name: "prop_gravestones", ref: AI("prop_bench"), size: "128x64", who: "Abda's graveyard", prompt: `pixel art set of three old gravestones for a top-down 2D farming RPG in the LPC style. Front view. Weathered grey stones of different shapes, moss, a few flowers. No letters. ${ENDING}`},
		{name: "prop_shipwreck", ref: AI("boatyard"), size: "256x160", who: "South Beach", prompt: `pixel art shipwreck on the sand for a top-down 2D farming RPG in the LPC style. Side view. The broken hull of an old wooden ship tilted on its side, ribs showing, a snapped mast, seaweed. ${ENDING}`},
		{name: "prop_sea_arch", ref: AI("prop_fountain"), size: "224x192", who: "Pigeon Rocks", prompt: `pixel art natural sea arch rock for a top-down 2D farming RPG in the LPC style. Front view. A tall pale limestone rock with an arch through it, pigeons on top, waves at its base. ${ENDING}`},
		{name: "prop_tide_pools", ref: AI("prop_fountain"), size: "160x96", who: "Pigeon Rocks", prompt: `pixel art tide pool rocks for a top-down 2D farming RPG in the LPC style. Top-down view. Flat rocks with small pools of clear water, starfish, a crab, shells. ${ENDING}`},
		{name: "prop_herb_bed", ref: AI("prop_planter"), size: "128x64", who: "Resolve's Rise herb garden", prompt: `pixel art raised herb garden bed for a top-down 2D farming RPG in the LPC style. Front view. A wooden raised bed with rows of herbs: lavender, basil, rosemary, little name stakes (no letters). ${ENDING}`},
		{name: "prop_swing", ref: AI("prop_bench"), size: "128x96", who: "Dahya playground", prompt: `pixel art wooden swing set for a top-down 2D farming RPG in the LPC style. Front view. A wooden A-frame swing with two rope swings. ${ENDING}`},
		{name: "prop_flower_bed", ref: AI("prop_planter"), size: "128x64", who: "Verdun Street", prompt: `pixel art round flower bed for a top-down 2D farming RPG in the LPC style. Front view. A stone-edged bed of red, yellow and white flowers. ${ENDING}`},
		{name: "prop_beach_umbrella", ref: AI("prop_bench"), size: "96x96", who: "the beaches", prompt: `pixel art striped beach umbrella and towel for a top-down 2D farming RPG in the LPC style. Front view. A red and white striped umbrella over a towel on no ground. ${ENDING}`},
	]},
];

// ---------------------------------------------------------------- the document
const W = 9026;   // A4 text width in DXA (1" margins)
const img = (file, maxW = 230, maxH = 200) => {
	const data = fs.readFileSync(file), im = readPng(file);
	const s = Math.min(maxW / im.w, maxH / im.h, 2);
	return new ImageRun({type: "png", data, transformation: {width: Math.round(im.w * s), height: Math.round(im.h * s)}});
};
const p = (text, o = {}) => new Paragraph({spacing: {after: 100}, ...o, children: [new TextRun({text, ...(o.run || {})})]});
const bullet = text => new Paragraph({numbering: {reference: "bullets", level: 0}, children: [new TextRun(text)]});
const border = {style: BorderStyle.SINGLE, size: 4, color: "BBBBBB"};
const borders = {top: border, bottom: border, left: border, right: border};

function assetTable(it){
	const left = 3200, right = W - left;
	const refCell = it.ref
		? [new Paragraph({alignment: AlignmentType.CENTER, children: [img(it.ref)]}), p("Style reference: " + path.basename(it.ref), {alignment: AlignmentType.CENTER, run: {size: 16, color: "666666"}})]
		: [p(it.refNote, {alignment: AlignmentType.CENTER, run: {italics: true}})];
	return new Table({
		width: {size: W, type: WidthType.DXA}, columnWidths: [left, right],
		rows: [new TableRow({children: [
			new TableCell({borders, width: {size: left, type: WidthType.DXA}, shading: {fill: "F4F1EA", type: ShadingType.CLEAR},
				margins: {top: 100, bottom: 100, left: 100, right: 100}, children: refCell}),
			new TableCell({borders, width: {size: right, type: WidthType.DXA}, margins: {top: 100, bottom: 100, left: 160, right: 160}, children: [
				new Paragraph({spacing: {after: 60}, children: [new TextRun({text: it.name + ".png", bold: true, size: 24})]}),
				p("For: " + it.who, {run: {size: 18}}),
				p("Canvas: " + it.size, {run: {size: 18}}),
				p("Prompt (paste as it is):", {run: {bold: true, size: 18}}),
				p(it.prompt, {run: {size: 18, font: "Consolas"}}),
			]}),
		]})],
	});
}

const children = [
	new Paragraph({heading: HeadingLevel.TITLE, children: [new TextRun("Harvest Valley - PixelLab Asset Brief")]}),
	p("Every building and prop the new world still needs, with the image to give PixelLab as a style reference and the prompt to paste. Make them on any PixelLab account, name each file as shown, and send them back: I clean them (background, trimming), import them, place them and credit them."),
	new Paragraph({heading: HeadingLevel.HEADING_1, children: [new TextRun("How to make each one")]}),
	bullet("Tool: Create map object (the one that made the houses so far)."),
	bullet("Settings for all: view \"low top-down\", detail \"medium detail\", shading \"basic shading\", outline \"single color outline\"."),
	bullet("Canvas: the size given with each asset (the building should fill about 70-85% of it)."),
	bullet("Style reference: upload the image shown beside the prompt (they are in art/ai_houses and art/meshy_houses in the project), so the new one matches the houses we have."),
	bullet("Paste the prompt as it is. If a result comes out at an angle (side walls showing), try once more; the words \"no side walls visible\" usually fix it."),
	bullet("Save the PNG under the asset's name (for example home_saba.png) and send it to me. A flat background colour is fine."),
	p("About 39 assets in all. Sections 1 and 2 matter most (they make every home unique); 3 makes the farmhouse grow with its upgrades; 4 and 5 replace the placeholders."),
];
for(const sec of SECTIONS){
	children.push(new Paragraph({children: [new PageBreak()]}));
	children.push(new Paragraph({heading: HeadingLevel.HEADING_1, children: [new TextRun(sec.title)]}));
	children.push(p(sec.intro));
	for(const it of sec.items){ children.push(assetTable(it)); children.push(new Paragraph({spacing: {after: 160}, children: []})); }
}

const doc = new Document({
	creator: "Claude for the Harvest Valley team",
	title: "Harvest Valley - PixelLab Asset Brief",
	styles: {
		default: {document: {run: {font: "Arial", size: 21}}},
		paragraphStyles: [
			{id: "Title", name: "Title", basedOn: "Normal", run: {font: "Arial", size: 44, bold: true, color: "3B2F1E"}, paragraph: {spacing: {before: 0, after: 200}}},
			{id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true, run: {font: "Arial", size: 30, bold: true, color: "5A4220"}, paragraph: {spacing: {before: 240, after: 120}, keepNext: true, outlineLevel: 0}},
		],
	},
	numbering: {config: [{reference: "bullets", levels: [{level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT, style: {paragraph: {indent: {left: 720, hanging: 360}}}}]}]},
	sections: [{properties: {page: {margin: {top: 1440, bottom: 1440, left: 1440, right: 1440}}}, children}],
});
const out = path.join(ROOT, "design", "PixelLab_Asset_Brief.docx");
Packer.toBuffer(doc).then(b => { fs.writeFileSync(out, b); console.log("wrote " + out + " (" + SECTIONS.reduce((a, s) => a + s.items.length, 0) + " assets)"); });
