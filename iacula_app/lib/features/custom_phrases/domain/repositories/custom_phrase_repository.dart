import '../entities/custom_phrase.dart';

abstract interface class CustomPhraseRepository {
  Future<List<CustomPhrase>> listAll();
  Future<CustomPhrase?> getById(String id);
  Future<void> save(CustomPhrase phrase);
  Future<void> delete(String id);
  Stream<List<CustomPhrase>> watchAll();
}
