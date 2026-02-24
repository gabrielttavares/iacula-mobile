# Cupertino-First App Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Redesign all presentation flows to a Cupertino-first, minimalist iOS-style UI while preserving existing app behavior and domain logic.

**Architecture:** Introduce a centralized Cupertino design system (tokens + shared widgets), migrate app bootstrapping to `CupertinoApp`, replace shell navigation with `CupertinoTabScaffold` and per-tab stacks, then incrementally migrate each presentation screen to shared Cupertino components. Preserve Riverpod providers/use-cases and only change UI/navigation layer.

**Tech Stack:** Flutter, Cupertino widgets, Riverpod, flutter_test

---

### Task 1: Add Cupertino design tokens and shared primitives

**Files:**
- Create: `lib/core/theme/cupertino_tokens.dart`
- Create: `lib/core/presentation/widgets/iacula_large_title.dart`
- Create: `lib/core/presentation/widgets/iacula_section_header.dart`
- Create: `lib/core/presentation/widgets/iacula_soft_card.dart`
- Create: `lib/core/presentation/widgets/iacula_buttons.dart`
- Create: `lib/core/presentation/widgets/iacula_list_item.dart`
- Create: `lib/core/presentation/widgets/iacula_horizontal_card_rail.dart`
- Test: `test/core/presentation/cupertino_primitives_test.dart`

**Step 1: Write failing tests for tokenized primitives**

```dart
testWidgets('IaculaPrimaryPillButton has height 52 and rounded shape', (tester) async {
  await tester.pumpWidget(const CupertinoApp(home: CupertinoPageScaffold(child: IaculaPrimaryPillButton(label: 'OK'))));
  final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
  expect(sizedBox.height, 52);
});
```

**Step 2: Run test to verify it fails**

Run: `fvm flutter test test/core/presentation/cupertino_primitives_test.dart -r expanded`
Expected: FAIL due to missing classes/files.

**Step 3: Implement minimal primitives and tokens**
- Add color, spacing, radius, and typography constants matching approved design.
- Implement each shared widget with Cupertino-compatible composition and no Material ripple.

**Step 4: Run test to verify it passes**

Run: `fvm flutter test test/core/presentation/cupertino_primitives_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/core/theme/cupertino_tokens.dart lib/core/presentation/widgets/iacula_*.dart test/core/presentation/cupertino_primitives_test.dart
git commit -m "feat(ui): add cupertino design tokens and reusable primitives"
```

### Task 2: Migrate app root to CupertinoApp

**Files:**
- Modify: `lib/app/app.dart`
- Modify: `lib/core/theme/app_theme.dart`
- Test: `test/widget_test.dart`

**Step 1: Write failing root-app test**
- Assert root app is `CupertinoApp` and does not depend on Material theme initialization.

**Step 2: Run test to verify it fails**

Run: `fvm flutter test test/widget_test.dart -r expanded`
Expected: FAIL because root is still `MaterialApp`.

**Step 3: Implement minimal migration**
- Replace `MaterialApp` with `CupertinoApp`.
- Move core visual defaults to Cupertino theme data.
- Keep existing routing targets wired.

**Step 4: Run test to verify it passes**

Run: `fvm flutter test test/widget_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/app/app.dart lib/core/theme/app_theme.dart test/widget_test.dart
git commit -m "refactor(app): migrate root to CupertinoApp"
```

### Task 3: Replace shell navigation with CupertinoTabScaffold (5 tabs)

**Files:**
- Modify: `lib/core/presentation/shell_screen.dart`
- Create: `lib/features/favorites/presentation/favorites_screen.dart`
- Test: `test/features/shell/cupertino_shell_navigation_test.dart`
- Test: `test/features/premium/shell_premium_navigation_test.dart`

**Step 1: Write failing shell tests**
- Assert 5 tabs exist with labels: Início, Meditação, Plano de vida, Favoritos, Perfil.
- Assert premium gating still blocks restricted tabs for non-premium user.
- Assert each tab keeps independent stack.

**Step 2: Run tests to verify failures**

Run: `fvm flutter test test/features/shell/cupertino_shell_navigation_test.dart test/features/premium/shell_premium_navigation_test.dart -r expanded`
Expected: FAIL due to missing Cupertino shell and favorites entry.

**Step 3: Implement minimal shell migration**
- Use `CupertinoTabScaffold` + `CupertinoTabBar`.
- Use `CupertinoTabView` for each tab stack.
- Preserve premium gate behavior currently in shell tap logic.

**Step 4: Run tests to verify pass**

Run: `fvm flutter test test/features/shell/cupertino_shell_navigation_test.dart test/features/premium/shell_premium_navigation_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/core/presentation/shell_screen.dart lib/features/favorites/presentation/favorites_screen.dart test/features/shell/cupertino_shell_navigation_test.dart test/features/premium/shell_premium_navigation_test.dart
git commit -m "feat(shell): adopt cupertino tab scaffold with five tabs"
```

### Task 4: Rebuild Home screen with Cupertino layout and shared components

**Files:**
- Modify: `lib/features/home/presentation/home_screen.dart`
- Test: `test/features/home/home_screen_test.dart`

**Step 1: Write failing home structure tests**
- Assert large greeting title style path is present.
- Assert sections: Destaques, Orações diárias, Orações temáticas, Orações de Santos.
- Assert horizontal rails render cards at ~70% width behavior.

**Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/home/home_screen_test.dart -r expanded`
Expected: FAIL on old structure assertions.

**Step 3: Implement minimal home rebuild**
- Replace Material scaffold with Cupertino page scaffold/safe area.
- Use shared primitives for cards, headers, list items, and CTA chip.
- Keep current data provider wiring unchanged.

**Step 4: Run tests to verify pass**

Run: `fvm flutter test test/features/home/home_screen_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/home/presentation/home_screen.dart test/features/home/home_screen_test.dart
git commit -m "feat(home): rebuild with cupertino content-first layout"
```

### Task 5: Rebuild Liturgia screen with Cupertino segmented content + calendar sheet

**Files:**
- Modify: `lib/features/liturgia_diaria/presentation/liturgia_screen.dart`
- Test: `test/features/liturgia_diaria/liturgia_screen_test.dart`

**Step 1: Write failing liturgy tests**
- Assert large title + horizontal day selector render.
- Assert segmented control toggles liturgy sections.
- Assert bottom calendar modal opens and confirm action closes modal.

**Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/liturgia_diaria/liturgia_screen_test.dart -r expanded`
Expected: FAIL because modal/segmented structure missing.

**Step 3: Implement minimal Cupertino liturgy screen**
- Replace Material chips and app bar with Cupertino header and segmented control.
- Add bottom sheet calendar modal.
- Keep liturgy data fetching provider as-is.

**Step 4: Run test to verify it passes**

Run: `fvm flutter test test/features/liturgia_diaria/liturgia_screen_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/liturgia_diaria/presentation/liturgia_screen.dart test/features/liturgia_diaria/liturgia_screen_test.dart
git commit -m "feat(liturgia): cupertino segmented screen with calendar sheet"
```

### Task 6: Convert Perfil/Configurações experience to Cupertino profile layout

**Files:**
- Modify: `lib/features/settings/presentation/settings_screen.dart`
- Modify: `lib/features/auth/presentation/auth_action_sheet.dart`
- Test: `test/features/settings/settings_screen_parity_test.dart`
- Test: `test/features/settings/auth_sync_section_test.dart`
- Test: `test/features/auth/auth_action_sheet_test.dart`

**Step 1: Write failing tests for profile hierarchy**
- Assert large `Perfil` title.
- Assert account and security sections with edit affordances.
- Assert auth sheet CTAs use pill visual hierarchy.

**Step 2: Run tests to verify failures**

Run: `fvm flutter test test/features/settings/settings_screen_parity_test.dart test/features/settings/auth_sync_section_test.dart test/features/auth/auth_action_sheet_test.dart -r expanded`
Expected: FAIL on old Material controls/layout assumptions.

**Step 3: Implement minimal profile/settings migration**
- Replace Material forms/lists where possible with Cupertino controls.
- Keep save/load behavior and existing validation semantics.
- Replace Material feedback surfaces with Cupertino feedback patterns.

**Step 4: Run tests to verify pass**

Run: `fvm flutter test test/features/settings/settings_screen_parity_test.dart test/features/settings/auth_sync_section_test.dart test/features/auth/auth_action_sheet_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/settings/presentation/settings_screen.dart lib/features/auth/presentation/auth_action_sheet.dart test/features/settings/settings_screen_parity_test.dart test/features/settings/auth_sync_section_test.dart test/features/auth/auth_action_sheet_test.dart
git commit -m "feat(profile): migrate settings and auth sheet to cupertino style"
```

### Task 7: Migrate remaining presentation screens to shared Cupertino primitives

**Files:**
- Modify: `lib/features/meditation/presentation/meditation_screen.dart`
- Modify: `lib/features/meditation/presentation/widgets/meditation_card.dart`
- Modify: `lib/features/plan_of_life/presentation/plan_of_life_screen.dart`
- Modify: `lib/features/plan_of_life/presentation/widgets/plan_item_row.dart`
- Modify: `lib/features/plan_of_life/presentation/widgets/animated_checkbox.dart`
- Modify: `lib/features/prayers/presentation/prayer_collections_screen.dart`
- Modify: `lib/features/prayers/presentation/prayer_screen.dart`
- Modify: `lib/features/notifications/presentation/alarm_screen.dart`
- Modify: `lib/features/premium/presentation/paywall_screen.dart`
- Modify: `lib/features/premium/presentation/premium_gate.dart`
- Test: Existing feature tests under `test/features/meditation`, `test/features/plan_of_life`, `test/features/prayers`, `test/features/premium`, `test/features/notifications`

**Step 1: Write or adjust failing tests per migrated feature**
- Ensure key Cupertino primitives are present.
- Ensure behavior parity for existing actions.

**Step 2: Run targeted tests to verify failures**

Run: `fvm flutter test test/features/premium test/features/prayers test/features/notifications -r expanded`
Expected: FAIL where UI assumptions are outdated.

**Step 3: Implement minimal visual migration per feature**
- Keep data and actions unchanged.
- Remove Material-only visual affordances (ripples/shadows/snackbars).

**Step 4: Run targeted tests to verify pass**

Run: `fvm flutter test test/features/premium test/features/prayers test/features/notifications -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/meditation lib/features/plan_of_life lib/features/prayers lib/features/notifications lib/features/premium
git add test/features/premium test/features/prayers test/features/notifications
 git commit -m "style(ui): migrate remaining presentation screens to cupertino primitives"
```

### Task 8: Full verification and cleanup

**Files:**
- Modify: any touched files requiring lint or test fixes

**Step 1: Run formatter**

Run: `fvm dart format lib test`
Expected: all modified files formatted.

**Step 2: Run analyzer**

Run: `fvm flutter analyze`
Expected: PASS with 0 errors.

**Step 3: Run broad regression tests**

Run: `fvm flutter test -r expanded`
Expected: PASS.

**Step 4: Commit verification fixes if needed**

```bash
git add .
git commit -m "test: finalize cupertino redesign verification fixes"
```

