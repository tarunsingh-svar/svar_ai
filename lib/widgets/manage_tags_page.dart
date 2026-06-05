import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_colors.dart';
import 'package:svar_ai/core/theme/text_styles.dart';
import 'package:svar_ai/modules/ai/transcribe_controller.dart';
import 'package:svar_ai/widgets/create_tag_sheet.dart';
import 'package:svar_ai/widgets/tag_picker_sheet.dart';

class ManageTagsPage extends StatefulWidget {
  const ManageTagsPage({super.key, required this.initialTags});

  final List<String> initialTags;

  @override
  State<ManageTagsPage> createState() => _ManageTagsPageState();
}

class _ManageTagsPageState extends State<ManageTagsPage> {
  late List<String> _allTags;
  late Set<String> _initialSelected;
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    final tc = Get.find<TranscribeController>();
    _allTags = getAllExistingTags(tc.allUsersTranscribe);
    _initialSelected = {
      for (final t in widget.initialTags)
        if (t.trim().isNotEmpty) t.trim(),
    };
    _selected = Set<String>.from(_initialSelected);
  }

  bool get _hasChanges => !_setsEqual(_initialSelected, _selected);

  bool _isSelected(String tag) =>
      _selected.any((t) => t.toLowerCase() == tag.toLowerCase());

  void _toggle(String tag) => setState(() {
        if (_isSelected(tag)) {
          _selected.removeWhere((t) => t.toLowerCase() == tag.toLowerCase());
        } else {
          _selected.add(tag);
        }
      });

  Future<void> _openCreateTag() async {
    final created = await showCreateTagSheet();
    if (created == null || created.isEmpty) return;

    setState(() {
      if (!_allTags.any((t) => t.toLowerCase() == created.toLowerCase())) {
        _allTags = [..._allTags, created]
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      }
      _selected.add(created);
    });
  }

  void _save() {
    if (!_hasChanges) return;
    Get.back(result: _selected.toList());
  }

  @override
  Widget build(BuildContext context) {
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
                        'Manage Tags',
                        style: AppTextTheme.body1Medium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _openCreateTag,
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 18.sp, color: AppColors.primary),
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
            Expanded(child: _buildTagList()),
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
              child: _SaveButton(
                isActive: _hasChanges,
                onTap: _hasChanges ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagList() {
    if (_allTags.isEmpty) {
      return Center(
        child: Text(
          'No tags yet. Tap + New to create one.',
          style: AppTextTheme.body3.copyWith(color: AppColors.grey500),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      itemCount: _allTags.length,
      separatorBuilder: (_, __) =>
          Divider(height: 0.5, color: AppColors.grey200),
      itemBuilder: (context, i) {
        final tag = _allTags[i];
        final selected = _isSelected(tag);
        return InkWell(
          onTap: () => _toggle(tag),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Row(
              children: [
                Text(
                  '#  ',
                  style: AppTextTheme.body2.copyWith(
                    color: AppColors.grey500,
                    fontWeight: FontWeight.w500,
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
                    size: 22.sp,
                    color: AppColors.primary,
                  )
                else
                  SizedBox(width: 22.sp),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isActive, this.onTap});

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
            'Save',
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

bool _setsEqual(Set<String> a, Set<String> b) {
  final aNorm = a.map((e) => e.toLowerCase()).toSet();
  final bNorm = b.map((e) => e.toLowerCase()).toSet();
  return aNorm.length == bNorm.length && aNorm.containsAll(bNorm);
}
