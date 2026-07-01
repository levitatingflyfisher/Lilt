# Concepts

The ideas behind Lilt, in prose. For the data shapes, see
[reference/data-model.md](reference/data-model.md); for the code layout, see
[architecture/OVERVIEW.md](architecture/OVERVIEW.md).

## Why pairwise comparison (and not a star rating)

Ask someone to rate 120 names from 1 to 5 and you get mush: everything clusters at 3–4,
the scale means something different on Tuesday than it did on Monday, and nobody can hold
120 names in their head at once to keep the scores consistent. Ask them instead *"Eliot or
Mara?"* and the answer is instant, honest, and requires no calibration. Pairwise
preference is the smallest, most reliable unit of taste.

The catch is that pairwise answers don't *look* like a ranking — they look like a pile of
"A beat B" facts, some of them contradictory (you might prefer A>B, B>C, and C>A on
different days). Turning that pile into a single stable order is the job of a ranking
engine. Lilt asks only the easy question and lets the engine do the hard synthesis.

## Names and the catalog

A **Name** has an `id`, a `display` string, a `gender` (male / female / neutral), a list
of spelling `variants`, and an `isCustom` flag. The `id` encodes the name and gender —
`"eliot-m"`, `"mara-f"` — which is why it maps 1:1 onto the ranking engine's item id with
no translation layer.

The app ships a bundled catalog of ~1,636 names (`assets/data/names.json`, built by
`scripts/build_name_dataset.py` from a curated source list). On first launch it is loaded
into SQLite once. Users can **add their own names** during pool setup; a custom name enters
the ranking pool exactly like any bundled one.

## Sessions and pools

A **NameSession** is one person's ranking run. It records the **pool** (`poolIds` — the
specific names being ranked), the filters that produced it (`genderFilter`, `poolSize`),
and lifecycle flags (`isComplete`, `resultsLocked`, timestamps). A `participantLabel`
distinguishes couple runs: `"Partner A"`, `"Partner B"`, or `null` for solo.

Setting up a pool (the **pool config** screen) means: pick a gender filter, pick a size
(Quick 30 / Standard 60 / Comprehensive 120 / Custom 10–200), optionally add custom names,
optionally hard-veto names by name, then optionally run a **quick veto pass** — a
one-name-at-a-time *keep / remove* swipe over the candidate pool before ranking begins. The
pool is drawn by filtering the catalog, removing vetoes, shuffling, and taking the first
`poolSize` names.

## Matches and the matchup loop

A **match** is one recorded head-to-head: `nameIdA` vs `nameIdB` with an `outcome` of
`aWins`, `bWins`, `tie`, or `skip`. Matches are stored as normalized rows (`EloMatchRows`)
and are the **only** persisted signal — see
[ADR-0002](adr/0002-history-is-source-of-truth.md).

The matchup loop is: rebuild the engine from history → ask it for the most informative next
pair (`nextMatch`) → show the two names → the user taps one, calls it a tie, or skips →
record the match → repeat. Every record and undo rebuilds a fresh engine, so the state on
screen is always exactly what the history implies. A `skip` is stored but doesn't count
toward progress.

## Convergence (when are you "done"?)

You never have to rank all pairs — that's the point. The engine watches the **stability**
of the ranking over a sliding window of recent matches and reports `isConverged` once
recent updates stop changing the order much. How strict that threshold is is the
**convergence τ** setting (default 0.90, adjustable 0.80–0.99 in Settings): higher τ means
more comparisons but a more settled result.

Two numbers appear in the UI and shouldn't be confused:
- The **estimated target** shown during setup and matchup is `poolSize × 1.6` — a rough
  heuristic for "about how many comparisons this will take," used only for the progress
  bar and label. It is *not* the stopping condition.
- The **real** stopping condition is the engine's `isConverged`. The progress bar caps at
  95% until the engine actually converges, so it never claims completion the math hasn't
  reached. The user can also stop early once they've done enough to be meaningful.

## Rankings and "show methodology"

When a session ends, the **solo results** screen shows the pool in ranked order, each name
with a confidence bar scaled between the top and bottom ratings, the top ten emphasized.

An optional **"show methodology"** view exposes the engine's ensemble: it runs fifteen
ranking algorithms and reports their agreement (Kendall's τ across all of them), flags when
your preferences are less linear than usual (low rankability), when they seem to have two
distinct dimensions (matrix factorization), or when there are genuine **preference cycles**
(you like A>B>C>A) — and lists the names the algorithms disagree about most. It's an honest
"hold these loosely if the algorithms don't agree" signal, not a score to optimize.

## The couple flow and "Matches"

Two people rank the **same pool** on one device. Partner A finishes (session locked),
hands the phone over, and Partner B is launched into A's exact pool without seeing A's
result — see [ADR-0004](adr/0004-peeking-prevention.md).

Once both are complete and locked, the **Matches** screen shows each partner's top 20 side
by side and, in the middle, the names that appear in *both* top-20 lists. That overlap is
ordered by the **harmonic mean** of the two rank-scores (a name both ranked highly scores
high; a name one loved and the other merely tolerated is pulled down), with names both put
in their top 5 highlighted most strongly. This is a deliberate, screen-local computation —
it is *not* `eloEngine`'s `merge` API (an older note claimed otherwise).

## The shortlist

Independent of any session, the **shortlist** is a saved set of names under active
consideration, each with an optional free-text note. You add to it from results/detail
screens, edit notes, remove entries, and share the whole thing as plain text. Clearing
completed sessions never touches the shortlist.
