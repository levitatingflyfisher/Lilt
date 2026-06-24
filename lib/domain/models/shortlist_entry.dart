import 'name.dart';

class ShortlistEntry {
  final String id;
  final Name name;
  final String? note;
  final DateTime addedAt;

  const ShortlistEntry({
    required this.id,
    required this.name,
    this.note,
    required this.addedAt,
  });
}
