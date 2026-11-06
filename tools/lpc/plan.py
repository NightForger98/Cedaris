"""Map LPC generator items onto Cedar & Sea creator slots and list the art files needed.

usage: python -I plan.py <lpc repo dir> <tree.txt> <out dir>
writes catalog.json (items, layers, sprites) and files.txt (sparse-checkout paths)
"""
import json, os, re, sys, collections

repo, tree_file, out = sys.argv[1:4]
tree = set(l.strip() for l in open(tree_file, encoding='utf-8'))

BODIES = ['male', 'female', 'muscular', 'teen', 'pregnant', 'child']
# Universal sheet rows, plus watering for the farm tools and run (rows 25-28, for sprinting)
ANIMS = ['spellcast', 'thrust', 'walk', 'slash', 'shoot', 'hurt', 'watering', 'run']

SLOT = {
    'body': 'body', 'head': 'head', 'ears': 'ears', 'nose': 'nose', 'eyes': 'eyes', 'eyebrows': 'eyebrows',
    'hair': 'hair', 'beard': 'beard', 'mustache': 'beard',
    'hat': 'hat', 'headcover': 'hat', 'bandana': 'hat',
    'facial_eyes': 'face', 'facial_mask': 'face', 'earrings': 'earrings',
    'neck': 'neck', 'necklace': 'neck', 'charm': 'neck',
    'clothes': 'shirt', 'dress': 'shirt', 'bandages': 'shirt',
    'vest': 'vest', 'chainmail': 'vest', 'apron': 'vest', 'overalls': 'vest',
    'jacket': 'coat', 'armour': 'coat',
    'belt': 'belt', 'sash': 'belt',
    'legs': 'pants', 'shoes': 'shoes', 'shoulders': 'shoulders', 'bauldron': 'bauldron',
    'bracers': 'wrist', 'wrists': 'wrist', 'gloves': 'gloves', 'cape': 'cape',
    'backpack': 'back', 'quiver': 'back',
    'weapon': 'held',
}
SKIP_FILES = {'body/special', 'body/wheelchair'}
# Items whose generator name doesn't say what they are (the bows are just "Normal", "Recurve", "Great")
RENAME = {'weapons/ranged/bow/weapon_ranged_bow_normal.json': 'Bow',
          'weapons/ranged/bow/weapon_ranged_bow_recurve.json': 'Recurve Bow',
          'weapons/ranged/bow/weapon_ranged_bow_great.json': 'Great Bow'}
BOW_WOOD = {'weapons/ranged/bow/weapon_ranged_bow_normal.json': 'medium',
            'weapons/ranged/bow/weapon_ranged_bow_recurve.json': 'dark',
            'weapons/ranged/bow/weapon_ranged_bow_great.json': 'light'}
# LPC custom (oversized) tool/weapon animations we support: they replay the body's slash or thrust rows.
# backslash_128 / halfslash_128 need body rows we don't convert. walk_128 is how the bows are carried: the game draws
# it in place of the held item while walking, frame for frame with the body's walk.
CUSTOM_OK = {'walk_128', 'tool_axe', 'tool_hammer', 'tool_rod', 'tool_whip', 'whip_oversize', 'slash_oversize',
             'slash_reverse_oversize', 'thrust_oversize', 'slash_128', 'thrust_128'}

def load(p):
    return json.load(open(p, encoding='utf-8'))

ramps, bases, source = {}, {}, {}
for m in ['body', 'eye', 'hair', 'cloth', 'metal', 'wood']:
    ramps[m] = load(os.path.join(repo, 'palette_definitions', m, m + '_ulpc.json'))
    bases[m] = load(os.path.join(repo, 'palette_definitions', m, 'meta_' + m + '.json'))['base']
    # Source colours can name an LPC Revised variant too; palettes offered in game are ULPC only
    lpcr = os.path.join(repo, 'palette_definitions', m, m + '_lpcr.json')
    source[m] = dict(load(lpcr)) if os.path.exists(lpcr) else {}
    source[m].update(ramps[m])

def groups_for(d):
    """Colour groups as [(material, base variant)], first one is player-selectable. None = fixed colours."""
    rc = d.get('recolors')
    if not rc:
        return None
    if 'material' in rc:
        rc = {'color_1': rc}
    gs = []
    for k in sorted(rc):
        g = rc[k]
        m = g.get('material')
        if m not in ramps:
            return None
        base = g.get('base') or bases[m]
        if base not in source[m]:
            base = bases[m]
        gs.append((m, base))
    return gs

def variant_choice(d):
    """For items shipped as one image per colour: a variant whose colours are a known cloth/metal ramp."""
    vs = d.get('variants') or []
    for m in ['cloth', 'metal']:
        for pref in [bases[m]] + list(ramps[m]):
            if pref in vs:
                return m, pref
    return None, (vs[0] if vs else None)

def sprite_name(path, variant):
    s = 'lpc_' + re.sub(r'[^a-z0-9]+', '_', path.lower()).strip('_')
    if variant:
        s += '_' + re.sub(r'[^a-z0-9]+', '_', variant.lower())
    return s

items, sprites, files = [], {}, set()
skipped = collections.Counter()
for dp, dn, fn in os.walk(os.path.join(repo, 'sheet_definitions')):
    for f in sorted(fn):
        if not f.endswith('.json') or f.startswith('meta_'):
            continue
        full = os.path.join(dp, f)
        rel = os.path.relpath(full, os.path.join(repo, 'sheet_definitions')).replace(os.sep, '/')
        d = load(full)
        slot = SLOT.get(d.get('type_name'))
        if slot is None or any(rel.startswith(s) for s in SKIP_FILES):
            skipped[d.get('type_name')] += 1
            continue
        if slot == 'body' and rel != 'body/body.json':
            continue

        groups = groups_for(d)
        mode, variant = 'recolor', None
        if rel in BOW_WOOD:
            # The bows: one natural wood finish each, in its own colours (their variant names would match cloth
            # ramps, and half a bow recoloured as cloth looks wrong)
            groups, mode, variant = None, 'variant_raw', BOW_WOOD[rel]
        elif groups is None:
            m, variant = variant_choice(d)
            if m:
                mode, groups = 'variant', [(m, variant)]
            elif variant:
                mode = 'variant_raw'
            else:
                mode = 'raw'

        layers = []
        actions = {}   # custom animation -> layers, for held items
        for lk in sorted(k for k in d if k.startswith('layer_')):
            L = d[lk]
            if L.get('is_mask'):
                continue
            if 'custom_animation' in L:
                anim = L['custom_animation']
                if slot != 'held' or anim not in CUSTOM_OK:
                    continue
                per_body = {}
                fv = variant.replace(' ', '_') if variant else None
                for b in BODIES:
                    path = L.get(b)
                    if not path:
                        continue
                    base = 'spritesheets/' + path.rstrip('/')
                    # One sheet already in the custom layout: <path>.png, <path>/<variant>.png or <path>/<anim>.png
                    cands = ([base + '/' + fv + '.png'] if fv else []) + [base + '.png', base + '/' + anim + '.png']
                    hit = next((c for c in cands if c in tree), None)
                    if hit is None:
                        continue
                    name = sprite_name(path.rstrip('/') + '/' + anim, variant if mode.startswith('variant') else None)
                    sprites[name] = {'custom': {'file': hit, 'anim': anim}, 'groups': groups, 'mode': mode}
                    files.add(hit)
                    per_body[b] = name
                if per_body:
                    actions.setdefault(anim, []).append({'z': L.get('zPos', 0), 'bodies': per_body})
                continue
            per_body = {}
            for b in BODIES:
                path = L.get(b)
                if not path:
                    continue
                path = path.rstrip('/') + '/'
                fv = variant.replace(' ', '_') if variant else None
                anim_files = {}
                for a in ANIMS:
                    p = 'spritesheets/' + path + (a + '/' + fv + '.png' if fv else a + '.png')
                    if p in tree:
                        anim_files[a] = p
                # A held item without a walk is drawn only while it's used - if it's carried by walk_128 (the bows)
                carried = slot == 'held' and any(d[k].get('custom_animation') == 'walk_128' for k in d if k.startswith('layer_'))
                if 'walk' not in anim_files and not (carried and anim_files):
                    continue
                name = sprite_name(path, variant if mode.startswith('variant') else None)
                sprites[name] = {'files': anim_files, 'groups': groups, 'mode': mode}
                files.update(anim_files.values())
                per_body[b] = name
            if per_body:
                layers.append({'z': L.get('zPos', 0), 'bodies': per_body})
        if not layers and not actions:
            skipped['no_art:' + str(d.get('type_name'))] += 1
            continue
        items.append({
            'name': RENAME.get(rel, d.get('name', f[:-5])), 'file': rel, 'slot': slot, 'mode': mode,
            'groups': groups, 'layers': layers, 'actions': actions, 'anims': d.get('animations', []),
            'credits': d.get('credits', []),
        })

os.makedirs(out, exist_ok=True)
json.dump({'items': items, 'sprites': sprites, 'ramps': ramps, 'source': source, 'bases': bases,
           'bodies': BODIES, 'anims': ANIMS}, open(os.path.join(out, 'catalog.json'), 'w'), indent=1)
open(os.path.join(out, 'files.txt'), 'w').write('\n'.join(sorted('/' + p for p in files)) + '\n')

by_slot = collections.Counter(i['slot'] for i in items)
print('items', len(items), dict(by_slot))
print('modes', dict(collections.Counter(i['mode'] for i in items)))
print('sprites', len(sprites), 'files', len(files))
print('bodies covered', dict(collections.Counter(b for i in items for L in i['layers'] for b in L['bodies'])))
print('skipped', skipped.most_common(15))
print('held items with custom actions', [(i['name'], sorted(i['actions'])) for i in items if i['actions']])
