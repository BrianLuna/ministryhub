import 'package:ministryhub/ministryhub.dart';

/// Constants for subscription limits
class SubscriptionLimits {
  const SubscriptionLimits._();

  /// Free tier limits
  static const int freeMaxChurches = 1;
  static const int freeMaxPeoplePerChurch = 50;

  /// Pro tier limits
  static const int proMaxChurches = 5;
  static const int proMaxPeoplePerChurch = 300;

  /// Premium tier has unlimited churches and people
  static const int premiumMaxChurches = -1; // -1 means unlimited
  static const int premiumMaxPeoplePerChurch = -1; // -1 means unlimited

  /// Get max churches for a subscription type
  static int getMaxChurches(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.free:
        return freeMaxChurches;
      case SubscriptionType.pro:
        return proMaxChurches;
      case SubscriptionType.premium:
        return premiumMaxChurches;
    }
  }

  /// Get max people per church for a subscription type
  static int getMaxPeoplePerChurch(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.free:
        return freeMaxPeoplePerChurch;
      case SubscriptionType.pro:
        return proMaxPeoplePerChurch;
      case SubscriptionType.premium:
        return premiumMaxPeoplePerChurch;
    }
  }

  /// Check if churches are unlimited
  static bool isChurchesUnlimited(SubscriptionType type) {
    return getMaxChurches(type) == -1;
  }

  /// Check if people are unlimited
  static bool isPeopleUnlimited(SubscriptionType type) {
    return getMaxPeoplePerChurch(type) == -1;
  }
}
