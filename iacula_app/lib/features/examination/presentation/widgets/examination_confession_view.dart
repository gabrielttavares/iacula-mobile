import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/presentation/design/iacula_feedback.dart';
import '../../../../core/presentation/widgets/iacula_spring_button.dart';
import '../../../../core/presentation/widgets/iacula_toast.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../application/examination_flow_notifier.dart';

class ExaminationConfessionView extends ConsumerWidget {
  const ExaminationConfessionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(examinationFlowProvider);
    final notifier = ref.read(examinationFlowProvider.notifier);
    final itemsAsync = ref.watch(confessionExaminationItemsProvider);

    final selectedItems = itemsAsync.whenOrNull<List<(String, String)>>(
      data: (items) => items
          .where((i) => flowState.selectedItemIds.contains(i.id))
          .map((i) => (i.id, i.text))
          .toList(),
    );

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      CupertinoIcons.chevron_back,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Selecionados',
                      style: context.textStyles.cardTitle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                physics: const BouncingScrollPhysics(),
                children: [
                  IaculaInlineMessage(
                    message:
                        'Lista temporária — será perdida ao sair desta tela.',
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(height: 24),
                  if (selectedItems != null && selectedItems.isNotEmpty) ...[
                    for (final entry in selectedItems) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6, right: 10),
                            child: Icon(
                              CupertinoIcons.circle_fill,
                              size: 6,
                              color: context.colors.textSecondary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.$2,
                              style: context.textStyles.readingBody,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ] else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          'Nenhum item selecionado.',
                          style: context.textStyles.secondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (selectedItems != null && selectedItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: IaculaSpringButton(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final text = itemsAsync.whenOrNull<String>(
                            data: (items) =>
                                notifier.buildShareText(items),
                          );
                          if (text != null && text.isNotEmpty) {
                            Clipboard.setData(ClipboardData(text: text));
                            IaculaToast.show(context, 'Texto copiado.');
                          }
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
                          Navigator.of(context).pop();
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
      ),
    );
  }
}
