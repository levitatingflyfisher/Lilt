import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lilt/services/database/database.dart';

/// Schema v2 added `sessions.partner_session_id` (the persisted couple
/// pairing) and v3 `sessions.deleted_at` (Clear all sessions is a soft
/// delete). A v1 database must upgrade in place, keeping its rows live.
void main() {
  test('a v1 database upgrades to the current schema and keeps its sessions', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory(setup: (raw) {
      raw.execute('CREATE TABLE "name_entries" ("id" TEXT NOT NULL, '
          '"display" TEXT NOT NULL, "gender" TEXT NOT NULL, '
          '"variants" TEXT NOT NULL, "is_custom" INTEGER NOT NULL DEFAULT 0 '
          'CHECK ("is_custom" IN (0, 1)), PRIMARY KEY ("id"))');
      raw.execute('CREATE TABLE "sessions" ("id" TEXT NOT NULL, '
          '"participant_label" TEXT NULL, "pool_ids" TEXT NOT NULL, '
          '"gender_filter" TEXT NOT NULL, "pool_size" INTEGER NOT NULL, '
          '"is_complete" INTEGER NOT NULL DEFAULT 0 CHECK ("is_complete" IN (0, 1)), '
          '"results_locked" INTEGER NOT NULL DEFAULT 1 CHECK ("results_locked" IN (0, 1)), '
          '"created_at" INTEGER NOT NULL, "completed_at" INTEGER NULL, '
          'PRIMARY KEY ("id"))');
      raw.execute('CREATE TABLE "elo_match_rows" ("id" INTEGER NOT NULL '
          'PRIMARY KEY AUTOINCREMENT, "session_id" TEXT NOT NULL REFERENCES '
          'sessions (id) ON DELETE CASCADE, "name_id_a" TEXT NOT NULL, '
          '"name_id_b" TEXT NOT NULL, "outcome" TEXT NOT NULL, '
          '"matched_at" INTEGER NOT NULL)');
      raw.execute('CREATE TABLE "shortlist_entries" ("id" TEXT NOT NULL, '
          '"name_id" TEXT NOT NULL REFERENCES name_entries (id), '
          '"note" TEXT NULL, "added_at" INTEGER NOT NULL, PRIMARY KEY ("id"))');
      raw.execute("INSERT INTO sessions (id, participant_label, pool_ids, "
          "gender_filter, pool_size, created_at) "
          "VALUES ('old', 'Partner A', '[]', 'all', 0, 0)");
      raw.execute('PRAGMA user_version = 1');
    }));
    addTearDown(db.close);

    final row = await db.sessionDao.getSession('old');
    expect(row, isNotNull);
    expect(row!.partnerSessionId, isNull);
    expect(row.deletedAt, isNull);
    final version =
        await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, db.schemaVersion);
    expect(db.schemaVersion, 3);
  });
}
