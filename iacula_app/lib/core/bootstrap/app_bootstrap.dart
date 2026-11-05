import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:cronet_http/cronet_http.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/favorites/infrastructure/repositories/isar_favorite_repository.dart';
import '../../features/auth/infrastructure/repositories/in_memory_auth_repository.dart';
import '../../features/auth/infrastructure/repositories/supabase_auth_repository.dart';
import '../../features/custom_phrases/application/use_cases/schedule_phrase_notifications_use_case.dart';
import '../../features/custom_phrases/infrastructure/repositories/isar_custom_phrase_repository.dart';
import '../../features/liturgical/domain/liturgical_season.dart';
import '../../features/liturgical/infrastructure/repositories/isar_liturgical_season_cache_repository.dart';
import '../../features/liturgical/infrastructure/services/remote_liturgical_season_service.dart';
import '../../features/leituras/data/repositories/leitura_repository.dart';
import '../../features/leituras/data/sources/leitura_local_source.dart';
import '../../features/notifications/application/use_cases/rebuild_notifications_use_case.dart';
import '../../features/notifications/application/services/notification_quote_fetcher.dart';
import '../../features/notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import '../../features/notifications/domain/services/notification_capacity_policy.dart';
import '../../features/liturgical/domain/easter_calculator.dart';
import '../../features/settings/domain/entities/settings.dart';
import '../../features/notifications/infrastructure/repositories/local_notification_scheduler_repository.dart';
import '../../features/notifications/infrastructure/repositories/sqlite_last_delivered_card_repository.dart';
import '../../features/notifications/infrastructure/repositories/sqlite_notification_history_repository.dart';
import '../../features/quotes/application/use_cases/get_next_escriva_points_quote_use_case.dart';
import '../../features/premium/domain/entities/premium_status.dart';
import '../../features/premium/domain/repositories/premium_repository.dart';
import '../../features/premium/infrastructure/always_unlocked_premium_repository.dart';
import '../../features/premium/infrastructure/isar_premium_repository.dart';
import '../../features/quotes/application/use_cases/get_next_quote_use_case.dart';
import '../../features/quotes/infrastructure/repositories/asset_quote_content_repository.dart';
import '../../features/quotes/infrastructure/repositories/sqlite_disabled_quotes_repository.dart';
import '../../features/quotes/infrastructure/repositories/sqlite_quote_indices_repository.dart';
import '../../features/reading/infrastructure/repositories/isar_reading_annotation_repository.dart';
import '../../features/settings/infrastructure/repositories/sqlite_settings_repository.dart';
import '../../features/spiritual_data/domain/entities/spiritual_entry.dart';
import '../../features/spiritual_data/infrastructure/repositories/isar_spiritual_entry_repositories.dart';
import '../../features/spiritual_data/infrastructure/storage/spiritual_data_encryption_key_provider.dart';
import '../../features/spiritual_data/infrastructure/storage/spiritual_data_isar_store.dart';
import '../../features/prayer_intentions/application/use_cases/schedule_intention_notifications_use_case.dart';
import '../../features/storage/domain/entities/media_asset.dart';
import '../../features/storage/domain/repositories/media_catalog_repository.dart';
import '../../features/storage/infrastructure/repositories/isar_media_catalog_repository.dart';
import '../../features/sync/domain/repositories/sync_orchestrator.dart';
import '../../features/sync/infrastructure/repositories/isar_sync_state_repository.dart';
import '../../features/sync/infrastructure/repositories/supabase_spiritual_sync_repository.dart';
import '../../features/sync/infrastructure/services/default_sync_orchestrator.dart';
import '../../features/sync/infrastructure/services/noop_sync_orchestrator.dart';
import '../config/app_env.dart';
import '../di/providers.dart';
import '../storage/isar/isar_store.dart';
import '../storage/sqlite/app_database.dart';
import 'bootstrap_status.dart';

final class AppBootstrap {
  const AppBootstrap._();

  static Future<List<Override>> createProductionOverrides() async {
    try {
      final env = AppEnv.fromDartDefines();

      final db = AppDatabase.instance;
      final isarStore = IsarStore.instance;

      // Single spiritual Isar store (same path/name) — must not be instantiated twice
      final localKeyProvider = SpiritualDataEncryptionKeyProvider(
        store: FlutterSecureKvStore(),
      );
      final spiritualStore = SpiritualDataIsarStore(
        keyProvider: localKeyProvider,
      );

      final settingsRepo = SqliteSettingsRepository(db);
      final indicesRepo = SqliteQuoteIndicesRepository(db);
      final disabledQuotesRepo = SqliteDisabledQuotesRepository(db);
      final lastDeliveredCardRepo = SqliteLastDeliveredCardRepository(db);
      final notificationHistoryRepo = SqliteNotificationHistoryRepository(db);
      final mediaRepo = IsarMediaCatalogRepository(isarStore);
      final favoriteRepo = IsarFavoriteRepository(store: isarStore);
      final readingAnnotationRepo = IsarReadingAnnotationRepository(
        store: isarStore,
      );
      final localPremiumRepo = IsarPremiumRepository(store: isarStore);
      final localCustomPhraseRepo = IsarCustomPhraseRepository(spiritualStore);
      final prayerIntentionRepo = IsarPrayerIntentionSpiritualEntryRepository(
        spiritualStore,
      );
      const devPremiumOverride =
          String.fromEnvironment('DEV_PREMIUM_OVERRIDE') == 'true';
      if (devPremiumOverride) {
        await localPremiumRepo.unlockPremium(
          PremiumStatus(
            isPremium: true,
            purchaseDate: DateTime.now(),
            storeTransactionId: 'dev-override',
          ),
        );
      }
      final liturgicalCacheRepo = IsarLiturgicalSeasonCacheRepository(
        isarStore,
      );
      final http.Client httpClient;
      if (Platform.isAndroid) {
        final engine = CronetEngine.build(
          cacheMode: CacheMode.memory,
          cacheMaxSize: 1024 * 1024,
        );
        httpClient = CronetClient.fromCronetEngine(engine, closeEngine: true);
      } else {
        httpClient = http.Client();
      }
      final liturgicalSeasonService = RemoteLiturgicalSeasonService(
        httpClient: httpClient,
        cacheRepository: liturgicalCacheRepo,
      );
      final quoteUseCase = GetNextQuoteUseCase(
        contentRepository: const AssetQuoteContentRepository(),
        indicesRepository: indicesRepo,
        disabledQuotesRepository: disabledQuotesRepo,
        customPhraseRepository: localCustomPhraseRepo,
      );
      final escrivaPointsUseCase = GetNextEscrivaPointsQuoteUseCase(
        LeituraRepository(localSource: LeituraLocalSource()),
      );

      await _seedMediaCatalog(mediaRepo);

      final scheduler = LocalNotificationSchedulerRepository();
      final currentSettings = await settingsRepo.load();
      bool permissionGranted;
      try {
        permissionGranted = await scheduler.initialize(
          requestPermission: currentSettings.onboardingCompleted,
        );
      } catch (e) {
        debugPrint('[Bootstrap] Notification init failed: $e');
        permissionGranted = false;
      }
      final quoteFetcher = buildNotificationQuoteFetcher(
        loadSettings: settingsRepo.load,
        listPhrases: localCustomPhraseRepo.listAll,
        nextQuote: quoteUseCase,
        nextEscrivaPoint: escrivaPointsUseCase,
      );

      // Heal custom-phrase notifications orphaned by an older build, where
      // deleting a phrase left its OS-level repeating notification scheduled
      // with no UI to cancel it. Runs unconditionally so users with
      // notifications enabled but permission denied (who hit neither branch
      // below) are still cleaned up. Idempotent: a no-op once orphans are gone.
      if (currentSettings.onboardingCompleted) {
        try {
          await SchedulePhraseNotificationsUseCase(
            scheduler,
            localCustomPhraseRepo,
          ).sweepOrphanedSlots();
        } catch (e) {
          debugPrint('[Bootstrap] Orphaned phrase notification sweep failed: $e');
        }
      }

      if (currentSettings.onboardingCompleted &&
          !currentSettings.notificationsEnabled) {
        try {
          await scheduler.cancelAll();
        } catch (e) {
          debugPrint('[Bootstrap] Notification cancelAll failed: $e');
        }
      } else if (currentSettings.onboardingCompleted &&
          currentSettings.notificationsEnabled &&
          permissionGranted) {
        try {
          await _rebuildNotifications(
            scheduler: scheduler,
            settings: currentSettings,
            quoteFetcher: quoteFetcher,
            notificationHistoryRepo: notificationHistoryRepo,
            lastDeliveredCardRepo: lastDeliveredCardRepo,
            customPhraseRepo: localCustomPhraseRepo,
            prayerIntentionRepo: prayerIntentionRepo,
            liturgicalSeasonService: liturgicalSeasonService,
          );
        } catch (e, st) {
          developer.log(
            'Notification scheduling failed during bootstrap.',
            name: 'AppBootstrap',
            error: e,
            stackTrace: st,
          );
        }
      }

      AuthRepository authRepository = InMemoryAuthRepository();
      // TODO(gabrielttav): restore local/synced premium repositories when paid access returns.
      PremiumRepository premiumRepository = AlwaysUnlockedPremiumRepository();
      SyncOrchestrator syncOrchestrator = const NoopSyncOrchestrator();
      var bootstrapStatus = const BootstrapStatus();
      SupabaseClient? supabaseClient;

      if (env.authSyncEnabled && env.hasSupabase) {
        try {
          await Supabase.initialize(
            url: env.supabaseUrl!,
            anonKey: env.supabaseAnonKey!,
          );

          supabaseClient = Supabase.instance.client;
          authRepository = SupabaseAuthRepository(supabaseClient);
          developer.log(
            'Premium runtime is in free-access mode; synced premium repository kept dormant for later restoration.',
            name: 'AppBootstrap',
          );

          final gateway = SupabaseSpiritualSyncGateway(supabaseClient);

          syncOrchestrator = DefaultSyncOrchestrator(
            authRepository: authRepository,
            syncStateRepository: IsarSyncStateRepository(spiritualStore),
            modules: [
              SyncModuleAdapter(
                module: SpiritualModule.examination,
                localRepository: IsarExaminationSpiritualEntryRepository(
                  spiritualStore,
                ),
                remoteRepository: SupabaseSpiritualSyncRepository(
                  module: SpiritualModule.examination,
                  table: 'examination_entries',
                  gateway: gateway,
                ),
              ),
              SyncModuleAdapter(
                module: SpiritualModule.prayerIntention,
                localRepository: IsarPrayerIntentionSpiritualEntryRepository(
                  spiritualStore,
                ),
                remoteRepository: SupabaseSpiritualSyncRepository(
                  module: SpiritualModule.prayerIntention,
                  table: 'prayer_intention_entries',
                  gateway: gateway,
                ),
              ),
            ],
          );

          bootstrapStatus = const BootstrapStatus(
            supabaseAvailable: true,
            authMode: AuthMode.supabase,
            syncEnabled: true,
          );
        } catch (error, st) {
          developer.log(
            'Supabase auth/sync bootstrap failed. Falling back to local-only mode.',
            name: 'AppBootstrap',
            error: error,
            stackTrace: st,
          );
          authRepository = InMemoryAuthRepository();
          premiumRepository = AlwaysUnlockedPremiumRepository();
          syncOrchestrator = const NoopSyncOrchestrator();
          bootstrapStatus = BootstrapStatus(
            errorMessage: 'Supabase initialization failed: $error',
          );
        }
      }

      final overrides = <Override>[
        appEnvProvider.overrideWithValue(env),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        quoteIndicesRepositoryProvider.overrideWithValue(indicesRepo),
        disabledQuotesRepositoryProvider.overrideWithValue(disabledQuotesRepo),
        lastDeliveredCardRepositoryProvider.overrideWithValue(
          lastDeliveredCardRepo,
        ),
        notificationHistoryRepositoryProvider.overrideWithValue(
          notificationHistoryRepo,
        ),
        mediaCatalogRepositoryProvider.overrideWithValue(mediaRepo),
        favoriteRepositoryProvider.overrideWithValue(favoriteRepo),
        readingAnnotationRepositoryProvider.overrideWithValue(
          readingAnnotationRepo,
        ),
        premiumRepositoryProvider.overrideWithValue(premiumRepository),
        customPhraseRepositoryProvider.overrideWithValue(localCustomPhraseRepo),
        liturgicalSeasonCacheRepositoryProvider.overrideWithValue(
          liturgicalCacheRepo,
        ),
        notificationSchedulerRepositoryProvider.overrideWithValue(scheduler),
        notificationPermissionProvider.overrideWith((ref) => permissionGranted),
        httpClientProvider.overrideWithValue(httpClient),
        authRepositoryProvider.overrideWithValue(authRepository),
        syncOrchestratorProvider.overrideWithValue(syncOrchestrator),
        bootstrapStatusProvider.overrideWithValue(bootstrapStatus),
        spiritualDataKeyProvider.overrideWithValue(localKeyProvider),
        spiritualDataIsarStoreProvider.overrideWithValue(spiritualStore),
        liturgicalSeasonServiceProvider.overrideWith((ref) {
          return RemoteLiturgicalSeasonService(
            httpClient: ref.watch(httpClientProvider),
            cacheRepository: ref.watch(liturgicalSeasonCacheRepositoryProvider),
          );
        }),
      ];

      if (supabaseClient != null) {
        overrides.add(supabaseClientProvider.overrideWithValue(supabaseClient));
      }

      return overrides;
    } catch (e, st) {
      developer.log(
        'Bootstrap failed unexpectedly. Returning empty overrides to avoid splash freeze.',
        name: 'AppBootstrap',
        error: e,
        stackTrace: st,
      );
      return <Override>[];
    }
  }

  /// Re-arms the pre-scheduled notifications with the app closed, from the
  /// periodic background task (Android WorkManager, iOS BGAppRefreshTask).
  ///
  /// Pre-scheduled local notifications run out (iOS: 64 pending ≈ 7 days;
  /// Android: a 14-day tail) and used to be renewed only when the app was
  /// opened, so people who stopped opening it stopped being reminded. This
  /// opens only the local stores the scheduler needs — no Supabase, no media
  /// seeding — and never prompts for permission.
  static Future<void> rearmNotificationsInBackground() async {
    final db = AppDatabase.instance;
    final settingsRepo = SqliteSettingsRepository(db);
    final settings = await settingsRepo.load();
    if (!settings.onboardingCompleted || !settings.notificationsEnabled) {
      return;
    }

    final scheduler = LocalNotificationSchedulerRepository();
    await scheduler.initialize(requestPermission: false);
    if (!await scheduler.checkPermission()) {
      debugPrint('[Bootstrap] Background re-arm skipped: no permission.');
      return;
    }

    final isarStore = IsarStore.instance;
    final spiritualStore = SpiritualDataIsarStore(
      keyProvider: SpiritualDataEncryptionKeyProvider(
        store: FlutterSecureKvStore(),
      ),
    );
    final customPhraseRepo = IsarCustomPhraseRepository(spiritualStore);

    await _rebuildNotifications(
      scheduler: scheduler,
      settings: settings,
      quoteFetcher: buildNotificationQuoteFetcher(
        loadSettings: settingsRepo.load,
        listPhrases: customPhraseRepo.listAll,
        nextQuote: GetNextQuoteUseCase(
          contentRepository: const AssetQuoteContentRepository(),
          indicesRepository: SqliteQuoteIndicesRepository(db),
          disabledQuotesRepository: SqliteDisabledQuotesRepository(db),
          customPhraseRepository: customPhraseRepo,
        ),
        nextEscrivaPoint: GetNextEscrivaPointsQuoteUseCase(
          LeituraRepository(localSource: LeituraLocalSource()),
        ),
      ),
      notificationHistoryRepo: SqliteNotificationHistoryRepository(db),
      lastDeliveredCardRepo: SqliteLastDeliveredCardRepository(db),
      customPhraseRepo: customPhraseRepo,
      prayerIntentionRepo: IsarPrayerIntentionSpiritualEntryRepository(
        spiritualStore,
      ),
      liturgicalSeasonService: RemoteLiturgicalSeasonService(
        httpClient: http.Client(),
        cacheRepository: IsarLiturgicalSeasonCacheRepository(isarStore),
      ),
    );
  }

  /// The one rebuild path shared by cold start and the background re-arm, so
  /// both use the platform's capacity policy and the same quote selection.
  static Future<void> _rebuildNotifications({
    required LocalNotificationSchedulerRepository scheduler,
    required Settings settings,
    required QuoteFetcher quoteFetcher,
    required SqliteNotificationHistoryRepository notificationHistoryRepo,
    required SqliteLastDeliveredCardRepository lastDeliveredCardRepo,
    required IsarCustomPhraseRepository customPhraseRepo,
    required IsarPrayerIntentionSpiritualEntryRepository prayerIntentionRepo,
    required RemoteLiturgicalSeasonService liturgicalSeasonService,
  }) async {
    final now = DateTime.now();
    var isEasterSeason = EasterCalculator.isWithinEasterSeason(now);
    try {
      // Cached per day; the network is only hit on a cache miss. Bounded so
      // an offline background run still finishes within the OS budget.
      final season = await liturgicalSeasonService.getCurrentSeason().timeout(
        const Duration(seconds: 5),
      );
      isEasterSeason = isEasterSeason || season == LiturgicalSeason.easter;
    } catch (e) {
      debugPrint('[Bootstrap] Liturgical season lookup failed: $e');
    }

    await RebuildNotificationsUseCase(
      scheduler: scheduler,
      notificationHistoryRepository: notificationHistoryRepo,
      lastDeliveredCardRepository: lastDeliveredCardRepo,
      schedulePhraseNotifications: SchedulePhraseNotificationsUseCase(
        scheduler,
        customPhraseRepo,
      ),
      scheduleIntentionNotifications: ScheduleIntentionNotificationsUseCase(
        scheduler,
        prayerIntentionRepo,
      ),
      quoteFetcher: quoteFetcher,
      capacityPolicy: NotificationCapacityPolicy.forPlatform(
        isAndroid: Platform.isAndroid,
      ),
    ).call(settings, isEasterSeason: isEasterSeason, showImmediate: false);
  }

  static Future<void> _seedMediaCatalog(
    MediaCatalogRepository mediaRepo,
  ) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets();

    final media = <MediaAsset>[];
    for (final key in assets) {
      if (!key.startsWith('assets/seed/images/') &&
          !key.startsWith('assets/seed/audio/')) {
        continue;
      }

      final type = key.contains('/audio/') ? 'audio' : 'image';
      media.add(MediaAsset(assetPath: key, type: type));
    }

    await mediaRepo.upsertAll(media);
  }
}
