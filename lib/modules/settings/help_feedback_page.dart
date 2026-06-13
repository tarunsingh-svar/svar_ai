import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:svar_ai/core/constants/app_colors.dart';
import 'package:svar_ai/core/constants/support_config.dart';
import 'package:svar_ai/core/helpers/link_launcher.dart';
import 'package:svar_ai/core/theme/text_styles.dart';

class HelpFeedbackPage extends StatelessWidget {
  const HelpFeedbackPage({super.key});

  void _copyEmail() {
    Clipboard.setData(
      const ClipboardData(text: SupportConfig.supportEmail),
    );
    Get.snackbar(
      'Copied',
      'Support email copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(8),
                    child: Icon(
                      Icons.arrow_back,
                      size: 22.sp,
                      color: AppColors.textBlack,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Help & Feedback',
                        style: AppTextTheme.body1Medium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 22.sp),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppColors.cardGrey,
                        borderRadius: BorderRadius.circular(14.sp),
                        border: Border.all(color: AppColors.grey300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need help?',
                            style: AppTextTheme.body1Medium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textBlack,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text.rich(
                            TextSpan(
                              style: AppTextTheme.body2.copyWith(
                                color: AppColors.textBlack,
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'For any kind of help and support, please reach out to ',
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: _copyEmail,
                                    child: Text(
                                      SupportConfig.supportEmail,
                                      style: AppTextTheme.body2.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      ' with your account info (User ID from Settings > User Info).',
                                ),
                              ],
                            ),
                          ),
                          if (userId != null) ...[
                            SizedBox(height: 1.5.h),
                            Text(
                              'Your User ID',
                              style: AppTextTheme.body3.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textGrey,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            SelectableText(
                              userId,
                              style: AppTextTheme.body3.copyWith(
                                color: AppColors.textBlack,
                              ),
                            ),
                          ],
                          SizedBox(height: 2.h),
                          _ActionButton(
                            icon: Icons.mail_outline_rounded,
                            label: 'Email support',
                            onTap: () => LinkLauncher.openSupportEmail(
                              userId: userId,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'More options',
                      style: AppTextTheme.body2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBlack,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    _HelpOptionTile(
                      icon: Icons.rate_review_outlined,
                      title: 'Share feedback',
                      subtitle:
                          'Rate SVAR AI on the App Store or Google Play',
                      onTap: LinkLauncher.openStoreForFeedback,
                    ),
                    SizedBox(height: 1.5.h),
                    _HelpOptionTile(
                      icon: Icons.lightbulb_outline_rounded,
                      title: 'Request a feature',
                      subtitle: 'Tell us what you would like to see next',
                      onTap: LinkLauncher.openFeatureRequestForm,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.sp),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.sp),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp, color: AppColors.primary),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTextTheme.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpOptionTile extends StatelessWidget {
  const _HelpOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Future<bool> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      borderRadius: BorderRadius.circular(14.sp),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.sp),
          border: Border.all(color: AppColors.grey300),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: AppColors.cardGrey,
                borderRadius: BorderRadius.circular(10.sp),
              ),
              child: Icon(icon, size: 20.sp, color: AppColors.primary),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextTheme.body2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    subtitle,
                    style: AppTextTheme.body3.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: AppColors.grey500,
            ),
          ],
        ),
      ),
    );
  }
}
