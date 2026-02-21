# Mobile Parity (iOS/Android) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build Flutter mobile parity with desktop quote/prayer/notification behavior, polished modern UI, and offline-safe assets.

**Architecture:** Keep the existing clean feature layering and evolve domain models/use cases to desktop parity. Notification routing becomes payload-driven (Home for quote, Prayer for Angelus/Regina Caeli), and Home displays the last delivered quote card with desktop-like composition.

**Tech Stack:** Flutter, Riverpod, flutter_local_notifications, sqflite, Isar, flutter_test.

**Related skills:** @test-driven-development @verification-before-completion

---

### Task 1: Add Liturgical Context Parity Model

**Files:**
- Create: `lib/features/liturgical/domain/liturgical_context.dart`
- Modify: `lib/features/liturgical/domain/services/liturgical_season_service.dart`
- Modify: `lib/features/liturgical/infrastructure/services/remote_liturgical_season_service.dart`
- Test: `test/features/liturgical/remote_liturgical_context_service_test.dart`

**Step 1: Write the failing test**

```dart
test('returns liturgical context with feast/rank/api quotes', () async {
  // mock response with liturgia/cor + antifonas/oracoes/salmo
  // expect context.rank, context.feastName, context.apiQuotes
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/liturgical/remote_liturgical_context_service_test.dart -r expanded`
Expected: FAIL because `LiturgicalContext`/`getCurrentContext` are missing.

**Step 3: Write minimal implementation**

- Introduce `LiturgicalContext` model (season, rank, feast, feastName, apiQuotes).
- Extend season service interface with `getCurrentContext`.
- Map remote API payload to context fields.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/liturgical/remote_liturgical_context_service_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add test/features/liturgical/remote_liturgical_context_service_test.dart \
  lib/features/liturgical/domain/liturgical_context.dart \
  lib/features/liturgical/domain/services/liturgical_season_service.dart \
  lib/features/liturgical/infrastructure/services/remote_liturgical_season_service.dart
git commit -m "feat(liturgical): add context parity model"
```

### Task 2: Add Feast-Aware Quote Domain Contract

**Files:**
- Modify: `lib/features/quotes/domain/entities/quote.dart`
- Modify: `lib/features/quotes/domain/repositories/quote_content_repository.dart`
- Modify: `lib/features/quotes/infrastructure/repositories/asset_quote_content_repository.dart`
- Test: `test/features/quotes/quote_content_repository_test.dart`

**Step 1: Write the failing test**

```dart
test('loads feast quotes and feast image path when feast slug exists', () async {
  // expect repository methods return curated feast quotes and image path
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/quotes/quote_content_repository_test.dart -r expanded`
Expected: FAIL due missing repository methods.

**Step 3: Write minimal implementation**

- Add optional fields to `Quote`: `feast`, `feastName`.
- Add repository methods: `loadFeastQuotes`, `getFeastImagePath`.
- Implement asset-path lookup + graceful fallback in asset repository.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/quotes/quote_content_repository_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add test/features/quotes/quote_content_repository_test.dart \
  lib/features/quotes/domain/entities/quote.dart \
  lib/features/quotes/domain/repositories/quote_content_repository.dart \
  lib/features/quotes/infrastructure/repositories/asset_quote_content_repository.dart
git commit -m "feat(quotes): add feast-aware quote contract"
```

### Task 3: Port Desktop Merge+Dedup Quote Selection Logic

**Files:**
- Modify: `lib/features/quotes/application/use_cases/get_next_quote_use_case.dart`
- Test: `test/features/quotes/get_next_quote_parity_use_case_test.dart`

**Step 1: Write the failing test**

```dart
test('prioritizes merged feast pool and deduplicates api+curated quotes', () async {
  // fixture: repeated quotes with accents/punctuation variants
  // expect deduped ordered output and feast metadata present
});

test('falls back to seasonal quotes when feast pool is empty', () async {
  // expect seasonal quote path
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/quotes/get_next_quote_parity_use_case_test.dart -r expanded`
Expected: FAIL because current use case does not merge feast/api quotes.

**Step 3: Write minimal implementation**

- Fetch `LiturgicalContext` from season service.
- Build merged quote pool with desktop-style normalized dedup.
- Apply feast image priority, seasonal image fallback.
- Persist indices as before.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/quotes/get_next_quote_parity_use_case_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add test/features/quotes/get_next_quote_parity_use_case_test.dart \
  lib/features/quotes/application/use_cases/get_next_quote_use_case.dart
git commit -m "feat(quotes): port desktop feast merge and dedup rules"
```

### Task 4: Add Last Delivered Card Snapshot for Home

**Files:**
- Create: `lib/features/notifications/domain/entities/last_delivered_card.dart`
- Create: `lib/features/notifications/domain/repositories/last_delivered_card_repository.dart`
- Create: `lib/features/notifications/infrastructure/repositories/sqlite_last_delivered_card_repository.dart`
- Modify: `lib/core/storage/sqlite/app_database.dart`
- Modify: `lib/core/bootstrap/app_bootstrap.dart`
- Test: `test/features/notifications/sqlite_last_delivered_card_repository_test.dart`

**Step 1: Write the failing test**

```dart
test('persists and reads last delivered quote card snapshot', () async {
  // save snapshot, reload, expect same quote/image/season/feast label
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/notifications/sqlite_last_delivered_card_repository_test.dart -r expanded`
Expected: FAIL due missing table/repository.

**Step 3: Write minimal implementation**

- Add SQLite table for last delivered card.
- Implement repository save/load.
- Wire repository through bootstrap/providers.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/notifications/sqlite_last_delivered_card_repository_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add test/features/notifications/sqlite_last_delivered_card_repository_test.dart \
  lib/features/notifications/domain/entities/last_delivered_card.dart \
  lib/features/notifications/domain/repositories/last_delivered_card_repository.dart \
  lib/features/notifications/infrastructure/repositories/sqlite_last_delivered_card_repository.dart \
  lib/core/storage/sqlite/app_database.dart \
  lib/core/bootstrap/app_bootstrap.dart
git commit -m "feat(notifications): persist last delivered card snapshot"
```

### Task 5: Payload-Driven Notification Deep-Link Routing

**Files:**
- Modify: `lib/features/notifications/domain/entities/reminder_event.dart`
- Modify: `lib/features/notifications/domain/entities/notification_action_event.dart`
- Modify: `lib/features/notifications/infrastructure/repositories/local_notification_scheduler_repository.dart`
- Modify: `lib/app/app.dart`
- Modify: `lib/features/notifications/application/use_cases/handle_notification_action_use_case.dart`
- Test: `test/features/notifications/notification_deeplink_routing_test.dart`

**Step 1: Write the failing test**

```dart
test('quote notification action resolves Home route', () async {
  // expect route target == home
});

test('angelus/regina action resolves Prayer route with payload context', () async {
  // expect route target == prayer
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/notifications/notification_deeplink_routing_test.dart -r expanded`
Expected: FAIL due missing route target metadata.

**Step 3: Write minimal implementation**

- Add route target and context fields in payload model.
- Emit route-specific payload at schedule-time.
- Update app-level action listener to navigate to Home/Prayer accordingly.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/notifications/notification_deeplink_routing_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add test/features/notifications/notification_deeplink_routing_test.dart \
  lib/features/notifications/domain/entities/reminder_event.dart \
  lib/features/notifications/domain/entities/notification_action_event.dart \
  lib/features/notifications/infrastructure/repositories/local_notification_scheduler_repository.dart \
  lib/features/notifications/application/use_cases/handle_notification_action_use_case.dart \
  lib/app/app.dart
git commit -m "feat(notifications): add payload-driven deep-link routing"
```

### Task 6: Build Prayer Screen for Angelus/Regina Caeli

**Files:**
- Create: `lib/features/prayers/presentation/prayer_screen.dart`
- Modify: `lib/app/app.dart`
- Test: `test/features/prayers/prayer_screen_test.dart`

**Step 1: Write the failing test**

```dart
testWidgets('renders prayer title, verses, image, and final prayer', (tester) async {
  // pump PrayerScreen with fixture model and verify content
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/prayers/prayer_screen_test.dart -r expanded`
Expected: FAIL because screen does not exist.

**Step 3: Write minimal implementation**

- Create reusable prayer screen matching desktop prayer layout hierarchy.
- Render image hero + verse/response blocks + closing prayer.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/prayers/prayer_screen_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add test/features/prayers/prayer_screen_test.dart \
  lib/features/prayers/presentation/prayer_screen.dart \
  lib/app/app.dart
git commit -m "feat(prayers): add in-app prayer screen"
```

### Task 7: Redesign Home to Desktop Card Parity + Landing Typography

**Files:**
- Modify: `lib/core/theme/app_theme.dart`
- Modify: `lib/features/home/presentation/home_screen.dart`
- Modify: `pubspec.yaml`
- Test: `test/features/home/home_screen_card_layout_test.dart`

**Step 1: Write the failing test**

```dart
testWidgets('home displays desktop-like quote card with image overlay and settings entry', (tester) async {
  // verify card container, quote text, season/feast label, settings button
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/home/home_screen_card_layout_test.dart -r expanded`
Expected: FAIL because current home is basic list/cards.

**Step 3: Write minimal implementation**

- Add Google Fonts dependencies and theme tokens aligned to current visual language.
- Replace Home scaffold body with a refined single-card composition and config entry.
- Bind card to `lastDeliveredCard` fallbacking to current quote.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/home/home_screen_card_layout_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add test/features/home/home_screen_card_layout_test.dart \
  lib/core/theme/app_theme.dart \
  lib/features/home/presentation/home_screen.dart \
  pubspec.yaml
git commit -m "feat(home): redesign quote card UI with modern visual language"
```

### Task 8: Settings Parity and Reminder Rebuild Verification

**Files:**
- Modify: `lib/features/settings/presentation/settings_screen.dart`
- Test: `test/features/settings/settings_screen_parity_test.dart`
- Test: `test/features/notifications/reminder_rebuild_on_save_test.dart`

**Step 1: Write the failing test**

```dart
testWidgets('settings screen contains full desktop parity fields', (tester) async {
  // check interval/duration/language/sound/4 modules + HH:MM
});

test('saving settings cancels and rebuilds reminders', () async {
  // verify cancelAll then schedule core + liturgy
});
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/features/settings/settings_screen_parity_test.dart test/features/notifications/reminder_rebuild_on_save_test.dart -r expanded`
Expected: FAIL due missing parity wiring/assertions.

**Step 3: Write minimal implementation**

- Ensure all parity controls and validation constraints mirror desktop behavior.
- Keep best-effort scheduler rebuild on save.
- Keep concise, modern microcopy and proper form grouping.

**Step 4: Run test to verify it passes**

Run: `flutter test test/features/settings/settings_screen_parity_test.dart test/features/notifications/reminder_rebuild_on_save_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add test/features/settings/settings_screen_parity_test.dart \
  test/features/notifications/reminder_rebuild_on_save_test.dart \
  lib/features/settings/presentation/settings_screen.dart
git commit -m "feat(settings): complete parity controls and reminder rebuild flow"
```

### Task 9: Full Verification Before Completion

**Files:**
- Modify (if needed): affected implementation files above
- Test: existing + new test suites

**Step 1: Run focused suites**

Run:
```bash
flutter test test/features/liturgical -r expanded
flutter test test/features/quotes -r expanded
flutter test test/features/notifications -r expanded
flutter test test/features/prayers -r expanded
flutter test test/features/home -r expanded
flutter test test/features/settings -r expanded
```

Expected: all PASS.

**Step 2: Run full test suite**

Run: `flutter test -r expanded`
Expected: all PASS, no skipped critical parity tests.

**Step 3: Manual sanity checks (simulator/device)**

- Trigger quote reminder -> tap opens Home.
- Trigger noon reminder -> tap opens Prayer with image and full text.
- Confirm Home shows last delivered quote card.
- Confirm offline mode still displays bundled images/content.

**Step 4: Commit final polish**

```bash
git add .
git commit -m "feat(mobile): complete desktop parity behavior and modern UI"
```
