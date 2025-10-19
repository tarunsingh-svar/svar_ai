import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_colors.dart';

import '../core/theme/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Widget? widget;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.widget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius ?? 17.sp),
          border: Border.all(
            color: borderColor ?? Colors.grey.shade400,
            width: 2.5.sp,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: AppTextTheme.button.copyWith(
                color: textColor ?? AppColors.primary,
                // fontSize: 16.sp,
                // fontWeight: FontWeight.w500,
              ),
            ),
            if (widget != null) ...[SizedBox(width: 1.w), widget!],
          ],
        ),
      ),
    );
  }
}
