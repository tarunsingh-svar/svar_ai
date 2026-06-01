import 'package:get/get.dart';

import '../../data/models/transcribe_model.dart';
import '../ai/transcribe_controller.dart';

class HomeController extends GetxController {
  final TranscribeController transcribeController = Get.find();

  final RxString selectedFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;

  List<String> get availableFilters {
    final tags = transcribeController.allUsersTranscribe
        .expand((note) => note.tags ?? const <String>[])
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return ['All', ...tags];
  }

  List<TranscribeModel> get filteredNotes {
    final query = searchQuery.value.trim().toLowerCase();
    final filter = selectedFilter.value;

    return transcribeController.allUsersTranscribe.where((note) {
      if (filter != 'All') {
        final noteTags = note.tags ?? const <String>[];
        final matchesTag = noteTags.any(
          (tag) => tag.trim().toLowerCase() == filter.toLowerCase(),
        );
        if (!matchesTag) return false;
      }

      if (query.isEmpty) return true;

      final title = (note.title ?? '').toLowerCase();
      final transcript = (note.transcribeText ?? '').toLowerCase();
      return title.contains(query) || transcript.contains(query);
    }).toList();
  }

  void syncFilterWithAvailableTags() {
    if (!availableFilters.contains(selectedFilter.value)) {
      selectedFilter.value = 'All';
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}
