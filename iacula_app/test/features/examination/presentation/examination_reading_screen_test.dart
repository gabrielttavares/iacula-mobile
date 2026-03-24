import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/examination/domain/entities/examination_reflection_item.dart';
import 'package:iacula_app/features/examination/domain/repositories/examination_reflection_repository.dart';
import 'package:iacula_app/features/examination/presentation/examination_reading_screen.dart';

final class _FakeExaminationReflectionRepository
    implements ExaminationReflectionRepository {
  _FakeExaminationReflectionRepository(this._items);

  final List<ExaminationReflectionItem> _items;
  final _controller =
      StreamController<List<ExaminationReflectionItem>>.broadcast();

  @override
  Future<void> createItem({
    required String sectionTitle,
    required String text,
  }) async {}

  @override
  Future<void> deleteItem(String id) async {}

  @override
  Future<List<ExaminationReflectionItem>> listAll() async =>
      List<ExaminationReflectionItem>.from(_items);

  @override
  Future<void> seedDefaultsIfEmpty() async {}

  @override
  Future<void> updateItem(ExaminationReflectionItem item) async {}

  @override
  Stream<List<ExaminationReflectionItem>> watchAll() async* {
    yield await listAll();
    yield* _controller.stream;
  }
}

void main() {
  testWidgets('reading screen renders persisted blocks without answer inputs', (
    tester,
  ) async {
    final repository = _FakeExaminationReflectionRepository([
      ExaminationReflectionItem(
        id: '1',
        sectionTitle: 'Ato de Presença de Deus',
        text: 'Meu Deus, dai-me luz para conhecer os pecados que hoje cometi.',
        sortOrder: 0,
        createdAt: DateTime(2026, 3, 11),
        updatedAt: DateTime(2026, 3, 11),
      ),
      ExaminationReflectionItem(
        id: '2',
        sectionTitle: 'Deveres para com Deus',
        text: 'Lembrei-me de Deus durante o dia oferecendo-Lhe o meu trabalho?',
        sortOrder: 1,
        createdAt: DateTime(2026, 3, 11),
        updatedAt: DateTime(2026, 3, 11),
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          examinationReflectionRepositoryProvider.overrideWithValue(repository),
        ],
        child: const CupertinoApp(home: ExaminationReadingScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Exame de Consciência Diário'), findsAtLeast(1));
    expect(find.text('Para fazer ao final do dia'), findsOneWidget);
    expect(find.text('Ato de Presença de Deus'), findsOneWidget);
    expect(find.text('Deveres para com Deus'), findsOneWidget);
    expect(find.byType(CupertinoTextField), findsNothing);
    expect(find.text('Começar'), findsNothing);
  });
}
