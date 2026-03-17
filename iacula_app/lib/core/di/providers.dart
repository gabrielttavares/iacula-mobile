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
import '../../features/liturgical/domain/repositories/liturgical_season_cache_repository.dart';
import '../../features/liturgical/domain/liturgical_context.dart';
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
import '../../features/premium/infrastructure/always_unlocked_premium_repository.dart';
import '../../features/premium/infrastructure/purchase_service.dart';
import '../../features/prayers/application/use_cases/get_prayer_use_case.dart';
import '../../features/prayers/application/use_cases/get_prayer_catalog_use_case.dart';
import '../../features/prayers/domain/repositories/prayer_catalog_repository.dart';
import '../../features/prayers/domain/repositories/prayer_content_repository.dart';
import '../../features/prayers/domain/entities/prayer_catalog_entry.dart';
import '../../features/prayers/infrastructure/repositories/asset_prayer_catalog_repository.dart';
import '../../features/prayers/infrastructure/repositories/asset_prayer_content_repository.dart';
import '../../features/quotes/application/use_cases/get_next_quote_use_case.dart';
import '../../features/quotes/application/use_cases/get_next_escriva_points_quote_use_case.dart';
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

import '../../features/prayer_intentions/application/use_cases/list_intentions_use_case.dart';
import '../../features/prayer_intentions/application/use_cases/add_intention_use_case.dart';
import '../../features/prayer_intentions/application/use_cases/update_intention_use_case.dart';
import '../../features/prayer_intentions/application/use_cases/delete_intention_use_case.dart';
import '../../features/prayer_intentions/application/use_cases/respond_intention_use_case.dart';
import '../../features/prayer_intentions/application/use_cases/schedule_prayer_intention_reminder_use_case.dart';
import '../../features/prayer_intentions/application/use_cases/cancel_prayer_intention_reminder_use_case.dart';
import '../../features/prayer_intentions/application/prayer_intentions_notifier.dart';

import '../../features/custom_phrases/application/custom_phrases_notifier.dart';
import '../../features/custom_phrases/application/use_cases/schedule_phrase_notifications_use_case.dart';
import '../../features/custom_phrases/domain/entities/custom_phrase.dart';
import '../../features/custom_phrases/domain/repositories/custom_phrase_repository.dart';
import '../../features/custom_phrases/infrastructure/repositories/isar_custom_phrase_repository.dart';
import '../../features/prayer_activity/application/prayer_activity_logger.dart';
import '../../features/prayer_activity/application/streak_calculator.dart';
import '../../features/prayer_activity/domain/entities/streak_info.dart';
import '../../features/prayer_activity/domain/entities/dashboard_stats.dart';
import '../../features/prayer_activity/domain/repositories/prayer_activity_repository.dart';
import '../../features/prayer_activity/infrastructure/repositories/isar_prayer_activity_repository.dart';
import '../../features/search/application/app_search_service.dart';
import '../../features/bible/domain/entities/bible_book.dart';
import '../../features/bible/domain/entities/bible_chapter_ref.dart';
import '../../features/bible/domain/entities/bible_verse.dart';
import '../../features/bible/domain/repositories/bible_repository.dart';
import '../../features/bible/infrastructure/repositories/asset_bible_repository.dart';
import '../../features/bible/presentation/bible_prefs_notifier.dart';
import '../../features/confession/domain/entities/confession_examination_item.dart';
import '../../features/confession/domain/repositories/confession_examination_repository.dart';
import '../../features/confession/domain/services/native_share_service.dart';
import '../../features/confession/infrastructure/repositories/asset_confession_examination_repository.dart';
import '../../features/confession/infrastructure/services/share_plus_native_share_service.dart';
import '../../features/journal/domain/entities/journal_entry.dart';
import '../../features/journal/domain/repositories/journal_repository.dart';
import '../../features/journal/infrastructure/repositories/isar_journal_repository.dart';
import '../../features/journal_prompts/domain/entities/journal_prompt.dart';
import '../../features/journal_prompts/domain/repositories/journal_prompt_repository.dart';
import '../../features/journal_prompts/infrastructure/repositories/asset_journal_prompt_repository.dart';
import '../../features/examination/domain/entities/examination_reflection_item.dart';
import '../../features/examination/domain/repositories/examination_reflection_repository.dart';
import '../../features/examination/infrastructure/repositories/isar_examination_reflection_repository.dart';
import '../../features/leituras/data/repositories/leitura_repository.dart';
import '../../features/leituras/data/sources/leitura_local_source.dart';
import '../../features/reading/domain/repositories/reading_annotation_repository.dart';
import '../../features/reading/infrastructure/repositories/in_memory_reading_annotation_repository.dart';
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

final themeModeProvider = StateProvider<String>((ref) => 'dark');

final appEnvProvider = Provider<AppEnv>((ref) => AppEnv.fromDartDefines());

final bootstrapStatusProvider = Provider<BootstrapStatus>((ref) {
  return const BootstrapStatus();
});

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  return null;
});

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final liturgicalSeasonCacheRepositoryProvider =
    Provider<LiturgicalSeasonCacheRepository>((ref) {
      return InMemoryLiturgicalSeasonCacheRepository();
    });

final liturgicalSeasonServiceProvider = Provider<LiturgicalSeasonService>((
  ref,
) {
  return const FallbackLiturgicalSeasonService();
});

final liturgicalContextProvider =
    FutureProvider.family<LiturgicalContext, DateTime?>((ref, date) async {
      return ref
          .watch(liturgicalSeasonServiceProvider)
          .getCurrentContext(date: date);
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
  return AssetPrayerContentRepository();
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

final notificationPermissionProvider = StateProvider<bool>((ref) => true);

final lastDeliveredCardRepositoryProvider =
    Provider<LastDeliveredCardRepository>((ref) {
      return InMemoryLastDeliveredCardRepository();
    });

final localDisplayNameProvider = FutureProvider<String?>((ref) async {
  final settings = await ref.read(getSettingsUseCaseProvider).call();
  return settings.displayName;
});

final journalPromptRepositoryProvider = Provider<JournalPromptRepository>((
  ref,
) {
  return AssetJournalPromptRepository();
});

final journalPromptCatalogProvider = FutureProvider<List<JournalPrompt>>((
  ref,
) async {
  return ref.watch(journalPromptRepositoryProvider).listAll();
});

final leituraLocalSourceProvider = Provider<LeituraLocalSource>((ref) {
  return LeituraLocalSource();
});

final leituraRepositoryProvider = Provider<LeituraRepository>((ref) {
  return LeituraRepository(localSource: ref.watch(leituraLocalSourceProvider));
});

final appSearchServiceProvider = Provider<AppSearchService>((ref) {
  return AppSearchService(
    prayerCatalogRepository: ref.watch(prayerCatalogRepositoryProvider),
    leituraRepository: ref.watch(leituraRepositoryProvider),
    quoteContentRepository: ref.watch(quoteContentRepositoryProvider),
  );
});

final mediaCatalogRepositoryProvider = Provider<MediaCatalogRepository>((ref) {
  return InMemoryMediaCatalogRepository();
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return InMemoryFavoriteRepository();
});

final readingAnnotationRepositoryProvider =
    Provider<ReadingAnnotationRepository>((ref) {
      return InMemoryReadingAnnotationRepository();
    });

final favoritesProvider = StreamProvider<List<FavoriteItem>>((ref) {
  return ref.watch(favoriteRepositoryProvider).watchAll();
});

/// Returns the favorite item whose [quoteText] matches, or null.
final favoriteItemByQuoteTextProvider =
    Provider.family<AsyncValue<FavoriteItem?>, String>((ref, quoteText) {
      final async = ref.watch(favoritesProvider);
      return async.whenData(
        (list) => list.where((e) => e.quoteText == quoteText).firstOrNull,
      );
    });

/// Returns the favorite item whose [prayerSlug] matches, or null.
final favoriteItemByPrayerSlugProvider =
    Provider.family<AsyncValue<FavoriteItem?>, String>((ref, slug) {
      final async = ref.watch(favoritesProvider);
      return async.whenData(
        (list) => list.where((e) => e.prayerSlug == slug).firstOrNull,
      );
    });

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return InMemoryAuthRepository();
});

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  // TODO(gabrielttav): swap back to IsarPremiumRepository when paid premium returns.
  return AlwaysUnlockedPremiumRepository();
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

final getNextEscrivaPointsQuoteUseCaseProvider =
    Provider<GetNextEscrivaPointsQuoteUseCase>((ref) {
      return GetNextEscrivaPointsQuoteUseCase(
        ref.watch(leituraRepositoryProvider),
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

final prayerEntryBySlugProvider =
    FutureProvider.family<PrayerCatalogEntry?, String>((ref, slug) async {
      final settings = await ref.watch(getSettingsUseCaseProvider).call();
      final useCase = ref.watch(getPrayerCatalogUseCaseProvider);
      return useCase.getBySlug(language: settings.language, slug: slug);
    });

// -- Spiritual Data Providers --

final spiritualDataKeyProvider = Provider<EncryptionKeyProvider>((ref) {
  return SpiritualDataEncryptionKeyProvider(store: FlutterSecureKvStore());
});

final spiritualDataIsarStoreProvider = Provider<SpiritualDataIsarStore>((ref) {
  return SpiritualDataIsarStore(
    keyProvider: ref.watch(spiritualDataKeyProvider),
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

final confessionExaminationRepositoryProvider =
    Provider<ConfessionExaminationRepository>((ref) {
      return AssetConfessionExaminationRepository();
    });

final confessionExaminationItemsProvider =
    FutureProvider<List<ConfessionExaminationItem>>((ref) {
      return ref.watch(confessionExaminationRepositoryProvider).listAll();
    });

final nativeShareServiceProvider = Provider<NativeShareService>((ref) {
  return const SharePlusNativeShareService();
});

final examinationReflectionRepositoryProvider =
    Provider<ExaminationReflectionRepository>((ref) {
      return IsarExaminationReflectionRepository(
        store: ref.watch(spiritualDataIsarStoreProvider),
      );
    });

final examinationReflectionItemsProvider =
    StreamProvider<List<ExaminationReflectionItem>>((ref) {
      return ref.watch(examinationReflectionRepositoryProvider).watchAll();
    });

final syncStateRepositoryProvider = Provider<SyncStateRepository>((ref) {
  return IsarSyncStateRepository(ref.watch(spiritualDataIsarStoreProvider));
});

final spiritualSyncGatewayProvider = Provider<SpiritualSyncGateway?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return SupabaseSpiritualSyncGateway(client);
});

// -- Prayer Intentions Providers --

final listIntentionsUseCaseProvider = Provider<ListIntentionsUseCase>((ref) {
  return ListIntentionsUseCase(
    ref.watch(prayerIntentionEntryRepositoryProvider),
  );
});

final addIntentionUseCaseProvider = Provider<AddIntentionUseCase>((ref) {
  return AddIntentionUseCase(ref.watch(prayerIntentionEntryRepositoryProvider));
});

final updateIntentionUseCaseProvider = Provider<UpdateIntentionUseCase>((ref) {
  return UpdateIntentionUseCase(
    ref.watch(prayerIntentionEntryRepositoryProvider),
  );
});

final deleteIntentionUseCaseProvider = Provider<DeleteIntentionUseCase>((ref) {
  return DeleteIntentionUseCase(
    ref.watch(prayerIntentionEntryRepositoryProvider),
    ref.watch(cancelPrayerIntentionReminderUseCaseProvider),
  );
});

final respondIntentionUseCaseProvider = Provider<RespondIntentionUseCase>((
  ref,
) {
  return RespondIntentionUseCase(
    ref.watch(prayerIntentionEntryRepositoryProvider),
  );
});

final schedulePrayerIntentionReminderUseCaseProvider =
    Provider<SchedulePrayerIntentionReminderUseCase>((ref) {
      return SchedulePrayerIntentionReminderUseCase(
        ref.watch(prayerIntentionEntryRepositoryProvider),
        ref.watch(notificationSchedulerRepositoryProvider),
      );
    });

final cancelPrayerIntentionReminderUseCaseProvider =
    Provider<CancelPrayerIntentionReminderUseCase>((ref) {
      return CancelPrayerIntentionReminderUseCase(
        ref.watch(prayerIntentionEntryRepositoryProvider),
        ref.watch(notificationSchedulerRepositoryProvider),
      );
    });

final prayerIntentionsNotifierProvider =
    StateNotifierProvider<PrayerIntentionsNotifier, PrayerIntentionsState>((
      ref,
    ) {
      return PrayerIntentionsNotifier(
        listIntentions: ref.watch(listIntentionsUseCaseProvider),
        addIntention: ref.watch(addIntentionUseCaseProvider),
        updateIntention: ref.watch(updateIntentionUseCaseProvider),
        deleteIntention: ref.watch(deleteIntentionUseCaseProvider),
        respondIntention: ref.watch(respondIntentionUseCaseProvider),
        scheduleReminder: ref.watch(
          schedulePrayerIntentionReminderUseCaseProvider,
        ),
        cancelReminder: ref.watch(cancelPrayerIntentionReminderUseCaseProvider),
      );
    });

// -- Custom Phrases Providers --

final customPhraseRepositoryProvider = Provider<CustomPhraseRepository>((ref) {
  return IsarCustomPhraseRepository(ref.watch(spiritualDataIsarStoreProvider));
});

final schedulePhraseNotificationsUseCaseProvider =
    Provider<SchedulePhraseNotificationsUseCase>((ref) {
      return SchedulePhraseNotificationsUseCase(
        ref.watch(notificationSchedulerRepositoryProvider),
        ref.watch(customPhraseRepositoryProvider),
      );
    });

final customPhrasesNotifierProvider =
    AsyncNotifierProvider<CustomPhrasesNotifier, List<CustomPhrase>>(() {
      return CustomPhrasesNotifier();
    });

// -- Prayer Activity / Streak Providers --

final prayerActivityRepositoryProvider = Provider<PrayerActivityRepository>((
  ref,
) {
  return IsarPrayerActivityRepository(store: IsarStore.instance);
});

final prayerActivityLoggerProvider = Provider<PrayerActivityLogger>((ref) {
  return PrayerActivityLogger(
    repository: ref.watch(prayerActivityRepositoryProvider),
  );
});

final streakInfoProvider = FutureProvider<StreakInfo>((ref) async {
  final repo = ref.watch(prayerActivityRepositoryProvider);
  final entries = await repo.listAll();
  return const StreakCalculator().computeStreak(entries);
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final repo = ref.watch(prayerActivityRepositoryProvider);
  final entries = await repo.listAll();
  return const StreakCalculator().computeDashboard(entries);
});

// -- Bible Providers --

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return AssetBibleRepository();
});

final biblePrefsProvider =
    StateNotifierProvider<BiblePrefsNotifier, BiblePrefs>((ref) {
      return BiblePrefsNotifier();
    });

final bibleBooksProvider = FutureProvider<List<BibleBook>>((ref) async {
  return ref.watch(bibleRepositoryProvider).listBooks();
});

final bibleChapterProvider =
    FutureProvider.family<List<BibleVerse>, BibleChapterRef>((
      ref,
      chapter,
    ) async {
      return ref
          .watch(bibleRepositoryProvider)
          .getChapter(
            bookAbbrev: chapter.bookAbbrev,
            chapterNumber: chapter.chapterNumber,
          );
    });

// -- Journal Providers --

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return IsarJournalRepository(store: IsarStore.instance);
});

final journalEntriesProvider = FutureProvider<List<JournalEntry>>((ref) async {
  return ref.watch(journalRepositoryProvider).listAll();
});
