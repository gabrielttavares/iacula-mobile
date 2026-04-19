# Plan: Escriba Hero Card Layout + Overflow

## Problem
Hero card text can overlap Share/Save buttons, and long Escriba points overflow without truncation or a way to read the full text.

## Chosen Approach
Padding exclusion for button safety. Truncation with fade + "Continuar lendo" CTA. New lightweight QuoteFullTextScreen. Card always tappable.

## Implementation Order

1. **Extract share/bookmark buttons** — move `_HeroShareButton` and `_HeroBookmarkButton` to `lib/features/home/presentation/widgets/hero_action_buttons.dart` so both HomeHeroCard and QuoteFullTextScreen can use them — S
2. **Button safe zone** — asymmetric padding on text container excluding top-right button area — S
3. **Text truncation** — `_AutoSizingQuoteText`: at min font 12, apply `maxLines` + `TextOverflow.ellipsis`. Return `isTruncated` via callback — S
4. **Truncation CTA + fade** — show "Continuar lendo" label when truncated, apply `ShaderMask` bottom fade — S
5. **QuoteFullTextScreen** — new CupertinoPageScaffold at `lib/features/home/presentation/pages/quote_full_text_screen.dart` with scrollable text, label, share/bookmark — M
6. **Wire card tap** — pass `onTap` to `PremiumTouchableCard`, navigate to QuoteFullTextScreen — S

## Acceptance Criteria

**AC-1:** Short text — buttons always tappable, text doesn't overlap button area
**AC-2:** Long text at min font — truncated with ellipsis, no overflow
**AC-3:** Truncated text shows "Continuar lendo" + bottom fade
**AC-4:** Short text — no CTA, no fade
**AC-5:** Card tap (body) → navigates to QuoteFullTextScreen
**AC-6:** Button taps don't trigger card navigation
**AC-7:** Full-text screen shows complete scrollable text, label, share/bookmark
**AC-8:** Back navigation returns to home, bookmark state synced
**AC-9:** Visual design preserved (gradients, animation, overlay)
**AC-10:** WidgetQuoteCard unaffected

## Key Risks
- Button tap vs card tap conflict: CupertinoButton absorbs taps. Verify on device.
- ShaderMask on older devices: minimal, single small gradient.

## Boundaries
- **Always:** preserve Escriba dark gradient, scale animation, radial overlay
- **Never:** touch WidgetQuoteCard, BookReaderPage, add new providers/models
