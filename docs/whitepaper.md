# Lilt — white paper

*The conceptual case: why pairwise ranking, why local-first here, who it's for, and how it
differs from the cloud name-app incumbents. For the invariants, see
[VISION.md](../VISION.md); for what's actually shipped, see
[reference/feature-status.md](reference/feature-status.md).*

## The problem: two people, one name, a thousand candidates

Naming a child is one of the first significant decisions a couple makes together, and the
tooling for it is bad in a specific way. Every "baby names" app hands you a **list** — a
thousand names to scroll, filter, and star. Lists fail the task on two fronts:

1. **They don't elicit honest preference.** Star ratings on a long list collapse: almost
   everything is a 3 or a 4, the scale drifts as you go, and no one can hold a thousand
   items in mind well enough to keep the scores consistent. You end up with a lightly
   sorted pile, not a ranking you trust.
2. **They don't help two people converge.** The hard part isn't finding names you like —
   it's finding names you *both* like, without one partner anchoring the other. On a shared
   list, whoever stars first sets the frame; the second person edits the margins.

## The idea: ask the easy question, compute the hard answer

Lilt never asks you to rate a list. It asks the smallest possible question — *this name or
that one?* — a few hundred times. A pairwise choice is instant and needs no calibration; it
is the most reliable unit of taste there is.

Those choices arrive as a pile of "A beat B" facts, some of them mutually contradictory
(real preferences contain cycles — you can prefer A over B, B over C, and C over A). Turning
that pile into a single stable order is a solved mathematical problem, and Lilt delegates it
to a dedicated engine — the [`eloEngine`](../../eloEngine) library, an ensemble of pairwise
ranking algorithms (Elo, Glicko-2, TrueSkill, Bradley-Terry, and more) that also detects
when the ranking has *converged*, so you stop clicking when the answer is settled rather than
when you've exhausted the list.

The result is a ranking you didn't have to construct — you only ever made easy choices — and
one you can *audit*: it is a pure function of the comparisons you actually made
([ADR-0002](adr/0002-history-is-source-of-truth.md)).

## The couple move: independent, then revealed

The feature that makes Lilt a *couples* tool is structural, not cosmetic. Each partner ranks
the **same pool** independently, and the app reveals nothing until **both** are finished
([ADR-0004](adr/0004-peeking-prevention.md)). Only then does it show where the two rankings
overlap — the names you each, without influence, put near the top.

This is the difference between *agreement* and *ratification*. If the second partner can see
the first's list, "agreement" is just politeness. By hiding results until both are done, Lilt
measures the taste you share **before** either of you had a chance to nudge the other. The
"Matches" screen is that shared ground made visible.

## Why local-first, here specifically

The house style is local-first everywhere, but this app is a sharp case for it. The data in
question — the names a couple is weighing for their child, months before an announcement — is
about as intimate as consumer data gets. The cloud incumbents monetize exactly this: accounts,
ad networks, "trending names" derived from aggregated user lists, and data resale. The
business model is the surveillance.

Lilt's model is the inverse, and it costs the product nothing, because the app has **no
functional need for a server**:

- The name catalog ships in the app bundle. Nothing is fetched.
- All computation — ranking, convergence, couple overlap — runs on-device.
- So there is no account, no server, no sync, no analytics, and no ads
  ([ADR-0005](adr/0005-local-first-no-account.md)). The only thing that ever leaves the phone
  is a plain-text list you explicitly choose to share.

The privacy story is therefore **architectural and checkable**, not a promise in a policy:
run it in airplane mode and it works; inspect the dependency list and there's nothing that
phones home; open the local SQLite file and that's all there is
([privacy-model.md](privacy-model.md)). A tool for an intimate family decision should not be
a data-collection funnel, and this one structurally can't be.

## Who it's for

Expecting or planning couples who want to narrow a shared name decision without arguing over a
spreadsheet — and who'd rather their candidate list not become someone's ad-targeting signal.
It works for a solo parent too (rank alone, get your own ordering), but the couple flow is the
reason it exists. It assumes the two people share, at some point, one phone — which is the
honest shape of a no-server product, and also just how a couple actually sits down to do this.

## How it's different, in one table

| | Typical cloud name app | Lilt |
|---|---|---|
| Input method | Scroll + star a long list | Pairwise "this or that" |
| Ranking | Implicit, from stars | Computed, convergence-aware, auditable |
| Couple mode | Shared list (anchoring) | Independent, revealed only when both finish |
| Account | Usually required | None, ever |
| Data | On a server; often monetized | On your device; nothing collected |
| Egress | Continuous | One plain-text share, on your tap |
| Offline | Partial | Complete |

## Honest limits (built vs. aspirational)

This paper argues the *why*; it should not oversell the *what*. As of v1.0.0:

- **Real:** the solo loop (config → matchup → results), the replay-from-history data layer
  (fully unit-tested), peeking prevention, same-device couple mode with the "Matches" overlap,
  and both APK and PWA builds.
- **Thin or absent:** the couple/results *screens* lack widget tests; there is **no PDF
  export** (the dependency is unused); there is **no separate-phones sync** — couple mode is
  one device passed by hand; the catalog is ~1,636 English/US names with no localization; and
  the couple result is a top-20 *overlap*, not a fused whole-pool ranking.

The thesis — easy questions, honest answers, private by construction — is real and shipping.
The frontier is making the couple experience richer (separate devices, better explanations)
without ever reintroducing the server that would undo the whole point. See
[VISION § Horizons](../VISION.md#horizons-problems-not-a-feature-list).
