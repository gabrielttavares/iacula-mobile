import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' show SelectableText, TextSpan;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/meditation/domain/entities/meditation_item.dart';
import 'package:iacula_app/features/meditation/presentation/meditation_reader_screen.dart';
import 'package:iacula_app/features/reading/domain/entities/reading_bookmark.dart';
import 'package:iacula_app/features/reading/domain/entities/reading_highlight.dart';
import 'package:iacula_app/features/reading/infrastructure/repositories/in_memory_reading_annotation_repository.dart';

void main() {
  testWidgets(
    'text meditations open in a minimal reader with bottom controls',
    (tester) async {
      final item = MeditationItem(
        id: 'remote-text',
        type: MeditationType.text,
        title: 'Meditação remota',
        summary: 'Resumo curto',
        categoryTags: const ['espiritual'],
        sourceName: 'Hablar con Dios',
        sourceUrl: 'https://example.com/meditacao',
        availability: const MeditationAvailability(
          kind: MeditationAvailabilityKind.daily,
        ),
        provenance: const MeditationProvenance(
          providerId: 'hablar-con-dios',
          providerType: 'daily_text',
        ),
      );

      final client = MockClient((request) async {
        expect(request.url.toString(), item.sourceUrl);
        return http.Response('''
        <html><body>
          <div class="entry-content">
            <p>Primeiro parágrafo.</p>
            <p>Segundo parágrafo.</p>
          </div>
        </body></html>
      ''', 200);
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [httpClientProvider.overrideWithValue(client)],
          child: CupertinoApp(home: MeditationReaderScreen(item: item)),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Meditação remota'), findsAtLeastNWidgets(1));
      expect(find.text('Primeiro parágrafo.'), findsOneWidget);
      expect(find.text('Segundo parágrafo.'), findsOneWidget);
      expect(find.text('A-'), findsOneWidget);
      expect(find.text('A+'), findsOneWidget);
      expect(find.text('Abrir original'), findsOneWidget);
      expect(find.text('Modo leitura'), findsNothing);
      expect(find.text('Texto sincronizado'), findsNothing);
    },
  );

  testWidgets(
    'text meditations render persisted highlights and bookmark actions',
    (tester) async {
      final repository = InMemoryReadingAnnotationRepository();
      await repository.saveHighlight(
        ReadingHighlight(
          id: 'hl-1',
          documentId: 'meditation:local-text',
          blockId: 'body-paragraph-0',
          startOffset: 0,
          endOffset: 8,
          colorKey: 'default',
          createdAt: DateTime.utc(2026, 3, 14),
        ),
      );
      await repository.saveBookmark(
        ReadingBookmark(
          documentId: 'meditation:local-text',
          blockId: 'body-paragraph-0',
          startOffset: 0,
          label: 'Primeiro',
          updatedAt: DateTime.utc(2026, 3, 14),
        ),
      );

      final item = MeditationItem(
        id: 'local-text',
        type: MeditationType.text,
        title: 'Leitura local',
        summary: '',
        categoryTags: const ['espiritual'],
        sourceName: 'Fonte',
        availability: const MeditationAvailability(
          kind: MeditationAvailabilityKind.evergreen,
        ),
        provenance: const MeditationProvenance(
          providerId: 'local',
          providerType: 'daily_text',
        ),
        textContent: const MeditationTextContent(
          body: 'Primeiro trecho.\n\nSegundo trecho.',
          format: 'plain',
          language: 'pt',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            readingAnnotationRepositoryProvider.overrideWithValue(repository),
          ],
          child: CupertinoApp(home: MeditationReaderScreen(item: item)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Marcar'), findsOneWidget);
      expect(find.text('Ir ao marcador'), findsOneWidget);

      final selectable = tester.widget<SelectableText>(
        find.byType(SelectableText).first,
      );
      final textSpan = selectable.textSpan! as TextSpan;
      final highlightedSpan = textSpan.children!
          .whereType<TextSpan>()
          .firstWhere((span) => span.style?.backgroundColor != null);
      expect(highlightedSpan.text, 'Primeiro');
    },
  );
}
