import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_colors.dart';
import 'package:svar_ai/core/theme/text_styles.dart';
import 'package:svar_ai/modules/auth/login/login_controller.dart';
import 'package:svar_ai/widgets/custom_button.dart';

class EmailAuthPage extends StatefulWidget {
  const EmailAuthPage({super.key});

  @override
  State<EmailAuthPage> createState() => _EmailAuthPageState();
}

class _EmailAuthPageState extends State<EmailAuthPage> {
  static const _minPasswordLength = 8;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = Get.find<LoginController>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isSignUp) {
      await controller.signUpWithEmail(email, password);
    } else {
      await controller.signInWithEmail(email, password);
    }
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
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSignUp ? 'Create your account' : 'Sign in with email',
                  style: AppTextTheme.h3,
                ),
                SizedBox(height: 1.h),
                Text(
                  _isSignUp
                      ? 'Choose an email and password to get started.'
                      : 'Enter your email and password to continue.',
                  style: AppTextTheme.body1.copyWith(color: AppColors.grey500),
                ),
                SizedBox(height: 4.h),
                Text('Email', style: AppTextTheme.body2),
                SizedBox(height: 0.8.h),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration('you@company.com'),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return 'Email is required';
                    if (!GetUtils.isEmail(email)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                Text('Password', style: AppTextTheme.body2),
                SizedBox(height: 0.8.h),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autofillHints: [
                    _isSignUp
                        ? AutofillHints.newPassword
                        : AutofillHints.password,
                  ],
                  textInputAction: _isSignUp
                      ? TextInputAction.next
                      : TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!_isSignUp) _submit();
                  },
                  decoration: _inputDecoration(
                    'At least $_minPasswordLength characters',
                  ).copyWith(
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.grey400,
                      ),
                    ),
                  ),
                  validator: (value) {
                    final password = value ?? '';
                    if (password.isEmpty) return 'Password is required';
                    if (password.length < _minPasswordLength) {
                      return 'Password must be at least $_minPasswordLength characters';
                    }
                    return null;
                  },
                ),
                if (_isSignUp) ...[
                  SizedBox(height: 2.h),
                  Text('Confirm password', style: AppTextTheme.body2),
                  SizedBox(height: 0.8.h),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: _inputDecoration('Re-enter your password'),
                    validator: (value) {
                      if ((value ?? '').isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
                SizedBox(height: 4.h),
                Obx(
                  () => Opacity(
                    opacity: loginController.isLoading.value ? 0.6 : 1,
                    child: CustomButton(
                      text: loginController.isLoading.value
                          ? (_isSignUp ? 'Creating account...' : 'Signing in...')
                          : (_isSignUp ? 'Create account' : 'Sign in'),
                      onTap: loginController.isLoading.value ? () {} : _submit,
                    ),
                  ),
                ),
                SizedBox(height: 2.5.h),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                        _confirmPasswordController.clear();
                      });
                    },
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign in'
                          : 'Create an account',
                      style: AppTextTheme.body2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.grey400.withValues(alpha: 0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.grey400.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
