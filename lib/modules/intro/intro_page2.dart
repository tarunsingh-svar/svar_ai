import 'package:flutter/material.dart';

import 'widgets/intro_capture_flow.dart';
import 'widgets/intro_metrics.dart';
import 'widgets/intro_shared.dart';

class IntroScreen2 extends StatelessWidget {
  const IntroScreen2({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final headlineGap = IntroMetrics.captureFlowToHeadlineGap(context);
              final flowHeight = constraints.maxHeight - headlineGap;

              return Column(
                children: [
                  SizedBox(
                    height: flowHeight.clamp(0, constraints.maxHeight),
                    width: constraints.maxWidth,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: IntroCaptureFlow(isActive: isActive),
                      ),
                    ),
                  ),
                  SizedBox(height: headlineGap),
                ],
              );
            },
          ),
        ),
        const IntroTextBlock(
          headlineBlue: 'Just speak',
          headlineBlack: 'Svar does the rest.',
          body: 'Turn a voice note into something you can actually use.',
        ),
      ],
    );
  }
}
