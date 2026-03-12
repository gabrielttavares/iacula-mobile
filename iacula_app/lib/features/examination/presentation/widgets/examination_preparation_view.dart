// lib/features/examination/presentation/widgets/examination_preparation_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/widgets/iacula_spring_button.dart';
import '../../../../core/theme/cupertino_tokens.dart';
import '../../application/examination_flow_notifier.dart';
import '../confession_guide_screen.dart';

class ExaminationPreparationView extends ConsumerWidget {
  const ExaminationPreparationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Icon(
              CupertinoIcons.heart,
              size: 56,
              color: context.colors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Exame de Consciência para Confissão',
              style: context.textStyles.largeTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Coloque-se na presença de Deus.\n'
              'Peça a luz do Espírito Santo para reconhecer '
              'suas faltas com sinceridade e confiança '
              'na misericórdia divina.',
              style: context.textStyles.readingBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Este exame é pessoal e privado. Nada do que for '
              'escrito aqui será armazenado.',
              style: context.textStyles.secondary.copyWith(
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 3),
            IaculaSpringButton(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(examinationFlowProvider.notifier).startExamination();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: context.colors.primaryButton,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Começar',
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
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => const ConfessionGuideScreen(),
                  ),
                );
              },
              child: Text(
                'Como se confessar?',
                style: context.textStyles.secondary.copyWith(
                  color: context.colors.primaryButton,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
