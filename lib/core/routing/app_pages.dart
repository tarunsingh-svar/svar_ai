import 'package:get/get.dart';
import 'package:svar_ai/modules/note/note_pages.dart';
import 'package:svar_ai/modules/user_details/user_age_screen.dart';
import 'package:svar_ai/modules/user_details/user_profession_screen.dart';
import 'package:svar_ai/modules/user_details/user_usage_screen.dart';
import 'package:svar_ai/modules/welcome/welcome_page.dart';
import '../../modules/intro/intro_screens.dart';
import '../../modules/auth/login/login_page.dart';
import '../../modules/home/home_page.dart';
import '../../modules/note/create_note_page.dart';
import '../../modules/note/recording_note_page.dart';
import '../../modules/pricing/princing_page.dart';
import '../../modules/record/record_page.dart';
import '../../modules/settings/settings_page.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(name: AppRoutes.welcome, page: () => const WelcomePage()),
    GetPage(name: AppRoutes.intro, page: () => const IntroScreens()),
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.home, page: () => HomePage()),
    GetPage(name: AppRoutes.userAgeScreen, page: () => UserAgeScreen()),
    GetPage(name: AppRoutes.userProfession, page: () => UserProfessionScreen()),
    GetPage(name: AppRoutes.userUsage, page: () => UserUsageScreen()),
    GetPage(name: AppRoutes.notePage, page: () => NotePage()),
    GetPage(name: AppRoutes.recordingNotePage, page: () => RecordingNotePage()),
    GetPage(name: AppRoutes.createNotePage, page: () => CreateNotePage()),
    GetPage(name: AppRoutes.settingsPage, page: () => SettingsPage()),
    GetPage(name: AppRoutes.pricingPage, page: () => PricingPage()),
    GetPage(name: AppRoutes.recordPage, page: () => RecordPage()),
  ];
}
