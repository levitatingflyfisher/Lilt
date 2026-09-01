/// The ranking, as the app's screens see it. These are domain models built
/// by `SessionRepository` from the replayed engine; nothing outside the
/// repository touches `elo_engine` (VISION invariant 5).
library;

/// What the person chose in one comparison. The names are the strings the
/// match history stores.
enum ComparisonOutcome { aWins, bWins, tie, skip }

/// The next two names to compare.
class NamePair {
  final String firstId;
  final String secondId;
  const NamePair(this.firstId, this.secondId);
}

/// One name's place in a session's ranking.
class RankedName {
  final String id;

  /// The engine's rating. Only its order is shown.
  final double rating;

  /// The chance this name beats a name of average rating in the same pool,
  /// 0 to 1 (the Elo expectation against the pool's mean rating). It has a
  /// true zero and a fixed scale, so a bar drawn from it is proportional:
  /// an average name draws half a bar, and a pool of ties draws every bar
  /// at half, not full.
  final double winChance;

  const RankedName(
      {required this.id, required this.rating, required this.winChance});
}

/// A session's ranking, best first, plus what the loop needs next.
class SessionRanking {
  final List<RankedName> ranked;

  /// The next pair to show, or null when every useful pair is exhausted.
  final NamePair? next;

  /// The engine judged the order stable.
  final bool isConverged;

  const SessionRanking(
      {required this.ranked, required this.next, required this.isConverged});

  /// 1-based rank of [nameId], or null if it is not in this session.
  int? rankOf(String nameId) {
    final i = ranked.indexWhere((r) => r.id == nameId);
    return i < 0 ? null : i + 1;
  }
}

/// A name the ranking methods placed far apart.
class RankDisagreement {
  final String nameId;

  /// 0-based rank by method display name ("Elo", "Borda", ...).
  final Map<String, int> rankByMethod;
  final int rankSpread;

  /// A rating-based method put it near one end and a pairwise method near
  /// the other: a sign the name sits in a preference cycle.
  final bool invertedAcrossFamilies;

  const RankDisagreement({
    required this.nameId,
    required this.rankByMethod,
    required this.rankSpread,
    required this.invertedAcrossFamilies,
  });
}

/// The "Show methodology" detail: how far the ensemble agrees.
class Methodology {
  /// Mean pairwise Kendall tau between the methods' rankings, -1 to 1.
  final double kendallTau;
  final double? rankability;
  final int? preferenceDimensions;
  final double? cycleStrength;

  /// Most disagreed-about names first.
  final List<RankDisagreement> disagreements;

  const Methodology({
    required this.kendallTau,
    required this.rankability,
    required this.preferenceDimensions,
    required this.cycleStrength,
    required this.disagreements,
  });
}
