# iOS Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Completely overhaul the Iacula app's UI to a bright, iOS-style aesthetic with a BottomNavigationBar and modern card-based layouts.

**Architecture:** We will first implement a new `ShellScreen` to handle the Bottom Navigation Bar, then update the global `AppTheme` to light mode, and finally redesign the `HomeScreen` and `PlanOfLifeScreen` to match the new bright, card-heavy aesthetic.

**Tech Stack:** Flutter, Riverpod.

---

### Task 1: Create Main Shell with Bottom Navigation Bar

**Files:**
- Create: `lib/core/presentation/shell_screen.dart`
- Modify: `lib/main.dart`
- Delete: `lib/core/presentation/widgets/app_drawer.dart`
- Modify: `lib/features/home/presentation/home_screen.dart`

**Step 1: Create the Shell Screen**
Create `shell_screen.dart` with a `StatefulWidget` containing a `Scaffold` and a `BottomNavigationBar`.
*   Maintain a `_currentIndex` state.
*   The body should be an `IndexedStack` to preserve state across tabs.
*   Children: `HomeScreen()`, `MeditationScreen()`, `PlanOfLifeScreen()`, and `SettingsScreen()` (temporarily using Settings for the 4th tab until Devotions is built).
*   Items: Início (Icons.home_rounded), Meditação (Icons.play_circle_outline), Plano de Vida (Icons.checklist), Perfil (Icons.person_outline).

**Step 2: Remove the Drawer**
Delete `app_drawer.dart`. In `home_screen.dart`, remove the `drawer` property from the `Scaffold` and remove the hamburger menu icon from the top Row.

**Step 3: Update main.dart**
In `main.dart`, change the `home` property of `MaterialApp` from `HomeScreen()` to `ShellScreen()`.

**Step 4: Verify Compilation**
Run: `fvm flutter analyze`
Expected: PASS with 0 errors.

**Step 5: Commit**
```bash
git rm lib/core/presentation/widgets/app_drawer.dart
git add lib/core/presentation/shell_screen.dart lib/main.dart lib/features/home/presentation/home_screen.dart
git commit -m "feat: Replace drawer with BottomNavigationBar shell"
```

---

### Task 2: Global Theme Overhaul (Light Mode)

**Files:**
- Modify: `lib/core/theme/app_theme.dart`
- Modify: `lib/features/meditation/presentation/meditation_screen.dart`
- Modify: `lib/features/meditation/presentation/widgets/meditation_card.dart`
- Modify: `lib/features/plan_of_life/presentation/plan_of_life_screen.dart`
- Modify: `lib/features/plan_of_life/presentation/widgets/plan_item_row.dart`
- Modify: `lib/features/plan_of_life/presentation/widgets/animated_checkbox.dart`

**Step 1: Update AppTheme**
In `app_theme.dart`:
*   Change `scaffoldBackgroundColor` to `Color(0xFFF2F2F7)` (iOS Grouped Background).
*   Change `colorScheme`:
    *   `primary`: `Color(0xFF1D3557)` (Deep Blue from Anchor).
    *   `onPrimary`: `Colors.white`.
    *   `surface`: `Colors.white`.
    *   `onSurface`: `Colors.black`.
*   Update `textTheme` colors from light to dark (e.g., bodyLarge color to black/dark gray).
*   Update `appBarTheme` to have a transparent or white background with black/blue text and zero elevation.

**Step 2: Clean up hardcoded dark colors**
Go through the Meditation and Plan of Life screens/widgets modified in the previous tasks. Ensure they rely on `Theme.of(context).colorScheme.surface` for card backgrounds and `onSurface` for text instead of explicit dark hex colors.

**Step 3: Verify Compilation**
Run: `fvm flutter analyze`
Expected: PASS.

**Step 4: Commit**
```bash
git add lib/core/theme/app_theme.dart lib/features/meditation/ lib/features/plan_of_life/
git commit -m "style: Apply light iOS-style global theme"
```

---

### Task 3: Redesign Home Screen (Início)

**Files:**
- Modify: `lib/features/home/presentation/home_screen.dart`

**Step 1: Implement Header**
Change the top `Row` to be a simple left-aligned large title:
```dart
Text(
  'Olá, Pedro', // Or generic greeting if name isn't available
  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
),
```

**Step 2: Implement Quick Actions Row**
Below the header, add a horizontally scrolling `ListView` or `SingleChildScrollView(scrollDirection: Axis.horizontal)` with 3-4 simple white cards (e.g., "Orações", "Rosário", "Novenas"). They can just be visual placeholders for now (Icon + Text).

**Step 3: Reposition Quote Card**
Move the existing `_QuoteCard` (the Jaculatória) below the Quick Actions. Wrap it in a `SizedBox(height: 300)` or similar so it serves as a large hero image card. Ensure it has generous `borderRadius: BorderRadius.circular(24)` and a soft shadow.

**Step 4: Verify Compilation & Tests**
Run: `fvm flutter test test/features/home/home_screen_test.dart`
Fix any broken tests related to finding widgets that were moved.

**Step 5: Commit**
```bash
git add lib/features/home/presentation/home_screen.dart
git commit -m "style: Redesign Home screen to modern iOS dashboard"
```

---

### Task 4: Redesign Plan of Life Screen

**Files:**
- Modify: `lib/features/plan_of_life/presentation/plan_of_life_screen.dart`
- Modify: `lib/features/plan_of_life/presentation/widgets/plan_item_row.dart`
- Modify: `lib/features/plan_of_life/presentation/widgets/animated_checkbox.dart`

**Step 1: Horizontal Date Picker (Mocked)**
At the top of `PlanOfLifeScreen`'s body, add a `Container` with a horizontal `ListView` showing a few days (e.g., "Qua 05", "Qui 06"). Highlight one as active (e.g., dark background, white text) and the others as inactive (transparent background, gray text).

**Step 2: Redesign Item Row as a Card**
Update `PlanItemRow` to look like the iOS reference:
*   Wrap the content in a `Card` or a decorated `Container` with white background, `borderRadius: BorderRadius.circular(16)`, and a very soft shadow.
*   Add a placeholder rounded image/icon container on the far left.
*   Change the layout: Left (Image) -> Center (Title + Subtitle "Diariamente") -> Right (AnimatedCheckbox + Icons.more_horiz).

**Step 3: Add Section Headers**
In the `ListView.builder` of the screen, simulate sections by adding a simple text header like "Manhã" with an icon before the first item, "Tarde" before the 5th item, etc.

**Step 4: Verify Compilation**
Run: `fvm flutter analyze`
Expected: PASS.

**Step 5: Commit**
```bash
git add lib/features/plan_of_life/
git commit -m "style: Redesign Plan of Life UI to iOS card style"
```
