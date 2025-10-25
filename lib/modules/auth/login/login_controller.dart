import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class LoginController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final isLoading = false.obs;

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google, // ✅ correct name
        redirectTo: 'https://kgzxaapyjqtbbpkkmogy.supabase.co/auth/v1/callback',
      );
    } catch (e) {
      debugPrint('Google sign-in failed: $e');
      Get.snackbar('Error', 'Google Sign-in failed. Try again.');
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
