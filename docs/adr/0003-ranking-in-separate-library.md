# ADR-0003: Ranking lives in a separate `eloEngine` library

- **Status:** Accepted
- **Date:** 2026-07-03 (documenting the split chosen at project start)

## Context

The interesting math here — turning a set of pairwise outcomes into a stable, defensible
ranking — is substantial and general. It is an ensemble of algorithms (Elo, Glicko-2,
TrueSkill, Bradley-Terry, Thurstone, Copeland, Schulze, Ranked Pairs, Borda, PageRank,
Markov, SpringRank, SerialRank, Hodge, matrix factorization), plus convergence detection,
inter-algorithm agreement (Kendall's τ), and merge/snapshot support. None of that is
specific to baby names. Baking it into Lilt would trap reusable, independently-testable
logic inside a consumer app and make the app's own domain harder to see.

## Decision

Keep the ranking engine in its own package, **[`eloEngine`](../../eloEngine)**, and depend
on it by path (`elo_engine: { path: ../eloEngine }`). Lilt owns the *product*: the
catalog, sessions, couple flow, privacy posture, and UI. `eloEngine` owns the *math*: it
knows nothing about names.

Consume it through a **single seam**:
`lib/domain/repositories/session_repository.dart` is the only file that imports
`elo_engine`. It maps Lilt's `Name.id` 1:1 onto `EloItem.id` (no translation layer) and
`EloMatchRow` onto `EloMatch`, then hands the rest of the app a plain `EloEngine` object.

## Consequences

- **Buys:** the ranking math is reusable and tested on its own (it has its own
  `AGENTS.md`, tests, and benchmarks); Lilt's domain stays about names, not gradient
  updates; a formal spec, if one is ever written, has an obvious home (in `eloEngine`, not
  here — which is why this repo has no yellow paper).
- **Costs:** a **sibling checkout** is required — `flutter pub get` fails unless
  `eloEngine` sits next to `Lilt`. CI checks out both. Cross-repo changes need two commits.
- **Forecloses:** inlining ranking logic into a screen or repository. New ranking behavior
  belongs in `eloEngine`; Lilt only calls it.

## Alternatives considered

- **Inline the ranking code in `lib/`:** rejected — it's general, sizeable, and better
  tested in isolation; embedding it hides both the library and the app.
- **Publish `eloEngine` to pub.dev and pin a version:** reasonable eventually; for now a
  path dependency keeps the two repos evolving together without a release dance.
