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
- Each partner's **own** results route (`/results/solo/:id`) is guarded too: a locked
  session that belongs to a couple (`partnerSessionId` set at hand-off) redirects to `/`
  until **both** sessions are complete. Home shows such a session as *locked until the
  partner finishes* rather than as a link. (Added 2026-09: before this, Home routed
  Partner A's completed tile straight to A's full ranking while B was still ranking.)
- **Way out:** a partner who never finishes would lock the other's results forever, so
  the locked Home tile offers **End pairing** (confirmed by a dialog). It clears only that
  session's side of the link (`SessionRepository.endPairing`), which unlocks its own
  results; the partner's session, comparisons and link back are kept, so they can still
  finish and open the reveal. Ending is an explicit, informed choice to give up
  independence, not a bypass.
  **Clear all sessions** (Settings) is the blunter way out: since 2026-09 it clears
  sessions in progress as well as finished ones, softly, with Undo and a Recently
  cleared list. A cleared partner reads as deleted, which the `/results/solo` guard
  treats as "nobody left to peek", so a couple is only ever cleared or restored
  together: restoring either half from Recently cleared restores both
  (`SessionDao.restore`; pinned in `peeking_lock_test.dart`). Otherwise Partner B could
  clear all, restore Partner A alone, and read A's list mid-ranking.
- The hand-off (`handOffToPartner` in `router.dart`) pops everything above Home before
  opening Partner B's setup, because a redirect runs when a route is pushed, never when
  it is popped back to: nothing of A's may sit in the back stack beneath B.
- Partner B is launched into the *same pool* A ranked, with A's results still unseen, so
  the comparison is apples-to-apples and B is not primed.

## Consequences

- **Buys:** the couple result means what it claims — independent overlap, not a nudged
  echo. The guarantee lives in route guards, a persisted pairing and a column default, not
  in a UI convention a refactor could quietly drop. `test/widget/navigation/
  peeking_lock_test.dart` fails if either results route or the hand-off leaks.
- **Costs:** you cannot peek at a partial couple result mid-way, even if you want to. Solo
  sessions are unaffected — a solo ranker sees their own result immediately.
- **Forecloses:** a "sneak preview" of the partner's ranking, and any code path that
  renders couple results without passing the guard. Weakening the guard is a regression.

## Alternatives considered

- **Show results as soon as each partner finishes:** rejected — it destroys the
  independence the feature exists to measure.
- **A soft in-UI "are you sure?" instead of a route guard:** rejected — a soft prompt is
  bypassable and easy to lose in a refactor; the invariant belongs at the boundary.
