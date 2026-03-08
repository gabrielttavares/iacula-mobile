# Phase 3 Search Discovery Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** evolve the current mixed local search into a structured discovery experience with ranked results, grouped sections, and better empty-state guidance.

**Architecture:** Keep search local. Extend the current search application layer to return scored, sectioned discovery results and update the search screen to render grouped sections, recent queries, and suggested prompts. Preserve existing destination routes.

**Tech Stack:** Flutter, Cupertino widgets, Riverpod, local repositories, widget tests

---

### Task 1: Lock desired search behavior in tests

**Files:**
- Modify: `test/features/search/app_search_service_test.dart`
- Modify: `test/features/search/presentation/search_screen_test.dart`

**Step 1: Write failing ranking tests**

Require:

- title matches outrank content-only matches
- results carry a section
- results are grouped deterministically by type

**Step 2: Write failing screen tests**

Require:

- empty search shows suggestions or recent search guidance
- results render section headers
- tapping a suggestion triggers a search

**Step 3: Run targeted tests to confirm failures**

Run: `~/fvm/versions/stable/bin/flutter test test/features/search/app_search_service_test.dart test/features/search/presentation/search_screen_test.dart`

Expected: FAIL before implementation.

**Step 4: Commit**

```bash
git add test/features/search/app_search_service_test.dart test/features/search/presentation/search_screen_test.dart
git commit -m "test(search): lock discovery ranking and grouping"
```

### Task 2: Extend the search application model

**Files:**
- Modify: `lib/features/search/application/app_search_service.dart`

**Step 1: Add explicit section/score metadata**

Extend the result model to expose:

- section label or enum
- relevance score
- stable ordering inputs

**Step 2: Implement deterministic ranking**

Use a simple scoring system favoring title matches over metadata matches over long-text matches.

**Step 3: Sort and group-compatible output**

Return results in score order while preserving enough metadata for UI section rendering.

**Step 4: Run search service tests**

Run: `~/fvm/versions/stable/bin/flutter test test/features/search/app_search_service_test.dart`

Expected: PASS

**Step 5: Commit**

```bash
git add lib/features/search/application/app_search_service.dart test/features/search/app_search_service_test.dart
git commit -m "feat(search): add ranking and sections to discovery service"
```

### Task 3: Upgrade the search screen into a discovery surface

**Files:**
- Modify: `lib/features/search/presentation/search_screen.dart`
- Optional create: `lib/features/search/presentation/search_recent_queries.dart`

**Step 1: Add empty-state discovery UI**

Render:

- recent queries if available
- suggested search chips otherwise or alongside

Keep it lightweight and local-only.

**Step 2: Render grouped results**

Add section headers for result groups while preserving the current direct navigation by type.

**Step 3: Keep debounce and direct navigation**

Do not redesign the route model.

**Step 4: Run the search screen tests**

Run: `~/fvm/versions/stable/bin/flutter test test/features/search/presentation/search_screen_test.dart`

Expected: PASS

**Step 5: Commit**

```bash
git add lib/features/search/presentation/search_screen.dart lib/features/search/presentation/search_recent_queries.dart test/features/search/presentation/search_screen_test.dart
git commit -m "feat(search): add grouped discovery UI"
```

If no new file is created, omit it from the commit command.

### Task 4: Verify integration with the wider app

**Files:**
- Verify: `lib/core/di/providers.dart`
- Verify: `test/features/home/home_search_navigates_test.dart`
- Verify: `test/features/premium/shell_premium_navigation_test.dart`

**Step 1: Run adjacent regression tests**

Run: `~/fvm/versions/stable/bin/flutter test test/features/home/home_search_navigates_test.dart test/features/premium/shell_premium_navigation_test.dart`

Expected: PASS

**Step 2: Confirm title stability**

Check that `Meditação` and `Plano de vida` labels remain unchanged in affected flows.

**Step 3: Commit**

Skip commit if no file changes were required.

### Task 5: Full verification

**Files:**
- Verify only

**Step 1: Run UI standards audit**

Run: `bash tool/ui_standards_check.sh`

Expected: `UI standards check passed.`

**Step 2: Run the full suite**

Run: `~/fvm/versions/stable/bin/flutter test`

Expected: `All tests passed!`

**Step 3: Run analyzer**

Run: `~/fvm/versions/stable/bin/flutter analyze`

Expected: no new analyzer errors; report any remaining pre-existing warnings/info accurately.

**Step 4: Commit final integration if needed**

```bash
git add -A
git commit -m "feat: complete phase 3 search discovery pass"
```

Use this only if earlier commits were skipped.
