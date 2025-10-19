import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class TagCard extends StatelessWidget {
  final String text;
  final Color color;

  const TagCard({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: AppColors.black, width: 2.sp),
      ),
      child: Text(
        text,
        style: AppTextTheme.body3Medium.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
