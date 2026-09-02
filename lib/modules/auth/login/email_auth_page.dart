import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../widgets/custom_button.dart';
import 'login_controller.dart';
import 'login_metrics.dart';

class EmailAuthPage extends StatefulWidget {
  const EmailAuthPage({super.key});

  @override
  State<EmailAuthPage> createState() => _EmailAuthPageState();
}

class _EmailAuthPageState extends State<EmailAuthPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _linkSent = false;
  String _sentToEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = Get.find<LoginController>();
    final email = _emailController.text.trim();
    final sent = await controller.sendMagicLink(email);
    if (!sent || !mounted) return;

    setState(() {
      _linkSent = true;
      _sentToEmail = email;
      _otpController.clear();
    });
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      Get.snackbar(
        'Enter the 6-digit code',
        'Use the code from your email if the link did not open the app.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final controller = Get.find<LoginController>();
    await controller.verifyEmailOtp(_sentToEmail, code);
  }

  Future<void> _resendLink() async {
    final controller = Get.find<LoginController>();
    final sent = await controller.sendMagicLink(_sentToEmail);
    if (!sent || !mounted) return;

    Get.snackbar(
      'Link sent again',
      'Check your inbox and spam folder for $_sentToEmail.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginController = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textBlack,
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: LoginMetrics.horizontalPadding(context),
            vertical: 8 * LoginMetrics.h(context),
          ),
          child: _linkSent ? _buildSentState(context) : _buildForm(context, loginController),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, LoginController loginController) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continue with email',
            style: AppTextTheme.h2.copyWith(
              fontSize: LoginMetrics.headlineFontSize(context) * 0.85,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: LoginMetrics.headlineToSubtextGap(context)),
          Text(
            'Enter your email and we\'ll send you a secure sign-in link.',
            style: AppTextTheme.body1.copyWith(
              fontSize: LoginMetrics.subtextFontSize(context),
              color: AppColors.textGrey,
              height: 1.45,
            ),
          ),
          SizedBox(height: LoginMetrics.subtextToButtonsGap(context)),
          Text('Email', style: AppTextTheme.body2),
          SizedBox(height: 8 * LoginMetrics.h(context)),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: _inputDecoration(context, 'you@company.com'),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Email is required';
              if (!GetUtils.isEmail(email)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          SizedBox(height: LoginMetrics.subtextToButtonsGap(context)),
          Obx(
            () => Opacity(
              opacity: loginController.isLoading.value ? 0.6 : 1,
              child: CustomButton(
                text: loginController.isLoading.value
                    ? 'Sending link...'
                    : 'Send sign-in link',
                onTap: loginController.isLoading.value ? () {} : _submit,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentState(BuildContext context) {
    final loginController = Get.find<LoginController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 48 * LoginMetrics.w(context),
          color: AppColors.primary,
        ),
        SizedBox(height: LoginMetrics.logoToHeadlineGap(context)),
        Text(
          'Check your email',
          style: AppTextTheme.h2.copyWith(
            fontSize: LoginMetrics.headlineFontSize(context) * 0.85,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: LoginMetrics.headlineToSubtextGap(context)),
        Text.rich(
          TextSpan(
            text: 'We sent a sign-in link to ',
            style: AppTextTheme.body1.copyWith(
              fontSize: LoginMetrics.subtextFontSize(context),
              color: AppColors.textGrey,
              height: 1.45,
            ),
            children: [
              TextSpan(
                text: _sentToEmail,
                style: const TextStyle(
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(
                text:
                    '. Open it on this device to continue. Also check spam or Promotions.',
              ),
            ],
          ),
        ),
        SizedBox(height: LoginMetrics.subtextToButtonsGap(context)),
        Text(
          'Have a 6-digit code instead?',
          style: AppTextTheme.body2.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8 * LoginMetrics.h(context)),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          maxLength: 6,
          onSubmitted: (_) => _verifyOtp(),
          decoration: _inputDecoration(context, '123456').copyWith(
            counterText: '',
          ),
        ),
        SizedBox(height: LoginMetrics.headlineToSubtextGap(context)),
        Obx(
          () => Opacity(
            opacity: loginController.isLoading.value ? 0.6 : 1,
            child: CustomButton(
              text: loginController.isLoading.value
                  ? 'Verifying...'
                  : 'Verify code',
              onTap: loginController.isLoading.value ? () {} : _verifyOtp,
            ),
          ),
        ),
        SizedBox(height: LoginMetrics.headlineToSubtextGap(context)),
        Obx(
          () => TextButton(
            onPressed: loginController.isLoading.value ? null : _resendLink,
            child: Text(
              'Resend link',
              style: AppTextTheme.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _linkSent = false;
              _sentToEmail = '';
              _otpController.clear();
            });
          },
          child: Text(
            'Use a different email',
            style: AppTextTheme.body2.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16 * LoginMetrics.w(context),
        vertical: 14 * LoginMetrics.h(context),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LoginMetrics.buttonRadius(context)),
        borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LoginMetrics.buttonRadius(context)),
        borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LoginMetrics.buttonRadius(context)),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(LoginMetrics.buttonRadius(context)),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
