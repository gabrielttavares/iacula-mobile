import '../entities/quote_indices.dart';

abstract interface class QuoteIndicesRepository {
  Future<QuoteIndices> load({required int dayOfWeek});
  Future<void> save(QuoteIndices indices);
}
