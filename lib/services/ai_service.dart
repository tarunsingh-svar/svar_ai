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

  // ✅ New text generation features
  Future<String?> createXPost(String text) async {
    Response? res = await _apiHelper.sendRequest(
      endpoint: "/generate_x_post",
      method: "POST",
      data: {"text": text},
    );
    return res?.data?["result"];
  }

  Future<String?> createXThread(String text) async {
    Response? res = await _apiHelper.sendRequest(
      endpoint: "/generate_x_thread",
      method: "POST",
      data: {"text": text},
    );
    return res?.data?["result"];
  }

  Future<String?> createFacebookPost(String text) async {
    Response? res = await _apiHelper.sendRequest(
      endpoint: "/generate_facebook_post",
      method: "POST",
      data: {"text": text},
    );
    return res?.data?["result"];
  }

  Future<String?> createLinkedInPost(String text) async {
    Response? res = await _apiHelper.sendRequest(
      endpoint: "/generate_linkedin_post",
      method: "POST",
      data: {"text": text},
    );
    return res?.data?["result"];
  }

  Future<String?> createMeetingNotes(String text) async {
    Response? res = await _apiHelper.sendRequest(
      endpoint: "/generate_meeting_notes",
      method: "POST",
      data: {"text": text},
    );
    return res?.data?["result"];
  }

  Future<String?> createJournal(String text) async {
    Response? res = await _apiHelper.sendRequest(
      endpoint: "/generate_journal",
      method: "POST",
      data: {"text": text},
    );
    return res?.data?["result"];
  }
}
