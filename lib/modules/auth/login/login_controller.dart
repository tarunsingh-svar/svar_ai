import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:svar_ai/core/routing/app_routes.dart';

class LoginController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final isLoading = false.obs;

  Future<void> loginWithGoogle() async {
    try {
      // This will open the Google Sign-In flow (via the web view or deep link)
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        // You must specify a custom scheme and path for mobile deep linking
        // This path must match your configured redirect URI in Google Cloud and Supabase
        redirectTo: 'com.svar.ai://login-callback/',
        authScreenLaunchMode: LaunchMode.platformDefault,
      );

      // if (res == true) {
      //   Get.offAll(AppRoutes.home);
      // }
      // The user will be redirected back to your app
    } on AuthException catch (e) {
      // Handle error
      print('Google sign-in error: ${e.message}');
    } catch (e) {
      // Handle other exceptions
      print('An unexpected error occurred: $e');
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
