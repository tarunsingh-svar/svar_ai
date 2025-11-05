import 'package:get/get.dart';
import 'dart:io';
import '../../services/ai_service.dart';

class AIController extends GetxController {
  final AIService _service = AIService();

  var isLoading = false.obs;

  var generatedText = "".obs;
  var transcriptText = "".obs;
  var headingText = "Summary".obs;

  // ===============================
  // ✅ Core Features
  // ===============================

  Future<void> getSummary({String? text}) async {
    headingText.value = "Summary";
    await _generateContent(
      () => _service.summariseText(text ?? transcriptText.value.trim()),
    );
  }

  Future<String?> transcribeAudio(File audioFile) async {
    try {
      isLoading.value = true;
      transcriptText.value = "";
      generatedText.value = "";
      final transcript = await _service.transcribeAudio(audioFile);
      transcriptText.value = transcript ?? "No transcript found";
      getSummary();
      return transcript ?? "No transcript found";
    } catch (e) {
      transcriptText.value = "Error: $e";
      return "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  // ===============================
  // ✅ Core Productivity
  // ===============================

  Future<void> generateQuickList({String? text}) async {
    headingText.value = "Quick List";
    await _generateContent(
      () => _service.createQuickList(text ?? transcriptText.value),
    );
  }

  Future<void> generateMeetingNotes({String? text}) async {
    headingText.value = "Meeting Notes";
    await _generateContent(
      () => _service.createMeetingNotes(text ?? transcriptText.value),
    );
  }

  Future<void> generateTodoList({String? text}) async {
    headingText.value = "To-Do List";
    await _generateContent(
      () => _service.createTodoList(text ?? transcriptText.value),
    );
  }

  // ===============================
  // ✅ Work Meetings & Collaboration
  // ===============================

  Future<void> generateDailyStandup({String? text}) async {
    headingText.value = "Daily Standup";
    await _generateContent(
      () => _service.createDailyStandup(text ?? transcriptText.value),
    );
  }

  Future<void> generateFeatureDiscussion({String? text}) async {
    headingText.value = "Feature Discussion";
    await _generateContent(
      () => _service.createFeatureDiscussion(text ?? transcriptText.value),
    );
  }

  Future<void> generateInterviewSummary({String? text}) async {
    headingText.value = "Interview Summary";
    await _generateContent(
      () => _service.createInterviewSummary(text ?? transcriptText.value),
    );
  }

  Future<void> generateDelegationNote({String? text}) async {
    headingText.value = "Delegation Note";
    await _generateContent(
      () => _service.createDelegationNote(text ?? transcriptText.value),
    );
  }

  // ===============================
  // ✅ Professional Writing
  // ===============================

  Future<void> generateEmailCasual({String? text}) async {
    headingText.value = "Casual Email";
    await _generateContent(
      () => _service.createEmailCasual(text ?? transcriptText.value),
    );
  }

  Future<void> generateEmailFormal({String? text}) async {
    headingText.value = "Formal Email";
    await _generateContent(
      () => _service.createEmailFormal(text ?? transcriptText.value),
    );
  }

  // ===============================
  // ✅ Creator
  // ===============================

  Future<void> generateXPost({String? text}) async {
    headingText.value = "X Post";
    await _generateContent(
      () => _service.createXPost(text ?? transcriptText.value),
    );
  }

  Future<void> generateXThread({String? text}) async {
    headingText.value = "X Thread";
    await _generateContent(
      () => _service.createXThread(text ?? transcriptText.value),
    );
  }

  Future<void> generateFacebookPost({String? text}) async {
    headingText.value = "Facebook Post";
    await _generateContent(
      () => _service.createFacebookPost(text ?? transcriptText.value),
    );
  }

  Future<void> generateLinkedInPost({String? text}) async {
    headingText.value = "LinkedIn Post";
    await _generateContent(
      () => _service.createLinkedInPost(text ?? transcriptText.value),
    );
  }

  Future<void> generateShortVideoScript({String? text}) async {
    headingText.value = "Short Video Script";
    await _generateContent(
      () => _service.createShortVideoScript(text ?? transcriptText.value),
    );
  }

  Future<void> generateContentOutline({String? text}) async {
    headingText.value = "Content Outline";
    await _generateContent(
      () => _service.createContentOutline(text ?? transcriptText.value),
    );
  }

  // ===============================
  // ✅ Learning & Research
  // ===============================

  Future<void> generateLectureSummary({String? text}) async {
    headingText.value = "Lecture Summary";
    await _generateContent(
      () => _service.createLectureSummary(text ?? transcriptText.value),
    );
  }

  // ===============================
  // ✅ Journaling
  // ===============================

  Future<void> generateJournal({String? text}) async {
    headingText.value = "Journal";
    await _generateContent(
      () => _service.createJournal(text ?? transcriptText.value),
    );
  }

  // ===============================
  // ✅ Internal
  // ===============================

  Future<void> _generateContent(Future<String?> Function() call) async {
    try {
      isLoading.value = true;
      generatedText.value = "";
      final result = await call();
      generatedText.value = result ?? "No content generated";
    } catch (e) {
      generatedText.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
