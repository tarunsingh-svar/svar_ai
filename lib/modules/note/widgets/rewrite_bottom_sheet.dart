import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../ai/ai_controller.dart';

class RewriteBottomSheet extends StatelessWidget {
  RewriteBottomSheet({super.key});

  final AIController aiController = Get.find<AIController>();

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
          // Drag handle
          Center(
            child: Container(
              height: 0.7.h,
              width: 10.w,
              decoration: BoxDecoration(
                color: AppColors.grey400,
                borderRadius: BorderRadius.circular(12.sp),
              ),
            ),
          ),
          SizedBox(height: 1.h),

          // Title + Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rewrite",
                style: AppTextTheme.button.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
              ),
              InkWell(
                onTap: () => Get.back(),
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

          _sectionTitle("Creator"),

          _buildOptionTile(
            iconPath: AppAssets.x,
            title: "X Post",
            subtitle: "Make an engaging tweet",
            onTap: () async {
              Get.back();
              EasyLoading.show();
              await aiController.generateXPost();
              EasyLoading.dismiss();
            },
          ),
          _divider(),

          _buildOptionTile(
            iconPath: AppAssets.x,
            title: "X Thread",
            subtitle: "Series of tweets",
            onTap: () async {
              Get.back();
              EasyLoading.show();
              await aiController.generateXThread();
              EasyLoading.dismiss();
            },
          ),
          _divider(),

          _buildOptionTile(
            iconPath: AppAssets.facebook,
            title: "Facebook",
            subtitle: "Friendly post",
            onTap: () async {
              Get.back();
              EasyLoading.show();
              await aiController.generateFacebookPost();
              EasyLoading.dismiss();
            },
          ),
          _divider(),

          _buildOptionTile(
            iconPath: AppAssets.linkedIn,
            title: "LinkedIn Posts",
            subtitle: "Professional tone",
            onTap: () async {
              Get.back();
              EasyLoading.show();
              await aiController.generateLinkedInPost();
              EasyLoading.dismiss();
            },
          ),

          SizedBox(height: 2.h),

          _sectionTitle("Text Editing"),
          _buildOptionTile(
            iconPath: AppAssets.stickyNote,
            title: "Meeting Notes",
            subtitle: "Clean meeting content",
            onTap: () async {
              Get.back();
              EasyLoading.show();
              await aiController.generateMeetingNotes();
              EasyLoading.dismiss();
            },
          ),
          _divider(),

          _buildOptionTile(
            iconPath: AppAssets.journal,
            title: "Journal",
            subtitle: "Personal reflection",
            onTap: () async {
              Get.back();
              EasyLoading.show();
              await aiController.generateJournal();
              EasyLoading.dismiss();
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: AppTextTheme.button.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.textBlack,
    ),
  );

  Widget _buildOptionTile({
    required String iconPath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.sp),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          children: [
            Image.asset(iconPath, width: 6.w, height: 6.w),
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

  Widget _divider() =>
      Divider(color: AppColors.grey300, thickness: 0.6, height: 0);
}
