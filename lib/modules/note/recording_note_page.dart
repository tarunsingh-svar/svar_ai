import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:svar_ai/modules/ai/ai_controller.dart';
import 'package:svar_ai/modules/note/note_pages.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/note_formatters.dart';
import '../../../core/theme/text_styles.dart';
import '../../../widgets/white_card.dart';
import '../../widgets/editable_text_widget.dart';
import '../../widgets/tag_card.dart';
import '../ai/transcribe_controller.dart';

class RecordingNotePage extends StatefulWidget {
  const RecordingNotePage({super.key});

  @override
  State<RecordingNotePage> createState() => _RecordingNotePageState();
}

class _RecordingNotePageState extends State<RecordingNotePage> {
  final AIController aiController = Get.find();
  final TranscribeController transcribeController = Get.find();

  final RxInt selectedTab = 0.obs;

  static const _tagColors = [
    AppColors.cardYellow,
    AppColors.cardGreen,
    AppColors.cardPurple,
  ];

  @override
  void initState() {
    super.initState();
    _syncNoteHeaderFromDb();
  }

  void _syncNoteHeaderFromDb() {
    final note = transcribeController.currentNote;
    if (note == null) return;
    final title = note.title?.trim();
    aiController.headingText.value =
        (title != null && title.isNotEmpty) ? title : 'Untitled Note';
  }

  Future<void> _showAddTagDialog() async {
    final noteId = transcribeController.thisNoteId.value;
    if (noteId == 0) return;

    final tagController = TextEditingController();
    final added = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Add tag'),
        content: TextField(
          controller: tagController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tag name'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final tag = tagController.text.trim();
              if (tag.isNotEmpty) Get.back(result: tag);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (added == null || added.isEmpty) return;

    final tags = List<String>.from(transcribeController.currentTags);
    if (tags.contains(added)) return;
    tags.add(added);
    await transcribeController.updateTags(noteId, tags);
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
                        ? Obx(() {
                            if (aiController.isSummaryLoading.value) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 3.h),

                                  _shimmerBox(
                                    width: 60.w,
                                    height: 3.h,
                                  ), // Title
                                  SizedBox(height: 1.h),
                                  _shimmerBox(
                                    width: 40.w,
                                    height: 2.h,
                                  ), // Date + Duration
                                  SizedBox(height: 2.h),

                                  // Tags
                                  Row(
                                    children: List.generate(
                                      4,
                                      (i) => Padding(
                                        padding: EdgeInsets.only(right: 2.w),
                                        child: _shimmerBox(
                                          width: 15.w,
                                          height: 4.h,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 2.5.h),

                                  // Summary Title
                                  _shimmerBox(width: 30.w, height: 2.5.h),
                                  SizedBox(height: 2.h),

                                  // Summary Paragraph Lines
                                  ...List.generate(
                                    4,
                                    (i) => Padding(
                                      padding: EdgeInsets.only(bottom: 1.5.h),
                                      child: _shimmerBox(
                                        width: (50 + Random().nextInt(40)).w,
                                        height: 2.h,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 3.h),

                                  // Action Items Title
                                  _shimmerBox(width: 30.w, height: 2.5.h),
                                  SizedBox(height: 2.h),

                                  // Bullet list shimmer
                                  ...List.generate(
                                    3,
                                    (i) => Padding(
                                      padding: EdgeInsets.only(bottom: 1.5.h),
                                      child: Row(
                                        children: [
                                          _shimmerBox(
                                            width: 2.h,
                                            height: 2.h,
                                            isCircle: true,
                                          ),
                                          SizedBox(width: 2.w),
                                          _shimmerBox(
                                            width:
                                                (50 + Random().nextInt(30)).w,
                                            height: 2.h,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.h),
                                ],
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 2.h),
                                EditableTextWidget(
                                  text: aiController.headingText.value,
                                  style: AppTextTheme.h4.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlack,
                                  ),
                                  onChanged: (val) {
                                    aiController.headingText.value = val;
                                    transcribeController.updateTitle(
                                      transcribeController.thisNoteId.value,
                                      val,
                                    );
                                  },
                                ),

                                SizedBox(height: .5.h),
                                Obx(() {
                                  final note = transcribeController.currentNote;
                                  final dateText = note != null
                                      ? formatNoteDate(note.createdAt)
                                      : formatNoteDate(DateTime.now());
                                  final durationText = formatRecordingDuration(
                                    transcribeController
                                        .recordingDurationSeconds.value,
                                  );
                                  return Text(
                                    '$dateText   •   $durationText',
                                    style: AppTextTheme.body3.copyWith(
                                      color: AppColors.textBlack,
                                    ),
                                  );
                                }),
                                SizedBox(height: 2.h),

                                Obx(() {
                                  final tags = transcribeController.currentTags;
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        ...List.generate(tags.length, (i) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              right: 2.w,
                                            ),
                                            child: TagCard(
                                              text: tags[i],
                                              color: _tagColors[
                                                  i % _tagColors.length],
                                            ),
                                          );
                                        }),
                                        InkWell(
                                          onTap: _showAddTagDialog,
                                          borderRadius:
                                              BorderRadius.circular(8.sp),
                                          child: Container(
                                            height: 3.8.h,
                                            width: 3.8.h,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.grey400,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.sp),
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
                                  );
                                }),

                                SizedBox(height: 2.5.h),
                                Text(
                                  aiController.headingText.value,
                                  style: AppTextTheme.body1Medium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                // Text(
                                //   aiController.generatedText.value,
                                //   style: AppTextTheme.body2.copyWith(
                                //     color: AppColors.textBlack,
                                //     fontSize: 15.sp,
                                //   ),
                                // ),
                                EditableTextWidget(
                                  text: aiController.generatedText.value,
                                  style: AppTextTheme.body2.copyWith(
                                    color: AppColors.textBlack,
                                    fontSize: 15.sp,
                                  ),
                                  maxLines: 200,
                                  onChanged: (val) {
                                    return aiController.generatedText.value =
                                        val;
                                  },
                                ),

                                SizedBox(height: 3.h),

                                // Text(
                                //   "Action Items",
                                //   style: AppTextTheme.body1Medium.copyWith(
                                //     fontWeight: FontWeight.w600,
                                //     color: AppColors.textBlack,
                                //   ),
                                // ),
                                // SizedBox(height: 2.h),
                                // _buildBulletPoint(
                                //   "Real-time transcription accuracy is above 90%.",
                                // ),
                                // _buildBulletPoint(
                                //   "Detected speakers are automatically labeled.",
                                // ),
                                // _buildBulletPoint(
                                //   "Summarization happens within 5 seconds post recording.",
                                // ),
                                SizedBox(height: 10.h),
                              ],
                            );
                          })
                        : Obx(() {
                            if (aiController.isLoading.value &&
                                aiController.transcriptText.isEmpty) {
                              return Padding(
                                padding: EdgeInsets.only(top: 3.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(20, (i) {
                                    double w = (50 + Random().nextInt(40)).w;

                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 1.5.h),
                                      child: Shimmer(
                                        duration: const Duration(
                                          milliseconds: 800,
                                        ),
                                        interval: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: Container(
                                          width: w,
                                          height: 2.h,
                                          decoration: BoxDecoration(
                                            color: AppColors.cardGrey,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }

                            if (aiController.transcriptText.value.isEmpty) {
                              return Column(
                                children: [
                                  SizedBox(height: 3.h),
                                  Text(
                                    "No transcript found",
                                    style: AppTextTheme.body2,
                                  ),
                                  SizedBox(height: 10.h),
                                ],
                              );
                            }

                            return Column(
                              children: [
                                SizedBox(height: 3.h),
                                // Text(
                                //   aiController.transcriptText.value,
                                //   style: AppTextTheme.body2,
                                // ),
                                EditableTextWidget(
                                  text: aiController.transcriptText.value,
                                  style: AppTextTheme.body2,
                                  maxLines: 200,
                                  onChanged: (val) {
                                    transcribeController.updateTranscribeText(
                                      transcribeController.thisNoteId.value,
                                      val,
                                    );
                                    return aiController.transcriptText.value =
                                        val;
                                  },
                                ),

                                SizedBox(height: 10.h),
                              ],
                            );
                          }),
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

  // Widget _buildBulletPoint(String text) {
  //   return Padding(
  //     padding: EdgeInsets.only(bottom: 1.2.h),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text("  •   "),
  //         Expanded(
  //           child: Text(
  //             text,
  //             style: AppTextTheme.body2.copyWith(
  //               color: AppColors.textBlack,
  //               fontSize: 15.sp,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _shimmerBox({
    required double width,
    required double height,
    bool isCircle = false,
  }) {
    return Shimmer(
      duration: const Duration(milliseconds: 800),
      interval: const Duration(milliseconds: 200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardGrey,
          borderRadius: isCircle
              ? BorderRadius.circular(50)
              : BorderRadius.circular(6),
        ),
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
