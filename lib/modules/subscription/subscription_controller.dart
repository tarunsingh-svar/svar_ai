import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/revenuecat_config.dart';
import '../../core/constants/plan_limits.dart';
import '../../core/helpers/debug_agent_log.dart';

/// Holds the user's subscription state and exposes the feature gates used
/// across the app. Entitlement is read from the RevenueCat SDK (instant) and
/// the lifetime note counter is read from Supabase `profiles`.
class SubscriptionController extends GetxController {
  final _supabase = Supabase.instance.client;

  /// True when the `pro` entitlement is active (paid, trial, or lifetime).
  final RxBool isPro = false.obs;

  /// True while the active entitlement is in its introductory free trial.
  final RxBool isTrial = false.obs;

  /// True when Pro was unlocked via the non-expiring lifetime purchase.
  final RxBool isLifetime = false.obs;

  /// Days remaining in the trial (0 when not on trial / unknown).
  final RxInt trialDaysLeft = 0.obs;

  /// Lifetime count of notes the user has created (server-tracked).
  final RxInt notesCreatedCount = 0.obs;

  /// Available offering from RevenueCat, used to render the paywall.
  final Rxn<Offering> offering = Rxn<Offering>();

  /// Fallback when offerings are not configured: products fetched directly
  /// by product id from the RevenueCat catalog.
  final RxList<StoreProduct> catalogProducts = <StoreProduct>[].obs;

  /// Last offerings load error message (for paywall display).
  final RxString offeringsError = ''.obs;

  final RxBool isPurchasing = false.obs;

  bool get _sdkAvailable => !kIsWeb;

  /// Human-readable plan label for settings UI.
  String get planLabel {
    if (!isPro.value) return 'Free';
    if (isLifetime.value) return 'Lifetime';
    if (isTrial.value) return 'Trial';
    return 'Pro';
  }

  /// Free users are capped at [PlanLimits.freeNoteLimit] lifetime notes.
  bool get canCreateNote =>
      isPro.value || notesCreatedCount.value < PlanLimits.freeNoteLimit;

  /// Max recording length in seconds, or null for unlimited (Pro).
  int? get maxRecordingSeconds =>
      isPro.value ? null : PlanLimits.freeMaxRecordingSeconds;

  /// Whether a given rewrite option id may be used by the current user.
  bool isRewriteAllowed(String rewriteId) =>
      isPro.value || PlanLimits.freeRewriteIds.contains(rewriteId);

  @override
  void onInit() {
    super.onInit();
    if (_sdkAvailable) {
      Purchases.addCustomerInfoUpdateListener(_applyCustomerInfo);
    }
    refreshAll();
  }

  /// Pull the latest entitlement + offerings + note count.
  Future<void> refreshAll() async {
    await Future.wait([
      _refreshCustomerInfo(),
      loadOfferings(),
      refreshNotesCreatedCount(),
    ]);
  }

  Future<void> _refreshCustomerInfo() async {
    if (!_sdkAvailable) return;
    try {
      final info = await Purchases.getCustomerInfo();
      _applyCustomerInfo(info);
    } catch (e) {
      debugPrint('RevenueCat getCustomerInfo error: $e');
    }
  }

  void _applyCustomerInfo(CustomerInfo info) {
    final entitlement =
        info.entitlements.active[RevenueCatConfig.proEntitlementId];

    if (entitlement == null) {
      isPro.value = false;
      isTrial.value = false;
      isLifetime.value = false;
      trialDaysLeft.value = 0;
      return;
    }

    isPro.value = true;
    isTrial.value = entitlement.periodType == PeriodType.trial;
    // A non-expiring entitlement (no expiration date) is the lifetime purchase.
    isLifetime.value = entitlement.expirationDate == null;

    final expiry = entitlement.expirationDate;
    if (isTrial.value && expiry != null) {
      final end = DateTime.tryParse(expiry);
      if (end != null) {
        final diff = end.difference(DateTime.now()).inDays;
        trialDaysLeft.value = diff < 0 ? 0 : diff;
      }
    } else {
      trialDaysLeft.value = 0;
    }
  }

  Future<void> loadOfferings() async {
    if (!_sdkAvailable) {
      // #region agent log
      debugAgentLog(
        'subscription_controller.dart:loadOfferings',
        'skipped: sdk not available (web?)',
        {},
        hypothesisId: 'A',
      );
      // #endregion
      return;
    }

    offeringsError.value = '';
    catalogProducts.clear();

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      final fallback = offerings.all[RevenueCatConfig.defaultOfferingId];
      final resolved = current ?? fallback;

      // #region agent log
      debugAgentLog(
        'subscription_controller.dart:loadOfferings',
        'getOfferings succeeded',
        {
          'currentOfferingId': current?.identifier,
          'fallbackOfferingId': fallback?.identifier,
          'resolvedOfferingId': resolved?.identifier,
          'allOfferingIds': offerings.all.keys.toList(),
          'packageCount': resolved?.availablePackages.length ?? 0,
          'packageIds': resolved?.availablePackages
                  .map((p) => p.identifier)
                  .toList() ??
              [],
          'hasAnnual': resolved?.annual != null,
          'hasMonthly': resolved?.monthly != null,
          'hasLifetime': resolved?.lifetime != null,
        },
        hypothesisId: 'C,D',
      );
      // #endregion
      debugPrint(
        '[RC-DEBUG] offerings current=${current?.identifier} '
        'all=${offerings.all.keys.toList()} '
        'packages=${resolved?.availablePackages.length ?? 0}',
      );

      if (resolved != null && resolved.availablePackages.isNotEmpty) {
        offering.value = resolved;
        return;
      }

      offeringsError.value =
          'No packages in your RevenueCat offering. Loading products directly…';
    } catch (e, s) {
      // #region agent log
      debugAgentLog(
        'subscription_controller.dart:loadOfferings',
        'getOfferings failed',
        {
          'error': e.toString(),
          'stack': s.toString().split('\n').take(3).join(' | '),
        },
        hypothesisId: 'B',
      );
      // #endregion
      debugPrint('[RC-DEBUG] getOfferings FAILED: $e');
      offeringsError.value = e.toString();
    }

    offering.value = null;
    await _loadCatalogProductsFallback();
  }

  Future<void> _loadCatalogProductsFallback() async {
    try {
      final subs = await Purchases.getProducts([
        RevenueCatConfig.monthlyProductId,
        RevenueCatConfig.yearlyProductId,
      ]);
      final lifetime = await Purchases.getProducts(
        [RevenueCatConfig.lifetimeProductId],
        productCategory: ProductCategory.nonSubscription,
      );

      final byId = <String, StoreProduct>{
        for (final p in [...subs, ...lifetime]) p.identifier: p,
      };
      final ordered = <StoreProduct>[
        if (byId.containsKey(RevenueCatConfig.yearlyProductId))
          byId[RevenueCatConfig.yearlyProductId]!,
        if (byId.containsKey(RevenueCatConfig.monthlyProductId))
          byId[RevenueCatConfig.monthlyProductId]!,
        if (byId.containsKey(RevenueCatConfig.lifetimeProductId))
          byId[RevenueCatConfig.lifetimeProductId]!,
      ];

      catalogProducts.value = ordered;

      // #region agent log
      debugAgentLog(
        'subscription_controller.dart:_loadCatalogProductsFallback',
        'catalog products loaded',
        {
          'productIds': ordered.map((p) => p.identifier).toList(),
          'count': ordered.length,
        },
        hypothesisId: 'C,D',
        runId: 'post-fix',
      );
      // #endregion
      debugPrint(
        '[RC-DEBUG] catalog fallback products=${ordered.map((p) => p.identifier).toList()}',
      );
    } catch (e) {
      // #region agent log
      debugAgentLog(
        'subscription_controller.dart:_loadCatalogProductsFallback',
        'catalog products failed',
        {'error': e.toString()},
        hypothesisId: 'B',
        runId: 'post-fix',
      );
      // #endregion
      debugPrint('[RC-DEBUG] catalog fallback FAILED: $e');
    }
  }

  /// Purchase a store product directly (catalog fallback path).
  Future<bool> purchaseStoreProduct(StoreProduct product) async {
    if (!_sdkAvailable) return false;
    isPurchasing.value = true;
    try {
      final result =
          await Purchases.purchase(PurchaseParams.storeProduct(product));
      _applyCustomerInfo(result.customerInfo);
      return isPro.value;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code != PurchasesErrorCode.purchaseCancelledError) {
        Get.snackbar('Purchase failed', e.message ?? 'Please try again.',
            snackPosition: SnackPosition.BOTTOM);
      }
      return false;
    } finally {
      isPurchasing.value = false;
    }
  }

  /// Read the server-tracked lifetime note counter from Supabase.
  Future<void> refreshNotesCreatedCount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      final row = await _supabase
          .from('profiles')
          .select('notes_created_count')
          .eq('user_id', user.id)
          .maybeSingle();
      if (row != null && row['notes_created_count'] != null) {
        notesCreatedCount.value = (row['notes_created_count'] as num).toInt();
      }
    } catch (e) {
      debugPrint('refreshNotesCreatedCount error: $e');
    }
  }

  /// Optimistically bump the local counter after a successful note insert,
  /// so the gate reacts immediately without a round-trip.
  void incrementLocalNoteCount() => notesCreatedCount.value++;

  /// Purchase a package; returns true if the user is now Pro.
  Future<bool> purchasePackage(Package package) async {
    if (!_sdkAvailable) return false;
    isPurchasing.value = true;
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _applyCustomerInfo(result.customerInfo);
      return isPro.value;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code != PurchasesErrorCode.purchaseCancelledError) {
        Get.snackbar('Purchase failed', e.message ?? 'Please try again.',
            snackPosition: SnackPosition.BOTTOM);
      }
      return false;
    } finally {
      isPurchasing.value = false;
    }
  }

  /// Restore previous purchases (e.g. after reinstall / new device).
  Future<bool> restorePurchases() async {
    if (!_sdkAvailable) return false;
    isPurchasing.value = true;
    try {
      final info = await Purchases.restorePurchases();
      _applyCustomerInfo(info);
      Get.snackbar(
        isPro.value ? 'Purchases restored' : 'Nothing to restore',
        isPro.value ? 'Your Pro access is active.' : 'No active purchases found.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return isPro.value;
    } catch (e) {
      Get.snackbar('Restore failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isPurchasing.value = false;
    }
  }

  /// Tie the RevenueCat identity to the Supabase user id on sign-in.
  Future<void> logInUser(String userId) async {
    if (_sdkAvailable) {
      try {
        final result = await Purchases.logIn(userId);
        _applyCustomerInfo(result.customerInfo);
      } catch (e) {
        debugPrint('RevenueCat logIn error: $e');
      }
    }
    await refreshNotesCreatedCount();
    await loadOfferings();
  }

  /// Reset entitlement on sign-out.
  Future<void> logOutUser() async {
    if (_sdkAvailable) {
      try {
        await Purchases.logOut();
      } catch (e) {
        debugPrint('RevenueCat logOut error: $e');
      }
    }
    isPro.value = false;
    isTrial.value = false;
    isLifetime.value = false;
    trialDaysLeft.value = 0;
    notesCreatedCount.value = 0;
  }
}
