import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/providers.dart';
import '../core/presentation/shell_screen.dart';
import '../core/theme/app_theme.dart';
import '../features/liturgia_diaria/presentation/liturgia_screen.dart';
import '../features/notifications/application/use_cases/handle_notification_action_use_case.dart';
import '../features/notifications/domain/entities/reminder_event.dart';
import '../features/notifications/presentation/alarm_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/prayers/presentation/prayer_screen.dart';
import '../features/settings/domain/entities/settings.dart';
import '../features/sync/infrastructure/services/background_sync_scheduler.dart';

class IaculaApp extends ConsumerStatefulWidget {
  const IaculaApp({super.key});

  @override
  ConsumerState<IaculaApp> createState() => _IaculaAppState();
}

class _IaculaAppState extends ConsumerState<IaculaApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription? _actionsSub;
  Settings? _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final syncService = ref.read(connectivitySyncServiceProvider);
      syncService.start();
      BackgroundSyncScheduler.configureTaskRunner((task, inputData) async {
        await ref.read(syncOrchestratorProvider).syncAll();
      });

      final backgroundSyncScheduler = ref.read(backgroundSyncSchedulerProvider);
      unawaited(backgroundSyncScheduler.register());
      unawaited(ref.read(syncOrchestratorProvider).syncAll());

      final scheduler = ref.read(notificationSchedulerRepositoryProvider);
      final handler = HandleNotificationActionUseCase(scheduler);

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
        }
      });
    });
  }

  @override
  void dispose() {
    _actionsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await ref.read(getSettingsUseCaseProvider).call();
    if (mounted) {
      setState(() => _settings = settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    return CupertinoApp(
      title: 'Iacula',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR'), Locale('en'), Locale('la')],
      routes: {LiturgiaScreen.routeName: (_) => const LiturgiaScreen()},
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
