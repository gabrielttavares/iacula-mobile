import '../entities/saint_of_day.dart';

abstract interface class SaintRepository {
  Future<SaintOfDay?> getSaintForDate(DateTime date);
}
