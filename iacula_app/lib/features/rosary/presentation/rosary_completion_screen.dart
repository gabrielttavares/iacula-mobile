import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/cupertino_tokens.dart';
import 'widgets/ken_burns_image.dart';
import '../domain/entities/rosary_final_prayers.dart';

class RosaryCompletionScreen extends ConsumerStatefulWidget {
  const RosaryCompletionScreen({
    super.key,
    required this.mysteryImagePath,
    required this.elapsed,
    required this.streakCount,
    required this.onDone,
  });

  final String? mysteryImagePath;
  final Duration elapsed;
  final int streakCount;
  final VoidCallback onDone;

  @override
  ConsumerState<RosaryCompletionScreen> createState() =>
      _RosaryCompletionScreenState();
}

class _RosaryCompletionScreenState
    extends ConsumerState<RosaryCompletionScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.elapsed.inMinutes <= 0 ? 1 : widget.elapsed.inMinutes;
    final completionPrayersAsync = ref.watch(
      rosaryCompletionPrayersProvider('pt-br'),
    );
    final completionPrayers = completionPrayersAsync.valueOrNull
            ?.pagesForLanguage('pt-br') ??
        const <RosaryCompletionPrayerPage>[];
    final totalPages = completionPrayers.length + 2;

    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          KenBurnsImage(
            imagePath: widget.mysteryImagePath,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x26000000),
                    Color(0x66000000),
                    Color(0xB3000000),
                  ],
                ),
              ),
            ),
          ),
          PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildDecisionPage(context, totalPages);
              }
              if (index == totalPages - 1) {
                return _buildSummaryPage(context, minutes);
              }
              return _buildPrayerPage(
                context,
                completionPrayers[index - 1],
              );
            },
          ),
          if (completionPrayersAsync.isLoading)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x66000000),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const CupertinoActivityIndicator(),
                  ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  void _goToPage(int index) {
    if (!mounted) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _finishRosary() {
    widget.onDone();
  }

  Widget _buildDecisionPage(BuildContext context, int totalPages) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '5º mistério concluído',
                  textAlign: TextAlign.center,
                  style: context.textStyles.sectionTitle.copyWith(
                    color: const Color(0xFFFFFFFF),
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Você pode encerrar agora ou continuar para rezar as orações finais.',
                  textAlign: TextAlign.center,
                  style: context.textStyles.secondary.copyWith(
                    color: const Color(0xCCFFFFFF),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Deslize para continuar',
                  style: context.textStyles.secondary.copyWith(
                    color: const Color(0x99FFFFFF),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoButton.filled(
                  onPressed: () {
                    _goToPage(1);
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: const Text('Continuar'),
                ),
                const SizedBox(height: 10),
                CupertinoButton(
                  onPressed: _finishRosary,
                  color: const Color(0x0CFFFFFF),
                  borderRadius: BorderRadius.circular(999),
                  child: const Text('Encerrar rosário'),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPrayerPage(
    BuildContext context,
    RosaryCompletionPrayerPage page,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x1A000000),
                        Color(0x00FFFFFF),
                        Color(0x1A000000),
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Container(color: const Color(0x00000000)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          page.title,
                          style: context.textStyles.cardTitle.copyWith(
                            color: const Color(0xFFFFFFFF),
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...page.lines.map(
                          (line) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              line,
                              style: context.textStyles.secondary.copyWith(
                                color: const Color(0xE6FFFFFF),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPage(BuildContext context, int minutes) {
    return SafeArea(
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rosário concluído',
                style: context.textStyles.sectionTitle.copyWith(
                  color: const Color(0xFFFFFFFF),
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$minutes minutos',
                style: context.textStyles.cardTitle.copyWith(
                  color: const Color(0xE6FFFFFF),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sequência: ${widget.streakCount}',
                style: context.textStyles.secondary.copyWith(
                  color: const Color(0xCCFFFFFF),
                ),
              ),
              const SizedBox(height: 18),
              CupertinoButton.filled(
                onPressed: _finishRosary,
                borderRadius: BorderRadius.circular(999),
                child: const Text('Concluído'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
