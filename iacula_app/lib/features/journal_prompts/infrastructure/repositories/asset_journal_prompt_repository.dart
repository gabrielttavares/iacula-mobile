import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/journal_prompt.dart';
import '../../domain/repositories/journal_prompt_repository.dart';

final class AssetJournalPromptRepository implements JournalPromptRepository {
  AssetJournalPromptRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  List<JournalPrompt>? _cache;

  @override
  Future<List<JournalPrompt>> listAll() async {
    if (_cache != null) return _cache!;

    try {
      final raw = await _bundle.loadString(
        'assets/seed/journal_prompts/prompts.json',
      );
      final json = jsonDecode(raw) as Map<String, dynamic>;

      final prompts = <JournalPrompt>[];
      for (final entry in json.entries) {
        final category = JournalPromptCategoryX.fromAssetKey(entry.key);
        final items = (entry.value as List<dynamic>).cast<String>();
        for (var index = 0; index < items.length; index++) {
          prompts.add(
            JournalPrompt(
              id: '${entry.key}-$index',
              category: category,
              text: items[index],
            ),
          );
        }
      }

      _cache = prompts;
    } catch (_) {
      _cache = const [];
    }

    return _cache!;
  }
}
