import 'package:flutter/material.dart';

import '../domain/entities/prayer.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({
    super.key,
    required this.prayer,
  });

  final Prayer prayer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13100D),
      appBar: AppBar(title: Text(prayer.title)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (prayer.imagePath != null)
            Image.asset(
              prayer.imagePath!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xA6000000), Color(0xEA0F0C09)],
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: prayer.verses.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == prayer.verses.length) {
                          return Text(
                            prayer.prayer,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFFF6EEE1),
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
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                            if (verse.response.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                verse.response,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFFE5D5BE),
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
