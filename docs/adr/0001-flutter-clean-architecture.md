# ADR-0001: Flutter + Clean Architecture + Riverpod + Drift

- **Status:** Accepted
- **Date:** 2026-07-03 (documenting the stack chosen at project start)

## Context

Lilt needs to run on a phone, persist a few thousand names and a growing history of
comparisons offline, stay testable, and share conventions with the rest of the OpenHearth
family so a maintainer moving between apps isn't relearning everything. It is a
consumer app with real domain logic (sessions, replay-from-history, couple matching) that
must not be tangled into widgets.

## Decision

Build with **Flutter**, structured as **Clean Architecture** with three layers, and the
OpenHearth-standard state and storage libraries:

- **Presentation** (`lib/features/`, `lib/app/`) — screens and Riverpod notifiers only.
- **Domain** (`lib/domain/`) — repositories and plain models; owns the logic.
- **Data** (`lib/services/database/`) — Drift tables, DAOs, and the SQLite connection.
- **[Riverpod](https://riverpod.dev)** for state and dependency injection (all wiring in
  `lib/core/providers/`).
- **[Drift](https://drift.simonbinder.eu)** over raw `sqflite` for local storage —
  typed queries, generated code, and an in-memory backend that makes the data layer
  unit-testable.
- **go_router** for declarative, deep-linkable navigation (including the couple-results
  route guard).

The dependency rule points inward: presentation → domain → data, never the reverse, and
UI code never handles a Drift row type.

## Consequences

- **Buys:** a data layer that is fully unit-tested on in-memory SQLite; widgets that stay
  thin; conventions shared with sibling apps; one obvious place for each kind of change.
- **Costs:** more files and ceremony than a single-file prototype; a **code-generation
  step** (`build_runner`) that must be re-run after any schema/DAO change, and generated
  `*.g.dart` files in the tree.
- **Forecloses:** reaching into the database from a widget, or putting ranking/session
  logic in a screen. Both are layer violations.

## Alternatives considered

- **`sqflite` + hand-written SQL:** rejected — loses type safety and the in-memory test
  harness that makes the data layer trustworthy.
- **A flatter, no-repository structure:** rejected — the replay-from-history and couple
  logic are exactly the kind of domain logic that rots when it lives in widgets.
- **A different state library (Bloc, Provider):** rejected for consistency — Riverpod is
  the family standard, and its `*.family` providers fit the per-session screens cleanly.
