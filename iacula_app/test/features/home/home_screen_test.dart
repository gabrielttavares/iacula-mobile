import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/home/presentation/home_screen.dart';
import 'package:iacula_app/features/notifications/domain/entities/last_delivered_card.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_history_entry.dart';
import 'package:iacula_app/features/notifications/domain/repositories/last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/domain/repositories/notification_history_repository.dart';
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

final class _FakeNotificationHistoryRepository
    implements NotificationHistoryRepository {
  _FakeNotificationHistoryRepository(this.entries);

  final List<NotificationHistoryEntry> entries;

  @override
  Future<void> add(NotificationHistoryEntry entry) async {}

  @override
  Future<void> clearFrom(DateTime instant) async {}

  @override
  Future<List<NotificationHistoryEntry>> listForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final dayEntries =
        entries
            .where(
              (entry) =>
                  !entry.deliveredAt.isBefore(start) &&
                  entry.deliveredAt.isBefore(end),
            )
            .toList(growable: false)
          ..sort((a, b) => b.deliveredAt.compareTo(a.deliveredAt));
    return dayEntries;
  }
}

Widget _buildApp({
  DateTime? now,
  LastDeliveredCard? lastCard,
  List<NotificationHistoryEntry> history = const [],
}) {
  final fixedNow = now ?? DateTime(2026, 2, 21, 11);
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(
        _FakeSettingsRepository(Settings.defaults),
      ),
      lastDeliveredCardRepositoryProvider.overrideWithValue(
        _FakeLastDeliveredCardRepository(
          lastCard ??
              LastDeliveredCard(
                quoteText: 'Permanecei em mim.',
                theme: 'Conversao',
                season: 'ordinary',
                deliveredAt: DateTime(2026, 2, 21, 11),
              ),
        ),
      ),
      notificationHistoryRepositoryProvider.overrideWithValue(
        _FakeNotificationHistoryRepository(history),
      ),
      homeNowProvider.overrideWith((ref) => fixedNow),
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
      i < 5 &&
          find
              .byKey(const Key('home_feature_confissao_card'))
              .evaluate()
              .isEmpty;
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
    expect(find.byKey(const Key('home_action_exame')), findsOneWidget);
    expect(
      find.byKey(const Key('home_feature_confissao_card')),
      findsOneWidget,
    );
  });

  testWidgets('home removes deleted shortcuts and sections', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Ação de Graças'), findsNothing);
    expect(find.byKey(const Key('home_action_liturgia')), findsNothing);
    expect(find.byKey(const Key('home_action_exame')), findsOneWidget);
    expect(find.byKey(const Key('home_feature_rosario_card')), findsNothing);
    expect(find.text('Liturgia diária'), findsNothing);
    expect(find.text('Rosário'), findsNothing);
  });

  testWidgets('home hero uses latest due quote from notification timeline', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        now: DateTime(2026, 2, 21, 10, 14),
        lastCard: LastDeliveredCard(
          quoteText: 'Stale card',
          theme: 'Conversao',
          season: 'ordinary',
          deliveredAt: DateTime(2026, 2, 21, 8, 0),
        ),
        history: [
          NotificationHistoryEntry(
            quoteText: 'Quote 10:00',
            theme: 'Conversao',
            season: 'ordinary',
            deliveredAt: DateTime(2026, 2, 21, 10, 0),
          ),
          NotificationHistoryEntry(
            quoteText: 'Quote 10:15',
            theme: 'Conversao',
            season: 'ordinary',
            deliveredAt: DateTime(2026, 2, 21, 10, 15),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quote 10:00'), findsOneWidget);
    expect(find.text('Quote 10:15'), findsNothing);
    expect(find.text('Stale card'), findsNothing);
  });

  testWidgets('home hero refreshes to next due quote while screen stays open', (
    tester,
  ) async {
    final nowProvider = StateProvider<DateTime>(
      (ref) => DateTime(2026, 2, 21, 10, 14),
    );

    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          _FakeSettingsRepository(Settings.defaults),
        ),
        lastDeliveredCardRepositoryProvider.overrideWithValue(
          _FakeLastDeliveredCardRepository(
            LastDeliveredCard(
              quoteText: 'Stale card',
              theme: 'Conversao',
              season: 'ordinary',
              deliveredAt: DateTime(2026, 2, 21, 8, 0),
            ),
          ),
        ),
        notificationHistoryRepositoryProvider.overrideWithValue(
          _FakeNotificationHistoryRepository([
            NotificationHistoryEntry(
              quoteText: 'Quote 10:00',
              theme: 'Conversao',
              season: 'ordinary',
              deliveredAt: DateTime(2026, 2, 21, 10, 0),
            ),
            NotificationHistoryEntry(
              quoteText: 'Quote 10:15',
              theme: 'Conversao',
              season: 'ordinary',
              deliveredAt: DateTime(2026, 2, 21, 10, 15),
            ),
          ]),
        ),
        homeNowProvider.overrideWith((ref) => ref.watch(nowProvider)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CupertinoApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quote 10:00'), findsOneWidget);
    expect(find.text('Quote 10:15'), findsNothing);

    container.read(nowProvider.notifier).state = DateTime(2026, 2, 21, 10, 16);
    await tester.pump(const Duration(seconds: 31));
    await tester.pumpAndSettle();

    expect(find.text('Quote 10:00'), findsNothing);
    expect(find.text('Quote 10:15'), findsOneWidget);
  });
}
