import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/providers.dart';
import '../core/presentation/shell_screen.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/lora_font_loader.dart';
import '../features/liturgical/domain/liturgical_season.dart';
import '../features/home_widget/application/use_cases/get_current_widget_quote_use_case.dart';
import '../features/home_widget/application/use_cases/refresh_widget_from_timeline_use_case.dart';
import '../features/notifications/application/services/notification_runtime_coordinator.dart';
import '../features/notifications/application/use_cases/handle_notification_action_use_case.dart';
import '../features/notifications/domain/repositories/notification_scheduler_repository.dart';
import '../features/notifications/domain/entities/reminder_event.dart';
import '../features/notifications/presentation/alarm_screen.dart';
import '../features/notifications/presentation/notification_detail_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/liturgy_hours/presentation/liturgy_hours_landing_screen.dart';
import '../features/night_prayer/presentation/night_prayer_screen.dart';
import '../features/home_widget/home_widget_service.dart';
import '../features/prayer_intentions/presentation/prayer_intentions_screen.dart';
import '../features/prayers/presentation/prayer_catalog_detail_screen.dart';
import '../features/prayers/presentation/prayer_screen.dart';
import '../features/settings/domain/entities/settings.dart';
import '../features/sync/infrastructure/services/background_sync_scheduler.dart';
import '../features/sync/infrastructure/services/background_task_runtime.dart';

class IaculaApp extends ConsumerStatefulWidget {
  const IaculaApp({super.key});

  @override
  ConsumerState<IaculaApp> createState() => _IaculaAppState();
}

class _IaculaAppState extends ConsumerState<IaculaApp>
    with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription? _actionsSub;
  Timer? _widgetRefreshSub;
  Settings? _settings;
  ReminderEvent? _pendingLaunchEvent;
  NotificationRuntimeCoordinator? _notificationCoordinator;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connectivity = ref.read(connectivityProvider);
      unawaited(loadLoraFontsWhenOnline(connectivity));

      final syncService = ref.read(connectivitySyncServiceProvider);
      syncService.start();

      final backgroundTaskRuntime = BackgroundTaskRuntime(
        syncAll: () => ref.read(syncOrchestratorProvider).syncAll(),
        refreshWidget: () => _makeWidgetRefreshUseCase().call().then((_) {}),
      );
      BackgroundSyncScheduler.configureTaskRunner(
        (task, inputData) => backgroundTaskRuntime.execute(task),
      );

      final backgroundSyncScheduler = ref.read(backgroundSyncSchedulerProvider);
      unawaited(backgroundSyncScheduler.register());
      unawaited(ref.read(syncOrchestratorProvider).syncAll());

      final scheduler = ref.read(notificationSchedulerRepositoryProvider);
      final handler = HandleNotificationActionUseCase(scheduler);

      _notificationCoordinator = NotificationRuntimeCoordinator(
        loadSettings: () => ref.read(getSettingsUseCaseProvider).call(),
        rebuild: (settings, {required isEasterSeason, required showImmediate}) async {
          final rebuildUseCase = ref.read(rebuildNotificationsUseCaseProvider);
          final liturgicalService = ref.read(liturgicalSeasonServiceProvider);
          final currentSeason = await liturgicalService.getCurrentSeason();
          await rebuildUseCase.call(
            settings,
            isEasterSeason: isEasterSeason || currentSeason == LiturgicalSeason.easter,
            showImmediate: showImmediate,
          );
        },
        pendingQuoteIds: () => scheduler.pendingNotificationIds(),
        refreshWidget: () => _makeWidgetRefreshUseCase().call().then((_) {}),
        cancelAll: () => scheduler.cancelAll(),
      );

      _widgetRefreshSub = Timer.periodic(const Duration(seconds: 30), (_) {
        unawaited(_syncWidgetFromTimeline());
      });
      unawaited(_syncWidgetFromTimeline());

      _actionsSub = scheduler.actions.listen((event) async {
        final shouldOpen = await handler.call(event);
        if (!shouldOpen) return;
        await _pushRouteForEvent(event.event);
      });

      unawaited(_handleLaunchNotification(scheduler, handler));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _actionsSub?.cancel();
    _widgetRefreshSub?.cancel();
    _pendingLaunchEvent = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      HomeWidgetService.instance.resetSignatureCache();
      unawaited(_notificationCoordinator?.handleAppResume());
    }
  }

  void _resetAndPush(NavigatorState nav, Widget destination) {
    nav.pushAndRemoveUntil(
      CupertinoPageRoute(builder: (_) => const ShellScreen()),
      (route) => false,
    );
    nav.push(CupertinoPageRoute(builder: (_) => destination));
  }

  Future<void> _pushRouteForEvent(ReminderEvent event) async {
    final nav = _navigatorKey.currentState;
    if (nav == null) return;

    switch (event.routeTarget) {
      case NotificationRouteTarget.home:
        ref.read(tappedNotificationScheduledAtProvider.notifier).state =
            event.scheduledAt;
        _resetAndPush(
          nav,
          NotificationDetailScreen(
            quoteText: event.body,
            theme: event.quoteTheme ?? '',
            season: event.quoteSeason ?? 'ordinary',
            feastName: event.quoteFeastName,
            imagePath: event.quoteImagePath,
          ),
        );
        return;

      case NotificationRouteTarget.prayer:
        final settings = await ref.read(getSettingsUseCaseProvider).call();
        final prayerSlug = event.prayerSlug;
        if (prayerSlug != null) {
          final catalogEntry = await ref
              .read(getPrayerCatalogUseCaseProvider)
              .getBySlug(language: settings.language, slug: prayerSlug);
          if (catalogEntry != null) {
            _resetAndPush(
              nav,
              PrayerCatalogDetailScreen(entry: catalogEntry),
            );
            return;
          }
        }

        final prayer = await ref
            .read(getPrayerUseCaseProvider)
            .call(language: settings.language);
        _resetAndPush(nav, PrayerScreen(prayer: prayer));
        return;

      case NotificationRouteTarget.alarm:
        nav.push(
          CupertinoPageRoute(
            builder: (_) => AlarmScreen(
              title: event.title,
              body: event.body,
            ),
          ),
        );
        return;

      case NotificationRouteTarget.prayerIntention:
        _resetAndPush(nav, const PrayerIntentionsScreen());
        return;

      case NotificationRouteTarget.nightPrayer:
        nav.push(
          CupertinoPageRoute(builder: (_) => const NightPrayerScreen()),
        );
        return;

      case NotificationRouteTarget.liturgyHours:
        nav.push(
          CupertinoPageRoute(
            builder: (_) => const LiturgyHoursLandingScreen(),
          ),
        );
        return;
    }
  }

  Future<void> _handleLaunchNotification(
    NotificationSchedulerRepository scheduler,
    HandleNotificationActionUseCase handler,
  ) async {
    final event = await scheduler.getLaunchNotificationAction();
    if (event == null) return;
    final shouldOpen = await handler.call(event);
    if (!shouldOpen) return;
    if (_settings != null) {
      await _pushRouteForEvent(event.event);
    } else {
      _pendingLaunchEvent = event.event;
    }
  }

  Future<void> _syncWidgetFromTimeline() async {
    await _makeWidgetRefreshUseCase().call();
  }

  RefreshWidgetFromTimelineUseCase _makeWidgetRefreshUseCase() {
    return RefreshWidgetFromTimelineUseCase(
      loadSettings: () => ref.read(getSettingsUseCaseProvider).call(),
      selectQuote: ({required settings, required now}) async {
        final selector = GetCurrentWidgetQuoteUseCase(
          notificationHistoryRepository: ref.read(
            notificationHistoryRepositoryProvider,
          ),
          lastDeliveredCardRepository: ref.read(
            lastDeliveredCardRepositoryProvider,
          ),
          fallbackQuoteFetcher:
              ({required String language, required DateTime now}) {
                if (settings.escrivaPointsFeedEnabled) {
                  return ref
                      .read(getNextEscrivaPointsQuoteUseCaseProvider)
                      .call(
                        language: language,
                        now: now,
                        cadenceMinutes: settings.intervalMinutes,
                      );
                }
                return ref
                    .read(getNextQuoteUseCaseProvider)
                    .call(language: language, now: now);
              },
        );

        return selector.call(language: settings.language, now: now);
      },
      updateWidgetIfChanged: HomeWidgetService.instance.updateWidgetIfChanged,
      saveIntervalMinutes: HomeWidgetService.instance.saveIntervalMinutes,
      now: DateTime.now,
    );
  }

  Future<void> _loadSettings() async {
    final settings = await ref.read(getSettingsUseCaseProvider).call();
    if (mounted) {
      ref.read(themeModeProvider.notifier).state = settings.themeMode;
      setState(() => _settings = settings);
      final pendingEvent = _pendingLaunchEvent;
      if (pendingEvent != null) {
        _pendingLaunchEvent = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pushRouteForEvent(pendingEvent);
        });
      }
    }
  }

  CupertinoThemeData _resolveTheme(String mode, BuildContext context) {
    switch (mode) {
      case 'light':
        return AppTheme.light();
      case 'dark':
        return AppTheme.dark();
      default:
        final brightness = MediaQuery.platformBrightnessOf(context);
        return brightness == Brightness.dark
            ? AppTheme.dark()
            : AppTheme.light();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    final themeMode = ref.watch(themeModeProvider);
    return CupertinoApp(
      title: 'Iacula',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: _resolveTheme(themeMode, context),
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR'), Locale('en'), Locale('la')],
      home: settings == null
          ? const CupertinoPageScaffold(
              child: Center(child: CupertinoActivityIndicator()),
            )
          : settings.onboardingCompleted
          ? const ShellScreen()
          : const OnboardingScreen(),
    );
  }
}
