// lib/features/examination/presentation/examination_flow_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/cupertino_tokens.dart';
import '../application/examination_flow_notifier.dart';
import 'widgets/examination_preparation_view.dart';
import 'widgets/examination_section_view.dart';

class ExaminationFlowScreen extends ConsumerStatefulWidget {
  const ExaminationFlowScreen({super.key, this.skipPreparation = false});

  final bool skipPreparation;

  @override
  ConsumerState<ExaminationFlowScreen> createState() =>
      _ExaminationFlowScreenState();
}

class _ExaminationFlowScreenState extends ConsumerState<ExaminationFlowScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Clear all ephemeral state when app goes to background
      ref.read(examinationFlowProvider.notifier).clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.skipPreparation) {
      return CupertinoPageScaffold(
        backgroundColor: context.colors.background,
        child: const ExaminationSectionView(),
      );
    }

    final flowState = ref.watch(examinationFlowProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      child: switch (flowState.step) {
        ExaminationStep.preparation => const ExaminationPreparationView(),
        ExaminationStep.examination => const ExaminationSectionView(),
      },
    );
  }
}
