# 3D Interaction & Tactile Feedback Design

**Date:** 2026-02-28
**Goal:** Make every tappable surface in the app feel physically real — buttons compress like real buttons, cards float and sink like layered paper.

---

## Design Decisions

**Two physical metaphors for two UI roles:**

| Element | Metaphor | Press behavior |
|---------|----------|---------------|
| Buttons (pill, icon, inline) | Spring compression | Scale 0.90, shadow collapses inward, slight brightness shift, bouncy spring release |
| Cards (soft, hero, image, list items) | Floating layers | Sink toward surface on press (scale 0.92, shadow shrinks from elevated to flat, subtle downward translate), spring back on release |

**Intensity:** Bold / expressive. Pronounced scale (0.90-0.92), visible shadow depth changes, heavy spring overshoot on release.

**Scope:** Full consistency pass. Every tappable surface gets interaction feedback — no more bare `GestureDetector` with zero visual response.

---

## Architecture

### Two new interaction primitives

#### 1. `IaculaSpringButton` — replaces direct CupertinoButton usage for pill buttons

Wraps any child with spring-compression press physics:

- **Press-down:** Scale to `0.90`, shadow blur shrinks from resting to 0, shadow offset drops to 0, background darkens ~5%. Duration: 80ms.
- **Release:** Spring back with `Curves.easeOutBack` overshoot. Duration: 200ms.
- **Haptics:** `HapticFeedback.lightImpact()` on tap-down.
- **Disabled state:** No animation, reduced opacity (0.4).

Implementation: `AnimationController` driving a `Transform.scale` + animated `BoxDecoration` shadow + `ColorFiltered` or opacity overlay.

#### 2. `IaculaTouchableCard` — replaces `PremiumTouchableCard` as the universal card interaction wrapper

Wraps any card child with floating-layer press physics:

- **Resting state:** Elevated shadow (`blur: 20, offset: (0, 8), opacity: 10%`). This is the existing `IaculaShadows.card`.
- **Press-down:** Scale to `0.92`, shadow collapses to `blur: 4, offset: (0, 1), opacity: 4%`, card translates down 2px. Duration: 100ms ease-in.
- **Release:** Spring back to resting with `Curves.easeOutBack`. Duration: 280ms.
- **Haptics:** `HapticFeedback.selectionClick()` on tap-down.
- **Disabled state:** No animation.

Implementation: `AnimationController` driving `Transform.scale` + `Transform.translate` + interpolated `BoxShadow` via `BoxShadowTween` (or manual lerp). The shadow transition is the key differentiator — it sells the "sinking into the surface" illusion.

### Shadow token expansion in `IaculaShadows`

```dart
final class IaculaShadows {
  static const cardResting = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 8)),
  ];
  static const cardPressed = [
    BoxShadow(color: Color(0x07000000), blurRadius: 4, offset: Offset(0, 1)),
  ];
  static const buttonResting = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static const buttonPressed = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
}
```

### Migration plan for bare GestureDetector widgets

These widgets currently have zero press feedback and need wrapping with `IaculaTouchableCard`:

| Widget | File | Current interaction |
|--------|------|-------------------|
| `MeditationCard` | `meditation_card.dart` | `GestureDetector` onTap only |
| `IaculaListItem` | `iacula_list_item.dart` | `GestureDetector` onTap only |
| `PlanItemRow` | `plan_item_row.dart` | `GestureDetector` onTap only |
| `_DoctrineCard` | `doctrine_collections_screen.dart` | `GestureDetector` onTap only |
| `_CollectionCard` | `prayer_collections_screen.dart` | `GestureDetector` onTap only |
| `_PrayerItemCard` | `prayer_catalog_group_screen.dart` | `GestureDetector` onTap only |
| `_FavoriteCard` | `favorites_screen.dart` | No tap, but delete button is bare |
| Meditation filter chips | `meditation_screen.dart` | `GestureDetector` onTap only |

### Migration plan for existing PremiumTouchableCard users

These already use `PremiumTouchableCard` (scale 0.97, no shadow animation). They need to switch to the new `IaculaTouchableCard`:

| Widget | File |
|--------|------|
| `HomeHeroCard` | `home_hero_card.dart` |
| `HomeActionGrid` cells | `home_action_grid.dart` |
| `HomeContinuationCard` | `home_continuation_card.dart` |
| `ImageBackgroundCard` | `image_background_card.dart` |

After migration, `PremiumTouchableCard` can be deleted or kept as a thin wrapper that adds premium-gate logic on top of `IaculaTouchableCard`.

### Button migration

`IaculaPrimaryPillButton` and `IaculaSecondaryPillButton` currently delegate to `CupertinoButton` (opacity fade only). They should wrap their content with `IaculaSpringButton` instead, which provides scale + shadow compression + haptics.

Direct `CupertinoButton` usages for icon actions (bell, search, add, calendar, edit, etc.) across screens should remain as-is — their small size means the default Cupertino opacity fade is appropriate. Only pill/primary action buttons get the spring treatment.

---

## Animation Curves & Timing Summary

| Action | Scale | Shadow | Translate | Curve | Duration |
|--------|-------|--------|-----------|-------|----------|
| Button press-down | 0.90 | Resting -> Pressed | none | easeIn | 80ms |
| Button release | 1.0 | Pressed -> Resting | none | easeOutBack | 200ms |
| Card press-down | 0.92 | Resting -> Pressed | +2px Y | easeIn | 100ms |
| Card release | 1.0 | Pressed -> Resting | 0px Y | easeOutBack | 280ms |

---

## Files to create

1. `lib/core/presentation/widgets/iacula_spring_button.dart` — button press primitive
2. `lib/core/presentation/widgets/iacula_touchable_card.dart` — card press primitive

## Files to modify

1. `lib/core/theme/cupertino_tokens.dart` — expand `IaculaShadows` with resting/pressed pairs
2. `lib/core/presentation/widgets/iacula_buttons.dart` — wrap pill buttons with `IaculaSpringButton`
3. `lib/core/presentation/widgets/iacula_soft_card.dart` — integrate animated shadow support
4. `lib/core/presentation/widgets/premium_touchable_card.dart` — delegate to `IaculaTouchableCard`
5. `lib/features/meditation/presentation/widgets/meditation_card.dart` — add `IaculaTouchableCard`
6. `lib/core/presentation/widgets/iacula_list_item.dart` — add `IaculaTouchableCard`
7. `lib/features/plan_of_life/presentation/widgets/plan_item_row.dart` — add `IaculaTouchableCard`
8. `lib/features/doctrina/presentation/doctrine_collections_screen.dart` — wrap `_DoctrineCard`
9. `lib/features/prayers/presentation/prayer_collections_screen.dart` — wrap `_CollectionCard`
10. `lib/features/prayers/presentation/prayer_catalog_group_screen.dart` — wrap `_PrayerItemCard`
11. `lib/features/favorites/presentation/favorites_screen.dart` — wrap `_FavoriteCard`
12. `lib/features/meditation/presentation/meditation_screen.dart` — wrap filter chips
13. `lib/features/home/presentation/widgets/home_hero_card.dart` — switch to `IaculaTouchableCard`
14. `lib/features/home/presentation/widgets/home_action_grid.dart` — switch to `IaculaTouchableCard`
15. `lib/features/home/presentation/widgets/home_continuation_card.dart` — switch to `IaculaTouchableCard`
16. `lib/core/presentation/widgets/image_background_card.dart` — switch to `IaculaTouchableCard`

## Out of scope

- Idle/ambient floating animations (ruled out)
- Icon button spring effects (too small, Cupertino opacity is fine)
- Tab bar interactions (handled by CupertinoTabBar)
- Navigation bar button interactions (handled by CupertinoNavigationBar)
