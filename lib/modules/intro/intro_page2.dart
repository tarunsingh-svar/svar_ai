import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/text_styles.dart';

class IntroScreen2 extends StatelessWidget {
  const IntroScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.h),

        // Image
        Image.asset(AppAssets.intro2, height: 40.h),
        SizedBox(height: 2.h),

        // Title
        Text.rich(
          TextSpan(
            text: 'Lost ',
            style: AppTextTheme.h3.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
            children: [
              TextSpan(
                text:
                    "important thoughts\nin WhatsApp drafts and sticky notes?",
                style: AppTextTheme.h3,
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Description
        Text(
          "Stop worrying about missed action items. We’ll handle the notes while you stay present.",
          style: AppTextTheme.body1.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}
