import 'package:flutter/material.dart';

import '../domain/entities/prayer.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key, required this.prayer});

  final Prayer prayer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(prayer.title)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (prayer.imagePath != null)
            Image.asset(
              prayer.imagePath!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.surface.withValues(alpha: 0.65),
                  colorScheme.surface.withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: prayer.verses.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == prayer.verses.length) {
                          return Text(
                            prayer.prayer,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          );
                        }

                        final verse = prayer.verses[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              verse.verse,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                                height: 1.5,
                              ),
                            ),
                            if (verse.response.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                verse.response,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
