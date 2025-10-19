import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/text_styles.dart';

class IntroScreen3 extends StatelessWidget {
  const IntroScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),

        // Image
        Image.asset(AppAssets.intro3, height: 40.h),
        SizedBox(height: 4.h),

        // Title
        Text.rich(
          TextSpan(
            text: 'Great ideas',
            style: AppTextTheme.h3,
            children: [
              TextSpan(
                text: ' slip ',
                style: AppTextTheme.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: "away before you can note\nthem down?",
                style: AppTextTheme.h3,
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Description
        Text(
          "Stop worrying about missed action items.\nWe’ll handle the notes while you stay present.",
          style: AppTextTheme.body1.copyWith(fontSize: 16.sp),
        ),
      ],
    );
  }
}
