# ADR-0002: Match history is the source of truth; ratings are replayed, never stored

- **Status:** Accepted
- **Date:** 2026-07-03 (documenting a decision load-bearing since the first session)

## Context

A ranking session produces two kinds of data: the **comparisons** the user actually made
("I picked Eliot over Mara"), and the **ratings** the engine derives from them. We could
persist either. Persisting ratings is tempting — it looks like a cache that saves work.
But ratings are a *function of* the comparisons and the algorithm; if the algorithm, its
config (e.g. convergence τ), or the ordering ever changes, stored ratings silently go
stale, and undo becomes a nightmare (you'd have to invert Elo updates).

## Decision

Persist **only the normalized comparison history**. The `EloMatchRows` table — one row
per head-to-head (`nameIdA`, `nameIdB`, `outcome`, `matchedAt`, autoincrement `id`) — is
the single source of truth. Ratings are **derived on demand**:
`SessionRepository.buildEngine(sessionId)` reads the pool and the match rows and
reconstructs a fresh `EloEngine` by replaying the whole history, every time.

- **Record** = insert one row, then rebuild.
- **Undo** = delete the most recent row (by autoincrement `id`), then rebuild.
- Ordering is by insertion `id`, **not** by `matchedAt` timestamp — several matches can
  land in the same wall-clock second, and only the `id` gives a stable total order (this
  was a real bug: undo/replay ordered by `matchedAt` mis-sequenced same-second matches).

## Consequences

- **Buys:** correctness and reproducibility — the ranking is always exactly what the
  clicks imply. Undo is trivial and exact. Changing the engine or τ needs no migration.
  The data on disk is human-auditable.
- **Costs:** every read rebuilds the engine. For the expected sizes (30–200 names, ~50–300
  matches) this is negligible; it would matter only at far larger scales.
- **Forecloses:** storing computed ratings as a first-class column, or any "resume from
  saved rating state" shortcut. If replay ever becomes a measured bottleneck, cache a
  *rebuild*, keyed by the match-row count — never a rating.

## Alternatives considered

- **Persist ratings, update incrementally:** rejected — couples staleness to the
  algorithm, makes undo error-prone, and needs a migration on every engine change.
- **Order history by `matchedAt`:** rejected after the same-second-collision bug;
  insertion `id` is the stable order.
