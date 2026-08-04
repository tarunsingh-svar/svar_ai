import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'environment.dart';

/// Central RevenueCat identifiers and SDK bootstrap.
///
/// Configure the matching values in the RevenueCat dashboard:
/// - [proEntitlementId]: the entitlement that unlocks Pro features.
/// - [defaultOfferingId]: the offering that holds the purchasable packages.
/// - [monthlyProductId] / [yearlyProductId] / [lifetimeProductId]: the store
///   product identifiers (used for display fallbacks and analytics).
class RevenueCatConfig {
  RevenueCatConfig._();

  static const proEntitlementId = 'pro';
  static const defaultOfferingId = 'default';

  static const monthlyProductId = 'svar_pro_monthly';
  static const yearlyProductId = 'svar_pro_yearly';
  static const lifetimeProductId = 'svar_pro_lifetime';

  static bool _isConfigured = false;

  /// True once [init] has successfully configured the SDK. Callers must check
  /// this before touching `Purchases`, which throws when unconfigured.
  static bool get isConfigured => _isConfigured;

  static String get _apiKey => Platform.isIOS
      ? Environment.revenueCatIosApiKey
      : Environment.revenueCatAndroidApiKey;

  /// Initialize the RevenueCat SDK. Safe to call once at app start.
  /// If a Supabase user is already signed in, the SDK is logged in with the
  /// Supabase user id so purchases are tied to the account across devices.
  ///
  /// Never throws: billing being unavailable should leave the user on the free
  /// tier, not prevent the app from starting.
  static Future<void> init() async {
    if (kIsWeb) return;

    if (_apiKey.isEmpty) {
      debugPrint(
        'RevenueCat: no API key for this platform, skipping init. '
        'Pass REVENUECAT_IOS_KEY / REVENUECAT_ANDROID_KEY via --dart-define.',
      );
      return;
    }

    try {
      await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.warn,
      );

      final userId = Supabase.instance.client.auth.currentUser?.id;
      final configuration = PurchasesConfiguration(_apiKey)
        ..appUserID = userId;

      await Purchases.configure(configuration);
      _isConfigured = true;
    } catch (e) {
      debugPrint('RevenueCat configure failed: $e');
    }
  }
}
