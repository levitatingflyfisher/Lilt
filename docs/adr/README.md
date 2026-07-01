# Architecture Decision Records

An ADR captures **one architectural decision**: the context that forced it, the choice
made, and the consequences we accepted. They are immutable once accepted — if a decision
is revisited, add a *new* ADR that supersedes the old one (mark the old one `Superseded
by ADR-NNNN`) rather than editing history.

Read these when you're about to change something load-bearing and want to know whether
you're fixing a mistake or unknowingly reopening a settled trade-off.

## Index

| # | Decision | Status |
|---|---|---|
| [0001](0001-flutter-clean-architecture.md) | Flutter + Clean Architecture + Riverpod + Drift | Accepted |
| [0002](0002-history-is-source-of-truth.md) | Match history is the source of truth; ratings are replayed, never stored | Accepted |
| [0003](0003-ranking-in-separate-library.md) | Ranking lives in a separate `eloEngine` library | Accepted |
| [0004](0004-peeking-prevention.md) | Peeking prevention, locked by default | Accepted |
| [0005](0005-local-first-no-account.md) | Local-first, no account, no network | Accepted |
| [0006](0006-dual-pwa-apk-target.md) | Ship as both a PWA and an APK | Accepted |

## Writing a new one

Copy [`0000-template.md`](0000-template.md) to the next number, fill it in, add a row
above. Keep it to ~one screen — an ADR that needs scrolling is two ADRs.
