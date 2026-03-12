import '../entities/examination_reflection_item.dart';

abstract interface class ExaminationReflectionRepository {
  Future<List<ExaminationReflectionItem>> listAll();
  Stream<List<ExaminationReflectionItem>> watchAll();
  Future<void> seedDefaultsIfEmpty();
  Future<void> createItem({required String sectionTitle, required String text});
  Future<void> updateItem(ExaminationReflectionItem item);
  Future<void> deleteItem(String id);
}
