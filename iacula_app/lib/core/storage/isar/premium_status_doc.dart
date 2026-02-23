import 'package:isar/isar.dart';

part 'premium_status_doc.g.dart';

@collection
class PremiumStatusDoc {
  Id id = 0;

  bool isPremium = false;
  DateTime? purchaseDate;
  String? storeTransactionId;
  String? userId;
  DateTime? lastValidated;
}
