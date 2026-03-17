import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/entities/bible_book.dart';

class BiblePrefs {
  const BiblePrefs({
    required this.testament,
    this.lastBookAbbrev,
    this.lastChapterNumber,
  });

  final BibleTestament testament;
  final String? lastBookAbbrev;
  final int? lastChapterNumber;

  BiblePrefs copyWith({
    BibleTestament? testament,
    String? lastBookAbbrev,
    int? lastChapterNumber,
    bool clearLastBook = false,
  }) {
    return BiblePrefs(
      testament: testament ?? this.testament,
      lastBookAbbrev: clearLastBook ? null : (lastBookAbbrev ?? this.lastBookAbbrev),
      lastChapterNumber: clearLastBook ? null : (lastChapterNumber ?? this.lastChapterNumber),
    );
  }
}

class BiblePrefsNotifier extends StateNotifier<BiblePrefs> {
  BiblePrefsNotifier({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        super(const BiblePrefs(testament: BibleTestament.novo)) {
    _load();
  }

  final FlutterSecureStorage _storage;

  static const _testamentKey = 'bible_testament';
  static const _lastBookKey = 'bible_last_book';
  static const _lastChapterKey = 'bible_last_chapter';

  Future<void> _load() async {
    final testamentStr = await _storage.read(key: _testamentKey);
    final lastBook = await _storage.read(key: _lastBookKey);
    final lastChapterStr = await _storage.read(key: _lastChapterKey);

    final testament = testamentStr == 'antigo'
        ? BibleTestament.antigo
        : BibleTestament.novo;
    final lastChapter = int.tryParse(lastChapterStr ?? '');

    state = BiblePrefs(
      testament: testament,
      lastBookAbbrev: lastBook,
      lastChapterNumber: lastChapter,
    );
  }

  Future<void> setTestament(BibleTestament testament) async {
    state = state.copyWith(testament: testament);
    await _storage.write(
      key: _testamentKey,
      value: testament == BibleTestament.antigo ? 'antigo' : 'novo',
    );
  }

  Future<void> savePosition(String bookAbbrev, int chapterNumber) async {
    state = state.copyWith(
      lastBookAbbrev: bookAbbrev,
      lastChapterNumber: chapterNumber,
    );
    await _storage.write(key: _lastBookKey, value: bookAbbrev);
    await _storage.write(key: _lastChapterKey, value: chapterNumber.toString());
  }
}
