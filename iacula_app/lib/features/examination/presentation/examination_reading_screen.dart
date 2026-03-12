import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/cupertino_tokens.dart';
import 'examination_management_screen.dart';

class ExaminationReadingScreen extends ConsumerStatefulWidget {
  const ExaminationReadingScreen({super.key});

  @override
  ConsumerState<ExaminationReadingScreen> createState() =>
      _ExaminationReadingScreenState();
}

class _ExaminationReadingScreenState
    extends ConsumerState<ExaminationReadingScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref
          .read(examinationReflectionRepositoryProvider)
          .seedDefaultsIfEmpty(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(examinationReflectionItemsProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Exame de Consciência Diário'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => const ExaminationManagementScreen(),
            ),
          ),
          child: const Icon(CupertinoIcons.square_list),
        ),
      ),
      child: SafeArea(
        child: itemsAsync.when(
          data: (items) => ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Text(
                'Exame de Consciência Diário',
                style: context.textStyles.largeTitle.copyWith(
                  color: const Color(0xFF8F2830),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Para fazer ao final do dia',
                style: context.textStyles.secondary.copyWith(
                  fontSize: 18,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              for (final item in items) ...[
                Text(item.sectionTitle, style: context.textStyles.sectionTitle),
                const SizedBox(height: 8),
                Text(
                  item.text,
                  style: context.textStyles.readingBody,
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              'Não foi possível carregar o exame.',
              style: context.textStyles.secondary,
            ),
          ),
        ),
      ),
    );
  }
}
