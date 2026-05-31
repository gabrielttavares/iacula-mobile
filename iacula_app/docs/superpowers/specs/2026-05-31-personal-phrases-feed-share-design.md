# Personal Phrases: feed share, not a replace-mode

**Date:** 2026-05-31
**Screen:** Minhas Jaculatórias (`minhas_jaculatorias_screen.dart`)
**Status:** Approved design, ready for implementation plan

## Problem

The "Minhas Jaculatórias" screen carries a global toggle, **"Usar apenas minhas frases"**, presented as a soft card wedged between the phrase list and the "Gerenciar jaculatórias padrão" link. Two things are wrong with it — one UX, one substantive.

**UX:** it is a global behavior *mode* dressed up as just another content row, on a screen that is otherwise about content the user authored. Its scope is ambiguous.

**Substantive (discovered during design):** the toggle today **only affects the home hero card**. Rotation-mode personal phrases (`useFixedSchedule = false`, the default) are consulted *only* in `home_screen.dart`'s `_homeQuoteProvider`. They never enter the notification feed — `SchedulePhraseNotificationsUseCase._scheduleForPhrase` returns early when `!useFixedSchedule` (line 45), and the notification `quoteFetcher` (`providers.dart:607`) only ever draws liturgical/Escrivá quotes. So the toggle's subtitle — "Substitui as jaculatórias do tempo pelas suas frases personalizadas" — overpromises: notifications keep showing liturgical quotes regardless.

The binary is also a cliff: OFF = a lone personal phrase is last-in-line and shows ~never; ON = the curated liturgical feed (the app's reason to exist) is fully replaced by the user's handful of phrases.

## Product framing

Personal phrases are a **power-user niche**: most users never add one; a few lean on them. The redesign must therefore be invisible to the majority and reliable for the few — not a prominent global switch.

## Design

### 1. Replace the binary with a guaranteed *share* (default behavior)

Drop the prominent global mode. When the user has active personal phrases opted into the feed, a **predictable, bounded slice** of feed slots is filled with their phrases instead of a liturgical draw. The rest stays liturgical. No mode, no cliff, no setting to forget.

- **Share target:** **1 in 4** feed slots becomes a personal phrase when eligible personal phrases exist (liturgical content still clearly dominates). When the user has zero eligible personal phrases, the share is 0 and the feed is 100% liturgical.
- **Scope:** applies to BOTH the home hero and notifications, so a phrase the user added actually shows up where they'd expect.

### 2. Extend the share to notifications WITHOUT changing default-mode scheduling

**Hard constraint:** a user with no eligible personal phrases must get byte-for-byte identical notification scheduling to today. The 64-pending budget math, the reserved non-quote budget (`kReservedNonQuoteBudget`), Angelus/sacred reservations, the today-layer and weekly-grid-floor slot counts — none of it changes.

**Mechanism:** the weighting lives **inside `quoteFetcher`**, which already produces one `Quote` per slot. For a slot selected as a "personal" slot, the fetcher returns a `Quote` built from a personal phrase with `source: QuoteSource.personal` *instead of* drawing a liturgical quote. Same slot, same notification id, same budget, same total count. `ScheduleCoreRemindersUseCase` is untouched. `Quote` already supports `QuoteSource.personal` end-to-end (the hero builds one at `home_screen.dart:519`; history/widget/routing already handle it).

- **Slot selection must be deterministic per fire time** so the scheduler's assignment cache (`schedule_core_reminders_use_case.dart:193-227`, keyed by fire `DateTime`) stays stable across same-day reschedules — re-running a pass must not re-roll whether a future slot is personal or liturgical.
- Personal phrases enter the feed only when **eligible**, expressed by **reusing existing flags** (no new field, no migration): for the hero, `isActive && displayOnHero`; for notifications, `isActive && displayAsNotification`. Fixed-schedule phrases keep their existing independent notification path unchanged; they are not double-counted into the share.

### 3. Bury the pure-replace escape hatch

Pure "only my phrases, silence the liturgical feed" still exists but is **removed from the Minhas Jaculatórias screen** and relocated to a deliberately quiet spot (Settings → Personalização). It is intentionally not a one-tap thing the casual user trips over. Where it lives, copy is clear, concise, and minimal, and honestly states it replaces the curated feed across hero and notifications. (`customPhrasesOnly` field is reused as the backing flag.)

### 4. Minhas Jaculatórias screen becomes pure authored content

After the toggle card is removed, the screen reads top to bottom as:
1. `ALARMES DE ORAÇÃO` — unchanged.
2. `FRASES PESSOAIS` — unchanged in structure (rows + "Adicionar frase").
3. "Gerenciar jaculatórias padrão" link — unchanged.

No global behavior mode on this screen.

## What is removed

- The "Usar apenas minhas frases" `IaculaSoftCard` (and its misleading subtitle) from `minhas_jaculatorias_screen.dart`, plus the now-unused `_customPhrasesOnly` state, `_loadSettings`, and `_toggleCustomPhrasesOnly` in that screen.

## What is kept

- `customPhrasesOnly` settings field + persistence — reused as the buried escape-hatch flag.
- Fixed-schedule personal phrase notifications — unchanged.
- All default-mode liturgical scheduling — unchanged.

## Components touched

| Unit | Change |
|------|--------|
| `minhas_jaculatorias_screen.dart` | Remove toggle card + its state/handlers. |
| `settings_screen.dart` | Add buried pure-replace control under Personalização with honest copy. |
| `quoteFetcher` wiring (`providers.dart:607`) + a new phrase-share selector | Inject personal phrases into the per-slot quote draw, eligibility-gated, deterministic per fire time. |
| `_homeQuoteProvider` (`home_screen.dart`) | Align hero selection with the same share logic (replacing the current all-or-nothing `customPhrasesOnly` branch for the default case; keep the branch only for the buried replace mode). |
| Phrase eligibility (`CustomPhrase` / repository query) | Define "eligible for feed share" (active + feed opt-in). Confirm whether `displayOnHero`/`displayAsNotification` already express opt-in or a new flag is needed — resolve in the plan. |

## Decisions locked

- **Share ratio:** 1 in 4 feed slots when eligible phrases exist.
- **Eligibility:** reuse existing flags — hero `isActive && displayOnHero`, notifications `isActive && displayAsNotification`. No new field, no migration, no edit-screen change.

## Open items for the implementation plan

1. How multiple eligible phrases rotate *within* the personal slots (deterministic, day-of-year style already used at `home_screen.dart:517`).
2. Confirm the deterministic per-fire-time selection function (which slots are "personal") and unit-test it against the assignment-cache reuse path so reschedules don't re-roll a future slot.
3. Exact placement + copy of the buried replace control in Settings → Personalização.

## Non-goals

- No change to default-mode notification scheduling or the 64-pending budget.
- No restyling of phrase rows or alarms.
- No new prominent global toggle anywhere.
