import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:svar_ai/core/constants/support_config.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkLauncher {
  LinkLauncher._();

  static Future<bool> openUrl(
    String url, {
    String? errorMessage,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showError(errorMessage ?? 'Invalid link.');
      return false;
    }

    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        _showError(errorMessage ?? 'Could not open link.');
      }
      return launched;
    } catch (_) {
      _showError(errorMessage ?? 'Could not open link.');
      return false;
    }
  }

  static Future<bool> openSupportEmail({String? userId}) async {
    final body = StringBuffer('Hi SVAR AI team,\n\n');
    if (userId != null && userId.isNotEmpty) {
      body.writeln('User ID: $userId');
      body.writeln();
    }
    body.write('Please describe your issue or question:\n');

    final uri = Uri(
      scheme: 'mailto',
      path: SupportConfig.supportEmail,
      queryParameters: {
        'subject': 'SVAR AI Support',
        'body': body.toString(),
      },
    );

    try {
      final launched = await launchUrl(uri);
      if (!launched) {
        _showError('Could not open your email app.');
      }
      return launched;
    } catch (_) {
      _showError('Could not open your email app.');
      return false;
    }
  }

  static Future<bool> openStoreForFeedback() async {
    if (kIsWeb) {
      _showError('Store reviews are available in the mobile app.');
      return false;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final reviewUrl = SupportConfig.appStoreReviewUrl;
      if (reviewUrl != null) {
        return openUrl(
          reviewUrl,
          errorMessage: 'Could not open the App Store.',
        );
      }
      _showError('App Store link is not configured yet.');
      return false;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return openUrl(
        SupportConfig.playStoreListingUrl,
        errorMessage: 'Could not open Google Play.',
      );
    }

    _showError('Store reviews are available on iOS and Android.');
    return false;
  }

  static Future<bool> openFeatureRequestForm() async {
    final url = SupportConfig.featureRequestFormUrl.trim();
    if (url.isEmpty) {
      _showError('Feature request form link is not available yet.');
      return false;
    }
    return openUrl(
      url,
      errorMessage: 'Could not open the feature request form.',
    );
  }

  static void _showError(String message) {
    Get.snackbar(
      'Unable to open',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
