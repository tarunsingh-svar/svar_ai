import 'package:flutter/foundation.dart';

/// The subscription flags the app gates features on, derived from a RevenueCat
/// entitlement.
///
/// This is deliberately separate from `SubscriptionController`: `Purchases` is a
/// static API that cannot be mocked, so the mapping lives here as a pure
/// function over primitives and stays unit-testable.
@immutable
class EntitlementStatus {
  const EntitlementStatus({
    required this.isPro,
    required this.isTrial,
    required this.isLifetime,
    required this.trialDaysLeft,
  });

  /// No active entitlement.
  static const free = EntitlementStatus(
    isPro: false,
    isTrial: false,
    isLifetime: false,
    trialDaysLeft: 0,
  );

  final bool isPro;
  final bool isTrial;
  final bool isLifetime;
  final int trialDaysLeft;

  /// Projects a RevenueCat entitlement onto [EntitlementStatus].
  ///
  /// [expirationDate] is the raw ISO-8601 string RevenueCat returns; a null
  /// expiry on an active entitlement is the non-renewing lifetime purchase.
  /// [now] is injectable so trial arithmetic can be tested deterministically.
  factory EntitlementStatus.fromEntitlement({
    required bool isActive,
    required bool isTrialPeriod,
    required String? expirationDate,
    DateTime? now,
  }) {
    if (!isActive) return free;

    final isLifetime = expirationDate == null;
    var trialDaysLeft = 0;

    if (isTrialPeriod && expirationDate != null) {
      final end = DateTime.tryParse(expirationDate);
      if (end != null) {
        final days = end.difference(now ?? DateTime.now()).inDays;
        trialDaysLeft = days < 0 ? 0 : days;
      }
    }

    return EntitlementStatus(
      isPro: true,
      isTrial: isTrialPeriod,
      isLifetime: isLifetime,
      trialDaysLeft: trialDaysLeft,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is EntitlementStatus &&
      other.isPro == isPro &&
      other.isTrial == isTrial &&
      other.isLifetime == isLifetime &&
      other.trialDaysLeft == trialDaysLeft;

  @override
  int get hashCode => Object.hash(isPro, isTrial, isLifetime, trialDaysLeft);

  @override
  String toString() =>
      'EntitlementStatus(isPro: $isPro, isTrial: $isTrial, '
      'isLifetime: $isLifetime, trialDaysLeft: $trialDaysLeft)';
}
