import '../../domain/entities/quote_indices.dart';
import '../../domain/repositories/quote_indices_repository.dart';
import '../../domain/services/quote_selector.dart';

final class InMemoryQuoteIndicesRepository implements QuoteIndicesRepository {
  QuoteIndices _indices = QuoteIndices.empty(DateTime.now().weekday % 7 + 1);

  @override
  Future<QuoteIndices> load({required int dayOfWeek}) async {
    _indices = QuoteSelector.ensureCurrentDay(_indices, dayOfWeek);
    return _indices;
  }

  @override
  Future<void> save(QuoteIndices indices) async {
    _indices = indices;
  }
}
