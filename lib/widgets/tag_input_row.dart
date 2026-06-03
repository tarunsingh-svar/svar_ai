import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_colors.dart';
import 'package:svar_ai/core/theme/text_styles.dart';
import 'package:svar_ai/widgets/tag_picker_sheet.dart';

class TagInputRow extends StatelessWidget {
  const TagInputRow({super.key, required this.tags});

  final RxList<Map<String, dynamic>> tags;

  static const _tagColors = [
    AppColors.cardYellow,
    AppColors.cardGreen,
    AppColors.darkGreen,
    AppColors.cardPurple,
  ];

  Future<void> _openTagPicker() async {
    final currentStrings = tags.map((t) => t['text'] as String).toList();
    final result = await showTagPickerSheet(selectedTags: currentStrings);
    if (result == null) return;

    // Rebuild list, preserving colours for existing tags
    final colorMap = {
      for (final t in tags) (t['text'] as String).toLowerCase(): t['color'],
    };
    int newColorIdx = 0;
    tags.value = result.map((name) {
      final existing = colorMap[name.toLowerCase()];
      if (existing != null) return {'text': name, 'color': existing};
      final color = _tagColors[
          (tags.length + newColorIdx++) % _tagColors.length];
      return {'text': name, 'color': color};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: [
          // Existing tags — tap to remove
          ...tags.map((t) => _RemovableTagChip(
                text: t['text'] as String,
                color: t['color'] as Color,
                onRemove: () => tags.remove(t),
              )),

          // "+" button to open picker
          InkWell(
            onTap: _openTagPicker,
            borderRadius: BorderRadius.circular(8.sp),
            child: Container(
              height: 3.8.h,
              width: 3.8.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300, width: 1),
                borderRadius: BorderRadius.circular(8.sp),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 18.sp,
                color: AppColors.grey600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemovableTagChip extends StatelessWidget {
  const _RemovableTagChip({
    required this.text,
    required this.color,
    required this.onRemove,
  });

  final String text;
  final Color color;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 4.w, right: 1.5.w, top: 0.7.h, bottom: 0.7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: AppColors.grey300, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: AppTextTheme.body3Medium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 1.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 14.sp,
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
