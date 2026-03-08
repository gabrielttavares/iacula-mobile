# Phase 2 Product Clarity Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** reshape Home and onboarding around immediate product clarity, with a guided primary action on Home and a simpler promise-first onboarding flow.

**Architecture:** This phase stays presentation-led. Reuse current providers, data sources, and routes; add only small presentation helpers where the Home hero needs a clearer "recommended next step" contract. Preserve navigation and domain logic unless a test proves a minimal wiring change is needed.

**Tech Stack:** Flutter, Cupertino widgets, Riverpod, widget tests, golden tests

---

### Task 1: Inventory the current Home and onboarding contracts

**Files:**
- Inspect: `lib/features/home/presentation/home_screen.dart`
- Inspect: `lib/features/home/presentation/widgets/home_action_grid.dart`
- Inspect: `lib/features/onboarding/presentation/onboarding_screen.dart`
- Inspect: `test/features/home/home_screen_test.dart`
- Inspect: `test/features/home/home_screen_golden_test.dart`
- Inspect: `test/features/onboarding/onboarding_screen_test.dart`

**Step 1: Read the current presentation code**

Run: `sed -n '1,260p' lib/features/home/presentation/home_screen.dart`

Expected: identify the current hero, quick actions, and exploration order.

**Step 2: Read the Home tests**

Run: `sed -n '1,260p' test/features/home/home_screen_test.dart`

Expected: list the assertions that already lock hierarchy and labels.

**Step 3: Read onboarding code and tests**

Run: `sed -n '1,240p' lib/features/onboarding/presentation/onboarding_screen.dart`

Run: `sed -n '1,220p' test/features/onboarding/onboarding_screen_test.dart`

Expected: identify current promise, proof points, and CTA assertions.

**Step 4: Write a short implementation note**

Record which existing components can be reused as-is and which need restructuring before editing.

**Step 5: Commit**

Skip commit if no files changed.

### Task 2: Lock the new Home hierarchy with failing tests

**Files:**
- Modify: `test/features/home/home_screen_test.dart`
- Modify: `test/features/home/home_screen_golden_test.dart`

**Step 1: Write the failing hierarchy assertions**

Add/adjust tests to require:

- one primary guided hero/action above quick actions
- quick actions below the hero
- exploration sections below quick actions
- CTA text that implies immediate action

**Step 2: Run the Home tests to verify they fail**

Run: `~/fvm/versions/stable/bin/flutter test test/features/home/home_screen_test.dart test/features/home/home_screen_golden_test.dart`

Expected: FAIL because current structure or copy does not satisfy the new expectations.

**Step 3: Add or update golden expectations only after functional assertions are written**

Keep the golden test in place so visual hierarchy changes are intentional.

**Step 4: Commit**

```bash
git add test/features/home/home_screen_test.dart test/features/home/home_screen_golden_test.dart
git commit -m "test(home): lock phase 2 clarity hierarchy"
```

### Task 3: Implement the guided Home hero

**Files:**
- Modify: `lib/features/home/presentation/home_screen.dart`
- Modify: `lib/features/home/presentation/widgets/home_action_grid.dart`
- Optional create: `lib/features/home/presentation/home_primary_action.dart`

**Step 1: Introduce a clear primary action model in the UI layer**

If needed, create a small presentation helper describing:

- title
- supporting copy
- CTA label
- action target

Do not create a new domain layer abstraction.

**Step 2: Implement the new hero structure**

Update Home so the top block contains:

- a situational title
- a concise explanation
- a primary CTA into the recommended action

Keep the existing quick actions below it.

**Step 3: Preserve the exploration rails**

Keep themes, saints, novenas, and readings available below the primary action.

**Step 4: Run the Home tests**

Run: `~/fvm/versions/stable/bin/flutter test test/features/home/home_screen_test.dart`

Expected: PASS

**Step 5: Update the goldens**

Run: `~/fvm/versions/stable/bin/flutter test --update-goldens test/features/home/home_screen_golden_test.dart`

Then run:

`~/fvm/versions/stable/bin/flutter test test/features/home/home_screen_golden_test.dart`

Expected: PASS

**Step 6: Commit**

```bash
git add lib/features/home/presentation/home_screen.dart lib/features/home/presentation/widgets/home_action_grid.dart lib/features/home/presentation/home_primary_action.dart test/features/home/home_screen_test.dart test/features/home/home_screen_golden_test.dart test/features/home/goldens
git commit -m "feat(home): guide users to the next prayer step"
```

If `home_primary_action.dart` is not created, omit it from the commit command.

### Task 4: Lock the onboarding narrative with failing tests

**Files:**
- Modify: `test/features/onboarding/onboarding_screen_test.dart`

**Step 1: Add assertions for promise-first onboarding**

Require:

- a single clear promise near the top
- no more than three proof points
- clearer primary and secondary CTAs
- the account vs guest distinction remaining obvious

**Step 2: Run the onboarding test to verify it fails**

Run: `~/fvm/versions/stable/bin/flutter test test/features/onboarding/onboarding_screen_test.dart`

Expected: FAIL before implementation.

**Step 3: Commit**

```bash
git add test/features/onboarding/onboarding_screen_test.dart
git commit -m "test(onboarding): lock promise-first onboarding flow"
```

### Task 5: Implement the onboarding clarity pass

**Files:**
- Modify: `lib/features/onboarding/presentation/onboarding_screen.dart`
- Modify: `test/features/onboarding/onboarding_screen_test.dart`

**Step 1: Reduce onboarding to one promise plus up to three proofs**

Rewrite the top structure so the promise is dominant and the support items are concise.

**Step 2: Keep CTAs explicit**

Primary CTA should clearly start the journey.

Secondary CTA should clearly allow continued use without account creation.

**Step 3: Run the onboarding test**

Run: `~/fvm/versions/stable/bin/flutter test test/features/onboarding/onboarding_screen_test.dart`

Expected: PASS

**Step 4: If onboarding layout changes materially, add/update a golden**

If a golden does not exist and the layout changed enough to justify one, create it with the smallest stable surface possible.

**Step 5: Commit**

```bash
git add lib/features/onboarding/presentation/onboarding_screen.dart test/features/onboarding/onboarding_screen_test.dart
git commit -m "feat(onboarding): clarify product promise and entry choices"
```

### Task 6: Align premium and feedback copy with the new clarity model

**Files:**
- Modify: `lib/features/premium/presentation/premium_gate.dart`
- Modify: `lib/features/premium/presentation/paywall_screen.dart`
- Modify: `lib/features/premium/presentation/premium_copy.dart`
- Modify: `test/features/premium/paywall_auth_section_test.dart`
- Modify: `test/features/premium/paywall_screen_test.dart`
- Modify: `test/features/premium/shell_premium_navigation_test.dart`

**Step 1: Write or update tests for copy alignment**

Require premium language to remain consistent with the new "what do I do now?" framing.

**Step 2: Run targeted premium tests and confirm failures if assertions changed**

Run: `~/fvm/versions/stable/bin/flutter test test/features/premium/paywall_auth_section_test.dart test/features/premium/paywall_screen_test.dart test/features/premium/shell_premium_navigation_test.dart`

Expected: FAIL if new copy expectations differ.

**Step 3: Update premium copy only as much as needed**

Do not redesign premium flow here.

Keep scope to:

- consistency with Home/onboarding
- less interruption of product understanding
- clearer preview/value language

**Step 4: Re-run the premium tests**

Run: `~/fvm/versions/stable/bin/flutter test test/features/premium/paywall_auth_section_test.dart test/features/premium/paywall_screen_test.dart test/features/premium/shell_premium_navigation_test.dart`

Expected: PASS

**Step 5: Commit**

```bash
git add lib/features/premium/presentation/premium_gate.dart lib/features/premium/presentation/paywall_screen.dart lib/features/premium/presentation/premium_copy.dart test/features/premium/paywall_auth_section_test.dart test/features/premium/paywall_screen_test.dart test/features/premium/shell_premium_navigation_test.dart
git commit -m "chore(premium): align messaging with phase 2 clarity"
```

### Task 7: Run full verification

**Files:**
- Verify only

**Step 1: Run the standards audit**

Run: `bash tool/ui_standards_check.sh`

Expected: `UI standards check passed.`

**Step 2: Run the full test suite**

Run: `~/fvm/versions/stable/bin/flutter test`

Expected: `All tests passed!`

**Step 3: Run analyzer**

Run: `~/fvm/versions/stable/bin/flutter analyze`

Expected: no new errors; if warnings remain, document whether they are pre-existing or introduced.

**Step 4: Review diff quality**

Run: `git diff --stat`

Expected: only Phase 2 Home/onboarding/premium clarity files changed.

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: complete phase 2 product clarity pass"
```

Use this final commit only if earlier task commits were skipped; otherwise omit.
