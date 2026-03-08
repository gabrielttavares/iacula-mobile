import 'dart:convert';

import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../../domain/entities/meditation_item.dart';

final class RemoteMeditationReaderService {
  const RemoteMeditationReaderService({required http.Client httpClient})
    : _httpClient = httpClient;

  final http.Client _httpClient;

  Future<MeditationTextContent?> load(MeditationItem item) async {
    if (item.type != MeditationType.text || item.sourceUrl == null) {
      return null;
    }

    final response = await _httpClient.get(Uri.parse(item.sourceUrl!));
    if (response.statusCode < 200 || response.statusCode >= 300) return null;

    return parse(item, response.body);
  }

  MeditationTextContent? parse(MeditationItem item, String rawBody) {
    return switch (item.provenance.providerId) {
      'hablar-con-dios' => _parseHablar(rawBody),
      'ibreviary' => _parseIBreviary(rawBody),
      'meditatione' => _parseMeditatione(rawBody),
      _ => null,
    };
  }

  MeditationTextContent? _parseHablar(String rawBody) {
    final document = html_parser.parse(rawBody);
    final root = document.querySelector('.entry-content');
    if (root == null) return null;

    for (final selector in ['figure', 'script', 'style', 'noscript']) {
      root.querySelectorAll(selector).forEach((element) => element.remove());
    }

    final paragraphs = root
        .querySelectorAll('p')
        .map((p) => _normalizeText(_htmlToText(p.innerHtml)))
        .where((text) => text.isNotEmpty)
        .toList(growable: false);

    if (paragraphs.isEmpty) return null;

    return MeditationTextContent(
      body: paragraphs.join('\n\n'),
      format: 'plain',
      language: 'pt',
      sections: const [],
    );
  }

  MeditationTextContent? _parseIBreviary(String rawBody) {
    final document = html_parser.parse(rawBody);
    final root = document.querySelector('#contenuto .inner');
    if (root == null) return null;

    var contentHtml = root.innerHtml;
    final start = contentHtml.indexOf('READINGS');
    if (start != -1) {
      contentHtml = contentHtml.substring(start);
    }

    final end = contentHtml.indexOf('******');
    if (end != -1) {
      contentHtml = contentHtml.substring(0, end);
    }

    final text = _normalizeText(_htmlToText(contentHtml));
    if (text.isEmpty) return null;

    final sections = _splitByHeadings(text, const [
      'FIRST READING',
      'SECOND READING',
      'CONCLUDING PRAYER',
      'ACCLAMATION',
    ]);

    return MeditationTextContent(
      body: text,
      format: 'plain',
      language: 'en',
      sections: sections,
    );
  }

  MeditationTextContent? _parseMeditatione(String rawBody) {
    final match = RegExp(
      r'<script id="__NEXT_DATA__" type="application/json">(.*?)</script>',
      dotAll: true,
    ).firstMatch(rawBody);
    if (match == null) return null;

    final decoded = jsonDecode(match.group(1)!) as Map<String, dynamic>;
    final props = decoded['props'] as Map<String, dynamic>?;
    final pageProps = props?['pageProps'] as Map<String, dynamic>?;
    final meditations = pageProps?['meditationsExt'] as List<dynamic>?;
    if (meditations == null || meditations.isEmpty) return null;

    final sections = <MeditationTextSection>[];
    for (final entry in meditations.cast<Map<String, dynamic>>()) {
      final meditation = entry['meditation'] as Map<String, dynamic>?;
      final book = entry['book'] as Map<String, dynamic>?;
      final author = entry['author'] as Map<String, dynamic>?;
      if (meditation == null || book == null) continue;
      if ((book['language'] as String?) != 'pt') continue;

      final title = (meditation['title'] as String?)?.trim();
      if (title == null || title.isEmpty) continue;

      final subtitle = (meditation['subTitle'] as String?)?.trim();
      final bodyParts = <String>[
        if (subtitle != null && subtitle.isNotEmpty) subtitle,
        if ((author?['name'] as String?)?.isNotEmpty ?? false)
          'Autor: ${author!['name']}',
        if ((book['shortDescription'] as String?)?.isNotEmpty ?? false)
          book['shortDescription'] as String,
        if ((book['text'] as String?)?.isNotEmpty ?? false)
          _stripMarkdown(book['text'] as String),
      ];

      sections.add(
        MeditationTextSection(
          heading: title,
          body: _normalizeText(bodyParts.join('\n\n')),
        ),
      );
    }

    if (sections.isEmpty) return null;

    return MeditationTextContent(
      body: sections
          .map((section) => '${section.heading}\n${section.body}')
          .join('\n\n'),
      format: 'plain',
      language: 'pt',
      sections: sections,
    );
  }

  List<MeditationTextSection> _splitByHeadings(
    String text,
    List<String> headings,
  ) {
    final sections = <MeditationTextSection>[];
    String? currentHeading;
    var buffer = StringBuffer();

    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        if (buffer.isNotEmpty) buffer.writeln();
        continue;
      }

      if (headings.contains(trimmed)) {
        if (currentHeading != null && buffer.isNotEmpty) {
          sections.add(
            MeditationTextSection(
              heading: currentHeading,
              body: _normalizeText(buffer.toString()),
            ),
          );
          buffer = StringBuffer();
        }
        currentHeading = trimmed;
        continue;
      }

      buffer.writeln(trimmed);
    }

    if (currentHeading != null && buffer.isNotEmpty) {
      sections.add(
        MeditationTextSection(
          heading: currentHeading,
          body: _normalizeText(buffer.toString()),
        ),
      );
    }

    return sections;
  }

  String _htmlToText(String html) {
    final withBreaks = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');

    final fragment = html_parser.parseFragment(withBreaks);
    return fragment.text ?? '';
  }

  String _normalizeText(String text) {
    return text
        .replaceAll('\u00a0', ' ')
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
  }

  String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\[(.*?)\]\((.*?)\)'), r'$1')
        .replaceAll('*', '')
        .replaceAll('_', '')
        .trim();
  }
}
