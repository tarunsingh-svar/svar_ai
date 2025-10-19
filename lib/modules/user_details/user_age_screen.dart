import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/widgets/custom_button.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/routing/app_routes.dart';

class UserAgeScreen extends StatelessWidget {
  UserAgeScreen({super.key});

  final RxInt selectedIndex = (-1).obs;

  final List<String> ageOptions = const [
    'Less than 18 Years',
    '18 - 24 years',
    '24 - 40 years',
    '40 - 50 years',
    '50 - 60 years',
    '60 + Years',
  ];

  void _onContinue() {
    if (selectedIndex.value != -1) {
      // You can store this selection to a controller or backend here
      Get.toNamed(AppRoutes.userProfession);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 21.h),

              // Title
              Text('What is your Age?', style: AppTextTheme.h2),

              SizedBox(height: 6.h),

              // Age Options
              Obx(
                () => Column(
                  children: List.generate(ageOptions.length, (index) {
                    final bool isSelected = selectedIndex.value == index;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 2.5.h),
                      child: GestureDetector(
                        onTap: () => selectedIndex.value = index,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 1.1.h,
                            horizontal: 5.w,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 0.6,
                            ),
                          ),
                          child: Text(
                            ageOptions[index],
                            style: AppTextTheme.body2.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textBlack,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const Spacer(),

              // Continue Button
              CustomButton(
                text: "Continue",
                onTap: _onContinue,
                widget: Icon(
                  Icons.arrow_forward_ios_rounded,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  size: 16.sp,
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
