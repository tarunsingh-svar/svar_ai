import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/modules/user_details/controller/user_details_controller.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/custom_button.dart';

class UserUsageScreen extends StatelessWidget {
  UserUsageScreen({super.key});

  final RxInt selectedIndex = (-1).obs;

  final List<String> usageOptions = const [
    'Meetings & Work',
    'Content Creation & Ideas',
    'Personal Notes',
    'Social Media Posts',
    'Journaling',
    'Take Lecture Notes',
  ];

  void _onContinue() async {
    if (selectedIndex.value != -1) {
      final UserDetailsController userDetailsController = Get.find();
      userDetailsController.email.value = "ankityadav12014@gmail.com";
      await userDetailsController.saveUserDetails();
      Get.offAllNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserDetailsController userDetailsController = Get.find();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 17.h),

              // Title
              RichText(
                text: TextSpan(
                  text: 'What do you want to use ',
                  style: AppTextTheme.h2,
                  children: [
                    TextSpan(
                      text: 'SVAR ',
                      style: AppTextTheme.h2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const TextSpan(text: 'for?'),
                  ],
                ),
              ),

              SizedBox(height: 6.h),

              // Options
              Obx(
                () => Column(
                  children: List.generate(usageOptions.length, (index) {
                    final bool isSelected = selectedIndex.value == index;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 2.5.h),
                      child: GestureDetector(
                        onTap: () {
                          selectedIndex.value = index;
                          userDetailsController.usage.value =
                              usageOptions[index];
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 1.h,
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
                            usageOptions[index],
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
