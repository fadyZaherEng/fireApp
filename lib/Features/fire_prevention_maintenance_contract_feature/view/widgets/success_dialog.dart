import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../core/localization/app_localizations.dart';

class SuccessDialog extends StatelessWidget {
  final AppLocalizations localizations;
  final VoidCallback onConfirm;

  const SuccessDialog({
    super.key,
    required this.localizations,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              localizations.translate('requestSubmittedSuccessfully'),
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.blackTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              localizations.translate('contactSoonMessage'),
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 14.sp,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  localizations.translate('backToHome'),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, AppLocalizations localizations,
      VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        localizations: localizations,
        onConfirm: onConfirm,
      ),
    );
  }
}
