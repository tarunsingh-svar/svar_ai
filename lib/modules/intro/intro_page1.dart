import 'package:flutter/material.dart';

import 'widgets/intro_metrics.dart';
import 'widgets/intro_shared.dart';

class IntroScreen1 extends StatelessWidget {
  const IntroScreen1({super.key, required this.isActive});

  final bool isActive;

  static const _firstPillLeft = 34.0;
  static const _meetingsLeft = 230.0;

  static const _firstPillTop = IntroMetrics.firstPillTopFromProgress;

  static const _meetingsTop =
      _firstPillTop +
      IntroMetrics.pillHeightRef +
      IntroMetrics.firstRowPillVerticalGap;

  static const _lecturesTop =
      _firstPillTop +
      IntroMetrics.pillHeightRef +
      IntroMetrics.firstToLecturesVerticalGap;

  static const _contentIdeaTop =
      _lecturesTop + IntroMetrics.pillHeightRef + IntroMetrics.pillVerticalGap;

  static const _contentIdeaLeft =
      _firstPillLeft +
      IntroMetrics.pillWidthRef +
      IntroMetrics.lecturesToContentHorizontalGap;

  static const _pills = [
    IntroPillSpec(
      label: '2 AM Thoughts',
      color: Color(0xFF6BAEF5),
      left: _firstPillLeft,
      top: _firstPillTop,
      tilt: -0.22,
    ),
    IntroPillSpec(
      label: 'Meetings',
      color: Color(0xFF5ECAB8),
      left: _meetingsLeft,
      top: _meetingsTop,
      tilt: -0.06,
    ),
    IntroPillSpec(
      label: 'Lectures',
      color: Color(0xFFAE9BF7),
      left: _firstPillLeft,
      top: _lecturesTop,
      tilt: 0.18,
    ),
    IntroPillSpec(
      label: 'Content Idea',
      color: Color(0xBFF4B447),
      left: _contentIdeaLeft,
      top: _contentIdeaTop,
      tilt: -0.16,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: IntroFloatingPills(pills: _pills, isActive: isActive),
        ),
        const IntroTextBlock(
          headlineBlue: "Thought's",
          headlineBlack: "don't wait.",
          body:
              'From important meetings to random ideas that hit you out of '
              'nowhere – capture them before they\'re gone.',
        ),
      ],
    );
  }
}
