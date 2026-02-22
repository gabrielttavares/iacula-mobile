import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/infrastructure/repositories/in_memory_auth_repository.dart';
import '../../features/liturgia_diaria/application/use_cases/get_liturgy_period_use_case.dart';
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
import '../../features/prayers/application/use_cases/get_prayer_use_case.dart';
import '../../features/prayers/domain/repositories/prayer_content_repository.dart';
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
import '../../features/sync/domain/repositories/sync_orchestrator.dart';
import '../../features/sync/infrastructure/services/background_sync_scheduler.dart';
import '../../features/sync/infrastructure/services/connectivity_sync_service.dart';
import '../config/app_env.dart';

final appEnvProvider = Provider<AppEnv>((ref) => AppEnv.fromDartDefines());

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

final notificationSchedulerRepositoryProvider =
    Provider<NotificationSchedulerRepository>((ref) {
      return InMemoryNotificationSchedulerRepository();
    });

final lastDeliveredCardRepositoryProvider =
    Provider<LastDeliveredCardRepository>((ref) {
      return InMemoryLastDeliveredCardRepository();
    });

final mediaCatalogRepositoryProvider = Provider<MediaCatalogRepository>((ref) {
  return InMemoryMediaCatalogRepository();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return InMemoryAuthRepository();
});

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final syncOrchestratorProvider = Provider<SyncOrchestrator>((ref) {
  return const _NoopSyncOrchestrator();
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

final getLiturgyPeriodUseCaseProvider = Provider<GetLiturgyPeriodUseCase>((
  ref,
) {
  return GetLiturgyPeriodUseCase(ref.watch(liturgiaCacheRepositoryProvider));
});

final class _NoopSyncOrchestrator implements SyncOrchestrator {
  const _NoopSyncOrchestrator();

  @override
  Future<void> syncAll() async {}

  @override
  Future<void> syncModule(String module) async {}
}
