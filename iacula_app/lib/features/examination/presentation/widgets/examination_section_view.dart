// lib/features/examination/presentation/widgets/examination_section_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/design/iacula_input.dart';
import '../../../../core/presentation/widgets/iacula_spring_button.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../application/examination_flow_notifier.dart';
import '../../domain/data/examination_checklist.dart';

class ExaminationSectionView extends ConsumerWidget {
  const ExaminationSectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(examinationFlowProvider);
    final notifier = ref.read(examinationFlowProvider.notifier);
    final sectionIndex = flowState.currentSectionIndex;
    
    // We add one extra "page" for the free text entry
    final totalPages = flowState.totalSections + 1;

    return SafeArea(
      child: Column(
        children: [
          // Top bar with back, progress, close
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: sectionIndex > 0
                      ? () {
                          HapticFeedback.selectionClick();
                          if (sectionIndex == flowState.totalSections) {
                            notifier.goToSection(flowState.totalSections - 1);
                          } else {
                            notifier.previousSection();
                          }
                        }
                      : () {
                          // Go back to preparation
                          notifier.clearAll();
                        },
                  child: Icon(
                    CupertinoIcons.chevron_back,
                    color: context.colors.textSecondary,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${sectionIndex + 1} / $totalPages',
                    style: context.textStyles.secondary,
                    textAlign: TextAlign.center,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticFeedback.lightImpact();
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
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (sectionIndex + 1) / totalPages,
                backgroundColor: context.colors.separator,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.colors.primaryButton,
                ),
                minHeight: 4,
              ),
            ),
          ),
          // Content
          Expanded(
            child: sectionIndex < flowState.totalSections
                ? _buildSectionContent(context, ref, flowState, sectionIndex)
                : _buildFreeTextPage(context, ref, flowState),
          ),
          // Bottom navigation
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: IaculaSpringButton(
              onTap: () {
                HapticFeedback.lightImpact();
                if (sectionIndex < flowState.totalSections - 1) {
                  notifier.nextSection();
                } else if (sectionIndex == flowState.totalSections - 1) {
                  // Go to free text page
                  notifier.goToSection(flowState.totalSections);
                } else {
                  // From free text page, go to review
                  notifier.goToReview();
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: context.colors.primaryButton,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  sectionIndex >= flowState.totalSections
                      ? 'Revisar'
                      : 'Próximo',
                  style: context.textStyles.cardTitle.copyWith(
                    color: context.colors.background,
                    fontSize: 17,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(
    BuildContext context,
    WidgetRef ref,
    ExaminationFlowState flowState,
    int sectionIndex,
  ) {
    final section = kExaminationSections[sectionIndex];
    final checkedItems = flowState.checkedItems[sectionIndex] ?? {};

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          section.title,
          style: context.textStyles.sectionTitle,
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < section.items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ref
                    .read(examinationFlowProvider.notifier)
                    .toggleItem(sectionIndex, i);
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      checkedItems.contains(i)
                          ? CupertinoIcons.checkmark_square_fill
                          : CupertinoIcons.square,
                      color: checkedItems.contains(i)
                          ? context.colors.primaryButton
                          : context.colors.textSecondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        section.items[i],
                        style: context.textStyles.secondary.copyWith(
                          fontSize: 15,
                          height: 1.4,
                          color: checkedItems.contains(i)
                              ? context.colors.textPrimary
                              : context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFreeTextPage(
    BuildContext context,
    WidgetRef ref,
    ExaminationFlowState flowState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outras faltas que desejo confessar',
            style: context.textStyles.sectionTitle,
          ),
          const SizedBox(height: 8),
          Text(
            'Opcional. Escreva livremente.',
            style: context.textStyles.secondary,
          ),
          const SizedBox(height: 16),
          IaculaTextInput(
            placeholder: 'Escreva aqui...',
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (text) {
              ref.read(examinationFlowProvider.notifier).updateFreeText(text);
            },
          ),
        ],
      ),
    );
  }
}

// Temporary: Flutter doesn't have LinearProgressIndicator in Cupertino.
// Use a simple custom one.
class LinearProgressIndicator extends StatelessWidget {
  const LinearProgressIndicator({
    super.key,
    required this.value,
    required this.backgroundColor,
    required this.valueColor,
    this.minHeight = 4,
  });

  final double value;
  final Color backgroundColor;
  final Animation<Color> valueColor;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: minHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                width: constraints.maxWidth,
                height: minHeight,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(minHeight / 2),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: constraints.maxWidth * value.clamp(0, 1),
                height: minHeight,
                decoration: BoxDecoration(
                  color: valueColor.value,
                  borderRadius: BorderRadius.circular(minHeight / 2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
