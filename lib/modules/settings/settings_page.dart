import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/routing/app_routes.dart';
import 'package:svar_ai/modules/auth/login/login_controller.dart';
import 'package:svar_ai/modules/subscription/subscription_controller.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../widgets/custom_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find();
    final SubscriptionController sub = Get.find();
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
              // 🔷 Plan card (promo for free users, status for Pro users)
              Obx(
                () => sub.isPro.value
                    ? _buildProStatusCard(sub)
                    : _buildUpgradeCard(),
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

              _buildSettingsTile(
                icon: AppAssets.userId,
                title: "Logout",
                onTap: () async {
                  EasyLoading.show();
                  await loginController.signOut();
                  EasyLoading.dismiss();
                  Get.offAllNamed(AppRoutes.splashScreen);
                },
              ),
              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }

  // 🔷 Upgrade promo card shown to free users.
  Widget _buildUpgradeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.sp),
        gradient: const LinearGradient(
          colors: [Color(0xFF0172FF), Color(0xFF014499)],
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
          _buildProFeature("All 16+ rewrite options"),
          _buildProFeature("Unlimited number of notes"),
          _buildProFeature("No limit on recording duration"),
          _buildProFeature("Priority support"),
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
    );
  }

  // 🔷 Status card shown to Pro / trial / lifetime users.
  Widget _buildProStatusCard(SubscriptionController sub) {
    final label = sub.isLifetime.value
        ? "Lifetime Pro"
        : sub.isTrial.value
            ? "Pro Trial"
            : "SVAR AI Pro";
    final subtitle = sub.isTrial.value && sub.trialDaysLeft.value > 0
        ? "${sub.trialDaysLeft.value} day(s) left in your free trial"
        : sub.isLifetime.value
            ? "You have lifetime access. Thank you!"
            : "Your Pro plan is active.";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.sp),
        gradient: const LinearGradient(
          colors: [Color(0xFF0172FF), Color(0xFF014499)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1.h),
          Row(
            children: [
              Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 22.sp),
              SizedBox(width: 2.w),
              Text(
                label,
                style: AppTextTheme.h5.copyWith(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            subtitle,
            style: AppTextTheme.body2.copyWith(color: Colors.white),
          ),
          SizedBox(height: 2.h),
          if (!sub.isLifetime.value)
            CustomButton(
              text: "Manage subscription",
              onTap: () {
                Get.snackbar(
                  "Manage subscription",
                  "Manage or cancel your plan from your device's store account settings (App Store / Google Play).",
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 4),
                );
              },
              borderRadius: 15.sp,
              backgroundColor: Colors.white,
              textColor: AppColors.textBlack,
              borderColor: Colors.transparent,
            ),
          SizedBox(height: 1.h),
          TextButton(
            onPressed: () => sub.restorePurchases(),
            child: Text(
              "Restore Purchases",
              style: AppTextTheme.body3.copyWith(color: Colors.white),
            ),
          ),
        ],
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
