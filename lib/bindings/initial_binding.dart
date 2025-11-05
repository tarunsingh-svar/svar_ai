import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modules/ai/ai_controller.dart';
import '../modules/ai/transcribe_controller.dart';
import '../modules/auth/login/login_controller.dart';
import '../modules/user_details/controller/user_details_controller.dart';

class InitialBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    Get.put(LoginController(), permanent: true);
    Get.put(UserDetailsController());
    Get.put(AIController());
    Get.put(TranscribeController());

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);
    Get.put<SharedPreferences>(prefs, permanent: true);
  }
}
