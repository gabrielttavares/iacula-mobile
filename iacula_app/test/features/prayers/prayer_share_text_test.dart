import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/prayers/domain/services/prayer_share_text.dart';

void main() {
  test('formats a prayer for WhatsApp with roles, rubrics and the app link', () {
    final text = formatPrayerForSharing(
      title: 'Ângelus',
      blocks: const [
        '℣ O Anjo do Senhor anunciou a Maria.',
        '℟ E Ela concebeu do Espírito Santo.',
        '_Ave-Maria…_',
        '# Oração final',
        '*Todos dizem:*',
        'São Miguel, ℟ rogai por nós.',
      ],
      appLink: 'https://apps.apple.com/app/id1',
    );

    expect(
      text,
      '*Ângelus*\n\n'
      'V. O Anjo do Senhor anunciou a Maria.\n\n'
      'R. E Ela concebeu do Espírito Santo.\n\n'
      '_Ave-Maria…_\n\n'
      '*Oração final*\n\n'
      '_Todos dizem:_\n\n'
      'São Miguel, R. rogai por nós.\n\n'
      'Rezado com o Iacula 🙏\nhttps://apps.apple.com/app/id1',
    );
  });

  test('keeps hymn line breaks and italicises each rubric line', () {
    final text = formatPrayerForSharing(
      title: 'Hino',
      blocks: const ['Verso um,\nverso dois.', '*Linha um\nlinha dois*'],
      appLink: 'x',
    );
    expect(text, contains('Verso um,\nverso dois.'));
    expect(text, contains('_Linha um_\n_linha dois_'));
  });
}
