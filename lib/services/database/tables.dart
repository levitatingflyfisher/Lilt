import 'package:drift/drift.dart';

/// Bundled name catalog + user-added custom names.
/// Populated from assets/data/names.json on first launch.
@DataClassName('NameEntryRow')
class NameEntries extends Table {
  TextColumn get id => text()(); // e.g. "eliot-m"
  TextColumn get display => text()(); // e.g. "Eliot"
  TextColumn get gender => text()(); // "m" | "f" | "n"
  TextColumn get variants => text()(); // JSON array, e.g. '["Elliott","Elliot"]'
  BoolColumn get isCustom =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// One ranking session per participant.
/// Two rows for same-device two-player; one row for solo.
@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get participantLabel => text().nullable()(); // "Partner A" | "Partner B" | null
  TextColumn get poolIds => text()(); // JSON-encoded List<String> of name IDs
  TextColumn get genderFilter => text()(); // "m" | "f" | "all"
  IntColumn get poolSize => integer()(); // 30 | 60 | 120 | custom
  BoolColumn get isComplete =>
      boolean().withDefault(const Constant(false))();
  /// When true, results screen requires partner to also be complete before showing.
  /// Default true = peeking prevention on.
  BoolColumn get resultsLocked =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row per recorded head-to-head comparison.
/// Normalized storage — EloEngine is rebuilt from this history.
@DataClassName('EloMatchRow')
class EloMatchRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId =>
      text().references(Sessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get nameIdA => text()();
  TextColumn get nameIdB => text()();
  TextColumn get outcome => text()(); // "aWins" | "bWins" | "tie" | "skip"
  DateTimeColumn get matchedAt => dateTime()();
}

/// User's saved shortlist of names under active consideration.
@DataClassName('ShortlistEntryRow')
class ShortlistEntries extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get nameId => text().references(NameEntries, #id)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
