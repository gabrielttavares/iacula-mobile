# Iacula App - New Features Design Document

## 1. Overview
This document outlines the design and architecture for adding four new main sections to the Iacula app: App Info & Spirituality, Devotions & Prayers, Daily Meditation, and Plan of Life (Plano de Vida). The implementation is strictly separated into UI components and Riverpod state management, allowing for parallel development and easier testing.

## 2. Global Navigation (App Drawer)
*   **Component:** `AppDrawer` widget (Hamburger Menu).
*   **Placement:** Accessible via an `Icons.menu_rounded` button on the top-left of the existing `HomeScreen`.
*   **Items:** Início, Sobre/Espiritualidade, Devoções & Orações, Meditação Diária, Plano de Vida.

## 3. Plan of Life (Plano de Vida) Architecture

### Data Layer (Isar Database)
*   **Entity:** `PlanItem`
    *   `id`: Id (Auto-increment)
    *   `title`: String
    *   `categoryId`: int (e.g., 1 for "Piedade, Devoções")
    *   `isCompleted`: bool
    *   `isCustom`: bool
    *   `lastCompletedDate`: DateTime?

### State Management (Riverpod)
*   `planItemRepositoryProvider`: Manages Isar CRUD operations.
*   `planItemsNotifierProvider`: (AsyncNotifier) Manages the state of the checklist.
    *   Methods: `toggleItem(int id, bool isCompleted)`, `addCustomItem(String title)`, `deleteItem(int id)`.
*   **Daily Reset Logic:** 
    *   A service that checks `lastCompletedDate` against `DateTime.now()`.
    *   If `lastCompletedDate` is before today, it resets `isCompleted` to `false`.
    *   This logic runs on app startup AND when the app resumes from the background using `WidgetsBindingObserver` (handling cases where the app is left open overnight).

### UI Components
*   **Screen:** `PlanOfLifeScreen`
*   **List:** `ListView.builder` separated by categories (starting with the default "Piedade, Devoções").
*   **Item Row:** A stateless `PlanItemRow` widget receiving the `PlanItem` data and a `onToggle` callback.
*   **Checkbox:** A custom animated circular checkbox widget (unfilled circle when false, filled with icon when true).
*   **Seed Data (10 default items):**
    1. Oferecimento de obras
    2. Leitura do Santo Evangelho
    3. Leitura espiritual
    4. Angelus (Anjo do Senhor)
    5. Oração mental (ou meditação)
    6. Visita ao Santíssimo
    7. Terço
    8. Santa Missa
    9. 3 Ave-Marias antes de deitar
    10. Exame de consciência (antes de deitar)

## 4. Daily Meditation (Meditação Diária) Architecture
*   **Dependency:** `url_launcher` package required.
*   **Screen:** `MeditationScreen` containing a list of `MeditationCard` widgets.
*   **Card Component:** `MeditationCard` (stateless).
    *   Props: `title`, `platformIcon` (YouTube/Soundcloud), `url`.
    *   Action: `onTap` uses `launchUrl(Uri.parse(url))`.
*   **Content (Hardcoded Links):**
    *   Padre Cléber Eduardo dos Santos Dias (SoundCloud)
    *   Homilia Diária Padre Paulo Ricardo (YouTube)
    *   Padre Pedro Willemsens (YouTube)

## 5. Devotions & Prayers (Devoções & Orações)
*   **Screen:** `DevotionsScreen` (List View).
*   **Logic:** Reuses existing `PrayerCollection` data structure or loads from localized JSON assets.
*   **Action:** Tapping an item navigates to the existing `PrayerScreen`.

## 6. About App & Spirituality (Sobre/Espiritualidade)
*   **Screen:** A clean, static reading view.
*   **Content:** Localized Markdown or rich text loaded from assets, explaining the app's purpose and spirituality.

## 7. Development Strategy
1.  **Phase 1 (UI Only):** Build the Drawer, Meditação Diária screen (with cards), and the Plano de Vida UI (list, custom checkboxes) using mocked data.
2.  **Phase 2 (Logic):** Create Isar schemas, Riverpod providers, and Daily Reset logic.
3.  **Phase 3 (Integration):** Connect the Riverpod providers to the UI components. Add `url_launcher` dependency.
