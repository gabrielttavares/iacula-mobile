import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/providers.dart';
import '../core/presentation/shell_screen.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/lora_font_loader.dart';
import '../features/home_widget/application/use_cases/get_current_widget_quote_use_case.dart';
import '../features/home_widget/application/use_cases/refresh_widget_from_timeline_use_case.dart';
import '../features/notifications/application/use_cases/handle_notification_action_use_case.dart';
import '../features/notifications/domain/entities/reminder_event.dart';
import '../features/notifications/presentation/alarm_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/liturgy_hours/presentation/liturgy_hours_landing_screen.dart';
import '../features/night_prayer/presentation/night_prayer_screen.dart';
import '../features/home_widget/home_widget_service.dart';
import '../features/prayer_intentions/presentation/prayer_intentions_screen.dart';
import '../features/prayers/presentation/prayer_screen.dart';
import '../features/settings/domain/entities/settings.dart';
import '../features/sync/infrastructure/services/background_sync_scheduler.dart';

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
      BackgroundSyncScheduler.configureTaskRunner((task, inputData) async {
        if (task == BackgroundSyncScheduler.widgetTaskName) {
          await _makeWidgetRefreshUseCase().call();
          return;
        }
        await ref.read(syncOrchestratorProvider).syncAll();
      });

      final backgroundSyncScheduler = ref.read(backgroundSyncSchedulerProvider);
      unawaited(backgroundSyncScheduler.register());
      unawaited(ref.read(syncOrchestratorProvider).syncAll());

      final scheduler = ref.read(notificationSchedulerRepositoryProvider);
      final handler = HandleNotificationActionUseCase(scheduler);

      _widgetRefreshSub = Timer.periodic(const Duration(seconds: 30), (_) {
        unawaited(_syncWidgetFromTimeline());
      });
      unawaited(_syncWidgetFromTimeline());

      _actionsSub = scheduler.actions.listen((event) async {
        final shouldOpen = await handler.call(event);
        if (!shouldOpen) return;

        final nav = _navigatorKey.currentState;
        if (nav == null) return;

        switch (event.event.routeTarget) {
          case NotificationRouteTarget.home:
            nav.pushAndRemoveUntil(
              CupertinoPageRoute(builder: (_) => const ShellScreen()),
              (route) => false,
            );
            return;

          case NotificationRouteTarget.prayer:
            final settings = await ref.read(getSettingsUseCaseProvider).call();
            final prayer = await ref
                .read(getPrayerUseCaseProvider)
                .call(language: settings.language);
            nav.push(
              CupertinoPageRoute(builder: (_) => PrayerScreen(prayer: prayer)),
            );
            return;

          case NotificationRouteTarget.alarm:
            nav.push(
              CupertinoPageRoute(
                builder: (_) => AlarmScreen(
                  title: event.event.title,
                  body: event.event.body,
                ),
              ),
            );
            return;

          case NotificationRouteTarget.prayerIntention:
            nav.pushAndRemoveUntil(
              CupertinoPageRoute(builder: (_) => const ShellScreen()),
              (route) => false,
            );
            nav.push(
              CupertinoPageRoute(
                builder: (_) => const PrayerIntentionsScreen(),
              ),
            );
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
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _actionsSub?.cancel();
    _widgetRefreshSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      HomeWidgetService.instance.resetSignatureCache();
      unawaited(_syncWidgetFromTimeline());
    }
  }

  Future<void> _syncWidgetFromTimeline() async {
    await _makeWidgetRefreshUseCase().call();
  }

  RefreshWidgetFromTimelineUseCase _makeWidgetRefreshUseCase() {
    return RefreshWidgetFromTimelineUseCase(
      loadSettings: () => ref.read(getSettingsUseCaseProvider).call(),
      selectQuote: ({required settings, required now}) {
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
                    .call(
                      language: language,
                      now: now,
                      liturgicalSeasonEnabled:
                          settings.liturgicalSeasonEnabled,
                    );
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
