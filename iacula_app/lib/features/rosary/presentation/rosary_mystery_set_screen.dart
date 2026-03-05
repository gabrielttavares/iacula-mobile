import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/cupertino_tokens.dart';
import '../domain/entities/rosary_mystery_set.dart';
import 'rosary_decade_screen.dart';
import 'widgets/ken_burns_image.dart';
import 'widgets/mystery_progress_bar.dart';

class RosaryMysterySetScreen extends StatefulWidget {
  const RosaryMysterySetScreen({super.key, required this.mysterySet});

  final RosaryMysterySet mysterySet;

  @override
  State<RosaryMysterySetScreen> createState() => _RosaryMysterySetScreenState();
}

class _RosaryMysterySetScreenState extends State<RosaryMysterySetScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _progressController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mystery = widget.mysterySet.mysteries[_currentPage];
    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mysterySet.mysteries.length,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
                _progressController
                  ..reset()
                  ..forward();
              });
            },
            itemBuilder: (context, index) {
              final item = widget.mysterySet.mysteries[index];
              return GestureDetector(
                onTap: () => _openDecade(index),
                child: KenBurnsImage(
                  imagePath: item.imagePath,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00000000),
                          Color(0x00000000),
                          Color(0xA6000000),
                        ],
                        stops: [0.0, 0.56, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Column(
                children: [
                  Row(
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
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) => MysteryProgressBar(
                      currentIndex: _currentPage,
                      currentProgress: _progressController.value,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 52),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_currentPage + 1}o Misterio',
                    style: context.textStyles.secondary.copyWith(
                      color: const Color(0xCCFFFFFF),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mystery.name,
                    style: context.textStyles.sectionTitle.copyWith(
                      color: const Color(0xFFFFFFFF),
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fruto: ${mystery.fruit}',
                    style: context.textStyles.secondary.copyWith(
                      color: const Color(0xB3FFFFFF),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDecade(int mysteryIndex) async {
    HapticFeedback.lightImpact();
    final result = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(
        builder: (_) => RosaryDecadeScreen(
          mysterySet: widget.mysterySet,
          mysteryIndex: mysteryIndex,
        ),
      ),
    );

    if (!mounted) return;
    if (result == true &&
        mysteryIndex < widget.mysterySet.mysteries.length - 1) {
      await _pageController.animateToPage(
        mysteryIndex + 1,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }
}
