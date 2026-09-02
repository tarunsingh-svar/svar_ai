import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Vector Svar mark — the bar-S on a squircle — drawn at any size.
///
/// Geometry is traced from the brand icon (13 vertical rounded bars forming
/// an S) so it stays sharp on every density instead of scaling a PNG.
class SvarMark extends StatelessWidget {
  const SvarMark({super.key, required this.size, this.showShadow = true});

  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SvarMarkPainter(showShadow: showShadow),
      ),
    );
  }
}

class _BarSeg {
  const _BarSeg(this.cx, this.top, this.bottom);

  /// All values are 0–1 of the 272px source canvas.
  final double cx;
  final double top;
  final double bottom;
}

/// Measured from the 272×272 source icon. Bars are ~5px wide on that canvas.
const _bars = <_BarSeg>[
  _BarSeg(71 / 272, 96 / 272, 111 / 272),
  _BarSeg(71 / 272, 169 / 272, 180 / 272),
  _BarSeg(82 / 272, 89 / 272, 122 / 272),
  _BarSeg(82 / 272, 163 / 272, 187 / 272),
  _BarSeg(93 / 272, 76 / 272, 134 / 272),
  _BarSeg(93 / 272, 169 / 272, 199 / 272),
  _BarSeg(103.5 / 272, 67 / 272, 141 / 272),
  _BarSeg(103.5 / 272, 163 / 272, 205 / 272),
  _BarSeg(114 / 272, 61 / 272, 145 / 272),
  _BarSeg(114 / 272, 173 / 272, 210 / 272),
  _BarSeg(125 / 272, 55 / 272, 86 / 272),
  _BarSeg(125 / 272, 112 / 272, 150 / 272),
  _BarSeg(125 / 272, 185 / 272, 216 / 272),
  _BarSeg(135.5 / 272, 48 / 272, 83 / 272),
  _BarSeg(135.5 / 272, 116 / 272, 155 / 272),
  _BarSeg(135.5 / 272, 188 / 272, 223 / 272),
  _BarSeg(146 / 272, 55 / 272, 86 / 272),
  _BarSeg(146 / 272, 121 / 272, 159 / 272),
  _BarSeg(146 / 272, 185 / 272, 216 / 272),
  _BarSeg(157 / 272, 61 / 272, 98 / 272),
  _BarSeg(157 / 272, 126 / 272, 210 / 272),
  _BarSeg(168 / 272, 66 / 272, 108 / 272),
  _BarSeg(168 / 272, 130 / 272, 205 / 272),
  _BarSeg(178 / 272, 72 / 272, 102 / 272),
  _BarSeg(178 / 272, 137 / 272, 197 / 272),
  _BarSeg(189 / 272, 84 / 272, 108 / 272),
  _BarSeg(189 / 272, 149 / 272, 186 / 272),
  _BarSeg(200 / 272, 92 / 272, 103 / 272),
  _BarSeg(200 / 272, 160 / 272, 177 / 272),
];

class _SvarMarkPainter extends CustomPainter {
  const _SvarMarkPainter({required this.showShadow});

  final bool showShadow;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(size.width * 0.34),
    );
    final path = shape.getOuterPath(rect);

    if (showShadow) {
      canvas.drawShadow(path, const Color(0x402563EB), 16, false);
    }

    final fill = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.15, -0.2),
        radius: 1.05,
        colors: [Color(0xFF3B82F6), AppColors.primary, Color(0xFF1D4ED8)],
        stops: [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawPath(path, fill);

    canvas.save();
    canvas.clipPath(path);

    final barW = size.width * (5.3 / 272);
    final radius = Radius.circular(barW / 2);
    final barPaint = Paint()
      ..color = Colors.white
      ..isAntiAlias = true;

    for (final seg in _bars) {
      final cx = seg.cx * size.width;
      final top = seg.top * size.height;
      final bottom = seg.bottom * size.height;
      final rrect = RRect.fromLTRBR(
        cx - barW / 2,
        top,
        cx + barW / 2,
        bottom,
        radius,
      );
      canvas.drawRRect(rrect, barPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
