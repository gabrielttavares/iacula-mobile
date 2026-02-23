final class PremiumStatus {
  const PremiumStatus({
    required this.isPremium,
    this.purchaseDate,
    this.storeTransactionId,
    this.userId,
  });

  final bool isPremium;
  final DateTime? purchaseDate;
  final String? storeTransactionId;
  final String? userId;

  static const free = PremiumStatus(isPremium: false);

  PremiumStatus copyWith({
    bool? isPremium,
    DateTime? purchaseDate,
    String? storeTransactionId,
    String? userId,
  }) {
    return PremiumStatus(
      isPremium: isPremium ?? this.isPremium,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      storeTransactionId: storeTransactionId ?? this.storeTransactionId,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is PremiumStatus &&
        other.isPremium == isPremium &&
        other.purchaseDate == purchaseDate &&
        other.storeTransactionId == storeTransactionId &&
        other.userId == userId;
  }

  @override
  int get hashCode =>
      Object.hash(isPremium, purchaseDate, storeTransactionId, userId);
}
