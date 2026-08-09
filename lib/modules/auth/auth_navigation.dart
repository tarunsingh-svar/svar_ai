import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:svar_ai/core/constants/keys.dart';
import 'package:svar_ai/core/routing/app_routes.dart';

/// Routes a signed-in user to home or onboarding based on whether a
/// `user_details` row exists (same durable check as the web app).
class AuthNavigation {
  AuthNavigation._();

  static Future<void> routeAfterSignIn({required String userId}) async {
    final supabase = Supabase.instance.client;

    try {
      final details = await supabase
          .from('user_details')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();

      final hasDetails = details != null;

      if (Get.isRegistered<SharedPreferences>()) {
        final prefs = Get.find<SharedPreferences>();
        await prefs.setBool(Keys.hasOnboarded, hasDetails);
      }

      Get.offAllNamed(
        hasDetails ? AppRoutes.home : AppRoutes.userAgeScreen,
      );
    } catch (e) {
      debugPrint('AuthNavigation.routeAfterSignIn failed: $e');
      // Fall back to the local flag if the network check fails.
      final prefs = Get.isRegistered<SharedPreferences>()
          ? Get.find<SharedPreferences>()
          : null;
      final hasOnboarded = prefs?.getBool(Keys.hasOnboarded) ?? false;
      Get.offAllNamed(
        hasOnboarded ? AppRoutes.home : AppRoutes.userAgeScreen,
      );
    }
  }
}
