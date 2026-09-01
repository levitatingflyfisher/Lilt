# Personas

Agents drive the real Lilt build as these people, per the fleet testing rule.
Each scenario gives a start state, plain steps, what success looks like, and
what to check. "Standard checks" means: text scale 1.3 at 360 dp width, dark
mode, airplane mode, and every error in plain words with a way out. Scenarios
aim at the weak spots found by the September 2026 lens audit.

## Primary: Sam and Noor, expecting their first child

Sam (33) and Noor (31) are expecting in spring and keep circling the same
arguments over names. They share one phone for Lilt on evenings at home, and
each must not see the other's ranking until both are done. The agent plays
both partners in turn.

- **Goal:** rank the same pool privately, then see the names they already
  agree on.
- **Context:** passing one phone across the sofa; tired after work; Noor uses
  text scale 1.3.
- **Would quit if:** either partner can peek, or the reveal is a bare list
  with nothing to do next.

**S1. Peeking guard.** Start: fresh install. Steps: start a same-device
two-player session as Partner A with a 30-name pool; finish ranking; hand off;
as Partner B, press system back repeatedly, and go Home and tap A's completed
tile. Success: B cannot reach A's ranking before finishing. Check: Settings
"Peeking Prevention" either is a real switch or states plainly that it is
always on.

**S2. The reveal.** Start: both partners finished. Steps: open Matches; tap a
matched name. Success: a headline names the top match; each match shows both
ranks; tapping a name opens its detail or offers "save to shortlist". Check:
standard checks; the both-top-5 colour has a key; the empty case reads kindly.

**S3. Partner B resumes later.** Start: A done, B mid-session, app closed.
Steps: reopen, resume B's session from Home. Success: B continues as B and is
not offered "Pass Phone to Partner" again. Check: session tiles carry a date.

## Secondary: Lucía, a single parent ranking alone

Lucía is 38, adopting a toddler as a single parent, and ranks names solo on
their commute, one-handed on a crowded train.

- **Goal:** get a trustworthy top ten and save favourites with notes.
- **Context:** one-handed, interrupted often, spotty signal.
- **Would quit if:** a mis-tap cannot be undone, or setup work is lost.

**L1. The Matchup loop.** Start: solo session, 60 names. Steps: compare ten
pairs; tap "Tie" once and "Don't care" once; undo twice. Success: the screen
asks its question in words; the two middle buttons mean different things or
only one exists; Undo is reachable by thumb. Check: counter starts at 1, not
"Match 0"; progress bar keeps moving past 95%.

**L2. The veto pass and back.** Start: Pool Config with gender, size, two
added names and two hard vetoes. Steps: tap Start Ranking; remove three names
in the Quick Veto Pass; press back. Success: the pass was announced; removals
can be undone; back returns to Pool Config with everything intact. Check:
"Remove" does not wrap at 1.3; a misspelled veto is flagged.

**L3. Shortlist.** Start: a completed solo ranking. Steps: find a way to add
the top name to the Shortlist with a note, then share it. Success: a visible
path exists; the Shortlist empty state names a button that really exists.
Check: offline share still works.

**L4. A stale link.** Start: any state. Steps: open a saved link to a name
that no longer exists, `/name/does-not-exist-xyz`. Success: a plain sentence
and a button back to sessions; no "Bad state" exception text. Check: dark
mode; the Settings Ranking Confidence slider explains itself without
statistics words.
