import '../../domain/entities/quote_indices.dart';
import '../../domain/repositories/quote_indices_repository.dart';

final class InMemoryQuoteIndicesRepository implements QuoteIndicesRepository {
  QuoteIndices _indices = QuoteIndices.empty();

  @override
  Future<QuoteIndices> load({required int dayOfWeek}) async => _indices;

  @override
  Future<void> save(QuoteIndices indices) async {
    _indices = indices;
  }
}
