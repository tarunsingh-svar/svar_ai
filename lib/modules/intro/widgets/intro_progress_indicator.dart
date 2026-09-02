import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'intro_metrics.dart';

/// Three-segment step indicator for the intro flow.
///
/// Completed pages show a full blue bar; the [currentPage] bar fills smoothly
/// via [currentPageProgress] (0.0 → 1.0).
class IntroProgressIndicator extends StatelessWidget {
  const IntroProgressIndicator({
    super.key,
    required this.currentPage,
    required this.currentPageProgress,
    this.totalSteps = 3,
  });

  final int currentPage;
  final double currentPageProgress;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final barHeight = IntroMetrics.progressBarHeight(context);
    final gap = IntroMetrics.progressBarGap(context);

    return Padding(
      padding: EdgeInsets.only(
        top: IntroMetrics.progressTopPadding(context),
        left: IntroMetrics.horizontalPadding(context),
        right: IntroMetrics.horizontalPadding(context),
      ),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final progress = index < currentPage
              ? 1.0
              : index == currentPage
              ? currentPageProgress.clamp(0.0, 1.0)
              : 0.0;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < totalSteps - 1 ? gap : 0),
              child: _ProgressSegment(progress: progress, height: barHeight),
            ),
          );
        }),
      ),
    );
  }
}

class _ProgressSegment extends StatelessWidget {
  const _ProgressSegment({required this.progress, required this.height});

  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.grey300),
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                heightFactor: 1,
                alignment: Alignment.centerLeft,
                child: const ColoredBox(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
