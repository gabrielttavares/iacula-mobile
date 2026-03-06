import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/saint_of_day.dart';

typedef ImageDirectoryProvider = Future<String> Function();
typedef SearchImageUrl = Future<String?> Function(String query);
typedef DownloadImage = Future<Uint8List?> Function(String url);
typedef FileExists = Future<bool> Function(String path);
typedef WriteFileBytes = Future<void> Function(String path, Uint8List bytes);

final class SaintImageResolver {
  SaintImageResolver({
    this.placeholderAssetPath = 'assets/placeholders/saint-placeholder.png',
    ImageDirectoryProvider? imageDirectoryProvider,
    SearchImageUrl? searchImageUrl,
    DownloadImage? downloadImage,
    FileExists? fileExists,
    WriteFileBytes? writeFileBytes,
    http.Client? httpClient,
  }) : _httpClient = httpClient,
       _imageDirectoryProvider =
           imageDirectoryProvider ?? _defaultImageDirectoryProvider,
       _searchImageUrl = searchImageUrl,
       _downloadImage = downloadImage,
       _fileExists = fileExists,
       _writeFileBytes = writeFileBytes;

  final String placeholderAssetPath;
  final ImageDirectoryProvider _imageDirectoryProvider;
  final SearchImageUrl? _searchImageUrl;
  final DownloadImage? _downloadImage;
  final FileExists? _fileExists;
  final WriteFileBytes? _writeFileBytes;
  final http.Client? _httpClient;

  static String slugify(String value) {
    const accents = <String, String>{
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
    };
    var normalized = value.trim().toLowerCase();
    accents.forEach((from, to) {
      normalized = normalized.replaceAll(from, to);
    });
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    normalized = normalized.replaceAll(RegExp(r'^-+|-+$'), '');
    return normalized;
  }

  Future<SaintOfDay> resolve(SaintOfDay saint) async {
    final directory = await _imageDirectoryProvider();
    final slug = slugify(saint.name);
    final localPath = p.join(directory, '$slug.jpg');

    if (await _exists(localPath)) {
      return saint.copyWith(localImagePath: localPath, imageAssetPath: null);
    }

    final remoteImageUrl =
        saint.remoteImageUrl ?? await _searchImage(saint.name);
    if (remoteImageUrl == null) {
      return saint.copyWith(
        localImagePath: null,
        imageAssetPath: placeholderAssetPath,
      );
    }

    final bytes = await _download(remoteImageUrl);
    if (bytes == null || bytes.isEmpty) {
      return saint.copyWith(
        localImagePath: null,
        imageAssetPath: placeholderAssetPath,
      );
    }

    await _write(localPath, bytes);
    return saint.copyWith(
      remoteImageUrl: saint.remoteImageUrl ?? remoteImageUrl,
      localImagePath: localPath,
      imageAssetPath: null,
    );
  }

  Future<String?> _searchImage(String saintName) async {
    if (_searchImageUrl != null) {
      return _searchImageUrl.call('$saintName catholic saint painting');
    }
    final client = _httpClient;
    if (client == null) return null;

    final uri = Uri.https('commons.wikimedia.org', '/w/api.php', {
      'action': 'query',
      'generator': 'search',
      'gsrnamespace': '6',
      'gsrsearch': '$saintName catholic saint painting',
      'prop': 'imageinfo',
      'iiprop': 'url',
      'format': 'json',
      'origin': '*',
    });
    try {
      final response = await client.get(uri);
      if (response.statusCode < 200 || response.statusCode > 299) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return null;
      final query = decoded['query'];
      if (query is! Map) return null;
      final pages = query['pages'];
      if (pages is! Map) return null;
      for (final value in pages.values) {
        if (value is! Map) continue;
        final imageInfo = value['imageinfo'];
        if (imageInfo is List && imageInfo.isNotEmpty) {
          final first = imageInfo.first;
          if (first is Map && first['url'] is String) {
            return first['url'] as String;
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> _download(String url) async {
    if (_downloadImage != null) return _downloadImage.call(url);
    final client = _httpClient;
    if (client == null) return null;
    try {
      final response = await client.get(Uri.parse(url));
      if (response.statusCode < 200 || response.statusCode > 299) return null;
      return response.bodyBytes;
    } catch (_) {
      return null;
    }
  }

  Future<bool> _exists(String path) async {
    if (_fileExists != null) return _fileExists.call(path);
    return File(path).exists();
  }

  Future<void> _write(String path, Uint8List bytes) async {
    if (_writeFileBytes != null) {
      return _writeFileBytes.call(path, bytes);
    }
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }

  static Future<String> _defaultImageDirectoryProvider() async {
    final directory = await getApplicationDocumentsDirectory();
    final saintsDir = Directory(p.join(directory.path, 'santos'));
    await saintsDir.create(recursive: true);
    return saintsDir.path;
  }
}
