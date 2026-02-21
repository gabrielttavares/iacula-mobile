import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../features/liturgical/infrastructure/repositories/isar_liturgical_season_cache_repository.dart';
import '../../features/liturgical/infrastructure/services/remote_liturgical_season_service.dart';
import '../../features/notifications/application/use_cases/schedule_core_reminders_use_case.dart';
import '../../features/notifications/application/use_cases/schedule_liturgy_reminders_use_case.dart';
import '../../features/notifications/infrastructure/repositories/local_notification_scheduler_repository.dart';
import '../../features/quotes/infrastructure/repositories/sqlite_quote_indices_repository.dart';
import '../../features/settings/infrastructure/repositories/sqlite_settings_repository.dart';
import '../../features/storage/domain/entities/media_asset.dart';
import '../../features/storage/domain/repositories/media_catalog_repository.dart';
import '../../features/storage/infrastructure/repositories/isar_media_catalog_repository.dart';
import '../di/providers.dart';
import '../storage/isar/isar_store.dart';
import '../storage/sqlite/app_database.dart';

final class AppBootstrap {
  const AppBootstrap._();

  static Future<List<Override>> createProductionOverrides() async {
    final db = AppDatabase.instance;
    final isarStore = IsarStore.instance;

    final settingsRepo = SqliteSettingsRepository(db);
    final indicesRepo = SqliteQuoteIndicesRepository(db);
    final mediaRepo = IsarMediaCatalogRepository(isarStore);
    final liturgicalCacheRepo = IsarLiturgicalSeasonCacheRepository(isarStore);

    await _seedMediaCatalog(mediaRepo);

    final scheduler = LocalNotificationSchedulerRepository();
    await scheduler.initialize();

    final currentSettings = await settingsRepo.load();
    await scheduler.cancelAll();

    try {
      await ScheduleCoreRemindersUseCase(scheduler).call(currentSettings);
      await ScheduleLiturgyRemindersUseCase(scheduler).call(currentSettings);
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

    return [
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      quoteIndicesRepositoryProvider.overrideWithValue(indicesRepo),
      mediaCatalogRepositoryProvider.overrideWithValue(mediaRepo),
      liturgicalSeasonCacheRepositoryProvider.overrideWithValue(liturgicalCacheRepo),
      notificationSchedulerRepositoryProvider.overrideWithValue(scheduler),
      httpClientProvider.overrideWithValue(http.Client()),
      liturgicalSeasonServiceProvider.overrideWith((ref) {
        return RemoteLiturgicalSeasonService(
          httpClient: ref.watch(httpClientProvider),
          cacheRepository: ref.watch(liturgicalSeasonCacheRepositoryProvider),
        );
      }),
    ];
  }

  static Future<void> _seedMediaCatalog(MediaCatalogRepository mediaRepo) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets();

    final media = <MediaAsset>[];
    for (final key in assets) {
      if (!key.startsWith('assets/seed/images/') && !key.startsWith('assets/seed/audio/')) {
        continue;
      }

      final type = key.contains('/audio/') ? 'audio' : 'image';
      media.add(MediaAsset(assetPath: key, type: type));
    }

    await mediaRepo.upsertAll(media);
  }
}
