import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../../confession/domain/entities/confession_examination_item.dart';
import '../../application/examination_flow_notifier.dart';
import 'examination_confession_view.dart';

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
                    Navigator.of(context).pop();
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
              data: (items) => _ExaminationBody(items: items),
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
        ],
      ),
    );
  }
}

class _ExaminationBody extends ConsumerWidget {
  const _ExaminationBody({required this.items});

  final List<ConfessionExaminationItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(
      examinationFlowProvider.select((s) => s.selectedItemIds),
    );

    return Stack(
      children: [
        _ExaminationList(items: items),
        if (selectedIds.isNotEmpty)
          Positioned(
            left: 24,
            right: 24,
            bottom: 16,
            child: _SelectionPillButton(count: selectedIds.length),
          ),
      ],
    );
  }
}

class _SelectionPillButton extends ConsumerWidget {
  const _SelectionPillButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const ExaminationConfessionView(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.primaryButton,
          borderRadius: BorderRadius.circular(IaculaRadius.card),
          boxShadow: IaculaShadows.buttonResting,
        ),
        child: Text(
          'Ver $count selecionado${count == 1 ? '' : 's'}',
          style: context.textStyles.cardTitle.copyWith(
            color: context.colors.background,
            fontSize: 17,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ExaminationList extends ConsumerWidget {
  const _ExaminationList({required this.items});

  final List<ConfessionExaminationItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Exame de Consciência para Confissão',
          style: context.textStyles.largeTitle.copyWith(
            color: const Color(0xFF8F2830),
          ),
        ),
        const SizedBox(height: 32),
        for (final item in items) ...[
          _CheckableItemRow(item: item),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _CheckableItemRow extends ConsumerWidget {
  const _CheckableItemRow({required this.item});

  final ConfessionExaminationItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(
      examinationFlowProvider.select(
        (s) => s.selectedItemIds.contains(item.id),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(examinationFlowProvider.notifier).toggleItem(item.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.text,
                style: context.textStyles.readingBody,
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                isSelected
                    ? CupertinoIcons.checkmark_square_fill
                    : CupertinoIcons.square,
                color: isSelected
                    ? context.colors.primaryButton
                    : context.colors.textSecondary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
