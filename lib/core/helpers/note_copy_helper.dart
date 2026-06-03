import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:svar_ai/modules/ai/ai_controller.dart';
Future<void> copyTextToClipboard(String text) async {
  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    Get.snackbar(
      'Nothing to copy',
      'There is no text to copy for this note.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  await Clipboard.setData(ClipboardData(text: trimmed));
  if (Get.isBottomSheetOpen ?? false) Get.back();
  Get.snackbar(
    'Copied',
    'Note text copied to clipboard.',
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 2),
  );
}

String buildRecordingNoteCopyText({
  bool includeTitle = true,
  bool includeSummary = false,
  bool includeTranscript = false,
}) {
  if (!Get.isRegistered<AIController>()) return '';

  final ai = Get.find<AIController>();
  final parts = <String>[];

  if (includeTitle) {
    final title = ai.headingText.value.trim();
    if (title.isNotEmpty) parts.add(title);
  }

  if (includeSummary) {
    final summary = ai.generatedText.value.trim();
    if (summary.isNotEmpty) {
      parts.add(parts.isEmpty ? summary : 'Summary\n$summary');
    }
  }

  if (includeTranscript) {
    final transcript = ai.transcriptText.value.trim();
    if (transcript.isNotEmpty) {
      parts.add(parts.isEmpty ? transcript : 'Transcript\n$transcript');
    }
  }

  return parts.join('\n\n');
}

String buildManualNoteCopyText({
  required String title,
  required String body,
}) {
  final parts = <String>[];
  final trimmedTitle = title.trim();
  final trimmedBody = body.trim();
  if (trimmedTitle.isNotEmpty) parts.add(trimmedTitle);
  if (trimmedBody.isNotEmpty) parts.add(trimmedBody);
  return parts.join('\n\n');
}
