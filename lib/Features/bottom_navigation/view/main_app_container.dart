import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/di/dependency_injection.dart';
import '../../home_feature/data/services/home_api_service.dart';
import '../../home_feature/cubit/home_cubit.dart';
import '../../home_feature/cubit/home_states.dart';
import '../../home_feature/view/home_view.dart';
import '../../receive_offers_feature/view/receive_offers_view.dart';
import '../../maintenance_schedule_feature/view/maintenance_schedule_view.dart';
import '../../in_progress_feature/view/in_progress_view.dart';
import 'bottom_navigation_bar.dart';

class MainAppContainer extends StatefulWidget {
  const MainAppContainer({super.key});

  @override
  State<MainAppContainer> createState() => _MainAppContainerState();
}

class _MainAppContainerState extends State<MainAppContainer> {
  int _selectedTab = 0;
  late PageController _pageController;
  AppLocalizations get _localizations => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return BlocProvider(
      create: (context) =>
          HomeCubit(sl<HomeApiService>())..checkAuthentication(),
      child: Scaffold(
        backgroundColor: const Color(0xFFEDF2FA),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFB60000),
                ),
              );
            }

            if (state is HomeNotAuthenticated) {
              return _buildNotAuthenticatedMessage(isRTL);
            }

            if (state is HomeError) {
              return _buildErrorMessage(state.message, isRTL);
            }
            if (state is HomeAuthCheckSuccess) {
              // If status is "Complete_Register", force user to maintenance schedule tab but show bottom nav
              if (state.status == "Complete_Register" &&
                  !state.isOnboardingComplete) {
                return _buildMainNavigation(state, false, isRTL);
              }
            }

            if (state is HomeCompleteRegistration) {
              return _buildMainNavigation(state, true, isRTL);
            }

            return _buildMainNavigation(null, true, isRTL);
          },
        ),
      ),
    );
  }

  Widget _buildMainNavigation(dynamic state, bool canNavigate, bool isRTL) {
    // If navigation is restricted, force to maintenance schedule tab
    if (!canNavigate) {
      _selectedTab = 2;
    }

    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index) {
          if (canNavigate) {
            setState(() {
              _selectedTab = index;
            });
          } else {
            // Force back to maintenance schedule if navigation is restricted
            if (index != 2) {
              Future.delayed(Duration.zero, () {
                _pageController.animateToPage(
                  2,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            }
          }
        },
        children: [
          state?.status == "Complete_Register"
              ? MaintenanceScheduleView()
              : HomeView(),
          ReceiveOffersView(),
          MaintenanceScheduleView(),
          InProgressView(),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedTab,
        onTap: (index) {
          if (canNavigate) {
            setState(() {
              _selectedTab = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            if (index == 2) {
              setState(() {
                _selectedTab = 2;
              });
              _pageController.animateToPage(
                2,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        },
        isRTL: isRTL,
        canNavigate: canNavigate,
      ),
    );
  }

  Widget _buildNotAuthenticatedMessage(bool isRTL) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64.sp,
                color: const Color(0xFFB60000),
              ),
              SizedBox(height: 16.h),
              Text(
                _localizations.translate('notAuthenticated'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF444444),
                  fontFamily: isRTL ? 'Almarai' : 'Poppins',
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _localizations.translate('pleaseLoginAgain'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF666666),
                  fontFamily: isRTL ? 'Almarai' : 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String message, bool isRTL) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: const Color(0xFFB60000),
              ),
              SizedBox(height: 16.h),
              Text(
                _localizations.translate('error'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF444444),
                  fontFamily: isRTL ? 'Almarai' : 'Poppins',
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF666666),
                  fontFamily: isRTL ? 'Almarai' : 'Poppins',
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  context.read<HomeCubit>().refreshUserStatus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB60000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  _localizations.translate('retry'),
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: isRTL ? 'Almarai' : 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
