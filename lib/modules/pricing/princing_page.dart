import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../subscription/subscription_controller.dart';

enum _CatalogKind { yearly, monthly, lifetime }

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  final SubscriptionController _sub = Get.find<SubscriptionController>();
  final Rxn<Package> _selectedPackage = Rxn<Package>();
  final Rxn<StoreProduct> _selectedProduct = Rxn<StoreProduct>();

  String? get _reason => Get.arguments is String ? Get.arguments as String : null;

  bool get _useCatalogFallback =>
      (_sub.offering.value?.availablePackages.isEmpty ?? true) &&
      _sub.catalogProducts.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _sub.loadOfferings();
      _selectDefault();
    });
  }

  void _selectDefault() {
    if (_useCatalogFallback) {
      _selectedProduct.value ??=
          _sub.catalogProducts.isNotEmpty ? _sub.catalogProducts.first : null;
      return;
    }
    final offering = _sub.offering.value;
    if (offering == null) return;
    _selectedPackage.value ??=
        offering.annual ?? offering.monthly ?? offering.lifetime ??
            (offering.availablePackages.isNotEmpty
                ? offering.availablePackages.first
                : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Obx(() {
                final offering = _sub.offering.value;
                _selectDefault();
                final packages = _orderedPackages(offering);
                final catalog = _sub.catalogProducts;
                final hasPlans =
                    packages.isNotEmpty || catalog.isNotEmpty;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 6.h),
                    Text(
                      "Unlimited access to SVAR AI",
                      style: AppTextTheme.body1,
                      textAlign: TextAlign.center,
                    ),
                    if (_reason != null) ...[
                      SizedBox(height: 1.h),
                      Text(
                        _reason!,
                        style: AppTextTheme.caption.copyWith(
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    SizedBox(height: 3.h),

                    _buildFeature("All 16+ rewrite options"),
                    _buildFeature("Unlimited number of notes"),
                    _buildFeature("No limit on recording duration"),
                    _buildFeature("Priority support"),
                    SizedBox(height: 3.5.h),

                    if (!hasPlans)
                      _buildUnavailable()
                    else if (_useCatalogFallback)
                      ...catalog.map(_buildCatalogPlanCard)
                    else
                      ...packages.map(_buildPlanCard),

                    SizedBox(height: 4.h),

                    _buildPurchaseButton(
                      packages: packages,
                      hasPlans: hasPlans,
                    ),

                    SizedBox(height: 2.h),

                    TextButton(
                      onPressed: _sub.isPurchasing.value
                          ? null
                          : () => _sub.restorePurchases(),
                      child: Text(
                        "Restore Purchases",
                        style: AppTextTheme.body3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    SizedBox(height: 1.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Terms of use", style: AppTextTheme.body3),
                        SizedBox(width: 10.w),
                        Text("Privacy Policy", style: AppTextTheme.body3),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in your store account settings.",
                      style: AppTextTheme.caption.copyWith(
                        fontSize: 10.sp,
                        color: AppColors.textBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }),
            ),
            Positioned(
              top: 1.h,
              right: 2.w,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.close_rounded, color: AppColors.grey600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Order: yearly, monthly, lifetime, then any remaining packages.
  List<Package> _orderedPackages(Offering? offering) {
    if (offering == null) return const [];
    final ordered = <Package>[];
    void add(Package? p) {
      if (p != null && !ordered.contains(p)) ordered.add(p);
    }

    add(offering.annual);
    add(offering.monthly);
    add(offering.lifetime);
    for (final p in offering.availablePackages) {
      add(p);
    }
    return ordered;
  }

  Widget _buildPlanCard(Package package) {
    final product = package.storeProduct;
    final isSelected = _selectedPackage.value?.identifier == package.identifier;
    final isLifetime = package.packageType == PackageType.lifetime;
    final hasTrial = product.introductoryPrice != null;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: GestureDetector(
        onTap: () => _selectedPackage.value = package,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.8.h, horizontal: 5.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.sp),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _planTitle(package),
                        style: AppTextTheme.body1Medium,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        isLifetime ? "One-time payment" : _planSubtitle(package),
                        style: AppTextTheme.caption.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        product.priceString,
                        style: AppTextTheme.button.copyWith(
                          color: AppColors.textBlack,
                        ),
                      ),
                      if (hasTrial)
                        Text(
                          "7-day free trial",
                          style: AppTextTheme.caption.copyWith(
                            color: AppColors.success,
                            fontSize: 10.sp,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (package.packageType == PackageType.annual)
              Positioned(
                top: -12.sp,
                right: 25,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 0.6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  child: Text(
                    "Best Deal",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _planTitle(Package package) {
    switch (package.packageType) {
      case PackageType.annual:
        return "Yearly";
      case PackageType.monthly:
        return "Monthly";
      case PackageType.lifetime:
        return "Lifetime";
      default:
        return package.storeProduct.title;
    }
  }

  String _planSubtitle(Package package) {
    switch (package.packageType) {
      case PackageType.annual:
        return "Billed yearly";
      case PackageType.monthly:
        return "Billed monthly";
      default:
        return "Cancel anytime";
    }
  }

  Widget _buildCatalogPlanCard(StoreProduct product) {
    final isSelected = _selectedProduct.value?.identifier == product.identifier;
    final kind = _catalogKind(product.identifier);
    final isLifetime = kind == _CatalogKind.lifetime;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: GestureDetector(
        onTap: () => _selectedProduct.value = product,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.8.h, horizontal: 5.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14.sp),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _catalogTitle(kind),
                        style: AppTextTheme.body1Medium,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        isLifetime ? 'One-time payment' : _catalogSubtitle(kind),
                        style: AppTextTheme.caption.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    product.priceString,
                    style: AppTextTheme.button.copyWith(
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              ),
            ),
            if (kind == _CatalogKind.yearly)
              Positioned(
                top: -12.sp,
                right: 25,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 0.6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  child: Text(
                    'Best Deal',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _CatalogKind _catalogKind(String productId) {
    if (productId.contains('yearly') || productId.contains('annual')) {
      return _CatalogKind.yearly;
    }
    if (productId.contains('lifetime')) return _CatalogKind.lifetime;
    return _CatalogKind.monthly;
  }

  String _catalogTitle(_CatalogKind kind) {
    switch (kind) {
      case _CatalogKind.yearly:
        return 'Yearly';
      case _CatalogKind.monthly:
        return 'Monthly';
      case _CatalogKind.lifetime:
        return 'Lifetime';
    }
  }

  String _catalogSubtitle(_CatalogKind kind) {
    switch (kind) {
      case _CatalogKind.yearly:
        return 'Billed yearly';
      case _CatalogKind.monthly:
        return 'Billed monthly';
      case _CatalogKind.lifetime:
        return 'One-time payment';
    }
  }

  Widget _buildPurchaseButton({
    required List<Package> packages,
    required bool hasPlans,
  }) {
    final selectedPackage = _selectedPackage.value;
    final selectedProduct = _selectedProduct.value;
    final canBuy = hasPlans &&
        !_sub.isPurchasing.value &&
        (_useCatalogFallback
            ? selectedProduct != null
            : selectedPackage != null);
    return GestureDetector(
      onTap: canBuy
          ? () async {
              final success = _useCatalogFallback
                  ? await _sub.purchaseStoreProduct(selectedProduct!)
                  : await _sub.purchasePackage(selectedPackage!);
              if (success) Get.back();
            }
          : null,
      child: Container(
        width: double.infinity,
        height: 8.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: canBuy ? AppColors.primary : AppColors.grey400,
          borderRadius: BorderRadius.circular(12.sp),
        ),
        child: _sub.isPurchasing.value
            ? const CircularProgressIndicator(color: Colors.white)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start Now',
                    style: AppTextTheme.h1.copyWith(
                      fontSize: 18.sp,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Cancel anytime",
                    style: AppTextTheme.body3.copyWith(color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildUnavailable() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.grey500, size: 24.sp),
          SizedBox(height: 1.h),
          Text(
            'Plans are currently unavailable.\n'
            'In RevenueCat, create a Current Offering named "default" '
            'and attach your Test Store products, or verify product IDs match '
            'svar_pro_monthly / svar_pro_yearly / svar_pro_lifetime.',
            style: AppTextTheme.body3.copyWith(color: AppColors.textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.info, size: 18.sp),
          SizedBox(width: 2.w),
          Text(text, style: AppTextTheme.body2.copyWith(fontSize: 15.sp)),
        ],
      ),
    );
  }
}
