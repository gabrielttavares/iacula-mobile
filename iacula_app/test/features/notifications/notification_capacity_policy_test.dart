import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/services/notification_capacity_policy.dart';

void main() {
  group('NotificationCapacityPolicy', () {
    test('iOS is capped, spreads across the runway, and has no tail', () {
      const policy = NotificationCapacityPolicy.ios;
      expect(policy.pendingTotalCapacity, 64);
      expect(policy.pendingQuoteCapacity, 64);
      expect(policy.spreadAcrossRunway, isTrue);
      expect(policy.hasTail, isFalse);
      expect(policy.tailHorizonDays, policy.denseRunwayDays);
    });

    test('Android is uncapped, honors full cadence, and adds a half tail', () {
      const policy = NotificationCapacityPolicy.android;
      expect(policy.pendingTotalCapacity, greaterThan(64));
      expect(policy.pendingQuoteCapacity, greaterThan(64));
      expect(policy.spreadAcrossRunway, isFalse);
      expect(policy.hasTail, isTrue);
      expect(policy.tailHorizonDays, greaterThan(policy.denseRunwayDays));
      // Half cadence: the tail doubles the spacing.
      expect(policy.tailCadenceMinutes(10), 20);
      expect(policy.tailCadenceMinutes(15), 30);
    });

    test('a no-tail policy reports its tail cadence as the same cadence', () {
      const policy = NotificationCapacityPolicy.ios;
      expect(policy.tailCadenceMinutes(10), 10);
    });
  });
}
