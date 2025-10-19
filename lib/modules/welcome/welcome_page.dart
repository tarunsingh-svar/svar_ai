import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_assets.dart';
import 'package:svar_ai/modules/intro/widgets/custom_button_intro.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/routing/app_routes.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // top icon/graphic
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 17.h),
                  Image.asset(AppAssets.welcomeImg, width: 75.w),
                  const SizedBox(height: 40),
                  Text.rich(
                    TextSpan(
                      text: 'Capture Every ',
                      style: AppTextTheme.h3,
                      children: [
                        TextSpan(
                          text: 'Thought',
                          style: AppTextTheme.h3.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(text: '. ', style: AppTextTheme.h3),
                        const TextSpan(text: '\nTurn it into '),
                        TextSpan(
                          text: 'Action',
                          style: AppTextTheme.h3.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Never lose an idea, detail, or meeting note again — in English, Hindi, and more.',
                    style: AppTextTheme.body1,
                  ),
                ],
              ),

              // bottom button + login link
              Column(
                children: [
                  CustomButtonIntro(
                    text: 'Get Started',
                    widget: Icon(
                      Icons.arrow_forward_ios_rounded,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      size: 16.sp,
                    ),
                    onTap: () {
                      Get.toNamed(AppRoutes.intro);
                    },
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.login),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: AppColors.textBlack,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
