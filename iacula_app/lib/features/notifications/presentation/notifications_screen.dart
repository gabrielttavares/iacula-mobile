import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/presentation/widgets/iacula_toast.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../favorites/domain/entities/favorite_item.dart';
import '../../liturgical/domain/liturgical_season.dart';
import '../../settings/presentation/settings_screen.dart';
import '../application/use_cases/schedule_core_reminders_use_case.dart';
import '../application/use_cases/schedule_liturgy_reminders_use_case.dart';
import '../domain/entities/notification_history_entry.dart';

final _historyForDayProvider =
    FutureProvider.family<List<NotificationHistoryEntry>, DateTime>((
      ref,
      day,
    ) {
      return ref.watch(notificationHistoryRepositoryProvider).listForDay(day);
    });

final _settingsProvider = FutureProvider((ref) {
  return ref.watch(getSettingsUseCaseProvider).call();
});

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = ref.read(notificationHistoryNowProvider);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  List<DateTime> _lastSevenDays() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return List.generate(
      7,
      (index) => start.subtract(Duration(days: index)),
      growable: false,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(_historyForDayProvider(_selectedDate));
    final now = ref.watch(notificationHistoryNowProvider);
    final settingsAsync = ref.watch(_settingsProvider);
    final permissionGranted = ref.watch(notificationPermissionProvider);
    final isTodaySelected = _isSameDay(_selectedDate, now);

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
                        lastDeliveredCardRepository: ref.read(
                          lastDeliveredCardRepositoryProvider,
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

                _HistoryDateSelector(
                  dates: _lastSevenDays(),
                  selectedDate: _selectedDate,
                  onSelect: (date) => setState(() => _selectedDate = date),
                ),
                const SizedBox(height: IaculaSpacing.sm),
                IaculaSectionHeader(
                  title: isTodaySelected
                      ? 'Citações de hoje'
                      : 'Citações do dia selecionado',
                ),
                const SizedBox(height: IaculaSpacing.sm),
                historyAsync.when(
                  data: (entries) {
                    final visibleEntries = isTodaySelected
                        ? entries
                              .where((entry) => !entry.deliveredAt.isAfter(now))
                              .toList(growable: false)
                        : entries;

                    if (visibleEntries.isEmpty) {
                      return IaculaSoftCard(
                        child: Text(
                          'As citações programadas para hoje aparecerão aqui conforme o dia avança.',
                          style: context.textStyles.secondary,
                        ),
                      );
                    }
                    return _NotificationsRail(entries: visibleEntries);
                  },
                  loading: () =>
                      const Center(child: CupertinoActivityIndicator()),
                  error: (error, stackTrace) => IaculaErrorState(
                    title: 'Erro ao carregar citacoes',
                    message: 'Tente novamente para atualizar o historico.',
                    onRetry: () => ref.invalidate(
                      _historyForDayProvider(_selectedDate),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, stackTrace) => Center(
            child: IaculaErrorState(
              title: 'Erro ao carregar configuracoes',
              message: 'Nao foi possivel abrir as configuracoes de notificacao.',
              onRetry: () => ref.invalidate(_settingsProvider),
            ),
          ),
        ),
      ),
    );
  }

}

String _formatTime(DateTime dt) {
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _NotificationsRail extends ConsumerWidget {
  const _NotificationsRail({required this.entries});

  final List<NotificationHistoryEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 188,
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
                    _formatTime(entry.deliveredAt),
                    style: context.textStyles.secondary,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    entry.quoteText,
                    maxLines: 4,
                    style: context.textStyles.cardTitle,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.feastName ?? entry.theme,
                          style: context.textStyles.secondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32),
                        onPressed: () async {
                          final repo = ref.read(favoriteRepositoryProvider);
                          final alreadyFavorite = await repo.isFavorite(
                            entry.quoteText,
                          );
                          if (alreadyFavorite) {
                            if (context.mounted) {
                              IaculaToast.show(
                                context,
                                'Esta citação já está nos favoritos.',
                                icon: CupertinoIcons.heart_fill,
                              );
                            }
                            return;
                          }

                          await repo.save(
                            FavoriteItem(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              quoteText: entry.quoteText,
                              theme: entry.theme,
                              season: entry.season,
                              savedAt: DateTime.now(),
                              imagePath: entry.imagePath,
                              feastName: entry.feastName,
                            ),
                          );
                          ref.invalidate(favoritesProvider);
                          if (context.mounted) {
                            IaculaToast.show(
                              context,
                              'Citação salva nos favoritos.',
                              icon: CupertinoIcons.heart_fill,
                            );
                          }
                        },
                        child: Icon(
                          CupertinoIcons.heart,
                          size: 18,
                          color: context.colors.primaryButton,
                        ),
                      ),
                    ],
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

class _HistoryDateSelector extends StatelessWidget {
  const _HistoryDateSelector({
    required this.dates,
    required this.selectedDate,
    required this.onSelect,
  });

  final List<DateTime> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _labelFor(DateTime date) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final diff = normalizedToday.difference(normalizedDate).inDays;
    if (diff == 0) {
      return 'Hoje';
    }
    if (diff == 1) {
      return 'Ontem';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = dates[index];
          final selected = _isSameDay(selectedDate, date);
          return CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: const Size(34, 34),
            color: selected ? context.colors.primaryButton : context.colors.card,
            borderRadius: BorderRadius.circular(IaculaRadius.small),
            onPressed: () => onSelect(date),
            child: Text(
              _labelFor(date),
              style: context.textStyles.secondary.copyWith(
                color: selected
                    ? CupertinoColors.white
                    : context.colors.textSecondary,
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
