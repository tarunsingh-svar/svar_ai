import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/widgets/white_card.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

class PricingPage extends StatelessWidget {
  const PricingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 22.h),
              Text("Unlimited access to SVAR AI", style: AppTextTheme.body1),
              SizedBox(height: 3.h),

              // ✅ Feature List
              _buildFeature("15+ rewrite options"),
              _buildFeature("Unlimited number of notes"),
              _buildFeature("No limit on recording duration"),
              _buildFeature("Access to SVAR AI"),
              SizedBox(height: 3.5.h),

              // ✅ Yearly Plan
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // ✅ Main Card
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 1.5.h,
                      horizontal: 5.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14.sp),
                      border: Border.all(
                        color: AppColors.darkGreen,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ✅ Left Text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Yearly", style: AppTextTheme.body1Medium),
                            SizedBox(height: 0.5.h),
                            Text(
                              "Pay once a year",
                              style: AppTextTheme.caption.copyWith(
                                color: AppColors.textBlack,
                              ),
                            ),
                          ],
                        ),

                        // ✅ Right Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "\$2499",
                              style: AppTextTheme.button.copyWith(
                                color: AppColors.textBlack,
                              ),
                            ),
                            Text(
                              "\$46.10/week",
                              style: AppTextTheme.caption.copyWith(
                                color: AppColors.textBlack,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ✅ “Best Deal” Pill
                  Positioned(
                    top: -12.sp,
                    right: 25,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 0.6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkGreen,
                        borderRadius: BorderRadius.circular(12.sp),
                      ),
                      child: Text(
                        "Best Deal",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // ✅ Monthly Plan
              Container(
                padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 5.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.sp),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0172FF), // bright blue
                      Color(0xFF014499), // deep blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ Left Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Monthly",
                          style: AppTextTheme.body1Medium.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          "Cancel anytime",
                          style: AppTextTheme.caption.copyWith(
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),

                    // ✅ Right Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$599",
                          style: AppTextTheme.button.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          "\$149.10/week",
                          style: AppTextTheme.caption.copyWith(
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),

              // ✅ Start Now Button
              WhiteCard(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 1.h),
                height: 8.h,
                margin: EdgeInsets.zero,
                color: AppColors.surface,
                borderRadius: 12.sp,
                child: Column(
                  children: [
                    Text(
                      "Start Now",
                      style: AppTextTheme.h1.copyWith(fontSize: 18.sp),
                    ),
                    Text("Cancel anytime", style: AppTextTheme.body3),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // ✅ Terms & Privacy
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Terms of use", style: AppTextTheme.body3),
                  SizedBox(width: 10.w),
                  Text("Privacy Policy", style: AppTextTheme.body3),
                ],
              ),

              SizedBox(height: 2.5.h),

              // ✅ Footer small note
              Text(
                "After the subscription is successfully completed, you can enjoy unlimited access to all features.\nAccording to policy of single plan only, your subscription will renew automatically at the renewal of the same term.",
                style: AppTextTheme.caption.copyWith(
                  fontSize: 10.sp,
                  color: AppColors.textBlack,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.info, size: 18.sp),
          SizedBox(width: 2.w),
          Text(text, style: AppTextTheme.body2.copyWith(fontSize: 15.sp)),
        ],
      ),
    );
  }
}
