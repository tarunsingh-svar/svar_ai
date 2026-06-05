import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_colors.dart';
import 'package:svar_ai/core/theme/text_styles.dart';

/// Bottom sheet for creating a new tag. Returns the tag name or null.
Future<String?> showCreateTagSheet() {
  return Get.bottomSheet<String>(
    const _CreateTagSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.black54,
    isDismissible: true,
    enableDrag: true,
  );
}

class _CreateTagSheet extends StatefulWidget {
  const _CreateTagSheet();

  @override
  State<_CreateTagSheet> createState() => _CreateTagSheetState();
}

class _CreateTagSheetState extends State<_CreateTagSheet> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canCreate => _controller.text.trim().isNotEmpty;

  void _create() {
    final tag = _controller.text.trim();
    if (tag.isEmpty) return;
    Get.back(result: tag);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, mq.padding.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(8),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20.sp,
                      color: AppColors.textBlack,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Create Tag',
                        style: AppTextTheme.body1Medium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20.sp),
                ],
              ),
              SizedBox(height: 2.5.h),
              TextField(
                controller: _controller,
                autofocus: true,
                style: TextStyle(fontSize: 15.sp, color: AppColors.textBlack),
                decoration: InputDecoration(
                  hintText: 'Enter tag name',
                  hintStyle: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.grey500,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.sp,
                    vertical: 14.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.sp),
                    borderSide: BorderSide(color: AppColors.grey300, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.sp),
                    borderSide: BorderSide(color: AppColors.grey300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.sp),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                  ),
                ),
                onSubmitted: (_) => _canCreate ? _create() : null,
              ),
              SizedBox(height: 2.h),
              _ActionButton(
                label: 'Create',
                isActive: _canCreate,
                onTap: _canCreate ? _create : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.isActive,
    this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 1.8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.grey200,
          borderRadius: BorderRadius.circular(14.sp),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextTheme.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textBlack,
            ),
          ),
        ),
      ),
    );
  }
}
