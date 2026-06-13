import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_colors.dart';
import 'package:svar_ai/core/constants/legal_content.dart';
import 'package:svar_ai/core/theme/text_styles.dart';

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    super.key,
    required this.title,
    required this.sections,
  });

  final String title;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(8),
                    child: Icon(
                      Icons.arrow_back,
                      size: 22.sp,
                      color: AppColors.textBlack,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: AppTextTheme.body1Medium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 22.sp),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last updated: ${LegalContent.lastUpdated}',
                      style: AppTextTheme.body3.copyWith(
                        color: AppColors.textGrey,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    ...sections.map(
                      (section) => Padding(
                        padding: EdgeInsets.only(bottom: 2.5.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.title,
                              style: AppTextTheme.body1Medium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textBlack,
                              ),
                            ),
                            SizedBox(height: 0.8.h),
                            Text(
                              section.body,
                              style: AppTextTheme.body2.copyWith(
                                color: AppColors.textBlack,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
