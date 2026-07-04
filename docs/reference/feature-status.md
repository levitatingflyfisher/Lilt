# Reference: feature status

Screen-by-screen and capability-by-capability, what is actually shipped as of **v1.0.0** —
the precise companion to the [VISION scorecard](../VISION.md#honest-scorecard--built-vs-aspirational)
and [limitations](../limitations.md). "Tests" means automated coverage that exists today.

## Screens

| Screen | Status | Tests |
|---|---|---|
| Home (session list, couple pairing, entry points) | ✅ Built | Golden + overflow |
| Pool config (filter, size, custom add, veto, estimate) | ✅ Built | — |
| Veto pass (keep/remove swipe) | ✅ Built | — |
| Matchup (pairwise, skip, undo, progress) | ✅ Built | Golden + overflow; notifier unit test |
| Solo results (ranking, bars, "show methodology") | ✅ Built | Ranked-tile golden; screen itself untested |
| Couple results ("Matches", top-20 overlap) | ✅ Built | **None** — thinly verified |
| Name detail | ✅ Built | — |
| Shortlist (list, notes, remove, share) | ✅ Built | — |
| Settings (τ, clear sessions, version) | ✅ Built | — |

## Capabilities

| Capability | Status |
|---|---|
| Solo loop: config → matchup → results | ✅ Real, load-bearing |
| Pairwise ranking via `eloEngine` (replay-from-history) | ✅ Real, data layer fully tested |
| Record / undo / skip | ✅ Real (undo ordered by insertion id) |
| Convergence detection (τ-tuned) | ✅ Real (engine `isConverged`) |
| "Show methodology" ensemble view (15 algorithms, Kendall's τ, cycles) | ✅ Built |
| Custom names + hard vetoes + quick veto pass | ✅ Built |
| Same-device two-player + peeking prevention | ✅ Built (route-guarded); couple UI untested |
| Couple "Matches" (top-20 overlap, harmonic-mean order) | ✅ Built — overlap only, not a fused ranking |
| Shortlist with notes | ✅ Built |
| Plain-text share (top 10 / shortlist) | ✅ Built |
| Android APK build | ✅ Shipped (arm64, split-per-ABI via CI) |
| PWA / web build (Drift WASM) | ✅ Shipped |
| **PDF export** | ❌ Not wired — `pdf` dep present but unused |
| **Cross-device / separate-phones couple sync** | ❌ Not built (no server; horizon) |
| **Localization / non-English catalog** | ❌ Not built (~1,636 EN/US names) |
| **In-app full backup/export** | ❌ Not built (plain-text share only) |
| Accounts / cloud / analytics / ads | ❌ **Intentionally absent** ([ADR-0005](../adr/0005-local-first-no-account.md)) |

## Test surface (what exists)

- **Unit** (`test/`): 4 DAO tests + 3 repository tests on in-memory SQLite (incl.
  `buildEngine`/record/undo); the matchup notifier.
- **Visual** (`test/visual/`): golden + overflow tests for home, matchup, ranked-name
  tile, and the convergence bar, each at text scale 1.0 and 3.0, phone and narrow widths.
- **Gap:** widget tests for the solo- and couple-results screens, name detail, shortlist,
  and settings.
