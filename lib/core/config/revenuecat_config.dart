import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/debug_agent_log.dart';
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

  static String get _apiKey =>
      Platform.isIOS ? Environment.revenueCatIosApiKey : Environment.revenueCatAndroidApiKey;

  /// Initialize the RevenueCat SDK. Safe to call once at app start.
  /// If a Supabase user is already signed in, the SDK is logged in with the
  /// Supabase user id so purchases are tied to the account across devices.
  static Future<void> init() async {
    if (kIsWeb) return;

    final platform = Platform.isIOS ? 'ios' : 'android';
    final keyPrefix = _apiKey.length >= 8 ? _apiKey.substring(0, 8) : 'short';

    try {
      await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.warn,
      );

      final userId = Supabase.instance.client.auth.currentUser?.id;
      final configuration = PurchasesConfiguration(_apiKey)
        ..appUserID = userId;

      await Purchases.configure(configuration);

      // #region agent log
      debugAgentLog(
        'revenuecat_config.dart:init',
        'Purchases.configure succeeded',
        {
          'platform': platform,
          'keyPrefix': keyPrefix,
          'hasUserId': userId != null,
        },
        hypothesisId: 'A',
      );
      // #endregion
      debugPrint('[RC-DEBUG] configure OK platform=$platform keyPrefix=$keyPrefix');
    } catch (e, s) {
      // #region agent log
      debugAgentLog(
        'revenuecat_config.dart:init',
        'Purchases.configure failed',
        {
          'platform': platform,
          'keyPrefix': keyPrefix,
          'error': e.toString(),
          'stack': s.toString().split('\n').take(3).join(' | '),
        },
        hypothesisId: 'A',
      );
      // #endregion
      debugPrint('[RC-DEBUG] configure FAILED: $e');
      rethrow;
    }
  }
}
