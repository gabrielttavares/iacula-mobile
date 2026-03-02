// lib/features/examination/presentation/widgets/examination_review_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/iacula_spring_button.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../application/examination_flow_notifier.dart';

class ExaminationReviewView extends ConsumerWidget {
  const ExaminationReviewView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(examinationFlowProvider);
    final notifier = ref.read(examinationFlowProvider.notifier);
    final totalChecked = flowState.totalChecked +
        (flowState.freeText.trim().isNotEmpty ? 1 : 0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Column(
            children: [
              const Spacer(flex: 2),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Icon(
                  CupertinoIcons.doc_text,
                  size: 56,
                  color: context.colors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Você selecionou $totalChecked ${totalChecked == 1 ? 'falta' : 'faltas'}.',
                style: context.textStyles.sectionTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Revise se desejar, ou gere sua confissão.',
                style: context.textStyles.secondary,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              IaculaSpringButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  notifier.generateConfession();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: context.colors.primaryButton,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Gerar Confissão',
                    style: context.textStyles.cardTitle.copyWith(
                      color: context.colors.background,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  notifier.goBackToExamination();
                },
                child: Text(
                  'Revisar',
                  style: context.textStyles.secondary.copyWith(
                    color: context.colors.primaryButton,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
