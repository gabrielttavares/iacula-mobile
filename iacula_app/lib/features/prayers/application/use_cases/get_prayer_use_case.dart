import '../../domain/entities/prayer.dart';
import '../../domain/repositories/prayer_content_repository.dart';

final class GetPrayerUseCase {
  const GetPrayerUseCase({required PrayerContentRepository prayerRepository})
    : _prayerRepository = prayerRepository;

  final PrayerContentRepository _prayerRepository;

  Future<Prayer> call({required String language}) async {
    final collection = await _prayerRepository.loadPrayers(language: language);
    return Prayer(
      title: collection.regularTitle,
      verses: collection.regularVerses,
      prayer: collection.regularPrayer,
      type: 'angelus',
      imagePath: await _prayerRepository.getAngelusImagePath(),
    );
  }
}
