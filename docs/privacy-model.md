# Privacy model

Lilt's privacy story is short because the architecture makes it short: **essentially
nothing leaves your device, and you can check that yourself.**

## What's collected

Nothing is collected *by anyone*. There is no account, no server, no analytics, no ads, and
no tracking SDK ([ADR-0005](adr/0005-local-first-no-account.md)). Lilt does not know who you
are and has nowhere to send data even if it wanted to.

## Where your data lives

All of it is on your device:

| Data | Where | Notes |
|---|---|---|
| Name catalog | SQLite (`lilt.sqlite`) | Loaded once from the bundled `assets/data/names.json`; not fetched |
| Your custom names | SQLite | Same table, `isCustom = true` |
| Sessions & pools | SQLite | Which names you ranked, filters, completion/lock state |
| Every comparison | SQLite (`EloMatchRows`) | The raw "A beat B" history — the source of truth |
| Shortlist & notes | SQLite | Saved names and your free-text notes |
| Convergence τ setting | `SharedPreferences` | A single number |

On native the database sits in the app's documents directory; on web/PWA it lives in
browser storage (the app requests **persistent** storage so a PWA isn't silently evicted).

## What leaves the device

Exactly one thing, and only when you tap it: a **plain-text Share**.

- **Solo results** → shares your top 10 names as text.
- **Shortlist** → shares your saved names (and their notes) as text.

That's the entire egress surface. The share goes wherever *you* send it (messages, notes,
email) via the OS share sheet — Lilt itself makes no network request. There is **no** PDF
export today (the `pdf` dependency is unused — see [limitations](limitations.md)).

## The threat model, briefly

- **Us / a server:** not in the picture — there is no server, so there's no server-side
  breach, profile, or resale to worry about.
- **Someone with your unlocked phone:** can open the app and see your sessions and
  shortlist, like any other local app. Lilt adds no separate lock. Peeking prevention
  ([ADR-0004](adr/0004-peeking-prevention.md)) guards a *partner* mid-flow, not a thief with
  your device.
- **Your partner (the intended "adversary"):** the couple flow deliberately hides each
  partner's ranking until both finish, so agreement is honest. This is a fairness
  guarantee, not a security one.
- **The network:** there is nothing to intercept, because nothing is transmitted.

## How to verify it yourself

You don't have to take the docs' word for it:

1. **Read the code.** Search the repo for HTTP clients or analytics: there are none. The
   dependency list in `pubspec.yaml` is short and inspectable (`share_plus` is the only
   thing that touches the outside world, and only via the OS share sheet).
2. **Watch the network.** Run the app in airplane mode — everything works. Or point a proxy
   at it and confirm it makes no requests.
3. **Inspect the database.** Pull `lilt.sqlite` off the device (or open it in a SQLite
   browser) — it's plain, unencrypted SQLite; what you see is all there is.
