import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class CustomButtonIntro extends StatelessWidget {
  final String text;
  final Widget? widget;
  final VoidCallback onTap;

  const CustomButtonIntro({
    super.key,
    required this.text,
    required this.onTap,
    this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(17.sp),
          border: Border.all(width: 0.1.sp),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary,
              offset: const Offset(0, 4),
              // blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),

        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: AppTextTheme.button.copyWith(color: AppColors.primary),
            ),
            SizedBox(width: 1.w),
            if (widget != null) widget!,
          ],
        ),
      ),
    );
  }
}
