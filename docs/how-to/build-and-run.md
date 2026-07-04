# How-to: build & run Lilt

Task-oriented. Assumes you have the Flutter SDK installed
(`flutter --version` ≥ the constraint in `pubspec.yaml`, Dart SDK ^3.10.7).

## 1. Clone `eloEngine` and `Lilt` side by side

Lilt depends on the ranking library by **path** (`elo_engine: { path: ../eloEngine }`), so
the two repos must be siblings ([ADR-0003](../adr/0003-ranking-in-separate-library.md)):

```bash
git clone git@github.com:levitatingflyfisher/eloEngine.git
git clone git@github.com:levitatingflyfisher/Lilt.git
# directory layout must be:
#   some-dir/
#     eloEngine/
#     Lilt/
```

If `eloEngine` isn't next to `Lilt`, `flutter pub get` fails to resolve the path
dependency.

## 2. Fetch dependencies and generate code

```bash
cd Lilt
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

The `build_runner` step generates the Drift `*.g.dart` files from `tables.dart` and the
DAOs. **Re-run it after any change to the schema, a DAO, or a `@DataClassName`.** If you
see analyzer errors about missing generated classes, you skipped this step.

## 3. Run it

```bash
flutter run                 # pick a connected device / emulator
flutter run -d chrome       # run the PWA build locally in a browser
```

On first launch the app shows a brief splash while `bootstrapProvider` loads
`assets/data/names.json` (~1,636 names) into SQLite. That happens once; subsequent launches
are instant.

## 4. Test and lint (before you commit)

```bash
flutter test        # unit tests (in-memory SQLite) + golden/overflow visual tests
flutter analyze     # static analysis per analysis_options.yaml
```

- Data-layer tests use `AppDatabase.forTesting(NativeDatabase.memory())` — no device
  needed.
- Golden tests render widgets at text scale 1.0 and 3.0 and at phone/narrow widths. If a
  deliberate visual change trips them, update the golden with
  `flutter test --update-goldens` and eyeball the diff before committing.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `pub get` can't resolve `elo_engine` | `eloEngine` not a sibling dir | Clone it next to `Lilt` (step 1) |
| Analyzer: undefined `_$AppDatabase` / DAO classes | codegen not run | `dart run build_runner build --delete-conflicting-outputs` |
| Web build: DB errors / blank after splash | missing WASM assets | Ensure `web/sqlite3.wasm` and `web/drift_worker.js` are present |
| Names never load, stuck on splash | asset not bundled | Confirm `assets/data/names.json` is listed under `flutter: assets:` in `pubspec.yaml` |
