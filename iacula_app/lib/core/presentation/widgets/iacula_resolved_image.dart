import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../config/app_env.dart';

class IaculaResolvedImage extends StatefulWidget {
  const IaculaResolvedImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  final String? source;
  final BoxFit fit;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  @override
  State<IaculaResolvedImage> createState() => _IaculaResolvedImageState();
}

class _IaculaResolvedImageState extends State<IaculaResolvedImage> {
  String? _resolvedSource;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant IaculaResolvedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final source = await IaculaImageResolver.resolve(widget.source);
    if (!mounted) return;
    setState(() {
      _resolvedSource = source;
    });
  }

  @override
  Widget build(BuildContext context) {
    final source = _resolvedSource;
    if (source == null || source.isEmpty) {
      return const SizedBox.shrink();
    }

    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorBuilder?.call(context, error) ??
              const SizedBox.shrink();
        },
      );
    }

    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorBuilder?.call(context, error) ??
              const SizedBox.shrink();
        },
      );
    }

    return Image.file(
      File(source),
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return widget.errorBuilder?.call(context, error) ??
            const SizedBox.shrink();
      },
    );
  }
}

final class IaculaImageResolver {
  const IaculaImageResolver._();

  static Future<Set<String>>? _assetSetFuture;

  static Future<String?> resolve(String? rawSource) async {
    final source = rawSource?.trim();
    if (source == null || source.isEmpty) {
      return null;
    }

    if (source.startsWith('assets/')) {
      final exists = await _assetExists(source);
      if (exists) {
        return source;
      }
      final fallback = await _resolveSupabaseKey(
        _assetPathToStorageKey(source),
      );
      return fallback ?? source;
    }

    if (_looksLikeAbsolutePath(source)) {
      return source;
    }

    if (_isHttpUrl(source)) {
      final cached = await _downloadAndCache(source);
      return cached ?? source;
    }

    final env = AppEnv.fromDartDefines();
    if (env.supabaseUrl == null || env.supabaseUrl!.isEmpty) {
      return source;
    }

    final fallback = await _resolveSupabaseKey(source);
    return fallback ?? source;
  }

  static bool _isHttpUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  static bool _looksLikeAbsolutePath(String value) {
    if (value.startsWith('/')) return true;
    return RegExp(r'^[a-zA-Z]:\\').hasMatch(value);
  }

  static Future<String?> _downloadAndCache(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }

    final file = await _cacheFileFor(uri);
    if (await file.exists()) {
      return file.path;
    }

    try {
      final client = HttpClient();
      final req = await client.getUrl(uri);
      final resp = await req.close();
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        client.close();
        return null;
      }
      final bytes = await consolidateHttpClientResponseBytes(resp);
      client.close();
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  static Future<File> _cacheFileFor(Uri uri) async {
    final dbPath = await getDatabasesPath();
    final cacheDir = Directory(p.join(dbPath, 'image_cache'));
    final ext = p.extension(uri.path).toLowerCase();
    final safeExt = ext.isEmpty ? '.img' : ext;
    final key = _fnv1a64(uri.toString());
    return File(p.join(cacheDir.path, '$key$safeExt'));
  }

  static Future<String?> _resolveSupabaseKey(String? rawKey) async {
    final key = rawKey?.trim();
    if (key == null || key.isEmpty) {
      return null;
    }
    final env = AppEnv.fromDartDefines();
    if (env.supabaseUrl == null || env.supabaseUrl!.isEmpty) {
      return null;
    }

    final normalized = key
        .replaceFirst(RegExp(r'^/+'), '')
        .replaceFirst(RegExp(r'^iacula_images/+'), '');
    if (normalized.isEmpty) {
      return null;
    }

    final encodedKey = normalized.split('/').map(Uri.encodeComponent).join('/');
    final publicUrl =
        '${env.supabaseUrl}/storage/v1/object/public/iacula_images/$encodedKey';
    final cached = await _downloadAndCache(publicUrl);
    return cached ?? publicUrl;
  }

  static String _assetPathToStorageKey(String assetPath) {
    return assetPath
        .replaceFirst(RegExp(r'^assets/seed/images/+'), '')
        .replaceFirst(RegExp(r'^/+'), '');
  }

  static Future<bool> _assetExists(String assetPath) async {
    _assetSetFuture ??= _loadAssetSet();
    final assetSet = await _assetSetFuture!;
    return assetSet.contains(assetPath);
  }

  static Future<Set<String>> _loadAssetSet() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest.listAssets().toSet();
  }

  static String _fnv1a64(String input) {
    var hash = 0xcbf29ce484222325;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }
}
