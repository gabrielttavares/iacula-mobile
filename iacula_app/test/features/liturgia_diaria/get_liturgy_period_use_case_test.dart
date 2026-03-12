import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/liturgia_diaria/application/use_cases/get_liturgy_period_use_case.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/entities/daily_liturgy.dart';
import 'package:iacula_app/features/liturgia_diaria/domain/repositories/liturgia_repository.dart';

final class _FakeLiturgiaRepository implements LiturgiaRepository {
  _FakeLiturgiaRepository(this.value, {Map<String, LiturgyDay>? byDate})
    : _byDate = byDate ?? <String, LiturgyDay>{};

  final List<LiturgyDay> value;
  final Map<String, LiturgyDay> _byDate;
  int periodCalls = 0;
  int? requestedDays;
  final List<DateTime> requestedDates = <DateTime>[];

  @override
  Future<LiturgyDay?> getLiturgyForDate(DateTime date) async {
    requestedDates.add(DateTime(date.year, date.month, date.day));
    return _byDate[_dateKey(date)];
  }

  @override
  Future<List<LiturgyDay>> getLiturgyPeriod(int days) async {
    periodCalls++;
    requestedDays = days;
    return value;
  }

  String _dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return '${normalized.year}-${normalized.month}-${normalized.day}';
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

  test('anchorDate fetches a centered distinct 7-day window around the anchor', () async {
    final byDate = <String, LiturgyDay>{};
    for (var day = 9; day <= 15; day++) {
      final date = DateTime(2026, 3, day);
      byDate['${date.year}-${date.month}-${date.day}'] = LiturgyDay(
        date: date,
        title: 'Dia $day',
        color: LiturgyColor.purple,
        prayers: const LiturgyPrayer(collect: '', offering: '', communion: ''),
        readings: const <LiturgyReading>[],
        antiphons: const LiturgyAntiphons(),
      );
    }
    final repo = _FakeLiturgiaRepository(const <LiturgyDay>[], byDate: byDate);
    final useCase = GetLiturgyPeriodUseCase(repo);

    final result = await useCase.call(days: 7, anchorDate: DateTime(2026, 3, 12));

    expect(repo.periodCalls, 0);
    expect(
      repo.requestedDates,
      [
        DateTime(2026, 3, 9),
        DateTime(2026, 3, 10),
        DateTime(2026, 3, 11),
        DateTime(2026, 3, 12),
        DateTime(2026, 3, 13),
        DateTime(2026, 3, 14),
        DateTime(2026, 3, 15),
      ],
    );
    expect(result.map((day) => day.date).toList(), repo.requestedDates);
    expect(result.map((day) => day.title).toList(), [
      'Dia 9',
      'Dia 10',
      'Dia 11',
      'Dia 12',
      'Dia 13',
      'Dia 14',
      'Dia 15',
    ]);
  });
}
