"""Write scripts/lpc_credits/lpc_credits.gml (artist names for the credits screen) from LPC_CREDITS.csv.
usage: python -I credits_gml.py <project dir>"""
import csv, os, sys
proj = sys.argv[1]
authors, licences = set(), set()
for row in csv.DictReader(open(os.path.join(proj, 'LPC_CREDITS.csv'), encoding='utf-8')):
    authors.update(a.strip() for a in row['authors'].split(';') if a.strip())
    licences.update(l.strip() for l in row['licenses'].split(';') if l.strip())
q = lambda s: '"' + s.replace('"', "'") + '"'
names = sorted(authors, key=str.lower)
gml = ('/// Generated from LPC_CREDITS.csv by tools/lpc/credits_gml.py (do not edit by hand).\n'
       '/// Artists of the LPC character art, for the credits screen. Full per-piece list: LPC_CREDITS.csv.\n'
       'function lpc_credits(){\n\treturn {\n\t\tlicences: [%s],\n\t\tauthors: [\n%s\n\t\t],\n\t};\n}\n') % (
    ', '.join(q(l) for l in sorted(licences)), ',\n'.join('\t\t\t' + q(n) for n in names))
d = os.path.join(proj, 'scripts', 'lpc_credits')
os.makedirs(d, exist_ok=True)
open(os.path.join(d, 'lpc_credits.gml'), 'w', encoding='utf-8', newline='\n').write(gml)
print(len(names), 'authors', sorted(licences))
