import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/meditation/domain/entities/meditation_item.dart';

void main() {
  test('fromJson parses video item correctly', () {
    final json = <String, dynamic>{
      'id': 'video-1',
      'type': 'video',
      'title': 'Test Video',
      'summary': 'A test video meditation',
      'durationSec': 600,
      'categoryTags': ['espiritual', 'foco'],
      'sourceName': 'Test Source',
      'sourceUrl': 'https://example.com/video',
      'mediaUrl': 'https://example.com/media',
      'availability': {'kind': 'evergreen'},
      'premiumTier': 'free',
      'provenance': {'providerId': 'test', 'providerType': 'channel'},
    };

    final item = MeditationItem.fromJson(json);

    expect(item.id, 'video-1');
    expect(item.type, MeditationType.video);
    expect(item.title, 'Test Video');
    expect(item.durationSec, 600);
    expect(item.categoryTags, ['espiritual', 'foco']);
    expect(item.availability.kind, MeditationAvailabilityKind.evergreen);
    expect(item.provenance.providerType, 'channel');
  });

  test('fromJson parses text item with textContent', () {
    final json = <String, dynamic>{
      'id': 'text-1',
      'type': 'text',
      'title': 'Daily Meditation',
      'summary': 'A daily text',
      'categoryTags': ['diário'],
      'sourceName': 'Test',
      'availability': {'kind': 'daily', 'timezone': 'America/Sao_Paulo'},
      'textContent': {
        'body': 'Some meditation text with several words for testing reading time.',
        'format': 'plain',
        'language': 'pt',
      },
      'provenance': {'providerId': 'test', 'providerType': 'daily_text'},
    };

    final item = MeditationItem.fromJson(json);

    expect(item.type, MeditationType.text);
    expect(item.textContent, isNotNull);
    expect(item.textContent!.format, 'plain');
    expect(item.textContent!.language, 'pt');
    expect(item.availability.kind, MeditationAvailabilityKind.daily);
    expect(item.availability.timezone, 'America/Sao_Paulo');
    expect(item.readingTimeSec, isNotNull);
    expect(item.provenance.providerType, 'daily_text');
  });

  test('durationLabel formats correctly', () {
    final item = MeditationItem.fromJson({
      'id': '1',
      'type': 'audio',
      'title': 'T',
      'summary': 'S',
      'durationSec': 90,
      'categoryTags': <String>[],
      'sourceName': 'S',
      'availability': {'kind': 'evergreen'},
      'provenance': {'providerId': 'p', 'providerType': 'channel'},
    });

    expect(item.durationLabel, '2 min');
  });

  test('estimateReadingTimeSec computes from word count', () {
    final text = List.filled(200, 'word').join(' '); // 200 words
    final secs = MeditationItem.estimateReadingTimeSec(text);
    expect(secs, 60); // 200 words / 200 wpm = 1 min = 60 sec
  });

  test('fromJson handles missing optional fields gracefully', () {
    final json = <String, dynamic>{
      'id': 'min-1',
      'type': 'video',
      'title': 'Minimal',
      'summary': 'Minimal item',
      'categoryTags': <String>[],
      'sourceName': 'Source',
      'availability': {'kind': 'evergreen'},
      'provenance': {'providerId': 'p'},
    };

    final item = MeditationItem.fromJson(json);

    expect(item.sourceUrl, isNull);
    expect(item.mediaUrl, isNull);
    expect(item.imageUrl, isNull);
    expect(item.dateRef, isNull);
    expect(item.textContent, isNull);
    expect(item.premiumTier, 'free');
    expect(item.provenance.providerType, 'channel');
  });
}
