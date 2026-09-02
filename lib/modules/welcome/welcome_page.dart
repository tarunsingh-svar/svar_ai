import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/modules/intro/widgets/custom_button_intro.dart';
import 'package:svar_ai/modules/welcome/widgets/welcome_hero.dart';
import 'package:svar_ai/modules/welcome/widgets/welcome_metrics.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/routing/app_routes.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static final TextStyle _headline = AppTextTheme.h3.copyWith(
    fontWeight: FontWeight.w600,
    height: 1.28,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Column(
                  children: [
                    const Spacer(),
                    WelcomeHero(
                      logoSize: WelcomeMetrics.logoSize(context),
                    ),
                    SizedBox(
                      height: WelcomeMetrics.gapBelowHeroBox(context),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                WelcomeMetrics.horizontalContentPadding(context),
                0,
                WelcomeMetrics.horizontalContentPadding(context),
                WelcomeMetrics.bottomPadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Capture Every ',
                      style: _headline,
                      children: [
                        TextSpan(
                          text: 'Thought',
                          style: _headline.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: '. '),
                        const TextSpan(text: '\nTurn it into '),
                        TextSpan(
                          text: 'Action',
                          style: _headline.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: WelcomeMetrics.headlineToSubtextGap(context)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Speak it, save it, and let Svar make sense of it.',
                      maxLines: 1,
                      style: AppTextTheme.body1.copyWith(
                        color: AppColors.textGrey,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: WelcomeMetrics.buttonToSubtextGap(context),
                  ),
                  CustomButtonIntro(
                    text: 'Get Started',
                    widget: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primary,
                      size: 16.sp,
                    ),
                    onTap: () => Get.toNamed(AppRoutes.intro),
                  ),
                  SizedBox(height: WelcomeMetrics.loginToButtonGap(context)),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTextTheme.body2.copyWith(
                            color: AppColors.textBlack,
                            fontSize: 15.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.login),
                          child: Text(
                            'Login',
                            style: AppTextTheme.button.copyWith(
                              color: AppColors.primary,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
}
