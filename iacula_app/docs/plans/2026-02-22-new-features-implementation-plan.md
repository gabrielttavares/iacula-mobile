# New Features (Plan of Life, Meditations, etc.) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement the new App Drawer navigation and the UI/Logic for the Plan of Life, Daily Meditation, Devotions, and About screens using Riverpod and Isar.

**Architecture:** We will implement the UI components first with mocked data, then build the Isar database layer and Riverpod state management, and finally integrate them.

**Tech Stack:** Flutter, Riverpod, Isar, url_launcher.

---

### Task 1: Setup Dependencies & Basic Drawer Navigation

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/features/home/presentation/home_screen.dart`
- Create: `lib/core/presentation/widgets/app_drawer.dart`

**Step 1: Add Dependency**
Run `flutter pub add url_launcher` in the terminal to add the required dependency.

**Step 2: Create AppDrawer Widget**
Create `lib/core/presentation/widgets/app_drawer.dart` containing a `Drawer` widget with a `ListView` of `ListTile`s for: Início (Home), Sobre/Espiritualidade, Devoções & Orações, Meditação Diária, Plano de Vida. For now, the `onTap` for the new items should just close the drawer (`Navigator.pop(context)`).

**Step 3: Add Drawer to Home Screen**
In `lib/features/home/presentation/home_screen.dart`:
1.  Wrap the `SafeArea` body in a `Scaffold` (it already is).
2.  Add `drawer: const AppDrawer(),` to the `Scaffold`.
3.  Replace the `SizedBox(width: 48)` in the top `Row` with:
    ```dart
    Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    ),
    ```

**Step 4: Verify**
Run the app. Verify the hamburger menu icon appears and opens the drawer successfully.

**Step 5: Commit**
```bash
git add pubspec.yaml pubspec.lock lib/core/presentation/widgets/app_drawer.dart lib/features/home/presentation/home_screen.dart
git commit -m "feat: Add url_launcher and AppDrawer navigation"
```

---

### Task 2: Build Meditação Diária (Daily Meditation) UI

**Files:**
- Create: `lib/features/meditation/presentation/meditation_screen.dart`
- Create: `lib/features/meditation/presentation/widgets/meditation_card.dart`
- Modify: `lib/core/presentation/widgets/app_drawer.dart`

**Step 1: Create MeditationCard Widget**
Create a stateless widget `MeditationCard` that accepts `title`, `platformIcon` (IconData), and `url`. Use `url_launcher` in its `onTap` to open the URL.
```dart
Future<void> _launchUrl() async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}
```

**Step 2: Create Meditation Screen**
Create `MeditationScreen` with a `Scaffold`, `AppBar(title: Text('Meditação Diária'))`, and a `ListView` containing 3 `MeditationCard`s with the hardcoded links:
1.  Padre Cléber Eduardo dos Santos Dias (https://soundcloud.com/praedicaverbum)
2.  Homilia Diária Padre Paulo Ricardo (https://www.youtube.com/@padrepauloricardo/videos)
3.  Padre Pedro Willemsens (https://www.youtube.com/@meditacoespadrepedro)

**Step 3: Link Drawer to Screen**
In `app_drawer.dart`, update the `ListTile` for Meditação Diária to navigate to `MeditationScreen`:
```dart
Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MeditationScreen()));
```

**Step 4: Verify**
Run the app. Open the drawer, tap "Meditação Diária", and verify the cards render and open the links in the browser/app.

**Step 5: Commit**
```bash
git add lib/features/meditation/ lib/core/presentation/widgets/app_drawer.dart
git commit -m "feat: Build Daily Meditation UI with external links"
```

---

### Task 3: Build Plano de Vida (Plan of Life) UI (Mocked)

**Files:**
- Create: `lib/features/plan_of_life/presentation/plan_of_life_screen.dart`
- Create: `lib/features/plan_of_life/presentation/widgets/plan_item_row.dart`
- Create: `lib/features/plan_of_life/presentation/widgets/animated_checkbox.dart`
- Modify: `lib/core/presentation/widgets/app_drawer.dart`

**Step 1: Create Animated Checkbox**
Create a highly visual `AnimatedCheckbox` widget (Stateful or heavily animated) that smoothly transitions from an empty circle border to a filled circle with a check icon.

**Step 2: Create PlanItemRow**
Create a `PlanItemRow` widget that takes a `title` (String), `isCompleted` (bool), and `onToggle` (Function(bool)). It should contain the text and the `AnimatedCheckbox`.

**Step 3: Create Screen with Mocked Data**
Create `PlanOfLifeScreen` with a `Scaffold`, `AppBar`, and a `ListView`. Hardcode a stateful list of the 10 default items (Oferecimento de obras, etc.) just to test the UI toggling.

**Step 4: Link Drawer to Screen**
Update `app_drawer.dart` to navigate to `PlanOfLifeScreen`.

**Step 5: Verify**
Run the app, navigate to Plano de Vida, and verify the checkboxes animate beautifully when tapped.

**Step 6: Commit**
```bash
git add lib/features/plan_of_life/presentation/ lib/core/presentation/widgets/app_drawer.dart
git commit -m "feat: Build Plan of Life UI with animated checkboxes (mocked)"
```

*(Note: The remaining tasks for Isar DB, Riverpod state, and the Daily Reset logic will be detailed in the next implementation phase once the UI is approved.)*
