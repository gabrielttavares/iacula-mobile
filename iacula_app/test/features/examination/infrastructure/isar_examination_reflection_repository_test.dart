import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/storage/isar/examination_reflection_doc.dart';
import 'package:iacula_app/features/examination/domain/entities/examination_reflection_item.dart';
import 'package:iacula_app/features/examination/infrastructure/repositories/isar_examination_reflection_repository.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;

const _defaultSeedJson = '''
[
  {"id":"1","section_title":"Ato de Presença de Deus","text":"Texto 1","sort_order":0},
  {"id":"2","section_title":"Deveres para com Deus","text":"Texto 2","sort_order":1},
  {"id":"3","section_title":"Deveres para com o próximo","text":"Texto 3","sort_order":2},
  {"id":"4","section_title":"Deveres para comigo mesmo","text":"Texto 4","sort_order":3},
  {"id":"5","section_title":"Ato de contrição","text":"Texto 5","sort_order":4}
]
''';

void main() {
  group('IsarExaminationReflectionRepository', () {
    late Isar isar;
    late IsarExaminationReflectionRepository repository;
    late Directory tempDir;

    setUp(() async {
      if (!Platform.isMacOS) return;

      await Isar.initializeIsarCore(
        libraries: {
          Abi.current(): p.join(
            Directory.current.path,
            'third_party/isar_flutter_libs/macos/libisar.dylib',
          ),
        },
      );

      tempDir = await Directory.systemTemp.createTemp('iacula-exam-reflection');
      isar = await Isar.open(
        [ExaminationReflectionDocSchema],
        directory: tempDir.path,
        name: 'exam_reflection_${DateTime.now().microsecondsSinceEpoch}',
      );
      repository = IsarExaminationReflectionRepository(
        isarProvider: () async => isar,
        loadSeed: () async => _defaultSeedJson,
      );
    });

    tearDown(() async {
      if (!Platform.isMacOS) return;
      await isar.close(deleteFromDisk: true);
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'seedDefaultsIfEmpty creates the default reading blocks once',
      () async {
        if (!Platform.isMacOS) return;

        await repository.seedDefaultsIfEmpty();
        final firstSeed = await repository.listAll();
        await repository.seedDefaultsIfEmpty();
        final secondSeed = await repository.listAll();

        expect(firstSeed, hasLength(5));
        expect(
          firstSeed.map((item) => item.sectionTitle),
          containsAll(<String>[
            'Ato de Presença de Deus',
            'Deveres para com Deus',
            'Deveres para com o próximo',
            'Deveres para comigo mesmo',
            'Ato de contrição',
          ]),
        );
        expect(secondSeed, hasLength(5));
      },
    );

    test(
      'seedDefaultsIfEmpty does not overwrite user-managed content',
      () async {
        if (!Platform.isMacOS) return;

        await repository.createItem(
          sectionTitle: 'Título próprio',
          text: 'Texto próprio',
        );

        await repository.seedDefaultsIfEmpty();
        final items = await repository.listAll();

        expect(items, hasLength(1));
        expect(items.single.sectionTitle, 'Título próprio');
        expect(items.single.text, 'Texto próprio');
      },
    );

    test('create update and delete keep the managed list consistent', () async {
      if (!Platform.isMacOS) return;

      await repository.createItem(
        sectionTitle: 'Primeira seção',
        text: 'Primeiro texto',
      );

      final created = (await repository.listAll()).single;
      expect(created.sortOrder, 0);

      final updated = ExaminationReflectionItem(
        id: created.id,
        sectionTitle: 'Seção atualizada',
        text: 'Texto atualizado',
        sortOrder: created.sortOrder,
        createdAt: created.createdAt,
        updatedAt: created.updatedAt,
      );

      await repository.updateItem(updated);
      final afterUpdate = (await repository.listAll()).single;
      expect(afterUpdate.sectionTitle, 'Seção atualizada');
      expect(afterUpdate.text, 'Texto atualizado');

      await repository.deleteItem(created.id);
      expect(await repository.listAll(), isEmpty);
    });
  });
}
