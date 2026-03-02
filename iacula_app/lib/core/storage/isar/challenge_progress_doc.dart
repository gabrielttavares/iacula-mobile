import 'package:isar/isar.dart';

part 'challenge_progress_doc.g.dart';

@collection
class ChallengeProgressDoc {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String challengeId;

  late DateTime startDate;

  late String completedDaysJson; // JSON array of ints e.g. "[1,2,3]"

  late bool isCompleted;

  DateTime? completedAt;
}
