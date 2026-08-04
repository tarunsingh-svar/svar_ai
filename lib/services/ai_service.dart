import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../core/helpers/api_helper.dart';
import '../core/helpers/transcription_preferences.dart';

class AIService {
  /// [apiHelper] and the durations are injectable so the transcription polling
  /// loop can be tested without a network or a three-minute wall-clock wait.
  /// Callers in the app use the defaults.
  AIService({
    ApiHelper? apiHelper,
    this.pollInterval = const Duration(seconds: 2),
    this.uploadRetryBackoff = const Duration(seconds: 2),
    this.transcribeTimeout = const Duration(minutes: 3),
  }) : _apiHelper = apiHelper ?? ApiHelper();

  final ApiHelper _apiHelper;

  /// Gap between job-status polls.
  final Duration pollInterval;

  /// Base delay before retrying a failed upload; multiplied by the attempt.
  final Duration uploadRetryBackoff;

  /// How long to keep polling before giving up on a job.
  final Duration transcribeTimeout;

  String? _readField(dynamic data, String key) {
    if (data == null) return null;
    if (data is Map) return data[key]?.toString();
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) return decoded[key]?.toString();
      } catch (_) {}
    }
    return null;
  }

  String? _extractSummary(dynamic data) {
    return _readField(data, 'summary');
  }

  String? _extractTranscript(dynamic data) {
    return _readField(data, 'transcript');
  }

  static const _summarizeTimeout = Duration(seconds: 60);
  // Render free tier can take 30–90s to cold-start before accepting uploads.
  static const _uploadTimeout = Duration(seconds: 90);
  static const _maxUploadAttempts = 3;

  Future<void> _wakeTranscribeServer() async {
    try {
      await _apiHelper.sendRequest(
        endpoint: '/',
        method: 'GET',
        receiveTimeout: _uploadTimeout,
      );
    } catch (_) {}
  }

  Future<Response?> _startTranscriptionJob(FormData formData) async {
    await _wakeTranscribeServer();

    for (var attempt = 1; attempt <= _maxUploadAttempts; attempt++) {
      final res = await _apiHelper.sendRequest(
        endpoint: "/transcribe",
        method: "POST",
        data: formData,
        receiveTimeout: _uploadTimeout,
      );

      final statusCode = res?.statusCode;
      if (statusCode == 202 || statusCode == 200) {
        return res;
      }

      if (attempt < _maxUploadAttempts) {
        await Future.delayed(uploadRetryBackoff * attempt);
        await _wakeTranscribeServer();
      }
    }

    return null;
  }

  Future<String?> summariseText(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    Response? res = await _apiHelper.sendRequest(
      endpoint: "/summarize",
      method: "POST",
      data: {"text": trimmed},
      receiveTimeout: _summarizeTimeout,
    );
    return _extractSummary(res?.data);
  }

  Future<String?> transcribeAudio(File audioFile) async {
    // The server routes to a transcription provider from these two fields: an
    // explicit language decides outright, the locale breaks the tie on auto.
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(audioFile.path),
      "language": TranscriptionPreferences.languageCode,
      "locale": TranscriptionPreferences.deviceLocale,
    });

    final res = await _startTranscriptionJob(formData);

    final data = res?.data;

    // Legacy sync server response.
    final syncTranscript = _extractTranscript(data);
    if (syncTranscript != null && syncTranscript.isNotEmpty) {
      return syncTranscript;
    }

    final jobId = _readField(data, 'job_id');
    if (jobId == null) {
      return _readField(data, 'error');
    }

    return _pollTranscriptionJob(jobId);
  }

  Future<String?> _pollTranscriptionJob(String jobId) async {
    final deadline = DateTime.now().add(transcribeTimeout);

    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(pollInterval);

      final res = await _apiHelper.sendRequest(
        endpoint: "/transcribe/status/$jobId",
        method: "GET",
        receiveTimeout: const Duration(seconds: 15),
      );

      if (res?.statusCode == 404) {
        return 'Transcription job not found';
      }

      final status = _readField(res?.data, 'status');

      if (status == 'complete') {
        return _readField(res?.data, 'transcript');
      }
      if (status == 'failed') {
        return _readField(res?.data, 'error') ?? 'Transcription failed';
      }
    }

    return null;
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
    return _readField(res?.data, 'result');
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
