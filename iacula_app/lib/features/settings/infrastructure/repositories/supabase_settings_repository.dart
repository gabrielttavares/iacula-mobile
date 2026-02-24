import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';

abstract interface class SettingsRemoteGateway {
  Future<Settings?> fetchForUser(String userId);
  Future<void> upsertForUser(String userId, Settings settings);
}

final class SupabaseSettingsGateway implements SettingsRemoteGateway {
  SupabaseSettingsGateway(this._client);

  final SupabaseClient _client;

  @override
  Future<Settings?> fetchForUser(String userId) async {
    final rows = await _client
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .limit(1);

    final list = rows as List<dynamic>;
    if (list.isEmpty) {
      return null;
    }

    final row = Map<String, dynamic>.from(list.first as Map<dynamic, dynamic>);
    return Settings(
      intervalMinutes: row['interval_minutes'] as int,
      durationSeconds: row['duration_seconds'] as int,
      autostart: row['autostart'] == true,
      language: row['language'] as String,
      liturgyReminderSoundEnabled: row['liturgy_sound_enabled'] == true,
      liturgyReminderSoundVolume: (row['liturgy_sound_volume'] as num).toDouble(),
      laudesEnabled: row['laudes_enabled'] == true,
      vespersEnabled: row['vespers_enabled'] == true,
      complineEnabled: row['compline_enabled'] == true,
      oraMediaEnabled: row['ora_media_enabled'] == true,
      laudesTime: row['laudes_time'] as String,
      vespersTime: row['vespers_time'] as String,
      complineTime: row['compline_time'] as String,
      oraMediaTime: row['ora_media_time'] as String,
      onboardingCompleted: row['onboarding_completed'] == true,
    );
  }

  @override
  Future<void> upsertForUser(String userId, Settings settings) async {
    await _client.from('user_settings').upsert(<String, dynamic>{
      'user_id': userId,
      'interval_minutes': settings.intervalMinutes,
      'duration_seconds': settings.durationSeconds,
      'autostart': settings.autostart,
      'language': settings.language,
      'liturgy_sound_enabled': settings.liturgyReminderSoundEnabled,
      'liturgy_sound_volume': settings.liturgyReminderSoundVolume,
      'laudes_enabled': settings.laudesEnabled,
      'vespers_enabled': settings.vespersEnabled,
      'compline_enabled': settings.complineEnabled,
      'ora_media_enabled': settings.oraMediaEnabled,
      'laudes_time': settings.laudesTime,
      'vespers_time': settings.vespersTime,
      'compline_time': settings.complineTime,
      'ora_media_time': settings.oraMediaTime,
      'onboarding_completed': settings.onboardingCompleted,
    });
  }
}

final class SyncedSettingsRepository implements SettingsRepository {
  SyncedSettingsRepository({
    required SettingsRepository localRepository,
    required AuthRepository authRepository,
    required SettingsRemoteGateway remoteGateway,
  }) : _localRepository = localRepository,
       _authRepository = authRepository,
       _remoteGateway = remoteGateway;

  final SettingsRepository _localRepository;
  final AuthRepository _authRepository;
  final SettingsRemoteGateway _remoteGateway;

  @override
  Future<Settings> load() async {
    final local = await _localRepository.load();
    final user = await _authRepository.currentUser();
    if (user == null) {
      return local;
    }

    Settings? remote;
    try {
      remote = await _remoteGateway.fetchForUser(user.id);
    } catch (_) {
      return local;
    }

    if (remote == null) {
      try {
        await _remoteGateway.upsertForUser(user.id, local);
      } catch (_) {}
      return local;
    }

    // On a fresh device, local defaults should not overwrite a previously synced row.
    if (_isSame(local, Settings.defaults) && !_isSame(remote, Settings.defaults)) {
      await _localRepository.save(remote);
      return remote;
    }

    if (!_isSame(local, remote)) {
      try {
        await _remoteGateway.upsertForUser(user.id, local);
      } catch (_) {}
    }

    return local;
  }

  @override
  Future<void> save(Settings settings) async {
    await _localRepository.save(settings);
    final user = await _authRepository.currentUser();
    if (user == null) {
      return;
    }
    try {
      await _remoteGateway.upsertForUser(user.id, settings);
    } catch (_) {}
  }

  bool _isSame(Settings a, Settings b) {
    return a.intervalMinutes == b.intervalMinutes &&
        a.durationSeconds == b.durationSeconds &&
        a.autostart == b.autostart &&
        a.language == b.language &&
        a.liturgyReminderSoundEnabled == b.liturgyReminderSoundEnabled &&
        a.liturgyReminderSoundVolume == b.liturgyReminderSoundVolume &&
        a.laudesEnabled == b.laudesEnabled &&
        a.vespersEnabled == b.vespersEnabled &&
        a.complineEnabled == b.complineEnabled &&
        a.oraMediaEnabled == b.oraMediaEnabled &&
        a.laudesTime == b.laudesTime &&
        a.vespersTime == b.vespersTime &&
        a.complineTime == b.complineTime &&
        a.oraMediaTime == b.oraMediaTime &&
        a.onboardingCompleted == b.onboardingCompleted;
  }
}
