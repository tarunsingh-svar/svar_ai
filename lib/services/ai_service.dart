import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../core/debug_agent_log.dart';
import '../core/helpers/api_helper.dart';

class AIService {
  final ApiHelper _apiHelper = ApiHelper();

  String? _extractSummary(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      final summary = data['summary'];
      return summary?.toString();
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) return decoded['summary']?.toString();
      } catch (_) {
        return data.startsWith('<') ? null : data;
      }
    }
    return null;
  }

  Future<String?> summariseText(String input) async {
    // #region agent log
    agentDebugLog(
      location: 'ai_service.dart:summariseText:entry',
      message: 'summarize request',
      hypothesisId: 'A',
      data: {'textLength': input.length, 'method': 'POST'},
    );
    // #endregion
    Response? res = await _apiHelper.sendRequest(
      endpoint: "/summarize",
      method: "POST",
      data: {"text": input},
    );
    final raw = res?.data;
    // #region agent log
    agentDebugLog(
      location: 'ai_service.dart:summariseText:response',
      message: 'summarize response received',
      hypothesisId: 'A,B',
      data: {
        'statusCode': res?.statusCode,
        'dataType': raw?.runtimeType.toString(),
        'dataPreview': raw is String
            ? raw.substring(0, raw.length.clamp(0, 80))
            : (raw is Map ? 'Map' : null),
      },
    );
    // #endregion
    return _extractSummary(raw);
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
