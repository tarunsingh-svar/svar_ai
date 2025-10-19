import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_assets.dart';
import 'package:svar_ai/core/constants/app_colors.dart';
import 'package:svar_ai/core/theme/text_styles.dart';
import 'package:svar_ai/widgets/tag_input_row.dart';
import 'package:svar_ai/widgets/white_card.dart';

class CreateNotePage extends StatelessWidget {
  CreateNotePage({super.key});

  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final noteController = TextEditingController();

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
              SizedBox(height: 3.h),

              // Back button
              InkWell(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.arrow_back,
                  size: 20.sp,
                  color: AppColors.textBlack,
                ),
              ),
              SizedBox(height: 3.h),
              // Content
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 3.h),

                    // Title input
                    TextField(
                      controller: titleController,
                      style: AppTextTheme.h4.copyWith(
                        fontWeight: FontWeight.w600,
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
                    SizedBox(height: 0.7.h),

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
                    SizedBox(height: 1.7.h),

                    // Category tags
                    TagInputRow(),
                    SizedBox(height: 2.8.h),

                    // ✅ Note Text Field (single large box)
                    TextField(
                      controller: noteController,
                      maxLines: 12,
                      style: AppTextTheme.body2.copyWith(
                        color: AppColors.textBlack,
                        fontSize: 15.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: "Write your note here...",
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
                        contentPadding: EdgeInsets.all(14.sp),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Buttons
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const CreateNoteBottomButtons(),
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
