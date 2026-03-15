import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/leituras/presentation/pages/leituras_home_page.dart';
import 'package:iacula_app/features/meditation/domain/entities/meditation_item.dart';
import 'package:iacula_app/features/meditation/domain/repositories/meditation_catalog_repository.dart';
import 'package:iacula_app/features/meditation/presentation/meditation_reader_screen.dart';
import 'package:iacula_app/features/meditation/presentation/meditation_screen.dart';
import 'package:iacula_app/features/premium/domain/entities/premium_status.dart';

final class _FakeMeditationCatalogRepository
    implements MeditationCatalogRepository {
  @override
  Future<MeditationItem?> getById(String id) async =>
      (await listAll()).firstWhere((item) => item.id == id);

  @override
  Future<List<MeditationItem>> listAll() async {
    return [
      MeditationItem.fromJson({
        'id': 'med-1',
        'type': 'text',
        'title': 'Meditação do dia',
        'summary': 'Resumo',
        'categoryTags': ['espiritual'],
        'sourceName': 'Fonte',
        'availability': {'kind': 'evergreen'},
        'textContent': {'body': 'Corpo', 'format': 'plain', 'language': 'pt'},
        'provenance': {'providerId': 'test', 'providerType': 'channel'},
      }),
      MeditationItem.fromJson({
        'id': 'med-2',
        'type': 'text',
        'title': 'Evangelho',
        'summary': 'Outro resumo',
        'categoryTags': ['evangelho'],
        'sourceName': 'Fonte',
        'availability': {'kind': 'evergreen'},
        'textContent': {
          'body': 'Outro corpo',
          'format': 'plain',
          'language': 'pt',
        },
        'provenance': {'providerId': 'test', 'providerType': 'channel'},
      }),
    ];
  }

  @override
  Future<List<MeditationItem>> listByCategory(String category) async => [];

  @override
  Future<List<MeditationItem>> listByType(MeditationType type) async => [];
}

Widget _buildMeditationTestApp({required PremiumStatus premiumStatus}) {
  return ProviderScope(
    overrides: [
      premiumStatusProvider.overrideWith((ref) {
        return Stream<PremiumStatus>.value(premiumStatus);
      }),
      meditationCatalogRepositoryProvider.overrideWithValue(
        _FakeMeditationCatalogRepository(),
      ),
    ],
    child: const CupertinoApp(home: MeditationScreen()),
  );
}

void main() {
  testWidgets('meditation screen no longer shows Reflexões entry points', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildMeditationTestApp(
        premiumStatus: const PremiumStatus(isPremium: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reflexões'), findsNothing);
    expect(find.text('Reflexões guiadas'), findsNothing);
    expect(find.text('Pelo que sou grato a Deus hoje?'), findsNothing);
    expect(
      find.text('Escolha um caminho mais concreto para rezar agora.'),
      findsOneWidget,
    );
    expect(find.text('Meditação do dia'), findsOneWidget);
    expect(find.text('Evangelho'), findsOneWidget);
  });

  testWidgets('tapping a meditation card opens the reader directly', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildMeditationTestApp(
        premiumStatus: const PremiumStatus(isPremium: true),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Meditação do dia'));
    await tester.pumpAndSettle();

    expect(find.byType(MeditationReaderScreen), findsOneWidget);
    expect(find.text('Corpo'), findsOneWidget);
    expect(find.text('A-'), findsOneWidget);
    expect(find.text('A+'), findsOneWidget);
  });

  testWidgets('meditation screen shows a Leituras card that opens Leituras', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildMeditationTestApp(
        premiumStatus: const PremiumStatus(isPremium: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Leituras'), findsAtLeastNWidgets(1));
    expect(find.text('Aprofunde a oração com autores e santos.'), findsOneWidget);

    await tester.tap(find.text('Leituras').first);
    await tester.pumpAndSettle();

    expect(find.byType(LeiturasHomePage), findsOneWidget);
  });

  testWidgets('free user can browse Meditação and gets premium gate on open', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildMeditationTestApp(premiumStatus: PremiumStatus.free),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MeditationScreen), findsOneWidget);
    expect(find.text('Meditação do dia'), findsOneWidget);

    await tester.tap(find.text('Meditação do dia'));
    await tester.pumpAndSettle();

    expect(find.text('Continue com o Premium'), findsAtLeastNWidgets(1));
    expect(find.text('Conhecer o Premium'), findsAtLeastNWidgets(1));
  });
}
