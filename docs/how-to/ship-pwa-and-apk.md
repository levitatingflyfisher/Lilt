# How-to: ship a PWA and an APK

Lilt targets two install stories from one codebase
([ADR-0006](../adr/0006-dual-pwa-apk-target.md)): an installable Android **APK** and a
zero-install **PWA**. This guide covers building each and the automated release.

## Prerequisites

- `eloEngine` cloned as a sibling directory (see [build-and-run](build-and-run.md)).
- `flutter pub get` and `dart run build_runner build --delete-conflicting-outputs` already run.

## Build the web (PWA)

```bash
flutter build web --release
```

Output lands in `build/web/`. It bundles the Drift web backend — `web/sqlite3.wasm` and
`web/drift_worker.js` are shipped so the database runs off the main thread in the browser.
Things to know:

- The app requests **persistent storage** so PWA data survives browser eviction.
- On desktop-width viewports the UI clamps to a **760px** centered column (it's a
  phone-shaped app), so it stays usable in a wide browser window.
- Serve `build/web/` from any static host. `web/manifest.json` and `web/icons/` make it
  installable as a PWA.

## Build the Android APK / AAB

```bash
# Split-per-ABI release APKs (smaller downloads):
flutter build apk --split-per-abi --release

# Or an app bundle for the Play Store:
flutter build appbundle --release
```

APKs land in `build/app/outputs/flutter-apk/`, the AAB in
`build/app/outputs/bundle/release/`. In practice Lilt builds arm64-only for size.

## The automated release (recommended)

Releases are cut by tag, not by hand. `.github/workflows/release.yml` triggers on a
`v*.*.*` tag push and:

1. Checks out **both** `Lilt` and `openhearth/eloEngine` side by side.
2. `flutter pub get` → `build_runner` codegen → `flutter test` (the release is gated on
   green tests).
3. Builds split-per-ABI APKs and an AAB.
4. Generates SHA-256 checksums for every APK.
5. Publishes a **draft** GitHub release with the APKs, checksums, and AAB attached.

To cut a release:

```bash
git tag v1.0.1
git push origin v1.0.1
# then review and publish the draft release the workflow creates
```

The release is created as a **draft** on purpose — a human reviews the artifacts and notes
before it goes live.
