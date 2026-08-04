/// The languages offered in Settings > Language Options.
///
/// Codes are sent to the backend, which routes each recording to the provider
/// that handles that language best. The [indian] group must stay in step with
/// `SARVAM_LANGUAGES` in `svar_ai_flask/services/stt/languages.py`; everything in
/// [global] is served by OpenAI.
///
/// Urdu is the one language in both camps, so it sits in [global]: Sarvam covers
/// `ur-IN`, but only speakers on an Indian device locale are routed there.
class TranscriptionLanguage {
  const TranscriptionLanguage({
    required this.code,
    required this.name,
    this.nativeName,
  });

  /// Code sent to the backend. `auto` means let the server detect.
  final String code;

  /// English display name.
  final String name;

  /// Endonym, shown as a subtitle where it differs from [name].
  final String? nativeName;

  /// What to show in a list row.
  String get subtitle => nativeName ?? name;
}

class TranscriptionLanguages {
  TranscriptionLanguages._();

  static const autoCode = 'auto';

  static const auto = TranscriptionLanguage(
    code: autoCode,
    name: 'Auto-detect',
  );

  /// Handled by Sarvam, which is noticeably better at code-mixed Hinglish and
  /// other Indian speech than general-purpose models.
  static const indian = <TranscriptionLanguage>[
    TranscriptionLanguage(
        code: 'en-IN', name: 'English (India)', nativeName: 'Indian English'),
    TranscriptionLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
    TranscriptionLanguage(code: 'as', name: 'Assamese', nativeName: 'অসমীয়া'),
    TranscriptionLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    TranscriptionLanguage(code: 'brx', name: 'Bodo', nativeName: 'बड़ो'),
    TranscriptionLanguage(code: 'doi', name: 'Dogri', nativeName: 'डोगरी'),
    TranscriptionLanguage(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી'),
    TranscriptionLanguage(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    TranscriptionLanguage(code: 'ks', name: 'Kashmiri', nativeName: 'کٲشُر'),
    TranscriptionLanguage(code: 'kok', name: 'Konkani', nativeName: 'कोंकणी'),
    TranscriptionLanguage(code: 'mai', name: 'Maithili', nativeName: 'मैथिली'),
    TranscriptionLanguage(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം'),
    TranscriptionLanguage(code: 'mni', name: 'Manipuri', nativeName: 'মৈতৈলোন্'),
    TranscriptionLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
    TranscriptionLanguage(code: 'ne', name: 'Nepali', nativeName: 'नेपाली'),
    TranscriptionLanguage(code: 'or', name: 'Odia', nativeName: 'ଓଡ଼ିଆ'),
    TranscriptionLanguage(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ'),
    TranscriptionLanguage(code: 'sa', name: 'Sanskrit', nativeName: 'संस्कृतम्'),
    TranscriptionLanguage(code: 'sat', name: 'Santali', nativeName: 'ᱥᱟᱱᱛᱟᱲᱤ'),
    TranscriptionLanguage(code: 'sd', name: 'Sindhi', nativeName: 'سنڌي'),
    TranscriptionLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    TranscriptionLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
  ];

  /// Handled by OpenAI, which covers roughly 99 languages.
  static const global = <TranscriptionLanguage>[
    TranscriptionLanguage(code: 'en', name: 'English'),
    TranscriptionLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    TranscriptionLanguage(code: 'zh', name: 'Chinese', nativeName: '中文'),
    TranscriptionLanguage(code: 'cs', name: 'Czech', nativeName: 'Čeština'),
    TranscriptionLanguage(code: 'da', name: 'Danish', nativeName: 'Dansk'),
    TranscriptionLanguage(code: 'nl', name: 'Dutch', nativeName: 'Nederlands'),
    TranscriptionLanguage(code: 'fil', name: 'Filipino'),
    TranscriptionLanguage(code: 'fi', name: 'Finnish', nativeName: 'Suomi'),
    TranscriptionLanguage(code: 'fr', name: 'French', nativeName: 'Français'),
    TranscriptionLanguage(code: 'de', name: 'German', nativeName: 'Deutsch'),
    TranscriptionLanguage(code: 'el', name: 'Greek', nativeName: 'Ελληνικά'),
    TranscriptionLanguage(code: 'he', name: 'Hebrew', nativeName: 'עברית'),
    TranscriptionLanguage(code: 'hu', name: 'Hungarian', nativeName: 'Magyar'),
    TranscriptionLanguage(
        code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia'),
    TranscriptionLanguage(code: 'it', name: 'Italian', nativeName: 'Italiano'),
    TranscriptionLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語'),
    TranscriptionLanguage(code: 'ko', name: 'Korean', nativeName: '한국어'),
    TranscriptionLanguage(
        code: 'ms', name: 'Malay', nativeName: 'Bahasa Melayu'),
    TranscriptionLanguage(code: 'no', name: 'Norwegian', nativeName: 'Norsk'),
    TranscriptionLanguage(code: 'fa', name: 'Persian', nativeName: 'فارسی'),
    TranscriptionLanguage(code: 'pl', name: 'Polish', nativeName: 'Polski'),
    TranscriptionLanguage(
        code: 'pt', name: 'Portuguese', nativeName: 'Português'),
    TranscriptionLanguage(code: 'ro', name: 'Romanian', nativeName: 'Română'),
    TranscriptionLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский'),
    TranscriptionLanguage(code: 'es', name: 'Spanish', nativeName: 'Español'),
    TranscriptionLanguage(
        code: 'sw', name: 'Swahili', nativeName: 'Kiswahili'),
    TranscriptionLanguage(code: 'sv', name: 'Swedish', nativeName: 'Svenska'),
    TranscriptionLanguage(code: 'th', name: 'Thai', nativeName: 'ไทย'),
    TranscriptionLanguage(code: 'tr', name: 'Turkish', nativeName: 'Türkçe'),
    TranscriptionLanguage(
        code: 'uk', name: 'Ukrainian', nativeName: 'Українська'),
    TranscriptionLanguage(code: 'ur', name: 'Urdu', nativeName: 'اردو'),
    TranscriptionLanguage(
        code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt'),
  ];

  static const all = <TranscriptionLanguage>[auto, ...indian, ...global];

  /// The language for [code], falling back to [auto] for anything unknown so a
  /// stale stored preference can never leave the picker with nothing selected.
  static TranscriptionLanguage byCode(String? code) {
    if (code == null || code.isEmpty) return auto;
    for (final language in all) {
      if (language.code == code) return language;
    }
    return auto;
  }
}
