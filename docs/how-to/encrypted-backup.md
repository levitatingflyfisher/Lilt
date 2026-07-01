# How-to: encrypted backup & restore

Task-oriented. Assumes you've already run Lilt at least once (Settings → Encrypted
Backup requires the app database to exist).

## What this is, and isn't

Lilt's data — custom names, ranking sessions, every comparison, your shortlist — lives
only on this device (see [privacy-model.md](../privacy-model.md)). There is no server,
so there is no "log back in on a new phone." Encrypted backup is the local-first
answer: you export a single encrypted file, store it wherever you already trust (a
password manager, an encrypted drive, cloud storage you control), and restore it on any
device running Lilt.

It is built on `sanctuary_auth_core` / `sanctuary_backup_ui`, the same Ghost-tier
primitives shared across the OpenHearth apps — see those packages' own docs for the
cryptographic detail (BIP39 mnemonic → HKDF-SHA256 → ChaCha20-Poly1305). Lilt uses its
own isolated key material (`appDomain: 'lilt'`) and its own AEAD context
(`lilt-backup/v1`): a Lilt backup can only ever be opened by Lilt, and — because the key
is domain-separated — even a shared recovery phrase used by another OpenHearth app on
the same device does not cross-decrypt Lilt's blob.

## The honest version of "recovery phrase"

**The 12 words *are* your data's only key.** Lilt does not hold a copy, cannot reset it
for you, and cannot recover a backup if the words are lost — there is no "forgot
password" flow, because there is no server to ask. Write the words down somewhere
durable *before* you rely on a backup for anything. Setup asks you to re-enter them, on
purpose: that turns "I clicked confirm" into a proof you can actually reproduce the
words later.

## Set up

1. Settings → **Encrypted Backup** → **Set up encrypted backup**.
2. Write down the 12 words shown, then re-enter them when prompted. A mismatch is
   caught here, not months later when you actually need the backup.

## Export

Settings → Encrypted Backup → **Export backup**. This produces
`lilt-backup-<yyyy-MM-dd>.ohbk` and hands it to the OS share sheet — send it wherever
you keep things you trust. The file is opaque ChaCha20-Poly1305 ciphertext; without the
12 words it reveals nothing.

## Restore

Settings → Encrypted Backup → **Restore from backup**, then pick an `.ohbk` file.

**This is destructive.** Restoring replaces every custom name, ranking session,
comparison, and shortlist entry currently on this device with the contents of the
backup file — in one all-or-nothing transaction, so a bad restore never leaves the app
half-updated. The confirmation dialog states this plainly before anything happens. The
bundled name catalog (the ~1,636 names shipped with the app) is **not** touched by
export or restore — it's reseeded from the app itself, not from your backup.

If this device already has a key set up, Lilt tries it first; if the backup was made
with different words, you're prompted to enter the words it was created with. A wrong
phrase yields a calm, specific message — never a partial restore.

## What a wrong file/phrase looks like

| What you did | What happens |
|---|---|
| Picked a file that isn't a Lilt `.ohbk` (or is truncated/corrupted) | "This file looks damaged or isn't a Lilt backup." |
| Entered words that don't unlock this file | "Those words didn't unlock this backup. Try the words from when it was made." |
| Restored a backup made by a newer version of Lilt | "This backup was made by a newer version of Lilt. Update the app, then restore." |

## Reset identity

Settings → Encrypted Backup → **Reset identity** wipes the recovery words from *this
device only* — your existing app data is untouched. You'll need a new phrase (and a new
backup) going forward; any backup made under the old words is only recoverable with
those old words.
