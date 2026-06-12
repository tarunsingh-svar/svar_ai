import 'package:get/get.dart';

import '../../core/routing/app_routes.dart';

/// Opens the subscription paywall. Pass an optional [reason] (e.g.
/// "You've reached the free note limit") to contextualize the upgrade prompt.
void showPaywall({String? reason}) {
  Get.toNamed(AppRoutes.pricingPage, arguments: reason);
}
