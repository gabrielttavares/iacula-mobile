import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/services/native_share_service.dart';

final class SharePlusNativeShareService implements NativeShareService {
  const SharePlusNativeShareService();

  static const Rect _defaultShareOrigin = Rect.fromLTWH(0, 0, 1, 1);
  static const String _appUrl = 'https://iacula.app';

  @visibleForTesting
  ShareParams buildShareParams(String text) {
    final sharedText = _appendAppUrl(text);

    return ShareParams(
      text: sharedText,
      sharePositionOrigin: _defaultShareOrigin,
    );
  }

  @visibleForTesting
  ShareParams buildImageShareParams({
    required String text,
    required Uint8List imageBytes,
    String fileName = 'iacula-share-card.png',
  }) {
    return ShareParams(
      text: _appendAppUrl(text),
      files: [XFile.fromData(imageBytes, mimeType: 'image/png')],
      fileNameOverrides: [fileName],
      sharePositionOrigin: _defaultShareOrigin,
    );
  }

  String _appendAppUrl(String text) {
    final normalizedText = text.trim();
    return normalizedText.contains(_appUrl)
        ? normalizedText
        : '$normalizedText\n\n$_appUrl';
  }

  @override
  Future<void> shareText(String text) {
    return SharePlus.instance.share(buildShareParams(text));
  }

  @override
  Future<void> shareTextWithImage({
    required String text,
    required Uint8List imageBytes,
    String fileName = 'iacula-share-card.png',
  }) async {
    try {
      await SharePlus.instance.share(
        buildImageShareParams(
          text: text,
          imageBytes: imageBytes,
          fileName: fileName,
        ),
      );
    } catch (_) {
      await shareText(text);
    }
  }
}
