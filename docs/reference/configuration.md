# Reference: configuration & settings

Every knob in Lilt, what it does, its range/default, and where it lives.

## User settings (Settings screen)

| Setting | Range / values | Default | Stored in | Effect |
|---|---|---|---|---|
| **Ranking confidence** (convergence τ) | 0.80–0.99 (slider, 19 steps) | `0.90` | `SharedPreferences` key `convergence_tau` | Higher τ = more comparisons, more stable ranking. Read by `convergenceTauProvider`, passed into `SessionRepository.ranking(convergenceTau:)`, and used by the engine's `isConverged` stability window. |
| **Peeking prevention** | always on — a statement, not a setting | on | per-session `resultsLocked` column + `partnerSessionId` pairing | Stated on the Settings screen as always on. Not switchable by design: the `/results/couple` guard requires `resultsLocked` on both sessions, so an "off" would dead-end the reveal. Enforced by that guard, the paired-session guard on `/results/solo`, and the hand-off's back-stack clear; pinned by `test/widget/navigation/peeking_lock_test.dart`. See [ADR-0004](../adr/0004-peeking-prevention.md). |
| **Clear all sessions** | action | — | `Sessions.deletedAt` | Clears every session, finished or in progress, at once (a soft delete, no dialog), with an Undo bar that never times out. **Keeps the shortlist.** Cleared sessions wait in **Recently cleared** (Settings) with Restore, and a Delete forever that asks first. |
| **Version** | display | `1.0.0` | — | App version label. |

> Note: `defaultTau = 0.90` in `settings_providers.dart`. The `eloEngine` library's own
> `EloConfig` default is `0.95`; Lilt overrides it to `0.90` when it builds the engine.

## Pool configuration (per session, Pool Config screen)

Not persisted as settings — chosen per session and captured on the `Sessions` row.

| Control | Values | Notes |
|---|---|---|
| **Gender filter** | All / Boys (`m`) / Girls (`f`) | Stored as `genderFilter` = `"all"`/`"m"`/`"f"` |
| **Pool size** | Quick 30 · Standard 60 · Comprehensive 120 · Custom | Custom is a 10–200 slider |
| **Add a name** | free text | Creates an `isCustom` catalog entry, id `"{name}-{gendercode}"` |
| **Hard vetoes** | free text, repeatable | Names excluded *before* ranking; shown as removable chips |
| **Quick veto pass** | keep / remove per name | Optional swipe pass over the candidate pool before ranking |

The **estimated comparisons** figure shown here and in the matchup screen is
`ceil(poolSize × 1.6)` — a heuristic for the progress display only, **not** the stopping
condition (that's the engine's `isConverged`).

## Theme & layout (compile-time)

| Item | Value | Where |
|---|---|---|
| Accent | `0xFF8B6F47` taupe (light), `0xFFC9A876` (dark) | `lib/app/theme.dart` |
| Theme mode | light, dark, or follow the phone (**default**), switched from the app-bar toggle on every screen except Matchup and the veto pass; stored under `lilt.themeMode` | `lib/core/providers/settings_providers.dart`, `lib/app/theme_toggle.dart` |
| Width cap | each screen's content capped at **640px** and centered on wider viewports (`OhPage`) | every `features/*_screen.dart` |
| DB filename | `lilt.sqlite` (native) / `lilt` (web WASM) | `connection/native.dart`, `connection/web.dart` |

## Routes (`lib/app/router.dart`)

| Path | Screen | Params |
|---|---|---|
| `/` | Home | — |
| `/pool-config` | Pool config | `?partnerB=1` · `?couple=1` · `?partnerA={sessionId}` |
| `/matchup/:sessionId` | Matchup | path `sessionId`; `?partnerA=` |
| `/results/solo/:sessionId` | Solo results | path `sessionId` — **guarded** for a paired, locked session: both partners must be complete, else redirect to `/` |
| `/results/couple` | Couple results | `?a={sessionId}&b={sessionId}` — **guarded**: both must be complete + locked, else redirect to `/` |
| `/name/:nameId` | Name detail | path `nameId`; `?a=` `?b=` |
| `/shortlist` | Shortlist | — |
| `/settings` | Settings | — |
