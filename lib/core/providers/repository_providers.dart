import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lilt/domain/repositories/names_repository.dart';
import 'package:lilt/domain/repositories/session_repository.dart';
import 'package:lilt/domain/repositories/shortlist_repository.dart';
import 'database_provider.dart';

final namesRepositoryProvider = Provider<NamesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return NamesRepository(db.namesDao);
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final names = ref.watch(namesRepositoryProvider);
  return SessionRepository(db.sessionDao, db.eloMatchesDao, names);
});

final shortlistRepositoryProvider = Provider<ShortlistRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final names = ref.watch(namesRepositoryProvider);
  return ShortlistRepository(db.shortlistDao, names);
});
