import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class RewriteBottomSheet extends StatelessWidget {
  const RewriteBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.sp),
          topRight: Radius.circular(20.sp),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle + Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 0.7.h,
                width: 10.w,
                decoration: BoxDecoration(
                  color: AppColors.grey400,
                  borderRadius: BorderRadius.circular(12.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 53.w,
                child: Text(
                  "Rewrite",
                  textAlign: TextAlign.end,
                  style: AppTextTheme.button.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(50),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.grey600,
                  size: 20.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // ===== Creator Section =====
          Text(
            "Creator",
            style: AppTextTheme.button.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
          SizedBox(height: 1.h),

          _buildOptionTile(
            iconPath: AppAssets.x,
            title: "X Post",
            subtitle: "Make an engaging tweet",
          ),
          _buildDivider(),
          _buildOptionTile(
            iconPath: AppAssets.x,
            title: "X Thread",
            subtitle: "Transform into series of tweets",
          ),
          _buildDivider(),
          _buildOptionTile(
            iconPath: AppAssets.facebook,
            title: "Facebook",
            subtitle: "Make an engaging social media post",
          ),
          _buildDivider(),
          _buildOptionTile(
            iconPath: AppAssets.linkedIn,
            title: "Linkedin Posts",
            subtitle: "Make a professional post",
          ),

          SizedBox(height: 2.h),

          // ===== Text Editing Section =====
          Text(
            "Text Editing",
            style: AppTextTheme.button.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
          SizedBox(height: 1.h),

          _buildOptionTile(
            iconPath: AppAssets.stickyNote,
            title: "Meeting Notes",
            subtitle: "Clean up chaotic conversations into insightful Notes",
          ),
          _buildDivider(),
          _buildOptionTile(
            iconPath: AppAssets.journal,
            title: "Journal",
            subtitle: "Journal out your day",
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required String iconPath,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(10.sp),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          children: [
            Image.asset(iconPath, width: 6.w, height: 6.w, fit: BoxFit.contain),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextTheme.body1Medium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    subtitle,
                    style: AppTextTheme.body3.copyWith(
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() =>
      Divider(color: AppColors.grey300, thickness: 0.5, height: 0);
}
