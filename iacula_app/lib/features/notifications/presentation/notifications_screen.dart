import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../liturgical/domain/liturgical_season.dart';
import '../../settings/presentation/settings_screen.dart';
import '../application/use_cases/schedule_core_reminders_use_case.dart';
import '../application/use_cases/schedule_liturgy_reminders_use_case.dart';
import '../domain/entities/notification_history_entry.dart';

final _todayHistoryProvider = FutureProvider<List<NotificationHistoryEntry>>((
  ref,
) {
  final now = ref.watch(notificationHistoryNowProvider);
  return ref.watch(notificationHistoryRepositoryProvider).listForDay(now);
});

final _settingsProvider = FutureProvider((ref) {
  return ref.watch(getSettingsUseCaseProvider).call();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(_todayHistoryProvider);
    final now = ref.watch(notificationHistoryNowProvider);
    final settingsAsync = ref.watch(_settingsProvider);
    final permissionGranted = ref.watch(notificationPermissionProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Notificações'),
      ),
      child: SafeArea(
        child: settingsAsync.when(
          data: (settings) {
            return ListView(
              padding: EdgeInsets.fromLTRB(
                IaculaSpacing.md,
                IaculaSpacing.md,
                IaculaSpacing.md,
                IaculaSpacing.md + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                // -- STATUS --
                _NotificationStatusCard(
                  enabled: settings.notificationsEnabled,
                  permissionGranted: permissionGranted,
                  intervalMinutes: settings.intervalMinutes,
                  onToggle: (value) async {
                    HapticFeedback.selectionClick();
                    final updated = settings.copyWith(
                      notificationsEnabled: value,
                    );
                    await ref.read(updateSettingsUseCaseProvider).call(updated);

                    final schedulerRepo =
                        ref.read(notificationSchedulerRepositoryProvider);
                    await schedulerRepo.cancelAll();

                    if (value) {
                      final season = await ref
                          .read(liturgicalSeasonServiceProvider)
                          .getCurrentSeason();
                      await ScheduleCoreRemindersUseCase(
                        schedulerRepo,
                        quoteFetcher: ({
                          required String language,
                          required DateTime now,
                        }) {
                          if (updated.escrivaPointsFeedEnabled) {
                            return ref
                                .read(getNextEscrivaPointsQuoteUseCaseProvider)
                                .call(language: language, now: now);
                          }
                          return ref
                              .read(getNextQuoteUseCaseProvider)
                              .call(language: language, now: now);
                        },
                        notificationHistoryRepository: ref.read(
                          notificationHistoryRepositoryProvider,
                        ),
                      ).call(
                        updated,
                        isEasterSeason: season == LiturgicalSeason.easter,
                      );
                      await ScheduleLiturgyRemindersUseCase(schedulerRepo)
                          .call(updated);
                    }

                    ref.invalidate(_settingsProvider);
                  },
                  onOpenSettings: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: IaculaRadius.cardSpacing),

                const IaculaSectionHeader(title: 'Citações de hoje'),
                const SizedBox(height: IaculaSpacing.sm),
                historyAsync.when(
                  data: (entries) {
                    final visibleEntries = entries
                        .where((entry) => !entry.deliveredAt.isAfter(now))
                        .toList(growable: false);

                    if (visibleEntries.isEmpty) {
                      return IaculaSoftCard(
                        child: Text(
                          'As citações programadas para hoje aparecerão aqui conforme o dia avança.',
                          style: context.textStyles.secondary,
                        ),
                      );
                    }
                    return _TodayNotificationsRail(entries: visibleEntries);
                  },
                  loading: () =>
                      const Center(child: CupertinoActivityIndicator()),
                  error: (error, stackTrace) => IaculaSoftCard(
                    child: Text(
                      'Erro ao carregar.',
                      style: context.textStyles.secondary,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              'Erro ao carregar configurações.',
              style: context.textStyles.secondary,
            ),
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _TodayNotificationsRail extends StatelessWidget {
  const _TodayNotificationsRail({required this.entries});

  final List<NotificationHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 176,
      child: ListView.separated(
        key: const Key('today_notifications_rail'),
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: IaculaSpacing.sm),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return SizedBox(
            width: 280,
            child: IaculaSoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    NotificationsScreen._formatTime(entry.deliveredAt),
                    style: context.textStyles.secondary,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    entry.quoteText,
                    maxLines: 4,
                    style: context.textStyles.cardTitle,
                  ),
                  const Spacer(),
                  Text(
                    entry.feastName ?? entry.theme,
                    style: context.textStyles.secondary,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationStatusCard extends StatelessWidget {
  const _NotificationStatusCard({
    required this.enabled,
    required this.permissionGranted,
    required this.intervalMinutes,
    required this.onToggle,
    required this.onOpenSettings,
  });

  final bool enabled;
  final bool permissionGranted;
  final int intervalMinutes;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return IaculaSoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enabled ? 'Ativas' : 'Desativadas',
                      style: context.textStyles.cardTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      enabled
                          ? 'Jaculatória a cada $intervalMinutes min \u00B7 Angelus ao meio-dia'
                          : 'Nenhuma notificação será enviada',
                      style: context.textStyles.secondary,
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: enabled,
                activeTrackColor: context.colors.primaryButton,
                onChanged: onToggle,
              ),
            ],
          ),
          if (!permissionGranted && enabled) ...[
            const SizedBox(height: IaculaSpacing.sm),
            Container(
              padding: const EdgeInsets.all(IaculaSpacing.sm),
              decoration: BoxDecoration(
                color: context.colors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(IaculaRadius.small),
              ),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    color: context.colors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Permissão negada. Ative nas Configurações do sistema.',
                      style: context.textStyles.secondary.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (enabled) ...[
            const SizedBox(height: IaculaSpacing.sm),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              onPressed: onOpenSettings,
              child: Text(
                'Configurar intervalo',
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.primaryButton,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
