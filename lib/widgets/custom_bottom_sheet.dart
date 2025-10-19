import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../core/constants/app_colors.dart';

/// Global reusable custom bottom sheet
class CustomBottomSheet extends StatelessWidget {
  final List<Widget> children;

  /// Optional customization
  final Color? backgroundColor;
  final double? topRadius;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;

  const CustomBottomSheet({
    super.key,
    required this.children,
    this.backgroundColor,
    this.topRadius,
    this.padding,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final sheetContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );

    return Container(
      padding:
          padding ??
          EdgeInsets.only(left: 5.w, right: 5.w, top: 4.h, bottom: 3.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topRadius ?? 25.sp),
          topRight: Radius.circular(topRadius ?? 25.sp),
        ),
      ),
      child: scrollable
          ? SingleChildScrollView(child: sheetContent)
          : sheetContent,
    );
  }
}

/// Utility function to show this bottom sheet anywhere
void showCustomBottomSheet({
  required List<Widget> children,
  Color? backgroundColor,
  double? topRadius,
  EdgeInsetsGeometry? padding,
  bool scrollable = false,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  Get.bottomSheet(
    CustomBottomSheet(
      backgroundColor: backgroundColor,
      topRadius: topRadius,
      padding: padding,
      scrollable: scrollable,
      children: children,
    ),
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent, // for rounded corners
  );
}
