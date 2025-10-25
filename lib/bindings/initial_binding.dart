import 'package:get/get.dart';
import '../modules/auth/login/login_controller.dart';
import '../modules/user_details/controller/user_details_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginController(), permanent: true);
    Get.put(UserDetailsController());
  }
}
