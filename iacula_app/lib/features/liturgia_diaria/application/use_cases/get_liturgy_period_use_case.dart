import '../../domain/entities/daily_liturgy.dart';
import '../../domain/repositories/liturgia_repository.dart';

final class GetLiturgyPeriodUseCase {
  const GetLiturgyPeriodUseCase(this._repository);

  final LiturgiaRepository _repository;

  Future<List<LiturgyDay>> call({int days = 7}) {
    final safeDays = days.clamp(1, 7);
    return _repository.getLiturgyPeriod(safeDays);
  }
}
