import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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

  final List<String> filters = ["All", "Favourites", "Office", "Archive"];

  getData() async {
    await transcribeController.fetchAllUsersTranscribes();
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
                () => SingleChildScrollView(
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
                              style: AppTextTheme.body2.copyWith(
                                fontWeight: FontWeight.w600,
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
                ),
              ),
              SizedBox(height: 3.h),

              // 🗒 Notes List
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    itemCount: transcribeController.allUsersTranscribe.length,
                    itemBuilder: (context, index) {
                      final note =
                          transcribeController.allUsersTranscribe[index];

                      return InkWell(
                        onTap: () {
                          aiController.transcriptText.value =
                              note.transcribeText ?? '';
                          aiController.getSummary();
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
                                      // ✅ Title fallback
                                      Text(
                                        "Transcription",
                                        style: AppTextTheme.body2.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textBlack,
                                        ),
                                      ),
                                      SizedBox(height: 1.h),

                                      // ✅ Show text or placeholder
                                      Text(
                                        note.transcribeText?.isNotEmpty == true
                                            ? note.transcribeText!
                                            : "Processing...",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextTheme.body3.copyWith(
                                          color: AppColors.textBlack,
                                        ),
                                      ),
                                      SizedBox(height: 1.h),

                                      // ✅ Format date cleanly
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
                  ),
                ),
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
