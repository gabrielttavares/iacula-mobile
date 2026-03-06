import 'dart:developer' as developer;

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
import '../../features/liturgical/infrastructure/repositories/isar_liturgical_season_cache_repository.dart';
import '../../features/liturgical/infrastructure/services/remote_liturgical_season_service.dart';
import '../../features/leituras/data/repositories/leitura_repository.dart';
import '../../features/leituras/data/sources/leitura_local_source.dart';
import '../../features/notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import '../../features/notifications/infrastructure/repositories/local_notification_scheduler_repository.dart';
import '../../features/notifications/infrastructure/repositories/sqlite_last_delivered_card_repository.dart';
import '../../features/quotes/application/use_cases/get_next_escriva_points_quote_use_case.dart';
import '../../features/plan_of_life/application/use_cases/seed_default_items_use_case.dart';
import '../../features/premium/domain/entities/premium_status.dart';
import '../../features/premium/domain/repositories/premium_repository.dart';
import '../../features/premium/infrastructure/isar_premium_repository.dart';
import '../../features/premium/infrastructure/supabase_premium_repository.dart';
import '../../features/quotes/application/use_cases/get_next_quote_use_case.dart';
import '../../features/quotes/infrastructure/repositories/asset_quote_content_repository.dart';
import '../../features/quotes/infrastructure/repositories/sqlite_quote_indices_repository.dart';
import '../../features/settings/infrastructure/repositories/sqlite_settings_repository.dart';
import '../../features/spiritual_data/domain/entities/spiritual_entry.dart';
import '../../features/spiritual_data/infrastructure/repositories/isar_spiritual_entry_repositories.dart';
import '../../features/spiritual_data/infrastructure/storage/spiritual_data_encryption_key_provider.dart';
import '../../features/spiritual_data/infrastructure/storage/spiritual_data_isar_store.dart';
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
    final lastDeliveredCardRepo = SqliteLastDeliveredCardRepository(db);
    final mediaRepo = IsarMediaCatalogRepository(isarStore);
    final favoriteRepo = IsarFavoriteRepository(store: isarStore);
    final localPremiumRepo = IsarPremiumRepository(store: isarStore);
    final localCustomPhraseRepo = IsarCustomPhraseRepository(spiritualStore);
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
    final liturgicalCacheRepo = IsarLiturgicalSeasonCacheRepository(isarStore);
    final httpClient = http.Client();
    final liturgicalSeasonService = RemoteLiturgicalSeasonService(
      httpClient: httpClient,
      cacheRepository: liturgicalCacheRepo,
    );
    final quoteUseCase = GetNextQuoteUseCase(
      contentRepository: const AssetQuoteContentRepository(),
      indicesRepository: indicesRepo,
      liturgicalSeasonService: liturgicalSeasonService,
    );
    final escrivaPointsUseCase = GetNextEscrivaPointsQuoteUseCase(
      LeituraRepository(localSource: LeituraLocalSource()),
    );

    await _seedMediaCatalog(mediaRepo);

    final scheduler = LocalNotificationSchedulerRepository();
    await scheduler.initialize();

    final currentSettings = await settingsRepo.load();
    await scheduler.cancelAll();

    try {
      await ScheduleCoreRemindersUseCase(
        scheduler,
        quoteFetcher: ({required String language, required DateTime now}) {
          if (currentSettings.escrivaPointsFeedEnabled) {
            return escrivaPointsUseCase.call(language: language, now: now);
          }

          return quoteUseCase.call(language: language, now: now);
        },
        lastDeliveredCardRepository: lastDeliveredCardRepo,
      ).call(currentSettings);
      await SchedulePhraseNotificationsUseCase(
        scheduler,
        localCustomPhraseRepo,
      ).call();
    } on PlatformException catch (e, st) {
      developer.log(
        'Notification scheduling skipped: ${e.code} ${e.message}',
        name: 'AppBootstrap',
        error: e,
        stackTrace: st,
      );
    } catch (e, st) {
      developer.log(
        'Notification scheduling failed during bootstrap.',
        name: 'AppBootstrap',
        error: e,
        stackTrace: st,
      );
    }

    AuthRepository authRepository = InMemoryAuthRepository();
    PremiumRepository premiumRepository = localPremiumRepo;
    SyncOrchestrator syncOrchestrator = const NoopSyncOrchestrator();
    var bootstrapStatus = const BootstrapStatus();
    SupabaseClient? supabaseClient;

    // Seed default plan of life items
    await SeedDefaultItemsUseCase(
      IsarPlanOfLifeSpiritualEntryRepository(spiritualStore),
    ).call();

    if (env.authSyncEnabled && env.hasSupabase) {
      try {
        await Supabase.initialize(
          url: env.supabaseUrl!,
          anonKey: env.supabaseAnonKey!,
        );

        supabaseClient = Supabase.instance.client;
        authRepository = SupabaseAuthRepository(supabaseClient);
        premiumRepository = SyncedPremiumRepository(
          localRepository: localPremiumRepo,
          authRepository: authRepository,
          remoteGateway: SupabasePremiumGateway(supabaseClient),
        );

        final gateway = SupabaseSpiritualSyncGateway(supabaseClient);

        syncOrchestrator = DefaultSyncOrchestrator(
          authRepository: authRepository,
          syncStateRepository: IsarSyncStateRepository(spiritualStore),
          modules: [
            SyncModuleAdapter(
              module: SpiritualModule.planOfLife,
              localRepository: IsarPlanOfLifeSpiritualEntryRepository(
                spiritualStore,
              ),
              remoteRepository: SupabaseSpiritualSyncRepository(
                module: SpiritualModule.planOfLife,
                table: 'plan_of_life_entries',
                gateway: gateway,
              ),
            ),
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
        premiumRepository = localPremiumRepo;
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
      lastDeliveredCardRepositoryProvider.overrideWithValue(
        lastDeliveredCardRepo,
      ),
      mediaCatalogRepositoryProvider.overrideWithValue(mediaRepo),
      favoriteRepositoryProvider.overrideWithValue(favoriteRepo),
      premiumRepositoryProvider.overrideWithValue(premiumRepository),
      customPhraseRepositoryProvider.overrideWithValue(localCustomPhraseRepo),
      liturgicalSeasonCacheRepositoryProvider.overrideWithValue(
        liturgicalCacheRepo,
      ),
      notificationSchedulerRepositoryProvider.overrideWithValue(scheduler),
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
