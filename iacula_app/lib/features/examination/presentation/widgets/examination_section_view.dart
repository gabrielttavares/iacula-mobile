import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/presentation/design/iacula_input.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../../confession/domain/entities/confession_examination_item.dart';
import '../../application/examination_flow_notifier.dart';
import '../../domain/entities/examination_reflection_item.dart';

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
        ],
      ),
    );
  }
}

class _ExaminationList extends ConsumerStatefulWidget {
  const _ExaminationList({required this.items});

  final List<ConfessionExaminationItem> items;

  @override
  ConsumerState<_ExaminationList> createState() => _ExaminationListState();
}

class _ExaminationListState extends ConsumerState<_ExaminationList> {
  final _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _addPersonalPoint() async {
    final text = _addController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    await ref.read(examinationReflectionRepositoryProvider).createItem(
          sectionTitle: 'Pontos particulares',
          text: text,
        );
    _addController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final personalItemsAsync = ref.watch(examinationReflectionItemsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'Exame de Consciência para Confissão',
          style: context.textStyles.largeTitle.copyWith(
            color: const Color(0xFF8F2830),
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 24),
        for (final item in widget.items) ...[
          Text(item.text, style: context.textStyles.readingBody),
          const SizedBox(height: 24),
        ],
        // --- Personal examination points ---
        const SizedBox(height: 8),
        Container(
          height: 1,
          color: context.colors.separator,
        ),
        const SizedBox(height: 24),
        Text(
          'Meus pontos particulares de exame',
          style: context.textStyles.cardTitle,
        ),
        const SizedBox(height: 8),
        Text(
          'Seus pontos particulares de exame ficam salvos apenas no seu celular.',
          style: context.textStyles.secondary.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 16),
        personalItemsAsync.when(
          data: (items) => Column(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _PersonalPointCard(item: item),
                ),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CupertinoActivityIndicator(),
          ),
          error: (_, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: IaculaTextInput(
                controller: _addController,
                placeholder: 'Adicionar ponto particular...',
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _addPersonalPoint(),
              ),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(36, 36),
              onPressed: _addPersonalPoint,
              child: Icon(
                CupertinoIcons.add_circled_solid,
                color: context.colors.primaryButton,
                size: 28,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PersonalPointCard extends ConsumerWidget {
  const _PersonalPointCard({required this.item});

  final ExaminationReflectionItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.separator),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.text,
              style: context.textStyles.readingBody,
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(28, 28),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref
                  .read(examinationReflectionRepositoryProvider)
                  .deleteItem(item.id);
            },
            child: Icon(
              CupertinoIcons.xmark_circle_fill,
              size: 20,
              color: context.colors.textSecondary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
