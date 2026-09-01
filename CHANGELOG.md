# Changelog

All notable changes to Lilt will be documented in this file.

## [Unreleased]

### Changed (fleet rollout, 2026-09)
- Adopts openhearth_design 0.7.2, sanctuary_backup_ui 0.3.0 and
  oh_fleet_conformance 0.8.1. Lora and Nunito now come from the design package;
  the app's own font files and OFL copy are gone.
- Failures are a plain sentence with a way out (`OhErrorState`), never the raw
  exception; an unknown name or page offers "Back to your sessions".
- **Clear all sessions** (was Clear Completed Sessions) clears finished and
  in-progress sessions at once, with an Undo that never times out and a Recently
  cleared list (Restore, Delete forever). Schema v3 adds `sessions.deleted_at`.
  Removing a shortlisted name offers Undo. End pairing asks through the shared confirm.
- Theme is light, dark or follow the phone (default), from the app bar on every
  screen but Matchup and the veto pass. Each screen caps its content at 640px on wide
  windows instead of the app-wide 760px clamp.
- Every app-bar command shows a word as well as an icon; Settings moved from Home's
  bar into the Home body. Home shows a dismissible "Backup isn't set up" line.
- On web, recovery words are stored under Lilt's own keys (fleet PWAs share an origin).
- Ranking bars use a fixed scale (chance of beating an average name in the pool) in
  one colour; Matches prints both partners' ranks for every match.
- Copy uses real apostrophes and quotes and no spaced em dashes; the done screen no
  longer promises "keep refining". The PWA manifest and page carry Lilt's name,
  description and colours.
- Only the session repository imports `elo_engine`; screens read domain models.

### Fixed
- Dark-mode readability: dark mode now carries a dark-tuned taupe accent
  (`#C9A876` — the same hue, lightened). Reusing the light accent left
  filled-button labels at 3.6:1 and accent text on the brown-black card
  surfaces at 3.6:1, below WCAG AA (4.5:1); both pairings now sit at
  ~7.5:1, verified by a computed-contrast test. Light mode keeps the
  original v1 taupe.

### Added
- `assets/fonts/OFL.txt`: the SIL Open Font License 1.1 text with the
  Lora and Nunito copyright notices (taken from the fonts' own
  metadata) now ships alongside the bundled faces, as the OFL requires;
  referenced from the README's License section.
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
