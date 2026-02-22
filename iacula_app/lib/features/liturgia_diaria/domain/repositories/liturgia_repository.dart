import '../entities/daily_liturgy.dart';

abstract interface class LiturgiaRepository {
  Future<LiturgyDay?> getLiturgyForDate(DateTime date);

  Future<List<LiturgyDay>> getLiturgyPeriod(int days);
}
