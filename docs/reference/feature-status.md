# Reference: feature status

Screen-by-screen and capability-by-capability, what is actually shipped as of **v1.0.0** —
the precise companion to the [VISION scorecard](../VISION.md#honest-scorecard--built-vs-aspirational)
and [limitations](../limitations.md). "Tests" means automated coverage that exists today.

## Screens

| Screen | Status | Tests |
|---|---|---|
| Home (session list, couple pairing, entry points, Finish setup line) | ✅ Built | Golden + overflow; primary-action sweep; backup reminder test |
| Pool config (filter, size, custom add, veto, estimate) | ✅ Built | Primary-action sweep (360dp × 1.3, 320dp × 3.0) |
| Veto pass (keep/remove swipe) | ✅ Built | — |
| Matchup (pairwise, skip, undo, progress) | ✅ Built | Golden + overflow; notifier unit test |
| Solo results (ranking, fixed-scale bars, "show methodology") | ✅ Built | Ranked-tile golden; bars test (`ranking_bars_test`); methodology τ test; primary-action sweep |
| Couple results ("Matches", top-20 overlap, both ranks per match) | ✅ Built | `matches_ranks_test` (rank pairs, one colour); primary-action sweep; navigation tests |
| Name detail | ✅ Built — opened from any ranked row, match row, or shortlist row | Navigation widget test (Home → results → detail) |
| Shortlist (list, notes, remove with Undo, share) | ✅ Built | Navigation widget test (Home → shortlist → detail); remove/Undo test |
| Settings (τ, peeking-prevention statement, clear all sessions with Undo and Recently cleared, backup, version) | ✅ Built | Widget + overflow (backup section); clear/restore/delete-forever test; primary-action sweep |

## Capabilities

| Capability | Status |
|---|---|
| Solo loop: config → matchup → results | ✅ Real, load-bearing |
| Pairwise ranking via `eloEngine` (replay-from-history) | ✅ Real, data layer fully tested |
| Record / undo / skip | ✅ Real (undo ordered by insertion id) |
| Convergence detection (τ-tuned) | ✅ Real (engine `isConverged`) |
| "Show methodology" ensemble view (15 algorithms, Kendall's τ, cycles) | ✅ Built |
| Custom names + hard vetoes + quick veto pass | ✅ Built |
| Same-device two-player + peeking prevention | ✅ Built (both results routes guarded, pairing persisted); navigation tests pin the lock (`test/widget/navigation/peeking_lock_test.dart`) |
| Couple "Matches" (top-20 overlap, harmonic-mean order) | ✅ Built — overlap only, not a fused ranking |
| Shortlist with notes | ✅ Built |
| Plain-text share (top 10 / shortlist) | ✅ Built |
| Android APK build | ✅ Shipped (arm64, split-per-ABI via CI) |
| PWA / web build (Drift WASM) | ✅ Shipped |
| **PDF export** | ❌ Not wired — `pdf` dep present but unused |
| **Cross-device / separate-phones couple sync** | ❌ Not built (no server; horizon) |
| **Localization / non-English catalog** | ❌ Not built (~1,636 EN/US names) |
| Encrypted backup / restore (`.ohbk`, custom names + sessions + matches + shortlist) | ✅ Built ([sanctuary_auth_core](../../../packages/sanctuary_auth_core) / [sanctuary_backup_ui](../../../packages/sanctuary_backup_ui)); see [how-to](../how-to/encrypted-backup.md) |
| Accounts / cloud / analytics / ads | ❌ **Intentionally absent** ([ADR-0005](../adr/0005-local-first-no-account.md)) |

## Test surface (what exists)

- **Unit** (`test/`): 4 DAO tests + 3 repository tests on in-memory SQLite (incl.
  `buildEngine`/record/undo); the matchup notifier; the sanctuary backup serializer
  (round-trip, wrong-app/future-schema rejection, catalog preservation) and controller
  (export → restore end-to-end through the real crypto package).
- **Visual** (`test/visual/`): golden + overflow tests for home, matchup, ranked-name
  tile, and the convergence bar, each at text scale 1.0 and 3.0, phone and narrow widths;
  the settings screen (incl. the backup section) at 320dp / textScale 3.0.
- **Widget** (`test/widget/`): BackupSettingsSection across its ghost/set-up/exported
  states; navigation tests on the real router that tap from Home to Name Detail and
  the Shortlist (`test/widget/navigation/`).
- **A11y** (`test/a11y/primary_action_sweep_test.dart`): seven primary-action screens at
  360dp × 1.3 (the primary action must be tappable) and 320dp × 3.0 (no overflow),
  required by conformance check C5-primaryScreens.
- **Guards** (`test/unit/`): layering (only the session repository imports `elo_engine`),
  copy typography, font weights and literal sizes, the PWA shell's name and colours, the
  theme preference; `test/fleet_conformance_test.dart` runs C1–C13 including C9 routes,
  C10 raw errors, C11 app-bar labels, C12 accent vs error and C13 (the PWA loads nothing
  from Google's CDNs; `web/flutter_bootstrap.js`).
- **Gap:** the veto pass and pool setup have no content tests beyond the sweep.
