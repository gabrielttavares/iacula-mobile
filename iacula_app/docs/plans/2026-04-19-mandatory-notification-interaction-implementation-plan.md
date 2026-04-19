# Mandatory Notification Interaction Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add the strongest cross-platform notification interaction pattern available in the current Flutter stack: every in-scope reminder shows "Rezar agora" and "Adiar 1h", opens the dedicated notification detail flow, and uses fullscreen/time-sensitive presentation where the OS allows it.

**Architecture:** Keep scheduling inside `LocalNotificationSchedulerRepository`, because all reminder types already converge there. Use `flutter_local_notifications` actions for Android and Darwin categories for iOS. Treat swipe-dismiss as a documented platform gap for the current plugin: Android `deleteIntent` is not exposed by `flutter_local_notifications` 19.5.0, and the iOS plugin ignores `UNNotificationDismissActionIdentifier`, so dismiss-as-snooze requires a later native scheduler/plugin fork or an in-app unacknowledged fallback.

**Tech Stack:** Flutter, Dart, Riverpod, `flutter_local_notifications` 19.5.0, Android notification actions, iOS `DarwinNotificationCategory`, Flutter widget/unit tests.

---

### Task 1: Update Action Contract

**Files:**
- Modify: `lib/features/notifications/domain/entities/notification_action_event.dart`
- Modify: `lib/features/notifications/domain/entities/reminder_event.dart`
- Test: `test/features/notifications/notification_action_event_test.dart`

**Step 1: Write the failing test**

Add a test that serializes a `ReminderEvent` with `snoozeCount: 2` and restores it with fallback action `NotificationActionEvent.snooze1hAction`.

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/notifications/notification_action_event_test.dart`

Expected: FAIL because `snooze1hAction` and `snoozeCount` do not exist.

**Step 3: Write minimal implementation**

Add:
- `prayNowAction = 'pray_now'`
- `snooze1hAction = 'snooze_1h'`
- `dismissAction = 'dismiss'`
- Deprecated aliases for old action IDs if needed during migration.
- `ReminderEvent.snoozeCount`, `copyWith`, `toMap`, and `fromMap`.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/notifications/notification_action_event_test.dart`

Expected: PASS.

### Task 2: Change Snooze Behavior to 1 Hour

**Files:**
- Modify: `lib/features/notifications/application/use_cases/handle_notification_action_use_case.dart`
- Test: `test/features/notifications/handle_notification_action_use_case_test.dart`

**Step 1: Write the failing test**

Add tests for:
- `snooze_1h` schedules exactly one event about 1 hour from now, with `repeatDaily: false`.
- `dismiss` uses the same 1-hour snooze path.
- A fourth consecutive snooze (`snoozeCount >= 3`) does not reschedule.

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/notifications/handle_notification_action_use_case_test.dart`

Expected: FAIL because only `snooze_10` exists.

**Step 3: Write minimal implementation**

Handle `snooze_1h`, `dismiss`, and the legacy `snooze_10` ID through one private snooze method. Increment `snoozeCount`. Return `false` for snooze/dismiss actions so navigation does not open.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/notifications/handle_notification_action_use_case_test.dart`

Expected: PASS.

### Task 3: Add Platform Notification Actions

**Files:**
- Modify: `lib/features/notifications/infrastructure/repositories/local_notification_scheduler_repository.dart`
- Test: `test/features/notifications/local_notification_scheduler_repository_test.dart`

**Step 1: Write the failing test**

Update Android detail tests to expect exactly two actions:
- ID `pray_now`, title `Rezar agora`, `showsUserInterface: true`
- ID `snooze_1h`, title `Adiar 1h`, `showsUserInterface: false`

Update iOS detail tests to expect:
- all in-scope notifications use `InterruptionLevel.timeSensitive`
- category identifier `iacula_reminder`

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/notifications/local_notification_scheduler_repository_test.dart`

Expected: FAIL because actions/category/time-sensitive are missing for non-alarm reminders.

**Step 3: Write minimal implementation**

Add static constants/helpers:
- `reminderCategoryIdentifier = 'iacula_reminder'`
- `androidActions`
- `darwinCategories`
- `isMandatoryInteractionType(ReminderEventType type)`

For in-scope types (`quoteInterval`, `angelusNoon`, `customPhrase`, `prayerIntentionReminder`):
- Android: `fullScreenIntent: true`, `category: alarm`, `actions: androidActions`
- iOS: `interruptionLevel: timeSensitive`, `categoryIdentifier: iacula_reminder`

Register the Darwin category in `initialize`.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/notifications/local_notification_scheduler_repository_test.dart`

Expected: PASS.

### Task 4: Keep Notification Tap Routing Working

**Files:**
- Modify: `lib/app/app.dart`
- Test: existing notification routing tests

**Step 1: Review current routing**

Current app routing treats any non-snooze action as open. That is compatible with `pray_now`, default notification tap, and legacy `open_now`.

**Step 2: Run focused routing tests**

Run:
`flutter test test/features/notifications/notification_deeplink_routing_test.dart test/features/notifications/notification_action_event_test.dart`

Expected: PASS.

### Task 5: Document Native Dismiss Gap

**Files:**
- Modify: `docs/superpowers/specs/2026-04-19-mandatory-notification-interaction-design.md`

**Step 1: Update feasibility section**

Document that current plugin cannot implement swipe-dismiss-as-snooze directly:
- Android has OS-level `deleteIntent`, but the plugin does not expose it.
- iOS supports `customDismissAction`, but plugin 19.5.0 drops dismiss responses.

**Step 2: Add follow-up implementation options**

Add explicit options:
- fork/patch `flutter_local_notifications`
- replace local notification posting with native scheduler for Android/iOS
- add in-app unacknowledged modal as plugin-compatible safety net

### Task 6: Final Verification

**Files:**
- All modified files

**Step 1: Format changed Dart files**

Run:
`dart format lib/features/notifications/domain/entities/notification_action_event.dart lib/features/notifications/domain/entities/reminder_event.dart lib/features/notifications/application/use_cases/handle_notification_action_use_case.dart lib/features/notifications/infrastructure/repositories/local_notification_scheduler_repository.dart test/features/notifications/notification_action_event_test.dart test/features/notifications/handle_notification_action_use_case_test.dart test/features/notifications/local_notification_scheduler_repository_test.dart`

**Step 2: Run focused tests**

Run:
`flutter test test/features/notifications/notification_action_event_test.dart test/features/notifications/handle_notification_action_use_case_test.dart test/features/notifications/local_notification_scheduler_repository_test.dart test/features/notifications/notification_deeplink_routing_test.dart`

Expected: PASS.

**Step 3: Run analyzer**

Run: `flutter analyze`

Expected: no new issues from this feature.
