import '../../domain/entities/doctrine_entry.dart';
import '../../domain/repositories/doctrine_repository.dart';

final class GetDoctrineCatalogUseCase {
  const GetDoctrineCatalogUseCase({required DoctrineRepository repository})
    : _repository = repository;

  final DoctrineRepository _repository;

  Future<List<DoctrineEntry>> listAll({required String language}) {
    return _repository.listCatalog(language: language);
  }

  Future<List<DoctrineEntry>> byCategory({
    required String language,
    required String category,
  }) async {
    final catalog = await listAll(language: language);
    return catalog
        .where((entry) => entry.category == category)
        .toList(growable: false);
  }
}
