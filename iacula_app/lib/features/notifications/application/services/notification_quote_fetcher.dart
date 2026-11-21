import '../../../custom_phrases/domain/entities/custom_phrase.dart';
import '../../../custom_phrases/domain/services/personal_phrase_feed_selector.dart';
import '../../../quotes/application/use_cases/get_next_escriva_points_quote_use_case.dart';
import '../../../quotes/application/use_cases/get_next_quote_use_case.dart';
import '../../../quotes/domain/entities/quote.dart';
import '../../../settings/domain/entities/settings.dart';
import '../use_cases/schedule_core_reminders_use_case.dart';

/// The single source of what each scheduled notification says. Shared by the
/// in-app rebuild, the cold-start rebuild and the background re-arm so the
/// three never drift apart (the cold-start copy once ignored personal
/// phrases, so "only my phrases" users got liturgical quotes after a restart).
QuoteFetcher buildNotificationQuoteFetcher({
  required Future<Settings> Function() loadSettings,
  required Future<List<CustomPhrase>> Function() listPhrases,
  required GetNextQuoteUseCase nextQuote,
  required GetNextEscrivaPointsQuoteUseCase nextEscrivaPoint,
}) {
  return ({required String language, required DateTime now}) async {
    final settings = await loadSettings();

    // Personal phrase feed. Two modes share the same eligible pool and
    // fire-time slot, differing only in cadence:
    //   • "only mine" (customPhrasesOnly): EVERY slot is a personal
    //     phrase, cycling the pool. An empty pool falls through to the
    //     liturgical draw so the feed is never empty.
    //   • default: a 1-in-4 slot is personal; the rest are liturgical.
    // Either way, an empty pool yields identical scheduling to before.
    final eligiblePhrases = PersonalPhraseFeedSelector.eligibleForNotifications(
      await listPhrases(),
    );
    final slotIndex = PersonalPhraseFeedSelector.slotIndexForFireTime(now);
    final selectedPhrase = settings.customPhrasesOnly
        ? PersonalPhraseFeedSelector.phraseForExclusiveSlot(
            slotIndex: slotIndex,
            eligible: eligiblePhrases,
          )
        : PersonalPhraseFeedSelector.phraseForSlot(
            slotIndex: slotIndex,
            eligible: eligiblePhrases,
          );
    if (selectedPhrase != null) {
      return Quote.personal(text: selectedPhrase.text, dayOfWeek: now.weekday);
    }

    if (settings.escrivaPointsFeedEnabled) {
      return nextEscrivaPoint.call(
        language: language,
        now: now,
        cadenceMinutes: settings.intervalMinutes,
      );
    }
    return nextQuote.call(language: language, now: now);
  };
}
