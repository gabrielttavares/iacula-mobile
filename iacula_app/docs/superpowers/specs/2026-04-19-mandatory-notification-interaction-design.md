# Mandatory Notification Interaction — Design Spec

## Goal

Make every Iacula notification require explicit user interaction ("Rezar agora" or "Adiar 1h") before it can be dismissed. If the user swipes the notification away without interacting, the system treats it as an implicit 1-hour snooze and reschedules automatically.

## Scope

Applies to all active notification types:
- `quoteInterval` — jaculatória reminders
- `angelusNoon` — Angelus noon reminder
- `customPhrase` — user-created phrases
- `prayerIntentionReminder` — prayer intention reminders

**Out of scope:** Liturgy of Hours (laudes, vespers, compline, oraMedia) — not in app's current scope.

## Chosen Approach

**Fullscreen Intent + Action Buttons + Dismiss-as-Snooze** (Approach A from brainstorming).

## Implementation Feasibility Update

The current dependency, `flutter_local_notifications` 19.5.0, supports the explicit-interaction portion of this strategy:

- Android action buttons.
- Android fullscreen intent.
- iOS notification categories with action buttons.
- iOS time-sensitive interruption level.

It does **not** expose the full swipe-dismiss-as-snooze behavior:

- Android has native `deleteIntent`, but `flutter_local_notifications` does not expose a `deleteIntent`/dismiss callback for scheduled notifications.
- iOS has `customDismissAction`, but the plugin's iOS implementation ignores `UNNotificationDismissActionIdentifier` instead of forwarding it to Dart.

Therefore the current implementation ships the strongest plugin-compatible behavior first: "Rezar agora" + "Adiar 1h" on every in-scope notification, fullscreen/time-sensitive presentation, and one-hour snooze handling. Swipe-dismiss-as-snooze remains a follow-up requiring either a plugin fork, a custom native scheduler, or an in-app unacknowledged fallback.

## Platform Behavior

### Android

1. **Fullscreen Intent:** All notifications set `fullScreenIntent: true`. When the phone is locked or idle, Android launches a fullscreen activity. When the phone is unlocked and in use, the notification appears in the shade with heads-up display.
2. **Action Buttons:** Two notification actions registered: "Rezar agora" and "Adiar 1h".
3. **Dismiss Detection:** Native Android supports `deleteIntent`, but this is not exposed by `flutter_local_notifications` 19.5.0. Implementing swipe-away as implicit snooze requires a plugin fork/custom native scheduler.
4. **Permission:** `USE_FULL_SCREEN_INTENT` already declared in `AndroidManifest.xml`.

### iOS

1. **Time-Sensitive Interruption Level:** All notifications use `interruptionLevel: .timeSensitive`. This causes persistent banners and bypasses Focus/DND modes (with user consent at the OS level). True fullscreen takeover is not available on iOS.
2. **Action Buttons:** UNNotificationCategory with two `UNNotificationAction`s: "Rezar agora" and "Adiar 1h".
3. **Dismiss Detection:** iOS can request dismiss callbacks through `customDismissAction`, but `flutter_local_notifications` 19.5.0 drops `UNNotificationDismissActionIdentifier`. Implementing swipe-away as implicit snooze requires a plugin fork/custom native scheduler or the in-app fallback.
4. **Notification Category:** Register a `UNNotificationCategory` with the two actions and `customDismissAction`; the action buttons are active now, and dismiss forwarding is a follow-up plugin/native change.

## Architecture

### Notification Action Buttons

Current `NotificationActionEvent` already defines `openAction` and `snooze10Action`. Changes:

- Replace `snooze10Action` with `snooze1hAction` (snooze duration: 1 hour)
- Rename `openAction` to `prayNowAction` for clarity
- Add `dismissAction` constant for dismiss-as-snooze events

### Action Registration

`flutter_local_notifications` supports action buttons via `AndroidNotificationDetails.actions` and iOS notification categories. Add:

```dart
// Android actions on every notification
AndroidNotificationAction('pray_now', 'Rezar agora', showsUserInterface: true)
AndroidNotificationAction('snooze_1h', 'Adiar 1h')
```

```dart
// iOS category registered at initialization
DarwinNotificationCategory(
  'iacula_reminder',
  actions: [
    DarwinNotificationAction.plain('pray_now', 'Rezar agora', options: {DarwinNotificationActionOption.foreground}),
    DarwinNotificationAction.plain('snooze_1h', 'Adiar 1h'),
  ],
  options: {DarwinNotificationCategoryOption.customDismissAction},
)
```

### Dismiss Detection — Android

Follow-up native implementation: a Kotlin `BroadcastReceiver` (`NotificationDismissReceiver`) is registered as the `deleteIntent` for each notification.

When triggered:
1. Extracts the `ReminderEvent` payload from the intent extras.
2. Sends a platform channel message to Flutter with the event data.
3. Flutter side: `HandleNotificationActionUseCase` reschedules the event 1 hour later.

If Flutter engine is not running (app killed), the receiver stores the dismissed event in `SharedPreferences`. On next Flutter init, the app reads and processes pending dismissed events.

### Dismiss Detection — iOS

Follow-up native/plugin implementation:
- Register the notification category with `customDismissAction`.
- The `UNUserNotificationCenter` delegate's dismiss callback fires when the user swipes away.
- Patch or replace `flutter_local_notifications` so it surfaces dismiss responses via `onDidReceiveNotificationResponse`.

For iOS < 16 (fallback):
- Add `acknowledged` boolean column to `notification_history_entries` table.
- On notification delivery, mark entry as `acknowledged = false`.
- On action tap ("Rezar agora" or "Adiar 1h"), mark as `acknowledged = true`.
- On app open, query unacknowledged entries. If any exist, show in-app modal with the notification content and same two action buttons.

### HandleNotificationActionUseCase Changes

Updated action handling:

| actionId | Behavior |
|----------|----------|
| `pray_now` | Navigate to `NotificationDetailScreen`, mark as acknowledged |
| `snooze_1h` | Reschedule same event +1 hour, mark as acknowledged |
| `dismiss` (swipe-away) | Reschedule same event +1 hour (implicit snooze) |

### Notification History Schema Change

Add column to `notification_history_entries`:

```sql
ALTER TABLE notification_history_entries ADD COLUMN acknowledged INTEGER NOT NULL DEFAULT 0;
```

- `0` = delivered but not interacted with
- `1` = user tapped "Rezar agora" or "Adiar 1h" (or dismiss-reschedule processed)

### In-App Unacknowledged Modal

On app launch / resume, `ShellScreen` checks for unacknowledged notification history entries. If found:

- Show a fullscreen `CupertinoAlertDialog` or a custom modal sheet
- Display the notification content (quote text, theme, season)
- Two buttons: "Rezar agora" (navigate to detail) + "Adiar 1h" (reschedule)
- Modal is not dismissible by tapping outside

This would serve as the safety net for:
- iOS < 16 where no dismiss callback exists
- Edge cases where the BroadcastReceiver/delegate didn't fire (process killed, etc.)

### Snooze Loop Prevention

To prevent infinite snooze chains:

- Add `snoozeCount` field to `ReminderEvent` (default 0).
- Each snooze (explicit or implicit) increments the count.
- After 3 consecutive snoozes of the same notification, stop rescheduling and mark as acknowledged.
- Reset count when the user taps "Rezar agora" or when a new scheduled notification fires.

## File Changes Summary

| File | Change |
|------|--------|
| `notification_action_event.dart` | Add `prayNowAction`, `snooze1hAction`, and `dismissAction` |
| `reminder_event.dart` | Add `snoozeCount` field |
| `local_notification_scheduler_repository.dart` | Add action buttons to all notifications, register iOS category, set fullScreenIntent for all types |
| `handle_notification_action_use_case.dart` | Handle `pray_now`, `snooze_1h`, `dismiss` actions; snooze loop prevention |
| `notification_history_entry.dart` | Follow-up: add `acknowledged` field for in-app fallback |
| `sqlite_notification_history_repository.dart` | Follow-up: support `acknowledged` column, query unacknowledged |
| `notification_history_repository.dart` | Follow-up: add `markAcknowledged()`, `listUnacknowledged()` |
| `app_database.dart` | Follow-up: migration to add `acknowledged` column |
| `shell_screen.dart` | Follow-up: check unacknowledged on resume, show modal |
| `AndroidManifest.xml` | Follow-up native path: register `NotificationDismissReceiver` |
| **New:** `android/.../NotificationDismissReceiver.kt` | Follow-up native path: BroadcastReceiver for delete intent |
| **New:** `android/.../NotificationDismissChannel.kt` | Follow-up native path: platform channel to relay dismissed events to Flutter |
| `ios/Runner/AppDelegate.swift` | Follow-up native path: forward dismiss callbacks if plugin is patched/replaced |

## Platform Compliance

### Android
- `USE_FULL_SCREEN_INTENT`: Already declared. On Android 14+, apps targeting SDK 34+ need user to grant this in settings — `flutter_local_notifications` handles the permission check.
- Action buttons: Fully supported, no restrictions.
- `deleteIntent`: Standard Android API, no policy concerns, but not exposed by the current plugin.

### iOS
- `timeSensitive` interruption level: Requires the app to have the Time Sensitive Notifications entitlement (automatic for local notifications since iOS 15). User can disable per-app in Settings.
- `customDismissAction`: Available since iOS 15. No App Store review concerns, but the current plugin does not forward dismiss callbacks to Dart.
- No true fullscreen notification on iOS — this is an OS-level limitation. The combination of time-sensitive + action buttons + in-app modal provides the strongest available enforcement.

## Acceptance Criteria

### AC-1: Action Buttons Present
**Given** any notification fires (quoteInterval, angelusNoon, customPhrase, prayerIntentionReminder)
**When** the notification appears in the shade or lockscreen
**Then** it displays exactly two action buttons: "Rezar agora" and "Adiar 1h"

### AC-2: "Rezar agora" Opens Detail Screen
**Given** a notification with action buttons is visible
**When** the user taps "Rezar agora"
**Then** the app opens and navigates to `NotificationDetailScreen` with the notification's content
**And** the notification history entry is marked as acknowledged

### AC-3: "Adiar 1h" Reschedules
**Given** a notification with action buttons is visible
**When** the user taps "Adiar 1h"
**Then** the same notification is rescheduled to fire 1 hour from now
**And** the original notification is dismissed
**And** the notification history entry is marked as acknowledged

### AC-4: Fullscreen Intent on Idle/Locked
**Given** the phone is locked or idle
**When** a notification fires
**Then** a fullscreen activity/alert appears requiring user interaction
**And** (Android) the fullscreen activity shows the notification content with "Rezar agora" and "Adiar 1h" buttons

### AC-5: Swipe-Away Triggers Implicit Snooze (Android)
**Given** a notification is in the shade on Android
**When** the user swipes it away without tapping an action
**Then** the same notification is automatically rescheduled 1 hour later

### AC-6: Swipe-Away Triggers Implicit Snooze (iOS 16+)
**Given** a notification is on screen on iOS 16+
**When** the user dismisses it without tapping an action
**Then** the same notification is automatically rescheduled 1 hour later

### AC-7: In-App Modal for Unacknowledged (iOS < 16 fallback + safety net)
**Given** there are unacknowledged notification history entries
**When** the user opens the app
**Then** a non-dismissible modal appears showing the notification content
**And** the modal has "Rezar agora" and "Adiar 1h" buttons
**And** tapping either button dismisses the modal and processes the action

### AC-8: Snooze Loop Prevention
**Given** a notification has been snoozed (explicitly or implicitly) 3 consecutive times
**When** the snooze would trigger a 4th reschedule
**Then** the notification is NOT rescheduled
**And** it is marked as acknowledged

### AC-9: iOS Time-Sensitive
**Given** the app is running on iOS 15+
**When** any notification fires
**Then** it uses `interruptionLevel: .timeSensitive` to bypass Focus mode

### AC-10: Existing Behavior Preserved
**Given** the app has existing notification scheduling for all in-scope types
**When** this feature is implemented
**Then** all existing scheduling logic, quiet hours, exact alarm fallback, and notification history recording continue to work unchanged
