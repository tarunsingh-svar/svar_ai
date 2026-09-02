import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routing/app_routes.dart';
import 'intro_page1.dart';
import 'intro_page2.dart';
import 'intro_page3.dart';
import 'widgets/intro_grid_background.dart';
import 'widgets/intro_metrics.dart';
import 'widgets/intro_progress_indicator.dart';
import 'widgets/intro_shared.dart';

class IntroScreens extends StatefulWidget {
  const IntroScreens({super.key});

  @override
  State<IntroScreens> createState() => _IntroScreensState();
}

class _IntroScreensState extends State<IntroScreens>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _pageProgress = 0;

  late final AnimationController _barFillController;

  static const _totalPages = 3;

  @override
  void initState() {
    super.initState();
    _barFillController = AnimationController(
      vsync: this,
      duration: IntroMetrics.screen1BarFillDuration,
    )..addListener(_onBarTick);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startBarFill(0);
    });
  }

  void _onBarTick() {
    if (mounted) {
      setState(() => _pageProgress = _barFillController.value);
    }
  }

  void _startBarFill(int page) {
    _barFillController.duration = IntroMetrics.barFillDurationForPage(page);
    _barFillController.forward(from: 0);
  }

  void _onPageChanged(int page) {
    _barFillController.stop();

    if (page == 0) {
      _barFillController.value = 0;
      setState(() {
        _currentPage = page;
        _pageProgress = 0;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _currentPage == 0) _startBarFill(0);
      });
      return;
    }

    // Reset before rebuild so the new segment doesn't flash at 100%.
    _barFillController.value = 0;
    setState(() {
      _currentPage = page;
      _pageProgress = 0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _currentPage == page) _startBarFill(page);
    });
  }

  void _onContinue() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _barFillController.removeListener(_onBarTick);
    _barFillController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      IntroScreen1(isActive: _currentPage == 0),
      IntroScreen2(isActive: _currentPage == 1),
      IntroScreen3(isActive: _currentPage == 2),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const IntroGridBackground(),
          SafeArea(
            child: Column(
              children: [
                IntroProgressIndicator(
                  currentPage: _currentPage,
                  currentPageProgress: _pageProgress,
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: pages,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    IntroMetrics.horizontalPadding(context),
                    0,
                    IntroMetrics.horizontalPadding(context),
                    IntroMetrics.bottomPadding(context),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: IntroMetrics.bodyToButtonGap(context)),
                      IntroContinueButton(onTap: _onContinue),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
