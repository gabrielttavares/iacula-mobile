import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/confession/domain/entities/confession_examination_item.dart';
import 'package:iacula_app/features/confession/domain/repositories/confession_examination_repository.dart';
import 'package:iacula_app/features/confession/domain/services/native_share_service.dart';
import 'package:iacula_app/features/confession/presentation/confession_flow_screen.dart';

final class _FakeConfessionExaminationRepository
    implements ConfessionExaminationRepository {
  const _FakeConfessionExaminationRepository(this.items);

  final List<ConfessionExaminationItem> items;

  @override
  Future<List<ConfessionExaminationItem>> listAll() async => items;
}

final class _FakeNativeShareService implements NativeShareService {
  String? sharedText;

  @override
  Future<void> shareText(String text) async {
    sharedText = text;
  }
}

void main() {
  ProviderScope buildTestApp({
    required ConfessionExaminationRepository repository,
    required NativeShareService shareService,
  }) {
    return ProviderScope(
      overrides: [
        confessionExaminationRepositoryProvider.overrideWithValue(repository),
        nativeShareServiceProvider.overrideWithValue(shareService),
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

  testWidgets('renders the list and allows multiple selections', (
    tester,
  ) async {
    final shareService = _FakeNativeShareService();

    await tester.pumpWidget(
      buildTestApp(
        repository: const _FakeConfessionExaminationRepository(items),
        shareService: shareService,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();

    expect(find.text('Exame de Consciência'), findsOneWidget);
    expect(find.text('Neguei ou abandonei a minha fé.'), findsOneWidget);
    expect(
      find.text(
        'Faltei voluntariamente à Missa aos domingos ou dias de preceito.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(CupertinoIcons.checkmark_square_fill), findsNothing);

    await tester.tap(find.text('Neguei ou abandonei a minha fé.'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(
        'Faltei voluntariamente à Missa aos domingos ou dias de preceito.',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(CupertinoIcons.checkmark_square_fill), findsNWidgets(2));
    expect(find.text('2 itens selecionados.'), findsOneWidget);
  });

  testWidgets('shows a message when sharing with no selection', (tester) async {
    final shareService = _FakeNativeShareService();

    await tester.pumpWidget(
      buildTestApp(
        repository: const _FakeConfessionExaminationRepository(items),
        shareService: shareService,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compartilhar'));
    await tester.pump();

    expect(find.text('Selecione ao menos um item.'), findsOneWidget);
    expect(shareService.sharedText, isNull);
  });

  testWidgets('shares selected items as newline separated plain text', (
    tester,
  ) async {
    final shareService = _FakeNativeShareService();

    await tester.pumpWidget(
      buildTestApp(
        repository: const _FakeConfessionExaminationRepository(items),
        shareService: shareService,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disse mentiras.'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Neguei ou abandonei a minha fé.'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compartilhar'));
    await tester.pump();

    expect(
      shareService.sharedText,
      'Neguei ou abandonei a minha fé.\nDisse mentiras.',
    );
  });
}
