import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import 'intro_flow_reveal.dart';
import 'intro_metrics.dart';

/// Animated voice → transcript → understanding card stack for intro screen 2.
class IntroCaptureFlow extends StatefulWidget {
  const IntroCaptureFlow({super.key, required this.isActive});

  final bool isActive;

  static const _voiceQuote =
      '“I need to send the revised proposal to Rahul tomorrow and '
      'review the pricing before Monday\'s client meeting.”';

  static const _transcript =
      'I need to send the revised proposal to Rahul tomorrow and '
      'review the pricing before Monday\'s client meeting.';

  static const _summary =
      'Send the revised proposal to Rahul and review pricing before '
      'Monday\'s client meeting.';

  static const _actionItems = [
    'Send revised proposal to Rahul',
    'Review pricing before Monday',
  ];

  @override
  State<IntroCaptureFlow> createState() => _IntroCaptureFlowState();
}

class _IntroCaptureFlowState extends State<IntroCaptureFlow> {
  static const _stepPause = Duration(milliseconds: 500);
  static const _cardRevealDuration = Duration(milliseconds: 450);

  bool _showCard1 = false;
  bool _showArrow1 = false;
  bool _showCard2 = false;
  bool _showArrow2 = false;
  bool _showCard3 = false;

  Timer? _timer;

  @override
  void didUpdateWidget(covariant IntroCaptureFlow oldWidget) {
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
  void initState() {
    super.initState();
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startSequence());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetSequence() {
    _timer?.cancel();
    setState(() {
      _showCard1 = false;
      _showArrow1 = false;
      _showCard2 = false;
      _showArrow2 = false;
      _showCard3 = false;
    });
  }

  void _startSequence() {
    _resetSequence();
    setState(() => _showCard1 = true);
    _delay(_stepPause, () {
      setState(() => _showArrow1 = true);
      _delay(_stepPause, () {
        setState(() => _showCard2 = true);
        _delay(_stepPause, () {
          setState(() => _showArrow2 = true);
          _delay(_stepPause, () {
            setState(() => _showCard3 = true);
          });
        });
      });
    });
  }

  void _delay(Duration duration, VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(duration, () {
      if (mounted) callback();
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = IntroMetrics.horizontalPadding(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontal,
        IntroMetrics.captureFlowTopPadding(context),
        horizontal,
        0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntroFlowRevealItem(
            visible: _showCard1,
            duration: _cardRevealDuration,
            child: const _VoiceCard(),
          ),
          IntroFlowRevealArrow(visible: _showArrow1),
          IntroFlowRevealItem(
            visible: _showCard2,
            duration: _cardRevealDuration,
            child: const _TranscriptCard(),
          ),
          IntroFlowRevealArrow(visible: _showArrow2),
          IntroFlowRevealItem(
            visible: _showCard3,
            duration: _cardRevealDuration,
            child: const _UnderstandingCard(),
          ),
        ],
      ),
    );
  }
}

class _CaptureCardShell extends StatelessWidget {
  const _CaptureCardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = IntroMetrics.captureCardRadius(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(IntroMetrics.captureCardPadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.borderGrey,
          width: IntroMetrics.captureCardBorderWidth(context),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2 * IntroMetrics.h(context)),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final iconSize = IntroMetrics.captureIconSize(context);

    return Row(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: iconSize * 0.52,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 8 * IntroMetrics.w(context)),
        Text(
          label,
          style: AppTextTheme.caption.copyWith(
            fontSize: IntroMetrics.captureLabelFontSize(context),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }
}

class _VoiceCard extends StatelessWidget {
  const _VoiceCard();

  @override
  Widget build(BuildContext context) {
    final bodyStyle = AppTextTheme.body2.copyWith(
      fontSize: IntroMetrics.captureBodyFontSize(context),
      height: 1.35,
      color: AppColors.textBlack,
    );

    return _CaptureCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VoiceCardHeader(),
          SizedBox(height: IntroMetrics.captureInnerGap(context)),
          Text(IntroCaptureFlow._voiceQuote, style: bodyStyle),
        ],
      ),
    );
  }
}

class _VoiceCardHeader extends StatelessWidget {
  const _VoiceCardHeader();

  @override
  Widget build(BuildContext context) {
    final iconSize = IntroMetrics.captureIconSize(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: const BoxDecoration(
            color: AppColors.infoLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mic_rounded,
            size: iconSize * 0.52,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 8 * IntroMetrics.w(context)),
        Text(
          'VOICE • 00:18',
          style: AppTextTheme.caption.copyWith(
            fontSize: IntroMetrics.captureLabelFontSize(context),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.grey600,
          ),
        ),
        const Spacer(),
        const _VoiceWaveform(compact: true),
      ],
    );
  }
}

class _TranscriptCard extends StatelessWidget {
  const _TranscriptCard();

  @override
  Widget build(BuildContext context) {
    final bodyStyle = AppTextTheme.body2.copyWith(
      fontSize: IntroMetrics.captureBodyFontSize(context),
      height: 1.35,
      color: AppColors.textBlack,
    );

    return _CaptureCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            icon: Icons.notes_rounded,
            label: 'TRANSCRIPT',
          ),
          SizedBox(height: IntroMetrics.captureInnerGap(context)),
          Text(IntroCaptureFlow._transcript, style: bodyStyle),
        ],
      ),
    );
  }
}

class _UnderstandingCard extends StatelessWidget {
  const _UnderstandingCard();

  @override
  Widget build(BuildContext context) {
    final bodyStyle = AppTextTheme.body2.copyWith(
      fontSize: IntroMetrics.captureBodyFontSize(context),
      height: 1.35,
      color: AppColors.textBlack,
    );
    final sectionStyle = AppTextTheme.caption.copyWith(
      fontSize: IntroMetrics.captureSectionLabelFontSize(context),
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: AppColors.primary,
    );

    return _CaptureCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            icon: Icons.auto_awesome_rounded,
            label: 'UNDERSTANDING',
          ),
          SizedBox(height: IntroMetrics.captureSectionGap(context)),
          Text('SUMMARY', style: sectionStyle),
          SizedBox(height: 4 * IntroMetrics.h(context)),
          Text(IntroCaptureFlow._summary, style: bodyStyle),
          SizedBox(height: IntroMetrics.captureSectionGap(context)),
          Text('ACTION ITEMS', style: sectionStyle),
          SizedBox(height: IntroMetrics.captureActionItemsLabelGap(context)),
          for (final item in IntroCaptureFlow._actionItems)
            _ActionItemRow(label: item),
        ],
      ),
    );
  }
}

class _ActionItemRow extends StatelessWidget {
  const _ActionItemRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final boxSize = IntroMetrics.captureCheckboxSize(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 4 * IntroMetrics.h(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(3 * IntroMetrics.w(context)),
            ),
            child: Icon(
              Icons.check_rounded,
              size: boxSize * 0.72,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8 * IntroMetrics.w(context)),
          Expanded(
            child: Text(
              label,
              style: AppTextTheme.body2.copyWith(
                fontSize: IntroMetrics.captureBodyFontSize(context),
                height: 1.3,
                color: AppColors.textBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceWaveform extends StatelessWidget {
  const _VoiceWaveform({this.compact = false});

  final bool compact;

  static const _compactHeights = [
    0.45, 0.7, 0.95, 0.6, 0.85, 0.55, 0.75, 0.5,
  ];

  @override
  Widget build(BuildContext context) {
    final barWidth = 2 * IntroMetrics.w(context);
    final gap = 2 * IntroMetrics.w(context);
    final maxHeight = IntroMetrics.captureWaveformCompactHeight(context);

    return SizedBox(
      height: maxHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final height in _compactHeights) ...[
            Container(
              width: barWidth,
              height: maxHeight * height,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(barWidth),
              ),
            ),
            SizedBox(width: gap),
          ],
        ],
      ),
    );
  }
}
