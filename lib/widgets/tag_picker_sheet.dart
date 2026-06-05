import 'package:get/get.dart';
import 'package:svar_ai/data/models/transcribe_model.dart';
import 'package:svar_ai/widgets/manage_tags_page.dart';

List<String> getAllExistingTags(List<TranscribeModel> notes) {
  final tags = notes
      .expand((note) => note.tags ?? const <String>[])
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toSet()
      .toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return tags;
}

/// Opens the full-screen Manage Tags page.
/// Returns the updated selected tags list, or null if dismissed without saving.
Future<List<String>?> showTagPickerSheet({
  required List<String> selectedTags,
}) async {
  final result = await Get.to<List<String>>(
    () => ManageTagsPage(initialTags: selectedTags),
  );
  return result;
}
