import 'package:flutter/material.dart';

import 'widgets/intro_metrics.dart';
import 'widgets/intro_rewrite_flow.dart';
import 'widgets/intro_shared.dart';

class IntroScreen3 extends StatelessWidget {
  const IntroScreen3({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: IntroRewriteFlow(isActive: isActive),
                  ),
                ),
                SizedBox(
                  height: IntroMetrics.rewriteChipToHeadlineGap(context),
                ),
              ],
            ),
          ),
        ),
        const IntroTextBlock(
          headlineBlue: 'One thought.',
          headlineBlack: 'Many ways to use it.',
          body:
              'Svar doesn\'t just capture what you said. '
              'It turns it into what you need.',
        ),
      ],
    );
  }
}
