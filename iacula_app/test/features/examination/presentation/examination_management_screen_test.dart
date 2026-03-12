import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/examination/domain/entities/examination_reflection_item.dart';
import 'package:iacula_app/features/examination/domain/repositories/examination_reflection_repository.dart';
import 'package:iacula_app/features/examination/presentation/examination_management_screen.dart';

final class _MutableFakeExaminationReflectionRepository
    implements ExaminationReflectionRepository {
  _MutableFakeExaminationReflectionRepository(
    List<ExaminationReflectionItem> seed,
  ) : _items = List<ExaminationReflectionItem>.from(seed);

  final List<ExaminationReflectionItem> _items;
  final _controller =
      StreamController<List<ExaminationReflectionItem>>.broadcast();

  @override
  Future<void> createItem({
    required String sectionTitle,
    required String text,
  }) async {
    _items.add(
      ExaminationReflectionItem(
        id: 'item-${_items.length + 1}',
        sectionTitle: sectionTitle,
        text: text,
        sortOrder: _items.length,
        createdAt: DateTime(2026, 3, 11),
        updatedAt: DateTime(2026, 3, 11),
      ),
    );
    _emit();
  }

  @override
  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    _emit();
  }

  @override
  Future<List<ExaminationReflectionItem>> listAll() async =>
      List<ExaminationReflectionItem>.from(_items);

  @override
  Future<void> seedDefaultsIfEmpty() async {}

  @override
  Future<void> updateItem(ExaminationReflectionItem item) async {
    final index = _items.indexWhere((entry) => entry.id == item.id);
    _items[index] = item;
    _emit();
  }

  @override
  Stream<List<ExaminationReflectionItem>> watchAll() async* {
    yield await listAll();
    yield* _controller.stream;
  }

  void _emit() {
    _controller.add(List<ExaminationReflectionItem>.from(_items));
  }
}

void main() {
  testWidgets('management screen adds edits and deletes reflection items', (
    tester,
  ) async {
    final repository = _MutableFakeExaminationReflectionRepository([
      ExaminationReflectionItem(
        id: '1',
        sectionTitle: 'Acto de Presença de Deus',
        text: 'Meu Deus, dai-me luz.',
        sortOrder: 0,
        createdAt: DateTime(2026, 3, 11),
        updatedAt: DateTime(2026, 3, 11),
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          examinationReflectionRepositoryProvider.overrideWithValue(repository),
        ],
        child: const CupertinoApp(home: ExaminationManagementScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Acto de Presença de Deus'), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(CupertinoTextField).at(0), 'Nova seção');
    await tester.enterText(find.byType(CupertinoTextField).at(1), 'Novo texto');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Nova seção'), findsOneWidget);

    await tester.tap(find.text('Nova seção'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(CupertinoTextField).at(0),
      'Nova seção editada',
    );
    await tester.enterText(
      find.byType(CupertinoTextField).at(1),
      'Novo texto editado',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Nova seção editada'), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.delete).last);
    await tester.pumpAndSettle();

    expect(find.text('Nova seção editada'), findsNothing);
  });
}
