import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';

final class InMemorySettingsRepository implements SettingsRepository {
  Settings _value = Settings.defaults;

  @override
  Future<Settings> load() async => _value;

  @override
  Future<void> save(Settings settings) async {
    _value = settings;
  }
}
