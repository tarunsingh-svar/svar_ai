import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../widgets/legal_link.dart';
import '../../welcome/widgets/svar_mark.dart';
import 'login_controller.dart';
import 'login_metrics.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loginController = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: LoginMetrics.horizontalPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: LoginMetrics.topPadding(context)),
                      SizedBox(
                        width: LoginMetrics.logoWidth(context),
                        height: LoginMetrics.logoHeight(context),
                        child: SvarMark(
                          size: LoginMetrics.logoWidth(context),
                          showShadow: false,
                        ),
                      ),
                      SizedBox(height: LoginMetrics.logoToHeadlineGap(context)),
                      _LoginHeadline(context),
                      SizedBox(height: LoginMetrics.headlineToSubtextGap(context)),
                      Text(
                        'Log in or Sign Up and start capturing instantly.',
                        textAlign: TextAlign.start,
                        style: AppTextTheme.body1.copyWith(
                          fontSize: LoginMetrics.subtextFontSize(context),
                          color: AppColors.textGrey,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: LoginMetrics.subtextToButtonsGap(context)),
              Obx(
                () => _AuthButton(
                  onTap: loginController.isLoading.value
                      ? null
                      : () => loginController.loginWithGoogle(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.google,
                        height: LoginMetrics.emailIconSize(context),
                      ),
                      SizedBox(width: 12 * LoginMetrics.w(context)),
                      Text(
                        loginController.isLoading.value
                            ? 'Signing in...'
                            : 'Continue with google',
                        style: AppTextTheme.button.copyWith(
                          color: AppColors.textBlack,
                          fontSize: LoginMetrics.buttonFontSize(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: LoginMetrics.orDividerGap(context)),
              _OrDivider(context),
              SizedBox(height: LoginMetrics.orDividerGap(context)),
              _AuthButton(
                onTap: () => Get.toNamed(AppRoutes.emailAuth),
                child: Icon(
                  Icons.mail_outline_rounded,
                  size: LoginMetrics.emailIconSize(context),
                  color: AppColors.grey600,
                ),
              ),
              SizedBox(height: LoginMetrics.buttonsToFooterGap(context)),
              Align(
                alignment: Alignment.center,
                child: _LegalFooter(context),
              ),
              SizedBox(height: LoginMetrics.bottomPadding(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginHeadline extends StatelessWidget {
  const _LoginHeadline(this.context);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final style = AppTextTheme.h2.copyWith(
      fontSize: LoginMetrics.headlineFontSize(this.context),
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.5,
    );

    return Text.rich(
      TextSpan(
        text: 'Your ',
        style: style.copyWith(color: AppColors.textBlack),
        children: [
          TextSpan(
            text: 'thoughts\n',
            style: style.copyWith(color: AppColors.primary),
          ),
          TextSpan(
            text: 'are ready\n',
            style: style.copyWith(color: AppColors.textBlack),
          ),
          TextSpan(
            text: 'for ',
            style: style.copyWith(color: AppColors.textBlack),
          ),
          TextSpan(
            text: 'SVAR.',
            style: style.copyWith(color: AppColors.primary),
          ),
        ],
      ),
      textAlign: TextAlign.start,
    );
  }
}

class _AuthButton extends StatelessWidget {
  const _AuthButton({required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final height = LoginMetrics.buttonHeight(context);
    final radius = LoginMetrics.buttonRadius(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 12,
              offset: Offset(0, 4 * LoginMetrics.h(context)),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider(this.context);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.borderGrey,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * LoginMetrics.w(context)),
          child: Text(
            'OR',
            style: AppTextTheme.caption.copyWith(
              fontSize: LoginMetrics.legalFontSize(context),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: AppColors.grey500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.borderGrey,
          ),
        ),
      ],
    );
  }
}

class _LegalFooter extends StatelessWidget {
  const _LegalFooter(this.context);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final base = AppTextTheme.caption.copyWith(
      fontSize: LoginMetrics.legalFontSize(context),
      color: AppColors.textGrey,
      height: 1.45,
    );

    return Text.rich(
      TextSpan(
        text: 'By Continuing, you agree to our ',
        style: base,
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: LegalLink(
              label: 'Terms of Service',
              route: AppRoutes.termsOfServicePage,
              style: base.copyWith(
                color: AppColors.textGrey,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          TextSpan(text: ' and ', style: base),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: LegalLink(
              label: 'Privacy Policy',
              route: AppRoutes.privacyPolicyPage,
              style: base.copyWith(
                color: AppColors.textGrey,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          TextSpan(text: '.', style: base),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
