/// Support, feedback, and store links used in Settings > Help & Feedback.
class SupportConfig {
  SupportConfig._();

  static const supportEmail = 'tech@svar.ai';

  /// Google Form URL for feature requests. Set when available.
  static const featureRequestFormUrl = '';

  static const androidPackageId = 'com.svar.ai';

  /// Public legal URLs. Both store consoles require these in the app listing;
  /// in-app screens link to the bundled copies instead so they work offline.
  static const privacyPolicyUrl = 'https://svar.ai/privacy';
  static const termsOfServiceUrl = 'https://svar.ai/terms';

  /// Numeric App Store ID from App Store Connect (e.g. 1234567890).
  static const iosAppStoreId = '';

  static String get playStoreListingUrl =>
      'https://play.google.com/store/apps/details?id=$androidPackageId';

  static String? get appStoreListingUrl {
    if (iosAppStoreId.isEmpty) return null;
    return 'https://apps.apple.com/app/id$iosAppStoreId';
  }

  static String? get appStoreReviewUrl {
    if (iosAppStoreId.isEmpty) return null;
    return 'https://apps.apple.com/app/id$iosAppStoreId?action=write-review';
  }
}
