import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_colors.dart';
import 'package:svar_ai/core/theme/text_styles.dart';
import 'package:svar_ai/data/models/transcribe_model.dart';
import 'package:svar_ai/modules/ai/transcribe_controller.dart';

List<String> getAllExistingTags(List<TranscribeModel> notes) {
  final tags = notes
      .expand((note) => note.tags ?? const <String>[])
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toSet()
      .toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return tags;
}

/// Shows a tag management bottom sheet.
/// [selectedTags] — tags already selected for this note.
/// Returns the updated selected tags list, or null if dismissed.
Future<List<String>?> showTagPickerSheet({
  required List<String> selectedTags,
}) {
  return Get.bottomSheet<List<String>>(
    _TagPickerSheet(selectedTags: selectedTags),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _TagPickerSheet extends StatefulWidget {
  const _TagPickerSheet({required this.selectedTags});
  final List<String> selectedTags;

  @override
  State<_TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends State<_TagPickerSheet> {
  late List<String> _allTags;
  late Set<String> _selected;
  final _newTagController = TextEditingController();
  bool _showNewTagInput = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final tc = Get.find<TranscribeController>();
    _allTags = getAllExistingTags(tc.allUsersTranscribe);
    _selected = {
      for (final t in widget.selectedTags)
        if (t.trim().isNotEmpty) t.trim(),
    };
  }

  @override
  void dispose() {
    _newTagController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _isSelected(String tag) =>
      _selected.any((t) => t.toLowerCase() == tag.toLowerCase());

  void _toggle(String tag) => setState(() {
        if (_isSelected(tag)) {
          _selected.removeWhere((t) => t.toLowerCase() == tag.toLowerCase());
        } else {
          _selected.add(tag);
        }
      });

  void _createTag() {
    final tag = _newTagController.text.trim();
    if (tag.isEmpty) return;
    setState(() {
      if (!_allTags.any((t) => t.toLowerCase() == tag.toLowerCase())) {
        _allTags = [..._allTags, tag]
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      }
      _selected.add(tag);
      _newTagController.clear();
      _showNewTagInput = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final keyboardOpen = mq.viewInsets.bottom > 0;
    final maxHeight = mq.size.height - mq.viewInsets.bottom - mq.padding.top - 8;

    // #region agent log
    debugPrint(
      '[tag_picker] keyboardOpen=$keyboardOpen '
      'viewInsets=${mq.viewInsets.bottom} maxHeight=$maxHeight '
      'showInput=$_showNewTagInput tagCount=${_allTags.length}',
    );
    // #endregion

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
        ),
        child: Column(
          mainAxisSize: (_showNewTagInput && keyboardOpen)
              ? MainAxisSize.min
              : MainAxisSize.max,
          children: [
            SizedBox(height: 1.2.h),
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Row(
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
                        'Manage Tags',
                        style: AppTextTheme.body1Medium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showNewTagInput = !_showNewTagInput;
                        if (_showNewTagInput) {
                          Future.microtask(() => _focusNode.requestFocus());
                        } else {
                          _focusNode.unfocus();
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16.sp, color: AppColors.primary),
                        Text(
                          ' New',
                          style: AppTextTheme.body3.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.5.h),
            if (_showNewTagInput) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newTagController,
                        focusNode: _focusNode,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textBlack,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter tag name',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.grey500,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.sp,
                            vertical: 11.sp,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.sp),
                            borderSide: BorderSide(
                              color: AppColors.grey300,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.sp),
                            borderSide: BorderSide(
                              color: AppColors.grey300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.sp),
                            borderSide: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.45),
                              width: 1.2,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _createTag(),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    TextButton(
                      onPressed: _createTag,
                      child: Text(
                        'Create',
                        style: AppTextTheme.body3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.h),
            ],
            if (!(_showNewTagInput && keyboardOpen))
              Flexible(
                child: _allTags.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Center(
                          child: Text(
                            'No tags yet. Tap + New to create one.',
                            style: AppTextTheme.body3.copyWith(
                              color: AppColors.grey500,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        itemCount: _allTags.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 0.5,
                          color: AppColors.grey200,
                        ),
                        itemBuilder: (context, i) {
                          final tag = _allTags[i];
                          final selected = _isSelected(tag);
                          return InkWell(
                            onTap: () => _toggle(tag),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 1.8.h),
                              child: Row(
                                children: [
                                  Text(
                                    '#  ',
                                    style: AppTextTheme.body2.copyWith(
                                      color: AppColors.grey400,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      tag,
                                      style: AppTextTheme.body2.copyWith(
                                        color: AppColors.textBlack,
                                      ),
                                    ),
                                  ),
                                  if (selected)
                                    Icon(
                                      Icons.check_rounded,
                                      size: 20.sp,
                                      color: AppColors.primary,
                                    )
                                  else
                                    SizedBox(width: 20.sp),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            SizedBox(height: 1.5.h),
            Padding(
              padding: EdgeInsets.fromLTRB(
                5.w,
                0,
                5.w,
                keyboardOpen ? 12 : mq.padding.bottom + 16,
              ),
              child: GestureDetector(
                onTap: () => Get.back(result: _selected.toList()),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Save',
                      style: AppTextTheme.body2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
