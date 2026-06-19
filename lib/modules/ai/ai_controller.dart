import 'package:get/get.dart';
import 'dart:io';
import '../../services/ai_service.dart';
import 'transcribe_controller.dart';

class AIController extends GetxController {
  final AIService _service = AIService();

  var isLoading = false.obs;
  var isSummaryLoading = false.obs;

  var generatedText = "".obs;
  var transcriptText = "".obs;
  var headingText = "Summary".obs;

  // ===============================
  // ✅ Core Features
  // ===============================

  Future<void> getSummary({String? text}) async {
    await _generateContent(
      () => _service.summariseText(text ?? transcriptText.value.trim()),
    );
  }

  Future<String?> transcribeAudio(File audioFile) async {
    await processRecordedAudio(audioFile, appendToExisting: false);
    return transcriptText.value;
  }

  Future<void> processRecordedAudio(
    File audioFile, {
    required bool appendToExisting,
  }) async {
    final existingTranscript =
        appendToExisting ? transcriptText.value.trim() : '';
    final existingSummary = appendToExisting ? generatedText.value.trim() : '';

    if (!appendToExisting) {
      transcriptText.value = '';
      generatedText.value = '';
    }

    try {
      isLoading.value = true;
      isSummaryLoading.value = true;

      final newTranscriptRaw = await _service.transcribeAudio(audioFile);
      final newTranscript = newTranscriptRaw?.trim() ?? '';

      if (newTranscript.isEmpty || newTranscript == 'No transcript found') {
        if (!appendToExisting) {
          transcriptText.value = newTranscriptRaw ?? 'No transcript found';
        }
        return;
      }

      if (newTranscript.startsWith('Error:')) {
        if (!appendToExisting) {
          transcriptText.value = newTranscript;
        }
        return;
      }

      final combinedTranscript =
          appendToExisting && existingTranscript.isNotEmpty
              ? '$existingTranscript\n\n$newTranscript'
              : newTranscript;
      transcriptText.value = combinedTranscript;

      isLoading.value = false;

      final textForSummary =
          appendToExisting ? newTranscript : combinedTranscript;
      final summaryResult =
          await _service.summariseText(textForSummary.trim());
      final newSummary = (summaryResult ?? '').trim();

      if (newSummary.isEmpty || newSummary == 'Error generating text') {
        if (!appendToExisting) {
          generatedText.value =
              'Summary could not be generated. Add OPENAI_API_KEY on the Render server.';
        }
      } else if (appendToExisting && existingSummary.isNotEmpty) {
        generatedText.value = '$existingSummary\n\n$newSummary';
      } else {
        generatedText.value = newSummary;
      }

      await _persistSummaryToDb();
    } catch (e) {
      if (!appendToExisting) {
        transcriptText.value = 'Error: $e';
      } else {
        Get.snackbar(
          'Transcription failed',
          'Could not transcribe the new recording.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
      isSummaryLoading.value = false;
    }
  }

  // ===============================
  // ✅ Core Productivity
  // ===============================

  Future<void> generateQuickList({String? text}) async {
    await _generateContent(
      () => _service.createQuickList(text ?? transcriptText.value),
    );
  }

  Future<void> generateMeetingNotes({String? text}) async {
    await _generateContent(
      () => _service.createMeetingNotes(text ?? transcriptText.value),
    );
  }

  Future<void> generateTodoList({String? text}) async {
    await _generateContent(
      () => _service.createTodoList(text ?? transcriptText.value),
    );
  }

  // ===============================
  // ✅ Work Meetings & Collaboration
  // ===============================

  Future<void> generateDailyStandup({String? text}) async {
    await _generateContent(
      () => _service.createDailyStandup(text ?? transcriptText.value),
    );
  }

  Future<void> generateFeatureDiscussion({String? text}) async {
    await _generateContent(
      () => _service.createFeatureDiscussion(text ?? transcriptText.value),
    );
  }

  Future<void> generateInterviewSummary({String? text}) async {
    await _generateContent(
      () => _service.createInterviewSummary(text ?? transcriptText.value),
    );
  }

  Future<void> generateDelegationNote({String? text}) async {
    await _generateContent(
      () => _service.createDelegationNote(text ?? transcriptText.value),
    );
  }

  // ===============================
  // ✅ Professional Writing
  // ===============================

  Future<void> generateEmailCasual({String? text}) async {
    await _generateContent(
      () => _service.createEmailCasual(text ?? transcriptText.value),
    );
  }

  Future<void> generateEmailFormal({String? text}) async {
    await _generateContent(
      () => _service.createEmailFormal(text ?? transcriptText.value),
    );
  }

  // ===============================
  // ✅ Creator
  // ===============================

  Future<void> generateXPost({String? text}) async {
    await _generateContent(
      () => _service.createXPost(text ?? transcriptText.value),
    );
  }

  Future<void> generateXThread({String? text}) async {
    await _generateContent(
      () => _service.createXThread(text ?? transcriptText.value),
    );
  }

  Future<void> generateFacebookPost({String? text}) async {
    await _generateContent(
      () => _service.createFacebookPost(text ?? transcriptText.value),
    );
  }

  Future<void> generateLinkedInPost({String? text}) async {
    await _generateContent(
      () => _service.createLinkedInPost(text ?? transcriptText.value),
    );
  }

  Future<void> generateShortVideoScript({String? text}) async {
    await _generateContent(
      () => _service.createShortVideoScript(text ?? transcriptText.value),
    );
  }

  Future<void> generateContentOutline({String? text}) async {
    await _generateContent(
      () => _service.createContentOutline(text ?? transcriptText.value),
    );
  }

  // ===============================
  // ✅ Learning & Research
  // ===============================

  Future<void> generateLectureSummary({String? text}) async {
    await _generateContent(
      () => _service.createLectureSummary(text ?? transcriptText.value),
    );
  }

  // ===============================
  // ✅ Journaling
  // ===============================

  Future<void> generateJournal({String? text}) async {
    await _generateContent(
      () => _service.createJournal(text ?? transcriptText.value),
    );
  }

  // ===============================
  // ✅ Internal
  // ===============================

  Future<void> _persistSummaryToDb({int? forNoteId}) async {
    final id = forNoteId ?? Get.find<TranscribeController>().thisNoteId.value;
    final currentId = Get.find<TranscribeController>().thisNoteId.value;
    if (id == 0 || generatedText.value.isEmpty) return;
    if (forNoteId != null && forNoteId != currentId) return;
    await Get.find<TranscribeController>()
        .updateSummaryText(id, generatedText.value);
  }

  Future<void> _generateContent(Future<String?> Function() call) async {
    final tc = Get.find<TranscribeController>();
    final startNoteId = tc.thisNoteId.value;
    try {
      isSummaryLoading.value = true;
      final result = await call();
      final endNoteId = tc.thisNoteId.value;
      if (startNoteId != endNoteId) {
        final text = result ?? '';
        if (text.isNotEmpty &&
            text != 'No content generated' &&
            text != 'Error generating text') {
          await tc.updateSummaryText(startNoteId, text);
        }
        return;
      }
      final text = result ?? "No content generated";
      if (text == "Error generating text") {
        generatedText.value =
            "Summary could not be generated. Add OPENAI_API_KEY on the Render server.";
      } else {
        generatedText.value = text;
      }
      await _persistSummaryToDb(forNoteId: startNoteId);
    } catch (e) {
      if (startNoteId == tc.thisNoteId.value) {
        generatedText.value = "Error: $e";
      }
    } finally {
      isSummaryLoading.value = false;
    }
  }
}
