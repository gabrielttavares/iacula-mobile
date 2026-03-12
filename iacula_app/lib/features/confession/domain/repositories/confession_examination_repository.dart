import '../entities/confession_examination_item.dart';

abstract interface class ConfessionExaminationRepository {
  Future<List<ConfessionExaminationItem>> listAll();
}
