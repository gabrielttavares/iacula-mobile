# Iacula Mobile Parity Design (Flutter iOS/Android)

Date: 2026-02-21  
Status: Approved

## 1. Objective
Deliver a mobile-first Flutter app for iOS and Android with desktop behavior parity for:
- periodic quote reminders,
- Angelus/Regina Caeli noon reminder,
- Liturgy of the Hours reminders,
- settings and content rules.

The mobile app must preserve the same spiritual and visual language as current desktop + landing, while using native OS notification banners (minimal text, no background image in banner).

## 2. Confirmed Product Decisions
- Scheduling policy: **best effort mobile-native**.
- Scope: **full parity in v1** (quotes + Angelus/Regina Caeli + Liturgia das Horas + settings parity).
- Quote notification tap route: **Home**.
- UX style direction: **beautiful, modern, minimalist notifications and polished app UI**.
- Offline requirement: **images and content must work offline**.

## 3. Chosen Approach
Chosen approach: **incremental parity on current Flutter codebase**.

Why:
- Existing clean architecture and repositories already exist.
- Real storage/notifications bootstrap is already wired.
- Fastest route with lower rewrite risk than a full restart.

## 4. Architecture and Parity Contract

### 4.1 Layering
Keep current Flutter feature layering (domain/application/infrastructure/presentation), extending models and use cases to parity.

### 4.2 Parity Source of Truth
Desktop behavior remains the parity reference for rule porting:
- Quote selection/merge/dedup + image behavior.
- Liturgical context mapping and fallback.
- Prayer routing Angelus vs Regina Caeli.

### 4.3 Domain Extensions Needed
- Add `LiturgicalContext` to Flutter (`season`, `rank`, optional `feast`, optional `feastName`, `apiQuotes`).
- Extend quote result model to include feast metadata used by UI and notification payloads.
- Add explicit app route target metadata for notification action handling.

### 4.4 Quote Rule Parity
For each reminder:
1. Resolve current liturgical context.
2. Load seasonal quotes by language/season.
3. If feast exists, load curated feast quotes.
4. Merge curated feast quotes + API quotes and deduplicate with normalization.
5. If merged feast pool not empty, feast pool becomes quote source for day.
6. Image priority:
   - feast image when available,
   - otherwise seasonal day image rotation.
7. Persist updated quote/image indices.

### 4.5 Prayer Rule Parity
- Noon event resolves season and shows:
  - `Regina Caeli` in Easter time,
  - `Angelus` otherwise.
- Manual/forced flows can override season where required.

## 5. UI/Navigation Design

### 5.1 Routes
- `HomeScreen` (default route; destination for quote notification tap).
- `SettingsScreen` (desktop-equivalent options).
- `PrayerScreen` (Angelus/Regina Caeli with image and full prayer content).

### 5.2 Home Layout
- Top-right config button.
- Main quote card reproducing desktop popup composition:
  - background image,
  - dark overlay,
  - quote text typography,
  - subtle season/feast label.
- Card displays **last delivered notification quote snapshot**.

### 5.3 Settings Parity
Keep parity with desktop fields:
- interval and duration,
- language,
- liturgy sound enabled + volume,
- Laudes/Vespers/Compline/Ora Media toggles and HH:MM times.

`autostart` remains in model parity but UI behavior is adapted for mobile platform limitations.

### 5.4 Visual Language
- Serif-based typography aligned with current language:
  - display: `Cormorant Garamond`,
  - body: `Libre Baskerville`.
- Warm liturgical palette and layered surfaces.
- Minimal, meaningful motion only (route/card transitions).
- Strong readability and contrast first.

## 6. Notifications (Minimalist + Modern)

### 6.1 Banner Policy
- Native OS banners only.
- Title/body text + app icon only.
- No background image in notification banner.
- Short, elegant copy.

### 6.2 Interaction
- Quote notification tap -> `HomeScreen`.
- Angelus/Regina Caeli notification tap -> `PrayerScreen` with prayer and image.
- Optional snooze action reserved for alarm-like events only.

### 6.3 Best-Effort Scheduling
- Android: exact scheduling when allowed; inexact fallback when restricted.
- iOS: schedule within platform limits.
- Rebuild schedules at startup and after settings save.

## 7. Offline Asset Strategy (Approved)
- Primary strategy: ship images/audio/quotes/prayers as **bundled assets**.
- The app reads assets directly via Flutter asset paths.
- Isar stores metadata/catalog/indexing only (no duplicated image binaries).
- If remote media is introduced later, cache to app documents directory and fallback to bundled assets.

Result: images and content continue to work fully offline.

## 8. Error Handling
- Liturgical API unavailable/timeout -> graceful fallback context (`ordinary`) without crashes.
- Missing quote/prayer/image -> safe placeholder content with stable UI.
- Notification permission denied -> in-app guidance in Settings state.

## 9. TDD Strategy (Mandatory)
Use strict red-green-refactor flow for every feature slice:

1. Write failing tests for parity behavior.
2. Implement minimum code to pass.
3. Refactor with tests still green.

Required test suites:
- quote parity (feast + API merge/dedup, indices, image priority),
- prayer parity (Angelus vs Regina Caeli),
- notification payload and deep-link routing,
- scheduling rebuild + fallback behavior,
- widget tests for Home/Prayer/Settings core states.

## 10. Delivery Phases
1. Core parity engine and tests.
2. Home/Prayer/Settings visual parity and polish.
3. Notification payload/routing and copy polish.
4. QA pass on iOS and Android devices.

## 11. Success Criteria
- Functional parity with desktop reminder and content rules.
- Offline reliability for all bundled content.
- Modern, polished mobile UI aligned with current brand/language.
- Minimalist notification experience with correct deep-link behavior.
- TDD-backed confidence with passing parity-focused test coverage.
