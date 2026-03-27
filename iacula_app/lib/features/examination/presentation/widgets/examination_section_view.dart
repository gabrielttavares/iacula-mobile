import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
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

class _ExaminationList extends StatelessWidget {
  const _ExaminationList({required this.items});

  final List<ConfessionExaminationItem> items;

  @override
  Widget build(BuildContext context) {
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
        for (final item in items) ...[
          Text(item.text, style: context.textStyles.readingBody),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}
