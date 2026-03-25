import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/home_widget/application/use_cases/get_current_widget_quote_use_case.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/notifications/domain/entities/last_delivered_card.dart';
import 'package:iacula_app/features/notifications/domain/entities/notification_history_entry.dart';
import 'package:iacula_app/features/notifications/domain/repositories/last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';

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

final class _FakeLastDeliveredCardRepository
    implements LastDeliveredCardRepository {
  _FakeLastDeliveredCardRepository(this.card);

  LastDeliveredCard? card;

  @override
  Future<LastDeliveredCard?> load() async => card;

  @override
  Future<void> save(LastDeliveredCard card) async {
    this.card = card;
  }
}

void main() {
  test('returns latest due quote from today history timeline', () async {
    var fallbackCalls = 0;
    final useCase = GetCurrentWidgetQuoteUseCase(
      notificationHistoryRepository: _FakeNotificationHistoryRepository([
        NotificationHistoryEntry(
          quoteText: 'Quote 10:15',
          theme: 'T1',
          season: LiturgicalSeason.lent.name,
          deliveredAt: DateTime(2026, 3, 24, 10, 15),
        ),
        NotificationHistoryEntry(
          quoteText: 'Quote 10:00',
          theme: 'T0',
          season: LiturgicalSeason.lent.name,
          deliveredAt: DateTime(2026, 3, 24, 10, 0),
        ),
      ]),
      lastDeliveredCardRepository: _FakeLastDeliveredCardRepository(
        LastDeliveredCard(
          quoteText: 'Stale',
          theme: 'Legacy',
          season: LiturgicalSeason.lent.name,
          deliveredAt: DateTime(2026, 3, 24, 9, 0),
        ),
      ),
      fallbackQuoteFetcher:
          ({required String language, required DateTime now}) async {
            fallbackCalls++;
            return const Quote(
              text: 'fallback',
              dayOfWeek: 2,
              theme: 'fallback',
              season: LiturgicalSeason.ordinary,
            );
          },
    );

    final quote = await useCase.call(
      language: 'pt-br',
      now: DateTime(2026, 3, 24, 10, 14),
    );

    expect(quote.text, 'Quote 10:00');
    expect(quote.theme, 'T0');
    expect(fallbackCalls, 0);
  });

  test(
    'falls back to last delivered card when no due history entry exists',
    () async {
      var fallbackCalls = 0;
      final useCase = GetCurrentWidgetQuoteUseCase(
        notificationHistoryRepository: _FakeNotificationHistoryRepository([
          NotificationHistoryEntry(
            quoteText: 'Future Quote',
            theme: 'Future',
            season: LiturgicalSeason.lent.name,
            deliveredAt: DateTime(2026, 3, 24, 10, 15),
          ),
        ]),
        lastDeliveredCardRepository: _FakeLastDeliveredCardRepository(
          LastDeliveredCard(
            quoteText: 'Last Delivered',
            theme: 'Legacy',
            season: LiturgicalSeason.lent.name,
            deliveredAt: DateTime(2026, 3, 24, 9, 0),
          ),
        ),
        fallbackQuoteFetcher:
            ({required String language, required DateTime now}) async {
              fallbackCalls++;
              return const Quote(
                text: 'fallback',
                dayOfWeek: 2,
                theme: 'fallback',
                season: LiturgicalSeason.ordinary,
              );
            },
      );

      final quote = await useCase.call(
        language: 'pt-br',
        now: DateTime(2026, 3, 24, 10, 14),
      );

      expect(quote.text, 'Last Delivered');
      expect(fallbackCalls, 0);
    },
  );

  test(
    'uses fallback fetcher only when no due history and no same-day card',
    () async {
      var fallbackCalls = 0;
      final useCase = GetCurrentWidgetQuoteUseCase(
        notificationHistoryRepository: _FakeNotificationHistoryRepository([
          NotificationHistoryEntry(
            quoteText: 'Future Quote',
            theme: 'Future',
            season: LiturgicalSeason.lent.name,
            deliveredAt: DateTime(2026, 3, 24, 10, 15),
          ),
        ]),
        lastDeliveredCardRepository: _FakeLastDeliveredCardRepository(
          LastDeliveredCard(
            quoteText: 'Yesterday',
            theme: 'Legacy',
            season: LiturgicalSeason.lent.name,
            deliveredAt: DateTime(2026, 3, 23, 23, 0),
          ),
        ),
        fallbackQuoteFetcher:
            ({required String language, required DateTime now}) async {
              fallbackCalls++;
              return const Quote(
                text: 'fallback',
                dayOfWeek: 2,
                theme: 'fallback',
                season: LiturgicalSeason.ordinary,
              );
            },
      );

      final quote = await useCase.call(
        language: 'pt-br',
        now: DateTime(2026, 3, 24, 10, 14),
      );

      expect(quote.text, 'fallback');
      expect(fallbackCalls, 1);
    },
  );
}
