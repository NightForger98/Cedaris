"""Write converted LPC sheets into the GameMaker project as sprites, plus palettes,
the lpc_catalog script and LPC_CREDITS.csv. Removes the old index_/pal_ sprites.

usage: python -I finalize.py <tools dir> <project dir> <lpc repo dir>
"""
import json, os, re, sys, shutil, uuid, zlib, struct, csv, io

tools, proj, repo = sys.argv[1:4]
out = os.path.join(tools, 'out')
sheets = os.path.join(tools, 'sheets')
cat = json.load(open(os.path.join(out, 'catalog.json')))
meta = json.load(open(os.path.join(out, 'jobs_meta.json')))
general = None
picks, fixed_frac = {}, {}
for l in open(os.path.join(tools, 'convert_log.txt'), encoding='utf-8-sig'):
    m = re.match(r'OK (\S+) groups=\d+ \S+ opaque=(\d+) unmatched=(\d+) pick=(\S+)', l)
    if m:
        picks[m[1]] = [int(x) for x in m[4].split(',')]
        fixed_frac[m[1]] = int(m[3]) / max(1, int(m[2]))

BODIES = cat['bodies']
PAL_MATERIALS = ['body', 'eye', 'hair', 'cloth', 'metal', 'wood']

# ---------------------------------------------------------------- helpers
def png_bytes(pixels, w, h):
    raw = b''.join(b'\x00' + bytes(pixels[y * w * 4:(y + 1) * w * 4]) for y in range(h))
    def chunk(t, d):
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    return (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
            + chunk(b'IDAT', zlib.compress(raw, 9)) + chunk(b'IEND', b''))

def png_size(path):
    with open(path, 'rb') as f:
        head = f.read(24)
    return struct.unpack('>II', head[16:24])

def safe(s):
    return re.sub(r'[^a-z0-9]+', '_', s.lower()).strip('_')

new_sprites = []   # (name, folder)

def write_sprite(name, png_path, folder, w=None, h=None):
    if w is None:
        w, h = png_size(png_path)
    d = os.path.join(proj, 'sprites', name)
    if os.path.exists(d):
        shutil.rmtree(d)
    frame, layer, key = str(uuid.uuid4()), str(uuid.uuid4()), str(uuid.uuid4())
    os.makedirs(os.path.join(d, 'layers', frame))
    shutil.copyfile(png_path, os.path.join(d, frame + '.png'))
    shutil.copyfile(png_path, os.path.join(d, 'layers', frame, layer + '.png'))
    yy = SPRITE_YY.format(name=name, frame=frame, layer=layer, key=key, w=w, h=h, r=w - 1, b=h - 1,
                          folder=folder, folderpath='folders/Sprites/LPC/' + folder + '.yy')
    open(os.path.join(d, name + '.yy'), 'w', encoding='utf-8', newline='\n').write(yy)
    new_sprites.append((name, folder))

SPRITE_YY = '''{{
  "$GMSprite":"v2",
  "%Name":"{name}",
  "bboxMode":0,
  "bbox_bottom":{b},
  "bbox_left":0,
  "bbox_right":{r},
  "bbox_top":0,
  "collisionKind":1,
  "collisionTolerance":0,
  "DynamicTexturePage":false,
  "edgeFiltering":false,
  "For3D":false,
  "frames":[
    {{"$GMSpriteFrame":"v1","%Name":"{frame}","name":"{frame}","resourceType":"GMSpriteFrame","resourceVersion":"2.0",}},
  ],
  "gridX":0,
  "gridY":0,
  "height":{h},
  "HTile":false,
  "layers":[
    {{"$GMImageLayer":"","%Name":"{layer}","blendMode":0,"displayName":"default","isLocked":false,"name":"{layer}","opacity":100.0,"resourceType":"GMImageLayer","resourceVersion":"2.0","visible":true,}},
  ],
  "name":"{name}",
  "nineSlice":null,
  "origin":0,
  "parent":{{
    "name":"{folder}",
    "path":"{folderpath}",
  }},
  "preMultiplyAlpha":false,
  "resourceType":"GMSprite",
  "resourceVersion":"2.0",
  "sequence":{{
    "$GMSequence":"v1",
    "%Name":"{name}",
    "autoRecord":true,
    "backdropHeight":768,
    "backdropImageOpacity":0.5,
    "backdropImagePath":"",
    "backdropWidth":1366,
    "backdropXOffset":0.0,
    "backdropYOffset":0.0,
    "events":{{
      "$KeyframeStore<MessageEventKeyframe>":"",
      "Keyframes":[],
      "resourceType":"KeyframeStore<MessageEventKeyframe>",
      "resourceVersion":"2.0",
    }},
    "eventStubScript":null,
    "eventToFunction":{{}},
    "length":1.0,
    "lockOrigin":false,
    "moments":{{
      "$KeyframeStore<MomentsEventKeyframe>":"",
      "Keyframes":[],
      "resourceType":"KeyframeStore<MomentsEventKeyframe>",
      "resourceVersion":"2.0",
    }},
    "name":"{name}",
    "playback":1,
    "playbackSpeed":30.0,
    "playbackSpeedType":0,
    "resourceType":"GMSequence",
    "resourceVersion":"2.0",
    "showBackdrop":true,
    "showBackdropImage":false,
    "timeUnits":1,
    "tracks":[
      {{"$GMSpriteFramesTrack":"","builtinName":0,"events":[],"inheritsTrackColour":true,"interpolation":1,"isCreationTrack":false,"keyframes":{{"$KeyframeStore<SpriteFrameKeyframe>":"","Keyframes":[
            {{"$Keyframe<SpriteFrameKeyframe>":"","Channels":{{
                "0":{{"$SpriteFrameKeyframe":"","Id":{{"name":"{frame}","path":"sprites/{name}/{name}.yy",}},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",}},
              }},"Disabled":false,"id":"{key}","IsCreationKey":false,"Key":0.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,}},
          ],"resourceType":"KeyframeStore<SpriteFrameKeyframe>","resourceVersion":"2.0",}},"modifiers":[],"name":"frames","resourceType":"GMSpriteFramesTrack","resourceVersion":"2.0","spriteId":null,"trackColour":0,"tracks":[],"traits":0,}},
    ],
    "visibleRange":null,
    "volume":1.0,
    "xorigin":0,
    "yorigin":0,
  }},
  "swatchColours":null,
  "swfPrecision":2.525,
  "textureGroupId":{{
    "name":"Default",
    "path":"texturegroups/Default",
  }},
  "type":0,
  "VTile":false,
  "width":{w},
}}'''

# ---------------------------------------------------------------- palettes
pal_dir = os.path.join(tools, 'palettes')
os.makedirs(pal_dir, exist_ok=True)
palettes = {}        # (material, variant) -> sprite name

def palette_sprite(material, variant, colours):
    key = (material, variant)
    if key in palettes:
        return palettes[key]
    name = 'lpc_pal_' + safe(material) + '_' + safe(variant)
    px = []
    for c in colours:
        c = c.lstrip('#')
        px += [int(c[0:2], 16), int(c[2:4], 16), int(c[4:6], 16), 255]
    p = os.path.join(pal_dir, name + '.png')
    open(p, 'wb').write(png_bytes(px, len(colours), 1))
    write_sprite(name, p, 'Palettes', len(colours), 1)
    palettes[key] = name
    return name

general = json.load(open(os.path.join(repo, 'palette_definitions', 'all', 'all_lpcr.json')))
for m in PAL_MATERIALS:
    for v, cols in cat['ramps'][m].items():
        palette_sprite(m, v, cols)

def ramp_colours(material, variant):
    return general[variant] if material == 'all' else cat['source'][material][variant]

# ---------------------------------------------------------------- sprites per converted sheet
sublayers = {}   # sheet name -> [(sprite, kind)], kind: 'sel' | 'skin' | 'eye' | 'raw' | palette sprite name
sel_material = {}  # sheet name -> (material, default variant) of its selectable group

def folder_of(slot):
    return slot

slot_of_sheet = {}
for it in cat['items']:
    for L in it['layers']:
        for n in L['bodies'].values():
            slot_of_sheet.setdefault(n, it['slot'])

for name, s in sorted(cat['sprites'].items()):
    folder = folder_of(slot_of_sheet[name])
    subs = []
    if not s['groups']:
        write_sprite(name, os.path.join(sheets, name + '_raw.png'), folder)
        subs.append((name, 'raw'))
    else:
        cands = meta[name]
        chosen = [cands[g][p] for g, p in enumerate(picks[name])]
        has_sel = False
        for g, (m, v) in enumerate(chosen):
            src = os.path.join(sheets, name + ('' if g == 0 else '_g%d' % (g + 1)) + '.png')
            spr = name if g == 0 else name + '_g%d' % (g + 1)
            write_sprite(spr, src, folder)
            declared = s['groups'][g][0] if s['mode'] == 'recolor' else (m if m in ('cloth', 'metal') else 'cloth')
            if declared == 'body':
                kind = 'skin'
            elif declared == 'eye':
                kind = 'eye'
            elif not has_sel:
                kind, has_sel = 'sel', True
                default = v if (m == declared and v in cat['ramps'][declared]) else list(cat['ramps'][declared])[0]
                sel_material[name] = (declared, default)
            else:
                kind = palette_sprite(m if m != 'all' else 'all', v, ramp_colours(m, v))
            subs.append((spr, kind))
        fix = os.path.join(sheets, name + '_fix.png')
        if os.path.exists(fix):
            write_sprite(name + '_fix', fix, folder)
            subs.append((name + '_fix', 'raw'))
    sublayers[name] = subs

# ---------------------------------------------------------------- GML catalog
def gml_str(s):
    return '"' + s.replace('\\', '/').replace('"', "'") + '"'

KIND = {'sel': '-1', 'skin': '-2', 'eye': '-3', 'raw': '-4'}
lines = []
for it in cat['items']:
    first = next(iter(it['layers'][0]['bodies'].values()))
    mat, default = sel_material.get(first, ('', ''))
    def_pal = palettes[(mat, default)] if mat else '-1'
    # Mostly fixed colours (gems, glasses...): recolouring barely shows, so offer no colour choice
    if max(fixed_frac.get(n, 0) for L in it['layers'] for n in L['bodies'].values()) > 0.5:
        mat = ''
    layer_src = []
    for L in it['layers']:
        bodies = []
        for b, n in L['bodies'].items():
            subs = ', '.join('{spr: %s, k: %s}' % (spr, KIND.get(k, k)) for spr, k in sublayers[n])
            bodies.append('%s: [%s]' % (b, subs))
        layer_src.append('{z: %d, %s}' % (L['z'], ', '.join(bodies)))
    lines.append('\t\t{name: %s, slot: %s, material: %s, defPal: %s, layers: [%s]},' % (
        gml_str(it['name']), gml_str(it['slot']), gml_str(mat), def_pal, ', '.join(layer_src)))

pal_lines = []
for m in PAL_MATERIALS:
    vs = list(cat['ramps'][m])
    pal_lines.append('\t\t%s: [%s],' % (m, ', '.join(palettes[(m, v)] for v in vs)))
    pal_lines.append('\t\t%s_names: [%s],' % (m, ', '.join(gml_str(v.replace('_', ' ')) for v in vs)))

gml = '''/// Generated from the Universal LPC Spritesheet Character Generator by tools/lpc (do not edit by hand).
/// Every item: slot, selectable palette material, default palette, and its layers.
/// Each layer has a draw depth z (higher draws on top) and, per body type, a list of
/// sprites with how each is coloured:
///   k = -1 selectable palette, -2 skin palette, -3 eye palette, -4 fixed colours, or a fixed palette sprite.
/// Sheets use the universal LPC layout (64x64 frames, walk cycle in rows 8-11, watering in rows 21-24).
function lpc_catalog(){
	static cat = undefined;
	if(cat != undefined) return cat;
	cat = {};
	cat.bodies = [%s];
	cat.palettes = {
%s
	};
	cat.items = [
%s
	];
	return cat;
}
''' % (', '.join(gml_str(b) for b in BODIES), '\n'.join(pal_lines), '\n'.join(lines))

sd = os.path.join(proj, 'scripts', 'lpc_catalog')
os.makedirs(sd, exist_ok=True)
open(os.path.join(sd, 'lpc_catalog.gml'), 'w', encoding='utf-8', newline='\n').write(gml)
open(os.path.join(sd, 'lpc_catalog.yy'), 'w', encoding='utf-8', newline='\n').write(
    open(os.path.join(proj, 'scripts', 'respawn_crop', 'respawn_crop.yy'), encoding='utf-8').read().replace('respawn_crop', 'lpc_catalog'))

# ---------------------------------------------------------------- credits
rows = []
seen = set()
for it in cat['items']:
    for c in it['credits']:
        k = c.get('file')
        if k in seen:
            continue
        seen.add(k)
        rows.append([it['name'], c.get('file', ''), '; '.join(c.get('authors', [])), '; '.join(c.get('licenses', [])),
                     '; '.join(c.get('urls', [])), c.get('notes', '')])
buf = io.StringIO()
w = csv.writer(buf)
w.writerow(['item', 'source', 'authors', 'licenses', 'urls', 'notes'])
w.writerows(rows)
open(os.path.join(proj, 'LPC_CREDITS.csv'), 'w', encoding='utf-8', newline='').write(buf.getvalue())

# ---------------------------------------------------------------- project file
yyp_path = os.path.join(proj, [f for f in os.listdir(proj) if f.endswith('.yyp')][0])
yyp = open(yyp_path, encoding='utf-8').read()
ro_path = yyp_path.replace('.yyp', '.resource_order')
ro = open(ro_path, encoding='utf-8').read() if os.path.exists(ro_path) else None

# drop old index_/pal_ sprites
old = re.findall(r'\{"id":\{"name":"((?:index|pal)_[^"]+)","path":"sprites/[^"]+",\},\},\n', yyp)
old += ['woodanddrirtpal']
for n in old:
    yyp = re.sub(r'    \{"id":\{"name":"%s","path":"sprites/[^"]+",\},\},\n' % re.escape(n), '', yyp)
    if ro:
        ro = re.sub(r'    \{"name":"%s","order":\d+,"path":"sprites/[^"]+",\},\n' % re.escape(n), '', ro)
    d = os.path.join(proj, 'sprites', n)
    if os.path.isdir(d):
        shutil.rmtree(d)

# drop any earlier LPC entries, then add the new ones
yyp = re.sub(r'    \{"id":\{"name":"lpc_[^"]+","path":"(?:sprites|scripts)/[^"]+",\},\},\n', '', yyp)
yyp = re.sub(r'    \{"\$GMFolder":"","%Name":"[^"]+","folderPath":"folders/Sprites/LPC[^"]*",[^\n]*\n', '', yyp)
res = ''.join('    {"id":{"name":"%s","path":"sprites/%s/%s.yy",},},\n' % (n, n, n) for n, _ in new_sprites)
res += '    {"id":{"name":"lpc_catalog","path":"scripts/lpc_catalog/lpc_catalog.yy",},},\n'
yyp = yyp.replace('  "resources":[\n', '  "resources":[\n' + res, 1)
folders = sorted({f for _, f in new_sprites})
fl = '    {"$GMFolder":"","%Name":"LPC","folderPath":"folders/Sprites/LPC.yy","name":"LPC","resourceType":"GMFolder","resourceVersion":"2.0",},\n'
fl += ''.join('    {"$GMFolder":"","%%Name":"%s","folderPath":"folders/Sprites/LPC/%s.yy","name":"%s","resourceType":"GMFolder","resourceVersion":"2.0",},\n' % (f, f, f) for f in folders)
yyp = yyp.replace('  "Folders":[\n', '  "Folders":[\n' + fl, 1)
open(yyp_path, 'w', encoding='utf-8', newline='\n').write(yyp)
if ro:
    open(ro_path, 'w', encoding='utf-8', newline='\n').write(ro)

print('removed old sprites', len(old))
print('new sprites', len(new_sprites), 'palettes', len(palettes))
print('items', len(cat['items']), 'credits rows', len(rows))
