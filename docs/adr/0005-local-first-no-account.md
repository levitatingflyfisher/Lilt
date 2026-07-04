# ADR-0005: Local-first, no account, no network

- **Status:** Accepted
- **Date:** 2026-07-03 (documenting a founding commitment)

## Context

The names a couple is considering for their child are intimate — arguably more so than
most of what apps hoover up. The cloud incumbents in this space monetize exactly that:
accounts, ads, "trends," and data resale. Lilt is an OpenHearth app, and the family
premise is the opposite: software that serves a household without surveilling it. The app
also has no functional need for a server — the catalog ships in the bundle, and all
computation (ranking, convergence, couple overlap) runs on-device.

## Decision

Lilt is **local-first with no account and no network dependency**:

- All state — the name catalog, sessions, every comparison, the shortlist, settings —
  lives in an on-device SQLite database (`lilt.sqlite`) via Drift, plus a little
  `SharedPreferences` for the τ setting.
- There is **no sign-up, no login, no server, and no sync.** The app makes no network
  requests. There are no analytics, ads, or tracking SDKs.
- The bundled catalog (`assets/data/names.json`) is loaded into SQLite once on first
  launch; nothing is fetched.
- The **only** data egress is a user-initiated plain-text **Share** (top-10 or shortlist).
  See [ADR-0004](0004-peeking-prevention.md) for how results are gated even locally.

## Consequences

- **Buys:** full offline operation; nothing to breach because nothing is collected; a
  privacy story that is *architectural*, checkable, and short (see
  [privacy-model.md](../privacy-model.md)); trivially fast reads.
- **Costs:** no cross-device continuity — data lives on the one device, and "two-player"
  is one phone passed by hand. Backup/restore is on the user (and their OS). There is no
  central catalog to update names without an app release.
- **Forecloses:** any feature that assumes an account or a server. If sync is ever added,
  it must be opt-in and travel as **encrypted blobs through a dumb relay** — never
  plaintext, never a BaaS — to preserve this posture.

## Alternatives considered

- **Cloud accounts + sync (the incumbent model):** rejected — it inverts the product's
  reason to exist and creates a honeypot of intimate data.
- **A "lite" backend just for couple sync across phones:** deferred as a *problem*, not a
  decision (see [VISION.md](../VISION.md) horizons). The honest shape is an encrypted
  export/import handoff, not a server.
