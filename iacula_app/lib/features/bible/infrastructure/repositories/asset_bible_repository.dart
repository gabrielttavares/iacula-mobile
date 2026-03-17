import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/bible_book.dart';
import '../../domain/entities/bible_verse.dart';
import '../../domain/repositories/bible_repository.dart';

typedef LoadBibleAsset = Future<String> Function(String path);

final class AssetBibleRepository implements BibleRepository {
  AssetBibleRepository({LoadBibleAsset? loadAsset})
    : _loadAsset = loadAsset ?? rootBundle.loadString;

  final LoadBibleAsset _loadAsset;
  List<BibleBook>? _booksCache;
  final Map<String, Map<String, dynamic>> _bookPayloadCache = {};

  @override
  Future<List<BibleBook>> listBooks() async {
    if (_booksCache != null) return _booksCache!;

    final raw = await _loadAsset('assets/seed/bible/listalivros.json');
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      _booksCache = const [];
      return _booksCache!;
    }

    _booksCache = [
      for (var i = 0; i < decoded.length; i++)
        _bookFromJson(decoded[i] as Map<String, dynamic>, i),
    ];
    return _booksCache!;
  }

  @override
  Future<List<BibleVerse>> getChapter({
    required String bookAbbrev,
    required int chapterNumber,
  }) async {
    if (chapterNumber < 1) return const [];
    final payload = await _loadBookPayload(bookAbbrev);
    if (payload == null) return const [];

    final chapters = payload['capitulos'];
    if (chapters is! List) return const [];

    for (final chapter in chapters) {
      if (chapter is! Map<String, dynamic>) continue;
      final number = _readInt(chapter['capitulo']);
      if (number != chapterNumber) continue;

      final verses = chapter['versiculos'];
      if (verses is! List) return const [];
      return [
        for (final verse in verses)
          if (verse is Map<String, dynamic>)
            BibleVerse(
              number: _readInt(verse['numero']) ?? 0,
              text: _sanitizeVerseText((verse['texto'] as String?) ?? ''),
            ),
      ];
    }

    return const [];
  }

  BibleBook _bookFromJson(Map<String, dynamic> json, int order) {
    final abbrev = (json['livro'] as String? ?? '').trim();
    return BibleBook(
      abbrev: abbrev,
      chapterCount: _readInt(json['quantidadeCap']) ?? 0,
      name: _bookLabelForAbbrev(abbrev),
      order: order,
      testament: _ntAbbrevs.contains(abbrev.toLowerCase())
          ? BibleTestament.novo
          : BibleTestament.antigo,
    );
  }

  Future<Map<String, dynamic>?> _loadBookPayload(String bookAbbrev) async {
    final normalized = bookAbbrev.trim().toLowerCase();
    if (_bookPayloadCache.containsKey(normalized)) {
      return _bookPayloadCache[normalized];
    }

    final oldPath = 'assets/seed/bible/antigotestamento/$normalized.json';
    final newPath = 'assets/seed/bible/novotestamento/$normalized.json';

    try {
      final raw = await _loadAsset(oldPath);
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _bookPayloadCache[normalized] = decoded;
        return decoded;
      }
    } catch (_) {}

    try {
      final raw = await _loadAsset(newPath);
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _bookPayloadCache[normalized] = decoded;
        return decoded;
      }
    } catch (_) {}

    return null;
  }

  int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _sanitizeVerseText(String input) {
    return input.replaceFirst(RegExp(r'^\[\d+\]\s*'), '').trim();
  }
}

const Map<String, String> _bookLabels = {
  'gn': 'Gênesis',
  'ex': 'Êxodo',
  'lv': 'Levítico',
  'nm': 'Números',
  'dt': 'Deuteronômio',
  'js': 'Josué',
  'ju': 'Juízes',
  'rt': 'Rute',
  '1sm': '1 Samuel',
  '2sm': '2 Samuel',
  '1rs': '1 Reis',
  '2rs': '2 Reis',
  '1pa': '1 Crônicas',
  '2pa': '2 Crônicas',
  'esd': 'Esdras',
  'ne': 'Neemias',
  'tob': 'Tobias',
  'jdi': 'Judite',
  'est': 'Ester',
  'job': 'Jó',
  'ps': 'Salmos',
  'pv': 'Provérbios',
  'ees': 'Eclesiastes',
  'cc': 'Cântico dos Cânticos',
  'sa': 'Sabedoria',
  'eus': 'Eclesiástico',
  'is': 'Isaías',
  'je': 'Jeremias',
  'lm': 'Lamentações',
  'ba': 'Baruc',
  'ez': 'Ezequiel',
  'dn': 'Daniel',
  'os': 'Oseias',
  'jl': 'Joel',
  'am': 'Amós',
  'ab': 'Abdias',
  'jn': 'Jonas',
  'mic': 'Miqueias',
  'na': 'Naum',
  'hc': 'Habacuc',
  'so': 'Sofonias',
  'ag': 'Ageu',
  'zc': 'Zacarias',
  'ml': 'Malaquias',
  '1ma': '1 Macabeus',
  '2ma': '2 Macabeus',
  'mt': 'Mateus',
  'mc': 'Marcos',
  'lc': 'Lucas',
  'jo': 'João',
  'act': 'Atos dos Apóstolos',
  'rm': 'Romanos',
  '1co': '1 Coríntios',
  '2co': '2 Coríntios',
  'gl': 'Gálatas',
  'ef': 'Efésios',
  'fp': 'Filipenses',
  'cl': 'Colossenses',
  '1ts': '1 Tessalonicenses',
  '2ts': '2 Tessalonicenses',
  '1tm': '1 Timóteo',
  '2tm': '2 Timóteo',
  'tt': 'Tito',
  'fm': 'Filemom',
  'hb': 'Hebreus',
  'tg': 'Tiago',
  '1pe': '1 Pedro',
  '2pe': '2 Pedro',
  '1jo': '1 João',
  '2jo': '2 João',
  '3jo': '3 João',
  'jda': 'Judas',
  'ap': 'Apocalipse',
};

String _bookLabelForAbbrev(String abbrev) {
  final key = abbrev.toLowerCase();
  return _bookLabels[key] ?? abbrev;
}

const _ntAbbrevs = {
  'mt',
  'mc',
  'lc',
  'jo',
  'act',
  'rm',
  '1co',
  '2co',
  'gl',
  'ef',
  'fp',
  'cl',
  '1ts',
  '2ts',
  '1tm',
  '2tm',
  'tt',
  'fm',
  'hb',
  'tg',
  '1pe',
  '2pe',
  '1jo',
  '2jo',
  '3jo',
  'jda',
  'ap',
};
