import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_catalog_entry.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_collection.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_detail.dart';
import 'package:iacula_app/features/prayers/domain/repositories/prayer_content_repository.dart';
import 'package:iacula_app/features/prayers/presentation/prayer_catalog_detail_screen.dart';

class _FakePrayerContentRepository implements PrayerContentRepository {
  @override
  Future<PrayerCollection> loadPrayers({required String language}) async {
    throw UnimplementedError();
  }

  @override
  Future<String?> getAngelusImagePath() async => null;

  @override
  Future<String?> getReginaCaeliImagePath() async => null;

  @override
  Future<PrayerDetail> loadPrayerDetail({required String slug}) async {
    return const PrayerDetail(
      slug: 'pai-nosso',
      defaultLanguage: 'pt-br',
      titlesByLanguage: {'pt-br': 'Pai Nosso', 'la': 'Pater Noster'},
      blocksByLanguage: {
        'pt-br': ['Pai nosso que estais nos céus.'],
        'la': ['Pater noster, qui es in caelis.'],
      },
    );
  }
}

void main() {
  const entry = PrayerCatalogEntry(
    slug: 'pai-nosso',
    title: 'Pai Nosso',
    content: 'Pai nosso que estais nos céus.',
    themes: ['oracoes-comuns'],
    saints: [],
    sectionId: 'oracoes-comuns',
    sectionTitle: 'Orações Comuns',
    availableLanguages: ['pt-br', 'la'],
  );

  testWidgets('shows segmented PT/LAT control and toggles content', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prayerContentRepositoryProvider.overrideWithValue(
            _FakePrayerContentRepository(),
          ),
        ],
        child: const CupertinoApp(
          home: PrayerCatalogDetailScreen(entry: entry),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pai nosso que estais nos céus.'), findsOneWidget);
    expect(find.text('Pater noster, qui es in caelis.'), findsNothing);

    await tester.tap(find.text('LAT'));
    await tester.pumpAndSettle();

    expect(find.text('Pater noster, qui es in caelis.'), findsOneWidget);
  });
}
