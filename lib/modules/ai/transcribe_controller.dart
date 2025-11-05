import 'dart:developer';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/transcribe_model.dart';

class TranscribeController extends GetxController {
  final _supabase = Supabase.instance.client;

  RxList<TranscribeModel> allUsersTranscribe = <TranscribeModel>[].obs;

  /// ✅ Fetch Transcribes for Logged-in User
  Future<void> fetchAllUsersTranscribes() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final res = await _supabase
          .from('transcribe')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      allUsersTranscribe.value = res
          .map((e) => TranscribeModel.fromJson(e))
          .toList();
    } catch (e) {
      log("Fetch error: $e");
    }
  }

  /// ✅ Insert Empty Row → Get ID
  Future<int?> addNewTranscribe() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('transcribe')
          .insert({"user_id": user.id, "transcribe_text": ""})
          .select()
          .single();

      final newItem = TranscribeModel.fromJson(data);
      allUsersTranscribe.insert(0, newItem);
      return newItem.id; // ✅ Return created row ID
    } catch (e) {
      log("Insert error: $e");
      return null;
    }
  }

  /// ✅ Update Transcribe Text Using ID
  Future<void> updateTranscribe(int id, String text) async {
    try {
      await _supabase
          .from('transcribe')
          .update({"transcribe_text": text})
          .eq('id', id);

      // Update local list too
      int index = allUsersTranscribe.indexWhere((item) => item.id == id);
      if (index != -1) {
        allUsersTranscribe[index] = TranscribeModel(
          id: id,
          userId: allUsersTranscribe[index].userId,
          createdAt: allUsersTranscribe[index].createdAt,
          transcribeText: text,
        );
      }
    } catch (e) {
      log("Update error: $e");
    }
  }

  /// ✅ Delete Row
  Future<void> deleteTranscribe(int id) async {
    try {
      await _supabase.from('transcribe').delete().eq('id', id);
      allUsersTranscribe.removeWhere((t) => t.id == id);
    } catch (e) {
      log("Delete error: $e");
    }
  }
}
