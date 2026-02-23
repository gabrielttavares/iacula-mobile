import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import 'prayer_screen.dart';

class PrayerCollectionsScreen extends ConsumerWidget {
  const PrayerCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _PrayerCategoryCard(
            title: 'Angelus / Regina Caeli',
            icon: Icons.notifications_active_outlined,
            onTap: () async {
              final settings = await ref.read(getSettingsUseCaseProvider).call();
              final prayer = await ref.read(getPrayerUseCaseProvider).call(
                    language: settings.language,
                  );
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PrayerScreen(prayer: prayer),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          _PrayerCategoryCard(
            title: 'Devoções',
            icon: Icons.auto_awesome,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Em breve...')),
              );
            },
          ),
        ],
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
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
