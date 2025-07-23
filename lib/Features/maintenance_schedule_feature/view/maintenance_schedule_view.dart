import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/routes.dart';
import '../../home_feature/cubit/home_cubit.dart';
import '../../home_feature/cubit/home_states.dart';

class MaintenanceScheduleView extends StatelessWidget {
  const MaintenanceScheduleView({super.key});
  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final localizations = AppLocalizations.of(context);

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeAuthCheckSuccess &&
            state.status == "Complete_Register" &&
            !state.isOnboardingComplete) {
          return _buildBlockingScreen(localizations, isRTL, state, context);
        }

        return _buildSimpleMaintenancePage(localizations, isRTL);
      },
    );
  }

  Widget _buildBlockingScreen(AppLocalizations localizations, bool isRTL,
      HomeAuthCheckSuccess state, BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFEDF2FA),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                margin: EdgeInsets.only(bottom: 24.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE6F4),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Sad emoji
                    Image.asset(
                      'assets/images/sad_emoji.png',
                      width: 69.w,
                      height: 69.h,
                    ),
                    SizedBox(height: 12.h),
                    // Warning text
                    Text(
                      localizations.translate('cannotReceiveRequestsMessage'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF444444),
                        fontWeight: FontWeight.w500,
                        fontFamily: isRTL ? 'Almarai' : 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Action buttons based on onboarding status
              _buildActionButtons(state, isRTL, localizations, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(HomeAuthCheckSuccess state, bool isRTL,
      AppLocalizations localizations, BuildContext context) {
    List<Widget> buttons = [];

    // Add employees button if not completed
    buttons.add(_buildActionButton(
      text: localizations.translate('addEmployees'),
      onPressed: () => _navigateToAddEmployees(context),
      isRTL: isRTL,
    ));

    // Add branches button if not completed

    buttons.add(_buildActionButton(
      text: localizations.translate('addBranches'),
      onPressed: () => _navigateToAddBranches(context),
      isRTL: isRTL,
    ));

    buttons.add(_buildActionButton(
      text: localizations.translate('termsAndConditions'),
      onPressed: () => _navigateToTermsAndConditions(context),
      isRTL: isRTL,
    ));

    return Column(
      children: buttons
          .map((button) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: button,
              ))
          .toList(),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    required bool isRTL,
  }) {
    return SizedBox(
      width: 240.w,
      height: 44.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: Color(0xFFB60000),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          backgroundColor: Color(0xFFB60000).withOpacity(0.1),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFB60000),
            fontFamily: isRTL ? 'Almarai' : 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleMaintenancePage(
      AppLocalizations localizations, bool isRTL) {
    return SafeArea(
      child: Container(
        color: const Color(0xFFEDF2FA),
        child: Center(
          child: Text(
            'maintenance',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF444444),
              fontFamily: isRTL ? 'Almarai' : 'Poppins',
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAddEmployees(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.addEmployees);
  }

  void _navigateToAddBranches(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.branchDetails);
  }

  void _navigateToTermsAndConditions(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.termsAndConditions);
  }
}
