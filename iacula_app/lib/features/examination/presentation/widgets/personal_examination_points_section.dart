import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/presentation/design/iacula_input.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../domain/entities/examination_reflection_item.dart';
import '../../domain/examination_reflection_constants.dart';

class PersonalExaminationPointsSection extends ConsumerStatefulWidget {
  const PersonalExaminationPointsSection({
    super.key,
    required this.items,
  });

  final List<ExaminationReflectionItem> items;

  @override
  ConsumerState<PersonalExaminationPointsSection> createState() =>
      _PersonalExaminationPointsSectionState();
}

class _PersonalExaminationPointsSectionState
    extends ConsumerState<PersonalExaminationPointsSection> {
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
          sectionTitle: kPersonalExaminationSectionTitle,
          text: text,
        );
    _addController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        Column(
          children: [
            for (final item in widget.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PersonalPointCard(item: item),
              ),
          ],
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
