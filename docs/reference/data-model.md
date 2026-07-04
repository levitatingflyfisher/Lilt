# Reference: data model

Precise shapes for Lilt's persisted data and domain models. Source of truth:
`lib/services/database/tables.dart` (Drift schema v1, file `lilt.sqlite`) and
`lib/domain/models/`.

## Database tables

### `NameEntries` — the catalog (bundled + custom)

Seeded from `assets/data/names.json` on first launch; also holds user-added custom names.

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT, **PK** | `"{lowercase-display}-{gender-code}"`, e.g. `"eliot-m"` |
| `display` | TEXT | e.g. `"Eliot"` |
| `gender` | TEXT | `"m"` \| `"f"` \| `"n"` |
| `variants` | TEXT | JSON array of strings, e.g. `'["Elliot","Elliott"]'` |
| `isCustom` | BOOL | default `false`; `true` for user-added names |

### `Sessions` — one ranking run per participant

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT, **PK** | UUID v4 |
| `participantLabel` | TEXT? | `"Partner A"` \| `"Partner B"` \| `null` (solo) |
| `poolIds` | TEXT | JSON-encoded `List<String>` of `NameEntries.id` |
| `genderFilter` | TEXT | `"m"` \| `"f"` \| `"all"` |
| `poolSize` | INT | 30 \| 60 \| 120 \| custom (10–200) |
| `isComplete` | BOOL | default `false` |
| `resultsLocked` | BOOL | **default `true`** — peeking prevention |
| `createdAt` | DATETIME | |
| `completedAt` | DATETIME? | set on completion |

### `EloMatchRows` — the comparison history (source of truth)

One row per recorded head-to-head. The `EloEngine` is rebuilt from these; ratings are
never stored ([ADR-0002](../adr/0002-history-is-source-of-truth.md)).

| Column | Type | Notes |
|---|---|---|
| `id` | INT, **PK autoincrement** | the stable total order for replay/undo |
| `sessionId` | TEXT, FK → `Sessions.id` | `ON DELETE CASCADE` |
| `nameIdA` | TEXT | left name |
| `nameIdB` | TEXT | right name |
| `outcome` | TEXT | `"aWins"` \| `"bWins"` \| `"tie"` \| `"skip"` |
| `matchedAt` | DATETIME | display only — **not** the ordering key |

### `ShortlistEntries` — saved names

| Column | Type | Notes |
|---|---|---|
| `id` | TEXT, **PK** | UUID v4 |
| `nameId` | TEXT, FK → `NameEntries.id` | |
| `note` | TEXT? | optional free text |
| `addedAt` | DATETIME | list is shown most-recent first |

## Domain models (`lib/domain/models/`)

- **`Name`** — `id`, `display`, `gender: NameGender {male, female, neutral}`,
  `variants: List<String>`, `isCustom`. Helpers `genderFromCode()` / `genderToCode()` map
  the enum to `m`/`f`/`n`.
- **`NameSession`** — the row above as a model, with `copyWith` for the lifecycle flags.
- **`ShortlistEntry`** — `id`, a hydrated `Name`, `note?`, `addedAt`.

## DAOs (`lib/services/database/daos/`)

| DAO | Methods |
|---|---|
| `NamesDao` | `countNames`, `getAllNames`, `getNamesByGender`, `getNamesByIds`, `insertNames`, `insertCustomName` |
| `SessionDao` | `getSession`, `getAllSessions`, `insertSession`, `markComplete`, `deleteSession` |
| `EloMatchesDao` | `getMatchesForSession` (ordered by `id`), `insertMatch`, `deleteLastMatch`, `getNonSkipMatchCount` |
| `ShortlistDao` | `getAll` (by `addedAt` desc), `isInShortlist`, `add`, `updateNote`, `remove` |

## Repositories (`lib/domain/repositories/`)

| Repository | Responsibility |
|---|---|
| `NamesRepository` | Catalog access, gender filter, `ensureLoaded()` first-launch seed, custom adds |
| `SessionRepository` | **The only `elo_engine` seam.** `createSession`, `buildEngine` (replay), `recordMatch`, `undoLastMatch`, `markComplete`, `deleteSession`, `getNonSkipMatchCount` |
| `ShortlistRepository` | Shortlist CRUD |

## ID conventions

- A name id is `"{lowercase-display}-{gender-code}"` and is used **unchanged** as the
  ranking engine's `EloItem.id` — there is no mapping layer.
- Sessions and shortlist entries use UUID v4.
- Match rows use an autoincrement integer `id`, which is also the replay/undo order.
