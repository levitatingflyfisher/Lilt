# How-to: customize the name catalog

There are two ways to change which names Lilt knows about: **in-app custom names** (per
user, at runtime) and **regenerating the bundled catalog** (for everyone, at build time).

## In-app: add a name while setting up a pool

No build required. On the **pool config** screen there's an *Add a Name* field: type a
name, tap Add, and it enters the ranking pool like any bundled name. It's stored in SQLite
with `isCustom = true` and an id of `"{lowercase-name}-{gender-code}"` (gender falls back to
neutral if no filter is set). This is the right path for a name your users want that isn't
in the shipped list.

## At build time: regenerate `assets/data/names.json`

The bundled catalog is generated, not hand-edited. The source of truth is
`scripts/build_name_dataset.py`, which combines a public **SSA baby-names** dataset with a
local **curated additions** file.

### Inputs

- **`~/Downloads/names.zip`** — the US SSA "National data" archive (`yobYYYY.txt` files:
  `name,sex,count`). The script reads years ≥ 1990 and keeps the **top 800 per gender** by
  total count.
- **`scripts/curated_names.json`** — a checked-in list of extra names (same
  `{id, display, gender, variants}` shape) that get merged in if not already present. This
  is where you add names the SSA top-800 misses, including `neutral` (`n`) names.

### Run it

```bash
cd Lilt
python3 scripts/build_name_dataset.py
```

It writes `assets/data/names.json` as `{ "version": 1, "names": [ … ] }`, sorted by gender
then display name, and prints a per-gender tally. Then rebuild the app so the new asset is
bundled (the catalog is re-seeded into SQLite only on a *fresh* install — see below).

### The record shape

```json
{ "id": "eliot-m", "display": "Eliot", "gender": "m", "variants": ["Elliot", "Elliott"] }
```

- `id` — `"{lowercase-display}-{gender-code}"`; must be unique. It maps 1:1 onto the ranking
  engine's item id, so keep it stable.
- `gender` — `"m"`, `"f"`, or `"n"`.
- `variants` — alternate spellings (stored; not yet surfaced in the ranking UI).

### Note on re-seeding

`NamesRepository.ensureLoaded()` populates SQLite from the asset **only when the table is
empty** (first launch), using `insertOrIgnore`. On a device that already has data, shipping a
new `names.json` will *not* retroactively add the new names to existing installs — it takes
effect on a fresh install or after the local database is cleared. Plan catalog changes
accordingly.
