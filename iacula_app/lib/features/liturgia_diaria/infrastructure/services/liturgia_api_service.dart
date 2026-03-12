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
    final requestedDate = DateTime(date.year, date.month, date.day);
    final result = list.first;
    if (_sameDate(result.date, requestedDate)) {
      return result;
    }
    return LiturgyDay(
      date: requestedDate,
      title: result.title,
      color: result.color,
      prayers: result.prayers,
      readings: result.readings,
      antiphons: result.antiphons,
    );
  }

  Future<List<LiturgyDay>> _fetchMany(Uri uri) async {
    try {
      final response = await _httpClient.get(uri).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode > 299) {
        return const <LiturgyDay>[];
      }

      final decoded = jsonDecode(response.body);
      final nodes = _extractDayNodes(decoded);
      final baseDate = DateTime.now();
      return nodes
          .asMap()
          .entries
          .map((entry) {
            return _parseDay(entry.value, entry.key, baseDate);
          })
          .toList(growable: false);
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

  LiturgyDay _parseDay(
    Map<String, dynamic> data,
    int index,
    DateTime baseDate,
  ) {
    return LiturgyDay(
      date: _parseDate(data, index, baseDate),
      title: _text(data['liturgia'], fallback: 'Liturgia diária'),
      color: _parseColor(data['cor']?.toString()),
      prayers: _parsePrayers(data['oracoes']),
      readings: _parseReadings(data['leituras']),
      antiphons: _parseAntiphons(data['antifonas']),
    );
  }

  DateTime _parseDate(Map<String, dynamic> data, int index, DateTime baseDate) {
    final rawDate = _dateText(data['data']) ?? _dateText(data['date']);
    if (rawDate != null) {
      final parsed = _tryParseDate(rawDate);
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

    final normalizedBase = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
    );
    return normalizedBase.add(Duration(days: index));
  }

  DateTime? _tryParseDate(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) return null;

    final iso = DateTime.tryParse(normalized);
    if (iso != null) return iso;

    final slashMatch = RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})$').firstMatch(
      normalized,
    );
    if (slashMatch != null) {
      final day = int.parse(slashMatch.group(1)!);
      final month = int.parse(slashMatch.group(2)!);
      final year = int.parse(slashMatch.group(3)!);
      return DateTime(year, month, day);
    }

    return null;
  }

  String? _dateText(Object? raw) {
    final text = raw?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

  static const _kindAliases = <String, LiturgyReadingKind>{
    'primeiraLeitura': LiturgyReadingKind.first,
    'primeira_leitura': LiturgyReadingKind.first,
    'primeira': LiturgyReadingKind.first,
    '1aLeitura': LiturgyReadingKind.first,
    '1a_leitura': LiturgyReadingKind.first,
    'firstReading': LiturgyReadingKind.first,
    'first_reading': LiturgyReadingKind.first,
    'salmo': LiturgyReadingKind.psalm,
    'psalm': LiturgyReadingKind.psalm,
    'salmoResponsorial': LiturgyReadingKind.psalm,
    'salmo_responsorial': LiturgyReadingKind.psalm,
    'segundaLeitura': LiturgyReadingKind.second,
    'segunda_leitura': LiturgyReadingKind.second,
    'segunda': LiturgyReadingKind.second,
    '2aLeitura': LiturgyReadingKind.second,
    '2a_leitura': LiturgyReadingKind.second,
    'secondReading': LiturgyReadingKind.second,
    'second_reading': LiturgyReadingKind.second,
    'sequencia': LiturgyReadingKind.sequence,
    'sequence': LiturgyReadingKind.sequence,
    'aclamacao': LiturgyReadingKind.acclamation,
    'aclamação': LiturgyReadingKind.acclamation,
    'acclamation': LiturgyReadingKind.acclamation,
    'evangelho': LiturgyReadingKind.gospel,
    'gospel': LiturgyReadingKind.gospel,
  };

  static const _kindLabels = <LiturgyReadingKind, String>{
    LiturgyReadingKind.first: 'Primeira leitura',
    LiturgyReadingKind.psalm: 'Salmo',
    LiturgyReadingKind.second: 'Segunda leitura',
    LiturgyReadingKind.sequence: 'Sequência',
    LiturgyReadingKind.acclamation: 'Aclamação ao Evangelho',
    LiturgyReadingKind.gospel: 'Evangelho',
  };

  List<LiturgyReading> _parseReadings(dynamic value) {
    final candidates =
        <({LiturgyReadingKind kind, Map<String, dynamic> raw})>[];

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      for (final entry in map.entries) {
        final kind = _kindAliases[entry.key] ?? LiturgyReadingKind.other;
        final raw = entry.value;
        if (raw is List) {
          for (final item in raw.whereType<Map>()) {
            candidates.add((kind: kind, raw: Map<String, dynamic>.from(item)));
          }
        } else if (raw is Map) {
          candidates.add((kind: kind, raw: Map<String, dynamic>.from(raw)));
        }
      }
    } else if (value is List) {
      for (final item in value.whereType<Map>()) {
        final map = Map<String, dynamic>.from(item);
        final kind = _detectKindFromItem(map);
        candidates.add((kind: kind, raw: map));
      }
    }

    final readings = <LiturgyReading>[];
    for (final c in candidates) {
      final reading = _parseReadingMap(c.raw, c.kind);
      if (reading != null) readings.add(reading);
    }

    readings.sort((a, b) => a.kind.index.compareTo(b.kind.index));
    return readings;
  }

  LiturgyReadingKind _detectKindFromItem(Map<String, dynamic> map) {
    for (final key in ['tipo', 'type', 'kind', 'nome', 'titulo']) {
      final val = map[key]?.toString();
      if (val != null) {
        final match = _kindAliases[val];
        if (match != null) return match;
      }
    }
    return LiturgyReadingKind.other;
  }

  LiturgyReading? _parseReadingMap(
    Map<String, dynamic> map,
    LiturgyReadingKind kind,
  ) {
    final reference = _text(map['referencia'] ?? map['ref']);
    final fallbackTitle =
        _kindLabels[kind] ?? (reference.isEmpty ? 'Leitura' : reference);
    final title = _text(map['titulo'], fallback: fallbackTitle);
    final text = _text(map['texto']);
    final response = _optionalText(map['refrao'] ?? map['resposta']);

    if (reference.isEmpty && text.isEmpty && response == null) return null;

    return LiturgyReading(
      reference: reference,
      title: title,
      text: text,
      response: response,
      kind: kind,
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
