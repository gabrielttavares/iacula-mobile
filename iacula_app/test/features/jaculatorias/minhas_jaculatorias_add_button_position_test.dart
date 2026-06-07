import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/custom_phrases/application/use_cases/schedule_phrase_notifications_use_case.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/custom_phrase.dart';
import 'package:iacula_app/features/custom_phrases/domain/entities/phrase_schedule.dart';
import 'package:iacula_app/features/custom_phrases/domain/repositories/custom_phrase_repository.dart';
import 'package:iacula_app/features/jaculatorias/presentation/minhas_jaculatorias_screen.dart';
import 'package:iacula_app/features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';

final class _StubCustomPhraseRepository implements CustomPhraseRepository {
  _StubCustomPhraseRepository(this._phrases);

  final List<CustomPhrase> _phrases;

  @override
  Future<List<CustomPhrase>> listAll() async => _phrases;

  @override
  Future<CustomPhrase?> getById(String id) async => null;

  @override
  Future<void> save(CustomPhrase phrase) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Stream<List<CustomPhrase>> watchAll() => const Stream.empty();
}

CustomPhrase _makeTextPhrase({required String id, required String text}) {
  return CustomPhrase(
    id: id,
    text: text,
    schedule: const PhraseSchedule(type: PhraseScheduleType.daily),
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}

Widget _buildScreenWithPhrases(List<CustomPhrase> phrases) {
  final repository = _StubCustomPhraseRepository(phrases);
  final scheduler = InMemoryNotificationSchedulerRepository();
  final scheduleUseCase = SchedulePhraseNotificationsUseCase(
    scheduler,
    repository,
  );

  return ProviderScope(
    overrides: [
      customPhraseRepositoryProvider.overrideWithValue(repository),
      schedulePhraseNotificationsUseCaseProvider.overrideWithValue(
        scheduleUseCase,
      ),
    ],
    child: const CupertinoApp(home: MinhasJaculatoriasScreen()),
  );
}

void main() {
  group('MinhasJaculatoriasScreen — Adicionar frase button position', () {
    testWidgets('shows add-phrase button before any phrase items when list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(_buildScreenWithPhrases([]));
      await tester.pumpAndSettle();

      expect(find.text('Adicionar frase'), findsOneWidget);
      expect(find.text('Nenhuma frase pessoal ainda'), findsOneWidget);

      final addButtonOffset =
          tester.getTopLeft(find.text('Adicionar frase')).dy;
      final emptyHintOffset =
          tester.getTopLeft(find.text('Nenhuma frase pessoal ainda')).dy;

      expect(
        addButtonOffset,
        lessThan(emptyHintOffset),
        reason:
            'Adicionar frase button must appear above the empty-state hint',
      );
    });

    testWidgets('shows add-phrase button before phrase items when list has entries', (
      tester,
    ) async {
      final phrases = [
        _makeTextPhrase(id: 'p1', text: 'Senhor, ficai conosco'),
        _makeTextPhrase(id: 'p2', text: 'Veni Sancte Spiritus'),
      ];

      await tester.pumpWidget(_buildScreenWithPhrases(phrases));
      await tester.pumpAndSettle();

      expect(find.text('Adicionar frase'), findsOneWidget);
      expect(find.text('Senhor, ficai conosco'), findsOneWidget);

      final addButtonOffset =
          tester.getTopLeft(find.text('Adicionar frase')).dy;
      final firstPhraseOffset =
          tester.getTopLeft(find.text('Senhor, ficai conosco')).dy;

      expect(
        addButtonOffset,
        lessThan(firstPhraseOffset),
        reason:
            'Adicionar frase button must appear above the first phrase item',
      );
    });
  });
}
