# Quote notifications: OS-owned daily-repeat slots with long-run rotation

**Date:** 2026-05-30
**Branch:** `feat/quote-daily-repeat-rotation` (worktree off `main`)
**Status:** Design — awaiting review

## Problem

Quote notifications barely deliver in the field (reported May 2026, ~v1.0.20+). The
root cause is not the device and not quote supply.

Today `ScheduleCoreRemindersUseCase` pre-schedules ~58 **one-shot** iOS notifications at
`now + i*interval`. iOS holds them fine, but the app keeps cancelling and
re-scheduling them from `now`:

- Any **settings save** cancels all ~58 and reschedules from the current moment.
- A launch/resume with an empty queue does the same.

With a large interval (e.g. 30m–3h), the next slot never matures before the next
reset pushes it forward again, so the user is starved of deliveries. The alarm path
(Angelus, liturgy hours, prayer alarms) never suffers this because it uses
`repeatDaily: true` → iOS owns the repeat and the app never has to replenish it.

## Goal

1. **Alarm-grade reliability:** quote notifications keep firing even if the app stays
   closed for days. iOS owns the repeat; nothing the app does on launch/settings-save
   can starve the next delivery.
2. **Long-run coverage:** every quote in each weekday bucket of `quotes.json` (492
   total across 7 weekdays) surfaces over time — not in a single day, but eventually,
   without repeating within a bucket until the bucket is exhausted.

These are reconciled by separating *what fires while closed* (fixed daily-repeat
registrations) from *what rotates the text* (the existing shuffle-bag, advanced
whenever the app runs a scheduling pass).

## Key iOS constraints (the reason for this design)

- A local notification is **either** a one-shot **or** a daily-repeat
  (`DateTimeComponents.time`), which fires at a fixed clock time every day **with the
  same baked-in text**, forever, with no app involvement.
- iOS has **no native text rotation**. The only thing that changes a notification's
  text is the app re-registering it.
- Hard cap of **64 pending notifications app-wide** — quotes share this budget with
  Angelus, liturgy hours, custom phrases, prayer intentions, season transitions.

Consequence: we cannot have "hundreds of distinct one-shots, one per quote." We use a
small set of daily-repeat slots; rotation across the full bucket happens over time as
the app re-rolls their text on each scheduling pass.

## Design

### Slot timing — interval-derived, fixed clock times

Replace `now + i*interval` drifting slots with **fixed daily clock times** spread
across a daily active window:

- Active window: the part of the day outside quiet hours (reuse `QuietHoursChecker`).
  When quiet hours are disabled, default window `08:00–22:00` (constants, tunable).
- Number of slots per day = `floor(activeWindowMinutes / intervalMinutes)`, clamped to
  a sane max (proposed `kMaxDailyQuoteSlots = 8`) and a min of 1.
- Slot times = walk from the window start in `intervalMinutes` steps, skipping any time
  that lands in quiet hours, until the window end or the slot cap is reached.
- Times are whole-minute, deterministic for a given (interval, quiet-hours) pair.

Example: interval 3h, window 08:00–22:00 → 08:00, 11:00, 14:00, 17:00, 20:00 (5 slots).

The existing interval picker UI stays meaningful: smaller interval → more slots/day.

### Slot registration — daily-repeat, OS-owned

For each slot time, register **one** notification with:

- A stable `scheduledId` per slot index (reuse the `quoteScheduleIdBase` range,
  e.g. `9000 + slotIndex`), so re-registration replaces in place.
- `repeatDaily: true` → the scheduler already maps this to
  `matchDateTimeComponents: DateTimeComponents.time`. iOS fires it daily forever.
- `scheduledAt` = next occurrence of that clock time (today if still ahead, else
  tomorrow).
- `body` = a quote fetched via the **existing** `QuoteFetcher` (i.e.
  `GetNextQuoteUseCase`), which advances the per-weekday shuffle-bag cursor.

Total registered = number of slots (≤ `kMaxDailyQuoteSlots`), comfortably inside the
64-cap budget. The existing reserved-slot accounting for alarms still applies and gets
*easier* because we register far fewer quote notifications.

### Rotation — reuse the existing engine, do not rebuild

`main` already has the complete rotation engine and it is already wired as the
`QuoteFetcher`:

- `QuoteSelector.selectFromShuffleBag` — shuffled draw-down per weekday, no repeats
  until the bag empties, then reshuffle (avoids immediate repeat).
- `GetNextQuoteUseCase` — filters disabled quotes, appends rotation custom phrases,
  advances and persists the cursor/order via `QuoteIndicesRepository`.

**No changes to quote selection.** Each slot we fill calls the fetcher once; the cursor
advances; over many scheduling passes (and across weekdays) the full bucket is walked.
This is what satisfies the long-run-coverage goal.

### Refresh behavior (when text changes vs. when it repeats)

- **App opens / settings save:** re-run the scheduling pass. Each daily-repeat slot is
  re-registered with a freshly fetched quote (cursor advances). This is now *safe* —
  re-registering a daily-repeat does not push the fire time forward the way the old
  one-shot reset did; the clock time is fixed.
- **App stays closed for days:** iOS keeps firing each slot at its fixed time with the
  last-baked quote. A slot repeats its current quote until the next app open. This is
  the accepted tradeoff (reliability over guaranteed-fresh-every-firing) and is
  strictly better than today's "nothing delivers."

### Immediate notification

Keep the existing immediate `showNow` on first schedule (id `quoteScheduleIdBase - 1`),
unchanged.

## What changes / what stays

**Changes (all inside `ScheduleCoreRemindersUseCase` and a small slot-time helper):**

- New slot-time computation: fixed clock times from interval + active window, replacing
  the `now + i*interval` cursor loop.
- Register quote slots with `repeatDaily: true` and stable per-slot ids.
- Drop the timestamp-keyed reuse/`clearBetweenExcept` churn for quotes — with fixed ids
  and daily-repeat, re-registration is idempotent by id, so the ISO-timestamp reuse map
  is no longer needed for quotes.

**Stays untouched:**

- `GetNextQuoteUseCase`, `QuoteSelector`, `QuoteIndicesRepository` (rotation engine).
- `LocalNotificationSchedulerRepository` (`scheduleWithId` already honors `repeatDaily`).
- Angelus / liturgy / custom-phrase / intention scheduling.
- The notification-history table semantics — though see Open Questions.

## Notification history / Notificações tab

The history table currently stores *predicted future* quote rows and the tab reads
`deliveredAt <= now`. With daily-repeat slots, "future predicted rows" no longer map
cleanly (a slot has no single future timestamp — it repeats). Proposed: stop writing
predicted future rows for quotes; instead record an actual-delivery row when the app can
observe a delivery (or, minimally, record the immediate-notification delivery and the
last-delivered card as today). This keeps the tab showing real deliveries rather than a
churning prediction table. **This is the main open design question — see below.**

## Error handling

- No quotes for a weekday bucket → fetcher already returns a safe fallback quote; slot
  still registers.
- Quiet hours cover the whole window → zero slots; register none (matches "no quotes
  during quiet hours"). Guard against divide-by-zero / empty slot list.
- `exact_alarms_not_permitted` (Android) → existing fallback to inexact already handled
  in `scheduleWithId`.

## Testing

- **Slot-time helper (unit):** interval + window + quiet hours → expected clock times;
  slot cap respected; empty window → no slots; quiet hours split window correctly.
- **Use case (unit):** N slots → N `scheduleWithId` calls with `repeatDaily: true` and
  stable ids; fetcher called once per slot; re-running the pass re-registers same ids
  (idempotent) with advanced cursor.
- **Rotation (existing tests cover the selector):** add a test that scheduling two
  consecutive passes for the same weekday yields different quote texts (cursor advanced).
- **Regression:** Angelus/liturgy scheduling unaffected; 64-budget accounting still
  holds with fewer quote registrations.

## Out of scope (YAGNI)

- Android-specific repeat semantics tuning beyond the existing fallback.
- Reworking the interval picker UI.
- Per-slot custom times chosen by the user (could be a later feature).

## Open questions for review

1. **History/tab semantics** — adopt the "record actual deliveries, stop predicting
   future rows" approach above, or keep the current table and just stop the churn? This
   affects what the Notificações tab and home hero show.
2. **Default active window** when quiet hours are off — `08:00–22:00` acceptable, or
   derive from something already in settings?
3. **`kMaxDailyQuoteSlots`** — is 8 the right ceiling?
