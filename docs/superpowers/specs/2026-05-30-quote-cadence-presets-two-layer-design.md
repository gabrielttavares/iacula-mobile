# Quote notifications: cadence presets + two-layer scheduling

**Date:** 2026-05-30
**Branch:** `feat/quote-daily-repeat-rotation` (continues the weekly-grid work)
**Status:** Design — approved verbally, proceeding to plan + implementation
**Language:** Spec/plan/code in English. User-facing strings in pt-BR.

## Problem

The shipped weekly grid (verified on-device) clusters all of a day's quote slots
at the start of the active window: a 30-min interval produced only 6 slots at
07:00–09:30, then nothing until the next day. The user expects jaculatórias as
*frequent remembrance throughout the day* — "at most every 2h" — spread morning to
night, not packed into the morning.

Two coupled problems:

1. **Engine:** the pure weekly grid caps per-day density hard, because it multiplies
   by 7 weekdays against the iOS 64-pending-notification limit. Hourly-every-day
   (14×7 = 98) cannot fit.
2. **UX:** the "every N minutes" interval control is the wrong mental model. With the
   grid it really controls daily density, and the "next at now+interval" preview is
   now false. Users hit confusion ("why didn't it fire at 16:43?").

## Goal

Deliver frequent, day-spanning quote reminders with three things preserved from the
verified grid:

1. **OS reliability:** quotes keep firing while the app is closed (OS-owned repeats).
2. **Correct weekday emphasis:** each weekday's `quotes.json` bucket fires on its day.
3. **Long-run rotation + freshness:** the existing `GetNextQuoteUseCase` shuffle-bag
   feeds every slot (disabled-quote filtering, custom rotation phrases, per-weekday
   cursor — all unchanged).

Plus reframe the setting into prayer-rhythm presets that set honest expectations.

## iOS constraint (the reason for two layers)

Max 64 pending local notifications app-wide, shared with Angelus + Liturgy Hours +
custom phrases + intentions. The weekly grid multiplies per-day slots by 7, so dense
daily cadence (hourly) cannot be a pure grid. Resolved by splitting *what fires today
densely* (one-shots, current day) from *what fires while closed* (a thin weekly grid
floor). "30-min forever while closed" remains impossible and is out of scope.

## Design

### Section 1 — Cadence presets (pt-BR, user-facing)

Replace the "every N minutes" control with three presets. Each maps to a
(today-cadence, floor-density) pair. Cross-cutting rules apply to all: **skip the noon
hour (12:00–12:59)** — reserved for Angelus/Regina Caeli — and **skip quiet hours**
(existing behavior). Active window **07:00–21:00**.

| Preset (pt-BR) | Today layer (one-shots) | Weekly floor (grid) |
|---|---|---|
| **Suave** | every 2h → ~7/day | 5/weekday |
| **Regular** | every 90min → ~9/day | 5/weekday |
| **Frequente** | every 1h → ~13/day | 5/weekday |

**Storage:** no schema change. The preset persists via the existing
`interval_minutes` SQLite column using a representative value: Suave=120, Regular=90,
Frequente=60. A pure mapping function converts between preset ⇄ minutes.

**Migration:** existing saved `intervalMinutes` maps to the nearest preset on first
read: `<= 60 → Frequente`, `<= 120 → Regular`, `> 120 → Suave`. No data loss.

### Section 2 — Two-layer scheduling engine

Both layers are fed by `GetNextQuoteUseCase` (unchanged), so freshness, disabled-quote
filtering, custom rotation phrases, and per-weekday buckets are identical to today.

**Layer A — Today (one-shots).** For the current calendar day only, generate slot
clock-times at the preset's today-cadence, from the next slot at/after `now` through
21:00, skipping the noon hour and quiet hours. Each slot is a **one-shot**
(`repeatWeekly=false`, no `matchDateTimeComponents`) carrying a fresh quote drawn for
*today's weekday bucket*. ID range **9100–9126** (reserved block, distinct from grid
and Angelus).

- **Reopen behavior (idempotent, no churn):** re-running the pass keeps already-past
  slots untouched, refills only the future hours of today with fresh quotes, and (via
  Layer B) keeps future days seeded. This mirrors the grid's idempotency and avoids the
  original churn bug. Implemented by clearing only Layer-A ids whose time is `> now`
  and rebuilding those.

**Layer B — Weekly grid floor.** The existing 7-weekday grid, capped at **5/weekday**
(`kMaxQuoteSlotsPerWeekday` lowered 6→5 = 35 cells), each a `repeatWeekly=true` /
`dayOfWeekAndTime` OS repeat. Unchanged mechanism; this is the "fires while closed,
correct weekday emphasis" floor. ID range **9000–9034**.

**Today de-duplication.** To avoid today firing both the dense one-shots *and* the
grid's today-weekday cells (double notifications), Layer B **skips the current
weekday** when Layer A is active. So today = exactly Layer A's count; future days =
Layer B. Implemented by passing `skipWeekday: now.weekday` into the grid registration
when notifications are enabled.

**Budget (worst case, Frequente):** Layer A ~13 + Layer B 35 (minus today's ~5 from
the skip, so ~30) + Angelus 1 ≈ **44 ≤ 64.** ✅ Even without the skip it was 49.

**ID map (no collisions):**
- Immediate: 8999
- Angelus: 200
- Weekly grid (Layer B): 9000–9034 (7 × 5)
- Today one-shots (Layer A): 9100–9126 (≤ 20 used by Frequente; block sized to 27)

### Section 3 — Settings UX (pt-BR)

- Replace `IntervalSelector` (preset buttons + custom minute picker) with a **3-option
  preset selector**: Suave / Regular / Frequente, each with a one-line pt-BR subtitle
  describing the rhythm (e.g. *"Lembranças a cada 2 horas"*, *"a cada 1h30"*,
  *"a cada hora"*).
- Replace `_buildNextNotificationEstimate` (the false "next at now+interval" line) with
  an honest preset description, e.g. *"~7 lembranças por dia, da manhã à noite"*.
- The settings subtitle "Jaculatória a cada X minutos" becomes preset-based copy.
- Save still writes settings + triggers `RebuildNotificationsUseCase` (unchanged path).

### Section 4 — Slot planning (engine internals)

`QuoteSlotPlanner` gains a noon-skip and is reused by both layers:

- `slotMinutesOfDay(...)` already skips quiet hours; add an unconditional **noon-hour
  skip** (12:00–12:59) so neither layer schedules there.
- Layer A calls a new `todaySlotsFrom(now, cadenceMinutes, ...)` that walks from the
  next aligned slot at/after `now` to 21:00 (window end), applying the same noon +
  quiet-hours skips, returning concrete `DateTime`s for today.
- Layer B continues using `slotMinutesOfDay` with `maxSlots: 5`.

## What changes / what stays

**Changes:**
- New `JaculatoriaCadencePreset` enum + pure preset⇄minutes mapping (settings domain).
- `QuoteSlotPlanner`: add noon-skip; add `todaySlotsFrom` for Layer A.
- `ScheduleCoreRemindersUseCase`: add Layer A registration; pass `skipWeekday` to the
  grid; lower grid cap to 5.
- Settings UI: preset selector + honest description copy (pt-BR).
- `kMaxQuoteSlotsPerWeekday` 6 → 5.

**Stays untouched:**
- `GetNextQuoteUseCase`, `QuoteSelector`, `QuoteIndicesRepository` (rotation engine).
- `ReminderEvent` / scheduler repeat mapping (`repeatWeekly`/`repeatDaily` already
  exist and are verified).
- Angelus / Liturgy Hours / custom phrases / intentions scheduling.
- Settings persistence schema (reuse `interval_minutes`).
- "Record actual deliveries only" history decision from the prior spec.

## Error handling

- Empty today window (e.g. now is past 21:00, or quiet hours cover the rest of day) →
  Layer A produces zero slots; Layer B still covers future days. No crash.
- Noon-only / quiet-only windows → planner returns fewer/zero slots, guarded.
- Notifications disabled → both layers register nothing (existing guard).

## Testing

- **Preset mapping (unit):** preset→minutes and minutes→preset round-trip; migration
  thresholds (60/120) map to the right preset.
- **Planner noon-skip (unit):** no slot in 12:00–12:59 for any cadence/window.
- **`todaySlotsFrom` (unit):** walks from now to 21:00 at cadence; skips noon + quiet
  hours; empty when now ≥ 21:00.
- **Layer A (use case):** Frequente at 08:00 → today one-shots at 08–21 skipping 12,
  ids in 9100+, `repeatWeekly=false`; reopen at 16:00 keeps past, refills 16–21 only.
- **Layer B skip-weekday (use case):** grid registers 6 weekdays (not today), 5 each;
  today covered by Layer A; total ids unique, ≤ 64.
- **Budget (use case):** Frequente worst case ≤ 64 pending.
- **Regression:** Angelus daily untouched; existing grid tests updated to cap 5 +
  skip-weekday.

## Out of scope (YAGNI)

- 30-min-or-denser "forever while closed" (iOS-impossible).
- Avoiding ±window around Liturgy Hours (only noon/Angelus is reserved).
- Per-user custom times / advanced custom cadence.
- Changing the `interval_minutes` storage schema.
