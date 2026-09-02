import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import 'svar_mark.dart';

/// Ring radii as a fraction of the hero's side. The outer ring nearly touches
/// the hero bounds, matching the reference where orbits run close to the
/// screen edges.
const _ringRadii = [0.30, 0.39, 0.48];

class _ChipSpec {
  const _ChipSpec(this.label, this.radiusFactor, this.angleDeg, this.tilt);

  final String label;

  /// Fraction of the hero side; matches one of [_ringRadii] so the chip sits
  /// on an orbit line.
  final double radiusFactor;

  /// 0° = right of centre, positive = clockwise (screen y grows down).
  final double angleDeg;

  /// Rotation of the chip itself, in radians.
  final double tilt;
}

const _chips = <_ChipSpec>[
  _ChipSpec('Summarize', 0.48, -118, -0.18),
  _ChipSpec('Audio File', 0.39, -18, 0.14),
  _ChipSpec('PDF', 0.48, 148, -0.16),
  _ChipSpec('Transcription', 0.48, 82, 0.06),
];

/// Hero graphic for the welcome screen: Svar mark, dashed orbits, feature
/// chips positioned on the orbit lines.
class WelcomeHero extends StatelessWidget {
  const WelcomeHero({super.key, required this.logoSize});

  /// Side length of the logo mark (136 px on a 412 px-wide reference).
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);

        return SizedBox(
          width: side,
          height: side,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _OrbitPainter()),
              ),
              SvarMark(size: logoSize),
              for (final chip in _chips)
                Transform.translate(
                  offset: Offset.fromDirection(
                    chip.angleDeg * math.pi / 180,
                    chip.radiusFactor * side,
                  ),
                  child: Transform.rotate(
                    angle: chip.tilt,
                    child: _OrbitChip(label: chip.label),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _OrbitChip extends StatelessWidget {
  const _OrbitChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.38),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTextTheme.body2.copyWith(
          color: AppColors.textBlack,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final shortest = math.min(size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..color = AppColors.primary.withValues(alpha: 0.25)
      ..isAntiAlias = true;

    for (final f in _ringRadii) {
      _dashedCircle(canvas, c, shortest * f, paint);
    }
  }

  void _dashedCircle(Canvas canvas, Offset c, double r, Paint paint) {
    const dash = 14.0;
    const gap = 10.0;
    final circ = 2 * math.pi * r;
    final n = math.max(1, (circ / (dash + gap)).floor());
    final step = (dash + gap) / r;
    final sweep = dash / r;
    // Offset each ring slightly so dashes don't line up into spokes.
    final phase = r * 0.02;
    for (var i = 0; i < n; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        i * step + phase,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
