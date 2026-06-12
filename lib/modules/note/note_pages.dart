import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:svar_ai/core/helpers/audio_download_helper.dart';
import 'package:svar_ai/core/helpers/note_copy_helper.dart';
import 'package:svar_ai/core/routing/app_routes.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../widgets/white_card.dart';
import '../../widgets/custom_bottom_sheet.dart';
import '../../widgets/tag_card.dart';
import '../subscription/paywall.dart';
import '../subscription/subscription_controller.dart';
import '../ai/ai_controller.dart';
import '../ai/transcribe_controller.dart';
import 'widgets/rewrite_bottom_sheet.dart';

class NotePage extends StatelessWidget {
  NotePage({super.key});

  final RxInt selectedTab = 0.obs; // 0: Structured Notes, 1: Transcript

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back icon
              SizedBox(height: 3.h),
              InkWell(
                onTap: () => Get.back(),
                child: Icon(
                  Icons.arrow_back,
                  size: 20.sp,
                  color: AppColors.textBlack,
                ),
              ),
              SizedBox(height: 3.h),

              // Tabs
              Obx(() {
                if (selectedTab.value.isEven) {}
                return Row(
                  children: [
                    _buildTab("Structured Notes", 0),
                    _buildTab("Transcript", 1),
                  ],
                );
              }),

              // ✅ Wrap scrollable content in Expanded
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3.h),

                      // SizedBox(height: 3.h),

                      // Title
                      Text(
                        "Tavastra Round 1 Discussion",
                        style: AppTextTheme.h4.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                      SizedBox(height: 0.7.h),

                      // Date and Time
                      Text(
                        "August 5, 2025  6:45 PM",
                        style: AppTextTheme.body3.copyWith(
                          color: AppColors.textBlack,
                        ),
                      ),
                      SizedBox(height: 1.7.h),

                      //category tag
                      Row(
                        children: [
                          TagCard(text: "All", color: AppColors.cardYellow),
                          SizedBox(width: 2.w),
                          // TagCard(text: "Office", color: AppColors.cardGreen),
                          // SizedBox(width: 2.w),
                          // TagCard(
                          //   text: "Kalpataru",
                          //   color: AppColors.cardPurple,
                          // ),
                          // SizedBox(width: 2.w),
                          InkWell(
                            onTap: () {
                              // add new tag
                            },
                            borderRadius: BorderRadius.circular(8.sp),
                            child: Container(
                              height: 3.8.h,
                              width: 3.8.h,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.grey400,
                                  width: 1,
                                ),
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
                      SizedBox(height: 2.8.h),

                      // Summary section
                      Text(
                        "Summary",
                        style: AppTextTheme.body1Medium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                      SizedBox(height: 1.2.h),
                      Text(
                        "Hi this is a demo summary for the initial testing of the Svar AI. Other note taking AI platform are currently being evaluated, focusing on its overall capabilities and functionality for audio recording.\n\nEngineers provided context that technical inspections are typically conducted entirely in English.",
                        style: AppTextTheme.body2.copyWith(
                          color: AppColors.textBlack,
                          fontSize: 15.sp,
                        ),
                      ),
                      SizedBox(height: 3.h),

                      // Action Items
                      Text(
                        "Action Items",
                        style: AppTextTheme.body1Medium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      _buildBulletPoint(
                        "Ongoing assessment of audio recording quality is crucial to determining the platform’s effectiveness.",
                      ),
                      _buildBulletPoint(
                        "What specifically you worked in design, umm… not design leave that Tell me what worked you did on distribution.",
                      ),
                      _buildBulletPoint(
                        "Yeah, sure! I worked on researching the twitter accounts.",
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const BottomFloatingButtons(),
    );
  }

  // Tab builder
  Widget _buildTab(String title, int index) {
    return Obx(
      () => GestureDetector(
        onTap: () => selectedTab.value = index,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 0.5.h),
            Text(
              title,
              style: AppTextTheme.body1Medium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
                // : AppColors.grey500,
              ),
            ),
            SizedBox(height: 1.2.h),
            Container(
              height: 0.1.h,
              width: 45.w,
              decoration: BoxDecoration(
                color: selectedTab.value == index
                    ? AppColors.lightGrey
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(5.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // bullet point widget
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("  •   "),
          Expanded(
            child: Text(
              text,
              style: AppTextTheme.body2.copyWith(
                color: AppColors.textBlack,
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔘 Bottom buttons
class BottomFloatingButtons extends StatelessWidget {
  const BottomFloatingButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      height: 9.h,
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => RewriteBottomSheet(),
              );
            },
            child: Image.asset(AppAssets.spark, width: 12.w),
          ),
          InkWell(
            onTap: _showCopyTextSheet,
            child: Image.asset(AppAssets.note, width: 12.w),
          ),
          InkWell(
            onTap: _showRecordingOptionsSheet,
            child: Image.asset(AppAssets.plus, width: 12.w),
          ),
          // 4th: Share — opens PDF sharing options
          InkWell(
            onTap: () => _showPdfShareSheet(),
            child: Image.asset(AppAssets.share, width: 12.w),
          ),

          // 5th: Three-dot — Download audio + Delete note
          InkWell(
            onTap: () => _showMoreOptionsSheet(),
            child: Image.asset(AppAssets.threeDots, height: 4.h),
          ),
        ],
      ),
    );
  }

  /// 3rd button (+): continue recording or start a new note
  void _showRecordingOptionsSheet() {
    final transcribeController = Get.isRegistered<TranscribeController>()
        ? Get.find<TranscribeController>()
        : null;

    showCustomBottomSheet(
      children: [
        InkWell(
          onTap: () {
            Get.back();
            if (transcribeController == null ||
                transcribeController.thisNoteId.value == 0) {
              Get.snackbar(
                'Note unavailable',
                'Open a saved note before continuing a recording.',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
            transcribeController.prepareContinueRecordingSession();
            Get.toNamed(AppRoutes.recordPage);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: 2.2.h,
              horizontal: 4.w,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.mic,
                      color: AppColors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      "Continue in Existing Note",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        InkWell(
          onTap: () {
            Get.back();
            final sub = Get.find<SubscriptionController>();
            if (!sub.canCreateNote) {
              showPaywall(
                reason:
                    "You've reached the free limit of 10 notes. Upgrade to Pro for unlimited notes.",
              );
              return;
            }
            transcribeController?.prepareNewRecordingSession(
              replaceCurrentNotePage: true,
            );
            Get.toNamed(AppRoutes.recordPage);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: 2.2.h,
              horizontal: 4.w,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.surface.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.mic,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      "Start a new recording",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textBlack,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: AppColors.grey600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 2nd button: copy note text options
  void _showCopyTextSheet() {
    showCustomBottomSheet(
      topRadius: 22,
      backgroundColor: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      children: [
        _sheetButton(
          label: 'Copy Summary',
          icon: Icons.summarize_outlined,
          isPrimary: true,
          onTap: () {
            copyTextToClipboard(
              buildRecordingNoteCopyText(
                includeTitle: true,
                includeSummary: true,
              ),
            );
          },
        ),
        SizedBox(height: 1.5.h),
        _sheetButton(
          label: 'Copy Transcript',
          icon: Icons.description_outlined,
          isPrimary: false,
          onTap: () {
            copyTextToClipboard(
              buildRecordingNoteCopyText(
                includeTitle: true,
                includeTranscript: true,
              ),
            );
          },
        ),
        SizedBox(height: 1.5.h),
        _sheetButton(
          label: 'Copy Full Note',
          icon: Icons.content_copy_outlined,
          isPrimary: false,
          onTap: () {
            copyTextToClipboard(
              buildRecordingNoteCopyText(
                includeTitle: true,
                includeSummary: true,
                includeTranscript: true,
              ),
            );
          },
        ),
      ],
    );
  }

  /// 4th button: Share PDF of transcript or summary
  void _showPdfShareSheet() {
    showCustomBottomSheet(
      topRadius: 22,
      backgroundColor: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      children: [
        _sheetButton(
          label: "Share PDF of Transcript",
          icon: Icons.description_outlined,
          isPrimary: true,
          onTap: () {
            Get.back();
            _generateAndSharePdf(isTranscript: true);
          },
        ),
        SizedBox(height: 1.5.h),
        _sheetButton(
          label: "Share PDF of Summary",
          icon: Icons.summarize_outlined,
          isPrimary: false,
          onTap: () {
            Get.back();
            _generateAndSharePdf(isTranscript: false);
          },
        ),
      ],
    );
  }

  Future<void> _generateAndSharePdf({required bool isTranscript}) async {
    final ai = Get.isRegistered<AIController>() ? Get.find<AIController>() : null;
    final tc = Get.isRegistered<TranscribeController>()
        ? Get.find<TranscribeController>()
        : null;

    final title = ai?.headingText.value ?? 'Note';
    final body = isTranscript
        ? (ai?.transcriptText.value ?? '')
        : (ai?.generatedText.value ?? '');
    final label = isTranscript ? 'Transcript' : 'Summary';
    final dateText = tc?.currentNote != null
        ? _formatDate(tc!.currentNote!.createdAt)
        : _formatDate(DateTime.now());

    if (body.trim().isEmpty) {
      Get.snackbar(
        "$label unavailable",
        "There is no $label content to share yet.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context ctx) => [
            // Header
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              '$dateText   •   $label',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
            ),
            pw.Divider(height: 24, color: PdfColors.grey400),
            // Body text — preserve line breaks
            ...body.split('\n').map(
              (line) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text(
                  line,
                  style: const pw.TextStyle(fontSize: 12, lineSpacing: 4),
                ),
              ),
            ),
          ],
        ),
      );

      final dir = await getTemporaryDirectory();
      final safeName = title.replaceAll(RegExp(r'[^a-zA-Z0-9_\- ]'), '').trim();
      final fileName = '${safeName}_$label.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '$title — $label',
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to generate PDF. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  /// 5th button (three-dot): Download audio + Delete note
  Future<void> _showMoreOptionsSheet() async {
    final transcribeController = Get.isRegistered<TranscribeController>()
        ? Get.find<TranscribeController>()
        : null;

    if (transcribeController != null) {
      await transcribeController.restoreAudioPathForCurrentNote();
    }

    final canDownload = transcribeController?.canDownloadAudio ?? false;

    showCustomBottomSheet(
      topRadius: 22,
      backgroundColor: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      children: [
        if (canDownload) ...[
          _sheetButton(
            label: "Download Audio",
            icon: Icons.download_outlined,
            isPrimary: true,
            onTap: () {
              Get.back();
              _downloadAudio();
            },
          ),
          SizedBox(height: 1.5.h),
        ],
        _sheetButton(
          label: "Delete Note",
          icon: Icons.delete_outline_rounded,
          isPrimary: false,
          isDestructive: true,
          onTap: () {
            Get.back();
            _confirmDeleteNote();
          },
        ),
      ],
    );
  }

  Future<void> _downloadAudio() async {
    final transcribeController = Get.isRegistered<TranscribeController>()
        ? Get.find<TranscribeController>()
        : null;

    if (transcribeController != null) {
      await transcribeController.restoreAudioPathForCurrentNote();
    }

    final audioPath = transcribeController?.currentAudioPath.value ?? '';

    if (audioPath.isEmpty || !File(audioPath).existsSync()) {
      Get.snackbar(
        "Audio unavailable",
        "The audio file for this recording could not be found.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final ai = Get.isRegistered<AIController>() ? Get.find<AIController>() : null;
    final title = ai?.headingText.value ?? 'Recording';

    try {
      final result = await AudioDownloadHelper.downloadAudio(
        sourcePath: audioPath,
        suggestedName: title,
      );

      if (result.success) {
        Get.snackbar(
          'Download complete',
          result.message ?? 'Audio saved to your device.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      Get.snackbar(
        'Download failed',
        result.error ?? 'Could not save the audio file.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Download failed',
        'Could not save the audio file. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _confirmDeleteNote() {
    final transcribeController = Get.isRegistered<TranscribeController>()
        ? Get.find<TranscribeController>()
        : null;

    if (transcribeController == null) return;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Delete Note",
          style: AppTextTheme.body1Medium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack,
          ),
        ),
        content: Text(
          "Are you sure you want to delete this note? This action cannot be undone.",
          style: AppTextTheme.body2.copyWith(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: AppTextTheme.body2.copyWith(color: AppColors.grey600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final noteId = transcribeController.thisNoteId.value;
              if (noteId != 0) {
                await transcribeController.deleteTranscribe(noteId);
                transcribeController.currentAudioPath.value = '';
              }
              Get.until((route) => route.isFirst);
            },
            child: Text(
              "Delete",
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

  /// Reusable bottom-sheet row button
  Widget _sheetButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final bgColor = isPrimary ? AppColors.primary : AppColors.white;
    final labelColor = isPrimary
        ? Colors.white
        : (isDestructive ? AppColors.error : AppColors.textBlack);
    final iconColor = isPrimary
        ? Colors.white
        : (isDestructive ? AppColors.error : AppColors.grey600);
    final arrowColor = isPrimary ? Colors.white : AppColors.grey600;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(
                  color: isDestructive
                      ? AppColors.error.withValues(alpha: 0.25)
                      : AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20.sp),
                SizedBox(width: 3.w),
                Text(
                  label,
                  style: AppTextTheme.body2.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: arrowColor,
            ),
          ],
        ),
      ),
    );
  }
}
