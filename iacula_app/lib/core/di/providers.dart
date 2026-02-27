import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/infrastructure/repositories/in_memory_auth_repository.dart';
import '../../features/favorites/domain/entities/favorite_item.dart';
import '../../features/favorites/domain/repositories/favorite_repository.dart';
import '../../features/favorites/infrastructure/repositories/in_memory_favorite_repository.dart';
import '../../features/liturgia_diaria/application/use_cases/get_liturgy_period_use_case.dart';
import '../../features/meditation/domain/entities/meditation_item.dart';
import '../../features/meditation/domain/repositories/meditation_catalog_repository.dart';
import '../../features/meditation/infrastructure/repositories/asset_meditation_catalog_repository.dart';
import '../../features/liturgia_diaria/domain/repositories/liturgia_repository.dart';
import '../../features/liturgia_diaria/infrastructure/repositories/liturgia_cache_repository.dart';
import '../../features/liturgia_diaria/infrastructure/services/liturgia_api_service.dart';
import '../../features/liturgical/domain/repositories/liturgical_season_cache_repository.dart';
import '../../features/liturgical/domain/services/liturgical_season_service.dart';
import '../../features/liturgical/infrastructure/repositories/in_memory_liturgical_season_cache_repository.dart';
import '../../features/liturgical/infrastructure/services/fallback_liturgical_season_service.dart';
import '../../features/notifications/domain/repositories/last_delivered_card_repository.dart';
import '../../features/notifications/domain/repositories/notification_scheduler_repository.dart';
import '../../features/notifications/infrastructure/repositories/in_memory_last_delivered_card_repository.dart';
import '../../features/notifications/infrastructure/repositories/in_memory_notification_scheduler_repository.dart';
import '../../features/premium/application/premium_bloc.dart';
import '../../features/premium/domain/entities/premium_status.dart';
import '../../features/premium/domain/repositories/premium_repository.dart';
import '../../features/premium/infrastructure/isar_premium_repository.dart';
import '../../features/premium/infrastructure/purchase_service.dart';
import '../../features/prayers/application/use_cases/get_prayer_use_case.dart';
import '../../features/prayers/application/use_cases/get_prayer_catalog_use_case.dart';
import '../../features/prayers/domain/repositories/prayer_catalog_repository.dart';
import '../../features/prayers/domain/repositories/prayer_content_repository.dart';
import '../../features/prayers/infrastructure/repositories/asset_prayer_catalog_repository.dart';
import '../../features/prayers/infrastructure/repositories/asset_prayer_content_repository.dart';
import '../../features/quotes/application/use_cases/get_next_quote_use_case.dart';
import '../../features/quotes/domain/repositories/quote_content_repository.dart';
import '../../features/quotes/domain/repositories/quote_indices_repository.dart';
import '../../features/quotes/infrastructure/repositories/asset_quote_content_repository.dart';
import '../../features/quotes/infrastructure/repositories/in_memory_quote_indices_repository.dart';
import '../../features/settings/application/use_cases/get_settings_use_case.dart';
import '../../features/settings/application/use_cases/update_settings_use_case.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/infrastructure/repositories/in_memory_settings_repository.dart';
import '../../features/storage/domain/repositories/media_catalog_repository.dart';
import '../../features/storage/infrastructure/repositories/in_memory_media_catalog_repository.dart';

import '../../features/spiritual_data/domain/repositories/spiritual_entry_repository.dart';
import '../../features/spiritual_data/infrastructure/repositories/isar_spiritual_entry_repositories.dart';
import '../../features/spiritual_data/infrastructure/storage/spiritual_data_encryption_key_provider.dart';
import '../../features/spiritual_data/infrastructure/storage/spiritual_data_isar_store.dart';
import '../../features/plan_of_life/domain/repositories/plan_completion_repository.dart';
import '../../features/plan_of_life/infrastructure/repositories/isar_plan_completion_repository.dart';
import '../../features/plan_of_life/application/use_cases/get_daily_plan_use_case.dart';
import '../../features/plan_of_life/application/use_cases/toggle_item_use_case.dart';
import '../../features/plan_of_life/application/use_cases/add_plan_item_use_case.dart';
import '../../features/plan_of_life/application/use_cases/update_plan_item_use_case.dart';
import '../../features/plan_of_life/application/use_cases/delete_plan_item_use_case.dart';
import '../../features/plan_of_life/application/plan_of_life_notifier.dart';

import '../../features/doctrina/application/use_cases/get_doctrine_catalog_use_case.dart';
import '../../features/doctrina/domain/entities/doctrine_entry.dart';
import '../../features/doctrina/domain/repositories/doctrine_repository.dart';
import '../../features/doctrina/infrastructure/repositories/asset_doctrine_repository.dart';
import '../../features/spiritual_data/domain/entities/spiritual_entry.dart';
import '../../features/sync/domain/repositories/sync_orchestrator.dart';
import '../../features/sync/domain/repositories/sync_state_repository.dart';
import '../../features/sync/infrastructure/repositories/isar_sync_state_repository.dart';
import '../../features/sync/infrastructure/repositories/supabase_spiritual_sync_repository.dart';
import '../../features/sync/infrastructure/services/background_sync_scheduler.dart';
import '../../features/sync/infrastructure/services/connectivity_sync_service.dart';
import '../../features/sync/infrastructure/services/default_sync_orchestrator.dart';
import '../../features/sync/infrastructure/services/noop_sync_orchestrator.dart';
import '../bootstrap/bootstrap_status.dart';
import '../config/app_env.dart';
import '../storage/isar/isar_store.dart';

final appEnvProvider = Provider<AppEnv>((ref) => AppEnv.fromDartDefines());

final bootstrapStatusProvider = Provider<BootstrapStatus>((ref) {
  return const BootstrapStatus();
});

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  return null;
});

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final liturgiaApiServiceProvider = Provider<LiturgiaApiService>((ref) {
  return LiturgiaApiService(httpClient: ref.watch(httpClientProvider));
});

final liturgiaCacheRepositoryProvider = Provider<LiturgiaRepository>((ref) {
  return LiturgiaCacheRepository(
    apiService: ref.watch(liturgiaApiServiceProvider),
  );
});

final liturgicalSeasonCacheRepositoryProvider =
    Provider<LiturgicalSeasonCacheRepository>((ref) {
      return InMemoryLiturgicalSeasonCacheRepository();
    });

final liturgicalSeasonServiceProvider = Provider<LiturgicalSeasonService>((
  ref,
) {
  return const FallbackLiturgicalSeasonService();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return InMemorySettingsRepository();
});

final quoteContentRepositoryProvider = Provider<QuoteContentRepository>((ref) {
  return const AssetQuoteContentRepository();
});

final quoteIndicesRepositoryProvider = Provider<QuoteIndicesRepository>((ref) {
  return InMemoryQuoteIndicesRepository();
});

final prayerContentRepositoryProvider = Provider<PrayerContentRepository>((
  ref,
) {
  return const AssetPrayerContentRepository();
});

final prayerCatalogRepositoryProvider = Provider<PrayerCatalogRepository>((
  ref,
) {
  return AssetPrayerCatalogRepository();
});

final notificationSchedulerRepositoryProvider =
    Provider<NotificationSchedulerRepository>((ref) {
      return InMemoryNotificationSchedulerRepository();
    });

final lastDeliveredCardRepositoryProvider =
    Provider<LastDeliveredCardRepository>((ref) {
      return InMemoryLastDeliveredCardRepository();
    });

final localDisplayNameProvider = FutureProvider<String?>((ref) async {
  final settings = await ref.read(getSettingsUseCaseProvider).call();
  return settings.displayName;
});

final meditationCatalogRepositoryProvider =
    Provider<MeditationCatalogRepository>((ref) {
      return AssetMeditationCatalogRepository();
    });

final meditationCatalogProvider = FutureProvider<List<MeditationItem>>((ref) {
  return ref.watch(meditationCatalogRepositoryProvider).listAll();
});

final doctrineRepositoryProvider = Provider<DoctrineRepository>((ref) {
  return AssetDoctrineRepository();
});

final doctrineCatalogProvider = FutureProvider<List<DoctrineEntry>>((ref) {
  return ref.watch(doctrineRepositoryProvider).listCatalog(language: 'pt-br');
});

final getDoctrineCatalogUseCaseProvider =
    Provider<GetDoctrineCatalogUseCase>((ref) {
      return GetDoctrineCatalogUseCase(
        repository: ref.watch(doctrineRepositoryProvider),
      );
    });

final mediaCatalogRepositoryProvider = Provider<MediaCatalogRepository>((ref) {
  return InMemoryMediaCatalogRepository();
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return InMemoryFavoriteRepository();
});

final favoritesProvider = StreamProvider<List<FavoriteItem>>((ref) {
  return ref.watch(favoriteRepositoryProvider).watchAll();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return InMemoryAuthRepository();
});

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  return IsarPremiumRepository(store: IsarStore.instance);
});

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return StorePurchaseService();
});

final premiumBlocProvider = Provider<PremiumBloc>((ref) {
  final bloc = PremiumBloc(
    repository: ref.watch(premiumRepositoryProvider),
    purchaseService: ref.watch(purchaseServiceProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
  ref.onDispose(bloc.dispose);
  unawaited(bloc.add(const CheckPremium()));
  return bloc;
});

final premiumStateProvider = StreamProvider<PremiumState>((ref) {
  final bloc = ref.watch(premiumBlocProvider);
  return () async* {
    yield bloc.state;
    yield* bloc.states;
  }();
});

final premiumStatusProvider = StreamProvider<PremiumStatus>((ref) {
  return ref.watch(premiumRepositoryProvider).watchStatus();
});

final syncOrchestratorProvider = Provider<SyncOrchestrator>((ref) {
  final env = ref.watch(appEnvProvider);
  final gateway = ref.watch(spiritualSyncGatewayProvider);

  if (!env.authSyncEnabled || gateway == null) {
    return const NoopSyncOrchestrator();
  }

  return DefaultSyncOrchestrator(
    authRepository: ref.watch(authRepositoryProvider),
    syncStateRepository: ref.watch(syncStateRepositoryProvider),
    modules: [
      SyncModuleAdapter(
        module: SpiritualModule.planOfLife,
        localRepository: ref.watch(planOfLifeEntryRepositoryProvider),
        remoteRepository: SupabaseSpiritualSyncRepository(
          module: SpiritualModule.planOfLife,
          table: 'plan_of_life_entries',
          gateway: gateway,
        ),
      ),
      SyncModuleAdapter(
        module: SpiritualModule.examination,
        localRepository: ref.watch(examinationEntryRepositoryProvider),
        remoteRepository: SupabaseSpiritualSyncRepository(
          module: SpiritualModule.examination,
          table: 'examination_entries',
          gateway: gateway,
        ),
      ),
      SyncModuleAdapter(
        module: SpiritualModule.prayerIntention,
        localRepository: ref.watch(prayerIntentionEntryRepositoryProvider),
        remoteRepository: SupabaseSpiritualSyncRepository(
          module: SpiritualModule.prayerIntention,
          table: 'prayer_intention_entries',
          gateway: gateway,
        ),
      ),
    ],
  );
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final connectivitySyncServiceProvider = Provider<ConnectivitySyncService>((
  ref,
) {
  final service = ConnectivitySyncService(
    connectivity: ref.watch(connectivityProvider),
    orchestrator: ref.watch(syncOrchestratorProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final backgroundSyncGatewayProvider = Provider<BackgroundSyncGateway>((ref) {
  return const WorkmanagerBackgroundSyncGateway();
});

final backgroundSyncSchedulerProvider = Provider<BackgroundSyncScheduler>((
  ref,
) {
  return BackgroundSyncScheduler(
    gateway: ref.watch(backgroundSyncGatewayProvider),
  );
});

final getSettingsUseCaseProvider = Provider<GetSettingsUseCase>((ref) {
  return GetSettingsUseCase(ref.watch(settingsRepositoryProvider));
});

final updateSettingsUseCaseProvider = Provider<UpdateSettingsUseCase>((ref) {
  return UpdateSettingsUseCase(ref.watch(settingsRepositoryProvider));
});

final getNextQuoteUseCaseProvider = Provider<GetNextQuoteUseCase>((ref) {
  return GetNextQuoteUseCase(
    contentRepository: ref.watch(quoteContentRepositoryProvider),
    indicesRepository: ref.watch(quoteIndicesRepositoryProvider),
    liturgicalSeasonService: ref.watch(liturgicalSeasonServiceProvider),
  );
});

final getPrayerUseCaseProvider = Provider<GetPrayerUseCase>((ref) {
  return GetPrayerUseCase(
    prayerRepository: ref.watch(prayerContentRepositoryProvider),
    liturgicalSeasonService: ref.watch(liturgicalSeasonServiceProvider),
  );
});

final getPrayerCatalogUseCaseProvider = Provider<GetPrayerCatalogUseCase>((
  ref,
) {
  return GetPrayerCatalogUseCase(
    repository: ref.watch(prayerCatalogRepositoryProvider),
  );
});

final getLiturgyPeriodUseCaseProvider = Provider<GetLiturgyPeriodUseCase>((
  ref,
) {
  return GetLiturgyPeriodUseCase(ref.watch(liturgiaCacheRepositoryProvider));
});

// -- Spiritual Data / Plan of Life Providers --

final spiritualDataKeyProvider = Provider<EncryptionKeyProvider>((ref) {
  return SpiritualDataEncryptionKeyProvider(store: FlutterSecureKvStore());
});

final spiritualDataIsarStoreProvider = Provider<SpiritualDataIsarStore>((ref) {
  return SpiritualDataIsarStore(
    keyProvider: ref.watch(spiritualDataKeyProvider),
  );
});

final planOfLifeEntryRepositoryProvider = Provider<SpiritualEntryRepository>((
  ref,
) {
  return IsarPlanOfLifeSpiritualEntryRepository(
    ref.watch(spiritualDataIsarStoreProvider),
  );
});

final examinationEntryRepositoryProvider = Provider<SpiritualEntryRepository>((
  ref,
) {
  return IsarExaminationSpiritualEntryRepository(
    ref.watch(spiritualDataIsarStoreProvider),
  );
});

final prayerIntentionEntryRepositoryProvider =
    Provider<SpiritualEntryRepository>((ref) {
      return IsarPrayerIntentionSpiritualEntryRepository(
        ref.watch(spiritualDataIsarStoreProvider),
      );
    });

final planCompletionRepositoryProvider = Provider<PlanCompletionRepository>((
  ref,
) {
  return IsarPlanCompletionRepository(
    ref.watch(spiritualDataIsarStoreProvider),
  );
});

final syncStateRepositoryProvider = Provider<SyncStateRepository>((ref) {
  return IsarSyncStateRepository(ref.watch(spiritualDataIsarStoreProvider));
});

final spiritualSyncGatewayProvider = Provider<SpiritualSyncGateway?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return SupabaseSpiritualSyncGateway(client);
});

final getDailyPlanUseCaseProvider = Provider<GetDailyPlanUseCase>((ref) {
  return GetDailyPlanUseCase(
    ref.watch(planOfLifeEntryRepositoryProvider),
    ref.watch(planCompletionRepositoryProvider),
  );
});

final toggleItemUseCaseProvider = Provider<ToggleItemUseCase>((ref) {
  return ToggleItemUseCase(ref.watch(planCompletionRepositoryProvider));
});

final addPlanItemUseCaseProvider = Provider<AddPlanItemUseCase>((ref) {
  return AddPlanItemUseCase(ref.watch(planOfLifeEntryRepositoryProvider));
});

final updatePlanItemUseCaseProvider = Provider<UpdatePlanItemUseCase>((ref) {
  return UpdatePlanItemUseCase(ref.watch(planOfLifeEntryRepositoryProvider));
});

final deletePlanItemUseCaseProvider = Provider<DeletePlanItemUseCase>((ref) {
  return DeletePlanItemUseCase(ref.watch(planOfLifeEntryRepositoryProvider));
});

final planOfLifeNotifierProvider =
    StateNotifierProvider<PlanOfLifeNotifier, PlanOfLifeState>((ref) {
      return PlanOfLifeNotifier(
        getDailyPlan: ref.watch(getDailyPlanUseCaseProvider),
        toggleItem: ref.watch(toggleItemUseCaseProvider),
        addItem: ref.watch(addPlanItemUseCaseProvider),
        updateItem: ref.watch(updatePlanItemUseCaseProvider),
        deleteItem: ref.watch(deletePlanItemUseCaseProvider),
      );
    });
