import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../prayer_activity/domain/entities/prayer_activity_entry.dart';
import '../application/rosary_session_notifier.dart';
import '../domain/entities/rosary_mystery_set.dart';
import 'rosary_completion_screen.dart';
import 'widgets/bead_dots.dart';
import 'widgets/ken_burns_image.dart';

class RosaryDecadeScreen extends ConsumerStatefulWidget {
  const RosaryDecadeScreen({
    super.key,
    required this.mysterySet,
    required this.mysteryIndex,
  });

  final RosaryMysterySet mysterySet;
  final int mysteryIndex;

  @override
  ConsumerState<RosaryDecadeScreen> createState() => _RosaryDecadeScreenState();
}

class _RosaryDecadeScreenState extends ConsumerState<RosaryDecadeScreen> {
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(rosarySessionProvider(widget.mysterySet).notifier)
          .selectMystery(widget.mysteryIndex);
    });
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(rosarySessionProvider(widget.mysterySet));
    final mystery = widget.mysterySet.mysteries[widget.mysteryIndex];

    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _isTransitioning ? null : _advance,
            child: KenBurnsImage(
              imagePath: mystery.imagePath,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x26000000),
                      Color(0x73000000),
                      Color(0xA6000000),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    minSize: 32,
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Icon(
                      CupertinoIcons.chevron_left,
                      color: Color(0xCCFFFFFF),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${widget.mysteryIndex + 1}º Mistério',
                      textAlign: TextAlign.center,
                      style: context.textStyles.secondary.copyWith(
                        color: const Color(0xFFFFFFFF),
                        fontSize: 15,
                        shadows: const [
                          Shadow(color: Color(0x99000000), blurRadius: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mystery.name,
                      textAlign: TextAlign.center,
                      style: context.textStyles.cardTitle.copyWith(
                        color: const Color(0xFFFFFFFF),
                        fontSize: 20,
                        shadows: const [
                          Shadow(color: Color(0x99000000), blurRadius: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Fruto: ${mystery.fruit}',
                      textAlign: TextAlign.center,
                      style: context.textStyles.secondary.copyWith(
                        color: const Color(0xCCFFFFFF),
                        fontSize: 14,
                        shadows: const [
                          Shadow(color: Color(0x99000000), blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    BeadDots(currentBeadIndex: session.currentBeadIndex),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _advance() async {
    if (_isTransitioning || !mounted) return;
    final provider = rosarySessionProvider(widget.mysterySet);
    final before = ref.read(provider);

    HapticFeedback.lightImpact();
    ref.read(provider.notifier).advanceBead();

    final after = ref.read(provider);
    final completedDecade =
        after.completedDecades.contains(widget.mysteryIndex) &&
        !before.completedDecades.contains(widget.mysteryIndex);

    if (completedDecade) {
      HapticFeedback.mediumImpact();
      _isTransitioning = true;
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      final isLast =
          widget.mysteryIndex >= widget.mysterySet.mysteries.length - 1;
      if (isLast) {
        final elapsed = DateTime.now().difference(after.startTime);
        final streak = (await ref.read(
          streakInfoProvider.future,
        )).currentStreak;
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (_) => RosaryCompletionScreen(
              mysteryImagePath:
                  widget.mysterySet.mysteries[widget.mysteryIndex].imagePath,
              elapsed: elapsed,
              streakCount: streak,
              onDone: () {
                ref
                    .read(prayerActivityLoggerProvider)
                    .logActivity(
                      type: PrayerActivityType.rosary,
                      durationSeconds: elapsed.inSeconds,
                      featureSlug: 'rosary_${widget.mysterySet.type.name}',
                    );
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        );
      } else {
        Navigator.of(context).pop(true);
      }
      _isTransitioning = false;
    }
  }
}
