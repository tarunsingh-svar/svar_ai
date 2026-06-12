import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:svar_ai/core/constants/auth_redirect.dart';
import 'package:svar_ai/core/routing/app_routes.dart';
import 'package:svar_ai/modules/subscription/subscription_controller.dart';

class LoginController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen for login / logout state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        print("✅ User signed in ✔");
        if (Get.isRegistered<SubscriptionController>()) {
          Get.find<SubscriptionController>().logInUser(session.user.id);
        }
        Get.offAllNamed(AppRoutes.home);
      }

      if (event == AuthChangeEvent.signedOut) {
        print("🚪 User signed out");
        if (Get.isRegistered<SubscriptionController>()) {
          Get.find<SubscriptionController>().logOutUser();
        }
        Get.offAllNamed(AppRoutes.welcome);
      }
    });
  }

  Future<void> loginWithGoogle() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : kAuthRedirectUrl,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );
    } on AuthException catch (e) {
      debugPrint('Google sign-in error: ${e.message}');
      Get.snackbar(
        'Sign-in failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      Get.snackbar(
        'Sign-in failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Sign-out error: $e');
    }
  }

  bool get isLoggedIn => _supabase.auth.currentUser != null;
}
