import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/modules/ai/ai_controller.dart';
import 'package:svar_ai/modules/note/note_pages.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../widgets/white_card.dart';
import '../../widgets/tag_card.dart';

class RecordingNotePage extends StatefulWidget {
  const RecordingNotePage({super.key});

  @override
  State<RecordingNotePage> createState() => _RecordingNotePageState();
}

class _RecordingNotePageState extends State<RecordingNotePage> {
  final AIController aiController = Get.find();

  final RxInt selectedTab = 0.obs;

  getData() async {
    EasyLoading.show();
    await aiController.getSummary();
    EasyLoading.dismiss();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getData();
    });
  }

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
              // 🔙 Back icon
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
              Row(
                children: [
                  _buildTab("Structured Notes", 0),
                  _buildTab("Transcript", 1),
                ],
              ),

              // ✅ Scrollable content
              Expanded(
                child: Obx(() {
                  return SingleChildScrollView(
                    child: selectedTab.value == 0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 3.h),

                              // 🔹 Title
                              Text(
                                "Svar AI Demo Recording",
                                style: AppTextTheme.h4.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textBlack,
                                ),
                              ),
                              SizedBox(height: 0.5.h),

                              // Date and Duration
                              Text(
                                "October 13, 2025   •   12 min 48 sec",
                                style: AppTextTheme.body3.copyWith(
                                  color: AppColors.textBlack,
                                ),
                              ),
                              SizedBox(height: 2.h),

                              // 🔹 Tags
                              Row(
                                children: [
                                  TagCard(
                                    text: "All",
                                    color: AppColors.cardYellow,
                                  ),
                                  SizedBox(width: 2.w),
                                  TagCard(
                                    text: "Office",
                                    color: AppColors.cardGreen,
                                  ),
                                  SizedBox(width: 2.w),
                                  TagCard(
                                    text: "Kalpataru",
                                    color: AppColors.cardPurple,
                                  ),
                                  SizedBox(width: 2.w),
                                  InkWell(
                                    onTap: () {},
                                    borderRadius: BorderRadius.circular(8.sp),
                                    child: Container(
                                      height: 3.8.h,
                                      width: 3.8.h,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.grey400,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.sp,
                                        ),
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
                              SizedBox(height: 2.5.h),

                              // 🔹 Recording Summary
                              Text(
                                "Summary",
                                style: AppTextTheme.body1Medium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textBlack,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                aiController.summaryText.value,
                                // "This recording captures a short demo discussion regarding the AI note-taking capabilities of the Svar platform. The conversation focuses on how accurately the AI extracts structured notes, key points, and speaker differentiation.",
                                style: AppTextTheme.body2.copyWith(
                                  color: AppColors.textBlack,
                                  fontSize: 15.sp,
                                ),
                              ),
                              SizedBox(height: 3.h),

                              // 🔹 Key Highlights
                              Text(
                                "Action Items",
                                style: AppTextTheme.body1Medium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textBlack,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              _buildBulletPoint(
                                "Real-time transcription accuracy is above 90%.",
                              ),
                              _buildBulletPoint(
                                "Detected speakers are automatically labeled.",
                              ),
                              _buildBulletPoint(
                                "Summarization happens within 5 seconds post recording.",
                              ),
                              SizedBox(height: 10.h),
                            ],
                          )
                        : Column(
                            children: [
                              SizedBox(height: 3.h),
                              Text(
                                aiController.transcriptText.value,
                                style: AppTextTheme.body2,
                              ),
                            ],
                          ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),

      // ✅ Bottom Buttons
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: const RecordingBottomButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: BottomFloatingButtons(),
    );
  }

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
                color: selectedTab.value == index
                    ? AppColors.textBlack
                    : AppColors.grey500,
              ),
            ),
            SizedBox(height: 1.2.h),
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

// 🎙️ Bottom Buttons for Recording
class RecordingBottomButtons extends StatelessWidget {
  const RecordingBottomButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 5.w, right: 5.w, top: 5.h, bottom: 3.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.sp),
          topRight: Radius.circular(25.sp),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔵 Continue in Existing Note
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 2.2.h, horizontal: 4.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mic, color: AppColors.white, size: 20.sp),
                      SizedBox(width: 3.w),
                      Text(
                        "Continue in Existing Note",
                        style: AppTextTheme.body2.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16.sp,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 1.5.h),

          // ⚪ Start a new recording
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: WhiteCard(
              width: double.infinity,
              shadowColor: AppColors.surface,
              height: 7.h,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              borderRadius: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mic, color: AppColors.primary, size: 20.sp),
                      SizedBox(width: 3.w),
                      Text(
                        "Start a new recording",
                        style: AppTextTheme.body2.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16.sp,
                    color: AppColors.grey600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
