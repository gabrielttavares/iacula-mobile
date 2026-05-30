# Quote slot assignment cache — advance the shuffle bag per delivery, not per schedule

**Date:** 2026-05-30
**Branch:** `feat/quote-daily-repeat-rotation`
**Status:** Design — decided, proceeding to implementation
**Language:** spec/plan/code English; user-facing strings pt-BR.

## Problem

The two-layer scheduler calls `GetNextQuoteUseCase` once per slot on every scheduling
pass. That fetcher advances and persists the per-weekday shuffle-bag cursor. Because a
pass schedules many slots (today layer ~13 for Frequente; grid floor 5×6 = 30), and a
pass re-runs on every app open / settings save, the bag is **drained per scheduled
slot, multiplied by the number of reopens** — not per quote the user actually receives.

Consequence: an engaged user who reopens the app several times in a day burns through a
weekday bucket far faster than the quotes they actually saw. The requirement — *the user
receives every quote in a weekday bucket once before any repeat, resuming across weeks,
then reshuffles* — is violated because "consumed" is measured at schedule time, not
delivery time.

The shuffle-bag selector (`QuoteSelector.selectFromShuffleBag`) and its persistence
(`QuoteIndicesRepository`) are correct and unchanged. The bug is purely that the
**scheduler treats a cursor-mutating fetcher as if it were a pure read, and calls it
redundantly.**

## Goal

Advance the shuffle bag approximately **once per delivered quote**, reconstructed at
app-open time (iOS gives no reliable background fire callback). Specifically:

- A fixed slot (identified by its next concrete fire `DateTime`) is assigned a quote
  **once**. While that fire time is still in the future, re-running the scheduling pass
  **reuses** the assignment — no new bag draw.
- Once a slot's fire time has **passed** (it has effectively delivered), the next pass
  that re-creates that slot **draws a fresh quote** (bag advances exactly once) and
  re-assigns it.
- One uniform rule for both layers (today one-shots and weekly grid cells); the only
  per-layer difference is how the slot's next-fire `DateTime` is computed, which the
  engine already does.

Preserves: non-repeat within a bucket, resume-across-weeks, reshuffle-on-exhaustion
(all already in the selector). Accepts: a slot whose app stays closed for many weeks
repeats its baked quote until reopen — an unavoidable iOS `dayOfWeekAndTime` limit,
identical regardless of this change.

## Design

### Assignment cache = the notification history table (reused)

The history table already stores `quoteText, theme, season, deliveredAt, imagePath,
feastName, source, referenceLabel` and exposes `add`, `clearFrom`, `clearFromExcept`,
`listForDay`, `listFromUntilEndOfDay`. We use **`deliveredAt` = the slot's next fire
`DateTime`** as the assignment key. A history row therefore means: "the slot firing at
this instant is assigned this quote." This doubles as the Notificações-tab record
(rows whose time has passed are real past deliveries; future rows are predictions for
upcoming slots — acceptable and useful for the tab).

No new table, repository, or schema. (Supersedes the prior spec's "record actual
deliveries only / write no future rows" decision: we now deliberately persist future
slot assignments again, but keyed stably and reused rather than churned.)

### Scheduling pass algorithm (both layers)

For each layer, after computing the slot fire `DateTime`s:

1. Load existing assignments via `listFromUntilEndOfDay(now)` for the today layer, and
   for the grid: load the rows in the grid's future window. Build a map
   `byFireTime[fireDateTime.toIso8601String()] -> historyEntry`.
2. For each slot fire time `fireAt`:
   - **If `byFireTime` has an entry for `fireAt`** (slot already assigned, still future):
     reuse it — register the OS notification with the cached `quoteText`/metadata,
     **do not call the fetcher** (no bag draw).
   - **Else** (new/elapsed slot): call `_quoteFetcher(now: fireAt)` once (bag advances),
     register the notification, and `add` a history row keyed at `fireAt`.
3. After scheduling, prune assignment rows that no longer correspond to any current slot
   (e.g. cadence changed) using `clearFromExcept(now, keepFireTimes)`, but **never delete
   rows whose `deliveredAt < now`** (those are real past deliveries shown in the tab).

The "reuse if future, redraw if elapsed" behaviour falls out naturally: an elapsed
slot's old row has `deliveredAt < now`, so it is *not* in the future-assignment map for
the new fire time → the recreated slot draws fresh. The bag advances once per elapsed
slot per pass, not per reopen.

### Per-layer fire-time computation (already exists)

- Today one-shots: `fireAt` = the concrete today `DateTime` from
  `QuoteSlotPlanner.todaySlotsFrom`.
- Grid cells: `fireAt` = `_nextOccurrenceOnWeekday(now, weekday, h, m)` — the next future
  occurrence of that weekday+time. When that occurrence passes and the app reopens, the
  computed `fireAt` rolls to the following week → no cached row for it → fresh draw.
  This is what rotates each weekday's grid quote across weeks (when opened ~weekly).

### Reopen-multiplier: eliminated

Two opens an hour apart in the same day compute the **same** future slot fire times →
find the **same** cached assignments → reuse them → **zero** extra bag draws. The bag
only advances when a genuinely new (or newly-elapsed) slot appears.

## What changes / what stays

**Changes (in `ScheduleCoreRemindersUseCase`):**
- Both layers consult the history table for an existing assignment at each slot's fire
  time before calling the fetcher; reuse when present, draw + persist when absent.
- Re-introduce pruning of stale future assignment rows via `clearFromExcept`, guarding
  past rows.
- The immediate notification path is unchanged (still records its own delivery).

**Stays untouched:**
- `QuoteSelector`, `QuoteIndicesRepository`, `GetNextQuoteUseCase` (bag + persistence).
- `QuoteSlotPlanner`, the two-layer slot computation, preset model, settings UI.
- `ReminderEvent` / scheduler repeat mapping.
- `NotificationHistoryRepository` interface (already has everything needed).

## Error handling

- No cached row + empty bucket → fetcher returns its existing safe fallback quote.
- Pool changes (quotes added/disabled) → `selectFromShuffleBag` already reshuffles via
  pool-key mismatch; cached rows for now-invalid pools are simply replaced on next draw.
- Clock moved backward / DST → at worst a slot is treated as future again and reused, or
  redrawn once; no crash, negligible drift.

## Testing

- **Reopen idempotency (use case):** schedule at 08:00; schedule again at 08:30 same day;
  assert the fetcher was called **0** extra times for still-future slots and the bag
  cursor (via a fake indices repo / call-count fake fetcher) advanced only for the
  initial distinct slots — not ×2.
- **Elapsed slot redraws (use case):** schedule at 08:00 (today slots 09:00, 10:00…);
  re-run at 09:30 → the 09:00 slot elapsed, its assignment is a past row, the new pass
  does not reuse it for a future slot; future slots (10:00+) reuse cached quotes.
- **Cross-week grid rotation (use case):** with a fake counting fetcher, a grid cell
  scheduled for next Saturday reuses its quote on a same-week reopen; after that
  Saturday passes, the next pass draws a fresh quote for the following Saturday (fetcher
  called again exactly once for it).
- **Past rows preserved:** a history row with `deliveredAt < now` survives a rebuild
  (not pruned), so the Notificações tab keeps real deliveries.
- **Regression:** existing two-layer tests still pass (counts, ids, repeat flags,
  budget, Angelus).

## Out of scope (YAGNI)

- True OS delivery callbacks (iOS doesn't provide them reliably).
- Tracking "was the phone on / notifications enabled" at each slot time.
- Any change to the bag/selector algorithm itself.
