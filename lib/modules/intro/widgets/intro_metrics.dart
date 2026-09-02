import 'package:flutter/material.dart';

/// Layout constants from the 412×917 reference frame, scaled per device.
class IntroMetrics {
  IntroMetrics._();

  static const refWidth = 412.0;
  static const refHeight = 917.0;

  static double w(BuildContext context) =>
      MediaQuery.sizeOf(context).width / refWidth;

  static double h(BuildContext context) =>
      MediaQuery.sizeOf(context).height / refHeight;

  static double horizontalPadding(BuildContext context) => 26 * w(context);

  static double progressTopPadding(BuildContext context) => 16 * h(context);

  static double progressBarHeight(BuildContext context) => 4 * h(context);

  static double progressBarGap(BuildContext context) => 8 * w(context);

  /// Smooth progress-bar fill — capped to each screen's reveal sequence length.
  static const screen1BarFillDuration = Duration(milliseconds: 1800);
  static const screen2BarFillDuration = Duration(milliseconds: 2500);
  static const screen3BarFillDuration = Duration(milliseconds: 2000);

  static Duration barFillDurationForPage(int page) => switch (page) {
    0 => screen1BarFillDuration,
    1 => screen2BarFillDuration,
    2 => screen3BarFillDuration,
    _ => screen1BarFillDuration,
  };

  static double headlineToBodyGap(BuildContext context) => 20 * h(context);

  static double bodyToButtonGap(BuildContext context) => 38 * h(context);

  static double bottomPadding(BuildContext context) => 26 * h(context);

  static double gridCellSize(BuildContext context) => 96 * w(context);

  /// Floating chip: 153.25 × 53.26 on the reference screen.
  static double pillWidth(BuildContext context) => 153.25 * w(context);

  static double pillHeight(BuildContext context) => 53.26 * h(context);

  static const pillHeightRef = 53.26;

  static const pillWidthRef = 153.25;

  /// Top offset for the first chip below the progress bars (412×917 ref).
  static const firstPillTopFromProgress = 75.0;

  /// Vertical gap between 2 AM Thoughts and Meetings (412×917 ref).
  static const firstRowPillVerticalGap = 40.0;

  /// Vertical gap between 2 AM Thoughts and Lectures (412×917 ref).
  static const firstToLecturesVerticalGap = 150.0;

  /// Vertical gap between Lectures and Content Idea (412×917 ref).
  static const pillVerticalGap = 75.0;

  /// Horizontal gap between Lectures and Content Idea (412×917 ref).
  static const lecturesToContentHorizontalGap = 24.0;

  /// Intro headline size on the reference screen (was 34 px).
  static double headlineFontSize(BuildContext context) => 40 * w(context);

  // Screen 2 — capture flow cards (412×917 ref).
  /// Gap from progress bar bottom to first card top.
  static double captureFlowTopPadding(BuildContext context) => 32 * h(context);

  /// Gap from the bottom card to the headline text block.
  static double captureFlowToHeadlineGap(BuildContext context) => 48 * h(context);

  static double captureArrowGap(BuildContext context) => 4 * h(context);

  static double captureCardPadding(BuildContext context) => 11 * w(context);

  static double captureCardRadius(BuildContext context) => 10 * w(context);

  static double captureCardBorderWidth(BuildContext context) => 1 * w(context);

  static double captureIconSize(BuildContext context) => 26 * w(context);

  static double captureLabelFontSize(BuildContext context) => 10 * w(context);

  static double captureBodyFontSize(BuildContext context) => 14 * w(context);

  static double captureSectionLabelFontSize(BuildContext context) => 10 * w(context);

  static double captureInnerGap(BuildContext context) => 8 * h(context);

  static double captureSectionGap(BuildContext context) => 10 * h(context);

  /// Compact waveform in the voice card header row.
  static double captureWaveformCompactHeight(BuildContext context) =>
      12 * h(context);

  static double captureActionItemsLabelGap(BuildContext context) => 15 * h(context);

  static double captureArrowSize(BuildContext context) => 22 * w(context);

  static double captureCheckboxSize(BuildContext context) => 16 * w(context);

  // Screen 3 — rewrite format chips (412×917 ref).
  static double rewriteChipGap(BuildContext context) => 16 * h(context);

  static double rewriteChipSpacing(BuildContext context) => 8 * w(context);

  static double rewriteChipRadius(BuildContext context) => 8 * w(context);

  static double rewriteChipFontSize(BuildContext context) => 11 * w(context);

  static double rewriteChipPaddingH(BuildContext context) => 14 * w(context);

  static double rewriteChipPaddingV(BuildContext context) => 10 * h(context);

  static double rewriteChipIconSize(BuildContext context) => 16 * w(context);

  static double rewriteCardHeaderFontSize(BuildContext context) => 12 * w(context);

  static double rewriteOptionsFontSize(BuildContext context) => 12 * w(context);

  static double rewriteCardBodyFontSize(BuildContext context) => 15 * w(context);

  /// Gap from the email chip row to the headline (412×917 ref).
  static double rewriteChipToHeadlineGap(BuildContext context) => 48 * h(context);
}
