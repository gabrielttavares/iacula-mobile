import '../../domain/entities/last_delivered_card.dart';
import '../../domain/repositories/last_delivered_card_repository.dart';

final class InMemoryLastDeliveredCardRepository implements LastDeliveredCardRepository {
  LastDeliveredCard? _value;

  @override
  Future<LastDeliveredCard?> load() async => _value;

  @override
  Future<void> save(LastDeliveredCard card) async {
    _value = card;
  }
}
