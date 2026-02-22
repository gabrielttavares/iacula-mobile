import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgia_diaria/application/use_cases/get_liturgy_period_use_case.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/entities/daily_liturgy.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/repositories/liturgia_repository.dart';

final class _FakeLiturgiaRepository implements LiturgiaRepository {
  _FakeLiturgiaRepository(this.value);

  final List<LiturgyDay> value;
  int periodCalls = 0;
  int? requestedDays;

  @override
  Future<LiturgyDay?> getLiturgyForDate(DateTime date) async {
    if (value.isEmpty) return null;
    return value.first;
  }

  @override
  Future<List<LiturgyDay>> getLiturgyPeriod(int days) async {
    periodCalls++;
    requestedDays = days;
    return value;
  }
}

void main() {
  test('delegates to repository and clamps period to API max 7 days', () async {
    final repo = _FakeLiturgiaRepository([
      LiturgyDay(
        date: DateTime(2026, 2, 22),
        title: 'Domingo',
        color: LiturgyColor.green,
        prayers: const LiturgyPrayer(collect: '', offering: '', communion: ''),
        readings: const <LiturgyReading>[],
        antiphons: const LiturgyAntiphons(),
      ),
    ]);

    final useCase = GetLiturgyPeriodUseCase(repo);
    final result = await useCase.call(days: 30);

    expect(result, hasLength(1));
    expect(repo.periodCalls, 1);
    expect(repo.requestedDays, 7);
  });
}
