import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iacula_app/core/di/providers.dart';
import 'package:iacula_app/features/meditation/domain/entities/meditation_item.dart';
import 'package:iacula_app/features/meditation/presentation/meditation_reader_screen.dart';

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
}
