import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_assets.dart';

import '../../../core/constants/app_colors.dart';
import '../../../widgets/white_card.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      height: 5.h,
      width: double.infinity,
      color: AppColors.surface,
      borderRadius: 30.sp,
      shadowColor: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          SizedBox(width: 2.w),
          Image.asset(AppAssets.search, height: 3.h),
          SizedBox(width: 3.w),
          Expanded(
            child: TextFormField(
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                // hintText: "Search...",
                hintStyle: TextStyle(color: AppColors.grey500, fontSize: 16.sp),
                border: InputBorder.none,

                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
