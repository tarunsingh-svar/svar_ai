import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:svar_ai/core/constants/auth_redirect.dart';
import 'package:svar_ai/core/routing/app_routes.dart';
import 'package:svar_ai/modules/auth/auth_navigation.dart';
import 'package:svar_ai/modules/subscription/subscription_controller.dart';

class LoginController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen for login / logout state changes
    _supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        debugPrint('User signed in');
        if (Get.isRegistered<SubscriptionController>()) {
          Get.find<SubscriptionController>().logInUser(session.user.id);
        }
        await AuthNavigation.routeAfterSignIn(userId: session.user.id);
      }

      if (event == AuthChangeEvent.signedOut) {
        debugPrint('User signed out');
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
        queryParams: const {
          'access_type': 'offline',
          'prompt': 'consent',
        },
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

  Future<bool> sendMagicLink(String email) async {
    if (isLoading.value) return false;
    try {
      isLoading.value = true;
      await _supabase.auth.signInWithOtp(
        email: email.trim(),
        emailRedirectTo: kIsWeb ? null : kAuthRedirectUrl,
        shouldCreateUser: true,
      );
      debugPrint('Magic link requested for ${email.trim()}');
      return true;
    } on AuthException catch (e) {
      debugPrint('Magic link error: ${e.message} (${e.code})');
      final message = _magicLinkErrorMessage(e);
      Get.snackbar(
        'Could not send link',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      return false;
    } catch (e) {
      debugPrint('Magic link error: $e');
      Get.snackbar(
        'Could not send link',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyEmailOtp(String email, String token) async {
    if (isLoading.value) return false;
    try {
      isLoading.value = true;
      await _supabase.auth.verifyOTP(
        email: email.trim(),
        token: token.trim(),
        type: OtpType.email,
      );
      return true;
    } on AuthException catch (e) {
      debugPrint('OTP verify error: ${e.message} (${e.code})');
      Get.snackbar(
        'Invalid or expired code',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      debugPrint('OTP verify error: $e');
      Get.snackbar(
        'Could not verify code',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String _magicLinkErrorMessage(AuthException error) {
    return switch (error.code) {
      'over_email_send_rate_limit' =>
        'Please wait about a minute before requesting another link.',
      'email_address_invalid' => 'That email address is not valid.',
      'email_address_not_authorized' =>
        'This email cannot receive auth messages from Supabase. Try another address or configure custom SMTP.',
      'validation_failed' =>
        'Could not send to that address. Check the email and try again.',
      _ => error.message,
    };
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      // onAuthStateChange handles navigation.
    } on AuthException catch (e) {
      debugPrint('Email sign-in error: ${e.message}');
      Get.snackbar(
        'Sign-in failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Email sign-in error: $e');
      Get.snackbar(
        'Sign-in failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );
      // Auto-confirm on → session established; onAuthStateChange handles nav.
      // If Confirm email is still enabled in Supabase, there is no session yet.
      if (response.session == null) {
        Get.snackbar(
          'Confirm your email',
          'Account created. Check your inbox to confirm, or disable '
              '"Confirm email" in the Supabase Auth settings for instant sign-up.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 6),
        );
      }
    } on AuthException catch (e) {
      debugPrint('Email sign-up error: ${e.message}');
      Get.snackbar(
        'Sign-up failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Email sign-up error: $e');
      Get.snackbar(
        'Sign-up failed',
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
