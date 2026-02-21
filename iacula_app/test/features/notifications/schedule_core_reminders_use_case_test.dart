import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import 'package:iacula_app/features/notifications/domain/entities/last_delivered_card.dart';
import 'package:iacula_app/features/notifications/domain/entities/reminder_event.dart';
import 'package:iacula_app/features/notifications/domain/repositories/last_delivered_card_repository.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import 'package:iacula_app/features/quotes/domain/entities/quote.dart';
import 'package:iacula_app/features/settings/domain/entities/settings.dart';

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
  test('schedules quote reminder with quote text and stores last delivered card', () async {
    final scheduler = InMemoryNotificationSchedulerRepository();
    final lastCardRepo = _InMemoryLastDeliveredCardRepository();

    final useCase = ScheduleCoreRemindersUseCase(
      scheduler,
      quoteFetcher: ({required String language, required DateTime now}) async {
        return const Quote(
          text: 'Sede santos, porque eu sou santo.',
          dayOfWeek: 1,
          theme: 'todos os santos',
          season: LiturgicalSeason.ordinary,
          imagePath: 'assets/seed/images/ordinary/1/E.jpg',
          feast: 'all-saints',
          feastName: 'todos os santos',
        );
      },
      lastDeliveredCardRepository: lastCardRepo,
    );

    final settings = Settings.defaults.copyWith(intervalMinutes: 15, language: 'pt-br');
    final now = DateTime(2026, 2, 21, 10, 0);

    await useCase(settings, now: now);

    final quoteEvent = scheduler.events.firstWhere((e) => e.type == ReminderEventType.quoteInterval);
    expect(quoteEvent.title, 'Iacula');
    expect(quoteEvent.body, 'Sede santos, porque eu sou santo.');

    final lastCard = await lastCardRepo.load();
    expect(lastCard, isNotNull);
    expect(lastCard!.quoteText, 'Sede santos, porque eu sou santo.');
    expect(lastCard.feastName, 'todos os santos');
  });
}
