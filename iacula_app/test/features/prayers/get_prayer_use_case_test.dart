import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/prayers/application/use_cases/get_prayer_use_case.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_collection.dart';
import 'package:iacula_app/features/prayers/domain/entities/prayer_detail.dart';
import 'package:iacula_app/features/prayers/domain/repositories/prayer_content_repository.dart';

class _FakePrayerRepository implements PrayerContentRepository {
  @override
  Future<String?> getAngelusImagePath() async => 'angelus';

  @override
  Future<String?> getReginaCaeliImagePath() async => 'regina';

  @override
  Future<PrayerCollection> loadPrayers({required String language}) async {
    return const PrayerCollection(
      regularTitle: 'Angelus',
      regularVerses: [PrayerVerse(verse: 'v1', response: 'r1')],
      regularPrayer: 'regular',
      easterTitle: 'Regina Caeli',
      easterVerses: [PrayerVerse(verse: 'v2', response: 'r2')],
      easterPrayer: 'easter',
    );
  }

  @override
  Future<PrayerDetail> loadPrayerDetail({required String slug}) async {
    throw UnimplementedError();
  }
}

void main() {
  test('always returns regular Angelus prayer', () async {
    final useCase = GetPrayerUseCase(prayerRepository: _FakePrayerRepository());

    final prayer = await useCase.call(language: 'pt-br');
    expect(prayer.type, 'angelus');
    expect(prayer.title, 'Angelus');
  });
}
