# Personal Phrases Feed Share Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the all-or-nothing "Usar apenas minhas frases" toggle with a guaranteed 1-in-4 feed share for eligible personal phrases (hero + notifications), bury the pure-replace mode in Settings, and strip the toggle off the Minhas Jaculatórias screen.

**Architecture:** A new pure, deterministic domain service, `PersonalPhraseFeedSelector`, decides for any given slot index / fire time whether that slot is "personal" (1 in every 4) and, if so, which eligible phrase fills it. It is unit-tested in isolation. It is then wired into the notification `quoteFetcher` (so personal slots return a `QuoteSource.personal` quote instead of a liturgical draw — same slot, same id, same budget) and into the home hero's `_homeQuoteProvider`. Default-mode scheduling (no eligible phrases) is byte-for-byte unchanged. The `customPhrasesOnly` flag is reused as the buried pure-replace escape hatch in Settings.

**Tech Stack:** Flutter (Cupertino), Riverpod, `flutter_test`. Run all commands with `fvm`.

---

## File Structure

| File | Responsibility | Change |
|------|----------------|--------|
| `lib/features/custom_phrases/domain/services/personal_phrase_feed_selector.dart` | Pure deterministic selection: is slot N personal? which phrase? eligibility filter. | Create |
| `test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart` | Unit tests for the selector. | Create |
| `lib/core/di/providers.dart` | Wire selector into `quoteFetcher` (notifications). | Modify (`:607-624`) |
| `lib/features/home/presentation/home_screen.dart` | Use selector for hero default case; keep `customPhrasesOnly` only for buried replace mode. | Modify (`_homeQuoteProvider`) |
| `lib/features/jaculatorias/presentation/minhas_jaculatorias_screen.dart` | Remove the toggle card + its state/handlers. | Modify |
| `lib/features/settings/presentation/settings_screen.dart` | Add buried pure-replace control under Personalização. | Modify |

---

## Task 1: PersonalPhraseFeedSelector — slot cadence

**Files:**
- Create: `lib/features/custom_phrases/domain/services/personal_phrase_feed_selector.dart`
- Test: `test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart`

The selector decides whether a given zero-based slot index is a "personal" slot. Share is 1 in 4: slot indices where `index % 4 == 3` are personal (the 4th of every group), so the first three of each run stay liturgical. Deterministic — same index always yields the same answer.

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/custom_phrases/domain/services/personal_phrase_feed_selector.dart';

void main() {
  group('PersonalPhraseFeedSelector.isPersonalSlot', () {
    test('every 4th slot (index 3, 7, 11) is personal', () {
      expect(PersonalPhraseFeedSelector.isPersonalSlot(0), isFalse);
      expect(PersonalPhraseFeedSelector.isPersonalSlot(1), isFalse);
      expect(PersonalPhraseFeedSelector.isPersonalSlot(2), isFalse);
      expect(PersonalPhraseFeedSelector.isPersonalSlot(3), isTrue);
      expect(PersonalPhraseFeedSelector.isPersonalSlot(7), isTrue);
      expect(PersonalPhraseFeedSelector.isPersonalSlot(11), isTrue);
    });

    test('is deterministic for the same index', () {
      expect(
        PersonalPhraseFeedSelector.isPersonalSlot(3),
        PersonalPhraseFeedSelector.isPersonalSlot(3),
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart`
Expected: FAIL — `Error: Method not found: 'PersonalPhraseFeedSelector.isPersonalSlot'` / target of URI doesn't exist.

- [ ] **Step 3: Write minimal implementation**

```dart
/// Decides which feed slots are filled by personal phrases and which phrase
/// fills them. Pure and deterministic: the same inputs always yield the same
/// result, so re-running a scheduling pass never re-rolls a slot.
final class PersonalPhraseFeedSelector {
  const PersonalPhraseFeedSelector._();

  /// 1-in-4 share: the 4th slot of every run (index 3, 7, 11, …) is personal.
  /// The first three of each run stay liturgical, so liturgical content
  /// clearly dominates.
  static const int shareStride = 4;

  static bool isPersonalSlot(int slotIndex) =>
      slotIndex % shareStride == shareStride - 1;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/custom_phrases/domain/services/personal_phrase_feed_selector.dart test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart
git commit -m "feat: add PersonalPhraseFeedSelector slot cadence"
```

---

## Task 2: PersonalPhraseFeedSelector — eligibility filters

**Files:**
- Modify: `lib/features/custom_phrases/domain/services/personal_phrase_feed_selector.dart`
- Test: `test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart`

Eligibility reuses existing flags (no new field). Hero eligibility: `isActive && displayOnHero`. Notification eligibility: `isActive && displayAsNotification`. Both also require rotation mode (`!useFixedSchedule`) — fixed-schedule phrases keep their own independent notification path and must not be double-counted.

- [ ] **Step 1: Write the failing test (append to existing file's `main`)**

```dart
import 'package:iacula_app/features/custom_phrases/domain/entities/custom_phrase.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/phrase_schedule.dart';

CustomPhrase _phrase({
  String id = 'p1',
  bool isActive = true,
  bool displayOnHero = true,
  bool displayAsNotification = true,
  bool useFixedSchedule = false,
}) {
  return CustomPhrase(
    id: id,
    text: 'Phrase $id',
    isActive: isActive,
    displayOnHero: displayOnHero,
    displayAsNotification: displayAsNotification,
    useFixedSchedule: useFixedSchedule,
    schedule: const PhraseSchedule(
      type: PhraseScheduleType.daily,
      daysOfWeek: [],
      times: [],
    ),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}

// inside main():
  group('PersonalPhraseFeedSelector eligibility', () {
    test('hero eligibility = active + displayOnHero + rotation mode', () {
      final phrases = [
        _phrase(id: 'ok'),
        _phrase(id: 'inactive', isActive: false),
        _phrase(id: 'noHero', displayOnHero: false),
        _phrase(id: 'fixed', useFixedSchedule: true),
      ];
      final eligible = PersonalPhraseFeedSelector.eligibleForHero(phrases);
      expect(eligible.map((p) => p.id), ['ok']);
    });

    test('notification eligibility = active + displayAsNotification + rotation', () {
      final phrases = [
        _phrase(id: 'ok'),
        _phrase(id: 'noNotif', displayAsNotification: false),
        _phrase(id: 'fixed', useFixedSchedule: true),
      ];
      final eligible = PersonalPhraseFeedSelector.eligibleForNotifications(phrases);
      expect(eligible.map((p) => p.id), ['ok']);
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart`
Expected: FAIL — `Method not found: 'PersonalPhraseFeedSelector.eligibleForHero'`.

- [ ] **Step 3: Add the eligibility methods**

Add inside the `PersonalPhraseFeedSelector` class (after `isPersonalSlot`), and add the import at the top:

```dart
// at top of file:
import '../entities/custom_phrase.dart';

// inside the class:
  /// Rotation-mode phrases that may surface on the home hero.
  static List<CustomPhrase> eligibleForHero(List<CustomPhrase> phrases) =>
      phrases
          .where((p) => p.isActive && p.displayOnHero && p.isRotationMode)
          .toList();

  /// Rotation-mode phrases that may take a notification feed slot.
  static List<CustomPhrase> eligibleForNotifications(
    List<CustomPhrase> phrases,
  ) =>
      phrases
          .where((p) =>
              p.isActive && p.displayAsNotification && p.isRotationMode)
          .toList();
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/custom_phrases/domain/services/personal_phrase_feed_selector.dart test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart
git commit -m "feat: add personal phrase feed eligibility filters"
```

---

## Task 3: PersonalPhraseFeedSelector — pick a phrase for a personal slot

**Files:**
- Modify: `lib/features/custom_phrases/domain/services/personal_phrase_feed_selector.dart`
- Test: `test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart`

When a slot is personal, pick which eligible phrase fills it deterministically. Rotate by the personal-slot ordinal (how many personal slots have come before, i.e. `slotIndex ~/ shareStride`) so consecutive personal slots cycle through the pool. Returns `null` when the pool is empty (caller then falls back to a liturgical draw — preserving default behavior).

- [ ] **Step 1: Write the failing test (append to `main`)**

```dart
  group('PersonalPhraseFeedSelector.phraseForSlot', () {
    test('returns null when no eligible phrases', () {
      expect(
        PersonalPhraseFeedSelector.phraseForSlot(slotIndex: 3, eligible: const []),
        isNull,
      );
    });

    test('returns null for a non-personal slot even with phrases', () {
      final pool = [_phrase(id: 'a'), _phrase(id: 'b')];
      expect(
        PersonalPhraseFeedSelector.phraseForSlot(slotIndex: 0, eligible: pool),
        isNull,
      );
    });

    test('cycles through the pool across successive personal slots', () {
      final pool = [_phrase(id: 'a'), _phrase(id: 'b')];
      // personal slots are 3, 7, 11, 15 -> ordinals 0,1,2,3 -> a,b,a,b
      expect(PersonalPhraseFeedSelector.phraseForSlot(slotIndex: 3, eligible: pool)!.id, 'a');
      expect(PersonalPhraseFeedSelector.phraseForSlot(slotIndex: 7, eligible: pool)!.id, 'b');
      expect(PersonalPhraseFeedSelector.phraseForSlot(slotIndex: 11, eligible: pool)!.id, 'a');
      expect(PersonalPhraseFeedSelector.phraseForSlot(slotIndex: 15, eligible: pool)!.id, 'b');
    });

    test('is deterministic for the same slot', () {
      final pool = [_phrase(id: 'a'), _phrase(id: 'b')];
      expect(
        PersonalPhraseFeedSelector.phraseForSlot(slotIndex: 7, eligible: pool)!.id,
        PersonalPhraseFeedSelector.phraseForSlot(slotIndex: 7, eligible: pool)!.id,
      );
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart`
Expected: FAIL — `Method not found: 'PersonalPhraseFeedSelector.phraseForSlot'`.

- [ ] **Step 3: Add the method**

```dart
  /// The eligible phrase that fills the given slot, or null if the slot is not
  /// a personal slot or the pool is empty. Rotates by personal-slot ordinal so
  /// successive personal slots cycle the pool deterministically.
  static CustomPhrase? phraseForSlot({
    required int slotIndex,
    required List<CustomPhrase> eligible,
  }) {
    if (eligible.isEmpty || !isPersonalSlot(slotIndex)) return null;
    final personalOrdinal = slotIndex ~/ shareStride;
    return eligible[personalOrdinal % eligible.length];
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart`
Expected: PASS (8 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/custom_phrases/domain/services/personal_phrase_feed_selector.dart test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart
git commit -m "feat: add deterministic phrase pick for personal feed slots"
```

---

## Task 4: Derive a stable slot index from fire time (notification path)

**Files:**
- Modify: `lib/features/custom_phrases/domain/services/personal_phrase_feed_selector.dart`
- Test: `test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart`

The notification `quoteFetcher` only receives a `now`/`slot` `DateTime`, not an index (see `schedule_core_reminders_use_case.dart:81` — it calls `_quoteFetcher(language:, now: slot)`). To keep the share stable across same-day reschedules (the assignment cache is keyed by fire `DateTime`), derive the slot index deterministically from the fire time: minutes-of-day since midnight divided by a nominal stride. We use a fixed 15-minute granularity (the finest cadence) so the same fire time always maps to the same index regardless of the user's current cadence.

- [ ] **Step 1: Write the failing test (append to `main`)**

```dart
  group('PersonalPhraseFeedSelector.slotIndexForFireTime', () {
    test('maps minutes-of-day to a stable 15-min bucket index', () {
      // 07:00 -> 420 min -> 420/15 = 28
      expect(
        PersonalPhraseFeedSelector.slotIndexForFireTime(
          DateTime(2026, 5, 31, 7, 0),
        ),
        28,
      );
      // 07:15 -> 29
      expect(
        PersonalPhraseFeedSelector.slotIndexForFireTime(
          DateTime(2026, 5, 31, 7, 15),
        ),
        29,
      );
    });

    test('same fire time always yields the same index', () {
      final a = PersonalPhraseFeedSelector.slotIndexForFireTime(
        DateTime(2026, 5, 31, 9, 30),
      );
      final b = PersonalPhraseFeedSelector.slotIndexForFireTime(
        DateTime(2026, 5, 31, 9, 30),
      );
      expect(a, b);
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `fvm flutter test test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart`
Expected: FAIL — `Method not found: 'PersonalPhraseFeedSelector.slotIndexForFireTime'`.

- [ ] **Step 3: Add the method**

```dart
  /// Finest supported cadence; used as the bucket size so a fire time maps to
  /// the same slot index regardless of the user's current cadence setting.
  static const int _bucketMinutes = 15;

  /// A stable slot index for a fire time, so the personal/liturgical decision
  /// for a given DateTime never changes across reschedules.
  static int slotIndexForFireTime(DateTime fireAt) {
    final minutesOfDay = fireAt.hour * 60 + fireAt.minute;
    return minutesOfDay ~/ _bucketMinutes;
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `fvm flutter test test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart`
Expected: PASS (10 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/features/custom_phrases/domain/services/personal_phrase_feed_selector.dart test/features/custom_phrases/domain/personal_phrase_feed_selector_test.dart
git commit -m "feat: derive stable slot index from fire time for personal share"
```

---

## Task 5: Wire personal share into the notification quoteFetcher

**Files:**
- Modify: `lib/core/di/providers.dart:607-624`

In the `quoteFetcher` closure, after loading settings: if NOT in buried replace mode (`!settings.customPhrasesOnly`), check whether this fire time is a personal slot with an eligible phrase; if so, return a `QuoteSource.personal` `Quote` built from it instead of drawing liturgical. Replace mode (`customPhrasesOnly == true`) and the zero-eligible-phrases case both fall through to the existing liturgical/Escrivá draw — so default behavior is unchanged. (Replace mode's full takeover on notifications is out of scope here; it already governs the hero, and the buried Settings copy describes hero + notifications as the intent — full notification replacement can be a follow-up, but for THIS plan replace mode leaves notifications liturgical, exactly as today.)

- [ ] **Step 1: Read the current closure**

Run: `sed -n '607,624p' lib/core/di/providers.dart`
Expected: the `quoteFetcher: ({required String language, required DateTime now}) async { ... }` block shown in the spec.

- [ ] **Step 2: Add imports at the top of providers.dart**

Verify these imports exist; add any that are missing:

```dart
import '../../features/custom_phrases/domain/services/personal_phrase_feed_selector.dart';
import '../../features/quotes/domain/entities/quote.dart';
import '../../features/liturgical/domain/liturgical_season.dart';
```

Run to check current imports: `grep -n "personal_phrase_feed_selector\|domain/entities/quote.dart\|liturgical_season.dart" lib/core/di/providers.dart`

- [ ] **Step 3: Replace the closure body**

Replace lines `607-624` (the `quoteFetcher:` value) with:

```dart
        quoteFetcher:
            ({required String language, required DateTime now}) async {
              final settings = await ref
                  .read(getSettingsUseCaseProvider)
                  .call();

              // Personal phrase share: when not in the buried replace mode, a
              // 1-in-4 slot is filled by an eligible personal phrase. Empty
              // pool falls through to the liturgical draw, so a user with no
              // eligible phrases gets identical scheduling to before.
              if (!settings.customPhrasesOnly) {
                final phrases =
                    await ref.read(customPhraseRepositoryProvider).listAll();
                final eligible =
                    PersonalPhraseFeedSelector.eligibleForNotifications(phrases);
                final slotIndex =
                    PersonalPhraseFeedSelector.slotIndexForFireTime(now);
                final picked = PersonalPhraseFeedSelector.phraseForSlot(
                  slotIndex: slotIndex,
                  eligible: eligible,
                );
                if (picked != null) {
                  return Quote(
                    text: picked.text,
                    dayOfWeek: now.weekday,
                    theme: 'personal',
                    season: LiturgicalSeason.ordinary,
                    imagePath: null,
                    source: QuoteSource.personal,
                  );
                }
              }

              if (settings.escrivaPointsFeedEnabled) {
                return ref
                    .read(getNextEscrivaPointsQuoteUseCaseProvider)
                    .call(
                      language: language,
                      now: now,
                      cadenceMinutes: settings.intervalMinutes,
                    );
              }
              return ref
                  .read(getNextQuoteUseCaseProvider)
                  .call(language: language, now: now);
            },
```

- [ ] **Step 4: Verify it compiles**

Run: `fvm flutter analyze lib/core/di/providers.dart`
Expected: No errors (warnings unrelated to this change are acceptable).

- [ ] **Step 5: Commit**

```bash
git add lib/core/di/providers.dart
git commit -m "feat: inject personal phrase share into notification feed"
```

---

## Task 6: Align the home hero with the share selector

**Files:**
- Modify: `lib/features/home/presentation/home_screen.dart` (`_homeQuoteProvider`, lines ~506-581)

Today the hero has two personal-phrase branches: the `customPhrasesOnly` replace branch (`:512-529`) and a schedule-match fallback (`:564-581`). Keep the replace branch as-is (it is the buried mode's hero behavior). Replace the fallback branch's ad-hoc `schedule.matchesNow` logic so that, in default mode, the hero shows a personal phrase when the current time maps to a personal slot — consistent with notifications. Empty pool falls through to the existing liturgical fallback.

- [ ] **Step 1: Add imports to home_screen.dart**

Verify/add at top:

```dart
import '../../custom_phrases/domain/services/personal_phrase_feed_selector.dart';
```

Run: `grep -n "personal_phrase_feed_selector" lib/features/home/presentation/home_screen.dart`

- [ ] **Step 2: Replace the schedule-match fallback block**

Find this block (currently `home_screen.dart:564-581`):

```dart
  // Fallback: if no regular quote has been delivered today and a personal
  // phrase matches the current schedule, show it. This only applies when
  // using phrases "alongside others" (customPhrasesOnly = false).
  final matching = phrases
      .where((p) => p.isActive && p.displayOnHero && p.schedule.matchesNow(now))
      .toList();

  if (matching.isNotEmpty) {
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final selected = matching[dayOfYear % matching.length];
    return Quote(
      text: selected.text,
      dayOfWeek: now.weekday,
      theme: 'personal',
      season: LiturgicalSeason.ordinary,
      imagePath: null,
      source: QuoteSource.personal,
    );
  }
```

Replace with:

```dart
  // Default-mode personal share: if no regular quote has been delivered today
  // and the current time maps to a personal slot, show an eligible phrase.
  // 1-in-4 cadence, consistent with the notification feed.
  final heroEligible = PersonalPhraseFeedSelector.eligibleForHero(phrases);
  final heroSlotIndex = PersonalPhraseFeedSelector.slotIndexForFireTime(now);
  final heroPersonal = PersonalPhraseFeedSelector.phraseForSlot(
    slotIndex: heroSlotIndex,
    eligible: heroEligible,
  );
  if (heroPersonal != null) {
    return Quote(
      text: heroPersonal.text,
      dayOfWeek: now.weekday,
      theme: 'personal',
      season: LiturgicalSeason.ordinary,
      imagePath: null,
      source: QuoteSource.personal,
    );
  }
```

- [ ] **Step 3: Run the home screen tests**

Run: `fvm flutter test test/features/home/`
Expected: PASS. If a test asserted the old `schedule.matchesNow` fallback, update its expectation to the slot-based behavior (the selector is deterministic, so assert against `slotIndexForFireTime` for the test's `now`).

- [ ] **Step 4: Verify it compiles**

Run: `fvm flutter analyze lib/features/home/presentation/home_screen.dart`
Expected: No errors. If `schedule.matchesNow` is now unused elsewhere, leave it — it is part of the public `PhraseSchedule` API.

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/presentation/home_screen.dart test/features/home/
git commit -m "feat: align home hero personal phrase pick with feed share selector"
```

---

## Task 7: Remove the toggle card from Minhas Jaculatórias

**Files:**
- Modify: `lib/features/jaculatorias/presentation/minhas_jaculatorias_screen.dart`

Delete the "Usar apenas minhas frases" `IaculaSoftCard` (`:159-193`) and the surrounding spacing that only existed for it, plus the now-dead `_customPhrasesOnly` field, `_settingsLoaded` field, `_loadSettings`, `_toggleCustomPhrasesOnly`, and the `initState` call to `_loadSettings`. Keep the alarms section, frases section, and the "Gerenciar jaculatórias padrão" link.

- [ ] **Step 1: Remove the toggle card widget**

Delete this block (currently `:158-194` — from the `SizedBox(height: IaculaSpacing.md)` that precedes the card through the `SizedBox(height: IaculaSpacing.lg)` that follows it). After the "Adicionar frase" `_AddButton` (ends at `:157`), the next widget should become the `Center(child: CupertinoButton(... 'Gerenciar jaculatórias padrão' ...))`. Insert a single `const SizedBox(height: IaculaSpacing.lg)` between the add button and the Center link to preserve spacing.

- [ ] **Step 2: Remove the dead state and handlers**

- Delete the fields `bool _customPhrasesOnly = false;` and `bool _settingsLoaded = false;` (`:28-29`).
- Delete the entire `_loadSettings()` method (`:37-44`).
- Delete the entire `_toggleCustomPhrasesOnly(bool value)` method (`:46-66`).
- In `initState` (`:31-35`), remove the `_loadSettings();` call. If `initState` is now empty besides `super.initState()`, delete the override entirely.
- Remove now-unused imports if the analyzer flags them (e.g. `liturgical_season.dart`, `services.dart` `HapticFeedback` is still used by `_AddButton`/`_DismissiblePhraseRow` — keep `services.dart`).

- [ ] **Step 3: Verify it compiles and analyze**

Run: `fvm flutter analyze lib/features/jaculatorias/presentation/minhas_jaculatorias_screen.dart`
Expected: No errors, no "unused field/method/import" warnings for the removed members.

- [ ] **Step 4: Run jaculatorias-related tests**

Run: `fvm flutter test test/features/custom_phrases/ test/features/jaculatorias/ 2>/dev/null; fvm flutter test test/features/custom_phrases/`
Expected: PASS. If any widget test asserted the toggle's presence on this screen, delete that assertion (the control no longer lives here).

- [ ] **Step 5: Commit**

```bash
git add lib/features/jaculatorias/presentation/minhas_jaculatorias_screen.dart test/
git commit -m "refactor: remove use-only-my-phrases toggle from Minhas Jaculatorias"
```

---

## Task 8: Add the buried pure-replace control in Settings

**Files:**
- Modify: `lib/features/settings/presentation/settings_screen.dart`

Add a row to the existing "Personalização" `IaculaSoftCard` (`:358-395`), below the "Jaculatórias" navigation button, that toggles `customPhrasesOnly`. It is deliberately quiet (a switch row inside an existing section, not its own section, not on the main content screen) with honest, minimal copy. Persist it through the existing `_save()` flow.

- [ ] **Step 1: Add backing state**

In `_SettingsScreenState`, add a field near the other booleans (`:31-38`):

```dart
  bool _customPhrasesOnly = false;
```

In `_load()` (after the other assignments, near `:65`), add:

```dart
    _customPhrasesOnly = settings.customPhrasesOnly;
```

- [ ] **Step 2: Add the control to the Personalização card**

Inside the Personalização `IaculaSoftCard`'s `Column` children (`:360-394`), after the existing "Jaculatórias" `CupertinoButton` and before the `// Pontos de Caminho...` comment, add:

```dart
                        Container(height: 1, color: context.colors.separator),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: IaculaRadius.innerPadding,
                            vertical: 14,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mostrar somente minhas frases',
                                      style: context.textStyles.cardTitle
                                          .copyWith(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Substitui as jaculatórias do tempo pelas suas frases no início do app.',
                                      style: context.textStyles.secondary,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              CupertinoSwitch(
                                value: _customPhrasesOnly,
                                activeTrackColor: context.colors.primaryButton,
                                onChanged: (value) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _customPhrasesOnly = value);
                                },
                              ),
                            ],
                          ),
                        ),
```

- [ ] **Step 3: Persist it in `_save()`**

In `_save()`'s `_loadedSettings.copyWith(...)` call (`:545-557`), add the field:

```dart
      customPhrasesOnly: _customPhrasesOnly,
```

- [ ] **Step 4: Verify it compiles and analyze**

Run: `fvm flutter analyze lib/features/settings/presentation/settings_screen.dart`
Expected: No errors.

- [ ] **Step 5: Run settings tests**

Run: `fvm flutter test test/features/settings/`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/settings/presentation/settings_screen.dart
git commit -m "feat: relocate pure-replace mode to Settings as a quiet control"
```

---

## Task 9: Full suite + analyzer sweep

**Files:** none (verification)

- [ ] **Step 1: Analyze the whole project**

Run: `fvm flutter analyze`
Expected: No new errors introduced by this work.

- [ ] **Step 2: Run the full test suite**

Run: `fvm flutter test`
Expected: PASS. Investigate and fix any failure rather than skipping it.

- [ ] **Step 3: Manual default-mode safety check (read, don't run)**

Confirm by reading `providers.dart` and `home_screen.dart`: with zero eligible personal phrases, `phraseForSlot` returns null in both the fetcher and the hero, so every path falls through to the original liturgical logic. No change to `schedule_core_reminders_use_case.dart`, the 64-pending budget, or reserved budgets. Record this confirmation in the commit message.

- [ ] **Step 4: Commit (if any fixes were needed)**

```bash
git add -A
git commit -m "test: full suite green for personal phrase feed share"
```

---

## Notes for the implementer

- Run everything with `fvm` (`fvm flutter test`, `fvm flutter analyze`).
- The `personal` theme string and `QuoteSource.personal` already flow through history, the home widget, and notification routing — no new plumbing needed for the personal `Quote`.
- After implementation, run `/simplify` on the changed files per the project's code-quality rule before reporting done.
- Do NOT touch `schedule_core_reminders_use_case.dart`. The whole point is that the scheduler is unaware of the share.
