import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/custom_phrases/application/use_cases/schedule_phrase_notifications_use_case.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/custom_phrase.dart';
import 'package:iacula_app/features/custom_phrases/domain/repositories/custom_phrase_repository.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_context.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/liturgical/domain/services/liturgical_season_service.dart';
import 'package:iacula_app/features/notifications/application/use_cases/rebuild_notifications_use_case.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_history_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import 'package:iacula_app/features/prayer_intentions/application/use_cases/schedule_intention_notifications_use_case.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:iacula_app/features/settings/presentation/settings_screen.dart';
import 'package:iacula_app/features/spiritual_data/domain/entities/spiritual_entry.dart';
import 'package:iacula_app/features/spiritual_data/domain/repositories/spiritual_entry_repository.dart';

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

final class _EmptySpiritualEntryRepository implements SpiritualEntryRepository {
  @override
  SpiritualModule get module => SpiritualModule.prayerIntention;
  @override
  Future<List<SpiritualEntry>> listLocal({bool includeDeleted = false}) async =>
      [];
  @override
  Future<List<SpiritualEntry>> listDirty() async => [];
  @override
  Future<void> saveLocal(SpiritualEntry entry) async {}
  @override
  Future<void> upsertMany(List<SpiritualEntry> entries) async {}
  @override
  Future<void> markDeleted(String id, {required DateTime deletedAt}) async {}
  @override
  Future<void> markClean(String id, {required DateTime syncedAt}) async {}
}

RebuildNotificationsUseCase _makeNoopRebuildUseCase() {
  final scheduler = InMemoryNotificationSchedulerRepository();
  return RebuildNotificationsUseCase(
    scheduler: scheduler,
    notificationHistoryRepository: InMemoryNotificationHistoryRepository(),
    lastDeliveredCardRepository: InMemoryLastDeliveredCardRepository(),
    schedulePhraseNotifications: SchedulePhraseNotificationsUseCase(
      scheduler,
      _EmptyCustomPhraseRepository(),
    ),
    scheduleIntentionNotifications: ScheduleIntentionNotificationsUseCase(
      scheduler,
      _EmptySpiritualEntryRepository(),
    ),
    quoteFetcher: ({required String language, required DateTime now}) async {
      return const Quote(
        text: 'x',
        dayOfWeek: 1,
        theme: 'Tema',
        season: LiturgicalSeason.ordinary,
      );
    },
  );
}

void main() {
  testWidgets('settings screen shows current mobile sections', (tester) async {
    final repo = _FakeSettingsRepository(Settings.defaults);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const CupertinoApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> expectVisible(String text) async {
      final finder = find.text(text);
      for (var i = 0; i < 12 && finder.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -250));
        await tester.pumpAndSettle();
      }
      expect(finder, findsOneWidget);
    }

    expect(find.text('Notificações'), findsOneWidget);
    expect(find.text('Aparência'), findsOneWidget);
    expect(find.text('Notificações ativas'), findsOneWidget);
    expect(find.text('Frequência das jaculatórias'), findsOneWidget);
    expect(find.text('Horário silencioso'), findsOneWidget);
    expect(find.text('Tema'), findsOneWidget);
    expect(find.text('Tamanho da fonte'), findsOneWidget);
    await expectVisible('Personalização');
    await expectVisible('Jaculatórias');
    await expectVisible('Mostrar só minhas jaculatórias');
    await expectVisible('Salvar');
    // The Pontos de Caminho/Sulco/Forja toggle was intentionally hidden from
    // the settings UI (e63b737).
    expect(find.text('Pontos de Caminho/Sulco/Forja'), findsNothing);
  });

  testWidgets('settings no longer shows deprecated sync and interval inputs', (
    tester,
  ) async {
    final repo = _FakeSettingsRepository(Settings.defaults);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
        child: const CupertinoApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Intervalo das jaculatórias (minutos)'), findsNothing);
    expect(find.text('Sincronização entre dispositivos'), findsNothing);
    expect(find.text('Continuar com Google'), findsNothing);
    expect(find.text('Sincronizar agora'), findsNothing);
  });

  // The Pontos de Caminho/Sulco/Forja switch was retired (e63b737). People who
  // already had the feed on keep the switch (optionVisible, set by the v19 DB
  // migration) so they can turn it off; everyone else never sees it.
  final escrivaCases = [
    (
      description: 'new user: switch hidden, feed stays off',
      isOptionVisible: false,
      isFeedEnabled: false,
      shouldTapSwitch: false,
      expectedFeedEnabled: false,
    ),
    (
      description: 'grandfathered user keeps the feed on',
      isOptionVisible: true,
      isFeedEnabled: true,
      shouldTapSwitch: false,
      expectedFeedEnabled: true,
    ),
    (
      description: 'grandfathered user turns the feed off',
      isOptionVisible: true,
      isFeedEnabled: true,
      shouldTapSwitch: true,
      expectedFeedEnabled: false,
    ),
    (
      description: 'hidden switch never resets a stored preference',
      isOptionVisible: false,
      isFeedEnabled: true,
      shouldTapSwitch: false,
      expectedFeedEnabled: true,
    ),
  ];
  for (final escrivaCase in escrivaCases) {
    testWidgets('Escrivá feed switch: ${escrivaCase.description}', (
      tester,
    ) async {
      final repo = _FakeSettingsRepository(
        Settings.defaults.copyWith(
          escrivaPointsFeedOptionVisible: escrivaCase.isOptionVisible,
          escrivaPointsFeedEnabled: escrivaCase.isFeedEnabled,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(repo),
            liturgicalSeasonServiceProvider.overrideWithValue(
              _FakeLiturgicalSeasonService(),
            ),
            rebuildNotificationsUseCaseProvider.overrideWith((ref) {
              return _makeNoopRebuildUseCase();
            }),
          ],
          child: const CupertinoApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final escrivaTitle = find.text('Pontos de Caminho/Sulco/Forja');
      final scrollable = find.byType(CustomScrollView);
      final saveButton = find.text('Salvar');
      for (var i = 0; i < 12 && saveButton.evaluate().isEmpty; i++) {
        await tester.drag(scrollable, const Offset(0, -250));
        await tester.pumpAndSettle();
      }
      expect(
        escrivaTitle,
        escrivaCase.isOptionVisible ? findsOneWidget : findsNothing,
      );

      if (escrivaCase.shouldTapSwitch) {
        final escrivaSwitch = find.descendant(
          of: find.ancestor(of: escrivaTitle, matching: find.byType(Row)).first,
          matching: find.byType(CupertinoSwitch),
        );
        await tester.ensureVisible(escrivaSwitch);
        await tester.tap(escrivaSwitch);
        await tester.pumpAndSettle();
      }

      expect(saveButton, findsOneWidget);
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(
        repo._value.escrivaPointsFeedEnabled,
        escrivaCase.expectedFeedEnabled,
      );
      expect(
        repo._value.escrivaPointsFeedOptionVisible,
        escrivaCase.isOptionVisible,
      );
    });
  }
}
