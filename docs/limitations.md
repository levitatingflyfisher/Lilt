# Limitations

Read this before adopting or building on Lilt. It is the honest companion to the
[VISION scorecard](../VISION.md#honest-scorecard--built-vs-aspirational): what Lilt does
*not* do, as of v1.0.0.

## No cross-device sync — "two-player" is one phone

There is no server and no sync ([ADR-0005](adr/0005-local-first-no-account.md)). Couple
mode works by **handing one physical device** between partners, who rank the same pool in
turn. Two people on two separate phones cannot combine their rankings today. All data lives
on the one device it was created on; backup and restore are whatever your OS provides.

## PDF export doesn't exist

The `pdf` package is listed in `pubspec.yaml` but is **never imported** anywhere in `lib/`.
Every "share" — top-10 from solo results, the shortlist — is a **plain-text** `Share.share`.
Don't document, promise, or rely on PDF export; it isn't wired. (The right fix is to either
implement it or drop the dependency.)

## The results screens are thinly tested

The data layer is well covered — 4 DAOs and 3 repositories are unit-tested on in-memory
SQLite, including replay/record/undo. But the **solo- and couple-results screens have no
widget tests**; only golden/overflow tests exist for the home screen, matchup screen, the
ranked-name tile, and the convergence bar. Treat the results UI (especially the couple
"Matches" computation) as built-but-thinly-verified, and add tests before refactoring it.

## The catalog is English/US-centric and modest

~1,636 names, curated from an English/US-leaning source. There is no localization, no
diacritic-aware matching, and variant spellings are stored but not surfaced for
deduplication in the ranking UI. A name you type as a custom add is keyed by a lowercase id
(`"{name}-{gender-code}"`), so casing and diacritics can produce near-duplicate ids.

## Convergence is a heuristic, and the estimate is rough

The "~N comparisons to convergence" figure is `poolSize × 1.6` — a guess for the progress
bar, not a promise. Real stopping is the engine's stability window (`isConverged`), tuned by
the τ setting. A large pool with genuinely cyclic preferences may keep proposing matches
longer than the estimate suggests; the app lets you stop early once results are meaningful.

## Couple matching is overlap, not a fused ranking

The Matches screen computes the **intersection of each partner's top 20**, ordered by the
harmonic mean of rank-scores. It does *not* produce a single merged ranking of the whole
pool, and it ignores agreement outside the top 20. Names you both dislike, or both feel
lukewarm about, simply don't appear. (eloEngine has a `merge`/`snapshot` API that a future
"full fused ranking" could use; it isn't used here.)

## Storage assumptions

Web/PWA data lives in browser storage; the app requests persistence, but an aggressive
browser or a "clear site data" still wipes it. On native, data lives in the app documents
directory and is removed with the app. There is no in-app export/backup of the full
database — only the plain-text shares above.

## Not a naming *authority*

Lilt ranks *your* preferences among names you chose to consider. It offers no popularity
data, meanings, origins, sibling-name suggestions, or trend charts. It is a decision aid for
two people, not a name encyclopedia.
