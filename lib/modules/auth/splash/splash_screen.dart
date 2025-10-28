import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:svar_ai/core/constants/keys.dart';
import 'package:svar_ai/core/theme/text_styles.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));

    final session = _supabase.auth.currentSession;
    final prefs = Get.find<SharedPreferences>();
    final hasOnboarded = prefs.getBool(Keys.hasOnboarded) ?? false;

    if (session != null) {
      if (hasOnboarded) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.userAgeScreen);
      }
      // user is logged in
    } else {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Text(
          "Svar AI",
          style: AppTextTheme.h2.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}
