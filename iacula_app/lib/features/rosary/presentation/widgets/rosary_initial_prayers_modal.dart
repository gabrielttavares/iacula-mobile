import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/cupertino_tokens.dart';

class RosaryInitialPrayersModal extends ConsumerStatefulWidget {
  const RosaryInitialPrayersModal({super.key});

  @override
  ConsumerState<RosaryInitialPrayersModal> createState() =>
      _RosaryInitialPrayersModalState();
}

class _RosaryInitialPrayersModalState
    extends ConsumerState<RosaryInitialPrayersModal> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final initialPrayersAsync = ref.watch(rosaryInitialPrayersProvider('pt-br'));

    return initialPrayersAsync.when(
      data: (prayers) {
        final options = prayers.optionsForLanguage('pt-br');
        if (options.isEmpty) {
          return const Center(child: Text('Nenhuma oração encontrada.'));
        }

        final selectedOption = options[_selectedIndex];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: context.colors.textSecondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedIndex,
                onValueChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedIndex = value);
                  }
                },
                children: {
                  for (int i = 0; i < options.length; i++)
                    i: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        options[i].title,
                        style: context.textStyles.secondary.copyWith(
                          fontSize: 14,
                          fontWeight: _selectedIndex == i
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                },
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedOption.title,
                      style: context.textStyles.sectionTitle.copyWith(
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...selectedOption.lines.map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          line,
                          style: context.textStyles.secondary.copyWith(
                            fontSize: 16,
                            height: 1.5,
                            color: context.colors.textPrimary,
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
      },
      loading: () => const SizedBox(
        height: 300,
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (err, stack) => SizedBox(
        height: 300,
        child: Center(child: Text('Erro ao carregar orações: $err')),
      ),
    );
  }
}
