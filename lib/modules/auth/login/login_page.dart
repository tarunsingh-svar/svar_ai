import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/routing/app_routes.dart';
import 'package:svar_ai/modules/auth/login/login_controller.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../widgets/white_card.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 9.h),

              // Logo Icon (Placeholder for now)
              Image.asset(AppAssets.welcomeImg, height: 27.h),

              SizedBox(height: 2.h),

              // App Name
              Image.asset(AppAssets.svarAi, height: 10.h, width: 50.w),

              SizedBox(height: 1.5.h),

              // Tagline
              Text(
                'Never lose an idea, detail, or meeting note\nagain — in English, Hindi, and more.',
                textAlign: TextAlign.center,
                style: AppTextTheme.body1,
                // .copyWith(fontSize: 17.sp),
              ),

              SizedBox(height: 3.h),

              // Google Sign-In Button
              InkWell(
                onTap: () async {
                  await loginController.loginWithGoogle();
                },
                child: WhiteCard(
                  width: double.infinity,
                  height: 6.h,
                  borderRadius: 10,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppAssets.google, height: 3.h),
                      SizedBox(width: 5.w),
                      Text(
                        'Continue with Google',
                        style: AppTextTheme.button.copyWith(
                          color: AppColors.textBlack,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // OR Divider
              Row(
                children: [
                  // Left gradient line
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, AppColors.grey500],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),

                  // OR text
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      'OR',
                      style: AppTextTheme.body3.copyWith(
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),

                  // Right gradient line
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, AppColors.grey500],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Email Sign-In Button (Only icon, no actual form here)
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.userAgeScreen);
                },
                child: WhiteCard(
                  width: double.infinity,
                  height: 6.h,
                  borderRadius: 10,
                  child: Center(
                    child: Icon(
                      Icons.mail,
                      color: AppColors.grey400,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 5.h),

              // Terms & Privacy Text
              Text.rich(
                TextSpan(
                  text: 'By Continuing, you agree to our ',
                  style: AppTextTheme.body2.copyWith(
                    color: AppColors.grey500,
                    fontSize: 15.sp,
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: AppTextTheme.body2.copyWith(
                        color: AppColors.grey500,
                        fontSize: 15.sp,
                      ),
                    ),
                    TextSpan(
                      text: ' and ',
                      style: AppTextTheme.body2.copyWith(
                        color: AppColors.grey500,
                        fontSize: 15.sp,
                      ),
                    ),
                    TextSpan(
                      text: 'Privacy Policy.',
                      style: AppTextTheme.body2.copyWith(
                        color: AppColors.grey500,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
