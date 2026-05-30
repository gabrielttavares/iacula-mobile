# Quote Weekly-Grid Notification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the drift-prone `now + i*interval` one-shot quote notifications with a fixed weekly grid of OS-owned repeating notifications (7 weekdays × N daily slots), so quotes fire reliably even when the app stays closed, with the correct weekday emphasis from `quotes.json`, and rotate through each weekday's bucket over time.

**Architecture:** Each grid cell is registered with `DateTimeComponents.dayOfWeekAndTime` so iOS fires it weekly on its weekday with baked text. Slot clock-times are derived from the interval within a daily active window (quiet-hours-aware), capped at 6 per weekday. Each cell's text comes from the existing `QuoteFetcher` called with a `now` on that weekday, advancing that weekday's existing shuffle-bag cursor. Quote scheduling no longer writes predicted future history rows; only the immediate notification records a delivery.

**Tech Stack:** Dart / Flutter, `flutter_local_notifications`, existing `ScheduleCoreRemindersUseCase`, `QuoteSelector` shuffle-bag, `flutter_test`.

**Working directory:** `iacula_app/` inside the worktree (`.worktrees/quote-daily-repeat-rotation`). All `flutter`/`dart` commands run from there, prefixed with `fvm`.

---

## File Structure

- **Modify** `iacula_app/lib/features/notifications/domain/entities/reminder_event.dart` — add `repeatWeekly` flag (mirrors `repeatDaily`) through ctor, fields, `copyWith`, `toMap`, `fromMap`.
- **Modify** `iacula_app/lib/features/notifications/infrastructure/repositories/local_notification_scheduler_repository.dart` — map `repeatWeekly` → `DateTimeComponents.dayOfWeekAndTime`.
- **Create** `iacula_app/lib/features/notifications/domain/services/quote_slot_planner.dart` — pure helper computing daily slot clock-times from interval + active window + quiet hours.
- **Modify** `iacula_app/lib/features/notifications/application/use_cases/schedule_core_reminders_use_case.dart` — replace the quote-scheduling block (current lines ~134–248) with weekly-grid registration; drop history reuse/clear for quotes.
- **Create** `iacula_app/test/features/notifications/quote_slot_planner_test.dart` — unit tests for the planner.
- **Rewrite** `iacula_app/test/features/notifications/schedule_core_reminders_use_case_test.dart` — replace assertions tied to the old `now + i*interval` model with weekly-grid assertions; keep the Angelus tests.

---

## Task 1: Add `repeatWeekly` to `ReminderEvent`

**Files:**
- Modify: `iacula_app/lib/features/notifications/domain/entities/reminder_event.dart`
- Test: `iacula_app/test/features/notifications/reminder_event_repeat_weekly_test.dart` (create)

- [ ] **Step 1: Write the failing test**

Create `iacula_app/test/features/notifications/reminder_event_repeat_weekly_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';

void main() {
  test('repeatWeekly defaults to false and round-trips through map', () {
    const event = ReminderEvent(
      type: ReminderEventType.quoteInterval,
      title: 'Iacula',
      body: 'Glória ao Pai.',
      scheduledAt: null,
      withVibration: true,
      isAlarm: false,
    );
    expect(event.repeatWeekly, isFalse);

    final weekly = event.copyWith(repeatWeekly: true);
    expect(weekly.repeatWeekly, isTrue);

    final restored = ReminderEvent.fromMap(weekly.toMap());
    expect(restored.repeatWeekly, isTrue);
  });
}
```

Note: `scheduledAt` is `required DateTime` — replace `null` with `DateTime(2026, 1, 1)` (the const ctor cannot be const then; drop `const`). Use:

```dart
final event = ReminderEvent(
  type: ReminderEventType.quoteInterval,
  title: 'Iacula',
  body: 'Glória ao Pai.',
  scheduledAt: DateTime(2026, 1, 1),
  withVibration: true,
  isAlarm: false,
);
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/notifications/reminder_event_repeat_weekly_test.dart`
Expected: FAIL — `The named parameter 'repeatWeekly' isn't defined` / `repeatWeekly` getter missing.

- [ ] **Step 3: Add the field**

In `reminder_event.dart`, add to the constructor (after `this.repeatDaily = false,`):

```dart
    this.repeatWeekly = false,
```

Add the field (after `final bool repeatDaily;`):

```dart
  final bool repeatWeekly;
```

Add to `copyWith` params (after `bool? repeatDaily,`):

```dart
    bool? repeatWeekly,
```

And in the returned `ReminderEvent` (after `repeatDaily: repeatDaily ?? this.repeatDaily,`):

```dart
      repeatWeekly: repeatWeekly ?? this.repeatWeekly,
```

In `toMap` (after `'repeatDaily': repeatDaily,`):

```dart
      'repeatWeekly': repeatWeekly,
```

In `fromMap` (after `repeatDaily: map['repeatDaily'] == true,`):

```dart
      repeatWeekly: map['repeatWeekly'] == true,
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/features/notifications/reminder_event_repeat_weekly_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add iacula_app/lib/features/notifications/domain/entities/reminder_event.dart iacula_app/test/features/notifications/reminder_event_repeat_weekly_test.dart
git commit -m "feat(notifications): add repeatWeekly flag to ReminderEvent"
```

---

## Task 2: Map `repeatWeekly` to weekly OS repeat in the scheduler

**Files:**
- Modify: `iacula_app/lib/features/notifications/infrastructure/repositories/local_notification_scheduler_repository.dart:316`

This is an infrastructure mapping over the platform plugin; it has no unit test today (the plugin is not faked). Change is a one-line behavior extension verified by the use-case tests in Task 4 (the in-memory scheduler records the `ReminderEvent`, so `repeatWeekly` is asserted there).

- [ ] **Step 1: Change the repeat mapping**

Find (line ~316):

```dart
    final repeat = event.repeatDaily ? DateTimeComponents.time : null;
```

Replace with:

```dart
    final DateTimeComponents? repeat;
    if (event.repeatWeekly) {
      repeat = DateTimeComponents.dayOfWeekAndTime;
    } else if (event.repeatDaily) {
      repeat = DateTimeComponents.time;
    } else {
      repeat = null;
    }
```

- [ ] **Step 2: Verify it compiles**

Run: `fvm flutter analyze lib/features/notifications/infrastructure/repositories/local_notification_scheduler_repository.dart`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add iacula_app/lib/features/notifications/infrastructure/repositories/local_notification_scheduler_repository.dart
git commit -m "feat(notifications): map repeatWeekly to dayOfWeekAndTime OS repeat"
```

---

## Task 3: Create the `QuoteSlotPlanner` (pure slot-time helper)

**Files:**
- Create: `iacula_app/lib/features/notifications/domain/services/quote_slot_planner.dart`
- Test: `iacula_app/test/features/notifications/quote_slot_planner_test.dart`

**Contract:** Given an interval, an active window (start/end minutes-of-day), optional quiet hours, and a max-slots cap, return the list of slot times as minutes-of-day (whole minutes), walking from the window start in `interval` steps, skipping quiet-hours times, stopping at window end or the cap.

- [ ] **Step 1: Write the failing test**

Create `iacula_app/test/features/notifications/quote_slot_planner_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/services/quote_slot_planner.dart';

void main() {
  test('spreads interval slots across the default 08:00-22:00 window', () {
    final slots = QuoteSlotPlanner.slotMinutesOfDay(
      intervalMinutes: 180, // 3h
      windowStartMinutes: 8 * 60,
      windowEndMinutes: 22 * 60,
      quietHoursEnabled: false,
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
      maxSlots: 6,
    );
    expect(slots, [8 * 60, 11 * 60, 14 * 60, 17 * 60, 20 * 60]);
  });

  test('caps the number of slots at maxSlots', () {
    final slots = QuoteSlotPlanner.slotMinutesOfDay(
      intervalMinutes: 60,
      windowStartMinutes: 8 * 60,
      windowEndMinutes: 22 * 60,
      quietHoursEnabled: false,
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
      maxSlots: 6,
    );
    expect(slots.length, 6);
    expect(slots.first, 8 * 60);
  });

  test('skips slots that fall inside quiet hours', () {
    final slots = QuoteSlotPlanner.slotMinutesOfDay(
      intervalMinutes: 60,
      windowStartMinutes: 6 * 60,
      windowEndMinutes: 23 * 60,
      quietHoursEnabled: true,
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
      maxSlots: 6,
    );
    for (final minutes in slots) {
      final inQuiet = minutes >= 22 * 60 || minutes < 7 * 60;
      expect(inQuiet, isFalse, reason: 'slot $minutes inside quiet hours');
    }
  });

  test('returns at least one slot even with a huge interval', () {
    final slots = QuoteSlotPlanner.slotMinutesOfDay(
      intervalMinutes: 360,
      windowStartMinutes: 8 * 60,
      windowEndMinutes: 9 * 60,
      quietHoursEnabled: false,
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
      maxSlots: 6,
    );
    expect(slots, [8 * 60]);
  });

  test('returns empty when the whole window is quiet', () {
    final slots = QuoteSlotPlanner.slotMinutesOfDay(
      intervalMinutes: 60,
      windowStartMinutes: 23 * 60,
      windowEndMinutes: 23 * 60 + 30,
      quietHoursEnabled: true,
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
      maxSlots: 6,
    );
    expect(slots, isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/notifications/quote_slot_planner_test.dart`
Expected: FAIL — `QuoteSlotPlanner` not defined.

- [ ] **Step 3: Implement the planner**

Create `iacula_app/lib/features/notifications/domain/services/quote_slot_planner.dart`:

```dart
/// Default daily active window used when quiet hours are disabled.
const int kQuoteWindowStartMinutes = 8 * 60; // 08:00
const int kQuoteWindowEndMinutes = 22 * 60; // 22:00

/// Maximum quote notification slots per weekday. With a 7-weekday grid this
/// caps quote notifications at 7 * 6 = 42, leaving headroom under the iOS
/// 64-pending-notification limit for Angelus, alarms, and intentions.
const int kMaxQuoteSlotsPerWeekday = 6;

/// Computes the clock times (as minutes-of-day) at which quote notifications
/// should fire on any given weekday. Pure and deterministic for a given input.
final class QuoteSlotPlanner {
  const QuoteSlotPlanner._();

  static List<int> slotMinutesOfDay({
    required int intervalMinutes,
    required int windowStartMinutes,
    required int windowEndMinutes,
    required bool quietHoursEnabled,
    required String quietHoursStart,
    required String quietHoursEnd,
    required int maxSlots,
  }) {
    if (intervalMinutes <= 0 || windowEndMinutes <= windowStartMinutes) {
      return const <int>[];
    }

    final quietStart = _parseMinutes(quietHoursStart);
    final quietEnd = _parseMinutes(quietHoursEnd);

    final slots = <int>[];
    var cursor = windowStartMinutes;
    while (cursor <= windowEndMinutes && slots.length < maxSlots) {
      final isQuiet = quietHoursEnabled &&
          quietStart != null &&
          quietEnd != null &&
          _isWithinQuiet(cursor, quietStart, quietEnd);
      if (!isQuiet) {
        slots.add(cursor);
      }
      cursor += intervalMinutes;
    }
    return slots;
  }

  /// Quiet window may wrap past midnight (e.g. 22:00 -> 07:00).
  static bool _isWithinQuiet(int minutes, int start, int end) {
    if (start == end) return false;
    if (start < end) {
      return minutes >= start && minutes < end;
    }
    return minutes >= start || minutes < end;
  }

  static int? _parseMinutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/features/notifications/quote_slot_planner_test.dart`
Expected: PASS (all 5 tests).

- [ ] **Step 5: Commit**

```bash
git add iacula_app/lib/features/notifications/domain/services/quote_slot_planner.dart iacula_app/test/features/notifications/quote_slot_planner_test.dart
git commit -m "feat(notifications): add QuoteSlotPlanner for daily quote slot times"
```

---

## Task 4: Replace quote scheduling with the weekly grid in the use case

**Files:**
- Modify: `iacula_app/lib/features/notifications/application/use_cases/schedule_core_reminders_use_case.dart`
- Test: `iacula_app/test/features/notifications/schedule_core_reminders_use_case_test.dart` (rewrite quote tests; keep Angelus tests)

### 4a — Rewrite the use-case quote block

The immediate-notification block (lines ~81–132) and the Angelus block (lines ~250–281) stay **unchanged**. Replace the quote-scheduling block (everything from `// iOS allows at most 64...` at line ~134 through the `clearFromExcept`/`debugPrint` at line ~248) with the grid.

- [ ] **Step 1: Replace the block**

Remove lines ~134–248 (from `const iosScheduledLimit = 64;` through the `debugPrint('[ScheduleCoreRemindersUseCase] queued ...')`) and replace with:

```dart
    // Register a weekly grid of OS-owned repeating quote notifications:
    // (each weekday 1..7) x (each daily slot time). Each cell repeats weekly
    // via DateTimeComponents.dayOfWeekAndTime, so iOS fires the correct
    // weekday's quote even if the app is never reopened. Quote text comes from
    // the shuffle-bag fetcher called with a `now` on that weekday, so the right
    // quotes.json bucket is used and its cursor advances over time.
    final windowStart = settings.quietHoursEnabled
        ? _quietHoursWindowStart(settings)
        : kQuoteWindowStartMinutes;
    final windowEnd = settings.quietHoursEnabled
        ? _quietHoursWindowEnd(settings)
        : kQuoteWindowEndMinutes;

    final slotMinutes = QuoteSlotPlanner.slotMinutesOfDay(
      intervalMinutes: settings.intervalMinutes,
      windowStartMinutes: windowStart,
      windowEndMinutes: windowEnd,
      quietHoursEnabled: settings.quietHoursEnabled,
      quietHoursStart: settings.quietHoursStart,
      quietHoursEnd: settings.quietHoursEnd,
      maxSlots: kMaxQuoteSlotsPerWeekday,
    );

    for (var weekdayIndex = 0; weekdayIndex < 7; weekdayIndex++) {
      // Dart DateTime.weekday is 1=Mon..7=Sun. weekdayIndex 0..6 maps to that.
      final weekday = weekdayIndex + 1;
      for (var slotIndex = 0; slotIndex < slotMinutes.length; slotIndex++) {
        final minutesOfDay = slotMinutes[slotIndex];
        final fireAt = _nextOccurrenceOnWeekday(
          current,
          weekday,
          minutesOfDay ~/ 60,
          minutesOfDay % 60,
        );

        final quote = await fetchNonRepeatingQuote(
          language: settings.language,
          slot: fireAt,
        );

        final scheduledId = quoteScheduleIdBase +
            (weekdayIndex * kMaxQuoteSlotsPerWeekday) +
            slotIndex;

        await _scheduler.scheduleWithId(
          scheduledId,
          ReminderEvent(
            type: ReminderEventType.quoteInterval,
            title: 'Iacula',
            body: quote.text,
            scheduledAt: fireAt,
            withVibration: true,
            isAlarm: false,
            repeatWeekly: true,
            routeTarget: NotificationRouteTarget.home,
            scheduledId: scheduledId,
            quoteTheme: quote.theme,
            quoteSeason: quote.season.name,
            quoteFeastName: quote.feastName,
            quoteImagePath: quote.imagePath,
          ),
        );
      }
    }

    debugPrint(
      '[ScheduleCoreRemindersUseCase] registered weekly grid: '
      '${slotMinutes.length} slots x 7 weekdays',
    );
```

- [ ] **Step 2: Add the imports and helper methods**

At the top of the file, add (with the other relative imports):

```dart
import '../../domain/services/quote_slot_planner.dart';
```

Remove the now-unused `import 'dart:io' show Platform;` and `import 'dart:math' show min;` if no other code in the file uses them (search the file for `Platform.` and `min(` — if none remain, delete those two imports).

Add these private methods inside the class, after `_isDateWithinEasterSeason`:

```dart
  /// Active-window start derived from quiet hours: quotes resume at quietHoursEnd.
  int _quietHoursWindowStart(Settings settings) {
    final end = _parseHhmm(settings.quietHoursEnd) ?? kQuoteWindowStartMinutes;
    return end;
  }

  /// Active-window end derived from quiet hours: quotes pause at quietHoursStart.
  int _quietHoursWindowEnd(Settings settings) {
    final start = _parseHhmm(settings.quietHoursStart) ?? kQuoteWindowEndMinutes;
    return start;
  }

  int? _parseHhmm(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }

  /// Next DateTime at the given weekday (1=Mon..7=Sun) and clock time, at or
  /// after [from]. Used as the first fire time for a weekly-repeating slot.
  DateTime _nextOccurrenceOnWeekday(
    DateTime from,
    int weekday,
    int hour,
    int minute,
  ) {
    var candidate = DateTime(from.year, from.month, from.day, hour, minute);
    final dayDelta = (weekday - candidate.weekday + 7) % 7;
    candidate = candidate.add(Duration(days: dayDelta));
    if (!candidate.isAfter(from)) {
      candidate = candidate.add(const Duration(days: 7));
    }
    return candidate;
  }
```

Note: when quiet hours wrap past midnight (start 22:00, end 07:00), `_quietHoursWindowStart` returns 07:00 (420) and `_quietHoursWindowEnd` returns 22:00 (1320) — a valid 07:00–22:00 active window. The planner additionally skips any slot still inside the quiet window, so non-wrapping quiet configs are also handled.

- [ ] **Step 3: Verify it compiles**

Run: `fvm flutter analyze lib/features/notifications/application/use_cases/schedule_core_reminders_use_case.dart`
Expected: No errors. (If `listFromUntilEndOfDay`/`clearFromExcept` are now unused on the history repo interface, that is fine — they remain on the interface for the immediate-delivery path and other callers; do not remove them.)

### 4b — Rewrite the use-case tests

The existing quote tests assert the removed `now + i*interval` model (65 events, ids 9000–9063, per-slot history writes, reuse/orphan cleanup). Replace them. Keep all four Angelus tests unchanged.

- [ ] **Step 4: Replace the quote tests**

In `iacula_app/test/features/notifications/schedule_core_reminders_use_case_test.dart`, delete these tests (the quote-model ones):
- `schedules quote reminders and writes only immediate history entry`
- `showImmediate false does not enqueue immediate notification id 8999`
- `showImmediate false still writes history for scheduled quotes`
- `earliest queued quote fires at now + intervalMinutes`
- `rebuilding preserves history entry delivered at current notification time`
- `quiet hours skip queued quote slots inside the quiet window`
- `rebuild reuses existing history entries so OS notifications match the tab`
- `interval change removes orphaned history entries and fills new slots`
- `past history entries are never deleted during rebuild`

Keep these tests (do not touch):
- `Angelus is not scheduled when noon is inside quiet hours`
- `Angelus shows Regina Caeli during Easter even when liturgical toggle is off`
- `Angelus uses local Easter fallback when caller passes isEasterSeason false`

Add these new tests (inside `main()`, alongside the kept Angelus tests). They reuse the existing `_InMemoryNotificationHistoryRepository` helper already in the file:

```dart
  test('registers a weekly grid of repeating quote notifications', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();

    final useCase = ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        // Encode the weekday so we can assert the right bucket was used.
        final weekday = (now.weekday % 7) + 1;
        return Quote(
          text: 'weekday-$weekday',
          dayOfWeek: weekday,
          theme: 'tema',
          season: LiturgicalSeason.ordinary,
        );
      },
      notificationHistoryRepository: history,
      lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    );

    // interval 3h, default window 08:00-22:00 -> 5 slots/weekday -> 35 cells.
    final settings = Settings.defaults.copyWith(intervalMinutes: 180);
    await useCase(settings, now: DateTime(2026, 2, 21, 10, 0),
        showImmediate: false);

    final quoteEvents = scheduler.events
        .where((e) => e.type == ReminderEventType.quoteInterval)
        .toList();

    expect(quoteEvents, hasLength(35));
    expect(quoteEvents.every((e) => e.repeatWeekly), isTrue);

    // Ids are stable, unique, and within the reserved range.
    final ids = quoteEvents.map((e) => e.scheduledId!).toSet();
    expect(ids.length, 35);
    expect(ids.every((id) => id >= 9000 && id < 9000 + 7 * 6), isTrue);
  });

  test('each grid cell draws from its own weekday bucket', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();

    final useCase = ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        final weekday = (now.weekday % 7) + 1;
        return Quote(
          text: 'weekday-$weekday',
          dayOfWeek: weekday,
          theme: 'tema',
          season: LiturgicalSeason.ordinary,
        );
      },
      notificationHistoryRepository: history,
      lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    );

    await useCase(Settings.defaults.copyWith(intervalMinutes: 180),
        now: DateTime(2026, 2, 21, 10, 0), showImmediate: false);

    final quoteEvents = scheduler.events
        .where((e) => e.type == ReminderEventType.quoteInterval);

    for (final event in quoteEvents) {
      final firedWeekday = (event.scheduledAt.weekday % 7) + 1;
      expect(event.body, 'weekday-$firedWeekday',
          reason: 'cell firing on weekday $firedWeekday used the wrong bucket');
    }

    // All 7 weekday buckets are represented across the grid.
    final bodies = quoteEvents.map((e) => e.body).toSet();
    expect(bodies, {
      for (var weekday = 1; weekday <= 7; weekday++) 'weekday-$weekday',
    });
  });

  test('quote scheduling writes no future history rows', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();

    final useCase = ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        return const Quote(
          text: 'Q',
          dayOfWeek: 1,
          theme: 't',
          season: LiturgicalSeason.ordinary,
        );
      },
      notificationHistoryRepository: history,
      lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    );

    await useCase(Settings.defaults.copyWith(intervalMinutes: 180),
        now: DateTime(2026, 2, 21, 10, 0), showImmediate: false);

    // showImmediate:false -> no immediate delivery row, and the grid writes none.
    expect(history.entries, isEmpty);
  });

  test('immediate notification still records exactly one delivery', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();

    final useCase = ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        return const Quote(
          text: 'Immediate quote',
          dayOfWeek: 1,
          theme: 't',
          season: LiturgicalSeason.ordinary,
        );
      },
      notificationHistoryRepository: history,
      lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    );

    final now = DateTime(2026, 2, 21, 10, 0);
    await useCase(Settings.defaults.copyWith(intervalMinutes: 180), now: now);

    expect(history.entries, hasLength(1));
    expect(history.entries.single.quoteText, 'Immediate quote');
    expect(history.entries.single.deliveredAt, now);

    // The immediate notification keeps id 8999 and is not weekly-repeating.
    final immediate = scheduler.events.firstWhere(
      (e) => e.scheduledId == 8999,
    );
    expect(immediate.repeatWeekly, isFalse);
  });

  test('re-running the pass replaces the same ids (idempotent)', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final history = _InMemoryNotificationHistoryRepository();

    var fetchCount = 0;
    final useCase = ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        fetchCount++;
        return Quote(
          text: 'Q-$fetchCount',
          dayOfWeek: 1,
          theme: 't',
          season: LiturgicalSeason.ordinary,
        );
      },
      notificationHistoryRepository: history,
      lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    );

    final settings = Settings.defaults.copyWith(intervalMinutes: 180);
    final now = DateTime(2026, 2, 21, 10, 0);

    await useCase(settings, now: now, showImmediate: false);
    final firstRunIds = scheduler.events
        .where((e) => e.type == ReminderEventType.quoteInterval)
        .map((e) => e.scheduledId)
        .toSet();

    await useCase(settings, now: now, showImmediate: false);
    final secondRunIds = scheduler.events
        .where((e) => e.type == ReminderEventType.quoteInterval)
        .map((e) => e.scheduledId)
        .toSet();

    // Same id set both runs: the grid replaces in place rather than piling up.
    expect(secondRunIds, firstRunIds);
  });
```

- [ ] **Step 5: Run the full notifications test file**

Run: `fvm flutter test test/features/notifications/schedule_core_reminders_use_case_test.dart`
Expected: PASS — 5 new quote tests + 3 kept Angelus tests = 8 passing.

- [ ] **Step 6: Commit**

```bash
git add iacula_app/lib/features/notifications/application/use_cases/schedule_core_reminders_use_case.dart iacula_app/test/features/notifications/schedule_core_reminders_use_case_test.dart
git commit -m "feat(notifications): register quotes as a weekly grid of OS repeats"
```

---

## Task 5: Full-suite regression and analyzer

**Files:** none (verification only)

- [ ] **Step 1: Analyze the whole project**

Run: `fvm flutter analyze`
Expected: No errors. If other tests/files referenced the removed quote behavior (search results from `grep -rn "9063\|now + i\|listFromUntilEndOfDay" test/`), fix or update them to the new model in this step, then re-run.

- [ ] **Step 2: Run the full test suite**

Run: `fvm flutter test`
Expected: All tests pass. Investigate and fix any failure tied to the old quote model (do not skip).

- [ ] **Step 3: Commit any regression fixes**

```bash
git add -A
git commit -m "test(notifications): align remaining tests with weekly-grid quotes"
```

(Skip this commit if `git status` is clean.)

---

## Self-Review notes (spec coverage)

- Goal 1 (reliability): Task 2 + Task 4 register cells with `repeatWeekly` → `dayOfWeekAndTime`. ✓
- Goal 2 (weekday emphasis offline): Task 4 grid loops weekdays 1–7, fetcher called with weekday-aligned `now`; asserted by "each grid cell draws from its own weekday bucket". ✓
- Goal 3 (long-run coverage): unchanged shuffle-bag fetcher advances per-weekday cursors each pass. ✓
- Decision 1 (record actual deliveries only): Task 4 removes per-slot history writes and the reuse/clear machinery; asserted by "quote scheduling writes no future history rows" + "immediate notification still records exactly one delivery". ✓
- Decision 2 (`08:00–22:00` window): `kQuoteWindowStartMinutes`/`kQuoteWindowEndMinutes` in Task 3. ✓
- Decision 3 (`kMaxQuoteSlotsPerWeekday = 6`): Task 3 constant; budget 7×6=42 asserted by id-range check in Task 4. ✓
- Budget safety: ids confined to `[9000, 9042)`; Angelus (200) and immediate (8999) unaffected. ✓
