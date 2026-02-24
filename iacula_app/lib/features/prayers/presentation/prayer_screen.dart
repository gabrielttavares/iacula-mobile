import 'package:flutter/material.dart';

import '../domain/entities/prayer.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key, required this.prayer});

  final Prayer prayer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Background Image (Top 45%)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: mediaQuery.size.height * 0.45,
            child: prayer.imagePath != null
                ? Image.asset(
                    prayer.imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: colorScheme.primary),
                  )
                : Container(color: colorScheme.primary),
          ),

          // Custom Back Button
          Positioned(
            top: mediaQuery.padding.top + 8,
            left: 16,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
            ),
          ),

          // Draggable/Scrollable Content Container
          Positioned(
            top: mediaQuery.size.height * 0.4 - 24,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ListView(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 32,
                  bottom: 24,
                ),
                children: [
                  Text(
                    prayer.title,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$28.99',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '4.3',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          Icon(Icons.star,
                              color: colorScheme.primary, size: 24),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Prayer content
                  for (int index = 0;
                      index <= prayer.verses.length;
                      index++) ...[
                    if (index == prayer.verses.length)
                      Text(
                        prayer.prayer,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      )
                    else ...[
                      Text(
                        prayer.verses[index].verse,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                      if (prayer.verses[index].response.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          prayer.verses[index].response,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 32),
                  // Join Course Bottom Bar
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child:
                            Icon(Icons.add, color: colorScheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary
                                    .withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Join Course',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.surface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating Heart FAB
          Positioned(
            top: mediaQuery.size.height * 0.4 - 54,
            right: 35,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: colorScheme.primary,
              shape: const CircleBorder(),
              elevation: 10,
              child: Icon(Icons.favorite, color: colorScheme.surface),
            ),
          ),
        ],
      ),
    );
  }
}
