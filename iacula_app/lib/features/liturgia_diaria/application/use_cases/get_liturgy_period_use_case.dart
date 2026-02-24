import '../../domain/entities/daily_liturgy.dart';
import '../../domain/repositories/liturgia_repository.dart';

final class GetLiturgyPeriodUseCase {
  const GetLiturgyPeriodUseCase(this._repository);

  final LiturgiaRepository _repository;

  Future<List<LiturgyDay>> call({int days = 7, DateTime? anchorDate}) async {
    final safeDays = days.clamp(1, 7);
    if (anchorDate == null) {
      return _repository.getLiturgyPeriod(safeDays);
    }

    final normalizedAnchor = DateTime(
      anchorDate.year,
      anchorDate.month,
      anchorDate.day,
    );
    final start = normalizedAnchor.subtract(Duration(days: safeDays ~/ 2));

    final period = <LiturgyDay>[];
    for (var index = 0; index < safeDays; index++) {
      final date = start.add(Duration(days: index));
      final day = await _repository.getLiturgyForDate(date);
      if (day != null) {
        period.add(day);
      }
    }

    if (period.isEmpty) {
      return _repository.getLiturgyPeriod(safeDays);
    }

    period.sort((a, b) => a.date.compareTo(b.date));
    return period;
  }
}
