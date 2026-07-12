# How-to: build & run Lilt

Task-oriented. Assumes you have the Flutter SDK installed
(`flutter --version` ≥ the constraint in `pubspec.yaml`, Dart SDK ^3.10.7).

## 1. Clone the sibling packages next to `Lilt`

Lilt depends on three libraries by **path**: the ranking engine
(`elo_engine: { path: ../eloEngine }`,
[ADR-0003](../adr/0003-ranking-in-separate-library.md)) and the encrypted-backup pair,
`sanctuary_auth_core` + `sanctuary_backup_ui`
([encrypted backup how-to](encrypted-backup.md)). All three repos must be siblings of
`Lilt/`:

```bash
git clone git@github.com:levitatingflyfisher/eloEngine.git
git clone https://github.com/levitatingflyfisher/sanctuaryAuthCore packages/sanctuary_auth_core
git clone https://github.com/levitatingflyfisher/sanctuaryBackupUi packages/sanctuary_backup_ui
git clone git@github.com:levitatingflyfisher/Lilt.git
# directory layout must be:
#   some-dir/
#     eloEngine/
#     packages/
#       sanctuary_auth_core/
#       sanctuary_backup_ui/
#     Lilt/
```

If any of the three isn't in place, `flutter pub get` fails to resolve the path
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
| `pub get` can't resolve `elo_engine` / `sanctuary_auth_core` / `sanctuary_backup_ui` | one of the three sibling repos is missing | Clone it into the right place next to `Lilt` (step 1) |
| Analyzer: undefined `_$AppDatabase` / DAO classes | codegen not run | `dart run build_runner build --delete-conflicting-outputs` |
| Web build: DB errors / blank after splash | missing WASM assets | Ensure `web/sqlite3.wasm` and `web/drift_worker.js` are present |
| Names never load, stuck on splash | asset not bundled | Confirm `assets/data/names.json` is listed under `flutter: assets:` in `pubspec.yaml` |
