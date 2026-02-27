# Cupertino Standardization Inventory (2026-02-27)

## Scope
- Reviewed all presentation files under `lib/features/**/presentation/*.dart`.
- Reviewed shared primitives under `lib/core/presentation/widgets/*.dart`.

## Current Pattern Inventory

### Modal/Dialog Patterns
- `showCupertinoDialog`: used in `home_screen.dart`, `profile_screen.dart`, `settings_screen.dart`, `meditation_*`, `paywall_screen.dart`.
- `showCupertinoModalPopup`: used in `plan_of_life_screen.dart`, `liturgia_screen.dart`, `premium_gate.dart`.
- Custom sheet containers duplicated in:
  - `plan_of_life_screen.dart`
  - `liturgia_screen.dart` (`_CalendarModal`)
  - `premium_gate.dart` (`_PremiumGateModal`)

### Text Input Patterns
- Raw `CupertinoTextField` appears in:
  - `settings_screen.dart`
  - `profile_screen.dart`
  - `plan_of_life_screen.dart`
- Repeated field spacing/labels/validation style is currently local to each screen.

### Navigation/Title Patterns
- Mixed use of:
  - `IaculaLargeTitle` in content layouts
  - `CupertinoNavigationBar` in select screens
  - manual header `Row` implementations
- No single wrapper for large-title scaffold + consistent paddings.

### Loading/Empty/Error Patterns
- Loading mostly uses `CupertinoActivityIndicator` directly.
- Empty/error states are mixed raw `Text`, ad-hoc card blocks, and custom messaging.
- No centralized feedback primitive for inline warning/error/empty states.

### Hardcoded Visual Values
- Direct constants repeated for:
  - radius (`16`, `20`, `24`, `26`)
  - card/sheet colors (`CupertinoColors.white`, custom grays)
  - modal heights and paddings
- Shadow and separator styles differ per screen.

## Priority Gaps (Wave 1)
- Standard modal API for alert/confirm/sheet.
- Standard text input wrappers with shared density, radius, and error rendering.
- Standard feedback components for empty/error inline messaging.
- Standard large-title scaffold wrapper to reduce per-screen layout drift.
