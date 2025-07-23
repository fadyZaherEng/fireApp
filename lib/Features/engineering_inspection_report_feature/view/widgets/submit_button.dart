import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../core/localization/app_localizations.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final AppLocalizations localizations;

  const SubmitButton({
    super.key,
    required this.onPressed,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          localizations.translate('submitRequest'),
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}
