# Cupertino UI Language Spec (Decision Lock)

## 1. Modal Taxonomy
- `alert`: informational, single acknowledgement action.
- `confirm`: explicit cancel + primary/destructive confirm.
- `action sheet`: short choice lists.
- `form sheet`: bottom sheet with header actions and form content.
- `picker sheet`: specialized form sheet for date/time selection.

### Modal Rules
- Use `IaculaModal.showAlert` for info-only dialogs.
- Use `IaculaModal.showConfirm` for destructive/risky actions.
- Use `IaculaModal.showSheet` for bottom-origin interactions and form editing.
- Form/picker sheets must respect safe area and keyboard insets.

## 2. Input Taxonomy
- `IaculaTextInput`: plain, secure, multiline, numeric.
- `IaculaTimeInput`: HH:MM with shared placeholder and keyboard.
- `IaculaValidatedInput`: wrapper for label + input + inline validation message.

### Input Rules
- Avoid raw `CupertinoTextField` in feature screens.
- Inputs use shared height token and radius token.
- Labels use secondary typography; error text uses semantic error color.

## 3. Typography/Spacing/Radius
- Large title: `IaculaText.largeTitle`.
- Section title: `IaculaText.sectionTitle`.
- Card title: `IaculaText.cardTitle`.
- Body/secondary: `IaculaText.secondary`.
- Spacing defaults: `xs 8`, `sm 12`, `md 16`, `lg 24`, `xl 32`.
- Radius defaults: small `12`, card `20`, modal top radius token.

## 4. Action Hierarchy
- Primary action: filled brand button.
- Secondary action: neutral filled/subtle button.
- Destructive action: explicit destructive red action and copy.
- Cancel action: always present on confirm flows.

## 5. Validation/Error Placement
- Validation appears directly below the related field.
- Section-level errors use `IaculaInlineMessage` with warning/error semantic color.
- Avoid full-screen blocking error dialogs for local validation failures.

## 6. Before/After Mapping (Wave 1)
- `settings_screen.dart`
  - Before: raw `CupertinoTextField`, local validation dialog.
  - After: `IaculaValidatedInput`, inline errors, standardized save action.
- `profile_screen.dart`
  - Before: ad-hoc alert dialogs with embedded input.
  - After: `IaculaModal.showAlert`/`showSheet` and shared input components.
- `plan_of_life_screen.dart`
  - Before: custom form/date sheets.
  - After: `IaculaModal.showSheet` + standardized controls and spacing.
- `premium_gate.dart`
  - Before: custom popup container.
  - After: standardized sheet API + consistent primary/secondary CTA stack.
- `home_screen.dart`
  - Before: direct `showCupertinoDialog`.
  - After: `IaculaModal.showAlert`.
