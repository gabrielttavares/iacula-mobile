import 'dart:convert';

import 'package:html/parser.dart' as html;
import 'package:http/http.dart' as http;

import '../../domain/entities/saint_of_day.dart';

final class SaintApiService {
  SaintApiService({
    required http.Client httpClient,
    this.apiBaseUrl = 'https://api-liturgia-diaria.vercel.app',
    this.cancaoNovaBaseUrl = 'https://santo.cancaonova.com',
    this.timeout = const Duration(seconds: 6),
  }) : _httpClient = httpClient;

  final http.Client _httpClient;
  final String apiBaseUrl;
  final String cancaoNovaBaseUrl;
  final Duration timeout;

  Future<SaintOfDay?> fetchTodaySaint() async {
    final uri = Uri.parse('$apiBaseUrl/santo-do-dia');
    try {
      final response = await _httpClient.get(uri).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode > 299) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return null;
      final node = decoded['today'];
      if (node is! Map) return null;
      return _parseSaintMap(
        Map<String, dynamic>.from(node as Map),
        fallbackDate: _today(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> resolveSaintPageUrl(DateTime date) async {
    final uri = Uri.parse('$cancaoNovaBaseUrl/wp-admin/admin-ajax.php');
    try {
      final response = await _httpClient
          .post(
            uri,
            body: <String, String>{
              'action': 'widget-ajax',
              'sMes': date.month.toString(),
              'sAno': date.year.toString(),
              'ajax': 'true',
            },
          )
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode > 299) return null;

      final document = html.parse(response.body);
      final links = document.querySelectorAll('a[href]');
      for (final link in links) {
        final href = link.attributes['href'];
        if (href == null) continue;
        if (href.contains('sDia=${date.day}') &&
            href.contains('sMes=${date.month.toString().padLeft(2, '0')}') &&
            href.contains('sAno=${date.year}')) {
          return href;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<SaintOfDay?> fetchSaintFromPage(
    String url, {
    required DateTime date,
  }) async {
    try {
      final response = await _httpClient.get(Uri.parse(url)).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode > 299) return null;
      final document = html.parse(response.body);
      final title = document.querySelector('h1.entry-title')?.text.trim() ?? '';
      if (title.isEmpty) return null;
      final entry = document.querySelector('.entry-content');
      final image = entry?.querySelector('img')?.attributes['src'];
      final paragraphs = <String>[];
      for (final paragraph in entry?.querySelectorAll('p') ?? const []) {
        final text = paragraph.text.trim();
        if (text.isNotEmpty) {
          paragraphs.add(text);
        }
      }
      return SaintOfDay(
        date: _normalizeDate(date),
        name: title,
        biographyParagraphs: paragraphs,
        remoteImageUrl: image,
      );
    } catch (_) {
      return null;
    }
  }

  SaintOfDay? _parseSaintMap(
    Map<String, dynamic> map, {
    required DateTime fallbackDate,
  }) {
    final name = (map['title'] ?? map['titulo'] ?? '').toString().trim();
    if (name.isEmpty) return null;
    final rawText = (map['full_text'] ?? map['texto'] ?? '').toString().trim();
    return SaintOfDay(
      date: _normalizeDate(fallbackDate),
      name: name,
      biographyParagraphs: _paragraphs(rawText),
      remoteImageUrl: _optionalText(map['image']),
    );
  }

  List<String> _paragraphs(String rawText) {
    return rawText
        .split(RegExp(r'\n\s*\n'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String? _optionalText(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
