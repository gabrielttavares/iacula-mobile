// lib/features/examination/presentation/widgets/examination_confession_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/iacula_spring_button.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../application/examination_flow_notifier.dart';

class ExaminationConfessionView extends ConsumerWidget {
  const ExaminationConfessionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(examinationFlowProvider);
    final notifier = ref.read(examinationFlowProvider.notifier);
    final confession = flowState.generatedConfession ?? '';

    return SafeArea(
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    notifier.clearAll();
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    CupertinoIcons.xmark,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              physics: const BouncingScrollPhysics(),
              children: [
                Text(
                  'Confissão',
                  style: context.textStyles.largeTitle,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.colors.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: IaculaShadows.card,
                  ),
                  child: Text(
                    confession,
                    style: context.textStyles.secondary.copyWith(
                      fontSize: 16,
                      height: 1.6,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Privacy notice
                Text(
                  'Sua confissão não é armazenada em nenhum local. '
                  'Ela não é salva no dispositivo nem em nossos servidores.',
                  style: context.textStyles.secondary.copyWith(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Bottom actions
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              children: [
                Expanded(
                  child: IaculaSpringButton(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Clipboard.setData(ClipboardData(text: confession));
                      _showCopiedToast(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: context.colors.primaryButton,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Copiar',
                        style: context.textStyles.cardTitle.copyWith(
                          color: context.colors.background,
                          fontSize: 17,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: IaculaSpringButton(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      notifier.clearAll();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: context.colors.secondaryButton,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Limpar tudo',
                        style: context.textStyles.cardTitle.copyWith(
                          fontSize: 17,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCopiedToast(BuildContext context) {
    final overlay = Navigator.of(context).overlay;
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Texto copiado.',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }
}
