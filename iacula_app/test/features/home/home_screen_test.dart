import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/home/presentation/home_screen.dart';
import 'package:iacula_app/features/notifications/domain/entities/last_delivered_card.dart';
import 'package:iacula_app/features/notifications/domain/repositories/last_delivered_card_repository.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/settings/domain/repositories/settings_repository.dart';

final class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.value);

  Settings value;

  @override
  Future<Settings> load() async => value;

  @override
  Future<void> save(Settings settings) async {
    value = settings;
  }
}

final class _FakeLastDeliveredCardRepository
    implements LastDeliveredCardRepository {
  _FakeLastDeliveredCardRepository(this.value);

  LastDeliveredCard? value;

  @override
  Future<LastDeliveredCard?> load() async => value;

  @override
  Future<void> save(LastDeliveredCard card) async {
    value = card;
  }
}

Widget _buildApp() {
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(
        _FakeSettingsRepository(Settings.defaults),
      ),
      lastDeliveredCardRepositoryProvider.overrideWithValue(
        _FakeLastDeliveredCardRepository(
          LastDeliveredCard(
            quoteText: 'Permanecei em mim.',
            theme: 'Conversao',
            season: 'lent',
            deliveredAt: DateTime(2026, 2, 21, 11),
          ),
        ),
      ),
    ],
    child: const CupertinoApp(home: HomeScreen()),
  );
}

void main() {
  testWidgets('home keeps the streamlined layout', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    for (
      var i = 0;
      i < 5 && find.byKey(const Key('home_custom_phrases_card')).evaluate().isEmpty;
      i++
    ) {
      await tester.drag(
        find.byKey(const Key('home_shortcuts_rail')),
        const Offset(-120, 0),
      );
      await tester.pumpAndSettle();
    }

    expect(find.byKey(const Key('home_hero_card')), findsOneWidget);
    expect(find.byKey(const Key('home_shortcuts_rail')), findsOneWidget);
    expect(find.byKey(const Key('home_action_oracoes')), findsOneWidget);
    expect(find.byKey(const Key('home_action_intencoes')), findsOneWidget);
    expect(find.byKey(const Key('home_custom_phrases_card')), findsOneWidget);
    expect(find.byKey(const Key('home_feature_biblia_card')), findsOneWidget);
    expect(find.byKey(const Key('home_feature_confissao_card')), findsOneWidget);
  });

  testWidgets('home removes deleted shortcuts and sections', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Ação de Graças'), findsNothing);
    expect(find.byKey(const Key('home_action_liturgia')), findsNothing);
    expect(find.byKey(const Key('home_action_exame')), findsNothing);
    expect(find.byKey(const Key('home_feature_rosario_card')), findsNothing);
    expect(find.text('Liturgia diária'), findsNothing);
    expect(find.text('Rosário'), findsNothing);
  });

  testWidgets('home keeps bible card above confession card', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    final confessionCard = find.byKey(const Key('home_feature_confissao_card'));
    await tester.dragUntilVisible(
      confessionCard,
      find.byType(CustomScrollView),
      const Offset(0, -220),
    );

    final bibleY = tester
        .getTopLeft(find.byKey(const Key('home_feature_biblia_card')))
        .dy;
    final confessionY = tester.getTopLeft(confessionCard).dy;

    expect(bibleY, lessThan(confessionY));
  });
}
