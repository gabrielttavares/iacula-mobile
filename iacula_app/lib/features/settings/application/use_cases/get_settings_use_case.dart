import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';

final class GetSettingsUseCase {
  const GetSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Settings> call() {
    return _repository.load();
  }
}
