import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class UserDetailsController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Observables
  final isLoading = false.obs;
  final email = ''.obs;
  final age = ''.obs;
  final profession = ''.obs;
  final usage = ''.obs;

  Future<void> saveUserDetails() async {
    try {
      if (email.isEmpty) {
        Get.snackbar('Error', 'User email not found');
        return;
      }

      isLoading.value = true;

      final response = await _supabase.from('user_details').upsert({
        'email': email.value,
        'age': age.value,
        'profession': profession.value,
        'usage': usage.value,
      });

      debugPrint('✅ User details saved: $response');
    } catch (e) {
      debugPrint('❌ Error saving user details: $e');
      Get.snackbar('Error', 'Failed to save user details. Try again.');
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
}
