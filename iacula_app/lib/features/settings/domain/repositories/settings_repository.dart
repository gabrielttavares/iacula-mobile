import '../entities/settings.dart';

abstract interface class SettingsRepository {
  Future<Settings> load();
  Future<void> save(Settings settings);
}
