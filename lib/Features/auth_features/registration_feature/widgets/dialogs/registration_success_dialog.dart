import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../../../../core/routing/routes.dart';

class RegistrationSuccessDialog extends StatelessWidget {
  const RegistrationSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 304.w,
          height: 332.h,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon (Checkmark in Circle)
                Container(
                  width: 90.w,
                  height: 90.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00B44B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: const Color(0xFFFFFFFF),
                    size: 50.sp,
                  ),
                ),

                SizedBox(height: 16.h),

                // Title Text
                Text(
                  localizations.translate('registrationSuccessTitle'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF003F7D),
                    fontFamily: 'Almarai',
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),

                SizedBox(height: 8.h),

                // Body Text / Description
                Text(
                  localizations.translate('registrationSuccessMessage'),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF888888),
                    fontFamily: 'Almarai',
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const RegistrationSuccessDialog(),
    );

    // Auto-navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _handleNavigationAfterSuccess(context);
    });
  }

  static void _handleNavigationAfterSuccess(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop(); // Close dialog
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.home,
      (route) => false,
    );
  }
}
