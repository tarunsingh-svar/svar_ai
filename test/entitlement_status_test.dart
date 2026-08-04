import 'package:flutter_test/flutter_test.dart';
import 'package:svar_ai/modules/subscription/entitlement_status.dart';

/// Every paid feature in the app is gated on these four flags, so a mistake here
/// either gives Pro away or locks out a paying customer.
void main() {
  final now = DateTime.utc(2026, 8, 5, 12);

  String iso(Duration fromNow) => now.add(fromNow).toIso8601String();

  group('no entitlement', () {
    test('an inactive entitlement is free', () {
      final status = EntitlementStatus.fromEntitlement(
        isActive: false,
        isTrialPeriod: false,
        expirationDate: null,
        now: now,
      );

      expect(status, EntitlementStatus.free);
      expect(status.isPro, isFalse);
    });

    test('an inactive entitlement stays free even mid-trial', () {
      final status = EntitlementStatus.fromEntitlement(
        isActive: false,
        isTrialPeriod: true,
        expirationDate: iso(const Duration(days: 5)),
        now: now,
      );

      expect(status, EntitlementStatus.free);
    });
  });

  group('paid subscription', () {
    test('an active non-trial subscription is Pro but not a trial', () {
      final status = EntitlementStatus.fromEntitlement(
        isActive: true,
        isTrialPeriod: false,
        expirationDate: iso(const Duration(days: 30)),
        now: now,
      );

      expect(status.isPro, isTrue);
      expect(status.isTrial, isFalse);
      expect(status.isLifetime, isFalse);
      expect(status.trialDaysLeft, 0);
    });

    test('an active entitlement with no expiry is the lifetime purchase', () {
      final status = EntitlementStatus.fromEntitlement(
        isActive: true,
        isTrialPeriod: false,
        expirationDate: null,
        now: now,
      );

      expect(status.isPro, isTrue);
      expect(status.isLifetime, isTrue);
    });
  });

  group('trial', () {
    test('days left counts whole days to the expiry', () {
      final status = EntitlementStatus.fromEntitlement(
        isActive: true,
        isTrialPeriod: true,
        expirationDate: iso(const Duration(days: 7)),
        now: now,
      );

      expect(status.isPro, isTrue);
      expect(status.isTrial, isTrue);
      expect(status.trialDaysLeft, 7);
    });

    test('a partial day is not rounded up', () {
      final status = EntitlementStatus.fromEntitlement(
        isActive: true,
        isTrialPeriod: true,
        expirationDate: iso(const Duration(days: 2, hours: 23)),
        now: now,
      );

      expect(status.trialDaysLeft, 2);
    });

    test('less than a day left reads as zero rather than negative', () {
      final status = EntitlementStatus.fromEntitlement(
        isActive: true,
        isTrialPeriod: true,
        expirationDate: iso(const Duration(hours: 3)),
        now: now,
      );

      expect(status.trialDaysLeft, 0);
      expect(status.isPro, isTrue, reason: 'still entitled until it expires');
    });

    test('an expiry in the past clamps to zero, never negative', () {
      final status = EntitlementStatus.fromEntitlement(
        isActive: true,
        isTrialPeriod: true,
        expirationDate: iso(const Duration(days: -4)),
        now: now,
      );

      expect(status.trialDaysLeft, 0);
    });

    test('an unparseable expiry does not throw', () {
      final status = EntitlementStatus.fromEntitlement(
        isActive: true,
        isTrialPeriod: true,
        expirationDate: 'not-a-date',
        now: now,
      );

      expect(status.isPro, isTrue);
      expect(status.trialDaysLeft, 0);
    });

    test('a trial with no expiry is not treated as a lifetime trial', () {
      final status = EntitlementStatus.fromEntitlement(
        isActive: true,
        isTrialPeriod: true,
        expirationDate: null,
        now: now,
      );

      expect(status.isLifetime, isTrue);
      expect(status.trialDaysLeft, 0);
    });
  });

  group('value semantics', () {
    test('identical flags compare equal', () {
      EntitlementStatus build() => EntitlementStatus.fromEntitlement(
            isActive: true,
            isTrialPeriod: true,
            expirationDate: iso(const Duration(days: 3)),
            now: now,
          );

      expect(build(), build());
      expect(build().hashCode, build().hashCode);
    });

    test('differing flags do not compare equal', () {
      final trial = EntitlementStatus.fromEntitlement(
        isActive: true,
        isTrialPeriod: true,
        expirationDate: iso(const Duration(days: 3)),
        now: now,
      );
      final paid = EntitlementStatus.fromEntitlement(
        isActive: true,
        isTrialPeriod: false,
        expirationDate: iso(const Duration(days: 3)),
        now: now,
      );

      expect(trial, isNot(paid));
    });
  });
}
