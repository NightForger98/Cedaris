"""Parse the generator's sources/custom-animations.ts into custom_anims.json (frame size, frame lists).

usage: python -I custom_anims.py <custom-animations.ts> <out dir>
Get the .ts with: git -C <lpc repo> show HEAD:sources/custom-animations.ts > custom-animations.ts
"""
import re, json, sys, os

src = open(sys.argv[1], encoding='utf-8').read()
body = src[src.index('const customAnimations'):]
anims = {}
for m in re.finditer(r'\n  (\w+): \{\n    frameSize: (\d+),(.*?)\n  \},', body, re.S):
    rows = re.findall(r'\[\s*((?:"[^"]+",?\s*)+)\]', m[3])
    anims[m[1]] = {'frameSize': int(m[2]), 'single': 'sourceSingleAnimation: true' in m[3],
                   'frames': [re.findall(r'"([^"]+)"', r) for r in rows]}
json.dump(anims, open(os.path.join(sys.argv[2], 'custom_anims.json'), 'w'), indent=1)
print(len(anims), 'custom animations')
