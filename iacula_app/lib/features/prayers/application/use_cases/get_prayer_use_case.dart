import '../../../liturgical/domain/liturgical_season.dart';
import '../../../liturgical/domain/services/liturgical_season_service.dart';
import '../../domain/entities/prayer.dart';
import '../../domain/repositories/prayer_content_repository.dart';

final class GetPrayerUseCase {
  const GetPrayerUseCase({
    required PrayerContentRepository prayerRepository,
    required LiturgicalSeasonService liturgicalSeasonService,
  })  : _prayerRepository = prayerRepository,
        _liturgicalSeasonService = liturgicalSeasonService;

  final PrayerContentRepository _prayerRepository;
  final LiturgicalSeasonService _liturgicalSeasonService;

  Future<Prayer> call({
    required String language,
    bool? forceEasterTime,
    DateTime? date,
  }) async {
    final season = await _liturgicalSeasonService.getCurrentSeason(date: date);
    final isEaster = forceEasterTime ?? season == LiturgicalSeason.easter;

    final collection = await _prayerRepository.loadPrayers(language: language);
    if (isEaster) {
      return Prayer(
        title: collection.easterTitle,
        verses: collection.easterVerses,
        prayer: collection.easterPrayer,
        type: 'reginaCaeli',
        imagePath: await _prayerRepository.getReginaCaeliImagePath(),
      );
    }

    return Prayer(
      title: collection.regularTitle,
      verses: collection.regularVerses,
      prayer: collection.regularPrayer,
      type: 'angelus',
      imagePath: await _prayerRepository.getAngelusImagePath(),
    );
  }
}
