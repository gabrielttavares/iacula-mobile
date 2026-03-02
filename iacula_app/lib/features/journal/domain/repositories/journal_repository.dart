import '../entities/journal_entry.dart';

abstract interface class JournalRepository {
  Future<List<JournalEntry>> listAll();
  Future<JournalEntry?> getById(String id);
  Future<void> save(JournalEntry entry);
  Future<void> delete(String id);
  Future<List<JournalEntry>> search(String query);
}
