"""Turn catalog.json into jobs.txt for the C# pixel converter.

usage: python -I jobs.py <out dir> <lpc repo dir>
line: name <TAB> groups <TAB> files
  groups: "" for fixed-colour art, else per colour group a list of candidate ramps:
          "rrggbb,...,rrggbb/rrggbb,...|..."  ('|' between groups, '/' between candidates)
          The converter picks the candidate that matches the most pixels.
  files:  "anim=abs path;anim=abs path"
Also writes jobs_meta.json: for each sprite and group, the (material, variant) of every candidate.
"""
import json, os, sys

out, repo = sys.argv[1:3]
cat = json.load(open(os.path.join(out, 'catalog.json')))
general = json.load(open(os.path.join(repo, 'palette_definitions', 'all', 'all_lpcr.json')))

def candidates(material, base):
    """Base variant first, then every other ramp of the same material, then the general LPC ramps."""
    c = [(material, base)] + [(material, v) for v in cat['source'][material] if v != base]
    if material != 'eye':
        c += [('all', v) for v in general]
    return c

def ramp(material, variant):
    src = general if material == 'all' else cat['source'][material]
    return ','.join(h.lstrip('#').lower() for h in src[variant])

lines, meta = [], {}
for name, s in sorted(cat['sprites'].items()):
    groups = ''
    if s['groups']:
        if s['mode'] == 'variant':
            # One image per colour: could be any cloth or metal ramp
            cands = [('cloth', v) for v in cat['source']['cloth']] + [('metal', v) for v in cat['source']['metal']] \
                    + [('all', v) for v in general]
            gl = [cands]
        else:
            gl = [candidates(m, base) for m, base in s['groups']]
        meta[name] = gl
        groups = '|'.join('/'.join(ramp(m, v) for m, v in g) for g in gl)
    files = ';'.join(a + '=' + os.path.join(repo, p.replace('/', os.sep)) for a, p in s['files'].items())
    lines.append('\t'.join([name, groups, files]))
open(os.path.join(out, 'jobs.txt'), 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
json.dump(meta, open(os.path.join(out, 'jobs_meta.json'), 'w'))
print(len(lines), 'jobs')
