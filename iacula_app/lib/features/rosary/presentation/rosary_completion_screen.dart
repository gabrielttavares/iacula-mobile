import 'package:flutter/cupertino.dart';

import '../../../core/theme/cupertino_tokens.dart';
import 'widgets/ken_burns_image.dart';

class RosaryCompletionScreen extends StatefulWidget {
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
  State<RosaryCompletionScreen> createState() => _RosaryCompletionScreenState();
}

class _RosaryCompletionScreenState extends State<RosaryCompletionScreen> {
  bool _showSalve = true;

  @override
  Widget build(BuildContext context) {
    final minutes = widget.elapsed.inMinutes <= 0
        ? 1
        : widget.elapsed.inMinutes;
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: _showSalve
                ? GestureDetector(
                    key: const Key('rosary-completion-salve'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _showSalve = false),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Text(
                              'Salve Rainha, Mãe de Misericórdia, vida, doçura e esperança nossa, salve!',
                              textAlign: TextAlign.center,
                              style: context.textStyles.cardTitle.copyWith(
                                color: const Color(0xFFFFFFFF),
                                fontSize: 20,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          CupertinoButton.filled(
                            onPressed: () => setState(() => _showSalve = false),
                            borderRadius: BorderRadius.circular(999),
                            child: const Text('Continuar'),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  )
                : Center(
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
                            onPressed: widget.onDone,
                            borderRadius: BorderRadius.circular(999),
                            child: const Text('Concluído'),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
