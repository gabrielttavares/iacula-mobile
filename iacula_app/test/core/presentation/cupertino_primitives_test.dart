import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/core/presentation/widgets/iacula_buttons.dart';
import 'package:iacula_app/core/presentation/widgets/iacula_soft_card.dart';
import 'package:iacula_app/core/theme/cupertino_tokens.dart';

void main() {
  testWidgets('IaculaPrimaryPillButton has height 52', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(child: IaculaPrimaryPillButton(label: 'Entrar')),
        ),
      ),
    );

    final size = tester.getSize(find.byType(IaculaPrimaryPillButton));
    expect(size.height, 52);
  });

  testWidgets('IaculaSoftCard uses 20 radius by default', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(child: IaculaSoftCard(child: Text('Card'))),
      ),
    );

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(IaculaSoftCard),
            matching: find.byType(Container),
          )
          .first,
    );

    final decoration = container.decoration as BoxDecoration;
    final borderRadius = decoration.borderRadius! as BorderRadius;
    expect(borderRadius.topLeft.x, IaculaRadius.card);
  });

  test('Iacula primary button color token is app blue', () {
    expect(IaculaColors.primaryButton, const Color(0xFF0975C8));
  });
}
