import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:svar_ai/modules/user_details/controller/user_details_controller.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/keys.dart';
import '../../core/routing/app_routes.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/custom_button.dart';

class UserUsageScreen extends StatelessWidget {
  UserUsageScreen({super.key});

  final RxList<int> selectedIndices = <int>[].obs;

  final List<String> usageOptions = const [
    'Meetings & Work',
    'Content Creation & Ideas',
    'Personal Notes',
    'Social Media Posts',
    'Journaling',
    'Take Lecture Notes',
  ];

  void _toggleOption(int index, UserDetailsController controller) {
    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index);
    } else {
      selectedIndices.add(index);
    }

    final selected = selectedIndices.toList()..sort();
    controller.usage.value =
        selected.map((i) => usageOptions[i]).join(', ');
  }

  void _onContinue() async {
    if (selectedIndices.isNotEmpty) {
      EasyLoading.show(maskType: EasyLoadingMaskType.black);
      final userDetailsController = Get.find<UserDetailsController>();
      final prefs = Get.find<SharedPreferences>();
      final supabase = Supabase.instance.client;

      // get current user’s email safely
      final email = supabase.auth.currentUser?.email;

      if (email != null) {
        userDetailsController.email.value = email;
        userDetailsController.saveUserDetails();
        // mark onboarding done
        prefs.setBool(Keys.hasOnboarded, true);
        EasyLoading.dismiss();
        Get.offAllNamed(AppRoutes.home);
      } else {
        // fallback if user not logged in
        Get.snackbar('Error', 'No user found. Please login again.');
        Get.offAllNamed(AppRoutes.login);
      }
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

              SizedBox(height: 1.5.h),

              Text(
                'Select all that apply',
                style: AppTextTheme.body2.copyWith(color: AppColors.textGrey),
              ),

              SizedBox(height: 4.h),

              // Options
              Obx(
                () => Column(
                  children: List.generate(usageOptions.length, (index) {
                    final bool isSelected = selectedIndices.contains(index);

                    return Padding(
                      padding: EdgeInsets.only(bottom: 2.5.h),
                      child: GestureDetector(
                        onTap: () =>
                            _toggleOption(index, userDetailsController),
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
