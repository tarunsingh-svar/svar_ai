import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/revenuecat_config.dart';
import '../../core/constants/plan_limits.dart';
import 'entitlement_status.dart';

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

  /// Purchases throws when the SDK was never configured, which happens on web
  /// and on any build missing its RevenueCat key.
  bool get _sdkAvailable => !kIsWeb && RevenueCatConfig.isConfigured;

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

    _applyStatus(EntitlementStatus.fromEntitlement(
      isActive: entitlement != null,
      isTrialPeriod: entitlement?.periodType == PeriodType.trial,
      expirationDate: entitlement?.expirationDate,
    ));
  }

  void _applyStatus(EntitlementStatus status) {
    isPro.value = status.isPro;
    isTrial.value = status.isTrial;
    isLifetime.value = status.isLifetime;
    trialDaysLeft.value = status.trialDaysLeft;
  }

  Future<void> loadOfferings() async {
    if (!_sdkAvailable) return;

    offeringsError.value = '';
    catalogProducts.clear();

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      final fallback = offerings.all[RevenueCatConfig.defaultOfferingId];
      final resolved = current ?? fallback;

      if (resolved != null && resolved.availablePackages.isNotEmpty) {
        offering.value = resolved;
        return;
      }

      offeringsError.value =
          'No packages in your RevenueCat offering. Loading products directly…';
    } catch (e) {
      debugPrint('RevenueCat getOfferings failed: $e');
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
    } catch (e) {
      debugPrint('RevenueCat catalog fallback failed: $e');
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
    _applyStatus(EntitlementStatus.free);
    notesCreatedCount.value = 0;
  }
}
