import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/confession/infrastructure/services/share_plus_native_share_service.dart';

void main() {
  test('buildShareParams sets a non-zero sharePositionOrigin', () {
    const service = SharePlusNativeShareService();

    final params = service.buildShareParams('Test share text');

    final origin = params.sharePositionOrigin;
    expect(origin, isNotNull);
    expect(origin!.width, greaterThan(0));
    expect(origin.height, greaterThan(0));
  });

  test('buildShareParams appends canonical app url in text and omits uri', () {
    const service = SharePlusNativeShareService();

    final params = service.buildShareParams('Test share text');

    expect(params.uri, isNull);
    expect(params.text, contains('https://iacula.app'));
  });

  test('buildImageShareParams includes image file and non-zero origin', () {
    const service = SharePlusNativeShareService();

    final params = service.buildImageShareParams(
      text: 'Test share text',
      imageBytes: Uint8List.fromList(const [1, 2, 3]),
    );

    expect(params.files, hasLength(1));
    expect(params.fileNameOverrides, hasLength(1));
    expect(params.uri, isNull);
    expect(params.text, contains('https://iacula.app'));
    final origin = params.sharePositionOrigin;
    expect(origin, isNotNull);
    expect(origin!.width, greaterThan(0));
    expect(origin.height, greaterThan(0));
  });
}
