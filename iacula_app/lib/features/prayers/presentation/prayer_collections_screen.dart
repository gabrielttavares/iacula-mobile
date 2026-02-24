import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import 'prayer_screen.dart';

class PrayerCollectionsScreen extends ConsumerWidget {
  const PrayerCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(IaculaSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IaculaLargeTitle('Orações'),
              const SizedBox(height: IaculaSpacing.lg),
              _PrayerCategoryCard(
                title: 'Angelus / Regina Caeli',
                icon: CupertinoIcons.bell,
                onTap: () async {
                  final settings = await ref
                      .read(getSettingsUseCaseProvider)
                      .call();
                  final prayer = await ref
                      .read(getPrayerUseCaseProvider)
                      .call(language: settings.language);
                  if (context.mounted) {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => PrayerScreen(prayer: prayer),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: IaculaSpacing.sm),
              _PrayerCategoryCard(
                title: 'Devoções',
                icon: CupertinoIcons.sparkles,
                onTap: () async {
                  await showCupertinoDialog<void>(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Devoções'),
                      content: const Text('Em breve...'),
                      actions: [
                        CupertinoDialogAction(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerCategoryCard extends StatelessWidget {
  const _PrayerCategoryCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IaculaSoftCard(
        radius: 16,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F1F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: IaculaColors.primaryButton),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: IaculaText.cardTitle)),
            const Icon(
              CupertinoIcons.chevron_right,
              color: IaculaColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
