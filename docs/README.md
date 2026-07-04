# Documentation

Organized on the [Diátaxis](https://diataxis.fr/) model — four kinds of docs for four
different needs. Find what you need by *what you're trying to do*, not by guessing a
filename.

| I want to… | I need | Go to |
|---|---|---|
| **learn by doing** | a Tutorial | [Tutorials](#tutorials) |
| **accomplish a specific task** | a How-to guide | [How-to guides](#how-to-guides) |
| **look up exact details** | Reference | [Reference](#reference) |
| **understand why** | Explanation | [Explanation](#explanation) |

New here? Start with the [README quickstart](../README.md), then
[Explanation § Concepts](concepts.md).

---

## Tutorials
*Learning-oriented — take me by the hand through my first success.*

- The **[README quickstart](../README.md)** — clone `eloEngine` + `Lilt` side by side,
  build, and run the app.

*Gap (contributions welcome):* a hand-held "rank your first 30 names and hand off to
your partner in 10 minutes" walkthrough. If you write one, put it in `docs/tutorials/`.

## How-to guides
*Task-oriented — how do I accomplish X (assumes you know the basics)?*

- **[Build & run](how-to/build-and-run.md)** — the sibling-checkout requirement, Drift
  codegen, and running on device / web.
- **[Ship a PWA and an APK](how-to/ship-pwa-and-apk.md)** — the two release targets and
  the tagged GitHub Actions build.
- **[Customize the name catalog](how-to/customize-the-name-catalog.md)** — regenerate
  `names.json` from the source lists, and how in-app custom names work.
- Working *in* this repo? See **[AGENTS.md](../AGENTS.md)**.

## Reference
*Information-oriented — tell me exactly, precisely, completely.*

- **[Data model](reference/data-model.md)** — the four Drift tables, the domain models,
  and the ID conventions.
- **[Configuration & settings](reference/configuration.md)** — convergence τ, pool
  presets, peeking prevention, and where each is stored.
- **[Feature status](reference/feature-status.md)** — screen-by-screen: shipped, thin,
  or absent.
- The ranking API (`EloEngine`, `MatchOutcome`, `compareAlgorithms`, …) is the
  **[`eloEngine`](../../eloEngine)** library's surface — see its own docs.

## Explanation
*Understanding-oriented — help me understand the ideas and the why.*

- **[Vision](../VISION.md)** — the one idea, the invariants, the honest scorecard.
- **[Architecture overview](architecture/OVERVIEW.md)** — the spine + diagrams.
- **[Architecture Decision Records](adr/)** — why each load-bearing choice was made.
- **[Concepts](concepts.md)** — names, sessions, matches, convergence, the couple flow,
  and why pairwise comparison beats a star rating.
- **[Privacy model](privacy-model.md)** — what leaves the device (almost nothing) and
  how you can check.
- **[Limitations](limitations.md)** — read before adopting. What it does *not* do.

---

### The white paper

- **[White paper](whitepaper.md)** — the conceptual case: why pairwise ranking, why
  local-first *here*, who it's for, and how it differs from the cloud name-app
  incumbents.

*There is no "yellow paper" (formal spec) in this repo by design: Lilt's formalizable
core — the ranking algorithms and their convergence/agreement math — lives in the
separate [`eloEngine`](../../eloEngine) library, which is where such a spec belongs.*
