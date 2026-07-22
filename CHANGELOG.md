# Changelog

All notable changes to Lilt will be documented in this file.

## [Unreleased]

### Fixed
- Dark-mode readability: dark mode now carries a dark-tuned taupe accent
  (`#C9A876` — the same hue, lightened). Reusing the light accent left
  filled-button labels at 3.6:1 and accent text on the brown-black card
  surfaces at 3.6:1, below WCAG AA (4.5:1); both pairings now sit at
  ~7.5:1, verified by a computed-contrast test. Light mode keeps the
  original v1 taupe.

### Added
- Dark mode. Lilt adopts the shared OpenHearth design grammar
  (`openhearth_design`): `OhTheme.light` on warm linen by day and
  `OhTheme.hearthDark`'s brown-black surfaces after sundown, following
  the system setting. Lilt's taupe stays as the app-signature accent in
  both. Dark mode arrives via the grammar rather than being hand-rolled —
  the whole tri-theme surface/typography system comes from one shared
  package.
- Bundled Lora (headings) and Nunito (UI text) faces — the fleet's OFL
  fonts — so the grammar renders its real typography offline, with zero
  network font fetches.
- Snapshot vault ("Previous backups" in Settings, via sanctuary_backup_ui
  v0.2.0): every encrypted export and every restore leaves a stamped
  on-device snapshot (keep-10, pinnable) you can restore, pin or delete.
- Mandatory pre-restore snapshot: a restore refuses to run unless the
  current data was snapshotted (and the snapshot verified by read-back)
  first — restoring is now reversible.
- Preview before restore: the confirm dialog shows the backup's age and
  per-table row counts next to what's on the device now. Counts are
  honest about Lilt's restore scope — `nameEntries` is your custom names
  only, because the bundled name catalog is never backed up or replaced.
- Encrypted exports verify themselves by read-back before reporting
  success, and the backup payload now carries a `createdAt` stamp
  additively (older backups still restore; older app versions still read
  new backups — no legacy key was removed or renamed).
- Plain-JSON export tile for unencrypted, human-readable copies.
- Silent freshness snapshot on app open when the newest one is older
  than 7 days and a backup key exists (post-frame, never blocks boot).
- Fleet conformance suite (`oh_fleet_conformance`): the OpenHearth
  standards as tests — canonical design grammar, backup-retention
  enforcement, size budgets (`budgets.json` records baseline+5% for the
  gzipped web JS and the arm64 APK), the zero-Android-permission claim
  verified in both directions, and the canonical test/CI harness.
- Push/PR CI workflow (analyze + test, debug-APK smoke, web-release
  smoke at the deploy base-href), pinned to the fleet Flutter 3.38.7.
  Release CI previously pointed its eloEngine clone at a nonexistent
  org and never cloned ohStyle — both fixed.

### Changed
- `test/flutter_test_config.dart` is now the fleet-canonical
  FontManifest-aware variant (byte-identical across the fleet). It
  loads the same bundled Lora/Nunito, via the asset manifest instead of
  direct file reads; all 16 goldens verified pixel-stable under the
  swap.
- The "Don't care" matchup button's label now uses the secondary-text
  color role instead of the outline border token — under the grammar the
  border token is a pale linen that is unreadable as text.
- Backup envelope validation now goes through the fleet-shared
  `BackupEnvelope.unwrap`, and preview shares `restoreAll`'s exact
  validation gate so preview can never accept a file restore would
  reject. A wrong-app backup now surfaces as the standard corrupt-file
  outcome (same user-visible copy as before).

### Removed
- The unused `pdf` dependency (no import anywhere in `lib/` or `test/`)
  and its 10 transitive packages.
