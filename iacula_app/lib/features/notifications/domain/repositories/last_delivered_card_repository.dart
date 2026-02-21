import '../entities/last_delivered_card.dart';

abstract interface class LastDeliveredCardRepository {
  Future<LastDeliveredCard?> load();
  Future<void> save(LastDeliveredCard card);
}
