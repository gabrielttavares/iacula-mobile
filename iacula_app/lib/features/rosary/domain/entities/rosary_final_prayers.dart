final class RosaryCompletionPrayerPage {
  const RosaryCompletionPrayerPage({
    required this.title,
    required this.lines,
    this.conditionalLines = const {},
  });

  final String title;
  final List<String> lines;
  final Map<String, List<String>> conditionalLines;

  factory RosaryCompletionPrayerPage.fromJson(Map<String, dynamic> json) {
    final rawConditional = json['conditionalLines'] as Map<String, dynamic>?;
    final parsedConditional = <String, List<String>>{};

    if (rawConditional != null) {
      for (final entry in rawConditional.entries) {
        parsedConditional[entry.key] = _toStringList(entry.value);
      }
    }

    return RosaryCompletionPrayerPage(
      title: json['title']?.toString() ?? '',
      lines: _toStringList(json['lines']),
      conditionalLines: parsedConditional,
    );
  }
}

final class RosaryCompletionPrayers {
  const RosaryCompletionPrayers({required this.pages});

  final Map<String, List<RosaryCompletionPrayerPage>> pages;

  factory RosaryCompletionPrayers.empty() {
    return const RosaryCompletionPrayers(pages: {'pt-br': []});
  }

  factory RosaryCompletionPrayers.fromJson(Map<String, dynamic> json) {
    final rawPages = (json['pages'] as Map<String, dynamic>?) ?? const {};
    final parsedPages = <String, List<RosaryCompletionPrayerPage>>{};

    for (final entry in rawPages.entries) {
      final language = entry.key;
      final list = (entry.value as List<dynamic>?) ?? const [];
      parsedPages[language] = list
          .whereType<Map<String, dynamic>>()
          .map(RosaryCompletionPrayerPage.fromJson)
          .toList(growable: false);
    }

    if (!parsedPages.containsKey('pt-br')) {
      final firstKey = parsedPages.isNotEmpty ? parsedPages.keys.first : 'pt-br';
      final fallback = parsedPages[firstKey] ?? const <RosaryCompletionPrayerPage>[];
      parsedPages['pt-br'] = fallback;
    }

    return RosaryCompletionPrayers(pages: parsedPages);
  }

  List<RosaryCompletionPrayerPage> pagesForLanguage(String language) {
    return pages[language] ?? pages['pt-br'] ?? const [];
  }
}

List<String> _toStringList(Object? value) {
  if (value is! List) return const [];
  return value.map((e) => e.toString()).toList(growable: false);
}
