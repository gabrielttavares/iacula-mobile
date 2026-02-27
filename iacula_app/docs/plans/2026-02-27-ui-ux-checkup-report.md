# UI/UX Checkup Report (2026-02-27)

## Summary
- Focus area: consistency, navigation coherence, state handling, accessibility/readability.
- Scope reviewed: core shell + Wave 1 screens (`home`, `settings`, `profile`, `plan_of_life`, `premium`).

## Findings

### P1 - Modal/Input inconsistency across core flows
- Multiple modal implementations and raw text fields create inconsistent spacing, action hierarchy, and keyboard behavior.
- Remediation: centralize through `IaculaModal` and `IaculaTextInput` wrappers.

### P1 - Validation feedback relies on alerts in settings/profile
- Local input/format errors are surfaced via dialogs, interrupting flow.
- Remediation: inline validation via `IaculaValidatedInput` + `IaculaInlineMessage`.

### P2 - Loading/empty/error states are visually inconsistent
- Mix of centered raw text and custom card blocks.
- Remediation: standardize via `IaculaEmptyState` and `IaculaErrorState`.

### P2 - Navigation/title patterns are mixed
- Some screens use `CupertinoNavigationBar`, others custom rows, others large title headers.
- Remediation: shared scaffold wrapper (`IaculaLargeTitleScaffold`) and nav helper (`IaculaNavBar`).

### P3 - Hardcoded radii/paddings in feature screens
- Repeated hardcoded constants reduce maintainability and visual consistency.
- Remediation: migrate to tokenized control metrics and card/modal helpers.

## Flow Coherence Checks
- Tab navigation: coherent, premium-gated tabs revert correctly.
- Deep links: app routes still map to liturgy and content flows.
- Back navigation: mostly standard, with modal-stack behavior requiring standardized APIs.

## Accessibility/Readability Checks
- Baseline tap targets are mostly acceptable.
- Readability and contrast good in primary surfaces; destructive/caption styles need tokenized semantic colors.
- Large titles should remain scalable with standardized scaffold paddings.

## Test Follow-ups
- Add tests for:
  - modal wrappers (`showAlert`, `showConfirm`, `showSheet`)
  - input wrappers and error rendering
  - empty/error state components
  - profile/settings modal behavior after migration
