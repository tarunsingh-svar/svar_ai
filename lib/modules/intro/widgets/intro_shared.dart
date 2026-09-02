import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import 'intro_flow_reveal.dart';
import 'intro_metrics.dart';

class IntroPillSpec {
  const IntroPillSpec({
    required this.label,
    required this.color,
    this.alignment,
    this.left,
    this.top,
    this.tilt = 0,
  }) : assert(
         alignment != null || (left != null && top != null),
         'Provide alignment or both left and top',
       );

  final String label;
  final Color color;

  /// Fractional position when [left]/[top] are not set.
  final Alignment? alignment;

  /// Distance from the left edge of the screen (412 px reference).
  final double? left;

  /// Distance from the top of the pill area (917 px reference height).
  /// When placing the first chip below the progress bars, use ~75 px.
  final double? top;

  final double tilt;
}

/// Pastel floating labels used in the intro illustrations.
class IntroFloatingPills extends StatefulWidget {
  const IntroFloatingPills({
    super.key,
    required this.pills,
    required this.isActive,
  });

  final List<IntroPillSpec> pills;
  final bool isActive;

  @override
  State<IntroFloatingPills> createState() => _IntroFloatingPillsState();
}

class _IntroFloatingPillsState extends State<IntroFloatingPills> {
  static const _stepPause = Duration(milliseconds: 400);
  static const _revealDuration = Duration(milliseconds: 450);

  int _visibleCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startSequence());
    }
  }

  @override
  void didUpdateWidget(covariant IntroFloatingPills oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.isActive) _startSequence();
      });
    } else if (!widget.isActive && oldWidget.isActive) {
      _resetSequence();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetSequence() {
    _timer?.cancel();
    setState(() => _visibleCount = 0);
  }

  void _startSequence() {
    _resetSequence();
    _revealNext(0);
  }

  void _revealNext(int index) {
    if (!mounted || index >= widget.pills.length) return;
    setState(() => _visibleCount = index + 1);
    if (index + 1 < widget.pills.length) {
      _timer = Timer(_stepPause, () => _revealNext(index + 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < widget.pills.length; i++)
                _AnimatedPill(
                  pill: widget.pills[i],
                  visible: i < _visibleCount,
                  duration: _revealDuration,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedPill extends StatelessWidget {
  const _AnimatedPill({
    required this.pill,
    required this.visible,
    required this.duration,
  });

  final IntroPillSpec pill;
  final bool visible;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final child = Transform.rotate(
      angle: pill.tilt,
      child: _Pill(label: pill.label, color: pill.color),
    );

    final revealed = IntroFlowRevealItem(
      visible: visible,
      duration: duration,
      child: child,
    );

    if (pill.left != null && pill.top != null) {
      return Positioned(
        left: pill.left! * IntroMetrics.w(context),
        top: pill.top! * IntroMetrics.h(context),
        child: revealed,
      );
    }

    return Align(
      alignment: pill.alignment!,
      child: revealed,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final width = IntroMetrics.pillWidth(context);
    final height = IntroMetrics.pillHeight(context);

    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height * 0.26),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextTheme.body2Medium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15 * IntroMetrics.w(context),
        ),
      ),
    );
  }
}

/// Solid primary Continue button from the intro designs.
class IntroContinueButton extends StatelessWidget {
  const IntroContinueButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'Continue',
          style: AppTextTheme.button.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Shared bottom text block for each intro step.
class IntroTextBlock extends StatelessWidget {
  const IntroTextBlock({
    super.key,
    required this.headlineBlue,
    required this.headlineBlack,
    required this.body,
  });

  final String headlineBlue;
  final String headlineBlack;
  final String body;

  static final TextStyle _headline = AppTextTheme.h2.copyWith(
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.5,
  );

  @override
  Widget build(BuildContext context) {
    final headlineStyle = _headline.copyWith(
      fontSize: IntroMetrics.headlineFontSize(context),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: IntroMetrics.horizontalPadding(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: '$headlineBlue\n',
              style: headlineStyle.copyWith(color: AppColors.primary),
              children: [
                TextSpan(
                  text: headlineBlack,
                  style: headlineStyle.copyWith(color: AppColors.textBlack),
                ),
              ],
            ),
          ),
          SizedBox(height: IntroMetrics.headlineToBodyGap(context)),
          Text(
            body,
            style: AppTextTheme.body1.copyWith(
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
