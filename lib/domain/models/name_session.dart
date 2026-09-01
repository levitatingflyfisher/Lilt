class NameSession {
  final String id;
  final String? participantLabel;
  final List<String> poolIds;
  final String genderFilter; // "m" | "f" | "all"
  final int poolSize;
  final bool isComplete;
  final bool resultsLocked;
  final DateTime createdAt;
  final DateTime? completedAt;

  /// The other session of a same-device couple; null for solo sessions.
  final String? partnerSessionId;

  const NameSession({
    required this.id,
    this.participantLabel,
    required this.poolIds,
    required this.genderFilter,
    required this.poolSize,
    required this.isComplete,
    required this.resultsLocked,
    required this.createdAt,
    this.completedAt,
    this.partnerSessionId,
  });

  NameSession copyWith({
    bool? isComplete,
    bool? resultsLocked,
    DateTime? completedAt,
  }) =>
      NameSession(
        id: id,
        participantLabel: participantLabel,
        poolIds: poolIds,
        genderFilter: genderFilter,
        poolSize: poolSize,
        isComplete: isComplete ?? this.isComplete,
        resultsLocked: resultsLocked ?? this.resultsLocked,
        createdAt: createdAt,
        completedAt: completedAt ?? this.completedAt,
        partnerSessionId: partnerSessionId,
      );
}
