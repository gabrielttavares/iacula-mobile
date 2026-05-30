# Quote notifications: OS-owned weekly-grid slots with long-run rotation

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
2. **Correct weekday emphasis without the app open:** each weekday's bucket
   (Domingo…Sábado in `quotes.json`) fires on its own weekday, Sunday-to-Sunday, even
   if the app is never opened. This rules out daily-repeat (which would replay one
   weekday's text every day) and requires a per-weekday weekly repeat.
3. **Long-run coverage:** every quote in each weekday bucket of `quotes.json` (492
   total across 7 weekdays) surfaces over time — not in a single day, but eventually,
   without repeating within a bucket until the bucket is exhausted.

These are reconciled by separating *what fires while closed* (a weekly grid of
per-weekday repeats) from *what rotates the text within a bucket* (the existing
shuffle-bag, advanced whenever the app runs a scheduling pass).

## Key iOS constraints (the reason for this design)

- A local notification is **either** a one-shot **or** a daily-repeat
  with a fixed baked-in text, forever, with no app involvement. The repeat cadence is
  set by `matchDateTimeComponents`:
  - `DateTimeComponents.time` → same clock time **every day**.
  - `DateTimeComponents.dayOfWeekAndTime` → same clock time **on one weekday**, weekly.
- iOS has **no native text rotation** and no concept of "use a different bucket on
  Sunday." The only thing that changes a notification's text — or selects a weekday
  bucket — is the app re-registering it, which only happens when the app runs.
- Hard cap of **64 pending notifications app-wide** — quotes share this budget with
  Angelus, prayer alarms, custom phrases, prayer intentions, season transitions.

Consequence: we cannot have "hundreds of distinct one-shots, one per quote." We use a
**weekly grid** of `dayOfWeekAndTime` repeats so each weekday's bucket fires on the
right weekday forever; rotation within each bucket happens over time as the app
re-rolls the grid's text on each scheduling pass.

## Design

### Slot timing — interval-derived clock times, per weekday

Replace `now + i*interval` drifting slots with **fixed daily clock times** spread
across a daily active window. The same set of clock times applies to every weekday:

- Active window: the part of the day outside quiet hours (reuse `QuietHoursChecker`).
  When quiet hours are disabled, default window `07:00–22:00` (constants, tunable).
- Slots per weekday = `floor(activeWindowMinutes / intervalMinutes)`, clamped to
  `kMaxQuoteSlotsPerWeekday = 6` (max) and 1 (min).
- Slot times = walk from the window start in `intervalMinutes` steps, skipping any time
  that lands in quiet hours, until the window end or the slot cap is reached.
- Times are whole-minute, deterministic for a given (interval, quiet-hours) pair.

Example: interval 3h, window 07:00–22:00 → 07:00, 10:00, 13:00, 16:00, 19:00, 22:00 (6 slots).

The existing interval picker UI stays meaningful: smaller interval → more slots/day.

### Slot registration — weekly grid, OS-owned per weekday

Register the cartesian product **(weekday 1–7) × (slot time)**. For each cell:

- A stable `scheduledId` = `quoteScheduleIdBase + (weekdayIndex * kMaxQuoteSlotsPerWeekday) + slotIndex`,
  so re-registration replaces in place and ids never collide.
- `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime` → iOS fires this cell
  at that clock time **only on that weekday**, every week, forever.
- `scheduledAt` = the next occurrence of (that weekday at that clock time) from now.
- `body` = a quote fetched via the **existing** `QuoteFetcher` for **that weekday**, so
  the text comes from the correct `quotes.json` bucket and advances that weekday's
  shuffle-bag cursor.

**Budget:** worst-case reservations are Angelus (1) + prayer alarms (~5) + intentions
(~7) + season transitions (≤2) ≈ 15, leaving ~49 of the 64 cap. With
`kMaxQuoteSlotsPerWeekday = 6`, the grid is at most 7 × 6 = **42** notifications,
leaving ~7 cushion. The reserved-slot accounting in the use case is updated to reflect
these figures.

### Scheduler change — support weekly repeat

`scheduleWithId` currently maps `repeatDaily == true` to
`matchDateTimeComponents: DateTimeComponents.time` and `false` to `null`. Extend
`ReminderEvent` with a repeat-cadence concept so a quote cell can request
`dayOfWeekAndTime`:

- Add `ReminderRepeat { none, daily, weekly }` (or a nullable `DateTimeComponents`-like
  enum in the domain layer) to `ReminderEvent`, defaulting to preserve current behavior
  (`repeatDaily: true` → `daily`).
- `scheduleWithId` maps `weekly → DateTimeComponents.dayOfWeekAndTime`.
- Existing Angelus/phrase callers that pass `repeatDaily: true` keep `daily` — no
  behavior change for them.

### Rotation — reuse the existing engine, do not rebuild

`main` already has the complete rotation engine and it is already wired as the
`QuoteFetcher`:

- `QuoteSelector.selectFromShuffleBag` — shuffled draw-down per weekday, no repeats
  until the bag empties, then reshuffle (avoids immediate repeat).
- `GetNextQuoteUseCase` — filters disabled quotes, appends rotation custom phrases,
  advances and persists the cursor/order via `QuoteIndicesRepository`.

**No changes to quote selection.** Each grid cell calls the fetcher once **for its own
weekday** (passing a `now` that lands on that weekday so `GetNextQuoteUseCase` reads the
right bucket); the cursor for that weekday advances; over many scheduling passes the
full bucket for each weekday is walked. This satisfies the long-run-coverage goal.

### Refresh behavior (when text changes vs. when it repeats)

- **App opens / settings save:** re-run the scheduling pass. Each grid cell is
  re-registered with a freshly fetched quote (its weekday's cursor advances). This is
  *safe* — re-registering a `dayOfWeekAndTime` repeat does not push the fire time
  forward the way the old one-shot reset did; the weekday+clock-time is fixed.
- **App stays closed for days/weeks:** iOS keeps firing each cell on its weekday with
  the last-baked quote. **The weekday emphasis is always correct** (Tuesday's cells only
  fire Tuesdays), because the weekday is encoded in the OS registration. The only
  degradation is that a cell repeats its current quote within its weekday bucket until
  the next app open — the accepted tradeoff (reliability over guaranteed-fresh-every-
  firing), strictly better than today's "nothing delivers."

### Immediate notification

Keep the existing immediate `showNow` on first schedule (id `quoteScheduleIdBase - 1`),
unchanged.

## What changes / what stays

**Changes:**

- `ScheduleCoreRemindersUseCase` + a small slot-time helper: compute fixed clock times
  from interval + active window, then register the 7-weekday × slots grid instead of the
  `now + i*interval` cursor loop.
- `ReminderEvent` + `scheduleWithId`: add a weekly repeat cadence mapping to
  `DateTimeComponents.dayOfWeekAndTime` (see Scheduler change above). `repeatDaily`
  callers keep daily behavior.
- Drop the timestamp-keyed reuse/`clearBetweenExcept` churn for quotes — with stable
  per-cell ids and OS-owned repeats, re-registration is idempotent by id, so the
  ISO-timestamp reuse map is no longer needed for quotes.

**Stays untouched:**

- `GetNextQuoteUseCase`, `QuoteSelector`, `QuoteIndicesRepository` (rotation engine).
- Angelus / liturgy / custom-phrase / intention scheduling (still use `daily`).

## Notification history / Notificações tab

The history table currently stores *predicted future* quote rows and the tab reads
`deliveredAt <= now`. With weekly-grid repeats, "future predicted rows" no longer map
cleanly (a cell has no single future timestamp — it repeats weekly). **Decision:** stop
writing predicted future rows for quotes. The grid registration does not write to the
history table at all. Keep the immediate-notification delivery row and the
last-delivered card exactly as today. The tab/hero therefore show real deliveries rather
than a churning prediction table — which ends the original display bug. Removing the
predicted-row writes also lets us drop the `clearBetweenExcept` churn entirely.

## Error handling

- No quotes for a weekday bucket → fetcher already returns a safe fallback quote; slot
  still registers.
- Quiet hours cover the whole window → zero slots; register none (matches "no quotes
  during quiet hours"). Guard against divide-by-zero / empty slot list.
- `exact_alarms_not_permitted` (Android) → existing fallback to inexact already handled
  in `scheduleWithId`.

## Testing

- **Slot-time helper (unit):** interval + window + quiet hours → expected clock times;
  cap at `kMaxQuoteSlotsPerWeekday`; empty window → no slots; quiet hours split window.
- **Use case (unit):** grid = 7 weekdays × slots → that many `scheduleWithId` calls with
  weekly cadence (`dayOfWeekAndTime`) and stable, non-colliding ids; the fetcher is
  called once per cell with a `now` on the matching weekday; re-running the pass
  re-registers the same ids (idempotent) with advanced cursors.
- **Weekday correctness:** a cell for weekday N draws from `quotes.json` bucket N
  (e.g. Tuesday cells pull Terça-feira quotes).
- **Rotation (selector already covered):** two consecutive passes for the same weekday
  yield different quote texts (cursor advanced).
- **Regression:** Angelus/liturgy/phrase scheduling unaffected (still `daily`); budget
  accounting holds — grid ≤ 42, reserved ≈ 15, total ≤ 64.

## Out of scope (YAGNI)

- Android-specific repeat semantics tuning beyond the existing fallback.
- Reworking the interval picker UI.
- Per-slot custom times chosen by the user (could be a later feature).

## Resolved decisions

1. **History/tab semantics** — *Record actual deliveries only.* Stop writing predicted
   future quote rows. Keep the immediate-notification delivery row + last-delivered card
   (as today). The grid registration no longer touches the history table. This ends the
   churn behind the original display bug; the tab reflects real deliveries.
2. **Default active window** (quiet hours off) — `07:00–22:00`, as constants.
3. **`kMaxQuoteSlotsPerWeekday = 6`** — 7 × 6 = 42, ~7 cushion under the 64 cap.
