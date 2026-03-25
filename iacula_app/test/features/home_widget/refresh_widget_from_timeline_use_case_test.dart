import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/home_widget/application/use_cases/refresh_widget_from_timeline_use_case.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/notifications/domain/entities/last_delivered_card.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';

void main() {
  test(
    'updates widget when onboarding and notifications are enabled',
    () async {
      var selectCalls = 0;
      var updateCalls = 0;

      final useCase = RefreshWidgetFromTimelineUseCase(
        loadSettings: () async => Settings.defaults.copyWith(
          onboardingCompleted: true,
          notificationsEnabled: true,
          intervalMinutes: 15,
        ),
        selectQuote:
            ({required Settings settings, required DateTime now}) async {
              selectCalls += 1;
              return const Quote(
                text: 'Q1',
                dayOfWeek: 2,
                theme: 'theme',
                season: LiturgicalSeason.lent,
              );
            },
        updateWidgetIfChanged:
            (LastDeliveredCard card, {int? intervalMinutes}) async {
              updateCalls += 1;
              expect(card.quoteText, 'Q1');
              expect(intervalMinutes, 15);
              return true;
            },
        saveIntervalMinutes: (int intervalMinutes) async {
          expect(intervalMinutes, 15);
        },
        now: () => DateTime(2026, 3, 24, 10, 0),
      );

      final updated = await useCase.call();

      expect(updated, isTrue);
      expect(selectCalls, 1);
      expect(updateCalls, 1);
    },
  );

  test('skips widget update when notifications are disabled', () async {
    var updateCalls = 0;
    var savedInterval = 0;

    final useCase = RefreshWidgetFromTimelineUseCase(
      loadSettings: () async => Settings.defaults.copyWith(
        onboardingCompleted: true,
        notificationsEnabled: false,
        intervalMinutes: 5,
      ),
      selectQuote: ({required Settings settings, required DateTime now}) async {
        throw StateError('should not fetch quote when notifications are off');
      },
      updateWidgetIfChanged:
          (LastDeliveredCard card, {int? intervalMinutes}) async {
            updateCalls += 1;
            return true;
          },
      saveIntervalMinutes: (int intervalMinutes) async {
        savedInterval = intervalMinutes;
      },
      now: DateTime.now,
    );

    final updated = await useCase.call();

    expect(updated, isFalse);
    expect(updateCalls, 0);
    expect(savedInterval, 5);
  });

  test('returns false when quote did not change', () async {
    final useCase = RefreshWidgetFromTimelineUseCase(
      loadSettings: () async => Settings.defaults.copyWith(
        onboardingCompleted: true,
        notificationsEnabled: true,
        intervalMinutes: 5,
      ),
      selectQuote: ({required Settings settings, required DateTime now}) async {
        return const Quote(
          text: 'same-slot',
          dayOfWeek: 2,
          theme: 'theme',
          season: LiturgicalSeason.ordinary,
        );
      },
      updateWidgetIfChanged:
          (LastDeliveredCard card, {int? intervalMinutes}) async => false,
      saveIntervalMinutes: (int intervalMinutes) async {},
      now: DateTime.now,
    );

    final updated = await useCase.call();

    expect(updated, isFalse);
  });
}
