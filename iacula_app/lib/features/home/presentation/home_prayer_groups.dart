import 'package:flutter/painting.dart';

import '../../prayers/domain/entities/prayer_catalog_entry.dart';

enum HomePrayerGroupType { theme, saint, section }

final class HomePrayerGroup {
  const HomePrayerGroup({
    required this.key,
    required this.label,
    required this.itemCount,
    required this.type,
  });

  final String key;
  final String label;
  final int itemCount;
  final HomePrayerGroupType type;
}

const kSectionIcons = <String, String>{
  'oracoes-comuns': 'assets/icons/sections/oracoes-comuns.png',
  'oracoes-santissima-trindade': 'assets/icons/sections/oracoes-santissima-trindade.png',
  'adoracao-eucaristica': 'assets/icons/sections/adoracao-eucaristica.png',
  'ao-espirito-santo': 'assets/icons/sections/ao-espirito-santo.png',
  'oracoes-a-nossa-senhora': 'assets/icons/sections/oracoes-a-nossa-senhora.png',
  'preparacao-santa-missa': 'assets/icons/sections/preparacao-santa-missa.png',
  'acao-de-gracas-santa-missa': 'assets/icons/sections/acao-de-gracas-santa-missa.png',
  'oracoes-a-sao-jose': 'assets/icons/sections/oracoes-a-sao-jose.png',
  'oracoes-diversas': 'assets/icons/sections/oracoes-diversas.png',
  'outras-devocoes': 'assets/icons/sections/outras-devocoes.png',
  'oracoes-pelos-defuntos': 'assets/icons/sections/oracoes-pelos-defuntos.png',
  'hinos': 'assets/icons/sections/hinos.png',
  'formulas-doutrina-catolica': 'assets/icons/sections/formulas-doutrina-catolica.png',
};

const kSectionImages = <String, String>{
  'oracoes-comuns': 'assets/placeholders/sections/oracoes-comuns.jpg',
  'oracoes-santissima-trindade': 'assets/placeholders/sections/santissima-trindade.jpeg',
  'adoracao-eucaristica': 'assets/placeholders/sections/adoracao-eucaristica.jpg',
  'ao-espirito-santo': 'assets/placeholders/sections/ES.jpg',
  'oracoes-a-nossa-senhora': 'assets/placeholders/sections/our-lady.jpeg',
  'preparacao-santa-missa': 'assets/placeholders/sections/preparacao-santa-missa.jpg',
  'acao-de-gracas-santa-missa': 'assets/placeholders/sections/acao-de-gracas.jpeg',
  'oracoes-a-sao-jose': 'assets/placeholders/sections/st-joseph.jpeg',
  'oracoes-diversas': 'assets/placeholders/sections/oracoes-diversas.jpg',
  'outras-devocoes': 'assets/placeholders/sections/outras-devocoes.jpeg',
  'oracoes-pelos-defuntos': 'assets/placeholders/sections/defuntos.png',
  'hinos': 'assets/placeholders/sections/hinos.jpeg',
  'formulas-doutrina-catolica': 'assets/placeholders/sections/formulas.jpeg',
};

const kSectionImageAlignments = <String, Alignment>{
  'oracoes-comuns': Alignment(0, 0.3),
  'oracoes-santissima-trindade': Alignment(0, -0.4),
  'adoracao-eucaristica': Alignment(0, -0.25),
  'preparacao-santa-missa': Alignment(0, -0.6),
  'acao-de-gracas-santa-missa': Alignment(0, 0.35),
};

const kHomeShortcutIcons = <String, String>{
  'oracoes': 'assets/icons/sections/oracoes.png',
  'exame-diario': 'assets/icons/sections/exame-diario.png',
  'confissao': 'assets/icons/sections/confissao.png',
};

const kCuratedThemeOrder = <String>[
  'familia',
  'trabalho',
  'mariano',
  'penitencia',
  'protecao',
  'espirito-santo',
  'eucaristica',
];

const kHomeThematicOrder = <String>[
  'trabalho',
  'estudos',
  'viagem',
  'matrimonio',
  'familia',
  'gestacao',
  'igreja',
  'eucaristica',
  'anjos',
];

const _homeThematicLabels = <String, String>{
  'trabalho': 'Trabalho',
  'estudos': 'Estudos',
  'viagem': 'Viagem',
  'matrimonio': 'Matrimônio',
  'familia': 'Família',
  'gestacao': 'Gestação',
  'igreja': 'Igreja',
  'eucaristica': 'Divina Eucaristia',
  'anjos': 'Santos Anjos',
};

const kHomeThematicImages = <String, String>{
  'trabalho': 'assets/placeholders/oracoes-tematicas/trabalho.png',
  'estudos': 'assets/placeholders/oracoes-tematicas/estudos.png',
  'viagem': 'assets/placeholders/oracoes-tematicas/viagem.png',
  'matrimonio': 'assets/placeholders/oracoes-tematicas/matrimonio.png',
  'familia': 'assets/placeholders/oracoes-tematicas/familia.png',
  'gestacao': 'assets/placeholders/oracoes-tematicas/gestacao.png',
  'igreja': 'assets/placeholders/oracoes-tematicas/igreja.png',
  'eucaristica': 'assets/placeholders/oracoes-tematicas/eucaristia.png',
  'anjos': 'assets/placeholders/oracoes-tematicas/anjos.png',
};

const _curatedSaintOrder = <String>[
  'virgem-maria',
  'anjos',
  'sao-jose',
  'sao-josemaria',
  'sao-tomas-de-aquino',
];

const _themeLabels = <String, String>{
  'defuntos': 'Defuntos',
  'devocoes': 'Devoções',
  'diversos': 'Diversos',
  'doutrina': 'Doutrina',
  'espirito-santo': 'Espírito Santo',
  'eucaristica': 'Eucarística',
  'familia': 'Família',
  'homilia': 'Homilia',
  'mariano': 'Mariano',
  'missa-acao-de-gracas': 'Missa: Ação de Graças',
  'missa-preparacao': 'Missa: Preparação',
  'oracoes-comuns': 'Orações Comuns',
  'paixao-de-cristo': 'Paixão de Cristo',
  'penitencia': 'Penitência',
  'protecao': 'Proteção',
  'rosario': 'Rosário',
  'santissima-trindade': 'Santíssima Trindade',
  'sao-jose': 'São José',
  'trabalho': 'Trabalho',
};

const _saintLabels = <String, String>{
  'anjos': 'Anjos',
  'santo-ambrosio': 'Santo Ambrósio',
  'sao-boaventura': 'São Boaventura',
  'sao-francisco': 'São Francisco',
  'sao-jose': 'São José',
  'sao-josemaria': 'São Josemaría',
  'sao-paulo': 'São Paulo',
  'sao-tomas-de-aquino': 'São Tomás de Aquino',
  'virgem-maria': 'Virgem Maria',
};

List<HomePrayerGroup> buildThemePrayerGroups(List<PrayerCatalogEntry> entries) {
  return _buildPrayerGroups(
    entries: entries,
    type: HomePrayerGroupType.theme,
    extractKeys: (entry) => entry.themes,
    labels: _themeLabels,
    curatedOrder: kCuratedThemeOrder,
  );
}

List<HomePrayerGroup> buildSaintPrayerGroups(List<PrayerCatalogEntry> entries) {
  return _buildPrayerGroups(
    entries: entries,
    type: HomePrayerGroupType.saint,
    extractKeys: (entry) => entry.saints,
    labels: _saintLabels,
    curatedOrder: _curatedSaintOrder,
  );
}

List<HomePrayerGroup> buildHomeThematicGroups(
  List<PrayerCatalogEntry> entries,
) {
  final counts = <String, int>{};
  final saintKeys = <String>{};

  for (final entry in entries) {
    for (final key in entry.themes) {
      if (key.trim().isEmpty) continue;
      counts.update(key, (v) => v + 1, ifAbsent: () => 1);
    }

    for (final key in entry.saints) {
      if (key.trim().isEmpty) continue;
      saintKeys.add(key);
      counts.update(key, (v) => v + 1, ifAbsent: () => 1);
    }
  }

  final groups = kHomeThematicOrder
      .where((key) => counts.containsKey(key) || saintKeys.contains(key))
      .map(
        (key) => HomePrayerGroup(
          key: key,
          label:
              _homeThematicLabels[key] ??
              _themeLabels[key] ??
              _saintLabels[key] ??
              _humanizeKey(key),
          itemCount: counts[key] ?? 0,
          type: saintKeys.contains(key)
              ? HomePrayerGroupType.saint
              : HomePrayerGroupType.theme,
        ),
      )
      .toList(growable: false);

  return groups;
}

String prayerCountLabel(int count) {
  return count == 1 ? '1 oração' : '$count orações';
}

List<HomePrayerGroup> _buildPrayerGroups({
  required List<PrayerCatalogEntry> entries,
  required HomePrayerGroupType type,
  required List<String> Function(PrayerCatalogEntry entry) extractKeys,
  required Map<String, String> labels,
  required List<String> curatedOrder,
}) {
  final counts = <String, int>{};
  for (final entry in entries) {
    for (final key in extractKeys(entry)) {
      if (key.trim().isEmpty) {
        continue;
      }
      counts.update(key, (value) => value + 1, ifAbsent: () => 1);
    }
  }

  final groups = counts.entries
      .where((entry) => entry.value > 0)
      .map(
        (entry) => HomePrayerGroup(
          key: entry.key,
          label: labels[entry.key] ?? _humanizeKey(entry.key),
          itemCount: entry.value,
          type: type,
        ),
      )
      .toList(growable: false);

  int orderIndex(String key) {
    final index = curatedOrder.indexOf(key);
    return index >= 0 ? index : curatedOrder.length + 1;
  }

  final sorted = [...groups]
    ..sort((a, b) {
      final aOrder = orderIndex(a.key);
      final bOrder = orderIndex(b.key);
      if (aOrder != bOrder) {
        return aOrder.compareTo(bOrder);
      }
      return a.label.compareTo(b.label);
    });

  return sorted;
}

String _humanizeKey(String key) {
  return key
      .split('-')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
