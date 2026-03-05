import 'dart:convert';

import 'package:flutter/services.dart';

typedef LeituraAssetLoader = Future<String> Function(String path);

class LeituraLocalSource {
  LeituraLocalSource({LeituraAssetLoader? loadAsset})
    : loadAsset = loadAsset ?? rootBundle.loadString;

  final LeituraAssetLoader loadAsset;

  Future<Map<String, dynamic>> loadIndex() async {
    final raw = await loadAsset('assets/books/escriva/index.json');
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return const <String, dynamic>{};
  }

  Future<Map<String, dynamic>> loadBook(String assetPath) async {
    final raw = await loadAsset(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return const <String, dynamic>{};
  }
}
