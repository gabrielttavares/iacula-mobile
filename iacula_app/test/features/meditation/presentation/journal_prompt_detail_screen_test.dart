import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/journal_prompts/domain/entities/journal_prompt.dart';
import 'package:iacula_app/features/meditation/presentation/journal_prompt_detail_screen.dart';
import 'package:iacula_app/features/meditation/presentation/meditation_screen.dart';

void main() {
  testWidgets('Abrir Leituras routes into the Meditação screen', (
    tester,
  ) async {
    const prompt = JournalPrompt(
      id: 'prompt-1',
      category: JournalPromptCategory.general,
      text: 'Pelo que sou grato hoje?',
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: CupertinoApp(home: JournalPromptDetailScreen(prompt: prompt)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Abrir Leituras'));
    await tester.pumpAndSettle();

    expect(find.byType(MeditationScreen), findsOneWidget);
  });
}
