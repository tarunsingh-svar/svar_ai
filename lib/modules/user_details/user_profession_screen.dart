import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/modules/user_details/controller/user_details_controller.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/custom_button.dart';

class UserProfessionScreen extends StatelessWidget {
  UserProfessionScreen({super.key});

  final RxInt selectedIndex = (-1).obs;

  final List<String> options = const [
    'Professional',
    'Content Creator',
    'Student',
    'Founder / C-level Executive',
    'Medical Professional',
    'Service',
  ];

  void _onContinue() {
    if (selectedIndex.value != -1) {
      Get.toNamed(AppRoutes.userUsage);
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
              SizedBox(height: 18.h),

              // Title
              Text(
                'Tell us a little bit\nabout what you do?',
                style: AppTextTheme.h2,
              ),

              SizedBox(height: 4.h),

              // Profession Options
              Obx(
                () => Column(
                  children: List.generate(options.length, (index) {
                    final bool isSelected = selectedIndex.value == index;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 2.5.h),
                      child: GestureDetector(
                        onTap: () {
                          selectedIndex.value = index;
                          userDetailsController.profession.value =
                              options[index];
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
                            options[index],
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
