# 3D Interaction & Tactile Feedback — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make every tappable surface feel physically real — buttons compress like spring-loaded switches, cards float above the surface and sink on press — with bold, expressive animation intensity.

**Architecture:** Two new interaction primitives (`IaculaSpringButton` for buttons, `IaculaTouchableCard` for cards) that animate scale, shadow depth, and vertical translate on press/release using spring curves. Then a full consistency pass migrating all bare `GestureDetector` tappable widgets to use these primitives.

**Tech Stack:** Flutter `AnimationController`, `Tween`, `Transform`, `BoxShadowTween` (manual lerp), `HapticFeedback`, `Curves.easeOutBack`.

---

## Task 1: Expand `IaculaShadows` with resting/pressed shadow pairs

**Files:**
- Modify: `lib/core/theme/cupertino_tokens.dart:245-251`

**Step 1: Update IaculaShadows**

Replace the existing `IaculaShadows` class (lines 245-251) with:

```dart
final class IaculaShadows {
  IaculaShadows._();

  // Card shadows — floating layer metaphor
  static const cardResting = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 8)),
  ];
  static const cardPressed = [
    BoxShadow(color: Color(0x07000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  // Keep backward compat alias
  static const card = cardResting;

  // Button shadows — spring compression metaphor
  static const buttonResting = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
  static const buttonPressed = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
}
```

**Step 2: Verify no compile errors**

Run: `flutter analyze lib/core/theme/cupertino_tokens.dart`
Expected: No errors. The `card` alias preserves all existing references.

**Step 3: Commit**

```
feat: expand IaculaShadows with resting/pressed pairs for 3D interactions
```

---

## Task 2: Create `IaculaTouchableCard` — the card press primitive

**Files:**
- Create: `lib/core/presentation/widgets/iacula_touchable_card.dart`

**Step 1: Write the widget**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../theme/cupertino_tokens.dart';

/// A card wrapper that animates scale, shadow depth, and vertical position
/// on press to create a "floating layer sinks toward surface" effect.
class IaculaTouchableCard extends StatefulWidget {
  const IaculaTouchableCard({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.92,
    this.pressTranslateY = 2.0,
    this.enableHaptics = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final double pressTranslateY;
  final bool enableHaptics;

  @override
  State<IaculaTouchableCard> createState() => _IaculaTouchableCardState();
}

class _IaculaTouchableCardState extends State<IaculaTouchableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _translateAnimation;
  late final Animation<double> _shadowBlurAnimation;
  late final Animation<double> _shadowOffsetAnimation;
  late final Animation<double> _shadowOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 280),
    );

    final forwardCurve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOutBack,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(forwardCurve);

    _translateAnimation = Tween<double>(
      begin: 0.0,
      end: widget.pressTranslateY,
    ).animate(forwardCurve);

    // Shadow: blur 20 -> 4
    _shadowBlurAnimation = Tween<double>(
      begin: 20.0,
      end: 4.0,
    ).animate(forwardCurve);

    // Shadow: offset Y 8 -> 1
    _shadowOffsetAnimation = Tween<double>(
      begin: 8.0,
      end: 1.0,
    ).animate(forwardCurve);

    // Shadow: opacity 0x0A (10) -> 0x07 (7), normalized 0-255
    _shadowOpacityAnimation = Tween<double>(
      begin: 10.0 / 255.0,
      end: 7.0 / 255.0,
    ).animate(forwardCurve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    _controller.forward();
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onTap == null) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _translateAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(
                        0, 0, 0, _shadowOpacityAnimation.value,
                      ),
                      blurRadius: _shadowBlurAnimation.value,
                      offset: Offset(0, _shadowOffsetAnimation.value),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
```

**Important:** `AnimatedBuilder` is the correct Flutter class name. If the analyzer complains, use `AnimatedBuilder` from `package:flutter/widgets.dart`. Double-check: the actual Flutter class is `AnimatedBuilder` — confirm at build time and fall back to wrapping with a plain `builder` pattern on the `AnimationController` listener if needed.

**Step 2: Verify it compiles**

Run: `flutter analyze lib/core/presentation/widgets/iacula_touchable_card.dart`
Expected: No errors.

**Step 3: Commit**

```
feat: add IaculaTouchableCard with floating-layer press physics
```

---

## Task 3: Create `IaculaSpringButton` — the button press primitive

**Files:**
- Create: `lib/core/presentation/widgets/iacula_spring_button.dart`

**Step 1: Write the widget**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../theme/cupertino_tokens.dart';

/// A button wrapper that animates scale and shadow on press to create
/// a spring-compression "real button" effect.
class IaculaSpringButton extends StatefulWidget {
  const IaculaSpringButton({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.90,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  @override
  State<IaculaSpringButton> createState() => _IaculaSpringButtonState();
}

class _IaculaSpringButtonState extends State<IaculaSpringButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _shadowBlurAnimation;
  late final Animation<double> _shadowOffsetAnimation;
  late final Animation<double> _shadowOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOutBack,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(curvedAnimation);

    // Shadow: blur 12 -> 2
    _shadowBlurAnimation = Tween<double>(
      begin: 12.0,
      end: 2.0,
    ).animate(curvedAnimation);

    // Shadow: offset Y 4 -> 1
    _shadowOffsetAnimation = Tween<double>(
      begin: 4.0,
      end: 1.0,
    ).animate(curvedAnimation);

    // Shadow: opacity 0x14 (20) -> 0x0A (10), normalized 0-255
    _shadowOpacityAnimation = Tween<double>(
      begin: 20.0 / 255.0,
      end: 10.0 / 255.0,
    ).animate(curvedAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap == null) return;
    _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onTap == null) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(
                      0, 0, 0, _shadowOpacityAnimation.value,
                    ),
                    blurRadius: _shadowBlurAnimation.value,
                    offset: Offset(0, _shadowOffsetAnimation.value),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
```

**Step 2: Verify it compiles**

Run: `flutter analyze lib/core/presentation/widgets/iacula_spring_button.dart`

**Step 3: Commit**

```
feat: add IaculaSpringButton with spring-compression press physics
```

---

## Task 4: Integrate `IaculaSpringButton` into pill buttons

**Files:**
- Modify: `lib/core/presentation/widgets/iacula_buttons.dart` (full rewrite, 85 lines)

**Step 1: Rewrite both pill buttons**

Replace the entire file. Key changes:
- Remove `CupertinoButton` as the press handler (it was providing the opacity fade).
- Wrap each button's visual container with `IaculaSpringButton`, which now provides scale + shadow + haptics.
- Keep the same visual appearance (colors, border radius, text style) but remove `CupertinoButton`'s built-in `onPressed` handling.
- Remove the manual `HapticFeedback.lightImpact()` calls — `IaculaSpringButton` handles haptics internally.

```dart
import 'package:flutter/cupertino.dart';

import '../../theme/cupertino_tokens.dart';
import 'iacula_spring_button.dart';

class IaculaPrimaryPillButton extends StatelessWidget {
  const IaculaPrimaryPillButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final height = IaculaMetrics.inputHeight + IaculaSpacing.xs;
    return IaculaSpringButton(
      onTap: onPressed,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: onPressed != null
              ? context.colors.primaryButton
              : context.colors.primaryButton.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: context.colors.background,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class IaculaSecondaryPillButton extends StatelessWidget {
  const IaculaSecondaryPillButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final height = IaculaMetrics.inputHeight + IaculaSpacing.xs;
    return IaculaSpringButton(
      onTap: onPressed,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: onPressed != null
              ? context.colors.secondaryButton
              : context.colors.secondaryButton.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Verify no compile errors**

Run: `flutter analyze lib/core/presentation/widgets/iacula_buttons.dart`

**Step 3: Commit**

```
feat: integrate IaculaSpringButton into pill buttons for 3D press
```

---

## Task 5: Update `PremiumTouchableCard` to delegate to `IaculaTouchableCard`

**Files:**
- Modify: `lib/core/presentation/widgets/premium_touchable_card.dart` (full rewrite, 81 lines)

**Step 1: Rewrite to thin wrapper**

Replace the entire file. `PremiumTouchableCard` becomes a pass-through to `IaculaTouchableCard`, preserving its public API so all existing callers work unchanged:

```dart
import 'package:flutter/cupertino.dart';

import 'iacula_touchable_card.dart';

class PremiumTouchableCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  const PremiumTouchableCard({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.92,
  });

  @override
  Widget build(BuildContext context) {
    return IaculaTouchableCard(
      onTap: onTap,
      scaleFactor: scaleFactor,
      child: child,
    );
  }
}
```

**Step 2: Verify compile + existing behavior works**

Run: `flutter analyze`
Expected: No errors. All existing `PremiumTouchableCard` usages (home_hero_card, home_action_grid, home_continuation_card, image_background_card) now get the full 3D treatment automatically.

**Step 3: Commit**

```
refactor: delegate PremiumTouchableCard to IaculaTouchableCard
```

---

## Task 6: Remove duplicate shadow from `IaculaSoftCard`

**Files:**
- Modify: `lib/core/presentation/widgets/iacula_soft_card.dart:19-27`

**Context:** `IaculaSoftCard` currently applies `IaculaShadows.card` via its `BoxDecoration`. But when wrapped in `IaculaTouchableCard`, there will be two competing shadow layers — the static one from `IaculaSoftCard` and the animated one from `IaculaTouchableCard`. The static shadow needs to be optional.

**Step 1: Add `showShadow` parameter**

```dart
class IaculaSoftCard extends StatelessWidget {
  const IaculaSoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(IaculaSpacing.md),
    this.radius = IaculaRadius.card,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: showShadow ? IaculaShadows.card : null,
      ),
      child: child,
    );
  }
}
```

**Step 2: Commit**

```
feat: add showShadow toggle to IaculaSoftCard for animated shadow compat
```

---

## Task 7: Migrate `MeditationCard` — add `IaculaTouchableCard`

**Files:**
- Modify: `lib/features/meditation/presentation/widgets/meditation_card.dart:42-43`

**Step 1: Replace bare GestureDetector with IaculaTouchableCard**

Change the build method's GestureDetector wrapper:

```dart
// Before (line 42-43):
    return GestureDetector(
      onTap: () => _launchUrl(context),

// After:
    return IaculaTouchableCard(
      onTap: () => _launchUrl(context),
```

Add import at top of file:
```dart
import '../../../../core/presentation/widgets/iacula_touchable_card.dart';
```

**Step 2: Commit**

```
feat: add press feedback to MeditationCard via IaculaTouchableCard
```

---

## Task 8: Migrate `IaculaListItem` — add `IaculaTouchableCard`

**Files:**
- Modify: `lib/core/presentation/widgets/iacula_list_item.dart:19`

**Step 1: Replace bare GestureDetector with IaculaTouchableCard**

```dart
// Before (line 19):
    return GestureDetector(
      onTap: onTap,

// After:
    return IaculaTouchableCard(
      onTap: onTap,
```

Add import:
```dart
import 'iacula_touchable_card.dart';
```

**Step 2: Commit**

```
feat: add press feedback to IaculaListItem via IaculaTouchableCard
```

---

## Task 9: Migrate `PlanItemRow` — add `IaculaTouchableCard`

**Files:**
- Modify: `lib/features/plan_of_life/presentation/widgets/plan_item_row.dart:29-30`

**Step 1: Replace bare GestureDetector with IaculaTouchableCard**

```dart
// Before (line 29-30):
      child: GestureDetector(
        onTap: () => onToggle(!isCompleted),

// After:
      child: IaculaTouchableCard(
        onTap: () => onToggle(!isCompleted),
```

Add import:
```dart
import '../../../../core/presentation/widgets/iacula_touchable_card.dart';
```

**Step 2: Commit**

```
feat: add press feedback to PlanItemRow via IaculaTouchableCard
```

---

## Task 10: Migrate `_PrayerCategoryCard` in prayer_collections_screen

**Files:**
- Modify: `lib/features/prayers/presentation/prayer_collections_screen.dart:189-191`

**Step 1: Replace bare GestureDetector with IaculaTouchableCard**

```dart
// Before (line ~189-191):
    return GestureDetector(
      onTap: onTap,
      child: IaculaSoftCard(

// After:
    return IaculaTouchableCard(
      onTap: onTap,
      child: IaculaSoftCard(
```

Add import:
```dart
import '../../../core/presentation/widgets/iacula_touchable_card.dart';
```

**Step 2: Commit**

```
feat: add press feedback to _PrayerCategoryCard via IaculaTouchableCard
```

---

## Task 11: Migrate `_PrayerItemCard` in prayer_catalog_group_screen

**Files:**
- Modify: `lib/features/prayers/presentation/prayer_catalog_group_screen.dart:114`

**Step 1: Replace bare GestureDetector with IaculaTouchableCard**

```dart
// Before (line 114):
    return GestureDetector(
      onTap: () {

// After:
    return IaculaTouchableCard(
      onTap: () {
```

Add import:
```dart
import '../../../core/presentation/widgets/iacula_touchable_card.dart';
```

**Step 2: Commit**

```
feat: add press feedback to _PrayerItemCard via IaculaTouchableCard
```

---

## Task 12: Migrate `_DoctrineCard` in doctrine_collections_screen

**Files:**
- Modify: `lib/features/doctrina/presentation/doctrine_collections_screen.dart:87-88`

**Step 1: Replace bare GestureDetector with IaculaTouchableCard**

```dart
// Before:
    return GestureDetector(
      onTap: onTap,
      child: IaculaSoftCard(

// After:
    return IaculaTouchableCard(
      onTap: onTap,
      child: IaculaSoftCard(
```

Add import:
```dart
import '../../../core/presentation/widgets/iacula_touchable_card.dart';
```

**Step 2: Commit**

```
feat: add press feedback to _DoctrineCard via IaculaTouchableCard
```

---

## Task 13: Migrate `_MeditationFeedCard` and `_FilterChips` in meditation_screen

**Files:**
- Modify: `lib/features/meditation/presentation/meditation_screen.dart`

**Step 1: Wrap `_MeditationFeedCard` with IaculaTouchableCard**

Replace the `GestureDetector` in `_MeditationFeedCard.build` (around line 175):

```dart
// Before:
    return GestureDetector(
      onTap: onTap,
      child: IaculaSoftCard(

// After:
    return IaculaTouchableCard(
      onTap: onTap,
      child: IaculaSoftCard(
```

**Step 2: Wrap `_FilterChips` individual chips with IaculaSpringButton**

In `_FilterChips.build`, replace the `GestureDetector` per chip (around line 140):

```dart
// Before:
          return GestureDetector(
            onTap: () => onSelected(filter),
            child: Container(

// After:
          return IaculaSpringButton(
            scaleFactor: 0.92,
            onTap: () => onSelected(filter),
            child: Container(
```

Add imports:
```dart
import '../../../core/presentation/widgets/iacula_touchable_card.dart';
import '../../../core/presentation/widgets/iacula_spring_button.dart';
```

**Step 3: Commit**

```
feat: add press feedback to meditation feed cards and filter chips
```

---

## Task 14: Final verification — full analyze + test

**Step 1: Run full analyzer**

Run: `flutter analyze`
Expected: No errors, no new warnings.

**Step 2: Run tests**

Run: `flutter test`
Expected: All existing tests pass. No behavioral changes — only visual press feedback was added.

**Step 3: Manual smoke test checklist**

Verify on device/simulator:
- [ ] Pill buttons: scale 0.90 on press, shadow collapses, bouncy spring release
- [ ] Home hero card: scale 0.92, shadow shrinks, 2px sink, spring release
- [ ] Home action grid tiles: same floating-layer press
- [ ] Image background cards: same
- [ ] Meditation feed cards: now have press feedback (previously dead)
- [ ] Prayer category cards: now have press feedback
- [ ] Plan item rows: now have press feedback
- [ ] Doctrine cards: now have press feedback
- [ ] Filter chips: spring compression on tap
- [ ] All haptics fire correctly

**Step 4: Commit**

```
chore: verify 3D interaction system — full analyze + test pass
```

---

## Summary

| Task | Description | Effort |
|------|-------------|--------|
| 1 | Expand IaculaShadows tokens | 2 min |
| 2 | Create IaculaTouchableCard primitive | 10 min |
| 3 | Create IaculaSpringButton primitive | 8 min |
| 4 | Integrate spring into pill buttons | 5 min |
| 5 | Delegate PremiumTouchableCard | 3 min |
| 6 | Add showShadow toggle to IaculaSoftCard | 2 min |
| 7-12 | Migrate 6 bare-GestureDetector widgets | 3 min each |
| 13 | Migrate meditation feed + filter chips | 5 min |
| 14 | Final verification | 5 min |
| **Total** | | **~55 min** |
