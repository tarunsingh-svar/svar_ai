import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:svar_ai/core/theme/text_styles.dart';
import 'package:svar_ai/modules/auth/auth_navigation.dart';
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

    if (session != null) {
      await AuthNavigation.routeAfterSignIn(userId: session.user.id);
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
