import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Layout constants from the 412×917 reference frame, scaled per device.
class WelcomeMetrics {
  WelcomeMetrics._();

  static const _refWidth = 412.0;
  static const _refHeight = 917.0;

  static double w(BuildContext context) =>
      MediaQuery.sizeOf(context).width / _refWidth;

  static double h(BuildContext context) =>
      MediaQuery.sizeOf(context).height / _refHeight;

  /// Logo mark: 136×136 on the reference screen.
  static double logoSize(BuildContext context) => 136 * w(context);

  /// Left/right inset for headline, subtext, and button (~26 px on reference).
  static double horizontalContentPadding(BuildContext context) =>
      26 * w(context);

  /// Login row sits ~26 px above the bottom edge.
  static double bottomPadding(BuildContext context) => 26 * h(context);

  /// Gap between the Get Started button and the login row.
  static double loginToButtonGap(BuildContext context) => 44 * h(context);

  /// Gap between the subtext and the Get Started button.
  static double buttonToSubtextGap(BuildContext context) => 38 * h(context);

  /// Gap between the headline and the subtext.
  static double headlineToSubtextGap(BuildContext context) => 20 * h(context);

  /// Gap between the outer orbit and the headline.
  static double orbitToHeadlineGap(BuildContext context) => 72 * h(context);

  /// Space between the hero box bottom and the headline. The outer orbit
  /// sits ~2 % above the hero box bottom, so this is slightly less than
  /// [orbitToHeadlineGap].
  static double gapBelowHeroBox(BuildContext context) {
    final heroSide = MediaQuery.sizeOf(context).width - (8.w);
    final insetBelowOrbit = heroSide * 0.02;
    return math.max(0, orbitToHeadlineGap(context) - insetBelowOrbit);
  }
}