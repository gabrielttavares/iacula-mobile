import 'package:flutter_test/flutter_test.dart';
import 'package:iacula_app/features/notifications/domain/services/notification_budget.dart';

void main() {
  group('NotificationBudget', () {
    test('starts with the full capacity available', () {
      final budget = NotificationBudget(capacity: 64);

      expect(budget.capacity, 64);
      expect(budget.remaining, 64);
      expect(budget.consumed, 0);
      expect(budget.isExhausted, isFalse);
    });

    test('tryConsume grants a slot while capacity remains', () {
      final budget = NotificationBudget(capacity: 2);

      expect(budget.tryConsume(), isTrue);
      expect(budget.remaining, 1);
      expect(budget.consumed, 1);

      expect(budget.tryConsume(), isTrue);
      expect(budget.remaining, 0);
      expect(budget.consumed, 2);
      expect(budget.isExhausted, isTrue);
    });

    test('tryConsume denies once exhausted and never goes negative', () {
      final budget = NotificationBudget(capacity: 1);

      expect(budget.tryConsume(), isTrue);
      expect(budget.tryConsume(), isFalse);
      expect(budget.tryConsume(), isFalse);
      expect(budget.remaining, 0);
      expect(budget.consumed, 1);
    });

    test('reserve removes capacity up front for a higher-priority tier', () {
      final budget = NotificationBudget(capacity: 10);

      budget.reserve(4);

      expect(budget.remaining, 6);
      expect(budget.consumed, 4);
    });

    test('reserve never drives remaining below zero (over-reservation clamps)',
        () {
      final budget = NotificationBudget(capacity: 3);

      budget.reserve(5);

      expect(budget.remaining, 0);
      expect(budget.consumed, 3);
      expect(budget.tryConsume(), isFalse);
    });

    test('a zero capacity budget grants nothing', () {
      final budget = NotificationBudget(capacity: 0);

      expect(budget.isExhausted, isTrue);
      expect(budget.tryConsume(), isFalse);
    });
  });
}
