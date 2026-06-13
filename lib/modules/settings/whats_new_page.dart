import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_colors.dart';
import 'package:svar_ai/core/constants/whats_new_content.dart';
import 'package:svar_ai/core/theme/text_styles.dart';

class WhatsNewPage extends StatelessWidget {
  const WhatsNewPage({super.key});

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
                        "What's New",
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
              child: ListView(
                padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 4.h),
                children: [
                  Text(
                    'Recent updates and new features in SVAR AI.',
                    style: AppTextTheme.body3.copyWith(color: AppColors.textGrey),
                  ),
                  SizedBox(height: 3.h),
                  ...WhatsNewContent.releases.map(
                    (release) => _ReleaseSection(release: release),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReleaseSection extends StatelessWidget {
  const _ReleaseSection({required this.release});

  final WhatsNewRelease release;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.sp),
                ),
                child: Text(
                  'v${release.version}',
                  style: AppTextTheme.body3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                release.dateLabel,
                style: AppTextTheme.body3.copyWith(color: AppColors.textGrey),
              ),
            ],
          ),
          if (release.summary != null) ...[
            SizedBox(height: 1.2.h),
            Text(
              release.summary!,
              style: AppTextTheme.body2.copyWith(
                color: AppColors.textBlack,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
          SizedBox(height: 2.h),
          ...release.features.map(
            (feature) => Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: _FeatureCard(feature: feature),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final WhatsNewFeature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(color: AppColors.grey300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (feature.imageAsset != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                feature.imageAsset!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.cardGrey,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 28.sp,
                    color: AppColors.grey500,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: AppTextTheme.body1Medium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  feature.description,
                  style: AppTextTheme.body2.copyWith(
                    color: AppColors.textBlack,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
