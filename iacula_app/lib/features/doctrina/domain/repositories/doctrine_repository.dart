import '../entities/doctrine_entry.dart';

abstract interface class DoctrineRepository {
  Future<List<DoctrineEntry>> listCatalog({required String language});
}
