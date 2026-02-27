# UI Update: Rename Novenas + Add Doutrina Católica Button

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rename "Novenas" button to "Orações e Novenas" and add "Doutrina Católica" quick action card in home screen.

**Architecture:** Modify home_screen.dart to update button labels and add new navigation

**Tech Stack:** Flutter, Cupertino widgets

---

## Task 1: Rename Novenas Button

### Task 1a: Update home_screen.dart

**Files:**
- Modify: `iacula_app/lib/features/home/presentation/home_screen.dart`

**Step 1: Find and update the button label**

Change line 238 from:
```dart
label: 'Novenas',
```

To:
```dart
label: 'Orações\ne Novenas',
```

Note: The `\n` makes it two lines to fit the card better.

**Step 2: Commit**

```bash
git add iacula_app/lib/features/home/presentation/home_screen.dart
git commit -m "feat(home): rename Novenas to Orações e Novenas"
```

---

## Task 2: Add Doctrina Navigation Handler

### Task 2a: Add onOpenDoctrina callback

**Files:**
- Modify: `iacula_app/lib/features/home/presentation/home_screen.dart`

**Step 1: Add callback parameter**

Find the `_HomeContentState` class and add to the parameters:
```dart
required this.onOpenDoctrina,
```

Add to the callback definitions:
```dart
final VoidCallback onOpenDoctrina;
```

**Step 2: Add route in HomeScreen**

Find where the other routes are defined (e.g., `_showEmBreveDialog(context, 'Novenas')`) and add:

```dart
onOpenNovenas: () {
  Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (_) => const PrayerCollectionsScreen(),
    ),
  );
},
```

**Step 3: Commit**

```bash
git add iacula_app/lib/features/home/presentation/home_screen.dart
git commit -m "feat(home): add navigation to Novenas (prayers section)"
```

---

## Task 3: Add Doctrina Quick Action Card

### Task 3a: Add DoctrinaCard to quick actions row

**Files:**
- Modify: `iacula_app/lib/features/home/presentation/home_screen.dart`

**Step 1: Add new quick action card**

In the `_QuickActionsRow` build method, find the row of cards and add a new one:

```dart
Expanded(
  child: _SquareFeatureCard(
    icon: CupertinoIcons.book_circle,
    label: 'Doutrina\nCatólica',
    onTap: onOpenDoctrina,
  ),
),
```

**Step 2: Commit**

```bash
git add iacula_app/lib/features/home/presentation/home_screen.dart
git commit -m "feat(home): add Doctrina Católica quick action card"
```

---

## Task 4: Wire Up Doctrina Screen

### Task 4a: Add navigation to DoctrineCollectionsScreen

**Files:**
- Modify: `iacula_app/lib/features/home/presentation/home_screen.dart`

**Step 1: Add import**

```dart
import '../../../features/doctrina/presentation/doctrine_collections_screen.dart';
```

**Step 2: Update onOpenDoctrina callback**

Change from showing "em breve" dialog to actual navigation:

```dart
onOpenDoctrina: () {
  Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (_) => const DoctrineCollectionsScreen(),
    ),
  );
},
```

**Step 3: Commit**

```bash
git add iacula_app/lib/features/home/presentation/home_screen.dart
git commit -m "feat(home): wire up Doctrina Católica screen navigation"
```

---

## Task 5: Verify Changes

### Task 5a: Run app to verify

**Step 1: Check the quick actions row**

The row should now have 4 cards:
1. Orações
2. Liturgia
3. Rosário 📿
4. Doutrina Católica

And the "Novenas" button should say "Orações\nNovenas"

**Step 2: Commit**

```bash
git commit -m "fix(home): adjust button layout for multi-line labels"
```

---

## Summary

**After completing all tasks:**
- "Novenas" button renamed to "Orações e Novenas"
- New "Doutrina Católica" quick action card added
- Both screens navigate correctly

**Commands to verify:**
```bash
git log --oneline -10
```

Expected output should show commits for UI updates.
