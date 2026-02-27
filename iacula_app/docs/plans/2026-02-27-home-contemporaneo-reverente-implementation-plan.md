# Home Contemporaneo Reverente (80/20) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Reestilizar a Home para transmitir acolhimento (80% Cupertino clean, 20% identidade sacra sutil) sem alterar regras de negocio.

**Architecture:** Extrair a composicao da Home em blocos (`HomeHeroCard`, `HomeActionGrid`, `HomeContinuationCard`) e aplicar tokens visuais de atmosfera reverente. Manter providers/use cases atuais, isolando estados `loading/empty/error/data` por bloco para resiliencia. Evoluir por TDD com testes widget e golden, sem mudancas de dominio.

**Tech Stack:** Flutter (Cupertino), Riverpod, flutter_test, golden tests existentes do projeto, fvm.

---

### Task 1: Add reverent visual tokens for Home

**Files:**
- Modify: `lib/core/theme/cupertino_tokens.dart`
- Modify: `lib/core/theme/app_theme.dart`
- Test: `test/core/presentation/design_contracts_test.dart`

**Step 1: Write the failing test**

```dart
test('home reverent tokens are exposed', () {
  expect(IaculaColors.homeWarmBackground.value, 0xFFFFFAF3);
  expect(IaculaColors.homeSacredAccent.value, 0xFFB08A57);
});
```

**Step 2: Run test to verify it fails**

Run: `fvm flutter test test/core/presentation/design_contracts_test.dart -r expanded`
Expected: FAIL because new Home tokens do not exist.

**Step 3: Write minimal implementation**

```dart
class IaculaColors {
  static const homeWarmBackground = Color(0xFFFFFAF3);
  static const homeSacredAccent = Color(0xFFB08A57);
  static const homeHeroTop = Color(0xFFF6EFE3);
  static const homeHeroBottom = Color(0xFFFDF9F2);
}
```

Update `app_theme.dart` only if needed so Cupertino defaults keep using shared tokenized colors.

**Step 4: Run test to verify it passes**

Run: `fvm flutter test test/core/presentation/design_contracts_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/core/theme/cupertino_tokens.dart lib/core/theme/app_theme.dart test/core/presentation/design_contracts_test.dart
git commit -m "feat(theme): add reverent home visual tokens"
```

### Task 2: Extract and implement HomeHeroCard with explicit states

**Files:**
- Create: `lib/features/home/presentation/widgets/home_hero_card.dart`
- Modify: `lib/features/home/presentation/home_screen.dart`
- Test: `test/features/home/home_screen_test.dart`

**Step 1: Write the failing test**

```dart
testWidgets('home renders hero card before quick actions', (tester) async {
  await tester.pumpWidget(_buildApp(...));
  await tester.pumpAndSettle();

  final hero = find.byKey(const Key('home_hero_card'));
  final actions = find.byKey(const Key('home_action_grid'));
  expect(hero, findsOneWidget);
  expect(actions, findsOneWidget);
});
```

**Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/home/home_screen_test.dart -r expanded`
Expected: FAIL because hero key/component is missing.

**Step 3: Write minimal implementation**

```dart
class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onPressed,
  });
  // build: gradient container + text + primary button
}
```

In `home_screen.dart`, replace inline promo header block with `HomeHeroCard(key: Key('home_hero_card'), ...)`.

**Step 4: Run test to verify it passes**

Run: `fvm flutter test test/features/home/home_screen_test.dart -r expanded`
Expected: PASS for new hero ordering test.

**Step 5: Commit**

```bash
git add lib/features/home/presentation/widgets/home_hero_card.dart lib/features/home/presentation/home_screen.dart test/features/home/home_screen_test.dart
git commit -m "feat(home): introduce hero card with welcoming hierarchy"
```

### Task 3: Standardize HomeActionGrid visual rhythm and labels

**Files:**
- Create: `lib/features/home/presentation/widgets/home_action_grid.dart`
- Modify: `lib/features/home/presentation/home_screen.dart`
- Test: `test/features/home/home_screen_test.dart`

**Step 1: Write the failing test**

```dart
testWidgets('home action grid exposes expected actions and context text', (tester) async {
  await tester.pumpWidget(_buildApp(...));
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('home_action_grid')), findsOneWidget);
  expect(find.text('Orações'), findsOneWidget);
  expect(find.text('Liturgia'), findsOneWidget);
});
```

**Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/home/home_screen_test.dart -r expanded`
Expected: FAIL because extracted grid key/component does not exist.

**Step 3: Write minimal implementation**

```dart
class HomeActionGrid extends StatelessWidget {
  const HomeActionGrid({super.key, required this.actions});
  // two-column responsive grid using existing navigation callbacks
}
```

Use consistent card height, internal spacing, and press feedback.

**Step 4: Run test to verify it passes**

Run: `fvm flutter test test/features/home/home_screen_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/home/presentation/widgets/home_action_grid.dart lib/features/home/presentation/home_screen.dart test/features/home/home_screen_test.dart
git commit -m "refactor(home): extract and standardize action grid"
```

### Task 4: Add HomeContinuationCard for resume journey pattern

**Files:**
- Create: `lib/features/home/presentation/widgets/home_continuation_card.dart`
- Modify: `lib/features/home/presentation/home_screen.dart`
- Test: `test/features/home/home_screen_test.dart`

**Step 1: Write the failing test**

```dart
testWidgets('home shows continuation card after action grid', (tester) async {
  await tester.pumpWidget(_buildApp(...));
  await tester.pumpAndSettle();

  expect(find.byKey(const Key('home_continuation_card')), findsOneWidget);
});
```

**Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/home/home_screen_test.dart -r expanded`
Expected: FAIL because continuation card is missing.

**Step 3: Write minimal implementation**

```dart
class HomeContinuationCard extends StatelessWidget {
  const HomeContinuationCard({super.key, required this.title, required this.onTap});
  // "Continue seu caminho" + chevron + lightweight metadata line
}
```

Insert this card after quick actions and before secondary sections.

**Step 4: Run test to verify it passes**

Run: `fvm flutter test test/features/home/home_screen_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/home/presentation/widgets/home_continuation_card.dart lib/features/home/presentation/home_screen.dart test/features/home/home_screen_test.dart
git commit -m "feat(home): add continuation card for journey resume"
```

### Task 5: Isolate per-block loading/empty/error states

**Files:**
- Modify: `lib/features/home/presentation/home_screen.dart`
- Modify: `lib/core/presentation/design/iacula_feedback.dart`
- Test: `test/features/home/home_screen_test.dart`

**Step 1: Write the failing test**

```dart
testWidgets('hero error does not remove quick actions', (tester) async {
  await tester.pumpWidget(_buildAppWithQuoteError(...));
  await tester.pumpAndSettle();

  expect(find.text('Tentar novamente'), findsOneWidget);
  expect(find.byKey(const Key('home_action_grid')), findsOneWidget);
});
```

**Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/home/home_screen_test.dart -r expanded`
Expected: FAIL because current top-level `quoteAsync.when` blocks entire screen.

**Step 3: Write minimal implementation**

```dart
// move async branching into hero section only
Widget _buildHero(AsyncValue<Quote> quoteAsync) {
  return quoteAsync.when(
    loading: () => const _HeroLoading(),
    error: (_, __) => IaculaErrorState(...),
    data: (quote) => HomeHeroCard(...),
  );
}
```

Keep action grid and remaining sections always renderable.

**Step 4: Run test to verify it passes**

Run: `fvm flutter test test/features/home/home_screen_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/home/presentation/home_screen.dart lib/core/presentation/design/iacula_feedback.dart test/features/home/home_screen_test.dart
git commit -m "refactor(home): make block-level async states resilient"
```

### Task 6: Add meaningful but subtle motion

**Files:**
- Modify: `lib/features/home/presentation/home_screen.dart`
- Test: `test/features/home/home_screen_test.dart`

**Step 1: Write the failing test**

```dart
testWidgets('home hero fades in on first frame', (tester) async {
  await tester.pumpWidget(_buildApp(...));
  expect(find.byType(AnimatedOpacity), findsWidgets);
});
```

**Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/home/home_screen_test.dart -r expanded`
Expected: FAIL because no explicit motion wrapper exists.

**Step 3: Write minimal implementation**

```dart
// wrap hero/action/continuation with implicit animations
AnimatedOpacity(
  duration: const Duration(milliseconds: 280),
  opacity: _ready ? 1 : 0,
  child: HomeHeroCard(...),
)
```

Use low-amplitude, short-duration animations only.

**Step 4: Run test to verify it passes**

Run: `fvm flutter test test/features/home/home_screen_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/home/presentation/home_screen.dart test/features/home/home_screen_test.dart
git commit -m "feat(home): add subtle staged entrance motion"
```

### Task 7: Add/refresh golden tests for Home visual guardrails

**Files:**
- Create/Modify: `test/features/home/home_screen_golden_test.dart`
- Create (if missing): `test/features/home/goldens/home_screen_default.png`
- Create (if missing): `test/features/home/goldens/home_screen_compact.png`

**Step 1: Write the failing golden test**

```dart
testWidgets('home golden default width', (tester) async {
  await tester.pumpWidget(_buildApp(...));
  await expectLater(
    find.byType(HomeScreen),
    matchesGoldenFile('features/home/goldens/home_screen_default.png'),
  );
});
```

**Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/home/home_screen_golden_test.dart -r expanded`
Expected: FAIL because baseline image is absent/outdated.

**Step 3: Generate/update baseline and minimal fixes**

```bash
fvm flutter test test/features/home/home_screen_golden_test.dart --update-goldens
```

Then adjust paddings/text overflow only if golden review indicates clipping.

**Step 4: Run test to verify it passes**

Run: `fvm flutter test test/features/home/home_screen_golden_test.dart -r expanded`
Expected: PASS.

**Step 5: Commit**

```bash
git add test/features/home/home_screen_golden_test.dart test/features/home/goldens/home_screen_default.png test/features/home/goldens/home_screen_compact.png
git commit -m "test(home): add golden baselines for reverent home"
```

### Task 8: Final verification and docs alignment

**Files:**
- Modify: `docs/ui/cupertino-standards-checklist.md` (only if new reusable pattern rules are needed)
- Verify existing changed files.

**Step 1: Run formatter**

Run: `fvm dart format lib/features/home/presentation/home_screen.dart lib/features/home/presentation/widgets/home_hero_card.dart lib/features/home/presentation/widgets/home_action_grid.dart lib/features/home/presentation/widgets/home_continuation_card.dart test/features/home/home_screen_test.dart test/features/home/home_screen_golden_test.dart`
Expected: files formatted, no errors.

**Step 2: Run targeted tests**

Run: `fvm flutter test test/features/home -r expanded`
Expected: PASS for all Home tests.

**Step 3: Run static analysis**

Run: `fvm flutter analyze`
Expected: PASS (or only known pre-existing issues outside scope, documented).

**Step 4: Commit final polish**

```bash
git add docs/ui/cupertino-standards-checklist.md lib/features/home test/features/home
git commit -m "chore(home): finalize contemporary reverent home rollout"
```

