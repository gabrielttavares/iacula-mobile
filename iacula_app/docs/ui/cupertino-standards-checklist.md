# Cupertino Standards Checklist

## Do
- Use `IaculaModal` for dialogs/sheets.
- Use `IaculaTextInput` / `IaculaValidatedInput` / `IaculaTimeInput` for form controls.
- Use `IaculaInlineMessage`, `IaculaEmptyState`, `IaculaErrorState` for user feedback.
- Prefer `IaculaLargeTitleScaffold` for large-title pages.
- Use tokenized spacing/radius/colors from `cupertino_tokens.dart`.

## Avoid
- Raw `showCupertinoModalPopup` in feature presentation files.
- Raw `showCupertinoDialog` in feature presentation files.
- Raw `CupertinoTextField` with per-screen styling.
- Duplicated modal container implementations.
- New hardcoded spacing/radius/color values when equivalent tokens exist.

## Review Checks
- Modal action hierarchy matches primary/secondary/destructive rules.
- Validation is inline, not only in blocking alerts.
- Loading/empty/error states are explicit and consistent.
- Tap targets are >= 44 logical pixels for interactive controls.
- Title/nav structure matches screen type (large-title scaffold vs nav bar).
