import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/challenges/infrastructure/repositories/asset_challenge_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('listAll parses imported novenas with complete day content', () async {
    final repository = AssetChallengeRepository();

    final challenges = await repository.listAll();
    final importedNovenas = challenges
        .where((challenge) => challenge.category.name == 'novena')
        .toList(growable: false);

    expect(importedNovenas, isNotEmpty);
    expect(
      importedNovenas.map((challenge) => challenge.title),
      containsAll([
        'Novena a São José',
        'Novena a Nossa Senhora de Fátima',
        'Novena de Pentecostes',
        'Novena a São Padre Pio',
        'Novena a São João Paulo II',
      ]),
    );

    for (final novena in importedNovenas) {
      expect(novena.durationDays, 9, reason: novena.id);
      expect(novena.content, hasLength(9), reason: novena.id);
      for (final day in novena.content) {
        expect(day.readingText.trim(), isNotEmpty, reason: '${novena.id}:${day.dayNumber}');
        expect(
          day.reflectionPrompt.trim(),
          isNotEmpty,
          reason: '${novena.id}:${day.dayNumber}',
        );
      }
    }
  });
}
