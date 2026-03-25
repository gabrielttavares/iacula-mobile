import '../../../notifications/domain/entities/last_delivered_card.dart';
import '../../../quotes/domain/entities/quote.dart';
import '../../../settings/domain/entities/settings.dart';

typedef WidgetSettingsLoader = Future<Settings> Function();
typedef WidgetQuoteSelector =
    Future<Quote> Function({required Settings settings, required DateTime now});
typedef WidgetUpdater =
    Future<bool> Function(LastDeliveredCard card, {int? intervalMinutes});
typedef WidgetIntervalSaver = Future<void> Function(int intervalMinutes);
typedef WidgetNowProvider = DateTime Function();

final class RefreshWidgetFromTimelineUseCase {
  RefreshWidgetFromTimelineUseCase({
    required WidgetSettingsLoader loadSettings,
    required WidgetQuoteSelector selectQuote,
    required WidgetUpdater updateWidgetIfChanged,
    required WidgetIntervalSaver saveIntervalMinutes,
    WidgetNowProvider? now,
  }) : _loadSettings = loadSettings,
       _selectQuote = selectQuote,
       _updateWidgetIfChanged = updateWidgetIfChanged,
       _saveIntervalMinutes = saveIntervalMinutes,
       _now = now ?? DateTime.now;

  final WidgetSettingsLoader _loadSettings;
  final WidgetQuoteSelector _selectQuote;
  final WidgetUpdater _updateWidgetIfChanged;
  final WidgetIntervalSaver _saveIntervalMinutes;
  final WidgetNowProvider _now;

  Future<bool> call() async {
    final settings = await _loadSettings();
    await _saveIntervalMinutes(settings.intervalMinutes);

    if (!settings.onboardingCompleted || !settings.notificationsEnabled) {
      return false;
    }

    final now = _now();
    final quote = await _selectQuote(settings: settings, now: now);
    final card = LastDeliveredCard.fromQuote(quote, deliveredAt: now);
    return _updateWidgetIfChanged(
      card,
      intervalMinutes: settings.intervalMinutes,
    );
  }
}
