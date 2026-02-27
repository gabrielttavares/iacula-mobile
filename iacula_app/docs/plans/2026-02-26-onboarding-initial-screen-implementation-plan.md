# Onboarding Initial Screen Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Update the onboarding/initial experience to match the requested branding, card hierarchy, and button color behavior.

**Architecture:** Apply a focused UI update in onboarding plus small shared-theme and header updates. Keep existing widget primitives (`IaculaSoftCard`, `IaculaPrimaryPillButton`) and token-driven styling. Validate behavior with widget tests before and after implementation using strict red-green cycles.

**Tech Stack:** Flutter, Cupertino widgets, Riverpod, flutter_test.

---

### Task 1: Lock expected onboarding and branding behavior with failing tests

**Files:**
- Modify: `test/features/onboarding/onboarding_screen_test.dart`
- Modify: `test/features/home/home_screen_test.dart`
- Modify: `test/core/presentation/cupertino_primitives_test.dart`

**Step 1: Write the failing tests**

```dart
expect(find.byIcon(CupertinoIcons.circle_grid_3x3_fill), findsNothing);
expect(find.text('Notificacoes diarias com Jaculatorias'), findsOneWidget);
expect(find.text('Angelus / Regina Caeli as 12:00'), findsOneWidget);
expect(find.text('Iacula • presenca de Deus no cotidiano'), findsNothing);
expect(IaculaColors.primaryButton, const Color(0xFF0975C8));
```

**Step 2: Run tests to verify failures**

Run: `flutter test test/features/onboarding/onboarding_screen_test.dart test/features/home/home_screen_test.dart test/core/presentation/cupertino_primitives_test.dart`

Expected: FAIL because current onboarding/home still render grid icon, old footer text exists, and primary color token is still dark.

### Task 2: Implement onboarding/header/theme updates minimally

**Files:**
- Modify: `lib/features/onboarding/presentation/onboarding_screen.dart`
- Modify: `lib/features/home/presentation/home_screen.dart`
- Modify: `lib/core/theme/cupertino_tokens.dart`

**Step 1: Update onboarding identity and card stack**
- Replace `_BrandMark` with centered logo + centered `Iacula` title.
- Add top exclusivity card.
- Keep Liturgia Diaria and Plano de Vida cards with equal visual size.
- Remove footer label below "Comecar sem conta".

**Step 2: Remove grid icon from other identity header usage**
- Update home header brand row to text-only `Iacula`.

**Step 3: Update global primary button token**

```dart
static const primaryButton = Color(0xFF0975C8);
```

**Step 4: Run target tests to verify pass**

Run: `flutter test test/features/onboarding/onboarding_screen_test.dart test/features/home/home_screen_test.dart test/core/presentation/cupertino_primitives_test.dart`

Expected: PASS.

### Task 3: Full verification

**Files:**
- No additional file changes

**Step 1: Run broader test slice**

Run: `flutter test test/features/onboarding test/features/home`

Expected: PASS with no regressions in onboarding/home flows.
