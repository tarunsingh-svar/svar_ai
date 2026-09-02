import 'package:flutter/material.dart';

/// Layout constants from the 412×917 login reference frame.
class LoginMetrics {
  LoginMetrics._();

  static const refWidth = 412.0;
  static const refHeight = 917.0;

  static double w(BuildContext context) =>
      MediaQuery.sizeOf(context).width / refWidth;

  static double h(BuildContext context) =>
      MediaQuery.sizeOf(context).height / refHeight;

  static double horizontalPadding(BuildContext context) => 26 * w(context);

  /// Terms footer — 30 px from the bottom of the 412×917 reference frame.
  static double bottomPadding(BuildContext context) {
    final targetFromScreenBottom = 30 * h(context);
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return (targetFromScreenBottom - safeBottom).clamp(0.0, double.infinity);
  }

  /// Logo top edge — 204 px from the top of the 412×917 reference frame.
  static double topPadding(BuildContext context) {
    final targetFromScreenTop = 204 * h(context);
    final safeTop = MediaQuery.paddingOf(context).top;
    return (targetFromScreenTop - safeTop).clamp(0.0, double.infinity);
  }

  static double logoWidth(BuildContext context) => 76 * w(context);

  static double logoHeight(BuildContext context) => 76 * w(context);

  static double logoSize(BuildContext context) => logoWidth(context);

  static double logoToHeadlineGap(BuildContext context) => 46 * h(context);

  static double headlineToSubtextGap(BuildContext context) => 20 * h(context);

  static double subtextToButtonsGap(BuildContext context) => 46 * h(context);

  static double buttonsToFooterGap(BuildContext context) => 60 * h(context);

  static double buttonHeight(BuildContext context) => 56 * h(context);

  static double buttonRadius(BuildContext context) => 28 * h(context);

  static double buttonGap(BuildContext context) => 16 * h(context);

  static double orDividerGap(BuildContext context) => 24 * h(context);

  static double headlineFontSize(BuildContext context) => 40 * w(context);

  static double subtextFontSize(BuildContext context) => 18 * w(context);

  static double buttonFontSize(BuildContext context) => 17 * w(context);

  static double legalFontSize(BuildContext context) => 12 * w(context);

  static double emailIconSize(BuildContext context) => 24 * w(context);
}
