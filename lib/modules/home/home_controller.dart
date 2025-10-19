import 'package:get/get.dart';
import '../../data/models/note_model.dart';

class HomeController extends GetxController {
  final RxString selectedFilter = 'All'.obs;

  final RxList<NoteModel> notes = <NoteModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSampleData();
  }

  void loadSampleData() {
    final data = [
      {
        "title": "PWC Reporting meet",
        "subtitle":
            "So I’m just testing how the recording of the svar ai is going...",
        "date": "August 5, 2025 | All Notes | Office",
        "category": "Office",
      },
      {
        "title": "Tavastra Round 1 - Discussion",
        "subtitle":
            "Out of 4244 applications, only 21 applicants were selected...",
        "date": "August 25, 2025 | Fundraising",
        "category": "Fundraising",
      },
      {
        "title": "Tavastra Round 2 - Discussion",
        "subtitle":
            "Out of 200 applicants, only 50 applicants were selected...",
        "date": "September 8, 2025 | All Notes",
        "category": "All Notes",
      },
      {
        "title": "Tavastra Round 2 - Discussion",
        "subtitle":
            "Out of 200 applicants, only 50 applicants were selected...",
        "date": "September 8, 2025 | All Notes",
        "category": "All Notes",
      },
    ];

    notes.value = data.map((e) => NoteModel.fromJson(e)).toList();
  }

  void changeFilter(String filter) => selectedFilter.value = filter;
}
