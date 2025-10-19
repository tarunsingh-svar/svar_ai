import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/text_styles.dart';

class IntroScreen1 extends StatelessWidget {
  const IntroScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.h),

        // Image
        Image.asset(AppAssets.intro1, height: 40.h),
        SizedBox(height: 5.h),

        // Title
        Text.rich(
          TextSpan(
            text: 'Still',
            style: AppTextTheme.h3,
            children: [
              TextSpan(
                text: ' scrambling ',
                style: AppTextTheme.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: 'to capture every detail in meetings?',
                style: AppTextTheme.h3,
              ),
            ],
          ),
          textAlign: TextAlign.left,
        ),

        SizedBox(height: 2.h),

        // Description
        Text(
          "Stop worrying about missed action items.\nWe’ll handle the notes while you stay present.",
          style: AppTextTheme.body1,
        ),
      ],
    );
  }
}
