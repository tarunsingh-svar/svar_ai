import 'package:get/get.dart';
import 'dart:io';
import '../../services/ai_service.dart';

class AIController extends GetxController {
  final AIService _service = AIService();

  var isLoading = false.obs;

  // Observables for UI
  var summaryText = "".obs;
  var transcriptText = "".obs;
  // var generatedText = "".obs;

  // ✅ Summarize text or latest transcript
  Future<void> getSummary({String? text}) async {
    try {
      isLoading.value = true;
      final result = await _service.summariseText(
        text ?? transcriptText.value.trim(),
      );
      summaryText.value = result ?? "No summary found";
    } catch (e) {
      summaryText.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Transcribe Audio
  Future<void> transcribeAudio(File audioFile) async {
    try {
      isLoading.value = true;
      transcriptText.value = "";
      summaryText.value = "";
      transcriptText.value = "";
      final transcript = await _service.transcribeAudio(audioFile);
      transcriptText.value = transcript ?? "No transcript found";
      getSummary();
    } catch (e) {
      transcriptText.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  // ===============================
  // ✅ Post / Content Generators
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

  Future<void> generateMeetingNotes({String? text}) async {
    await _generateContent(
      () => _service.createMeetingNotes(text ?? transcriptText.value),
    );
  }

  Future<void> generateJournal({String? text}) async {
    await _generateContent(
      () => _service.createJournal(text ?? transcriptText.value),
    );
  }

  // ✅ Reusable internal method
  Future<void> _generateContent(Future<String?> Function() apiCall) async {
    try {
      isLoading.value = true;
      final result = await apiCall();
      summaryText.value = result ?? "No content generated";
    } catch (e) {
      summaryText.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
