import 'package:flutter/material.dart';
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
      constraints: BoxConstraints(maxHeight: 90.h),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.sp),
          topRight: Radius.circular(20.sp),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Drag handle
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

            /// Title + Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
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
                  child: Container(
                    padding: EdgeInsets.all(0.5.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.grey400),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.grey600,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            /// Core Productivity
            _sectionTitle("Core Productivity"),
            _buildOptionTile(
              iconPath: AppAssets.quickList,
              title: "Quick List",
              subtitle: "Converts thoughts into clean bullet points",
              onTap: () => _execute(aiController.generateQuickList),
            ),
            _divider(),
            _buildOptionTile(
              iconPath: AppAssets.stickyNote,
              title: "Meeting Notes",
              subtitle: "Turns discussions into clean summaries",
              onTap: () => _execute(aiController.generateMeetingNotes),
            ),
            _divider(),
            _buildOptionTile(
              iconPath: AppAssets.toDoList,
              title: "To-do List",
              subtitle: "Checklist-ready action items",
              onTap: () => _execute(aiController.generateTodoList),
            ),
            _divider(),

            SizedBox(height: 2.h),

            /// Work Meetings & Collaboration
            _sectionTitle("Work Meetings & Collaboration"),
            _buildOptionTile(
              iconPath: AppAssets.dailyStandup,
              title: "Daily Standup",
              subtitle: "Classic stand-up style update",
              onTap: () => _execute(aiController.generateDailyStandup),
            ),
            _divider(),
            _buildOptionTile(
              iconPath: AppAssets.featureDiscussion,
              title: "Feature Discussion",
              subtitle: "Structured product talk format",
              onTap: () => _execute(aiController.generateFeatureDiscussion),
            ),
            _divider(),
            _buildOptionTile(
              iconPath: AppAssets.interview,
              title: "User Interview Summary",
              subtitle: "Extract insights from interviews",
              onTap: () => _execute(aiController.generateInterviewSummary),
            ),
            _divider(),
            _buildOptionTile(
              iconPath: AppAssets.delegation,
              title: "Delegation Note",
              subtitle:
                  "Assigns tasks clearly to others using Who / What / When structure.",
              onTap: () => _execute(aiController.generateDelegationNote),
            ),
            _divider(),

            SizedBox(height: 2.h),

            /// Professional Writing
            _sectionTitle("Professional Writing"),
            _buildOptionTile(
              iconPath: AppAssets.email,
              title: "Email - Casual",
              subtitle:
                  "Turns notes into friendly, short emails for informal updates.",
              onTap: () => _execute(aiController.generateEmailCasual),
            ),
            _divider(),
            _buildOptionTile(
              iconPath: AppAssets.email,
              title: "Email - Formal",
              subtitle: "Converts notes into structured, professional emails.",
              onTap: () => _execute(aiController.generateEmailFormal),
            ),
            _divider(),

            SizedBox(height: 2.h),

            /// Creator
            _sectionTitle("Creator"),
            _buildOptionTile(
              iconPath: AppAssets.x,
              title: "X Post",
              subtitle: "Make an engaging tweet",
              onTap: () => _execute(aiController.generateXPost),
            ),
            _divider(),
            _buildOptionTile(
              iconPath: AppAssets.x,
              title: "X Thread",
              subtitle: "Transform into series of tweets",
              onTap: () => _execute(aiController.generateXThread),
            ),
            _divider(),
            _buildOptionTile(
              iconPath: AppAssets.insta,
              title: "Short Video Script",
              subtitle: "Make an engaging attention catching script.",
              onTap: () => _execute(aiController.generateShortVideoScript),
            ),
            _divider(),
            _buildOptionTile(
              iconPath: AppAssets.linkedIn,
              title: "LinkedIn Posts",
              subtitle: "Make a professional post",
              onTap: () => _execute(aiController.generateLinkedInPost),
            ),
            _divider(),
            _buildOptionTile(
              iconPath: AppAssets.contentOutline,
              title: "Content Outline",
              subtitle:
                  "Creates a structured outline for posts, videos, or newsletters",
              onTap: () => _execute(aiController.generateContentOutline),
            ),
            _divider(),

            SizedBox(height: 2.h),

            /// Learning & Research
            _sectionTitle("Learning & Research"),
            _buildOptionTile(
              iconPath: AppAssets.lectureSummary,
              title: "Lecture/Class Summary",
              subtitle:
                  "Turns notes into friendly, short emails for informal updates.",
              onTap: () => _execute(aiController.generateLectureSummary),
            ),
            _divider(),

            SizedBox(height: 2.h),

            /// Journaling & Personal
            _sectionTitle("Journaling & Personal"),
            _buildOptionTile(
              iconPath: AppAssets.journal,
              title: "Daily Journal Entry",
              subtitle: "Summarizes personal reflections or thoughts.",
              onTap: () => _execute(aiController.generateJournal),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Future<void> _execute(Future<void> Function() fn) async {
    Get.back();
    fn();
  }

  Widget _sectionTitle(String title) => Padding(
    padding: EdgeInsets.symmetric(vertical: 1.h),
    child: Text(
      title,
      style: AppTextTheme.button.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textBlack,
      ),
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

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';
// import '../../../core/constants/app_assets.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/theme/text_styles.dart';
// import '../../ai/ai_controller.dart';

// class RewriteBottomSheet extends StatelessWidget {
//   RewriteBottomSheet({super.key});
//   final AIController aiController = Get.find<AIController>();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: BoxConstraints(maxHeight: 80.h),
//       padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20.sp),
//           topRight: Radius.circular(20.sp),
//         ),
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _topBar(context),
//             SizedBox(height: 2.h),

//             /// Core Productivity
//             _sectionTitle("Core Productivity"),
//             _tile(
//               AppAssets.quickList,
//               "Quick List",
//               "Clean bullet points",
//               () => _run(aiController.generateQuickList),
//             ),
//             _divider(),
//             _tile(
//               AppAssets.stickyNote,
//               "Meeting Notes",
//               "Clean up conversations",
//               () => _run(aiController.generateMeetingNotes),
//             ),
//             _divider(),
//             _tile(
//               AppAssets.toDoList,
//               "To-do List",
//               "Checklist ready",
//               () => _run(aiController.generateTodoList),
//             ),

//             SizedBox(height: 2.h),

//             /// Work Meetings & Collaboration
//             _sectionTitle("Work Meetings & Collaboration"),
//             _tile(
//               AppAssets.dailyStandup,
//               "Daily Standup",
//               "Classic stand-up format",
//               () => _run(aiController.generateDailyStandup),
//             ),
//             _divider(),
//             _tile(
//               AppAssets.featureDiscussion,
//               "Feature Discussion",
//               "Structured product talks",
//               () => _run(aiController.generateFeatureDiscussion),
//             ),
//             _divider(),
//             _tile(
//               AppAssets.interview,
//               "User Interview Summary",
//               "Insights from interviews",
//               () => _run(aiController.generateInterviewSummary),
//             ),
//             _divider(),
//             _tile(
//               AppAssets.delegation,
//               "Delegation Note",
//               "Assign tasks clearly",
//               () => _run(aiController.generateDelegationNote),
//             ),

//             SizedBox(height: 2.h),

//             /// Professional Writing
//             _sectionTitle("Professional Writing"),
//             _tile(
//               AppAssets.email,
//               "Email – Casual",
//               "Friendly short emails",
//               () => _run(aiController.generateEmailCasual),
//             ),
//             _divider(),
//             _tile(
//               AppAssets.email,
//               "Email – Formal",
//               "Structured professional emails",
//               () => _run(aiController.generateEmailFormal),
//             ),

//             SizedBox(height: 2.h),

//             /// Creator
//             _sectionTitle("Creator"),
//             _tile(
//               AppAssets.x,
//               "X Post",
//               "Engaging single tweet",
//               () => _run(aiController.generateXPost),
//             ),
//             _divider(),
//             _tile(
//               AppAssets.x,
//               "X Thread",
//               "Series of tweets",
//               () => _run(aiController.generateXThread),
//             ),
//             _divider(),
//             _tile(
//               AppAssets.insta,
//               "Short Video Script (Reel/TikTok)",
//               "Attention grabbing script",
//               () => _run(aiController.generateShortVideoScript),
//             ),
//             _divider(),
//             _tile(
//               AppAssets.linkedIn,
//               "LinkedIn Posts",
//               "Professional tone",
//               () => _run(aiController.generateLinkedInPost),
//             ),
//             _divider(),
//             _tile(
//               AppAssets.contentOutline,
//               "Content Outline",
//               "Structured outline for posts",
//               () => _run(aiController.generateContentOutline),
//             ),

//             SizedBox(height: 2.h),

//             /// Learning & Research
//             _sectionTitle("Learning & Research"),
//             _tile(
//               AppAssets.note,
//               "Lecture/Class Summary",
//               "Short class summary",
//               () => _run(aiController.generateLectureSummary),
//             ),

//             SizedBox(height: 2.h),

//             /// Journaling
//             _sectionTitle("Journaling & Personal"),
//             _tile(
//               AppAssets.journal,
//               "Daily Journal Entry",
//               "Personal reflection",
//               () => _run(aiController.generateJournal),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _topBar(BuildContext context) => Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       const SizedBox(),
//       Text(
//         "Rewrite",
//         style: AppTextTheme.button.copyWith(
//           fontWeight: FontWeight.w600,
//           color: AppColors.textBlack,
//         ),
//       ),
//       InkWell(
//         onTap: () => Get.back(),
//         borderRadius: BorderRadius.circular(50),
//         child: Container(
//           padding: EdgeInsets.all(0.5.w),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(color: AppColors.grey400),
//           ),
//           child: Icon(
//             Icons.close_rounded,
//             color: AppColors.grey600,
//             size: 20.sp,
//           ),
//         ),
//       ),
//     ],
//   );

//   Widget _sectionTitle(String title) => Padding(
//     padding: EdgeInsets.only(bottom: 1.h),
//     child: Text(
//       title,
//       style: AppTextTheme.button.copyWith(
//         fontWeight: FontWeight.bold,
//         color: AppColors.textBlack,
//       ),
//     ),
//   );

//   Widget _tile(
//     String icon,
//     String title,
//     String subtitle,
//     Future<void> Function() fn,
//   ) {
//     return InkWell(
//       onTap: () => _run(fn),
//       borderRadius: BorderRadius.circular(10.sp),
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: 1.5.h),
//         child: Row(
//           children: [
//             Image.asset(icon, width: 6.w, height: 6.w),
//             SizedBox(width: 4.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: AppTextTheme.body1Medium.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.textBlack,
//                     ),
//                   ),
//                   SizedBox(height: 0.3.h),
//                   Text(
//                     subtitle,
//                     style: AppTextTheme.body3.copyWith(
//                       color: AppColors.textBlack,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _divider() =>
//       Divider(color: AppColors.grey300, thickness: 0.6, height: 0);

//   Future<void> _run(Future<void> Function() fn) async {
//     print("*******************************************");

//     if (Navigator.of(Get.context!).canPop()) {
//       Navigator.pop(Get.context!);
//     }

//     await fn();
//   }
// }
