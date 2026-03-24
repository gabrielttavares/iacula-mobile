import 'dart:typed_data';

abstract interface class NativeShareService {
  Future<void> shareText(String text);

  Future<void> shareTextWithImage({
    required String text,
    required Uint8List imageBytes,
    String fileName,
  });
}
