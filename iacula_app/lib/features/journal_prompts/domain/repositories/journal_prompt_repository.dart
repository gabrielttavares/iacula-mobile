import '../entities/journal_prompt.dart';

abstract interface class JournalPromptRepository {
  Future<List<JournalPrompt>> listAll();
}
