# Prayer Card Image Fix Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix the prayer card image not displaying by changing the white gradient overlay to a black gradient (matching the working quote implementation).

**Architecture:** Modify the gradient overlay in PrayerScreen to use black instead of white, which will allow the underlying image to be visible. Optionally add path transformation helper for consistency.

**Tech Stack:** Flutter, Dart

---

### Task 1: Fix White Gradient Overlay in PrayerScreen

**Files:**
- Modify: `lib/features/prayers/presentation/prayer_screen.dart:25-36`

**Step 1: Read the current implementation**

Run: Read lines 25-40 of `prayer_screen.dart`

**Step 2: Edit the gradient colors**

Replace the white gradient with black gradient (matching home_screen.dart implementation):

```dart
// BEFORE (lines 25-36):
DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        CupertinoColors.white.withValues(alpha: 0.65),
        CupertinoColors.white.withValues(alpha: 0.95),
      ],
    ),
  ),
)

// AFTER:
DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        CupertinoColors.black.withValues(alpha: 0.3),
        CupertinoColors.black.withValues(alpha: 0.86),
      ],
    ),
  ),
)
```

**Step 3: Commit**

```bash
git add lib/features/prayers/presentation/prayer_screen.dart
git commit -m "fix: change prayer card gradient from white to black to reveal image"
```

---

### Task 2: Verify the Fix

**Step 1: Run Flutter analyze**

Run: `flutter analyze` in the project directory
Expected: No errors

**Step 2: Build iOS simulator (optional)**

Run: `flutter build ios --simulator --no-codesign`
Expected: Build succeeds

---

**Plan complete.**

Two execution options:

1. **Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

2. **Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

Which approach?
