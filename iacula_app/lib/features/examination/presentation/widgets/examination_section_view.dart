import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/presentation/widgets/iacula_spring_button.dart';
import '../../../../core/presentation/widgets/iacula_toast.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../../confession/domain/entities/confession_examination_item.dart';
import '../../application/examination_flow_notifier.dart';

class ExaminationSectionView extends ConsumerWidget {
  const ExaminationSectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(confessionExaminationItemsProvider);

    return SafeArea(
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
                    ref.read(examinationFlowProvider.notifier).clearAll();
                  },
                  child: Icon(
                    CupertinoIcons.chevron_back,
                    color: context.colors.textSecondary,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Exame de Consciência',
                    style: context.textStyles.cardTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(examinationFlowProvider.notifier).clearAll();
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
          Expanded(
            child: itemsAsync.when(
              data: (items) => _ExaminationList(items: items),
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Não foi possível carregar o exame de consciência.',
                    style: context.textStyles.secondary,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          itemsAsync.maybeWhen(
            data: (items) => _ShareBar(items: items),
            orElse: SizedBox.shrink,
          ),
        ],
      ),
    );
  }
}

class _ExaminationList extends ConsumerWidget {
  const _ExaminationList({required this.items});

  final List<ConfessionExaminationItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(examinationFlowProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Selecione os itens que deseja levar para a confissão.',
          style: context.textStyles.sectionTitle,
        ),
        const SizedBox(height: 8),
        Text(
          'Os itens são baseados no exame de consciência para adultos do Opus Dei e foram adaptados para afirmações em primeira pessoa.',
          style: context.textStyles.secondary,
        ),
        const SizedBox(height: 20),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(examinationFlowProvider.notifier).toggleItem(item.id);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: flowState.selectedItemIds.contains(item.id)
                        ? context.colors.primaryButton
                        : context.colors.separator,
                  ),
                  boxShadow: IaculaShadows.card,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          flowState.selectedItemIds.contains(item.id)
                              ? CupertinoIcons.checkmark_square_fill
                              : CupertinoIcons.square,
                          key: ValueKey<bool>(
                            flowState.selectedItemIds.contains(item.id),
                          ),
                          color: flowState.selectedItemIds.contains(item.id)
                              ? context.colors.primaryButton
                              : context.colors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.text,
                        style: context.textStyles.readingBody.copyWith(
                          color: flowState.selectedItemIds.contains(item.id)
                              ? context.colors.textPrimary
                              : context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
      ],
    );
  }
}

class _ShareBar extends ConsumerWidget {
  const _ShareBar({required this.items});

  final List<ConfessionExaminationItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(examinationFlowProvider);
    final notifier = ref.read(examinationFlowProvider.notifier);
    final shareService = ref.read(nativeShareServiceProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            flowState.totalChecked == 0
                ? 'Nenhum item selecionado.'
                : '${flowState.totalChecked} ${flowState.totalChecked == 1 ? 'item selecionado' : 'itens selecionados'}.',
            style: context.textStyles.secondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          IaculaSpringButton(
            onTap: () async {
              HapticFeedback.lightImpact();
              if (flowState.totalChecked == 0) {
                IaculaToast.show(context, 'Selecione ao menos um item.');
                return;
              }

              final text = notifier.buildShareText(items);
              await shareService.shareText(text);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: context.colors.primaryButton,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Compartilhar',
                style: context.textStyles.cardTitle.copyWith(
                  color: context.colors.background,
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
