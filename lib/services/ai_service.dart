import 'dart:io';
import 'package:dio/dio.dart';
import '../core/helpers/api_helper.dart';

class AIService {
  final ApiHelper _apiHelper = ApiHelper();

  Future<String?> summariseText(String input) async {
    Response? res = await _apiHelper.sendRequest(
      endpoint: "/summarize",
      query: {"text": input},
    );
    return res?.data?["summary"];
  }

  Future<String?> transcribeAudio(File audioFile) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(audioFile.path),
    });

    Response? res = await _apiHelper.sendRequest(
      endpoint: "/transcribe",
      method: "POST",
      data: formData,
    );

    return res?.data?["transcript"];
  }

  // ========================
  // ✅ Content Generation
  // ========================

  Future<String?> _post(String endpoint, String text) async {
    Response? res = await _apiHelper.sendRequest(
      endpoint: endpoint,
      method: "POST",
      data: {"text": text},
    );
    return res?.data?["result"];
  }

  // Creator / Social
  Future<String?> createXPost(String text) => _post("/generate_x_post", text);
  Future<String?> createXThread(String text) =>
      _post("/generate_x_thread", text);
  Future<String?> createFacebookPost(String text) =>
      _post("/generate_facebook_post", text);
  Future<String?> createLinkedInPost(String text) =>
      _post("/generate_linkedin_post", text);
  Future<String?> createShortVideoScript(String text) =>
      _post("/generate_video_script", text);
  Future<String?> createContentOutline(String text) =>
      _post("/generate_content_outline", text);

  // Productivity
  Future<String?> createMeetingNotes(String text) =>
      _post("/generate_meeting_notes", text);
  Future<String?> createQuickList(String text) =>
      _post("/generate_quick_list", text);
  Future<String?> createTodoList(String text) =>
      _post("/generate_todo_list", text);

  // Collaboration
  Future<String?> createDailyStandup(String text) =>
      _post("/generate_daily_standup", text);
  Future<String?> createFeatureDiscussion(String text) =>
      _post("/generate_feature_discussion", text);
  Future<String?> createInterviewSummary(String text) =>
      _post("/generate_interview_summary", text);
  Future<String?> createDelegationNote(String text) =>
      _post("/generate_delegation_note", text);

  // Emails
  Future<String?> createEmailCasual(String text) =>
      _post("/generate_email_casual", text);
  Future<String?> createEmailFormal(String text) =>
      _post("/generate_email_formal", text);

  // Learning
  Future<String?> createLectureSummary(String text) =>
      _post("/generate_lecture_summary", text);

  // Journaling
  Future<String?> createJournal(String text) =>
      _post("/generate_journal", text);
}
