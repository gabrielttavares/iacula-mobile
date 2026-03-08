import 'saint_of_day.dart';

const kFallbackSaintName = 'Comunhão dos santos';
const kFallbackSaintDescription =
    'Hoje a Igreja convida você a rezar em sintonia com o tempo litúrgico.';

SaintOfDay saintOfDayOrFallback(SaintOfDay? saint, {DateTime? date}) {
  if (saint != null) {
    return saint;
  }

  return SaintOfDay(
    date: date ?? DateTime.now(),
    name: kFallbackSaintName,
    biographyParagraphs: const [kFallbackSaintDescription],
    imageAssetPath: 'assets/placeholders/saint-placeholder.png',
  );
}
