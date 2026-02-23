import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/daily_liturgy.dart';

final class LiturgiaApiService {
  LiturgiaApiService({
    required http.Client httpClient,
    this.baseUrl = 'https://liturgia.up.railway.app/v2',
    this.timeout = const Duration(seconds: 4),
  }) : _httpClient = httpClient;

  final http.Client _httpClient;
  final String baseUrl;
  final Duration timeout;

  Future<List<LiturgyDay>> fetchPeriod({int days = 7}) async {
    final safeDays = days.clamp(1, 7);
    final uri = Uri.parse('$baseUrl/?periodo=$safeDays');
    return _fetchMany(uri);
  }

  Future<LiturgyDay?> fetchByDate(DateTime date) async {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    final uri = Uri.parse('$baseUrl/?dia=$day&mes=$month&ano=$year');
    final list = await _fetchMany(uri);
    if (list.isEmpty) return null;
    return list.first;
  }

  Future<List<LiturgyDay>> _fetchMany(Uri uri) async {
    try {
      final response = await _httpClient.get(uri).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode > 299) {
        return const <LiturgyDay>[];
      }

      final decoded = jsonDecode(response.body);
      final nodes = _extractDayNodes(decoded);
      return nodes.map(_parseDay).toList(growable: false);
    } catch (_) {
      return const <LiturgyDay>[];
    }
  }

  List<Map<String, dynamic>> _extractDayNodes(dynamic payload) {
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);
    }

    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final candidates = <dynamic>[
        map['dias'],
        map['periodo'],
        map['dados'],
        map['liturgias'],
      ];
      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(growable: false);
        }
      }
      if (_looksLikeDayMap(map)) {
        return <Map<String, dynamic>>[map];
      }
    }

    return const <Map<String, dynamic>>[];
  }

  bool _looksLikeDayMap(Map<String, dynamic> map) {
    return map.containsKey('liturgia') ||
        map.containsKey('cor') ||
        map.containsKey('leituras');
  }

  LiturgyDay _parseDay(Map<String, dynamic> data) {
    return LiturgyDay(
      date: _parseDate(data),
      title: _text(data['liturgia'], fallback: 'Liturgia diária'),
      color: _parseColor(data['cor']?.toString()),
      prayers: _parsePrayers(data['oracoes']),
      readings: _parseReadings(data['leituras']),
      antiphons: _parseAntiphons(data['antifonas']),
    );
  }

  DateTime _parseDate(Map<String, dynamic> data) {
    final fromIso = data['data']?.toString() ?? data['date']?.toString();
    if (fromIso != null) {
      final parsed = DateTime.tryParse(fromIso);
      if (parsed != null) {
        return DateTime(parsed.year, parsed.month, parsed.day);
      }
    }

    final day = int.tryParse('${data['dia'] ?? ''}');
    final month = int.tryParse('${data['mes'] ?? ''}');
    final year = int.tryParse('${data['ano'] ?? ''}');
    if (day != null && month != null && year != null) {
      return DateTime(year, month, day);
    }

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  LiturgyColor _parseColor(String? raw) {
    switch (_normalize(raw)) {
      case 'vermelho':
        return LiturgyColor.red;
      case 'roxo':
        return LiturgyColor.purple;
      case 'rosa':
        return LiturgyColor.pink;
      case 'branco':
        return LiturgyColor.white;
      case 'verde':
      default:
        return LiturgyColor.green;
    }
  }

  LiturgyPrayer _parsePrayers(dynamic value) {
    final map = value is Map
        ? Map<String, dynamic>.from(value)
        : const <String, dynamic>{};
    final extras = map['extras'];
    return LiturgyPrayer(
      collect: _text(map['coleta']),
      offering: _text(map['oferendas']),
      communion: _text(map['comunhao']),
      extra: extras is List
          ? extras
                .whereType<Object?>()
                .map((e) => _text(e))
                .where((e) => e.isNotEmpty)
                .toList(growable: false)
          : const <String>[],
    );
  }

  LiturgyAntiphons _parseAntiphons(dynamic value) {
    final map = value is Map
        ? Map<String, dynamic>.from(value)
        : const <String, dynamic>{};
    final extras = map['extras'];
    return LiturgyAntiphons(
      entry: _optionalText(map['entrada']),
      communion: _optionalText(map['comunhao']),
      extra: extras is List
          ? extras
                .whereType<Object?>()
                .map((e) => _text(e))
                .where((e) => e.isNotEmpty)
                .toList(growable: false)
          : const <String>[],
    );
  }

  List<LiturgyReading> _parseReadings(dynamic value) {
    final map = value is Map
        ? Map<String, dynamic>.from(value)
        : const <String, dynamic>{};
    final readings = <LiturgyReading>[];

    final firstReading = _parseReadingMap(
      map['primeiraLeitura'] ?? map['primeira_leitura'],
    );
    if (firstReading != null) readings.add(firstReading);

    final secondReading = _parseReadingMap(
      map['segundaLeitura'] ?? map['segunda_leitura'],
    );
    if (secondReading != null) readings.add(secondReading);

    final psalmRaw = map['salmo'];
    if (psalmRaw is List) {
      for (final item in psalmRaw.whereType<Map>()) {
        final psalm = _parseReadingMap(item);
        if (psalm != null) readings.add(psalm);
      }
    } else {
      final psalm = _parseReadingMap(psalmRaw);
      if (psalm != null) readings.add(psalm);
    }

    final gospel = _parseReadingMap(map['evangelho']);
    if (gospel != null) readings.add(gospel);

    return readings;
  }

  LiturgyReading? _parseReadingMap(dynamic value) {
    if (value is! Map) return null;
    final map = Map<String, dynamic>.from(value);

    final reference = _text(map['referencia'] ?? map['ref']);
    final title = _text(
      map['titulo'],
      fallback: reference.isEmpty ? 'Leitura' : reference,
    );
    final text = _text(map['texto']);
    final response = _optionalText(map['refrao'] ?? map['resposta']);

    if (reference.isEmpty && text.isEmpty && response == null) return null;

    return LiturgyReading(
      reference: reference,
      title: title,
      text: text,
      response: response,
    );
  }

  String _normalize(String? value) {
    return (value ?? '')
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .trim();
  }

  String _text(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String? _optionalText(Object? value) {
    final text = _text(value);
    return text.isEmpty ? null : text;
  }
}
