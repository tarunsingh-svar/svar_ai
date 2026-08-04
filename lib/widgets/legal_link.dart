import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/text_styles.dart';

/// Tappable link to one of the in-app legal documents.
///
/// Both stores require the sign-in screen and the paywall to link to the Terms
/// of Use and the Privacy Policy. These open the in-app pages rather than
/// svar.ai so they work offline and without handing off to a browser; the
/// public URLs in `SupportConfig` are what the store listings point at.
class LegalLink extends StatelessWidget {
  const LegalLink({
    super.key,
    required this.label,
    required this.route,
    this.style,
  });

  final String label;
  final String route;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? AppTextTheme.body3;

    return InkWell(
      onTap: () => Get.toNamed(route),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Text(
          label,
          style: baseStyle.copyWith(
            color: baseStyle.color ?? AppColors.primary,
            decoration: TextDecoration.underline,
            decorationColor: baseStyle.color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}
