import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../prayers/presentation/widgets/font_size_controls.dart';
import '../domain/entities/doctrine_entry.dart';

class DoctrineDetailScreen extends ConsumerWidget {
  const DoctrineDetailScreen({super.key, required this.entry});

  final DoctrineEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(getSettingsUseCaseProvider).call();

    return FutureBuilder(
      future: settingsAsync,
      builder: (context, snapshot) {
        final fontSize = snapshot.data?.prayerFontSize ?? 15.0;

        return CupertinoPageScaffold(
          backgroundColor: context.colors.background,
          navigationBar: CupertinoNavigationBar(
            middle: Text(entry.title),
            backgroundColor: context.colors.background,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(IaculaSpacing.md),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.title,
                            style: context.textStyles.sectionTitle.copyWith(
                              fontSize: fontSize + 7,
                            ),
                          ),
                        ),
                        const FontSizeControls(),
                      ],
                    ),
                    const SizedBox(height: IaculaSpacing.lg),
                    Text(
                      entry.content,
                      style: context.textStyles.secondary.copyWith(
                        color: context.colors.textPrimary,
                        height: 1.6,
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
