import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/routing/app_routes.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../widgets/custom_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   title: Text(
      //     "SETTINGS",
      //     style: AppTextTheme.h5.copyWith(
      //       fontWeight: FontWeight.w700,
      //       color: AppColors.textBlack,
      //       fontSize: 22.sp,
      //     ),
      //   ),
      //   centerTitle: false,
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: 3.h),
              Text(
                "SETTINGS",
                style: AppTextTheme.h5.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                  fontSize: 20.sp,
                ),
              ),
              SizedBox(height: 5.h),
              // 🔷 Premium Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.sp),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0172FF), // bright blue
                      Color(0xFF014499), // deep blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),
                    Text.rich(
                      TextSpan(
                        text: 'Try SVAR AI',
                        style: AppTextTheme.h5.copyWith(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: ' Pro',
                            style: AppTextTheme.h5.copyWith(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.5.h),

                    _buildProFeature("15+ rewrite options"),
                    _buildProFeature("Unlimited number of notes"),
                    _buildProFeature("No limit on recording duration"),
                    _buildProFeature("Access to SVAR AI"),
                    SizedBox(height: 2.5.h),

                    CustomButton(
                      text: "Go Premium",
                      onTap: () {
                        Get.toNamed(AppRoutes.pricingPage);
                      },
                      borderRadius: 15.sp,
                      backgroundColor: Colors.white,
                      textColor: AppColors.textBlack,
                      borderColor: Colors.transparent,
                    ),
                    SizedBox(height: 1.5.h),
                  ],
                ),
              ),
              SizedBox(height: 3.h),

              // ⚙️ Settings List
              _buildSettingsTile(
                icon: AppAssets.whatsNew,
                title: "What's New",
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: AppAssets.helpFeedback,
                title: "Help & Feedback",
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: AppAssets.lang,
                title: "Language Options",
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: AppAssets.privacyPolicy,
                title: "Privacy Policy",
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: AppAssets.terms,
                title: "Terms of service",
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: AppAssets.userId,
                title: "User ID",
                onTap: () {},
              ),

              SizedBox(height: 3.h),

              // 🔗 Social Section
              Text(
                "Socials",
                style: AppTextTheme.body1.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  color: AppColors.textBlack,
                ),
              ),
              SizedBox(height: 1.h),
              _buildSettingsTile(
                icon: AppAssets.insta,
                title: "Instagram",
                onTap: () {},
              ),
              _buildSettingsTile(icon: AppAssets.x, title: "X", onTap: () {}),
              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ PRO feature item
  Widget _buildProFeature(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 16.sp),
          SizedBox(width: 2.w),
          Text(
            text,
            style: AppTextTheme.body2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Settings tile
  Widget _buildSettingsTile({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.sp),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0.6.h),
            child: Row(
              children: [
                Image.asset(icon, width: 8.w),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextTheme.body2.copyWith(
                      color: AppColors.textBlack,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: AppColors.grey500,
                ),
              ],
            ),
          ),
        ),
        Divider(thickness: 2.sp),
      ],
    );
  }
}
