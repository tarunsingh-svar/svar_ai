import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:svar_ai/core/routing/app_routes.dart';
import 'package:svar_ai/modules/ai/ai_controller.dart';
import 'package:svar_ai/modules/ai/transcribe_controller.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../widgets/white_card.dart';
import 'home_controller.dart';
import 'widgets/search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homeController = Get.put(HomeController());
  final TranscribeController transcribeController = Get.find();
  final AIController aiController = Get.find();

  final isLoading = false.obs;
  getData() async {
    isLoading.value = true;
    await transcribeController.fetchAllUsersTranscribes();
    homeController.syncFilterWithAvailableTags();
    isLoading.value = false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
              SizedBox(height: 4.h),
              // 🔍 Search bar
              CustomSearchBar(),
              SizedBox(height: 3.h),

              // 🔘 Filter chips
              Obx(
                () {
                  final filters = homeController.availableFilters;
                  return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filters.map((filter) {
                      final bool isSelected =
                          homeController.selectedFilter.value == filter;
                      return Padding(
                        padding: EdgeInsets.only(right: 2.w),
                        child: GestureDetector(
                          onTap: () => homeController.changeFilter(filter),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.5.w,
                              vertical: 0.6.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.5.sp,
                                color: AppColors.grey500,
                              ),
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(20.sp),
                            ),
                            child: Text(
                              filter,
                              style: AppTextTheme.homeFilterChip.copyWith(
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.textGrey,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
                },
              ),
              SizedBox(height: 3.h),

              // 🗒 Notes List
              // 🗒 Notes List with Loading Shimmers
              Expanded(
                child: Obx(() {
                  if (transcribeController.allUsersTranscribe.isEmpty &&
                      isLoading.isTrue) {
                    // ✅ Show shimmer placeholders
                    return ListView.builder(
                      itemCount: 6,
                      itemBuilder: (_, __) => Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Shimmer(
                          child: WhiteCard(
                            height: 13.h,
                            color: AppColors.surface,
                            boxShadow: [],
                            borderRadius: 15.sp,
                            margin: EdgeInsets.zero,
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 2.h,
                                        width: 30.w,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 1.h),
                                      Container(
                                        height: 2.h,
                                        width: 50.w,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 1.h),
                                      Container(
                                        height: 1.8.h,
                                        width: 20.w,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Container(
                                  height: 2.5.h,
                                  width: 2.5.h,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final filteredNotes = homeController.filteredNotes;

                  if (transcribeController.allUsersTranscribe.isNotEmpty &&
                      filteredNotes.isEmpty) {
                    return Center(
                      child: Text(
                        "No matching notes",
                        style: AppTextTheme.h2.copyWith(
                          color: AppColors.grey400,
                        ),
                      ),
                    );
                  }

                  // ✅ Normal List View
                  if (filteredNotes.isNotEmpty) {
                    return ListView.builder(
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = filteredNotes[index];

                        return InkWell(
                          onTap: () {
                            transcribeController.thisNoteId.value = note.id;
                            transcribeController.recordingDurationSeconds.value =
                                note.durationSeconds;
                            if (note.durationSeconds == 0) {
                              transcribeController.currentAudioPath.value = '';
                            }
                            final title = note.title?.trim();
                            aiController.headingText.value =
                                (title != null && title.isNotEmpty)
                                    ? title
                                    : 'Untitled Note';
                            aiController.transcriptText.value =
                                note.transcribeText ?? '';
                            final savedSummary = note.summaryText?.trim();
                            aiController.generatedText.value = savedSummary ?? '';
                            if (savedSummary == null || savedSummary.isEmpty) {
                              aiController.getSummary();
                            }
                            Get.toNamed(AppRoutes.recordingNotePage);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: WhiteCard(
                              height: 13.h,
                              color: AppColors.surface,
                              boxShadow: [],
                              borderRadius: 15.sp,
                              margin: EdgeInsets.zero,
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 2.h,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (note.title ?? "").trim().isNotEmpty
                                              ? note.title!.trim()
                                              : "Untitled Note",
                                          style: AppTextTheme.homeCardTitle,
                                        ),
                                        SizedBox(height: 1.h),
                                        Text(
                                          note.transcribeText?.isNotEmpty ==
                                                  true
                                              ? note.transcribeText!
                                              : "Processing...",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextTheme.homeCardBody,
                                        ),
                                        SizedBox(height: 1.h),
                                        Text(
                                          note.createdAt
                                              .toLocal()
                                              .toString()
                                              .split('.')[0],
                                          style: AppTextTheme.caption.copyWith(
                                            color: AppColors.textBlack,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 22.sp,
                                    color: AppColors.textBlack,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text(
                        "No notes found",
                        style: AppTextTheme.h2.copyWith(
                          color: AppColors.grey400,
                        ),
                      ),
                    );
                  }
                }),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),

      // 🎤 Bottom bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: BottomFloatingButtons(),
    );
  }
}

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
            onTap: () {
              Get.toNamed(AppRoutes.createNotePage);
            },
            child: Image.asset(AppAssets.pen),
          ),
          InkWell(
            onTap: () {
              Get.find<TranscribeController>().prepareNewRecordingSession();
              Get.toNamed(AppRoutes.recordPage);
            },
            child: Image.asset(AppAssets.mic),
          ),
          InkWell(
            onTap: () {
              Get.toNamed(AppRoutes.settingsPage);
            },
            child: Image.asset(AppAssets.settings),
          ),
        ],
      ),
    );
  }
}
