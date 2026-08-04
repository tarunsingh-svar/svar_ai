import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/transcription_languages.dart';

/// The user's transcription language choice, plus the device locale.
///
/// The backend needs both: an explicit language pins the provider outright,
/// while the locale is what lets auto-detect keep Indian speech on Sarvam and
/// send everyone else to OpenAI.
class TranscriptionPreferences {
  TranscriptionPreferences._();

  static const _languageKey = 'transcription_language';

  static SharedPreferences? get _prefs =>
      Get.isRegistered<SharedPreferences>() ? Get.find<SharedPreferences>() : null;

  /// Selected language code, or `auto`.
  static String get languageCode =>
      _prefs?.getString(_languageKey) ?? TranscriptionLanguages.autoCode;

  static TranscriptionLanguage get language =>
      TranscriptionLanguages.byCode(languageCode);

  static Future<void> setLanguageCode(String code) async {
    await _prefs?.setString(_languageKey, code);
  }

  /// Device locale as a BCP-47-ish tag, e.g. `en-IN` or `de`.
  static String get deviceLocale {
    final locale = PlatformDispatcher.instance.locale;
    final country = locale.countryCode;
    if (country == null || country.isEmpty) return locale.languageCode;
    return '${locale.languageCode}-$country';
  }
}
