import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class UserDetailsController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Observables
  final isLoading = false.obs;
  final email = ''.obs;
  final name = ''.obs;
  final age = ''.obs;
  final profession = ''.obs;
  final usage = ''.obs;

  Future<void> saveUserDetails() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    if (email.value.isEmpty) {
      Get.snackbar('Error', 'User email missing');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _supabase.from('user_details').upsert({
        'user_id': user.id,
        'email': email.value,
        'name': name.value.trim(),
        'age': age.value,
        'profession': profession.value,
        'usage': usage.value,
      }, onConflict: 'email');

      debugPrint('✅ User details saved: $response');
    } catch (e) {
      debugPrint('❌ Error: $e');
      Get.snackbar('Error', 'Couldn’t save details');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserDetails(String userEmail) async {
    try {
      isLoading.value = true;
      final data = await _supabase
          .from('user_details')
          .select()
          .eq('email', userEmail)
          .maybeSingle();

      if (data != null) {
        email.value = data['email'] ?? '';
        name.value = data['name'] ?? '';
        age.value = data['age'] ?? '';
        profession.value = data['profession'] ?? '';
        usage.value = data['usage'] ?? '';
      }
    } catch (e) {
      debugPrint('❌ Error fetching user details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads profile fields for the signed-in user (Settings > User Info).
  Future<void> loadCurrentUserDetails() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    email.value = user.email ?? '';

    try {
      isLoading.value = true;
      final data = await _supabase
          .from('user_details')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (data != null) {
        name.value = data['name'] ?? '';
        age.value = data['age'] ?? '';
        profession.value = data['profession'] ?? '';
        usage.value = data['usage'] ?? '';
        if (data['email'] != null) {
          email.value = data['email'] as String;
        }
      } else {
        final meta = user.userMetadata;
        name.value = meta?['full_name']?.toString() ??
            meta?['name']?.toString() ??
            '';
      }
    } catch (e) {
      debugPrint('❌ Error fetching user details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Persists only the display name from Settings > User Info.
  Future<bool> saveDisplayName() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User not logged in');
      return false;
    }

    final userEmail = user.email ?? email.value;
    if (userEmail.isEmpty) {
      Get.snackbar('Error', 'User email missing');
      return false;
    }

    try {
      isLoading.value = true;
      await _supabase.from('user_details').upsert({
        'user_id': user.id,
        'email': userEmail,
        'name': name.value.trim(),
      }, onConflict: 'email');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving name: $e');
      Get.snackbar('Error', 'Couldn’t save name');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
