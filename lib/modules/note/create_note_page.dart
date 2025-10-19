import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_colors.dart';
import 'package:svar_ai/core/theme/text_styles.dart';
import 'package:svar_ai/core/constants/app_assets.dart';
import 'package:svar_ai/widgets/white_card.dart';
import '../../widgets/tag_card.dart';

class CreateNotePage extends StatelessWidget {
  CreateNotePage({super.key});

  final RxInt selectedTab = 0.obs;
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final summaryController = TextEditingController();
  final actionItemsController = TextEditingController();

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
              // Back button
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
              Obx(
                () => Row(
                  children: [
                    _buildTab("Structured Notes", 0),
                    _buildTab("Transcript", 1),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3.h),

                      // Title input
                      TextField(
                        controller: titleController,
                        style: AppTextTheme.h4.copyWith(
                          color: AppColors.textBlack,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter Note Title",
                          hintStyle: AppTextTheme.body2.copyWith(
                            color: AppColors.grey500,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(height: 0.5.h),

                      // Date input
                      TextField(
                        controller: dateController,
                        style: AppTextTheme.body3.copyWith(
                          color: AppColors.textBlack,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter Date & Time",
                          hintStyle: AppTextTheme.body3.copyWith(
                            color: AppColors.grey500,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      SizedBox(height: 1.5.h),

                      // Category tags
                      Row(
                        children: [
                          TagCard(text: "All", color: AppColors.cardYellow),
                          SizedBox(width: 2.w),
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
                      SizedBox(height: 2.h),

                      // Summary input
                      Text(
                        "Summary",
                        style: AppTextTheme.body1Medium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextField(
                        controller: summaryController,
                        maxLines: 6,
                        style: AppTextTheme.body2.copyWith(
                          color: AppColors.textBlack,
                          fontSize: 15.sp,
                        ),
                        decoration: InputDecoration(
                          hintText: "Write a summary...",
                          hintStyle: AppTextTheme.body2.copyWith(
                            color: AppColors.grey500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.sp),
                            borderSide: BorderSide(
                              color: AppColors.grey400,
                              width: 1,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(12.sp),
                        ),
                      ),
                      SizedBox(height: 3.h),

                      // Action Items input
                      Text(
                        "Action Items",
                        style: AppTextTheme.body1Medium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      TextField(
                        controller: actionItemsController,
                        maxLines: 6,
                        style: AppTextTheme.body2.copyWith(
                          color: AppColors.textBlack,
                          fontSize: 15.sp,
                        ),
                        decoration: InputDecoration(
                          hintText: "Add action items (one per line)...",
                          hintStyle: AppTextTheme.body2.copyWith(
                            color: AppColors.grey500,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.sp),
                            borderSide: BorderSide(
                              color: AppColors.grey400,
                              width: 1,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(12.sp),
                        ),
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

      // Bottom buttons
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const CreateNoteBottomButtons(),
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
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTextTheme.body1Medium.copyWith(
                fontWeight: FontWeight.w600,
                color: selectedTab.value == index
                    ? AppColors.textBlack
                    : AppColors.grey500,
              ),
            ),
            Container(
              height: 0.2.h,
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
}

// 🔘 Bottom buttons
class CreateNoteBottomButtons extends StatelessWidget {
  const CreateNoteBottomButtons({super.key});

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
              // save note logic here
            },
            child: Image.asset(AppAssets.plus, width: 12.w),
          ),
          InkWell(
            onTap: () {},
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
