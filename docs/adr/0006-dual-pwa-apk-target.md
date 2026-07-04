# ADR-0006: Ship as both a PWA and an APK

- **Status:** Accepted
- **Date:** 2026-07-03 (documenting the web-enablement decision)

## Context

Flutter targets many platforms, but the two that matter for a family utility are a phone
you install and a link you can just open. An installable **Android APK** gives the native,
offline, home-screen experience; a **PWA** removes all friction — try it in a browser, no
store, no install. The hard part is the database: Drift's default native backend uses
`dart:io`, which does not exist on the web.

## Decision

Ship **both**, from one codebase, with a conditional database connection:

- `lib/services/database/connection/connection.dart` conditionally imports **`native.dart`**
  (`NativeDatabase.createInBackground` on a file in the app documents dir) or
  **`web.dart`** (`WasmDatabase` running off the main thread).
- The web build bundles `sqlite3.wasm` and `drift_worker.js` (checked into `web/`).
- On desktop-width viewports the app clamps its content to a **760px** centered column so
  the phone-shaped UI stays usable in a browser window.
- The web build requests **persistent storage** so PWA data survives browser eviction.
- Release is automated: a tagged push (`v*.*.*`) triggers GitHub Actions to run tests,
  then build **split-per-ABI APKs** and an **AAB**, with SHA-256 checksums, as a draft
  release. (Android is built arm64-only in practice for size.)

## Consequences

- **Buys:** one code path for two very different install stories; the same tested Drift
  schema on both; a zero-install way to try Lilt.
- **Costs:** the web target constrains the data layer to what compiles to WASM (no
  `dart:io` assumptions); the WASM assets must be kept in sync with the Drift version; some
  responsive/layout care (the 760px clamp, golden tests) that a phone-only app could skip.
- **Forecloses:** using any plugin or API that is native-only without a web fallback in
  the conditional layer.

## Alternatives considered

- **Android-only (native deps):** rejected here — Lilt has no native-only dependency that
  would force it, and the PWA's frictionless trial is worth the WASM plumbing. (Some
  sibling apps with native deps *are* APK-only; this one isn't.)
- **Web-only PWA:** rejected — the installed, fully-offline phone app is the primary
  experience for the target user.
