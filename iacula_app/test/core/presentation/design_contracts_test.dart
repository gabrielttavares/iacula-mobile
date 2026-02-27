import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/presentation/design/iacula_feedback.dart';
import 'package:iacula_app/core/presentation/design/iacula_input.dart';
import 'package:iacula_app/core/presentation/design/iacula_modal.dart';
import 'package:iacula_app/core/presentation/design/iacula_nav.dart';
import 'package:iacula_app/core/theme/cupertino_tokens.dart';

void main() {
  testWidgets('IaculaTextInput renders placeholder text', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: IaculaTextInput(placeholder: 'Seu nome'),
        ),
      ),
    );

    expect(find.text('Seu nome'), findsOneWidget);
  });

  testWidgets('IaculaValidatedInput shows error message', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: IaculaValidatedInput(
            label: 'Horário',
            errorText: 'Formato HH:MM',
            child: IaculaTextInput(placeholder: '00:00'),
          ),
        ),
      ),
    );

    expect(find.text('Formato HH:MM'), findsOneWidget);
  });

  testWidgets('IaculaEmptyState renders title and message', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: IaculaEmptyState(
            title: 'Sem dados',
            message: 'Nenhum item encontrado.',
          ),
        ),
      ),
    );

    expect(find.text('Sem dados'), findsOneWidget);
    expect(find.text('Nenhum item encontrado.'), findsOneWidget);
  });

  testWidgets('IaculaLargeTitleScaffold shows title', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: IaculaLargeTitleScaffold(
          title: 'Configurações',
          child: SizedBox.shrink(),
        ),
      ),
    );

    expect(find.text('Configurações'), findsOneWidget);
  });

  testWidgets('IaculaModal.showAlert displays CupertinoAlertDialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CupertinoApp(home: CupertinoPageScaffold(child: SizedBox.shrink())),
    );
    final context = tester.element(find.byType(SizedBox).first);

    IaculaModal.showAlert(
      context: context,
      title: 'Aviso',
      message: 'Mensagem',
      actionLabel: 'OK',
    );
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.text('Aviso'), findsOneWidget);
  });

  test('extended semantic tokens are defined', () {
    expect(IaculaColors.success, const Color(0xFF34C759));
    expect(IaculaColors.warning, const Color(0xFFFF9500));
    expect(IaculaColors.error, const Color(0xFFFF3B30));
    expect(IaculaMetrics.minTapTarget, 44.0);
  });

  test('home reverent tokens are exposed', () {
    expect(IaculaColors.homeWarmBackground, const Color(0xFFFFFAF3));
    expect(IaculaColors.homeSacredAccent, const Color(0xFFB08A57));
    expect(IaculaColors.homeHeroTop, const Color(0xFFF6EFE3));
    expect(IaculaColors.homeHeroBottom, const Color(0xFFFDF9F2));
  });
}
