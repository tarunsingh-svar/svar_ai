import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:svar_ai/core/constants/app_colors.dart';
import 'package:svar_ai/core/theme/text_styles.dart';
import 'package:svar_ai/modules/subscription/subscription_controller.dart';
import 'package:svar_ai/modules/user_details/controller/user_details_controller.dart';
import 'package:svar_ai/widgets/custom_button.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final UserDetailsController _userDetails = Get.find();
  final SubscriptionController _sub = Get.find();
  late final TextEditingController _nameController;
  String _savedName = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    EasyLoading.show();
    await _userDetails.loadCurrentUserDetails();
    EasyLoading.dismiss();
    if (!mounted) return;
    _savedName = _userDetails.name.value;
    _nameController.text = _savedName;
    setState(() {});
  }

  bool get _nameChanged => _nameController.text.trim() != _savedName;

  Future<void> _saveName() async {
    _userDetails.name.value = _nameController.text.trim();
    EasyLoading.show(status: 'Saving...');
    final ok = await _userDetails.saveDisplayName();
    EasyLoading.dismiss();
    if (!mounted) return;
    if (ok) {
      _savedName = _userDetails.name.value;
      setState(() {});
      Get.snackbar(
        'Saved',
        'Your name was updated.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _copyUserId(String userId) {
    Clipboard.setData(ClipboardData(text: userId));
    Get.snackbar(
      'Copied',
      'User ID copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  String get _activePlanLabel {
    if (!_sub.isPro.value) return 'Free';
    if (_sub.isLifetime.value) return 'Lifetime Pro';
    if (_sub.isTrial.value) return 'Pro Trial';
    return 'Pro';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? '—';
    final email = user?.email ?? '—';

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
                        'User Info',
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
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your account details. Share your User ID when contacting support.',
                      style: AppTextTheme.body3.copyWith(color: AppColors.textGrey),
                    ),
                    SizedBox(height: 3.h),
                    _InfoField(
                      label: 'User ID',
                      hint: 'Unique ID for support requests',
                      value: userId,
                      readOnly: true,
                      trailing: IconButton(
                        onPressed: user == null ? null : () => _copyUserId(userId),
                        icon: Icon(Icons.copy_rounded, size: 18.sp),
                        color: AppColors.primary,
                        tooltip: 'Copy User ID',
                      ),
                    ),
                    SizedBox(height: 2.h),
                    _InfoField(
                      label: 'Name',
                      hint: 'Add your name',
                      controller: _nameController,
                      readOnly: false,
                      onChanged: (_) => setState(() {}),
                    ),
                    SizedBox(height: 2.h),
                    _InfoField(
                      label: 'Email',
                      hint: 'Email linked to this account',
                      value: email,
                      readOnly: true,
                    ),
                    SizedBox(height: 2.h),
                    Obx(
                      () => _InfoField(
                        label: 'Active plan',
                        hint: 'Your current subscription',
                        value: _activePlanLabel,
                        readOnly: true,
                      ),
                    ),
                    if (_nameChanged) ...[
                      SizedBox(height: 3.h),
                      CustomButton(
                        text: 'Save name',
                        onTap: _saveName,
                        borderRadius: 15.sp,
                      ),
                    ],
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

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.hint,
    this.value,
    this.controller,
    required this.readOnly,
    this.trailing,
    this.onChanged,
  });

  final String label;
  final String hint;
  final String? value;
  final TextEditingController? controller;
  final bool readOnly;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextTheme.body2.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          hint,
          style: AppTextTheme.body3.copyWith(color: AppColors.textGrey),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: readOnly ? AppColors.grey100 : AppColors.white,
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(color: AppColors.grey300),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Expanded(
                child: readOnly
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.4.h),
                        child: Text(
                          value ?? '',
                          style: AppTextTheme.body2.copyWith(
                            color: AppColors.textBlack,
                          ),
                        ),
                      )
                    : TextField(
                        controller: controller,
                        onChanged: onChanged,
                        style: AppTextTheme.body2.copyWith(
                          color: AppColors.textBlack,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Your name',
                          hintStyle: AppTextTheme.body2.copyWith(
                            color: AppColors.grey500,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 1.4.h),
                        ),
                      ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ],
    );
  }
}
