# Vision

> The north star for Lilt. If you (person or agent) are about to change something
> load-bearing, read this first — it says what must stay true and why. For *how it's
> built*, see [docs/architecture/OVERVIEW.md](docs/architecture/OVERVIEW.md); for
> *why each decision was made*, [docs/adr/](docs/adr/).

## The one idea

**Turn "argue over a list" into a game of *this or that*.**

Choosing a baby name is a joint decision made under bias. You anchor on the first
name you hear. You defer to whoever feels strongest. You peek at your partner's
shortlist and quietly drift toward it. A flat list of a thousand names makes all of
this worse.

Lilt replaces the list with a stream of tiny two-name choices — *Eliot or Mara?* —
and lets a ranking engine turn a few hundred gut reactions into one stable order. A
pairwise choice is easy and honest; a ranked list of 120 names is neither. So we
only ever ask the easy question, many times, and compute the hard answer.

The second move is what makes it work *for couples*: each partner ranks the same pool
**privately**, and the app reveals nothing until **both** are done. Then it shows you
the names you already agreed on — before either of you had a chance to sway the other.

## What this is

A **local-first baby-name ranking app** for couples (and solo parents). Configure a
pool of names, rank them by rapid pairwise comparison, and get a stable ranking — plus,
for two people, a "Matches" view of where your tastes overlap. Everything lives on the
device; nothing leaves it unless you tap *Share*.

```
  a pool of names            rapid pairwise ranking             a shared answer
 ───────────────────      ───────────────────────────      ─────────────────────
  bundled catalog           this-or-that, hundreds of        solo: your ranking
  + custom adds       ──▶   times, under an Elo engine  ──▶  couple: your overlap
  + hard vetoes             that detects convergence         (revealed only when
                                                             both partners finish)
```

The ranking math is **not** in this repo. It lives in a separate library,
[`eloEngine`](../eloEngine) — an ensemble of pairwise-ranking algorithms (Elo,
Glicko-2, TrueSkill, Bradley-Terry, and eleven more). Lilt is the *product* built on
top of it: the catalog, the sessions, the couple flow, the privacy posture, the warmth.

## The invariants (do not break these)

These are the load-bearing beliefs. Breaking one is a design regression, not a
feature. Each is enforced somewhere in the code and recorded as an ADR.

1. **Local-first, no account, no network.** Every name, session, and comparison is
   stored on-device (Drift/SQLite). There is no sign-up, no server, no sync. "Ghost
   mode" is not a tier — it is the whole app. ([ADR-0005](docs/adr/0005-local-first-no-account.md))
2. **Nothing leaves the device unless you ask.** The only egress is an explicit,
   user-initiated plain-text *Share*. No telemetry, no analytics, no ads. A list of
   names you're considering for your child is intimate; it stays yours.
3. **The match history is the source of truth.** Ratings are *derived, never stored* —
   every screen rebuilds the engine by replaying the same normalized comparisons. The
   answer is always reproducible from what you actually clicked.
   ([ADR-0002](docs/adr/0002-history-is-source-of-truth.md))
4. **Peeking prevention is a feature, not a nicety.** Sessions are locked by default;
   neither partner sees results until both finish. This protects the honesty of the
   second ranker, who would otherwise just ratify the first.
   ([ADR-0004](docs/adr/0004-peeking-prevention.md))
5. **Clean layering.** Presentation (`features/`) talks to domain (`repositories/`)
   talks to data (`daos/` + Drift). The UI never touches a Drift row or the ranking
   engine directly — exactly one file imports `elo_engine`.
   ([ADR-0001](docs/adr/0001-flutter-clean-architecture.md))
6. **Warm, not sterile.** Home-cooked software: Material 3, a warm-brown palette, a
   matchup loop that feels fast and tactile. The tone is a kitchen table, not a form.

## Honest scorecard — built vs. aspirational

A guiding light has to tell the truth about where the light reaches. This code and its
comments were written by an AI assistant; treat them as *what currently exists*, not as
gospel — verify a claim before you rely on it. If a comment and the tests disagree, the
tests win; if the tests and reality disagree, reality wins. As of v1.0.0:

**Real, tested, load-bearing:**
- The **solo loop** — pool config → matchup → results — is complete. Config covers
  gender filter, size presets (30/60/120) + custom (10–200), custom name adds, hard
  vetoes, and a quick swipe-veto pass. Matchup does pairwise choice with skip, undo,
  and a progress estimate. Results show a ranked list with rating bars and an optional
  "show methodology" ensemble view.
- The **data layer** — 4 Drift tables, 4 DAOs, 3 repositories — is fully unit-tested on
  in-memory SQLite, including the replay-from-history rebuild (`buildEngine`), record,
  and undo-ordering.
- **Peeking prevention**: locked-by-default sessions plus a couple-results route guard
  that refuses to render until both sessions are complete *and* locked.
- **Same-device two-player**: Partner A finishes → hands the phone to Partner B (same
  pool) → a "Matches" screen shows the top-20 overlap, ordered by agreement.
- Runs as an **Android APK and a PWA** (Drift conditional connection + WASM on web).
  Golden + overflow visual tests cover home, matchup, the ranked tile, and the
  convergence bar at text scale 1.0 and 3.0.

**Aspirational — still a hope, or thinly verified:**
- The **couple/results *screens* have no widget tests** — only the data layer beneath
  them is covered. Treat the couple-matching UI as built-but-thinly-verified.
- **PDF export does not exist.** The `pdf` package is a dependency but is never
  imported; every "share" is plain text. Wire it or drop the dep — don't document it as
  shipped.
- **No separate-phones couple mode.** "Two-player" means literally one device passed
  between partners. Two people on two phones cannot combine rankings today.
- The bundled catalog is **~1,636 English/US-centric names**. No localization, no
  diacritic-aware matching, no dedup-by-variant surfaced in the UI.
- The convergence target shown in the UI (`poolSize × 1.6`) is a **rough heuristic**,
  not a guarantee; real convergence is decided by the engine's stability window.

Keep that line bright: the solo engine loop and the data layer are real; anything that
crosses a *second device*, a *file format*, or an *untested screen* is still a hope.

## Horizons (problems, not a feature list)

Framed as problems on purpose — a dated feature list self-destructs.

- **Near** — Decide the `pdf` dependency (wire a real export, or remove it). Put widget
  tests under the solo- and couple-results screens. Make the couple "Matches" view
  explain *itself* ("you both ranked these in your top 20").
- **Mid** — The **separate-phones problem**: let two partners rank the same pool on
  their own devices and merge the result, still without a server. The local-first-honest
  shape is an encrypted-blob handoff (export A's pool + matches, import on B);
  `eloEngine` already ships the `snapshot`/`merge` API this would build on.
- **Far** — A **culturally broad catalog** — correct diacritics, variants deduped,
  still a static asset with no name-service call — and the genuinely hard one: helping
  a couple understand *why* they disagree (eloEngine's cycle/Hodge analysis already
  hints at it) without turning a warm decision into a dashboard.

## The name

**Lilt** — a light, swinging rhythm in music or in a speaking voice; the gentle rise
and fall of a name said aloud. That cadence *is* the app: a light back-and-forth —
*this? or that?* — repeated until the name that sounds like home rises to the top.
