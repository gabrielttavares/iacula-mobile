import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/services/native_share_service.dart';

final class SharePlusNativeShareService implements NativeShareService {
  const SharePlusNativeShareService();

  static const Rect _defaultShareOrigin = Rect.fromLTWH(0, 0, 1, 1);

  @visibleForTesting
  ShareParams buildShareParams(String text) {
    return ShareParams(
      text: text.trim(),
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
      text: text.trim(),
      files: [XFile.fromData(imageBytes, mimeType: 'image/png')],
      fileNameOverrides: [fileName],
      sharePositionOrigin: _defaultShareOrigin,
    );
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
