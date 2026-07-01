# Lilt

**Baby-name ranking for couples. Local-first, no account required.**

> Turn "argue over a list" into a game of *this or that*. Rank names by rapid pairwise
> choice, and — for two people — reveal where you already agree, but only once you've
> *both* finished. Everything stays on your device.

Choosing a name from a list of a thousand is miserable: you anchor, you defer, you
peek. Lilt only ever asks the easy question — *Eliot or Mara?* — a few hundred times,
and computes the hard answer (a stable ranking) from your choices. Two partners rank
the same pool privately; results stay hidden until both are done, then Lilt shows the
overlap.

## What it does

- **Set up a pool** — filter by gender, pick a size (30 / 60 / 120 / custom), add your
  own names, hard-veto ones you'd never use, and run a quick swipe-veto pass.
- **Rank by pairwise choice** — tap the name you prefer, skip a toss-up, undo a
  misfire; a live estimate tracks how close you are to a stable result.
- **See your ranking** — a full ordered list with confidence bars, plus an optional
  "show methodology" view that runs fifteen ranking algorithms and tells you how much
  they agree.
- **Rank together** — hand the phone to your partner, they rank the same pool, and a
  **Matches** screen surfaces the names you both put near the top.
- **Keep a shortlist** — save favourites with notes; share it as plain text when you're
  ready.

## Privacy in one line

Everything — names, sessions, every comparison — lives in an on-device SQLite database.
There is no account, no server, and no network call. What leaves your phone is a
plain-text list you explicitly tap **Share** on, or an **encrypted** `.ohbk` backup file
you explicitly export (Settings → Encrypted Backup) — Lilt itself never transmits
anything. See [docs/privacy-model.md](docs/privacy-model.md) and
[docs/how-to/encrypted-backup.md](docs/how-to/encrypted-backup.md).

## Quickstart (build & run)

Lilt is a Flutter app and depends on three sibling packages by path — clone all four
**side by side**:

```bash
git clone git@github.com:levitatingflyfisher/eloEngine.git
git clone https://github.com/levitatingflyfisher/sanctuaryAuthCore packages/sanctuary_auth_core
git clone https://github.com/levitatingflyfisher/sanctuaryBackupUi packages/sanctuary_backup_ui
git clone git@github.com:levitatingflyfisher/Lilt.git
cd Lilt

flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift codegen
flutter run                                                # device / emulator / chrome
```

`packages/sanctuary_auth_core` and `packages/sanctuary_backup_ui` (the encrypted-backup
primitives and UI, shared with the rest of the OpenHearth fleet — see
[docs/how-to/encrypted-backup.md](docs/how-to/encrypted-backup.md)) must sit next to
`Lilt/` and `eloEngine/`, matching this layout:

```
eloEngine/
packages/
  sanctuary_auth_core/
  sanctuary_backup_ui/
Lilt/                        # this repo
```

Full instructions, including the web (PWA) and APK builds, are in
[docs/how-to/build-and-run.md](docs/how-to/build-and-run.md).

## See the docs

- **[VISION.md](VISION.md)** — the one idea, the invariants, and an honest scorecard of
  what's real vs. aspirational.
- **[docs/README.md](docs/README.md)** — the documentation hub
  ([Diátaxis](https://diataxis.fr/): tutorials · how-to · reference · explanation).
- **[AGENTS.md](AGENTS.md)** — guidance for anyone (human or agent) editing this repo.

## Tech

Flutter · Clean Architecture (domain / data / presentation) · Riverpod · Drift/SQLite ·
go_router. Ranking is delegated to the [`eloEngine`](../eloEngine) library. Ships as an
Android APK and a PWA.

## License

MIT — see [LICENSE](LICENSE). The bundled Lora and Nunito font families are
licensed separately under the [SIL Open Font License 1.1](assets/fonts/OFL.txt).
