import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/design/iacula_feedback.dart';
import '../../../core/presentation/widgets/iacula_animated_icon.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../favorites/domain/entities/favorite_item.dart';
import '../../liturgical/domain/liturgical_season.dart';
import '../../settings/domain/jaculatoria_interval.dart';
import '../../settings/presentation/settings_screen.dart';
import '../domain/entities/notification_history_entry.dart';
import 'notification_detail_screen.dart';

final _historyForDayProvider =
    FutureProvider.family<List<NotificationHistoryEntry>, DateTime>((ref, day) {
      return ref.watch(notificationHistoryRepositoryProvider).listForDay(day);
    });

final _settingsProvider = FutureProvider((ref) {
  return ref.watch(getSettingsUseCaseProvider).call();
});

final _availableHistoryDatesProvider = FutureProvider<List<DateTime>>((
  ref,
) async {
  final now = ref.watch(notificationHistoryNowProvider);
  final today = DateTime(now.year, now.month, now.day);
  final candidates = List.generate(
    7,
    (index) => today.subtract(Duration(days: index)),
    growable: false,
  );
  final repository = ref.watch(notificationHistoryRepositoryProvider);

  final dates = <DateTime>[today];
  for (final day in candidates.skip(1)) {
    final entries = await repository.listForDay(day);
    if (entries.isNotEmpty) {
      dates.add(day);
    }
  }
  return dates;
});

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with WidgetsBindingObserver {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = ref.read(notificationHistoryNowProvider);
    _selectedDate = DateTime(now.year, now.month, now.day);
    // Refresh on the events that matter — first open and returning to the
    // foreground — instead of polling on a timer. A periodic invalidate
    // rebuilds the list and yanks the user's horizontal scroll back to the
    // start mid-gesture, which reads as the screen "flashing". New
    // notifications while the screen is already open are rare enough that
    // refresh-on-resume is the better UX trade.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  void _refresh() {
    ref.invalidate(notificationHistoryNowProvider);
    ref.invalidate(_availableHistoryDatesProvider);
  }

  /// Pull-to-refresh handler: re-pull the clock, the available days, and the
  /// currently shown day's history, then await the reloads so the Cupertino
  /// refresh spinner stays until fresh data has actually arrived.
  Future<void> _pullToRefresh() async {
    _refresh();
    ref.invalidate(_historyForDayProvider(_selectedDate));
    await Future.wait([
      ref.read(_availableHistoryDatesProvider.future),
      ref.read(_historyForDayProvider(_selectedDate).future),
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(notificationHistoryNowProvider);
    final today = DateTime(now.year, now.month, now.day);
    final settingsAsync = ref.watch(_settingsProvider);
    final availableDatesAsync = ref.watch(_availableHistoryDatesProvider);
    final permissionGranted = ref.watch(notificationPermissionProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.colors.background,
      navigationBar: const CupertinoNavigationBar(middle: Text('Notificações')),
      child: SafeArea(
        child: settingsAsync.when(
          data: (settings) {
            return availableDatesAsync.when(
              data: (availableDates) {
                final selectedDate =
                    availableDates.any(
                      (date) => _isSameDay(date, _selectedDate),
                    )
                    ? _selectedDate
                    : today;
                final isTodaySelected = _isSameDay(selectedDate, today);
                final historyAsync = ref.watch(
                  _historyForDayProvider(selectedDate),
                );

                return CustomScrollView(
                  slivers: [
                    CupertinoSliverRefreshControl(onRefresh: _pullToRefresh),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        IaculaSpacing.md,
                        IaculaSpacing.md,
                        IaculaSpacing.md,
                        IaculaSpacing.md + MediaQuery.paddingOf(context).bottom,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
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
                              await ref
                                  .read(updateSettingsUseCaseProvider)
                                  .call(updated);

                              final season = await ref
                                  .read(liturgicalSeasonServiceProvider)
                                  .getCurrentSeason();
                              await ref
                                  .read(rebuildNotificationsUseCaseProvider)
                                  .call(
                                    updated,
                                    isEasterSeason:
                                        season == LiturgicalSeason.easter,
                                    showImmediate: false,
                                  );

                              ref.invalidate(_settingsProvider);
                              ref.invalidate(_availableHistoryDatesProvider);
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
                            dates: availableDates,
                            selectedDate: selectedDate,
                            today: today,
                            onSelect: (date) =>
                                setState(() => _selectedDate = date),
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
                                        .where(
                                          (entry) =>
                                              !entry.deliveredAt.isAfter(now),
                                        )
                                        .toList(growable: false)
                                  : entries;
                              final dedupedEntries =
                                  _collapseNearbyDuplicateQuotes(
                                    visibleEntries,
                                    intervalMinutes: settings.intervalMinutes,
                                  );
                              final sanitizedEntries =
                                  _collapseLegacyBurstEntries(dedupedEntries);

                              if (sanitizedEntries.isEmpty) {
                                return IaculaSoftCard(
                                  child: Text(
                                    isTodaySelected
                                        ? 'As citações programadas para hoje aparecerão aqui conforme o dia avança.'
                                        : 'Não há citações registradas para este dia.',
                                    style: context.textStyles.secondary,
                                  ),
                                );
                              }
                              return _NotificationsRail(
                                entries: sanitizedEntries,
                              );
                            },
                            loading: () => const Center(
                              child: CupertinoActivityIndicator(),
                            ),
                            error: (error, stackTrace) => IaculaErrorState(
                              title: 'Erro ao carregar citacoes',
                              message:
                                  'Tente novamente para atualizar o historico.',
                              onRetry: () => ref.invalidate(
                                _historyForDayProvider(selectedDate),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (error, stackTrace) => Center(
                child: IaculaErrorState(
                  title: 'Erro ao carregar histórico',
                  message:
                      'Tente novamente para atualizar os dias disponíveis.',
                  onRetry: () => ref.invalidate(_availableHistoryDatesProvider),
                ),
              ),
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, stackTrace) => Center(
            child: IaculaErrorState(
              title: 'Erro ao carregar configuracoes',
              message:
                  'Nao foi possivel abrir as configuracoes de notificacao.',
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

List<NotificationHistoryEntry> _collapseNearbyDuplicateQuotes(
  List<NotificationHistoryEntry> entries, {
  required int intervalMinutes,
}) {
  if (entries.length < 2 || intervalMinutes <= 1) return entries;

  final kept = <NotificationHistoryEntry>[];
  final latestByQuote = <String, NotificationHistoryEntry>{};
  for (final entry in entries) {
    final latestForText = latestByQuote[entry.quoteText];
    if (latestForText != null) {
      final diff = latestForText.deliveredAt
          .difference(entry.deliveredAt)
          .abs();
      if (diff.inMinutes <= intervalMinutes) {
        continue;
      }
    }
    kept.add(entry);
    latestByQuote[entry.quoteText] = entry;
  }
  return kept;
}

List<NotificationHistoryEntry> _collapseLegacyBurstEntries(
  List<NotificationHistoryEntry> entries,
) {
  if (entries.length < 2) return entries;

  // Legacy bug created synthetic rows 1-2 minutes apart. Keep only the latest
  // card inside these burst windows so historical noise does not dominate UI.
  const legacyBurstWindowMinutes = 2;
  final kept = <NotificationHistoryEntry>[];
  for (final entry in entries) {
    if (kept.isEmpty) {
      kept.add(entry);
      continue;
    }

    final latestKept = kept.last;
    final diff = latestKept.deliveredAt.difference(entry.deliveredAt).abs();
    if (diff.inMinutes <= legacyBurstWindowMinutes) {
      continue;
    }
    kept.add(entry);
  }
  return kept;
}

class _NotificationsRail extends StatelessWidget {
  const _NotificationsRail({required this.entries});

  final List<NotificationHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 188,
      child: ListView.separated(
        key: const Key('today_notifications_rail'),
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: IaculaSpacing.sm),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute(
                  builder: (_) =>
                      NotificationDetailScreen.fromHistoryEntry(entry),
                ),
              );
            },
            child: SizedBox(
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
                    Text(
                      entry.quoteText,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.cardTitle,
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _NotificationHistoryBookmarkButton(entry: entry),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationHistoryBookmarkButton extends ConsumerWidget {
  const _NotificationHistoryBookmarkButton({required this.entry});

  final NotificationHistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteAsync = ref.watch(
      favoriteItemByQuoteTextProvider(entry.quoteText),
    );
    final isSaved = favoriteAsync.valueOrNull != null;
    final savedItem = favoriteAsync.valueOrNull;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(32, 32),
      onPressed: () async {
        HapticFeedback.selectionClick();
        final repo = ref.read(favoriteRepositoryProvider);
        if (savedItem != null) {
          await repo.remove(savedItem.id);
        } else {
          await repo.save(
            FavoriteItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              quoteText: entry.quoteText,
              theme: entry.theme,
              season: entry.season,
              savedAt: DateTime.now(),
              imagePath: entry.imagePath,
              feastName: entry.feastName,
            ),
          );
        }
      },
      child: IaculaAnimatedIcon(
        icon: isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
        color: context.colors.primaryButton,
        size: 20,
        enableHaptics: false,
      ),
    );
  }
}

class _HistoryDateSelector extends StatelessWidget {
  const _HistoryDateSelector({
    required this.dates,
    required this.selectedDate,
    required this.today,
    required this.onSelect,
  });

  final List<DateTime> dates;
  final DateTime selectedDate;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _labelFor(DateTime date) {
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
            color: selected
                ? context.colors.primaryButton
                : context.colors.card,
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
                          ? 'Jaculatória a cada ${formatJaculatoriaIntervalCompactForBadge(intervalMinutes)} \u00B7 Angelus ao meio-dia'
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
