import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/helpers/api_helper.dart';
import '../../data/models/transcribe_model.dart';

class TranscribeController extends GetxController {
  final _supabase = Supabase.instance.client;
  final thisNoteId = 0.obs;

  RxList<TranscribeModel> allUsersTranscribe = <TranscribeModel>[].obs;

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

  /// ✅ Create new transcribe
  Future<int?> addNewTranscribe() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      logger.i("⛔ addNewTranscribe: No user logged in");
      return null;
    }

    logger.i("📌 Creating new transcribe row for user: ${user.id}");

    try {
      final data = await _supabase
          .from('transcribe')
          .insert({
            "user_id": user.id,
            "title": "",
            "transcribe_text": "",
            "tags": [],
          })
          .select()
          .single();

      logger.i("✅ addNewTranscribe Response: $data");

      final newItem = TranscribeModel.fromJson(data);
      allUsersTranscribe.insert(0, newItem);
      thisNoteId.value = newItem.id;

      logger.i("🟢 Inserted new transcribe with ID: ${newItem.id}");

      return newItem.id;
    } catch (e, s) {
      logger.i("❌ addNewTranscribe Error: $e\n$s");
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
        );
      }

      logger.i("🟢 Local update done for ID: $id");
    } catch (e, s) {
      logger.i("❌ updateTranscribeText Error: $e\n$s");
    }
  }

  /// ✅ Update title
  Future<void> updateTitle(int id, String title) async {
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
          tags: old.tags,
          title: title,
        );
      }

      logger.i("🟢 Local update done for ID: $id");
    } catch (e, s) {
      logger.i("❌ updateTitle Error: $e\n$s");
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
      final res = await _supabase.from('transcribe').delete().eq('id', id);

      logger.i("✅ deleteTranscribe Response: $res");

      allUsersTranscribe.removeWhere((t) => t.id == id);

      logger.i("🟢 Removed from local list");
    } catch (e, s) {
      logger.i("❌ deleteTranscribe Error: $e\n$s");
    }
  }
}
