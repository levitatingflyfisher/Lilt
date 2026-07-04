# AGENTS.md

Guidance for AI coding agents (and humans) working in this repo. This is the top-level
map; read it before non-trivial work.

**Read these three, in order, before you change anything load-bearing:**
1. [VISION.md](VISION.md) — what must stay true and why (the invariants).
2. [docs/architecture/OVERVIEW.md](docs/architecture/OVERVIEW.md) — how it fits together, with diagrams.
3. [docs/concepts.md](docs/concepts.md) — the domain model (names, sessions, matches, convergence, couples).

## Take the code as current-state, not gospel

Every line of source and every comment here was written by an AI assistant. Treat it as
**an accurate record of what currently exists, offered with gratitude and a grain of
salt** — not as a specification and not as guaranteed-correct. A comment claiming an
invariant is a *hypothesis to verify*, not a proof. If a comment and the tests disagree,
the tests win; if the tests and reality disagree, reality wins. (Two live examples: an
old note claimed five screens were stubs — they are all built now; another claimed
couple results use `EloMerge` — they actually use a top-20 overlap scored by harmonic
mean. Confirm before you rely.)

## What this is

A **local-first baby-name ranking app** for couples. Configure a pool of names, rank
them by rapid pairwise comparison, get a stable ranking; two partners can each rank the
same pool on one device and see where they overlap — with results hidden until both
finish. Flutter + Clean Architecture + Riverpod + Drift. The ranking math lives in a
separate library, [`eloEngine`](../eloEngine); this repo is the product on top of it.

## Non-negotiables (breaking one is a regression, not a feature)

- **Local-first, no account, no network.** No sign-up, no server, no sync, no analytics.
  Adding a network call or a telemetry SDK is a design regression. Everything persists
  on-device via Drift/SQLite.
- **Nothing leaves the device except an explicit user *Share*.** The only egress is the
  plain-text share on the results and shortlist screens, initiated by a tap. Keep it
  that way.
- **The match history is the source of truth.** Never persist computed ratings. Every
  read rebuilds the engine by replaying `EloMatchRows` (`SessionRepository.buildEngine`).
  If you cache, cache a *rebuild*, never a rating.
- **Peeking prevention stays locked-by-default.** Do not weaken the couple-results
  route guard (`/results/couple` redirects home unless both sessions are complete *and*
  locked).
- **Respect the layering.** `features/` (presentation) → `repositories/` (domain) →
  `daos/` + Drift (data). The UI must not import Drift rows or `elo_engine` directly.
  **Exactly one file imports `elo_engine`:** `lib/domain/repositories/session_repository.dart`.
  Keep it that way.
- **TDD, always.** Data-layer tests run on in-memory SQLite
  (`AppDatabase.forTesting(NativeDatabase.memory())`). Every bugfix ships a regression
  test. Regenerate `.g.dart` after any schema/DAO change (see below).
- **Atomic commits, one concern each.** Commit messages state the *why*. **No AI
  attribution** (`Co-Authored-By` / "Generated with" lines) — deliberate project policy.
- **Never commit** `CLAUDE.md`, `GEMINI.md`, or `docs/superpowers/` — they are
  gitignored working artifacts. This repo ships `AGENTS.md`.

## Where things are (progressive disclosure)

Start with the module map in
[OVERVIEW.md § Module map](docs/architecture/OVERVIEW.md#module-map-where-to-look).
The short version, by concern:

| You're touching… | Go to |
|---|---|
| **App shell / routing** | `lib/main.dart`, `lib/app/app.dart` (theme, bootstrap splash, 760px desktop clamp), `lib/app/router.dart` (8 routes + couple guard) |
| **The ranking integration** | `lib/domain/repositories/session_repository.dart` — the *only* `elo_engine` consumer (`buildEngine`, `recordMatch`, `undoLastMatch`) |
| **The matchup loop** | `lib/features/matchup/matchup_notifier.dart` (state, progress, record/undo), `matchup_screen.dart` |
| **Results** | `lib/features/results/solo_results_screen.dart` (ranking bars + "show methodology" ensemble), `couple_results_screen.dart` (top-20 overlap, harmonic-mean) |
| **Pool setup** | `lib/features/pool_config/pool_config_screen.dart` (filter, size, custom adds, vetoes), `veto_screen.dart` (swipe veto pass) |
| **Shortlist / detail / settings** | `lib/features/shortlist/`, `name_detail/`, `settings/` |
| **The data model** | `lib/services/database/tables.dart` (4 tables), `database.dart`, `daos/` (4 DAOs) |
| **Domain models** | `lib/domain/models/` (`name.dart`, `name_session.dart`, `shortlist_entry.dart`) |
| **Providers / config** | `lib/core/providers/` (`repository_providers`, `bootstrap_provider`, `settings_providers` — convergence τ) |
| **The name catalog** | `assets/data/names.json` (~1,636 names), built by `scripts/build_name_dataset.py` |
| **Web / native DB glue** | `lib/services/database/connection/` (`native.dart`, `web.dart`, `connection.dart`) |

Docs are organized [Diátaxis](https://diataxis.fr/)-style — see [docs/README.md](docs/README.md)
for the tutorials / how-to / reference / explanation split.

## How to work here

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift codegen (the .g.dart files)
flutter test                                               # unit + golden/overflow — green before commit
flutter analyze                                            # lints (analysis_options.yaml) — must pass
```

- **`eloEngine` must be a sibling checkout.** `pubspec.yaml` depends on it by path
  (`../eloEngine`). Clone it next to this repo, or `flutter pub get` fails. The release
  workflow checks out `openhearth/eloEngine` alongside `Lilt`.
- **Drift codegen is not optional.** The `*.g.dart` files are generated from
  `tables.dart` / the DAOs; re-run `build_runner` whenever you change the schema, a DAO,
  or a `@DataClassName`.
- **New screen?** Define a screen-local `FutureProvider.family` / `AsyncNotifierProvider.family`
  keyed by `sessionId`, watching a repository provider. Follow the matchup notifier as
  the pattern.
- **Web build** ships `sqlite3.wasm` + `drift_worker.js` from `web/`; the DB runs off
  the main thread. Don't assume `dart:io` — the connection layer is conditionally
  imported.

## When you're unsure

Prefer a failing test to a plausible fix. Prefer matching the surrounding code to a new
pattern. Prefer keeping data on-device to any convenience that sends it off. When in
doubt about a decision's rationale, grep [docs/adr/](docs/adr/) before reopening it —
you may be re-litigating a settled trade-off.
