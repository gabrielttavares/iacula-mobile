import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';

final class UpdateSettingsUseCase {
  const UpdateSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(Settings settings) {
    return _repository.save(settings);
  }
}
