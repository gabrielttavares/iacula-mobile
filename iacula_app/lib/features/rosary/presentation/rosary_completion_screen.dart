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
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Text(
                          'Salve Rainha, Mae de Misericordia, vida, docura e esperanca nossa, salve!\n\nToque para continuar.',
                          textAlign: TextAlign.center,
                          style: context.textStyles.cardTitle.copyWith(
                            color: const Color(0xFFFFFFFF),
                            fontSize: 20,
                            height: 1.5,
                          ),
                        ),
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
                            'Rosario completo',
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
                            'Sequencia: ${widget.streakCount}',
                            style: context.textStyles.secondary.copyWith(
                              color: const Color(0xCCFFFFFF),
                            ),
                          ),
                          const SizedBox(height: 18),
                          CupertinoButton.filled(
                            onPressed: widget.onDone,
                            borderRadius: BorderRadius.circular(999),
                            child: const Text('Concluido'),
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
