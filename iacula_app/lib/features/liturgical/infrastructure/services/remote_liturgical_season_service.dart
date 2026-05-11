import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/liturgical_context.dart';
import '../../domain/liturgical_season.dart';
import '../../domain/repositories/liturgical_season_cache_repository.dart';
import '../../domain/services/liturgical_season_service.dart';

final class RemoteLiturgicalSeasonService implements LiturgicalSeasonService {
  RemoteLiturgicalSeasonService({
    required http.Client httpClient,
    required LiturgicalSeasonCacheRepository cacheRepository,
    this.baseUrl = 'https://liturgia.up.railway.app/v2',
    this.timeout = const Duration(seconds: 3),
  })  : _httpClient = httpClient,
        _cacheRepository = cacheRepository;

  final http.Client _httpClient;
  final LiturgicalSeasonCacheRepository _cacheRepository;
  final String baseUrl;
  final Duration timeout;

  final Map<String, LiturgicalContext> _memoryCache = {};
  final Map<String, Future<LiturgicalContext>> _pending = {};

  DateTime? _lastFailureTime;
  static const _retryCooldown = Duration(seconds: 60);

  static const Map<String, String> _feastSlugAliases = {
    'domingo-de-pentecostes': 'pentecost',
    'santissima-trindade': 'holy-trinity',
    'santissimo-corpo-e-sangue-de-cristo': 'corpus-christi',
    'todos-os-santos': 'all-saints',
    'imaculada-conceicao-da-bem-aventurada-virgem-maria': 'immaculate-conception',
    'assuncao-da-bem-aventurada-virgem-maria': 'assumption',
    'sao-jose-esposo-da-bem-aventurada-virgem-maria': 'st-joseph',
    'santos-pedro-e-paulo-apostolos': 'sts-peter-paul',
    'bem-aventurada-virgem-maria-da-conceicao-aparecida-padroeira-do-brasil': 'our-lady-aparecida',
  };
  static const List<({List<String> keywords, String slug})> _feastPatterns = [
    (keywords: <String>['domingo de ramos'], slug: 'palm-sunday'),
    (keywords: <String>['semana santa', 'ceia do senhor'], slug: 'holy-thursday'),
    (keywords: <String>['paixao do senhor'], slug: 'good-friday'),
    (keywords: <String>['vigilia pascal'], slug: 'easter-vigil'),
    (keywords: <String>['domingo de pascoa'], slug: 'easter-sunday'),
    (keywords: <String>['pentecostes'], slug: 'pentecost'),
    (keywords: <String>['santissima trindade'], slug: 'holy-trinity'),
    (keywords: <String>['corpo e sangue de cristo'], slug: 'corpus-christi'),
    (keywords: <String>['todos os santos'], slug: 'all-saints'),
    (keywords: <String>['imaculada conceicao'], slug: 'immaculate-conception'),
    (keywords: <String>['assuncao'], slug: 'assumption'),
    (keywords: <String>['sao jose'], slug: 'st-joseph'),
    (keywords: <String>['santos pedro e paulo'], slug: 'sts-peter-paul'),
    (keywords: <String>['aparecida'], slug: 'our-lady-aparecida'),
  ];

  @override
  Future<LiturgicalSeason> getCurrentSeason({DateTime? date}) async {
    final context = await getCurrentContext(date: date);
    return context.season;
  }

  @override
  Future<LiturgicalContext> getCurrentContext({DateTime? date}) async {
    final target = date ?? DateTime.now();
    final key = _dateKey(target);

    final mem = _memoryCache[key];
    if (mem != null) {
      return mem;
    }

    final persistedSeason = await _cacheRepository.getByDateKey(key);
    if (persistedSeason != null) {
      final cached = LiturgicalContext(
        season: persistedSeason,
        rank: LiturgicalRank.weekday,
        apiQuotes: const <String>[],
      );
      _memoryCache[key] = cached;
      return cached;
    }

    final pending = _pending[key];
    if (pending != null) {
      return pending;
    }

    final request = _resolveContext(target).then((result) async {
      _memoryCache[key] = result.context;
      if (result.cacheable) {
        await _cacheRepository.put(key, result.context.season);
      }
      return result.context;
    }).whenComplete(() {
      _pending.remove(key);
    });

    _pending[key] = request;
    return request;
  }

  Future<_ContextResolution> _resolveContext(DateTime date) async {
    final lastFail = _lastFailureTime;
    if (lastFail != null &&
        DateTime.now().difference(lastFail) < _retryCooldown) {
      return const _ContextResolution(
        LiturgicalContext.ordinaryFallback,
        false,
      );
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final uri = Uri.parse('$baseUrl/?dia=$day&mes=$month&ano=$year');

    try {
      final response = await _httpClient.get(uri).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode > 299) {
        debugPrint(
          '[RemoteLiturgicalSeasonService] Liturgical API returned non-2xx; returning fallback. statusCode=${response.statusCode} uri=$uri date=$date',
        );
        developer.log(
          'Liturgical API returned non-2xx; returning fallback. statusCode=${response.statusCode} uri=$uri date=$date',
          name: 'RemoteLiturgicalSeasonService',
        );
        _lastFailureTime = DateTime.now();
        return const _ContextResolution(LiturgicalContext.ordinaryFallback, false);
      }

      _lastFailureTime = null;
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final liturgia = payload['liturgia']?.toString() ?? '';
      final normalizedLiturgy = _normalizeText(liturgia);
      final season = _mapSeason(cor: payload['cor']?.toString(), liturgia: liturgia);
      final rank = _parseRank(normalizedLiturgy);
      final feastName = _extractFeastName(liturgia);
      final feast = _detectFeast(normalizedLiturgy, rank, feastName);

      final context = LiturgicalContext(
        season: season,
        rank: rank,
        feast: feast,
        feastName: feast == null || feastName.isEmpty ? null : feastName,
        apiQuotes: _extractApiQuotes(payload),
      );

      return _ContextResolution(context, true);
    } catch (e, st) {
      debugPrint(
        '[RemoteLiturgicalSeasonService] Liturgical API error; returning fallback. error=$e',
      );
      developer.log(
        'Liturgical API error; returning fallback.',
        name: 'RemoteLiturgicalSeasonService',
        error: e,
        stackTrace: st,
      );
      _lastFailureTime = DateTime.now();
      return const _ContextResolution(LiturgicalContext.ordinaryFallback, false);
    }
  }

  LiturgicalSeason _mapSeason({String? cor, String? liturgia}) {
    final normalizedCor = _normalizeText(cor ?? '');
    final normalizedLiturgy = _normalizeText(liturgia ?? '');

    if (normalizedLiturgy.contains('semana santa') ||
        normalizedLiturgy.contains('paixao do senhor') ||
        normalizedLiturgy.contains('paixao')) {
      return LiturgicalSeason.lent;
    }

    switch (normalizedCor) {
      case 'verde':
      case 'vermelho':
        return LiturgicalSeason.ordinary;
      case 'roxo':
      case 'rosa':
        return normalizedLiturgy.contains('advento') ? LiturgicalSeason.advent : LiturgicalSeason.lent;
      case 'branco':
        if (normalizedLiturgy.contains('natal')) return LiturgicalSeason.christmas;
        if (normalizedLiturgy.contains('pascoa') ||
            normalizedLiturgy.contains('ressurreicao') ||
            normalizedLiturgy.contains('aleluia')) {
          return LiturgicalSeason.easter;
        }
        return LiturgicalSeason.ordinary;
      default:
        return LiturgicalSeason.ordinary;
    }
  }

  LiturgicalRank _parseRank(String normalizedLiturgy) {
    if (normalizedLiturgy.contains('solenidade')) return LiturgicalRank.solemnity;
    if (normalizedLiturgy.contains('festa')) return LiturgicalRank.feast;
    if (normalizedLiturgy.contains('memoria')) return LiturgicalRank.memorial;
    return LiturgicalRank.weekday;
  }

  String? _detectFeast(String normalizedLiturgy, LiturgicalRank rank, String feastName) {
    for (final pattern in _feastPatterns) {
      final hasMatch = pattern.keywords.every(normalizedLiturgy.contains);
      if (hasMatch) {
        return pattern.slug;
      }
    }

    if (rank == LiturgicalRank.solemnity || rank == LiturgicalRank.feast) {
      final rawSlug = _slugify(feastName);
      return _feastSlugAliases[rawSlug] ?? rawSlug;
    }

    return null;
  }

  String _extractFeastName(String liturgia) {
    final normalized = _normalizeText(liturgia)
        .replaceFirst(RegExp(r'^solenidade\s+de\s+'), '')
        .replaceFirst(RegExp(r'^festa\s+de\s+'), '')
        .replaceFirst(RegExp(r'^memoria\s+de\s+'), '')
        .replaceAll(RegExp(r',\s*(solenidade|festa|memoria)$'), '')
        .trim();

    return normalized;
  }

  List<String> _extractApiQuotes(Map<String, dynamic> payload) {
    final antifonas = payload['antifonas'] as Map<String, dynamic>?;
    final leituras = payload['leituras'] as Map<String, dynamic>?;
    final oracoes = payload['oracoes'] as Map<String, dynamic>?;

    final salmoList = leituras?['salmo'] as List<dynamic>?;
    final salmoRefrao = (salmoList != null && salmoList.isNotEmpty)
        ? (salmoList.first as Map<String, dynamic>)['refrao']?.toString()
        : null;

    final values = <String?>[
      antifonas?['entrada']?.toString(),
      antifonas?['comunhao']?.toString(),
      salmoRefrao,
      oracoes?['coleta']?.toString(),
      oracoes?['oferendas']?.toString(),
      oracoes?['comunhao']?.toString(),
    ];

    return values
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  String _normalizeText(String value) {
    return value
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
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _slugify(String value) {
    return value
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

final class _ContextResolution {
  const _ContextResolution(this.context, this.cacheable);

  final LiturgicalContext context;
  final bool cacheable;
}
