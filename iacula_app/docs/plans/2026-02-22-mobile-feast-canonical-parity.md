# Mobile Feast Canonical Parity Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make mobile feast detection and slug resolution strictly canonical and parity-complete with desktop feast behavior, while preserving offline-first operation.

**Architecture:** Mobile `RemoteLiturgicalSeasonService` becomes the single source of canonical feast slug mapping. It detects feast by explicit pattern first, then rank-based slugify + alias canonicalization. Quote/image lookup remains canonical-only and uses existing offline bundled assets with graceful image fallback.

**Tech Stack:** Flutter, Dart 3.11, Riverpod, Flutter test, asset bundle JSON/image loading.

---

### Task 1: Baseline verification snapshot

**Files:**
- Test: `/Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/test/features/liturgical/remote_liturgical_context_service_test.dart`
- Test: `/Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/test/features/liturgical/remote_liturgical_season_service_test.dart`

**Step 1: Run liturgical tests before changes**

Run:
```bash
cd /Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app
fvm flutter test test/features/liturgical/remote_liturgical_context_service_test.dart test/features/liturgical/remote_liturgical_season_service_test.dart -r expanded
```

Expected: Current tests pass and establish baseline.

**Step 2: Commit checkpoint (optional if clean baseline)**

```bash
git status --short
```

Expected: clean working tree before feature edits.

---

### Task 2: Add failing tests for canonical slug normalization

**Files:**
- Modify: `/Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/test/features/liturgical/remote_liturgical_context_service_test.dart`
- Modify: `/Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/test/features/liturgical/remote_liturgical_season_service_test.dart`

**Step 1: Write failing canonicalization tests**

Add tests for:
- `Domingo de Pentecostes, Solenidade` -> `context.feast == 'pentecost'`
- `Sao Jose, Esposo da Bem-Aventurada Virgem Maria, Solenidade` -> `context.feast == 'st-joseph'`

Example skeleton:
```dart
test('normalizes domingo-de-pentecostes slug to pentecost', () async {
  // mock response with liturgia Domingo de Pentecostes
  // expect context.feast == 'pentecost'
});

test('normalizes long sao jose slug to st-joseph', () async {
  // mock response with long Sao Jose title
  // expect context.feast == 'st-joseph'
});
```

**Step 2: Run tests to verify they fail**

Run:
```bash
fvm flutter test test/features/liturgical/remote_liturgical_context_service_test.dart test/features/liturgical/remote_liturgical_season_service_test.dart -r expanded
```

Expected: FAIL for at least one new canonicalization assertion.

**Step 3: Commit tests-in-red checkpoint**

```bash
git add /Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/test/features/liturgical/remote_liturgical_context_service_test.dart /Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/test/features/liturgical/remote_liturgical_season_service_test.dart
git commit -m "test(mobile): add failing canonical feast slug normalization cases"
```

---

### Task 3: Add failing tests for expanded feast pattern mapping + Holy Week season rule

**Files:**
- Modify: `/Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/test/features/liturgical/remote_liturgical_context_service_test.dart`
- Modify: `/Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/test/features/liturgical/remote_liturgical_season_service_test.dart`

**Step 1: Add pattern detection tests (red)**

Add tests for:
- `Domingo de Ramos` -> `palm-sunday`
- `Semana Santa ... Ceia do Senhor` -> `holy-thursday`
- `Paixao do Senhor` -> `good-friday`
- `Vigilia Pascal` -> `easter-vigil`
- `Domingo de Pascoa` -> `easter-sunday`

**Step 2: Add Holy Week season override test (red)**

Case:
- API payload `cor=Vermelho` + liturgy containing `Semana Santa` or `Paixao` => season is `lent`.

**Step 3: Execute tests and confirm red**

Run:
```bash
fvm flutter test test/features/liturgical/remote_liturgical_context_service_test.dart test/features/liturgical/remote_liturgical_season_service_test.dart -r expanded
```

Expected: New tests fail before implementation.

**Step 4: Commit red tests**

```bash
git add /Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/test/features/liturgical/remote_liturgical_context_service_test.dart /Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/test/features/liturgical/remote_liturgical_season_service_test.dart
git commit -m "test(mobile): add failing feast pattern and Holy Week mapping cases"
```

---

### Task 4: Implement canonical feast detection parity in remote liturgical service

**Files:**
- Modify: `/Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/lib/features/liturgical/infrastructure/services/remote_liturgical_season_service.dart`

**Step 1: Add FEAST_PATTERNS table parity**

Insert a static list of keyword groups mapped to canonical slugs:
- palm-sunday, holy-thursday, good-friday, easter-vigil, easter-sunday,
- pentecost, holy-trinity, corpus-christi, all-saints,
- immaculate-conception, assumption, st-joseph, sts-peter-paul, our-lady-aparecida.

**Step 2: Update `_detectFeast` order**

Algorithm:
1. Check pattern matches first and return canonical slug.
2. If rank is solemnity/feast, slugify feastName and canonicalize via alias map.
3. Else return null.

**Step 3: Update `_mapSeason` Holy Week override**

Before color switch, force `LiturgicalSeason.lent` when normalized liturgy contains:
- `semana santa`
- `paixao do senhor`
- `paixao`

**Step 4: Keep canonical-only behavior**

No fallback to raw/legacy slugs in this service. Return canonical slugs only.

**Step 5: Run liturgical tests to green**

Run:
```bash
fvm flutter test test/features/liturgical/remote_liturgical_context_service_test.dart test/features/liturgical/remote_liturgical_season_service_test.dart -r expanded
```

Expected: all liturgical tests PASS.

**Step 6: Commit implementation**

```bash
git add /Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/lib/features/liturgical/infrastructure/services/remote_liturgical_season_service.dart /Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/test/features/liturgical/remote_liturgical_context_service_test.dart /Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/test/features/liturgical/remote_liturgical_season_service_test.dart
git commit -m "feat(mobile): implement canonical feast detection parity for liturgical context"
```

---

### Task 5: Prove canonical slug consumption in quote selection

**Files:**
- Modify: `/Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/test/features/quotes/get_next_quote_parity_use_case_test.dart`

**Step 1: Add canonical consumption assertions**

Add a test double that records slug input for:
- `loadFeastQuotes(slug)`
- `getFeastImagePath(slug)`

New assertion set:
- Returned context with non-canonical feast phrase still produces canonical slug requests.
- Both methods receive canonical slug (`pentecost`, `st-joseph`, etc.).

**Step 2: Run quote parity test**

Run:
```bash
fvm flutter test test/features/quotes/get_next_quote_parity_use_case_test.dart -r expanded
```

Expected: PASS.

**Step 3: Commit quote parity coverage**

```bash
git add /Users/gabrielttav/projects/side/iacula/iacula_mobile/Iacula_flutter/iacula_app/test/features/quotes/get_next_quote_parity_use_case_test.dart
git commit -m "test(mobile): assert canonical feast slug use in quote asset lookup"
```

---

### Task 6: Full regression verification

**Files:**
- Verify only (no source edits expected)

**Step 1: Run full suite**

Run:
```bash
fvm flutter test -r expanded
```

Expected: all tests PASS.

**Step 2: Inspect diff for unintended changes**

Run:
```bash
git status --short
git diff --name-only
```

Expected: only planned files changed.

**Step 3: Commit verification marker (if any final changes)**

```bash
git add .
git commit -m "chore(mobile): finalize canonical feast parity verification"
```

---

### Task 7: Push and release notes snapshot

**Files:**
- Docs/update note in PR description or release note (if applicable)

**Step 1: Push branch/main according to current flow**

Run:
```bash
git push origin main
```

**Step 2: Capture release summary**

Include:
- Canonical feast slug parity achieved.
- Expanded feast mapping coverage.
- Holy Week/Lent mapping parity.
- Offline-first behavior unchanged.

---

## Explicit Non-Goals
- No desktop repo changes.
- No new feast images/assets added.
- No manifest generation scripts in mobile.
- No `easterTime` setting implementation.

## Acceptance Checklist
- [ ] Canonical slug tests for Pentecost and Sao Jose pass.
- [ ] Pattern mapping tests for key movable feasts pass.
- [ ] Holy Week red-color case maps to Lent.
- [ ] Quote use case requests canonical slugs only.
- [ ] Full mobile test suite passes.
- [ ] Only intended files were modified.
