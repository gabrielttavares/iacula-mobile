import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/presentation/widgets/iacula_section_header.dart';
import '../../../core/presentation/widgets/iacula_soft_card.dart';
import '../../../core/theme/cupertino_tokens.dart';
import '../../settings/presentation/settings_screen.dart';
import '../application/use_cases/schedule_core_reminders_use_case.dart';
import '../application/use_cases/schedule_liturgy_reminders_use_case.dart';
import '../domain/entities/last_delivered_card.dart';

final _lastCardProvider = FutureProvider<LastDeliveredCard?>((ref) {
  return ref.watch(lastDeliveredCardRepositoryProvider).load();
});

final _settingsProvider = FutureProvider((ref) {
  return ref.watch(getSettingsUseCaseProvider).call();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardAsync = ref.watch(_lastCardProvider);
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
                        lastDeliveredCardRepository: ref.read(
                          lastDeliveredCardRepositoryProvider,
                        ),
                      ).call(updated);
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

                // -- PRÓXIMAS --
                if (settings.notificationsEnabled) ...[
                  const IaculaSectionHeader(title: 'Próximas notificações'),
                  const SizedBox(height: IaculaSpacing.sm),
                  _UpcomingNotificationsCard(
                    intervalMinutes: settings.intervalMinutes,
                  ),
                  const SizedBox(height: IaculaRadius.cardSpacing),
                ],

                // -- ÚLTIMA --
                const IaculaSectionHeader(title: 'Última notificação'),
                const SizedBox(height: IaculaSpacing.sm),
                cardAsync.when(
                  data: (card) {
                    if (card == null) {
                      return IaculaSoftCard(
                        child: Text(
                          'Nenhuma notificação enviada ainda.',
                          style: context.textStyles.secondary,
                        ),
                      );
                    }
                    return IaculaSoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.theme,
                            style: context.textStyles.secondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            card.quoteText,
                            style: context.textStyles.cardTitle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatDate(card.deliveredAt),
                            style: context.textStyles.secondary,
                          ),
                          if (card.feastName != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              card.feastName!,
                              style: context.textStyles.secondary,
                            ),
                          ],
                        ],
                      ),
                    );
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

  static String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
                          ? 'Jaculatória a cada $intervalMinutes min'
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

class _UpcomingNotificationsCard extends StatelessWidget {
  const _UpcomingNotificationsCard({required this.intervalMinutes});

  final int intervalMinutes;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = List.generate(5, (i) {
      final at = now.add(Duration(minutes: intervalMinutes * (i + 1)));
      return at;
    });

    return IaculaSoftCard(
      child: Column(
        children: [
          for (var i = 0; i < upcoming.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Container(
                  height: 1,
                  color: context.colors.separator,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.bell,
                    size: 16,
                    color: context.colors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _formatTime(upcoming[i]),
                    style: context.textStyles.cardTitle.copyWith(fontSize: 15),
                  ),
                  const Spacer(),
                  Text(
                    _relativeTime(upcoming[i], DateTime.now()),
                    style: context.textStyles.secondary.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  static String _relativeTime(DateTime target, DateTime now) {
    final diff = target.difference(now);
    if (diff.inMinutes < 60) return 'em ${diff.inMinutes} min';
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;
    if (mins == 0) return 'em ${hours}h';
    return 'em ${hours}h ${mins}min';
  }
}
