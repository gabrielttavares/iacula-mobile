# Plan: Short-interval jaculatória cadence presets (platform-aware)

> STATUS: **Step 1 + Step 2 DONE.**
> Step 2 shipped via `NotificationCapacityPolicy` (domain/services), resolved from
> `defaultTargetPlatform` at the DI root and injected into RebuildNotificationsUseCase →
> ScheduleCoreRemindersUseCase. iOS: 64-cap, spread across 7-day runway, no tail (unchanged).
> Android: uncapped (`pendingTotalCapacity` 2000), 3 dense days at full cadence + half-cadence
> tail out to 14 days via `QuoteSlotPlanner.multiDaySlotsWithTail`. `quoteIdBlockSize` = 1024
> (fixed id space). Android settings note promises true cadence. Nothing committed yet.

## Goal
Let users pick sub-30-min cadences (15 / 10 / 5 min). Deliver honestly per platform,
and tell the user exactly what closed-app delivery looks like.

## Verified ground truth (read from code 2026-06-07)
- iOS hard cap: 64 pending local notifications app-wide (`RebuildNotificationsUseCase.maxPendingNotifications`).
- `ScheduleCoreRemindersUseCase`: quote budget = 64 − reserved tiers; spread across
  `runwayDays = 7`; per-day = `max(minQuotesPerDay, min(naturalSlotsPerDay, budget/7))`.
  So even the densest preset yields ≈9 quotes/day closed-app today. This is platform-blind.
- `JaculatoriaCadencePreset.weeklyFloorSlotsPerWeekday = 5` is DEAD — only referenced in
  its own doc + one test. The live multi-day queue does not use it. Will be removed.
- No platform branch in domain scheduling. Only platform code: repo exact-alarm fallback
  (`local_notification_scheduler_repository.dart` ~line 195, 335) — Android already uses
  `exactAllowWhileIdle` with `inexactAllowWhileIdle` fallback, so closed-app exact alarms work.
- Repo supports repeatDaily / repeatWeekly (matchDateTimeComponents). No "every N min" primitive.

## Decisions (from user)
- iOS: best-effort, keep 64÷7 spread. Honest UI note.
- Android: days 0–3 = true chosen cadence (exact). After day 3, still closed: HALF the
  chosen cadence (5→10, 10→20, 15→30), indefinitely until app reopened. No 64 cap on Android.
- UI note: per-platform text.

## Design

### 1. Presets (`jaculatoria_cadence_preset.dart`)
Add: `intenso` (15m), `muitoIntenso` (10m), `extremo` (5m) — names TBD, keep pt-BR labels short.
- `todayCadenceMinutes` returns the literal minutes for the new ones.
- Update `fromIntervalMinutes` thresholds so 5/10/15 round-trip to their own preset
  (current `<=45 -> maisFrequente` collapses them all). New bands: `<=7→5m, <=12→10m,
  <=22→15m, <=45→30m(maisFrequente), <=75→frequente, <=135→regular, else suave`.
- DELETE `weeklyFloorSlotsPerWeekday` (dead, misleading) + its test assertion.
- Add `cadenceLabelPtBr` / `cadencePhrasePtBr` cases for the new presets.

### 2. Capacity policy (new, injectable, platform-aware) — keeps domain pure
New value object e.g. `NotificationCapacityPolicy` in domain/services:
```
final class NotificationCapacityPolicy {
  final int pendingCapacity;       // iOS 64; Android large (e.g. 480 → ~3 days @5min in window)
  final int denseRunwayDays;       // iOS 7 (budget-spread); Android 3 (true cadence)
  final bool spreadBudgetAcrossRunway; // iOS true; Android false (honor real cadence)
  final int? tailCadenceDivisor;   // Android 2 (half-cadence tail); iOS null
}
```
Resolve once at the composition root (DI provider) from `defaultTargetPlatform`
(NOT inside domain). Pass into `RebuildNotificationsUseCase` / `ScheduleCoreRemindersUseCase`.
Tests inject a fake policy → fully deterministic, no Platform calls in tests.

### 3. ScheduleCoreRemindersUseCase changes
- Replace hardcoded `maxQueuedQuoteReminders`/`runwayDays` reads with policy values.
- iOS path: unchanged math (spread budget across runway).
- Android path: `slotsPerDay = naturalSlotsPerDay` (full cadence, no budget squeeze) for
  days 0..denseRunwayDays; then append a HALF-cadence tail.
  - Tail mechanism: prefer a repeating notification at half-cadence. Since the plugin has
    no "every N min" matchComponent, evaluate options in spike:
    (a) `periodicallyShow` with a custom RepeatInterval (plugin supports `everyMinute`/
        `hourly`/`daily` only — not arbitrary N), OR
    (b) a long finite one-shot list at half-cadence out to a far horizon (e.g. +14 days),
        re-armed on each app open. Android has no pending cap so a long list is acceptable.
  - LEANING (b): finite half-cadence one-shots to a 14-day horizon. Simple, exact,
    re-arms on open, no new repeat primitive. Confirm alarm-count is sane (~half of dense).

### 4. UI
- `CadencePresetSelector`: surface new presets. Keep cards from wrapping (labels short).
- Add per-platform closed-app note near the selector / settings:
  - iOS: "Com o app fechado, você recebe algumas jaculatórias por dia (cadência reduzida)."
  - Android: "Você recebe na frequência escolhida; após alguns dias sem abrir, a metade dela."
  (Exact pt-BR wording: user picked "per-platform note"; finalize copy, run /humanizer-style
   pass only if it were a work repo — this is side/, so skip humanizer.)

### 5. Tests (TDD — write first)
- `jaculatoria_cadence_preset_test.dart`: new presets round-trip via fromIntervalMinutes;
  remove dead weeklyFloor assertion; label/phrase cases.
- New `schedule_core_reminders_platform_policy_test.dart`:
  - iOS policy → total quote one-shots ≤ 64, spread ≈ budget/7 per day.
  - Android policy → days 0..3 at full chosen cadence; day 4+ at half cadence; no 64 cap.
  - Floor still honored (minQuotesPerDay).
- Widget test for CadencePresetSelector showing the new presets + correct per-platform note.

## Out of scope / explicitly NOT doing
- No Firebase / no backend (separately decided: season transitions already local + tested).
- No change to season-transition, intentions, phrases, liturgy tiers.

## Risks
- Android many-alarms battery/Doze: exact alarms while idle are allowed but Doze may batch;
  half-cadence tail keeps counts moderate. Validate pending count in a real/em run.
- iOS perception: user picks 5min but closed-app is ~9/day. The honest note is the mitigation.
