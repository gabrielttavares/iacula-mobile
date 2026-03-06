enum JournalPromptCategory { liturgical, ignatian, lectioDivina, general }

extension JournalPromptCategoryX on JournalPromptCategory {
  String get assetKey => switch (this) {
    JournalPromptCategory.liturgical => 'liturgical',
    JournalPromptCategory.ignatian => 'ignatian',
    JournalPromptCategory.lectioDivina => 'lectio_divina',
    JournalPromptCategory.general => 'general',
  };

  String get label => switch (this) {
    JournalPromptCategory.liturgical => 'Litúrgico',
    JournalPromptCategory.ignatian => 'Inaciano',
    JournalPromptCategory.lectioDivina => 'Lectio Divina',
    JournalPromptCategory.general => 'Geral',
  };

  String get description => switch (this) {
    JournalPromptCategory.liturgical =>
      'Reflita a partir do tempo litúrgico e da Palavra do dia.',
    JournalPromptCategory.ignatian =>
      'Examine o dia na presença de Deus com simplicidade.',
    JournalPromptCategory.lectioDivina =>
      'Leve a leitura à oração e à resposta concreta.',
    JournalPromptCategory.general =>
      'Escreva a partir da vida interior e das graças recebidas.',
  };

  static JournalPromptCategory fromAssetKey(String key) {
    return JournalPromptCategory.values.firstWhere(
      (value) => value.assetKey == key,
    );
  }
}

final class JournalPrompt {
  const JournalPrompt({
    required this.id,
    required this.category,
    required this.text,
  });

  final String id;
  final JournalPromptCategory category;
  final String text;
}
