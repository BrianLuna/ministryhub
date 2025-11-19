/// Subscription type enum
enum SubscriptionType {
  free,
  pro,
  premium;

  /// Get subscription type from string
  static SubscriptionType fromString(String value) {
    return SubscriptionType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => SubscriptionType.free,
    );
  }

  /// Convert to string for Firestore storage
  String toFirestoreValue() => name;
}

