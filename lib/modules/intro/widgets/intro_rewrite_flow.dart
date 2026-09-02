import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import 'intro_flow_reveal.dart';
import 'intro_metrics.dart';

const _chipUnselectedFill = Color(0xFFFAF8FF);

enum IntroRewriteFormat {
  meetingNotes,
  todo,
  delegationNote,
  email,
}

/// Screen 3 — capture card, rewrite output card, and format chips.
class IntroRewriteFlow extends StatefulWidget {
  const IntroRewriteFlow({super.key, required this.isActive});

  final bool isActive;

  @override
  State<IntroRewriteFlow> createState() => _IntroRewriteFlowState();
}

class _IntroRewriteFlowState extends State<IntroRewriteFlow> {
  IntroRewriteFormat _selected = IntroRewriteFormat.meetingNotes;

  static const _formats = IntroRewriteFormat.values;
  static const _stepPause = Duration(milliseconds: 500);
  static const _cardRevealDuration = Duration(milliseconds: 450);
  static const _chipCycleDelay = Duration(milliseconds: 2200);

  bool _showCaptureCard = false;
  bool _showArrow = false;
  bool _showOutputCard = false;
  bool _showChips = false;

  Timer? _sequenceTimer;
  Timer? _chipCycleTimer;

  static const _captureQuote =
      '“Rahul will send the proposal tomorrow. I need to review it '
      'before the client call.”';

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startSequence());
    }
  }

  @override
  void didUpdateWidget(covariant IntroRewriteFlow oldWidget) {
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
    _sequenceTimer?.cancel();
    _chipCycleTimer?.cancel();
    super.dispose();
  }

  void _resetSequence() {
    _sequenceTimer?.cancel();
    _chipCycleTimer?.cancel();
    setState(() {
      _selected = IntroRewriteFormat.meetingNotes;
      _showCaptureCard = false;
      _showArrow = false;
      _showOutputCard = false;
      _showChips = false;
    });
  }

  void _startSequence() {
    _resetSequence();
    setState(() => _showCaptureCard = true);
    _delay(_stepPause, () {
      setState(() => _showArrow = true);
      _delay(_stepPause, () {
        setState(() => _showOutputCard = true);
        _delay(_stepPause, () {
          setState(() => _showChips = true);
          _startChipCycle();
        });
      });
    });
  }

  void _startChipCycle() {
    _chipCycleTimer?.cancel();
    if (!widget.isActive || !_showChips) return;

    _chipCycleTimer = Timer.periodic(_chipCycleDelay, (_) {
      if (!mounted || !widget.isActive) return;
      setState(() {
        final index = _formats.indexOf(_selected);
        _selected = _formats[(index + 1) % _formats.length];
      });
    });
  }

  void _onFormatSelected(IntroRewriteFormat format) {
    setState(() => _selected = format);
    _startChipCycle();
  }

  void _delay(Duration duration, VoidCallback callback) {
    _sequenceTimer?.cancel();
    _sequenceTimer = Timer(duration, () {
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntroFlowRevealItem(
            visible: _showCaptureCard,
            duration: _cardRevealDuration,
            child: _CaptureCard(quote: _captureQuote),
          ),
          IntroFlowRevealArrow(visible: _showArrow),
          IntroFlowRevealItem(
            visible: _showOutputCard,
            duration: _cardRevealDuration,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.06),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              child: _OutputCard(
                key: ValueKey(_selected),
                format: _selected,
              ),
            ),
          ),
          IntroFlowRevealItem(
            visible: _showChips,
            duration: _cardRevealDuration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: IntroMetrics.rewriteChipGap(context)),
                _FormatChipRow(
                  selected: _selected,
                  onSelected: _onFormatSelected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureCard extends StatelessWidget {
  const _CaptureCard({required this.quote});

  final String quote;

  @override
  Widget build(BuildContext context) {
    return _IntroFlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CapsLabel('ONE CAPTURE'),
          SizedBox(height: IntroMetrics.captureInnerGap(context)),
          Text(
            quote,
            style: _quoteStyle(context),
          ),
        ],
      ),
    );
  }
}

class _OutputCard extends StatelessWidget {
  const _OutputCard({super.key, required this.format});

  final IntroRewriteFormat format;

  @override
  Widget build(BuildContext context) {
    return _IntroFlowCard(
      child: switch (format) {
        IntroRewriteFormat.meetingNotes => _MeetingNotesBody(
          label: 'MEETING NOTES',
        ),
        IntroRewriteFormat.todo => const _TodoBody(),
        IntroRewriteFormat.delegationNote => const _DelegationBody(),
        IntroRewriteFormat.email => const _EmailBody(),
      },
    );
  }
}

class _MeetingNotesBody extends StatelessWidget {
  const _MeetingNotesBody({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CapsLabel(label),
        SizedBox(height: IntroMetrics.captureSectionGap(context)),
        const _SectionHeading('Summary'),
        SizedBox(height: 4 * IntroMetrics.h(context)),
        const _BulletText('Proposal due tomorrow'),
        const _BulletText('Pricing review before Monday'),
        SizedBox(height: IntroMetrics.captureSectionGap(context)),
        const _SectionHeading('Action Items'),
        SizedBox(height: IntroMetrics.captureActionItemsLabelGap(context)),
        const _BulletText('Review Proposal'),
      ],
    );
  }
}

class _TodoBody extends StatelessWidget {
  const _TodoBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CapsLabel('TO-DO'),
        SizedBox(height: IntroMetrics.captureSectionGap(context)),
        const _ChecklistRow('Review proposal before client call'),
        const _ChecklistRow('Confirm pricing with team'),
        const _ChecklistRow('Follow up with Rahul on timeline'),
      ],
    );
  }
}

class _DelegationBody extends StatelessWidget {
  const _DelegationBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CapsLabel('DELEGATION NOTE'),
        SizedBox(height: IntroMetrics.captureSectionGap(context)),
        Text(
          'Please review the revised proposal and pricing before '
          'Monday\'s client call. Flag any changes needed by EOD tomorrow.',
          style: _bodyStyle(context),
        ),
      ],
    );
  }
}

class _EmailBody extends StatelessWidget {
  const _EmailBody();

  @override
  Widget build(BuildContext context) {
    final body = _bodyStyle(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CapsLabel('EMAIL'),
        SizedBox(height: IntroMetrics.captureSectionGap(context)),
        Text(
          'Subject: Proposal review before Monday\'s call',
          style: body.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: IntroMetrics.captureInnerGap(context)),
        Text('Hi Rahul,', style: body),
        SizedBox(height: 4 * IntroMetrics.h(context)),
        Text(
          'Following up on the proposal — could you send the revised version '
          'tomorrow? I\'ll review pricing before our client call on Monday.',
          style: body,
        ),
        SizedBox(height: 4 * IntroMetrics.h(context)),
        Text('Thanks,\nAlex', style: body),
      ],
    );
  }
}

class _FormatChipRow extends StatelessWidget {
  const _FormatChipRow({
    required this.selected,
    required this.onSelected,
  });

  final IntroRewriteFormat selected;
  final ValueChanged<IntroRewriteFormat> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: IntroMetrics.rewriteChipSpacing(context),
          runSpacing: IntroMetrics.rewriteChipSpacing(context),
          children: [
            _FormatChip(
              label: 'MEETING NOTES',
              isSelected: selected == IntroRewriteFormat.meetingNotes,
              onTap: () => onSelected(IntroRewriteFormat.meetingNotes),
            ),
            _FormatChip(
              label: 'TO-DO',
              isSelected: selected == IntroRewriteFormat.todo,
              onTap: () => onSelected(IntroRewriteFormat.todo),
            ),
            _FormatChip(
              label: 'DELEGATION NOTE',
              isSelected: selected == IntroRewriteFormat.delegationNote,
              onTap: () => onSelected(IntroRewriteFormat.delegationNote),
            ),
          ],
        ),
        SizedBox(height: IntroMetrics.rewriteChipSpacing(context)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _FormatChip(
              label: 'EMAIL',
              isSelected: selected == IntroRewriteFormat.email,
              onTap: () => onSelected(IntroRewriteFormat.email),
            ),
            SizedBox(width: 8 * IntroMetrics.w(context)),
            Text(
              '+ 12 rewriting options',
              style: AppTextTheme.caption.copyWith(
                fontSize: IntroMetrics.rewriteOptionsFontSize(context),
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = IntroMetrics.rewriteChipRadius(context);
    final fontSize = IntroMetrics.rewriteChipFontSize(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: IntroMetrics.rewriteChipPaddingH(context),
          vertical: IntroMetrics.rewriteChipPaddingV(context),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardGrey : _chipUnselectedFill,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderGrey,
            width: IntroMetrics.captureCardBorderWidth(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check_rounded,
                size: IntroMetrics.rewriteChipIconSize(context),
                color: AppColors.primary,
              ),
              SizedBox(width: 6 * IntroMetrics.w(context)),
            ],
            Text(
              label,
              style: AppTextTheme.caption.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: isSelected ? AppColors.primary : AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroFlowCard extends StatelessWidget {
  const _IntroFlowCard({required this.child});

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

class _CapsLabel extends StatelessWidget {
  const _CapsLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextTheme.caption.copyWith(
        fontSize: IntroMetrics.rewriteCardHeaderFontSize(context),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.primary,
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextTheme.body2.copyWith(
        fontSize: IntroMetrics.rewriteCardBodyFontSize(context),
        fontWeight: FontWeight.w400,
        color: AppColors.textBlack,
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4 * IntroMetrics.h(context)),
      child: Text('- $text', style: _bulletStyle(context)),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final boxSize = IntroMetrics.captureCheckboxSize(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 6 * IntroMetrics.h(context)),
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
          Expanded(child: Text(text, style: _bodyStyle(context))),
        ],
      ),
    );
  }
}

TextStyle _quoteStyle(BuildContext context) {
  return AppTextTheme.body2.copyWith(
    fontSize: IntroMetrics.rewriteCardBodyFontSize(context),
    height: 1.35,
    color: AppColors.textGrey,
  );
}

TextStyle _bodyStyle(BuildContext context) {
  return AppTextTheme.body2.copyWith(
    fontSize: IntroMetrics.rewriteCardBodyFontSize(context),
    height: 1.35,
    color: AppColors.textBlack,
  );
}

TextStyle _bulletStyle(BuildContext context) {
  return AppTextTheme.body2.copyWith(
    fontSize: IntroMetrics.rewriteCardBodyFontSize(context),
    height: 1.35,
    color: AppColors.textGrey,
  );
}
