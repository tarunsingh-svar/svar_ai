import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import 'intro_page1.dart';
import 'intro_page2.dart';
import 'intro_page3.dart';
import 'widgets/custom_button_intro.dart';

class IntroScreens extends StatefulWidget {
  const IntroScreens({super.key});

  @override
  State<IntroScreens> createState() => _IntroScreensState();
}

class _IntroScreensState extends State<IntroScreens> {
  final PageController _pageController = PageController();
  final RxInt _currentPage = 0.obs;
  final int _totalPages = 3;

  final List<Widget> _pages = const [
    IntroScreen1(),
    IntroScreen2(),
    IntroScreen3(),
  ];

  void _onNextPressed() {
    if (_currentPage.value < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offNamed(AppRoutes.login);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      _currentPage.value = _pageController.page?.round() ?? 0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // -------------------------------
              // Swipable Intro Screens
              // -------------------------------
              Expanded(
                child: PageView(controller: _pageController, children: _pages),
              ),

              // -------------------------------
              // Bottom Section
              // -------------------------------
              Column(
                children: [
                  CustomButtonIntro(text: 'Continue', onTap: _onNextPressed),
                  SizedBox(height: 4.h),
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _totalPages,
                    effect: WormEffect(
                      spacing: 4.w,
                      radius: 2.w,
                      dotWidth: 1.8.w,
                      dotHeight: 1.8.w,
                      dotColor: AppColors.grey400,
                      activeDotColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
