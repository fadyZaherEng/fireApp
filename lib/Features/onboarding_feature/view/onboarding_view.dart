import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/routes.dart';
import '../../../core/utils/constants/image_strings.dart';
import '../../../core/services/shared_pref/shared_pref.dart';
import '../../../core/services/shared_pref/pref_keys.dart';

import '../models/onboarding_page.dart';
import '../widgets/page_indicator.dart';
import '../widgets/sheet_handle.dart';
import '../widgets/action_button.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  AppLocalizations get _localizations => AppLocalizations.of(context);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToNextPage() {
    if (_currentPage < 2) {
      final nextPage = _currentPage + 1;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    // Mark onboarding as complete
    SharedPref().setBool(PrefKeys.isOnboardingComplete, true);
    Navigator.pushReplacementNamed(context, Routes.loginPhone);
  }

  @override
  Widget build(BuildContext context) {
    final List<OnboardingPage> pages = [
      OnboardingPage(
        icon: TImages.permitIcon,
        titleKey: 'permitIssuanceTitle',
        descriptionKey: 'permitIssuanceDescription',
        buttonColor: const Color(0xFFD32F2F),
        route: Routes.home,
      ),
      OnboardingPage(
        icon: TImages.contractIcon,
        titleKey: 'maintenanceContractTitle',
        descriptionKey: 'maintenanceContractDescription',
        buttonColor: const Color(0xFFD32F2F),
        route: Routes.home,
      ),
      OnboardingPage(
        icon: TImages.extinguisherIcon,
        titleKey: 'extinguisherMaintenanceTitle',
        descriptionKey: 'extinguisherMaintenanceDescription',
        buttonColor: const Color(0xFFD32F2F),
        route: Routes.home,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Background PageView
              PageView.builder(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: _onPageChanged,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    pages[index].icon,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),

              // Content Sheet - Static with animated content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildContentSheet(constraints, pages),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContentSheet(
      BoxConstraints constraints, List<OnboardingPage> pages) {
    return Container(
      height: 280.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 15.h),
          const SheetHandle(),
          SizedBox(height: 16.h),

          // Static content area that only updates data
          Expanded(
            child: _buildPageContent(pages[_currentPage]),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(OnboardingPage page) {
    // Get localized text from translation keys properly
    final String title = _localizations.translate(page.titleKey);
    final String description = _localizations.translate(page.descriptionKey);
    final String buttonText = _localizations.translate('continueButton');

    // Wrap in SingleChildScrollView to handle overflow
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with fade transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                title,
                key: ValueKey('title_$_currentPage'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  color: const Color(0xFF1E1E1E),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(height: 12.h),

            // Description with fade transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                description,
                key: ValueKey('description_$_currentPage'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: const Color(0xFF444444),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(height: 16.h),

            // Progress indicators
            PageIndicator(
              currentPage: _currentPage,
              pageCount: 3,
              activeColor: page.buttonColor,
            ),

            SizedBox(height: 16.h),

            // Action button with animated color
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: ActionButton(
                key: ValueKey('button_$_currentPage'),
                text: buttonText,
                color: page.buttonColor,
                onPressed: _navigateToNextPage,
                height: 45,
              ),
            ),

            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
