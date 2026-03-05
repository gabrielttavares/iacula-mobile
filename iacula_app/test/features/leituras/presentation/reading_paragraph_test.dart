import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/leituras/data/models/reading_point_model.dart';
import 'package:iacula_app/features/leituras/presentation/widgets/reading_paragraph.dart';

void main() {
  testWidgets('reading paragraph renders numbered header and selectable text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: ReadingParagraph(
            point: ReadingPointModel(
              number: 12,
              paragraphs: ['Primeiro parágrafo', 'Segundo parágrafo'],
            ),
            fontSize: 16,
          ),
        ),
      ),
    );

    expect(find.text('12.'), findsOneWidget);
    expect(find.byType(SelectableText), findsNWidgets(2));
  });
}
