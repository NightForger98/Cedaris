"""Pick an icon frame for every held item (tool or weapon) and write icon_jobs.txt for icons.ps1.

usage: python -I icons.py <tools dir>
For each held item, the candidate frames are its custom (oversized) action sheet if it has one, else its
normal sheet's action rows (slash, thrust, shoot, spellcast) and walk rows, facing west and south. icons.ps1
finds the frame with the most item pixels and its bounding box, so icons show the whole tool, large.
"""
import json, os, sys

tools = sys.argv[1]
cat = json.load(open(os.path.join(tools, 'out', 'catalog.json')))
customs = json.load(open(os.path.join(tools, 'out', 'custom_anims.json')))
ROWS = {'spellcast': 0, 'thrust': 4, 'walk': 8, 'slash': 12, 'shoot': 16}

def pick_body(layers):
    for b in ['male', 'female', 'teen', 'muscular', 'pregnant', 'child']:
        if any(b in L['bodies'] for L in layers):
            return b
    return None

lines = []
for it in cat['items']:
    if it['slot'] != 'held':
        continue
    acts = sorted(it.get('actions', {}))
    if acts:
        act = acts[0]
        layers = it['actions'][act]
        fs = customs[act]['frameSize']
        rows = [1, 2]                           # west, south
    else:
        act = ''
        layers = it['layers']
        fs = 64
        rows = []
        for a in ['slash', 'thrust', 'shoot', 'spellcast']:
            if a in it.get('anims', []):
                rows = [ROWS[a] + 1, ROWS[a] + 2]
                break
        rows += [ROWS['walk'] + 1, ROWS['walk'] + 2]
    body = pick_body(layers)
    if body is None:
        continue
    files = [os.path.join(tools, 'sheets', L['bodies'][body] + '_raw.png') for L in layers if body in L['bodies']]
    lines.append('\t'.join([it['name'], act, str(fs), ','.join(map(str, rows)), ';'.join(files)]))
open(os.path.join(tools, 'out', 'icon_jobs.txt'), 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
print(len(lines), 'held items')
