import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/home_widget/home_widget_service.dart';
import 'package:iacula_app/features/liturgical/domain/liturgical_season.dart';
import 'package:iacula_app/features/notifications/domain/entities/last_delivered_card.dart';

void main() {
  LastDeliveredCard buildCard(String quote) {
    return LastDeliveredCard(
      quoteText: quote,
      theme: 'T',
      season: LiturgicalSeason.lent.name,
      deliveredAt: DateTime(2026, 3, 24, 10, 0),
    );
  }

  test('publishes first card then suppresses duplicate card', () {
    final cache = WidgetCardSignatureCache();
    final card = buildCard('Quote A');

    expect(cache.shouldPublish(card), isTrue);
    cache.markPublished(card);
    expect(cache.shouldPublish(card), isFalse);
  });

  test('publishes again when quote slot changes', () {
    final cache = WidgetCardSignatureCache();
    final first = buildCard('Quote A');
    final second = buildCard('Quote B');

    expect(cache.shouldPublish(first), isTrue);
    cache.markPublished(first);
    expect(cache.shouldPublish(second), isTrue);
  });

  test('does not republish when only deliveredAt changes', () {
    final cache = WidgetCardSignatureCache();
    final first = LastDeliveredCard(
      quoteText: 'Quote A',
      theme: 'T',
      season: LiturgicalSeason.lent.name,
      deliveredAt: DateTime(2026, 3, 24, 10, 0),
    );
    final sameSlot = LastDeliveredCard(
      quoteText: 'Quote A',
      theme: 'T',
      season: LiturgicalSeason.lent.name,
      deliveredAt: DateTime(2026, 3, 24, 10, 5),
    );

    expect(cache.shouldPublish(first), isTrue);
    cache.markPublished(first);
    expect(cache.shouldPublish(sameSlot), isFalse);
  });
}
