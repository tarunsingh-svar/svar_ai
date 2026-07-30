import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/helpers/api_helper.dart';
import '../../data/models/transcribe_model.dart';
import '../subscription/paywall.dart';
import '../subscription/subscription_controller.dart';

enum RecordingSessionMode { newNote, continueNote }

class TranscribeController extends GetxController {
  static const _audioPathKeyPrefix = 'note_audio_path_';

  /// Bucket shared with the web app. Objects live under `<user_id>/…` so the
  /// Storage RLS policies can key off the first path segment.
  static const audioBucket = 'note-audio';

  final _supabase = Supabase.instance.client;
  final thisNoteId = 0.obs;
  final recordingDurationSeconds = 0.obs;
  final currentAudioPath = ''.obs;
  final recordingSessionMode = RecordingSessionMode.newNote.obs;
  final shouldReplaceNotePageOnFinish = false.obs;

  RxList<TranscribeModel> allUsersTranscribe = <TranscribeModel>[].obs;

  TranscribeModel? get currentNote {
    final id = thisNoteId.value;
    if (id == 0) return null;
    for (final note in allUsersTranscribe) {
      if (note.id == id) return note;
    }
    return null;
  }

  List<String> get currentTags => currentNote?.tags ?? [];

  bool get isManualNote {
    final note = currentNote;
    if (note == null) return true;
    return note.durationSeconds == 0;
  }

  bool get showTranscriptTab => !isManualNote;

  bool get hasDownloadableAudio {
    final path = currentAudioPath.value;
    return path.isNotEmpty && File(path).existsSync();
  }

  bool get canDownloadAudio => !isManualNote && hasDownloadableAudio;

  bool get isContinuingRecording =>
      recordingSessionMode.value == RecordingSessionMode.continueNote;

  void prepareNewRecordingSession({bool replaceCurrentNotePage = false}) {
    recordingSessionMode.value = RecordingSessionMode.newNote;
    shouldReplaceNotePageOnFinish.value = replaceCurrentNotePage;
  }

  void prepareContinueRecordingSession() {
    recordingSessionMode.value = thisNoteId.value == 0
        ? RecordingSessionMode.newNote
        : RecordingSessionMode.continueNote;
    shouldReplaceNotePageOnFinish.value = false;
  }

  String _audioPathKey(int noteId) => '$_audioPathKeyPrefix$noteId';

  Future<void> persistAudioPath(int noteId, String path) async {
    if (noteId == 0 || path.isEmpty) return;

    final prefs = Get.find<SharedPreferences>();
    await prefs.setString(_audioPathKey(noteId), path);
    currentAudioPath.value = path;

    // Fire and forget: the local file already backs playback on this device,
    // so a failed upload should never block finishing a recording. It only
    // costs the user cross-device playback for this note.
    unawaited(uploadAudioToCloud(noteId, path));
  }

  /// Copies a local recording into Storage and records the object path on the
  /// note, which is what makes the audio playable on the web app and on a
  /// second device.
  Future<void> uploadAudioToCloud(int noteId, String localPath) async {
    final user = _supabase.auth.currentUser;
    if (user == null || noteId == 0) return;

    final file = File(localPath);
    if (!file.existsSync()) return;

    final lastDot = localPath.lastIndexOf('.');
    final extension = lastDot == -1 ? '' : localPath.substring(lastDot + 1);
    final stamp =
        DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
    final objectPath =
        '${user.id}/$stamp-$noteId.${extension.isEmpty ? 'm4a' : extension}';

    try {
      await _supabase.storage.from(audioBucket).upload(objectPath, file);
      await _supabase
          .from('transcribe')
          .update({'audio_path': objectPath})
          .eq('id', noteId);
      logger.i('☁️ Uploaded note $noteId audio to $objectPath');
    } catch (e, s) {
      logger.i('⚠️ uploadAudioToCloud failed for note $noteId: $e\n$s');
    }
  }

  /// Removes the note's recording from Storage. Going through the Storage API
  /// (rather than letting the row cascade) is what actually reclaims the file.
  Future<void> _deleteCloudAudio(int noteId) async {
    if (noteId == 0) return;

    try {
      final row = await _supabase
          .from('transcribe')
          .select('audio_path')
          .eq('id', noteId)
          .maybeSingle();

      final objectPath = row?['audio_path'] as String?;
      if (objectPath == null || objectPath.isEmpty) return;

      await _supabase.storage.from(audioBucket).remove([objectPath]);
    } catch (e) {
      logger.i('⚠️ _deleteCloudAudio failed for note $noteId: $e');
    }
  }

  /// Signed URL for a note's cloud recording, or null when there isn't one.
  /// Used when the local file is gone — after a reinstall, or for a note that
  /// was recorded on another device.
  Future<String?> cloudAudioUrl(int noteId) async {
    if (noteId == 0) return null;

    try {
      final row = await _supabase
          .from('transcribe')
          .select('audio_path')
          .eq('id', noteId)
          .maybeSingle();

      final objectPath = row?['audio_path'] as String?;
      if (objectPath == null || objectPath.isEmpty) return null;

      return await _supabase.storage
          .from(audioBucket)
          .createSignedUrl(objectPath, 60 * 60);
    } catch (e) {
      logger.i('⚠️ cloudAudioUrl failed for note $noteId: $e');
      return null;
    }
  }

  Future<void> restoreAudioPathForCurrentNote() async {
    final noteId = thisNoteId.value;
    if (noteId == 0) {
      currentAudioPath.value = '';
      return;
    }

    if (isManualNote) {
      currentAudioPath.value = '';
      return;
    }

    if (hasDownloadableAudio) return;

    final prefs = Get.find<SharedPreferences>();
    final stored = prefs.getString(_audioPathKey(noteId)) ?? '';
    currentAudioPath.value =
        stored.isNotEmpty && File(stored).existsSync() ? stored : '';
  }

  Future<void> clearStoredAudioPath(int noteId) async {
    if (noteId == 0) return;

    final prefs = Get.find<SharedPreferences>();
    final stored = prefs.getString(_audioPathKey(noteId));
    await prefs.remove(_audioPathKey(noteId));

    if (stored != null && stored.isNotEmpty) {
      final file = File(stored);
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }

  /// ✅ Fetch all user transcriptions
  Future<void> fetchAllUsersTranscribes() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      logger.i("⛔ fetchAllUsersTranscribes: No user logged in");
      return;
    }

    logger.i("📌 Fetch all transcribes for user: ${user.id}");

    try {
      final res = await _supabase
          .from('transcribe')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      logger.i("✅ fetchAllUsersTranscribes Response: $res");

      allUsersTranscribe.value = res
          .map((e) => TranscribeModel.fromJson(e))
          .toList();

      logger.i("🟢 Local list updated: ${allUsersTranscribe.length} items");
    } catch (e, s) {
      logger.i("❌ fetchAllUsersTranscribes Error: $e\n$s");
    }
  }

  /// Safety net: free users are capped at the lifetime note limit. The primary
  /// gate is at the note-creation entry points (home), but this prevents
  /// creating a note if that gate is somehow bypassed. Returns false (and opens
  /// the paywall) when blocked.
  bool _ensureCanCreateNote() {
    if (!Get.isRegistered<SubscriptionController>()) return true;
    final sub = Get.find<SubscriptionController>();
    if (sub.canCreateNote) return true;
    showPaywall(
      reason:
          "You've reached the free limit of 10 notes. Upgrade to Pro for unlimited notes.",
    );
    return false;
  }

  void _bumpLocalNoteCount() {
    if (Get.isRegistered<SubscriptionController>()) {
      Get.find<SubscriptionController>().incrementLocalNoteCount();
    }
  }

  /// ✅ Create new transcribe
  Future<int?> addNewTranscribe() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      logger.i("⛔ addNewTranscribe: No user logged in");
      return null;
    }

    if (!_ensureCanCreateNote()) return null;

    logger.i("📌 Creating new transcribe row for user: ${user.id}");

    try {
      final data = await _supabase
          .from('transcribe')
          .insert({
            "user_id": user.id,
            "title": "Untitled Note",
            "transcribe_text": "",
            "summary_text": "",
            "duration_seconds": recordingDurationSeconds.value,
            "tags": [],
          })
          .select()
          .single();

      logger.i("✅ addNewTranscribe Response: $data");

      final newItem = TranscribeModel.fromJson(data);
      allUsersTranscribe.insert(0, newItem);
      thisNoteId.value = newItem.id;
      _bumpLocalNoteCount();

      logger.i("🟢 Inserted new transcribe with ID: ${newItem.id}");

      return newItem.id;
    } catch (e, s) {
      logger.i("❌ addNewTranscribe Error: $e\n$s");
      return null;
    }
  }

  /// Create a manual text note (no recording).
  Future<int?> addManualNote({
    required String title,
    required String body,
    List<String> tags = const [],
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      logger.i("⛔ addManualNote: No user logged in");
      return null;
    }

    if (!_ensureCanCreateNote()) return null;

    final trimmedTitle =
        title.trim().isEmpty ? 'Untitled Note' : title.trim();
    final trimmedBody = body.trim();

    logger.i("📌 Creating manual note for user: ${user.id}");

    try {
      final data = await _supabase
          .from('transcribe')
          .insert({
            "user_id": user.id,
            "title": trimmedTitle,
            "transcribe_text": "",
            "summary_text": trimmedBody,
            "duration_seconds": 0,
            "tags": tags,
          })
          .select()
          .single();

      logger.i("✅ addManualNote Response: $data");

      final newItem = TranscribeModel.fromJson(data);
      allUsersTranscribe.insert(0, newItem);
      _bumpLocalNoteCount();

      logger.i("🟢 Inserted manual note with ID: ${newItem.id}");

      return newItem.id;
    } catch (e, s) {
      logger.i("❌ addManualNote Error: $e\n$s");
      return null;
    }
  }

  /// ✅ Update transcription text
  Future<void> updateTranscribeText(int id, String text) async {
    logger.i("✏️ updateTranscribeText -> id: $id, text length: ${text.length}");

    try {
      final res = await _supabase
          .from('transcribe')
          .update({"transcribe_text": text})
          .eq('id', id);

      logger.i("✅ updateTranscribeText Response: $res");

      final index = allUsersTranscribe.indexWhere((item) => item.id == id);
      if (index != -1) {
        final old = allUsersTranscribe[index];
        allUsersTranscribe[index] = TranscribeModel(
          id: old.id,
          userId: old.userId,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
          title: old.title,
          tags: old.tags,
          transcribeText: text,
          summaryText: old.summaryText,
          durationSeconds: old.durationSeconds,
        );
      }

      logger.i("🟢 Local update done for ID: $id");
    } catch (e, s) {
      logger.i("❌ updateTranscribeText Error: $e\n$s");
    }
  }

  /// ✅ Update title
  Future<void> updateTitle(int id, String title) async {
    if (id == 0) {
      logger.i("⛔ updateTitle skipped: invalid note id");
      return;
    }
    logger.i("✏️ updateTitle -> id: $id, title: $title");

    try {
      final res = await _supabase
          .from('transcribe')
          .update({"title": title})
          .eq('id', id);

      logger.i("✅ updateTitle Response: $res");

      final index = allUsersTranscribe.indexWhere((item) => item.id == id);
      if (index != -1) {
        final old = allUsersTranscribe[index];
        allUsersTranscribe[index] = TranscribeModel(
          id: old.id,
          userId: old.userId,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
          transcribeText: old.transcribeText,
          summaryText: old.summaryText,
          durationSeconds: old.durationSeconds,
          tags: old.tags,
          title: title,
        );
      }

      logger.i("🟢 Local update done for ID: $id");
    } catch (e, s) {
      logger.i("❌ updateTitle Error: $e\n$s");
    }
  }

  Future<void> updateSummaryText(int id, String summary) async {
    if (id == 0) return;
    try {
      await _supabase
          .from('transcribe')
          .update({"summary_text": summary})
          .eq('id', id);

      final index = allUsersTranscribe.indexWhere((item) => item.id == id);
      if (index != -1) {
        final old = allUsersTranscribe[index];
        allUsersTranscribe[index] = TranscribeModel(
          id: old.id,
          userId: old.userId,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
          title: old.title,
          tags: old.tags,
          transcribeText: old.transcribeText,
          summaryText: summary,
          durationSeconds: old.durationSeconds,
        );
      }
    } catch (e, s) {
      logger.i("❌ updateSummaryText Error: $e\n$s");
    }
  }

  Future<void> updateDurationSeconds(int id, int seconds) async {
    if (id == 0) return;
    recordingDurationSeconds.value = seconds;
    try {
      await _supabase
          .from('transcribe')
          .update({"duration_seconds": seconds})
          .eq('id', id);

      final index = allUsersTranscribe.indexWhere((item) => item.id == id);
      if (index != -1) {
        final old = allUsersTranscribe[index];
        allUsersTranscribe[index] = TranscribeModel(
          id: old.id,
          userId: old.userId,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
          title: old.title,
          tags: old.tags,
          transcribeText: old.transcribeText,
          summaryText: old.summaryText,
          durationSeconds: seconds,
        );
      }
    } catch (e, s) {
      logger.i("❌ updateDurationSeconds Error: $e\n$s");
    }
  }

  /// ✅ Update tags
  Future<void> updateTags(int id, List<String> tags) async {
    logger.i("🏷 updateTags -> id: $id, tags: $tags");

    try {
      final res = await _supabase
          .from('transcribe')
          .update({"tags": tags})
          .eq('id', id);

      logger.i("✅ updateTags Response: $res");

      final index = allUsersTranscribe.indexWhere((item) => item.id == id);
      if (index != -1) {
        final old = allUsersTranscribe[index];
        allUsersTranscribe[index] = TranscribeModel(
          id: old.id,
          userId: old.userId,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
          transcribeText: old.transcribeText,
          summaryText: old.summaryText,
          durationSeconds: old.durationSeconds,
          title: old.title,
          tags: tags,
        );
      }

      logger.i("🟢 Local update done for ID: $id");
    } catch (e, s) {
      logger.i("❌ updateTags Error: $e\n$s");
    }
  }

  /// ✅ Delete item
  Future<void> deleteTranscribe(int id) async {
    logger.i("🗑 deleteTranscribe -> id: $id");

    try {
      await clearStoredAudioPath(id);
      await _deleteCloudAudio(id);

      final res = await _supabase.from('transcribe').delete().eq('id', id);

      logger.i("✅ deleteTranscribe Response: $res");

      allUsersTranscribe.removeWhere((t) => t.id == id);

      logger.i("🟢 Removed from local list");
    } catch (e, s) {
      logger.i("❌ deleteTranscribe Error: $e\n$s");
    }
  }
}
