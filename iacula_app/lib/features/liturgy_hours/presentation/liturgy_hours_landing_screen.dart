import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../liturgical/domain/liturgical_season.dart';
import '../../liturgia_diaria/domain/entities/saint_of_day.dart';
import '../../liturgia_diaria/domain/entities/saint_of_day_fallback.dart';
import '../../premium/domain/entities/premium_feature.dart';
import '../../premium/presentation/premium_gate.dart';
import '../domain/entities/liturgical_hour.dart';
import '../infrastructure/repositories/asset_liturgy_hours_repository.dart';
import 'hour_prayer_screen.dart';

final _liturgyHoursRepository = AssetLiturgyHoursRepository();

final _liturgicalSeasonProvider = FutureProvider<LiturgicalSeason>((ref) async {
  return ref.watch(liturgicalSeasonServiceProvider).getCurrentSeason();
});

final _saintOfDayProvider = FutureProvider<SaintOfDay?>((ref) async {
  return ref.watch(saintRepositoryProvider).getSaintForDate(DateTime.now());
});

class LiturgyHoursLandingScreen extends ConsumerWidget {
  const LiturgyHoursLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final todayStr =
        '${_weekday(now.weekday)}, ${now.day} de ${_month(now.month)}';
    final seasonAsync = ref.watch(_liturgicalSeasonProvider);
    final saintAsync = ref.watch(_saintOfDayProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.colors.background,
        border: null,
        middle: Text('Liturgia das Horas', style: context.textStyles.cardTitle),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date header
              IaculaSoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(todayStr, style: context.textStyles.sectionTitle),
                    const SizedBox(height: 4),
                    Text(
                      seasonAsync.maybeWhen(
                        data: _seasonLabel,
                        orElse: () => 'Carregando tempo litúrgico...',
                      ),
                      style: context.textStyles.secondary,
                    ),
                    saintAsync.maybeWhen(
                      data: (saint) => Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _SaintOfDaySummary(
                          saint: saintOfDayOrFallback(saint, date: now),
                        ),
                      ),
                      orElse: SizedBox.shrink,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IaculaSpacing.lg),

              // Available hours
              ...LiturgicalHourType.values.map((hourType) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: IaculaSpacing.sm),
                  child: _HourCard(hourType: hourType),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaintOfDaySummary extends StatelessWidget {
  const _SaintOfDaySummary({required this.saint});

  final SaintOfDay saint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(saint.name, style: context.textStyles.cardTitle),
        const SizedBox(height: 4),
        Text(
          saint.biographyParagraphs.firstOrNull ?? '',
          style: context.textStyles.secondary,
        ),
      ],
    );
  }
}

String _seasonLabel(LiturgicalSeason season) {
  return switch (season) {
    LiturgicalSeason.ordinary => 'Tempo Comum',
    LiturgicalSeason.advent => 'Tempo do Advento',
    LiturgicalSeason.lent => 'Tempo da Quaresma',
    LiturgicalSeason.easter => 'Tempo Pascal',
    LiturgicalSeason.christmas => 'Tempo do Natal',
  };
}

class _HourCard extends ConsumerWidget {
  const _HourCard({required this.hourType});

  final LiturgicalHourType hourType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () async {
        final isPremium =
            ref.read(premiumStatusProvider).valueOrNull?.isPremium ?? true;
        if (!isPremium) {
          PremiumGate.showModal(
            context,
            feature: PremiumFeature.liturgyOfHours,
          );
          return;
        }

        HapticFeedback.lightImpact();
        final hour = await _liturgyHoursRepository.getHour(
          type: hourType,
          date: DateTime.now(),
        );

        if (hour != null && context.mounted) {
          Navigator.of(context).push(
            CupertinoPageRoute(builder: (_) => HourPrayerScreen(hour: hour)),
          );
        }
      },
      child: IaculaSoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colors.primaryButton.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.book,
                  color: context.colors.primaryButton,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hourType.label,
                    style: context.textStyles.cardTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hourType.timeHint,
                    style: context.textStyles.secondary.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.chevron_right,
              color: context.colors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

String _weekday(int day) => switch (day) {
  1 => 'Segunda-feira',
  2 => 'Terça-feira',
  3 => 'Quarta-feira',
  4 => 'Quinta-feira',
  5 => 'Sexta-feira',
  6 => 'Sábado',
  7 => 'Domingo',
  _ => '',
};

String _month(int m) => switch (m) {
  1 => 'janeiro',
  2 => 'fevereiro',
  3 => 'março',
  4 => 'abril',
  5 => 'maio',
  6 => 'junho',
  7 => 'julho',
  8 => 'agosto',
  9 => 'setembro',
  10 => 'outubro',
  11 => 'novembro',
  12 => 'dezembro',
  _ => '',
};
