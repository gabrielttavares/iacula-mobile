import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Slider;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/core/presentation/shell_screen.dart';
import 'package:iacula_app/features/home/presentation/home_screen.dart'
    show homeNowProvider;
import 'package:iacula_app/features/custom_phrases/application/use_cases/schedule_phrase_notifications_use_case.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/custom_phrase.dart';
import 'package:iacula_app/features/custom_phrases/domain/repositories/custom_phrase_repository.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_context.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/liturgical/domain/services/liturgical_season_service.dart';
import 'package:iacula_app/features/notifications/application/use_cases/rebuild_notifications_use_case.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_liturgy_reminders_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/last_delivered_card.dart';
import 'package:iacula_app/features/notifications/domain/repositories/last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_history_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/settings/domain/repositories/settings_repository.dart';

/// Mesmo padrão do [_heroSettingsProvider] em `home_screen.dart`: cache do
/// Riverpod só atualiza quando `getSettingsUseCaseProvider` é invalidado.
final _testHeroSettingsProvider = FutureProvider<Settings>((ref) async {
  return ref.watch(getSettingsUseCaseProvider).call();
});

final class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._value);

  Settings _value;

  @override
  Future<Settings> load() async => _value;

  @override
  Future<void> save(Settings settings) async {
    _value = settings;
  }
}

final class _FakeLastDeliveredCardRepository
    implements LastDeliveredCardRepository {
  _FakeLastDeliveredCardRepository(this._value);

  LastDeliveredCard? _value;

  @override
  Future<LastDeliveredCard?> load() async => _value;

  @override
  Future<void> save(LastDeliveredCard card) async {
    _value = card;
  }
}

final class _EmptyCustomPhraseRepository implements CustomPhraseRepository {
  @override
  Future<void> delete(String id) async {}

  @override
  Future<CustomPhrase?> getById(String id) async => null;

  @override
  Future<List<CustomPhrase>> listAll() async => [];

  @override
  Future<void> save(CustomPhrase phrase) async {}

  @override
  Stream<List<CustomPhrase>> watchAll() => const Stream.empty();
}

final class _FakeLiturgicalSeasonService implements LiturgicalSeasonService {
  @override
  Future<LiturgicalContext> getCurrentContext({DateTime? date}) async {
    return LiturgicalContext.ordinaryFallback;
  }

  @override
  Future<LiturgicalSeason> getCurrentSeason({DateTime? date}) async {
    return LiturgicalSeason.ordinary;
  }
}

RebuildNotificationsUseCase _noopRebuildUseCase() {
  final scheduler = InMemoryNotificationSchedulerRepository();
  return RebuildNotificationsUseCase(
    scheduler: scheduler,
    notificationHistoryRepository: InMemoryNotificationHistoryRepository(),
    lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    scheduleLiturgyReminders: ScheduleLiturgyRemindersUseCase(scheduler),
    schedulePhraseNotifications: SchedulePhraseNotificationsUseCase(
      scheduler,
      _EmptyCustomPhraseRepository(),
    ),
    quoteFetcher: ({required String language, required DateTime now}) async {
      return const Quote(
        text: 'x',
        dayOfWeek: 1,
        theme: 'Tema',
        season: LiturgicalSeason.ordinary,
      );
    },
    batchFetcherForSettings: (_) => null,
  );
}

void main() {
  testWidgets(
    'salvar novo intervalo em Configurações atualiza o mesmo cache de settings usado pelo hero',
    (tester) async {
      final repo = _FakeSettingsRepository(Settings.defaults);
      final fixedNow = DateTime(2026, 2, 21, 11);

      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
          lastDeliveredCardRepositoryProvider.overrideWithValue(
            _FakeLastDeliveredCardRepository(
              LastDeliveredCard(
                quoteText: 'Permanecei em mim.',
                theme: 'Conversao',
                season: 'ordinary',
                deliveredAt: fixedNow,
              ),
            ),
          ),
          rebuildNotificationsUseCaseProvider.overrideWith((ref) {
            return _noopRebuildUseCase();
          }),
          homeNowProvider.overrideWith((ref) => fixedNow),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const CupertinoApp(
            localizationsDelegates: [
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [Locale('pt', 'BR'), Locale('en')],
            home: ShellScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        (await container.read(
          _testHeroSettingsProvider.future,
        )).intervalMinutes,
        15,
      );

      const initialSubtitle =
          'Jaculatórias a cada 15min \u00B7 Angelus ao meio-dia';
      expect(find.text(initialSubtitle), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(CupertinoTabBar),
          matching: find.text('Notificações'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Configurar intervalo'));
      await tester.pumpAndSettle();

      final scrollable = find.byType(CustomScrollView);
      for (var i = 0; i < 14; i++) {
        if (find.byType(Slider).evaluate().isNotEmpty) {
          break;
        }
        await tester.drag(scrollable, const Offset(0, -220));
        await tester.pumpAndSettle();
      }

      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);
      await tester.drag(slider, const Offset(800, 0));
      await tester.pumpAndSettle();

      final saveButton = find.text('Salvar');
      await tester.scrollUntilVisible(saveButton, 300);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(repo._value.intervalMinutes, greaterThan(15));

      final fromRepo = repo._value.intervalMinutes;
      final fromProvider = (await container.read(
        _testHeroSettingsProvider.future,
      )).intervalMinutes;
      expect(
        fromProvider,
        fromRepo,
        reason:
            'após Salvar, o FutureProvider do hero deve refletir o repositório '
            '(getSettingsUseCaseProvider precisa ser invalidado). '
            'O subtítulo sob o hero em `home_screen.dart` lê o mesmo cache.',
      );
    },
  );
}
