# Changelog

All notable changes to Lilt will be documented in this file.

## [Unreleased]

### Added
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

### Changed
- Backup envelope validation now goes through the fleet-shared
  `BackupEnvelope.unwrap`, and preview shares `restoreAll`'s exact
  validation gate so preview can never accept a file restore would
  reject. A wrong-app backup now surfaces as the standard corrupt-file
  outcome (same user-visible copy as before).
