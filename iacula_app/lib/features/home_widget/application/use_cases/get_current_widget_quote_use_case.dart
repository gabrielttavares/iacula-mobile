import '../../../liturgical/domain/liturgical_season.dart';
import '../../../notifications/domain/entities/notification_history_entry.dart';
import '../../../notifications/domain/repositories/last_delivered_card_repository.dart';
import '../../../notifications/domain/repositories/notification_history_repository.dart';
import '../../../quotes/domain/entities/quote.dart';

typedef WidgetFallbackQuoteFetcher =
    Future<Quote> Function({required String language, required DateTime now});

final class GetCurrentWidgetQuoteUseCase {
  const GetCurrentWidgetQuoteUseCase({
    required NotificationHistoryRepository notificationHistoryRepository,
    required LastDeliveredCardRepository lastDeliveredCardRepository,
    required WidgetFallbackQuoteFetcher fallbackQuoteFetcher,
  }) : _notificationHistoryRepository = notificationHistoryRepository,
       _lastDeliveredCardRepository = lastDeliveredCardRepository,
       _fallbackQuoteFetcher = fallbackQuoteFetcher;

  final NotificationHistoryRepository _notificationHistoryRepository;
  final LastDeliveredCardRepository _lastDeliveredCardRepository;
  final WidgetFallbackQuoteFetcher _fallbackQuoteFetcher;

  Future<Quote> call({required String language, DateTime? now}) async {
    final current = now ?? DateTime.now();
    final history = await _notificationHistoryRepository.listForDay(current);
    final dueEntries = history.where(
      (entry) => !entry.deliveredAt.isAfter(current),
    );

    NotificationHistoryEntry? latestDue;
    for (final entry in dueEntries) {
      if (latestDue == null ||
          entry.deliveredAt.isAfter(latestDue.deliveredAt)) {
        latestDue = entry;
      }
    }

    if (latestDue != null) {
      return _toQuote(latestDue, current);
    }

    final lastCard = await _lastDeliveredCardRepository.load();
    if (lastCard != null && _isSameDay(lastCard.deliveredAt, current)) {
      return lastCard.toQuote();
    }

    return _fallbackQuoteFetcher(language: language, now: current);
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  Quote _toQuote(NotificationHistoryEntry entry, DateTime now) {
    final season = LiturgicalSeason.values.firstWhere(
      (candidate) => candidate.name == entry.season,
      orElse: () => LiturgicalSeason.ordinary,
    );

    return Quote(
      text: entry.quoteText,
      dayOfWeek: now.weekday,
      theme: entry.theme,
      season: season,
      imagePath: entry.imagePath,
      feastName: entry.feastName,
    );
  }
}
