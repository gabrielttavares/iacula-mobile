final class RosaryInitialPrayerOption {
  const RosaryInitialPrayerOption({
    required this.id,
    required this.title,
    required this.lines,
  });

  final String id;
  final String title;
  final List<String> lines;

  factory RosaryInitialPrayerOption.fromJson(Map<String, dynamic> json) {
    return RosaryInitialPrayerOption(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      lines: _toStringList(json['lines']),
    );
  }
}

final class RosaryInitialPrayers {
  const RosaryInitialPrayers({required this.options});

  final Map<String, List<RosaryInitialPrayerOption>> options;

  factory RosaryInitialPrayers.empty() {
    return const RosaryInitialPrayers(options: {'pt-br': []});
  }

  factory RosaryInitialPrayers.fromJson(Map<String, dynamic> json) {
    final rawOptions = (json['options'] as Map<String, dynamic>?) ?? const {};
    final parsedOptions = <String, List<RosaryInitialPrayerOption>>{};

    for (final entry in rawOptions.entries) {
      final language = entry.key;
      final list = (entry.value as List<dynamic>?) ?? const [];
      parsedOptions[language] = list
          .whereType<Map<String, dynamic>>()
          .map(RosaryInitialPrayerOption.fromJson)
          .toList(growable: false);
    }

    if (!parsedOptions.containsKey('pt-br')) {
      final firstKey =
          parsedOptions.isNotEmpty ? parsedOptions.keys.first : 'pt-br';
      final fallback =
          parsedOptions[firstKey] ?? const <RosaryInitialPrayerOption>[];
      parsedOptions['pt-br'] = fallback;
    }

    return RosaryInitialPrayers(options: parsedOptions);
  }

  List<RosaryInitialPrayerOption> optionsForLanguage(String language) {
    return options[language] ?? options['pt-br'] ?? const [];
  }
}

List<String> _toStringList(Object? value) {
  if (value is! List) return const [];
  return value.map((e) => e.toString()).toList(growable: false);
}
