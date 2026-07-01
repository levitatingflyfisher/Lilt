# ADR-0004: Peeking prevention, locked by default

- **Status:** Accepted
- **Date:** 2026-07-03 (documenting a decision load-bearing since the couple flow shipped)

## Context

The couple mode's whole value is discovering **independent** agreement — names you both
gravitated to *before* either could sway the other. That value evaporates if the second
partner can see the first partner's ranking first. They'd anchor on it, consciously or
not, and "agreement" would just be ratification. The product only works if the second
ranking is honest, which means results must be hidden until both are done.

## Decision

Make results **locked by default** and enforce it at the route boundary:

- Every `NameSession` carries `resultsLocked`, which **defaults to `true`** at creation
  (`Sessions.resultsLocked` → `withDefault(const Constant(true))`).
- The couple-results route (`/results/couple?a=…&b=…`) has a `redirect` guard that reads
  both sessions and returns to `/` unless **both are `isComplete` AND `resultsLocked`**.
  There is no way to reach the Matches screen early by URL.
- Partner B is launched into the *same pool* A ranked, with A's results still unseen, so
  the comparison is apples-to-apples and B is not primed.

## Consequences

- **Buys:** the couple result means what it claims — independent overlap, not a nudged
  echo. The guarantee lives in a route guard and a column default, not in a UI convention
  a refactor could quietly drop.
- **Costs:** you cannot peek at a partial couple result mid-way, even if you want to. Solo
  sessions are unaffected — a solo ranker sees their own result immediately.
- **Forecloses:** a "sneak preview" of the partner's ranking, and any code path that
  renders couple results without passing the guard. Weakening the guard is a regression.

## Alternatives considered

- **Show results as soon as each partner finishes:** rejected — it destroys the
  independence the feature exists to measure.
- **A soft in-UI "are you sure?" instead of a route guard:** rejected — a soft prompt is
  bypassable and easy to lose in a refactor; the invariant belongs at the boundary.
