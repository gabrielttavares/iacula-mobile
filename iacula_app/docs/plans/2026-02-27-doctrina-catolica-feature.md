# Doutrina Católica Feature Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a new "Doutrina Católica" section (replacing the Novenas button location) with Catholic doctrine content like Mandments, Virtues, Works of Mercy, etc.

**Architecture:** Create a new feature similar to prayers, with entities, repository, use cases, and presentation screens

**Tech Stack:** Flutter, Riverpod, JSON assets

**Source PDF:** `/Users/gabrielttav/Downloads/oracoes.pdf` (Fórmulas de Doutrina Católica section)

---

## Task 1: Create Domain Layer

### Task 1a: Create DoctrineEntry Entity

**Files:**
- Create: `iacula_app/lib/features/doctrina/domain/entities/doctrine_entry.dart`

**Step 1: Write the entity**

```dart
final class DoctrineEntry {
  const DoctrineEntry({
    required this.slug,
    required this.title,
    required this.content,
    required this.category,
  });

  final String slug;
  final String title;
  final String content;
  final String category;
}
```

**Step 2: Run tests (if available)**

Run: `flutter test test/features/doctrina/ --reporter compact 2>/dev/null || echo "No tests yet"`

**Step 3: Commit**

```bash
git add iacula_app/lib/features/doctrina/domain/entities/doctrine_entry.dart
git commit -m "feat(doctrina): add DoctrineEntry entity"
```

### Task 1b: Create DoctrineRepository Interface

**Files:**
- Create: `iacula_app/lib/features/doctrina/domain/repositories/doctrine_repository.dart`

**Step 1: Write the repository interface**

```dart
import '../entities/doctrine_entry.dart';

abstract class DoctrineRepository {
  Future<List<DoctrineEntry>> listAll({required String language});
  Future<DoctrineEntry?> getBySlug({required String slug, required String language});
}
```

**Step 2: Commit**

```bash
git add iacula_app/lib/features/doctrina/domain/repositories/doctrine_repository.dart
git commit -m "feat(doctrina): add DoctrineRepository interface"
```

---

## Task 2: Create Infrastructure Layer

### Task 2a: Create AssetDoctrineRepository

**Files:**
- Create: `iacula_app/lib/features/doctrina/infrastructure/repositories/asset_doctrine_repository.dart`

**Step 1: Write the repository implementation**

```dart
import 'dart:convert';
import 'package:flutter/services.dart';

import '../../domain/entities/doctrine_entry.dart';
import '../../domain/repositories/doctrine_repository.dart';

class AssetDoctrineRepository implements DoctrineRepository {
  const AssetDoctrineRepository();

  @override
  Future<List<DoctrineEntry>> listAll({required String language}) async {
    final jsonString = await rootBundle.loadString(
      'assets/seed/doctrina/$language/doctrina_catalog.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => DoctrineEntry(
      slug: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
    )).toList();
  }

  @override
  Future<DoctrineEntry?> getBySlug({
    required String slug,
    required String language,
  }) async {
    final entries = await listAll(language: language);
    try {
      return entries.firstWhere((e) => e.slug == slug);
    } catch (_) {
      return null;
    }
  }
}
```

**Step 2: Commit**

```bash
git add iacula_app/lib/features/doctrina/infrastructure/repositories/asset_doctrine_repository.dart
git commit -m "feat(doctrina): add AssetDoctrineRepository implementation"
```

---

## Task 3: Create Application Layer (Use Cases)

### Task 3a: Create GetDoctrineCatalogUseCase

**Files:**
- Create: `iacula_app/lib/features/doctrina/application/use_cases/get_doctrine_catalog_use_case.dart`

**Step 1: Write the use case**

```dart
import '../../domain/entities/doctrine_entry.dart';
import '../../domain/repositories/doctrine_repository.dart';

class GetDoctrineCatalogUseCase {
  const GetDoctrineCatalogUseCase(this._repository);

  final DoctrineRepository _repository;

  Future<List<DoctrineEntry>> call({required String language}) {
    return _repository.listAll(language: language);
  }
}
```

**Step 2: Commit**

```bash
git add iacula_app/lib/features/doctrina/application/use_cases/get_doctrine_catalog_use_case.dart
git commit -m "feat(doctrina): add GetDoctrineCatalogUseCase"
```

---

## Task 4: Create Data Assets

### Task 4a: Create doctrina_catalog.json

**Files:**
- Create: `iacula_app/assets/seed/doctrina/pt-br/doctrina_catalog.json`

**Step 1: Write the catalog**

```json
[
  {
    "id": "mandamentos-caridade",
    "title": "Os Mandamentos da Caridade",
    "content": "1. Amarás a Deus de todo o teu coração, de toda a tua alma e de toda a tua mente.\n2. Amarás ao teu próximo como a ti mesmo.\n\nEm que consistem estes dois mandamentos? Na Lei inteira e nos Profetas.",
    "category": "doutrina-fundamental"
  },
  {
    "id": "regra-ouro",
    "title": "A Regra de Ouro",
    "content": "Tudo quanto vós quereis que os homens vos façam, fazei-lho também a eles. (Mt 7,12)",
    "category": "doutrina-fundamental"
  },
  {
    "id": "bem-aventurancas",
    "title": "As Bem-aventuranças",
    "content": "1. Bem-aventurados os pobres em espírito, porque deles é o reino dos céus.\n2. Bem-aventurados os mansos, porque possuirão a terra.\n3. Bem-aventurados os que choram, porque serão consolados.\n4. Bem-aventurados os que têm fome e sede de justiça, porque serão saciados.\n5. Bem-aventurados os misericordiosos, porque alcançarão misericórdia.\n6. Bem-aventurados os puros de coração, porque verão a Deus.\n7. Bem-aventurados os pacificadores, porque serão chamados filhos de Deus.\n8. Bem-aventurados os perseguidos por causa da justiça, porque deles é o reino dos céus.\n\n(Mt 5, 3-12)",
    "category": "doutrina-fundamental"
  },
  {
    "id": "virtudes-teologais",
    "title": "As Virtudes Teologais",
    "content": "1. Fé - A virtude teologal pela qual acreditamos em Deus e em tudo o que Ele nos revelou e propõe à nossa crença.\n2. Esperança - A virtude teologal pela qual desejamos e esperamos com firme confiança a vida eterna e as graças para alcançá-la.\n3. Caridade - A virtude teologal pela qual amamos a Deus sobre todas as coisas e ao próximo como a nós mesmos por amor de Deus.",
    "category": "virtudes"
  },
  {
    "id": "virtudes-cardeais",
    "title": "As Virtudes Cardeais",
    "content": "1. Prudência - A virtude que dispõe a razão para discernir, em todas as circunstâncias, o nosso bem moral e a regular os nossos atos.\n2. Justiça - A virtude moral que consiste na firme e constante vontade de dar a Deus e ao próximo o que lhe é devido.\n3. Fortaleza - A virtude que assegura a firmeza nas dificuldades e a constância na perseguição.\n4. Temperança - A virtue que modera o appetito dos prazeres sensíveis e nos dá o equilíbrio no uso dos bens created.",
    "category": "virtudes"
  },
  {
    "id": "dons-espirito-santo",
    "title": "Os Dons do Espírito Santo",
    "content": "1. Sabedoria - Dá-nos o gosto das coisas divinas e o discernimento dos espíritos.\n2. Entendimento - Ajuda-nos a compreender as verdades da fé.\n3. Conselho - Guia-nos nas decisões da vida.\n4. Fortidão - Dá-nos força para superar as dificuldades.\n5. Ciência - Ilumina-nos para conhecer as criaturas em relação a Deus.\n6. Piedade - Infunde-nos o amor de Deus como Pai.\n7. Temor de Deus - Inspira-nos a fugir do pecado por amor a Deus.",
    "category": "espirito-santo"
  },
  {
    "id": "frutos-espirito-santo",
    "title": "Os Frutos do Espírito Santo",
    "content": "O fruto do Espírito é: caridade, alegria, paz, paciência, longanimidade, bondade, mansidão, fidelidade, modéstia, castidade, continência.",
    "category": "espirito-santo"
  },
  {
    "id": "mandamentos-igreja",
    "title": "Os Mandamentos da Igreja",
    "content": "1. Ouvir a Missa inteira todos os domingos e dias de preceito.\n2. Confessar-se ao menos uma vez por ano.\n3. Comungar ao menos uma vez por ano, pelo Natal.\n4. Observar os dias de jejum e abstinência.\n5. Pagar o dízimo à Igreja.",
    "category": "mandamentos"
  },
  {
    "id": "obras-misericordia-corporal",
    "title": "As Obras de Misericórdia Corporal",
    "content": "1. Dar de comer a quem tem fome.\n2. Dar de beber a quem tem sede.\n3. Vestir os nus.\n4. Dar pousada aos peregrinos.\n5. Visitar os enfermos.\n6. Visitar os encarcerados.\n7. Enterrar os mortos.",
    "category": "misericordia"
  },
  {
    "id": "obras-misericordia-espiritual",
    "title": "As Obras de Misericórdia Espiritual",
    "content": "1. Dar bons conselhos.\n2. Ensinar os ignorantes.\n3. Corrigir os pecadores.\n4. Consolar os aflitos.\n5. Perdoar as ofensas.\n6. Sofrer com paciência as fraquezas do próximo.\n7. Rezar a Deus por vivos e mortos.",
    "category": "misericordia"
  },
  {
    "id": "vicios-capitais",
    "title": "Os Vícios Capitais",
    "content": "1. Soberba - Amor excessivo de si mesmo, desprezo de Deus e do próximo.\n2. Avareza - Amor excessivo das riquezas.\n3. Luxúria - Desejo desordenado dos prazeres carnais.\n4. Inveja - Tristeza do bem alheio e desejo de tê-lo.\n5. Gula - Excesso no comer e no beber.\n6. Ira - Desejo de vingança.\n7. Preguiça - Tedio das coisas espirituais e aversão ao trabalho.",
    "category": "vicios"
  },
  {
    "id": "novissimos",
    "title": "Os Novíssimos",
    "content": "1. Morte - Separação da alma e do corpo.\n2. Juízo Particular - Julgamento de Deus logo após a morte.\n3. Purgatório - Estado de purificação para as almas que morrem em graça mas com dívida temporal.\n4. Inferno - Estado de danação eterna para os que morrem em pecado mortal.\n5. Juízo Universal - Julgamento de todos os homens no fim do mundo.\n6. Céu - Glória eterna com Deus.",
    "category": "escatologia"
  }
]
```

**Step 2: Verify JSON is valid**

Run: `python3 -c "import json; json.load(open('iacula_app/assets/seed/doctrina/pt-br/doctrina_catalog.json'))" && echo "Valid JSON"`

**Step 3: Commit**

```bash
git add iacula_app/assets/seed/doctrina/pt-br/doctrina_catalog.json
git commit -m "feat(doctrina): add Catholic doctrine catalog"
```

---

## Task 5: Create Presentation Layer

### Task 5a: Create DoctrineCollectionsScreen

**Files:**
- Create: `iacula_app/lib/features/doctrina/presentation/doctrine_collections_screen.dart`

**Step 1: Write the screen**

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_large_title.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../prayers/domain/entities/prayer_catalog_entry.dart';
import 'doctrine_detail_screen.dart';

final _catalogProvider = FutureProvider<List<DoctrineEntry>>((ref) async {
  final settings = await ref.watch(getSettingsUseCaseProvider).call();
  return ref.watch(getDoctrineCatalogUseCaseProvider).listAll(language: settings.language);
});

class DoctrineCollectionsScreen extends ConsumerWidget {
  const DoctrineCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(_catalogProvider);

    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(IaculaSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IaculaLargeTitle('Doutrina Católica'),
              const SizedBox(height: IaculaSpacing.lg),
              Expanded(
                child: catalogAsync.when(
                  data: (entries) => _DoctrineList(entries: entries),
                  loading: () => const Center(child: CupertinoActivityIndicator()),
                  error: (e, _) => Center(child: Text('Erro: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctrineList extends StatelessWidget {
  const _DoctrineList({required this.entries});

  final List<DoctrineEntry> entries;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<DoctrineEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.category, () => []).add(entry);
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: grouped.length,
      separatorBuilder: (_, __) => const SizedBox(height: IaculaSpacing.lg),
      itemBuilder: (context, index) {
        final category = grouped.keys.elementAt(index);
        final categoryEntries = grouped[category]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: IaculaSpacing.xs, bottom: IaculaSpacing.sm),
              child: Text(
                _categoryTitle(category),
                style: IaculaText.sectionHeader,
              ),
            ),
            ...categoryEntries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
              child: _DoctrineCard(entry: entry),
            )),
          ],
        );
      },
    );
  }

  String _categoryTitle(String category) {
    switch (category) {
      case 'doutrina-fundamental':
        return 'Doutrina Fundamental';
      case 'virtudes':
        return 'Virtudes';
      case 'espirito-santo':
        return 'Espírito Santo';
      case 'mandamentos':
        return 'Mandamentos';
      case 'misericordia':
        return 'Misericórdia';
      case 'vicios':
        return 'Vícios';
      case 'escatologia':
        return 'Últimas Coisas';
      default:
        return category;
    }
  }
}

class _DoctrineCard extends StatelessWidget {
  const _DoctrineCard({required this.entry});

  final DoctrineEntry entry;

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => DoctrineDetailScreen(entry: entry),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(IaculaSpacing.md),
        child: Row(
          children: [
            const Icon(CupertinoIcons.book, color: IaculaColors.primaryButton),
            const SizedBox(width: IaculaSpacing.md),
            Expanded(
              child: Text(entry.title, style: IaculaText.cardTitle),
            ),
            const Icon(CupertinoIcons.chevron_right, color: IaculaColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add iacula_app/lib/features/doctrina/presentation/doctrine_collections_screen.dart
git commit -m "feat(doctrina): add DoctrineCollectionsScreen"
```

### Task 5b: Create DoctrineDetailScreen

**Files:**
- Create: `iacula_app/lib/features/doctrina/presentation/doctrine_detail_screen.dart`

**Step 1: Write the screen**

```dart
import 'package:flutter/cupertino.dart';

import '../../domain/entities/doctrine_entry.dart';
import '../../../core/theme/cupertino_tokens.dart';

class DoctrineDetailScreen extends StatelessWidget {
  const DoctrineDetailScreen({super.key, required this.entry});

  final DoctrineEntry entry;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: IaculaColors.background,
      navigationBar: CupertinoNavigationBar(
        middle: Text(entry.title),
        backgroundColor: IaculaColors.background,
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(IaculaSpacing.md),
          child: Text(
            entry.content,
            style: IaculaText.prayerText,
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add iacula_app/lib/features/doctrina/presentation/doctrine_detail_screen.dart
git commit -m "feat(doctrina): add DoctrineDetailScreen"
```

---

## Task 6: Register Providers

### Task 6a: Add providers to main providers file

**Files:**
- Modify: `iacula_app/lib/core/di/providers.dart`

**Step 1: Add doctrine providers**

Add after prayer providers:

```dart
// Doctrine providers
final doctrineRepositoryProvider = Provider<DoctrineRepository>((ref) {
  return const AssetDoctrineRepository();
});

final getDoctrineCatalogUseCaseProvider = Provider<GetDoctrineCatalogUseCase>((ref) {
  return GetDoctrineCatalogUseCase(ref.watch(doctrineRepositoryProvider));
});
```

**Step 2: Add imports**

```dart
import '../../features/doctrina/domain/repositories/doctrine_repository.dart';
import '../../features/doctrina/infrastructure/repositories/asset_doctrine_repository.dart';
import '../../features/doctrina/application/use_cases/get_doctrine_catalog_use_case.dart';
```

**Step 3: Commit**

```bash
git add iacula_app/lib/core/di/providers.dart
git commit -m "feat(doctrina): register doctrine providers"
```

---

## Task 7: Test the Feature

### Task 7a: Write basic test

**Files:**
- Create: `iacula_app/test/features/doctrina/doctrine_entry_test.dart`

**Step 1: Write test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/doctrina/domain/entities/doctrine_entry.dart';

void main() {
  group('DoctrineEntry', () {
    test('creates correctly', () {
      const entry = DoctrineEntry(
        slug: 'test-slug',
        title: 'Test Title',
        content: 'Test content',
        category: 'test-category',
      );

      expect(entry.slug, 'test-slug');
      expect(entry.title, 'Test Title');
      expect(entry.content, 'Test content');
      expect(entry.category, 'test-category');
    });
  });
}
```

**Step 2: Run test**

Run: `flutter test test/features/doctrina/doctrine_entry_test.dart`

Expected: PASS

**Step 3: Commit**

```bash
git add test/features/doctrina/doctrine_entry_test.dart
git commit -m "test(doctrina): add DoctrineEntry test"
```

---

## Summary

**After completing all tasks:**
- New `doctrina` feature with full Clean Architecture
- Domain: Entity + Repository interface
- Infrastructure: JSON asset repository
- Application: Use cases
- Presentation: Collections + Detail screens
- Providers registered
- Basic tests passing

**Commands to verify:**
```bash
git log --oneline -15
```

Expected output should show all commits for the doctrina feature.
