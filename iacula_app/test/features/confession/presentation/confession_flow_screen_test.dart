import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/confession/domain/entities/confession_examination_item.dart';
import 'package:iacula_app/features/confession/domain/repositories/confession_examination_repository.dart';
import 'package:iacula_app/features/confession/presentation/confession_flow_screen.dart';

final class _FakeConfessionExaminationRepository
    implements ConfessionExaminationRepository {
  const _FakeConfessionExaminationRepository(this.items);

  final List<ConfessionExaminationItem> items;

  @override
  Future<List<ConfessionExaminationItem>> listAll() async => items;
}

void main() {
  Widget buildNavigationHarness({
    required ConfessionExaminationRepository repository,
  }) {
    return ProviderScope(
      overrides: [
        confessionExaminationRepositoryProvider.overrideWithValue(repository),
      ],
      child: CupertinoApp(
        home: Builder(
          builder: (context) => CupertinoPageScaffold(
            child: Center(
              child: CupertinoButton(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const ConfessionFlowScreen(),
                    ),
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ProviderScope buildTestApp({
    required ConfessionExaminationRepository repository,
  }) {
    return ProviderScope(
      overrides: [
        confessionExaminationRepositoryProvider.overrideWithValue(repository),
      ],
      child: const CupertinoApp(home: ConfessionFlowScreen()),
    );
  }

  const items = [
    ConfessionExaminationItem(
      id: 'faith_denied',
      text: 'Neguei ou abandonei a minha fé.',
      sortOrder: 0,
    ),
    ConfessionExaminationItem(
      id: 'missed_mass',
      text: 'Faltei voluntariamente à Missa aos domingos ou dias de preceito.',
      sortOrder: 1,
    ),
    ConfessionExaminationItem(
      id: 'lies',
      text: 'Disse mentiras.',
      sortOrder: 2,
    ),
  ];

  testWidgets(
    'opens confession examination directly without intro screen',
    (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          repository: const _FakeConfessionExaminationRepository(items),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.text('Exame de Consciência para Confissão'),
        findsOneWidget,
      );
      expect(find.text('Começar'), findsNothing);
      expect(find.text('Como se confessar?'), findsNothing);
      expect(find.text('Neguei ou abandonei a minha fé.'), findsOneWidget);
      expect(
        find.text(
          'Faltei voluntariamente à Missa aos domingos ou dias de preceito.',
        ),
        findsOneWidget,
      );
      expect(find.text('Compartilhar'), findsNothing);
      expect(find.byIcon(CupertinoIcons.square), findsNothing);
      expect(find.byIcon(CupertinoIcons.checkmark_square_fill), findsNothing);
    },
  );

  testWidgets('back arrow returns to parent screen', (tester) async {
    await tester.pumpWidget(
      buildNavigationHarness(
        repository: const _FakeConfessionExaminationRepository(items),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Abrir'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(ConfessionFlowScreen), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.chevron_back));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(ConfessionFlowScreen), findsNothing);
    expect(find.text('Abrir'), findsOneWidget);
  });
}
