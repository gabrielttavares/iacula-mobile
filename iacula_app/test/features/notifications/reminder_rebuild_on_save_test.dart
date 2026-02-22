import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_context.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/liturgical/domain/services/liturgical_season_service.dart';
import 'package:iacula_app/features/notifications/domain/entities/last_delivered_card.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_action_event.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/domain/repositories/last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/domain/repositories/notification_scheduler_repository.dart';
import 'package:iacula_app/features/quotes/domain/entities/day_quotes.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote_indices.dart';
import 'package:iacula_app/features/quotes/domain/repositories/quote_content_repository.dart';
import 'package:iacula_app/features/quotes/domain/repositories/quote_indices_repository.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';
import 'package:iacula_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:iacula_app/features/settings/presentation/settings_screen.dart';

final class _FakeSettingsRepository implements SettingsRepository {
  Settings _value;

  _FakeSettingsRepository(this._value);

  @override
  Future<Settings> load() async => _value;

  @override
  Future<void> save(Settings settings) async {
    _value = settings;
  }
}

final class _FakeNotificationSchedulerRepository implements NotificationSchedulerRepository {
  final _controller = StreamController<NotificationActionEvent>.broadcast();

  int cancelAllCalls = 0;
  final List<ReminderEvent> scheduled = [];

  @override
  Stream<NotificationActionEvent> get actions => _controller.stream;

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    scheduled.clear();
  }

  @override
  Future<void> cancelByType(ReminderEventType type) async {
    scheduled.removeWhere((event) => event.type == type);
  }

  @override
  Future<void> schedule(ReminderEvent event) async {
    scheduled.removeWhere((e) => e.type == event.type);
    scheduled.add(event);
  }
}

final class _FakeQuoteContentRepository implements QuoteContentRepository {
  @override
  Future<String?> getFeastImagePath(String feastSlug) async => null;

  @override
  Future<List<String>> listDayImages({required int dayOfWeek, required LiturgicalSeason season}) async {
    return ['assets/seed/images/ordinary/1/E.jpg'];
  }

  @override
  Future<Map<String, DayQuotes>> loadQuotes({required String language, required LiturgicalSeason season}) async {
    return {
      '1': const DayQuotes(day: 'Domingo', theme: 'Tema', quotes: ['Jaculatoria de teste']),
    };
  }

  @override
  Future<List<String>> loadFeastQuotes(String feastSlug) async => const <String>[];
}

final class _FakeQuoteIndicesRepository implements QuoteIndicesRepository {
  QuoteIndices _indices = QuoteIndices.empty(1);

  @override
  Future<QuoteIndices> load({required int dayOfWeek}) async => _indices;

  @override
  Future<void> save(QuoteIndices indices) async {
    _indices = indices;
  }
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

final class _InMemoryLastDeliveredCardRepository implements LastDeliveredCardRepository {
  LastDeliveredCard? value;

  @override
  Future<LastDeliveredCard?> load() async => value;

  @override
  Future<void> save(LastDeliveredCard card) async {
    value = card;
  }
}

void main() {
  testWidgets('saving settings cancels and rebuilds reminders', (tester) async {
    final settingsRepo = _FakeSettingsRepository(Settings.defaults.copyWith(laudesEnabled: true));
    final schedulerRepo = _FakeNotificationSchedulerRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          notificationSchedulerRepositoryProvider.overrideWithValue(schedulerRepo),
          quoteContentRepositoryProvider.overrideWithValue(_FakeQuoteContentRepository()),
          quoteIndicesRepositoryProvider.overrideWithValue(_FakeQuoteIndicesRepository()),
          liturgicalSeasonServiceProvider.overrideWithValue(_FakeLiturgicalSeasonService()),
          lastDeliveredCardRepositoryProvider.overrideWithValue(_InMemoryLastDeliveredCardRepository()),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(ElevatedButton, 'Salvar');
    await tester.dragUntilVisible(
      saveButton,
      find.byType(ListView),
      const Offset(0, -180),
    );

    final save = tester.widget<ElevatedButton>(saveButton);
    save.onPressed!.call();
    await tester.pumpAndSettle();

    expect(schedulerRepo.cancelAllCalls, 1);
    expect(schedulerRepo.scheduled.any((e) => e.type == ReminderEventType.quoteInterval), isTrue);
    expect(schedulerRepo.scheduled.any((e) => e.type == ReminderEventType.angelusNoon), isTrue);
    expect(schedulerRepo.scheduled.any((e) => e.type == ReminderEventType.laudes), isTrue);
  });
}
