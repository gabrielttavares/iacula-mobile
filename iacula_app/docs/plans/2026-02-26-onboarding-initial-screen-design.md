# Onboarding Initial Screen Design

**Goal**
- Align Screen 1 with the approved brand and onboarding requirements: centered Iacula title + logo, consistent card hierarchy, and blue primary actions.

**Scope**
- Update onboarding visual identity block in `lib/features/onboarding/presentation/onboarding_screen.dart`.
- Add a top exclusive-feature card for notifications/Jaculatorias and noon Angelus/Regina Caeli reminder.
- Keep Liturgia Diaria and Plano de Vida cards visually consistent.
- Remove the onboarding footer label under the secondary action.
- Remove the grid identity icon from onboarding and other visible app identity usage (`lib/features/home/presentation/home_screen.dart`).
- Apply global primary button color token `#0975C8` via `lib/core/theme/cupertino_tokens.dart`.

**Design Decisions**
- Use the app icon asset as the onboarding logo (`assets/seed/images/icon.png`) in medium-large size above the title.
- Keep typography and spacing tokens already used by the app for consistency.
- Represent exclusivity with dedicated copy in the first card and an accent background tint.
- Preserve existing layout behavior on narrow devices by keeping cards in existing responsive row/column structure.

**Validation**
- Widget tests updated to assert:
  - no grid icon on onboarding and home header
  - onboarding key texts and removal of old footer text
  - exclusive feature card content exists
  - global primary color token set to `0xFF0975C8`
