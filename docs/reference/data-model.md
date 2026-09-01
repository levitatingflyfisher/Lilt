# Reference: data model

Precise shapes for Lilt's persisted data and domain models. Source of truth:
`lib/services/database/tables.dart` (Drift schema v3, file `lilt.sqlite`) and
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
| `partnerSessionId` | TEXT? | the other half of a same-device couple, written on **both** rows in one transaction at hand-off (`SessionRepository.createPartnerSession`); `null` for solo. Added in schema v2 (`onUpgrade` → `addColumn`); pre-v2 couples keep `null` and Home falls back to pairing them by creation time. **End pairing** clears one side only (the one whose results it unlocks) |
| `deletedAt` | DATETIME? | set by **Clear all sessions** (a soft delete); `null` for a live session. Every read (`getSession`, `getAllSessions`) leaves cleared rows out, so screens and route guards treat them as gone. Settings' **Recently cleared** list restores them (clears the column; restoring one half of a couple restores both, so the peeking guard never sees a live session whose partner merely looks deleted) or deletes them forever with their `EloMatchRows`. Added in schema v3 |

### `EloMatchRows` — the comparison history (source of truth)

One row per recorded head-to-head. The `EloEngine` is rebuilt from these; ratings are
never stored ([ADR-0002](../adr/0002-history-is-source-of-truth.md)).

| Column | Type | Notes |
|---|---|---|
| `id` | INT, **PK autoincrement** | the stable total order for replay/undo |
| `sessionId` | TEXT, FK → `Sessions.id` | `ON DELETE CASCADE`, enforced: every connection sets `PRAGMA foreign_keys = ON` (`AppDatabase.beforeOpen`), so deleting a session deletes its matches and a match for an unknown session is refused |
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
- **Ranking models** (`ranking.dart`) — what screens see of the engine, built by
  `SessionRepository` so nothing in `features/` imports `elo_engine`:
  `ComparisonOutcome {aWins, bWins, tie, skip}` (the stored outcome strings);
  `SessionRanking` (`ranked: List<RankedName>` best first, `next: NamePair?`,
  `isConverged`, `rankOf(id)`); `RankedName` (`id`, `rating`, and `winChance`, the
  chance of beating a name of the pool's mean rating, 0–1); `Methodology` (Kendall τ,
  rankability, dimensions, cycle strength, `RankDisagreement`s keyed by method name).

## DAOs (`lib/services/database/daos/`)

| DAO | Methods |
|---|---|
| `NamesDao` | `countNames`, `getAllNames`, `getNamesByGender`, `getNamesByIds`, `insertNames`, `insertCustomName` |
| `SessionDao` | `getSession`, `getAllSessions` (both skip cleared rows), `getClearedSessions`, `insertSession`, `insertLinkedPartner`, `clearPartner`, `markComplete`, `clearAll`, `restore`, `deleteClearedForever` |
| `EloMatchesDao` | `getMatchesForSession` (ordered by `id`), `insertMatch`, `deleteLastMatch`, `getNonSkipMatchCount` |
| `ShortlistDao` | `getAll` (by `addedAt` desc), `isInShortlist`, `add`, `updateNote`, `remove` |

## Repositories (`lib/domain/repositories/`)

| Repository | Responsibility |
|---|---|
| `NamesRepository` | Catalog access, gender filter, `ensureLoaded()` first-launch seed, custom adds |
| `SessionRepository` | **The only `elo_engine` seam.** `createSession`, `createPartnerSession`, `buildEngine` (replay; domain-internal), `ranking` and `methodology` (the domain models screens read), `recordMatch`, `undoLastMatch`, `markComplete`, `endPairing`, `clearAllSessions` / `clearedSessions` / `restoreSessions` / `deleteClearedForever`, `getNonSkipMatchCount` |
| `ShortlistRepository` | Shortlist CRUD |

## ID conventions

- A name id is `"{lowercase-display}-{gender-code}"` and is used **unchanged** as the
  ranking engine's `EloItem.id` — there is no mapping layer.
- Sessions and shortlist entries use UUID v4.
- Match rows use an autoincrement integer `id`, which is also the replay/undo order.
