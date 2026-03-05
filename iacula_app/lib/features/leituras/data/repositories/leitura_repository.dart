import '../models/book_model.dart';
import '../models/chapter_model.dart';
import '../sources/leitura_local_source.dart';

final class LeituraRepository {
  LeituraRepository({LeituraLocalSource? localSource})
    : _localSource = localSource ?? LeituraLocalSource();

  final LeituraLocalSource _localSource;

  List<BookModel>? _indexCache;
  final Map<String, BookModel> _bookCache = <String, BookModel>{};

  Future<List<BookModel>> listBooks() async {
    if (_indexCache != null) {
      return _indexCache!;
    }

    final payload = await _localSource.loadIndex();
    final books = (payload['books'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(BookModel.fromIndexJson)
        .where((book) => book.id.isNotEmpty && book.assetPath.isNotEmpty)
        .toList(growable: false);

    _indexCache = books;
    return books;
  }

  Future<BookModel?> getBook(String id) async {
    if (_bookCache.containsKey(id)) {
      return _bookCache[id];
    }

    final books = await listBooks();
    final summary = books.where((book) => book.id == id).firstOrNull;
    if (summary == null) {
      return null;
    }

    final payload = await _localSource.loadBook(summary.assetPath);
    final chapters =
        (payload['chapters'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(ChapterModel.fromJson)
            .toList(growable: false);

    final hydrated = summary.copyWith(chapters: chapters);
    _bookCache[id] = hydrated;
    return hydrated;
  }

  Future<ChapterModel?> getChapter({
    required String bookId,
    required String chapterSlug,
  }) async {
    final book = await getBook(bookId);
    if (book == null) {
      return null;
    }

    return book.chapters
        .where((chapter) => chapter.slug == chapterSlug)
        .firstOrNull;
  }
}
