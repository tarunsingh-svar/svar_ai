import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_colors.dart';
import 'package:svar_ai/core/helpers/note_formatters.dart';
import 'package:svar_ai/core/theme/text_styles.dart';
import 'package:svar_ai/modules/ai/transcribe_controller.dart';
import 'package:svar_ai/modules/subscription/paywall.dart';
import 'package:svar_ai/modules/subscription/subscription_controller.dart';
import 'package:svar_ai/widgets/tag_input_row.dart';
import 'package:svar_ai/widgets/white_card.dart';

class CreateNotePage extends StatefulWidget {
  const CreateNotePage({super.key});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _tags = <Map<String, dynamic>>[].obs;
  final _createdAt = DateTime.now();
  final _transcribeController = Get.find<TranscribeController>();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _hasContent =>
      _titleController.text.trim().isNotEmpty ||
      _noteController.text.trim().isNotEmpty ||
      _tags.isNotEmpty;

  List<String> get _selectedTags =>
      _tags.map((tag) => tag['text'] as String).toList();

  Future<void> _saveNote() async {
    if (_isSaving) return;

    if (!_hasContent) {
      Get.snackbar(
        'Nothing to save',
        'Add a title or some note content first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!Get.find<SubscriptionController>().canCreateNote) {
      showPaywall(
        reason:
            "You've reached the free limit of 10 notes. Upgrade to Pro for unlimited notes.",
      );
      return;
    }

    setState(() => _isSaving = true);
    EasyLoading.show(status: 'Saving note...');

    final noteId = await _transcribeController.addManualNote(
      title: _titleController.text,
      body: _noteController.text,
      tags: _selectedTags,
    );

    EasyLoading.dismiss();
    if (!mounted) return;

    setState(() => _isSaving = false);

    if (noteId == null) {
      Get.snackbar(
        'Save failed',
        'Could not save your note. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.back();
    Get.snackbar(
      'Note saved',
      'Your note was saved successfully.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _discardNote() {
    if (!_hasContent) {
      Get.back();
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Discard note?',
          style: AppTextTheme.body1Medium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        content: Text(
          'Your changes will be lost if you leave without saving.',
          style: AppTextTheme.body2.copyWith(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Keep editing',
              style: AppTextTheme.body2.copyWith(color: AppColors.grey600),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: Text(
              'Discard',
              style: AppTextTheme.body2.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasContent,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _discardNote();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 3.h),
                TextField(
                  controller: _titleController,
                  style: AppTextTheme.h4.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Note Title',
                    hintStyle: AppTextTheme.body2.copyWith(
                      color: AppColors.grey500,
                    ),
                    border: InputBorder.none,
                  ),
                ),
                SizedBox(height: 0.7.h),
                Text(
                  formatNoteDate(_createdAt),
                  style: AppTextTheme.body3.copyWith(
                    color: AppColors.textBlack,
                  ),
                ),
                SizedBox(height: 1.7.h),
                TagInputRow(tags: _tags),
                SizedBox(height: 2.h),
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: AppTextTheme.body2.copyWith(
                      color: AppColors.textBlack,
                      fontSize: 15.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Write your note here...',
                      hintStyle: AppTextTheme.body2.copyWith(
                        color: AppColors.grey500,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: CreateNoteBottomBar(
          isSaving: _isSaving,
          onDiscard: _discardNote,
          onSave: _saveNote,
        ),
      ),
    );
  }
}

class CreateNoteBottomBar extends StatelessWidget {
  const CreateNoteBottomBar({
    super.key,
    required this.onDiscard,
    required this.onSave,
    required this.isSaving,
  });

  final VoidCallback onDiscard;
  final VoidCallback onSave;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      height: 9.h,
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: isSaving ? null : onDiscard,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 5.5.h,
              width: 5.5.h,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey400, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 22.sp,
                color: AppColors.grey600,
              ),
            ),
          ),
          InkWell(
            onTap: isSaving ? null : onSave,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.4.h),
              decoration: BoxDecoration(
                color: isSaving ? AppColors.grey400 : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    isSaving ? 'Saving...' : 'Save note',
                    style: AppTextTheme.body2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
