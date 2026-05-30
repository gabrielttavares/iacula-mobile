# "Mais frequente" (~30-min) cadence preset — dense-today-only

**Date:** 2026-05-30
**Branch:** `feat/quote-daily-repeat-rotation` (continues the two-layer cadence work)
**Status:** Design — proposed, pending approval
**Language:** Spec/plan/code in English. User-facing strings in pt-BR.

This spec extends [the two-layer cadence-preset design](2026-05-30-quote-cadence-presets-two-layer-design.md)
and is intentionally consistent with [the slot-assignment-cache design](2026-05-30-quote-slot-assignment-cache-design.md).
Read both first. Nothing here contradicts the "advance the bag per delivery, reuse-if-future"
rule; the new preset only makes the today layer denser, and the cache rule already
covers an arbitrary number of today one-shots.

## Problem

The shipped preset set tops out at **Frequente** (1h today layer, ~13 reminders/day).
Some users — the most engaged ones, who keep the app open through the day — want
jaculatórias as near-continuous remembrance: roughly **every 30 minutes**. The current
ceiling can't express that.

The naive request ("a 30-min option") collides with the iOS reality the two-layer
engine was built to respect:

1. A 30-min cadence applied to the **weekly grid floor** (Layer B) is impossible: a
   ~12–14h window at 30-min is ~24 slots, multiplied by 7 weekdays = ~168 pending
   notifications, far past the 64 app-wide cap. The grid floor must therefore stay at
   its gentle ~5/weekday density regardless of the preset.
2. So a 30-min cadence can only live in the **today layer** (Layer A): dense one-shots
   for the current calendar day, refilled on app open. That means 30-min is honest only
   on days the user actually opens the app. **Closed days fall back to the ~5/weekday
   grid floor** — the same floor every other preset uses.

The human's key insight — that a longer *horário silencioso* (quiet hours) shrinks the
active window, frees budget, and could "allow" 30-min to fit — turns out to be true but
**not load-bearing for fitting** (see Budget below): the today layer is a single day, so
even the full 07:00–21:00 window at 30-min fits comfortably. Quiet hours remain a
**comfort / fatigue** lever (fewer pre-dawn and late-night pings), not a gate that
unlocks the preset.

## Goal

Add a fourth preset, **"Mais frequente"** (~30-min today cadence), that:

1. Reuses the existing two-layer engine with **no engine restructuring** — only a new
   `todayCadenceMinutes` value and a slightly larger today-layer cap.
2. Keeps the weekly grid floor unchanged at 5/weekday (`kMaxQuoteSlotsPerWeekday`), so
   closed-app behaviour and the budget math for Layers B + Angelus are untouched.
3. Stays safely under the 64-pending iOS cap **with headroom reserved for the other
   notification consumers** (custom phrases, prayer intentions), in every quiet-
   hours configuration.
4. Sets honest expectations in pt-BR copy: this is a high volume, and the 30-min density
   only applies on days the app is opened.
5. Round-trips through the existing `interval_minutes` storage and the
   `fromIntervalMinutes` migration thresholds without colliding with the 60/90/180
   mapping the three existing presets use.

## iOS constraint

Max **64 pending local notifications app-wide**, shared across:

- Angelus / Regina Caeli (1 daily repeat, id 200)
- Custom phrases (user-defined, variable — real, has a scheduler + UI)
- Prayer intentions (user-defined, variable — real, has a scheduler + UI)
- The two quote layers (grid floor 9000–9034, today one-shots 9100+)
- Immediate (8999)

(There is a dormant `ScheduleLiturgyRemindersUseCase` + `laudesEnabled` setting in the
codebase, but it has **no settings toggle**, defaults to `false`, and only Laudes is
schedulable — so it is **not a live notification-budget consumer** and is deliberately
excluded from the reserve below.)

The today layer is the only lever that can be dense, because it covers a single day and
is not multiplied by 7. The grid floor stays gentle. This is the same partition the
parent spec established; this preset only pushes the today layer to its practical limit.

## Design

### Decision 1 — Always-available 4th preset, NOT a conditional unlock

**Decision: ship "Mais frequente" as a permanent 4th preset card. Do not gate it behind
a quiet-hours length.**

Reasoning:

- **The budget math doesn't need the gate.** A conditional unlock would only be justified
  if 30-min *failed to fit* under short/absent quiet hours and *fit* under long quiet
  hours. It doesn't work that way: the worst case (no quiet hours, full 07:00–21:00
  window) is the densest today layer, and it still fits (see Decision 2). Quiet hours can
  only *reduce* the today-layer count, never push it over. There is no budget cliff to
  protect against, so a gate would be protecting against nothing.
- **Conditional unlock is a confusing UX.** A preset that silently appears/disappears as
  the user drags quiet-hours times is a discoverability and trust problem: the user can't
  find the option they were told about, and we'd owe them an explanation ("set quiet
  hours ≥ N hours to unlock…") that is itself a worse fatigue nudge than just showing the
  card. It also couples two unrelated controls (cadence and quiet hours) in the user's
  mental model.
- **Fatigue is handled by honesty, not by hiding.** ~30-min on an active day is up to
  ~24 reminders — genuinely a lot for a devotional app. The right mitigation is clear
  copy that states the volume and the open-the-app caveat (Decision 4), plus the option
  to set quiet hours to trim the edges. Hiding the card doesn't reduce fatigue for the
  users who do enable it; it just makes the feature feel broken for everyone else.
- **The cap is the real safety mechanism**, not the gate. We reserve headroom for other
  consumers via `maxTodayLayerSlots` (Decision 2), which protects the budget regardless
  of quiet-hours settings.

The one thing we keep from the human's insight: surface quiet hours as the recommended
companion to this preset in copy (a gentle "consider a longer horário silencioso"), but
never as a hard prerequisite.

### Decision 2 — Budget math and the today-layer cap

Window 07:00–21:00 = 14h = 840 min. Noon hour 12:00–12:59 is always skipped (Angelus).
Grid floor with today's weekday skipped = 6 weekdays × 5 = **30**. Angelus = **1**.

Today-layer slot count for a 30-min cadence, by quiet-hours config (computed against the
real planner semantics: slots aligned to 07:00 + k·30, skip noon hour, skip quiet hours,
through 21:00 inclusive):

| Quiet hours | Effective active span | Today layer (30-min) | + grid 30 + Angelus 1 | Fits ≤ 64? |
|---|---|---|---|---|
| none | 07:00–21:00 (14h) | **27** | **58** | yes |
| 22:00–07:00 (default) | 07:00–21:00 (14h) | 27 | 58 | yes |
| 23:00–06:00 | 07:00–21:00 (14h) | 27 | 58 | yes |
| 22:00–08:00 | 08:00–21:00 (13h) | 25 | 56 | yes |
| 21:00–08:00 | 08:00–20:30 (~12h) | 24 | 55 | yes |
| 21:00–09:00 (long, ~12h window) | 09:00–20:30 | 22 | 53 | yes |
| 20:00–08:00 (12h window) | 08:00–19:30 | 22 | 53 | yes |

For contrast, the 1h (Frequente) today layer is **14** in the full window → 14 + 30 + 1 =
45, matching the parent spec's stated 44–45.

**The densest case is "no quiet hours": today layer = 27, total quote+Angelus = 58.**
Quiet hours only ever shrink the today layer, so 58 is the worst case for the
quote-engine's own footprint.

**Headroom for other consumers.** 64 − 58 = **6** pending slots left for custom phrases +
prayer intentions (the only other live consumers; Angelus is already in the 58). Six is
thin for a user with a handful of custom phrases. To guarantee we never overrun the cap,
we **cap the today layer below its natural 27**:

- **Raise `maxTodayLayerSlots` from 27 → 28** so the constant no longer silently clips a
  legitimate 30-min full-window day (which produces 27), but
- **introduce an explicit reserved-budget guard** so the today layer is additionally
  capped at runtime to `maxQueuedQuoteReminders − gridFloorCount − reservedForOthers`.

  Concretely, define `kReservedNonQuoteBudget = 10` (1 Angelus + ~9 headroom for custom
  phrases and prayer intentions — no liturgy hours, since those aren't a live consumer).
  The effective today-layer cap each pass is:

  ```
  effectiveTodayCap = min(
    maxTodayLayerSlots,                              // 28, the id-block ceiling
    maxQueuedQuoteReminders - gridFloorCount - kReservedNonQuoteBudget
  )
  // worst case: 64 - 30 - 10 = 24
  ```

  So in the densest real configuration the today layer is trimmed to **24**, giving
  24 + 30 + 1 (Angelus) = 55 quote+Angelus pending, leaving **9** for custom phrases +
  intentions. When the grid floor is smaller (e.g. quiet hours trim some grid cells too)
  the today layer is allowed to grow back toward 27/28. This keeps the app *provably*
  under 64 for any combination, at the cost of capping the very densest 30-min days a
  touch below the theoretical 27 — an invisible trade (the user still gets ~24 reminders
  that day, plus the grid).

**Answer to "does 30-min need the cap raised, and to what":** yes, nudge
`maxTodayLayerSlots` 27 → **28** (so a full-window 30-min day's 27 slots aren't clipped by
the id-block ceiling), but the *binding* limit is the new reserved-budget guard, which
trims the today layer to **24** in the worst real case. Net worst-case pending committed
to: **55** (quotes + Angelus), with 9 reserved for custom phrases + intentions.

### Decision 3 — What the preset changes vs. the existing presets

| Field | Suave | Regular | Frequente | **Mais frequente (new)** |
|---|---|---|---|---|
| `intervalMinutes` (stored) | 180 | 90 | 60 | **30** |
| `todayCadenceMinutes` | 120 | 90 | 60 | **30** |
| `weeklyFloorSlotsPerWeekday` | 5 | 5 | 5 | **5 (unchanged)** |

So the new preset changes **only** the today-layer cadence (30) and the persisted
representative value (30). The grid floor density stays 5/weekday — closed-app behaviour
and Layer-B budget are identical to every other preset.

**Storage & round-trip — new `fromIntervalMinutes` thresholds.** The current thresholds
are `<=60 → frequente`, `<=120 → regular`, `else suave`. Persisting 30 for the new preset
would currently map back to `frequente` (30 ≤ 60), colliding. New thresholds:

```
<= 45  -> maisFrequente
<= 75  -> frequente      // 60 lands here
<= 135 -> regular        // 90 lands here
else   -> suave          // 180 lands here
```

Round-trip check (stored value → preset):

- 30 → ≤45 → maisFrequente ✓
- 60 → ≤75 → frequente ✓
- 90 → ≤135 → regular ✓
- 180 → else → suave ✓

No collisions; each preset's representative interval lands in its own band. The 45 / 75
boundaries are midpoints between adjacent representative values (30↔60 → 45; 60↔90 → 75),
so legacy custom intervals migrate to the nearest preset sensibly (e.g. a legacy 40
→ maisFrequente, 50 → frequente).

**Enum ordering.** Add `maisFrequente(intervalMinutes: 30)` as the **last** enum value
(after `frequente`), so the preset selector renders Suave → Regular → Frequente → Mais
frequente in increasing-density order, matching reading direction.

### Decision 4 — UX copy (pt-BR) and the honest disclosure

New enum strings (mirroring the existing fields):

- `cadenceLabelPtBr` (short card subtitle, must not wrap): **`A cada 30min`**
- `cadencePhrasePtBr` (inline, lowercase): **`a cada 30 minutos`**
- `dailyVolumeDescriptionPtBr` (settings estimate line):
  **`Cerca de 24 lembranças por dia — só nos dias em que você abre o app.`**

The honest open-the-app caveat is the load-bearing addition. Two-part placement:

1. **Always-visible, preset-specific estimate line** (the existing
   `_buildNextNotificationEstimate` slot, already below the selector). For "Mais
   frequente" only, this line carries the volume *and* the caveat in one sentence (the
   `dailyVolumeDescriptionPtBr` above). The other three presets keep their current
   single-clause descriptions, so the caveat doesn't clutter the common case.
2. **A one-line footnote shown only when "Mais frequente" is selected**, placed directly
   under the estimate line, styled as `secondary`:
   **`Nos dias sem abrir o app, mantemos um ritmo suave.`**
   This is the explicit closed-day fallback disclosure. Gating it on selection keeps the
   settings screen uncluttered for users on the other three presets.

Optional gentle nudge (same conditional footnote block, second line) tying in the quiet-
hours lever without making it a requirement:
**`Dica: um horário silencioso mais longo deixa o ritmo mais tranquilo de manhã e à noite.`**

No new card label string lives on the enum; the display label `Mais frequente` is added
to the `_presetLabels` map in `cadence_preset_selector.dart` alongside the existing three.

**Card-wrapping note.** The selector currently lays out 3 equal-width cards in a Row. A
4th card narrows each column; `A cada 30min` is comparable in width to the existing
`A cada 1h30`, so it should fit, but the selector should be verified at the smallest
supported width. If 4 cards in one row are too cramped, the fallback (out of scope to
build now, noted for the implementer) is a 2×2 wrap — but first try 4-in-a-row, since the
subtitles are all short.

### Decision 5 — Consistency with the slot-assignment-cache design

The cache spec's rule is layer-agnostic: "a slot identified by its next concrete fire
`DateTime` is assigned a quote once; reuse if still future, redraw if elapsed." The
30-min preset only increases the *number* of today-layer fire times (up to ~24 instead
of ~13). Nothing about the rule changes:

- **Bag draws scale with distinct future slots, not with cadence-as-such.** A denser today
  layer means more distinct fire `DateTime`s per day (up to ~24 instead of ~13), so the
  bag legitimately advances more times per active day — which is correct: the user is
  genuinely receiving more quotes. Reopening the app the same day still finds the same
  future fire times in
  `byFireTime` and reuses them → **zero** extra draws per reopen, exactly as the cache
  spec guarantees. The reopen-multiplier stays eliminated.
- **No new pruning concerns.** `clearFromExcept(now, keepFireTimes)` with more
  `keepFireTimes` is the same operation; past rows (`deliveredAt < now`) are still
  preserved for the Notificações tab.

**ID-range concern (flagged precisely).** Today-layer ids are `todayLayerIdBase + slotIndex`
= 9100 + slotIndex. The grid floor occupies 9000–9034. The today block must not collide
with the grid block and must fit its own slots:

- Worst-case today-layer count after the reserved-budget guard is 24 → ids 9100–9123.
- Even the uncapped natural maximum (27, no quiet hours) → ids 9100–9126.
- `maxTodayLayerSlots` rises 27 → **28**, so the reserved id block is **9100–9127**.

9100–9127 is clear of the grid's 9000–9034 (66-id gap) and of Angelus (200) and immediate
(8999). **No id collision.** The only constant that changes for ranges is
`maxTodayLayerSlots` (27 → 28). `todayLayerIdBase` (9100) and `quoteScheduleIdBase` (9000)
are unchanged.

## What changes / what stays

**Changes:**

- `JaculatoriaCadencePreset`: add `maisFrequente(intervalMinutes: 30)` as the last value;
  add its `todayCadenceMinutes` (30) and pt-BR strings (`cadenceLabelPtBr` `A cada 30min`,
  `cadencePhrasePtBr` `a cada 30 minutos`, `dailyVolumeDescriptionPtBr` with the
  open-the-app caveat); update `fromIntervalMinutes` thresholds to `45 / 75 / 135`.
- `ScheduleCoreRemindersUseCase`: bump `maxTodayLayerSlots` 27 → 28; add
  `kReservedNonQuoteBudget` (=10) and an `effectiveTodayCap = min(maxTodayLayerSlots,
  maxQueuedQuoteReminders − gridFloorCount − kReservedNonQuoteBudget)` used in the
  today-layer loop bound instead of the bare `maxTodayLayerSlots`.
- `cadence_preset_selector.dart`: add `JaculatoriaCadencePreset.maisFrequente → 'Mais
  frequente'` to `_presetLabels`; verify the 4-card Row at minimum width.
- `settings_screen.dart`: when `maisFrequente` is selected, render the conditional
  closed-day footnote (`Nos dias sem abrir o app, mantemos um ritmo suave.`) and the
  optional quiet-hours nudge under the estimate line.

**Stays untouched:**

- `kMaxQuoteSlotsPerWeekday` (5) and the entire weekly grid floor mechanism (Layer B).
- `QuoteSlotPlanner` (`todaySlotsFrom`, `slotMinutesOfDay`, noon-skip, window consts) —
  30 is just another `cadenceMinutes`/`intervalMinutes` value; no planner change.
- The slot-assignment-cache design and its history-table reuse.
- `GetNextQuoteUseCase`, `QuoteSelector`, `QuoteIndicesRepository` (rotation engine).
- `ReminderEvent` / scheduler repeat mapping; Angelus / custom phrases / intentions
  scheduling.
- Settings persistence schema (still the `interval_minutes` column; stored value 30).
- `todayLayerIdBase` (9100), `quoteScheduleIdBase` (9000), `maxQueuedQuoteReminders` (64).

## Error handling

- **Empty today window** (now past 21:00, or quiet hours cover the rest of today): the
  planner returns zero today slots; the grid floor still covers future days. No crash.
- **Reserved-budget guard yields ≤ 0** (only if the grid floor + reserved budget already
  exceed 64 — not reachable with grid=30, reserved=10, cap=64, since 30+10 = 40 < 64):
  defensively clamp `effectiveTodayCap` to `max(0, …)` so the loop simply schedules no
  today slots rather than iterating negatively.
- **Migration of a legacy stored interval** between 31–45 (e.g. someone had a 40-min
  custom interval from before presets): maps to `maisFrequente`. Acceptable — it's the
  nearest preset and the new preset can honour it.
- All existing guards (notifications disabled → both layers register nothing; noon/quiet-
  only windows → fewer/zero slots) are unchanged.

## Testing

- **Preset mapping (unit):** `maisFrequente.intervalMinutes == 30`,
  `todayCadenceMinutes == 30`, `weeklyFloorSlotsPerWeekday == 5`; `fromIntervalMinutes`
  round-trips 30→maisFrequente, 60→frequente, 90→regular, 180→suave; boundary cases
  45→maisFrequente, 46→frequente, 75→frequente, 76→regular, 135→regular, 136→suave.
- **Migration (unit):** legacy 40 → maisFrequente; legacy 50 → frequente (no collision
  with the existing presets' bands).
- **Today layer at 30-min (use case):** maisFrequente at 07:00 with no quiet hours →
  today one-shots at 30-min spacing 07:00–21:00 skipping the noon hour, count == 27 before
  the reserved-budget guard; ids in 9100–9127, `repeatWeekly == false`.
- **Reserved-budget guard (use case):** with grid floor = 30 and `kReservedNonQuoteBudget
  = 10`, the today layer is trimmed to 24; total quote+Angelus pending == 55; assert
  ≤ 64. Add a case with several custom phrases + intentions enabled and assert total
  app-wide pending ≤ 64.
- **Quiet-hours configs (use case):** parametrize the table in Decision 2 (none /
  22:00–07:00 / 22:00–08:00 / 21:00–09:00) and assert today-layer counts (27/27/25/22) and
  that each total ≤ 64.
- **Reopen idempotency at 30-min (use case):** schedule maisFrequente at 08:00, re-run at
  08:15 → the cache rule reuses all still-future today slots → fetcher called 0 extra
  times for them (consistent with the slot-assignment-cache spec).
- **Selector & copy (widget):** 4 preset cards render in increasing-density order; the
  closed-day footnote appears only when maisFrequente is selected and not for the other
  three; `A cada 30min` subtitle does not wrap at the minimum supported width.
- **Regression:** the three existing presets' today-layer counts (Suave 7, Regular 9,
  Frequente 13/14) and the parent spec's budget figures are unchanged; Angelus daily and
  the grid skip-weekday behaviour untouched.

## Out of scope (YAGNI)

- 30-min (or denser) "forever while closed" — iOS-impossible; the closed-day floor stays
  at 5/weekday by design.
- A conditional quiet-hours unlock for the preset (explicitly rejected in Decision 1).
- A 2×2 selector layout — only build it if the 4-in-a-row Row proves too cramped at the
  smallest width; first preference is keeping the single Row.
- Per-user custom 30-min times / sub-30-min cadences.
- Dynamically counting other consumers' actual pending notifications to compute
  `kReservedNonQuoteBudget` precisely — a fixed conservative reserve (10) is sufficient
  and avoids querying the OS for the current pending set on every pass.
- Changing the `interval_minutes` storage schema.
