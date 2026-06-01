#!/usr/bin/env python3
"""Build assets/data/names.json from a local SSA names.zip + curated additions."""
import csv, json, zipfile, io, os
from collections import defaultdict

ZIP_PATH = os.path.expanduser("~/Downloads/names.zip")
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
OUTPUT_PATH = os.path.join(PROJECT_DIR, "assets", "data", "names.json")
CURATED_PATH = os.path.join(SCRIPT_DIR, "curated_names.json")
TOP_N_PER_GENDER = 800

def gender_code(sex):
    return 'm' if sex.upper() == 'M' else 'f'

def name_id(display, gender):
    return f"{display.lower()}-{gender}"

def load_ssa_names(min_year=1990):
    print(f"Reading {ZIP_PATH} ...")
    counts = defaultdict(int)
    display_map = {}
    with zipfile.ZipFile(ZIP_PATH) as z:
        for fname in sorted(z.namelist()):
            if not fname.startswith('yob') or not fname.endswith('.txt'):
                continue
            year = int(fname[3:7])
            if year < min_year:
                continue
            with z.open(fname) as f:
                for row in csv.reader(io.TextIOWrapper(f)):
                    if len(row) != 3:
                        continue
                    display, sex, count_str = row[0].strip(), row[1].strip(), row[2].strip()
                    g = gender_code(sex)
                    nid = name_id(display, g)
                    counts[nid] += int(count_str)
                    if nid not in display_map:
                        display_map[nid] = display
    return {nid: {'display': display_map[nid], 'gender': nid[-1], 'count': counts[nid]} for nid in counts}

def main():
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    ssa = load_ssa_names()
    male   = sorted([(k,v) for k,v in ssa.items() if v['gender']=='m'], key=lambda x:-x[1]['count'])[:TOP_N_PER_GENDER]
    female = sorted([(k,v) for k,v in ssa.items() if v['gender']=='f'], key=lambda x:-x[1]['count'])[:TOP_N_PER_GENDER]
    entries = [{'id':k,'display':v['display'],'gender':v['gender'],'variants':[]} for k,v in male+female]

    if os.path.exists(CURATED_PATH):
        existing = {e['id'] for e in entries}
        added = 0
        for n in json.load(open(CURATED_PATH, encoding='utf-8')):
            if n['id'] not in existing:
                entries.append(n); existing.add(n['id']); added += 1
        print(f"  Added {added} curated names")

    entries.sort(key=lambda x: (x['gender'], x['display'].lower()))
    with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
        json.dump({'version': 1, 'names': entries}, f, indent=2, ensure_ascii=False)

    tally = defaultdict(int)
    for e in entries: tally[e['gender']] += 1
    labels = {'m': 'male', 'f': 'female', 'n': 'neutral'}
    print(f"Generated {len(entries)} names: " + ", ".join(f"{labels[g]}: {c}" for g,c in sorted(tally.items())))
    print(f"Written to {OUTPUT_PATH}")

if __name__ == '__main__':
    main()
