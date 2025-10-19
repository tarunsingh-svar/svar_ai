import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_colors.dart';

class WhiteCard extends StatelessWidget {
  final double? height;
  final double? width;
  final Color? color;
  final double? borderRadius;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final Color? shadowColor;
  final List<BoxShadow>? boxShadow;

  const WhiteCard({
    super.key,
    this.height,
    this.width,
    this.color,
    this.borderRadius,
    this.child,
    this.padding,
    this.margin,
    this.border,
    this.shadowColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 6.h, // roughly matches 54dp
      width: width ?? 90.w, // roughly matches 333dp
      margin: margin ?? EdgeInsets.symmetric(horizontal: 5.w),
      padding: padding ?? EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 20.sp),
        border: border ?? Border.all(color: AppColors.grey300, width: 0.2),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: shadowColor ?? AppColors.grey200,
                offset: Offset(0, 4),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
      ),
      child: child,
    );
  }
}
