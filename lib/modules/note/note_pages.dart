import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/routing/app_routes.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../widgets/white_card.dart';
import '../../widgets/tag_card.dart';
import 'widgets/share_bottom_sheet.dart';

class NotePage extends StatelessWidget {
  NotePage({super.key});

  final RxInt selectedTab = 0.obs; // 0: Structured Notes, 1: Transcript

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back icon
              SizedBox(height: 3.h),
              InkWell(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.arrow_back,
                  size: 20.sp,
                  color: AppColors.textBlack,
                ),
              ),
              SizedBox(height: 3.h),

              // Tabs
              Obx(() {
                if (selectedTab.value.isEven) {}
                return Row(
                  children: [
                    _buildTab("Structured Notes", 0),
                    _buildTab("Transcript", 1),
                  ],
                );
              }),

              // ✅ Wrap scrollable content in Expanded
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3.h),

                      // SizedBox(height: 3.h),

                      // Title
                      Text(
                        "Tavastra Round 1 Discussion",
                        style: AppTextTheme.h4.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                      SizedBox(height: 0.7.h),

                      // Date and Time
                      Text(
                        "August 5, 2025  6:45 PM",
                        style: AppTextTheme.body3.copyWith(
                          color: AppColors.textBlack,
                        ),
                      ),
                      SizedBox(height: 1.7.h),

                      //category tag
                      Row(
                        children: [
                          TagCard(text: "All", color: AppColors.cardYellow),
                          SizedBox(width: 2.w),
                          // TagCard(text: "Office", color: AppColors.cardGreen),
                          // SizedBox(width: 2.w),
                          // TagCard(
                          //   text: "Kalpataru",
                          //   color: AppColors.cardPurple,
                          // ),
                          // SizedBox(width: 2.w),
                          InkWell(
                            onTap: () {
                              // add new tag
                            },
                            borderRadius: BorderRadius.circular(8.sp),
                            child: Container(
                              height: 3.8.h,
                              width: 3.8.h,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.grey400,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8.sp),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                size: 18.sp,
                                color: AppColors.grey600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.8.h),

                      // Summary section
                      Text(
                        "Summary",
                        style: AppTextTheme.body1Medium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                      SizedBox(height: 1.2.h),
                      Text(
                        "Hi this is a demo summary for the initial testing of the Svar AI. Other note taking AI platform are currently being evaluated, focusing on its overall capabilities and functionality for audio recording.\n\nEngineers provided context that technical inspections are typically conducted entirely in English.",
                        style: AppTextTheme.body2.copyWith(
                          color: AppColors.textBlack,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 3.h),

                      // Action Items
                      Text(
                        "Action Items",
                        style: AppTextTheme.body1Medium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      _buildBulletPoint(
                        "Ongoing assessment of audio recording quality is crucial to determining the platform’s effectiveness.",
                      ),
                      _buildBulletPoint(
                        "What specifically you worked in design, umm… not design leave that Tell me what worked you did on distribution.",
                      ),
                      _buildBulletPoint(
                        "Yeah, sure! I worked on researching the twitter accounts.",
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const BottomFloatingButtons(),
    );
  }

  // Tab builder
  Widget _buildTab(String title, int index) {
    return Obx(
      () => GestureDetector(
        onTap: () => selectedTab.value = index,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 0.5.h),
            Text(
              title,
              style: AppTextTheme.body1Medium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
                // : AppColors.grey500,
              ),
            ),
            SizedBox(height: 1.2.h),
            Container(
              height: 0.1.h,
              width: 45.w,
              decoration: BoxDecoration(
                color: selectedTab.value == index
                    ? AppColors.lightGrey
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(5.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // bullet point widget
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("  •   "),
          Expanded(
            child: Text(
              text,
              style: AppTextTheme.body2.copyWith(
                color: AppColors.textBlack,
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔘 Bottom buttons
class BottomFloatingButtons extends StatelessWidget {
  const BottomFloatingButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      height: 9.h,
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {},
            child: Image.asset(AppAssets.spark, width: 12.w),
          ),
          InkWell(
            onTap: () {},
            child: Image.asset(AppAssets.note, width: 12.w),
          ),
          InkWell(
            onTap: () {
              Get.toNamed(AppRoutes.recordingNotePage);
            },
            child: Image.asset(AppAssets.plus, width: 12.w),
          ),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => const ShareBottomSheet(),
              );
            },
            child: Image.asset(AppAssets.share, width: 12.w),
          ),
          InkWell(
            onTap: () {},
            child: Image.asset(AppAssets.threeDots, height: 4.h),
          ),
        ],
      ),
    );
  }
}
