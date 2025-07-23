import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../core/localization/app_localizations.dart';

class ProviderChoiceButtons extends StatelessWidget {
  final bool wantsProvider;
  final Function(bool) onSelectionChanged;
  final AppLocalizations localizations;

  const ProviderChoiceButtons({
    super.key,
    required this.wantsProvider,
    required this.onSelectionChanged,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.2)),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // No Button
          Expanded(
            child: ElevatedButton(
              onPressed: () => onSelectionChanged(false),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    !wantsProvider ? AppColors.primaryRed : Colors.white,
                foregroundColor:
                    !wantsProvider ? Colors.white : AppColors.primaryRed,
                elevation: 0,
                side: BorderSide(
                  color: AppColors.primaryRed,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                localizations.translate('no'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Yes Button
          Expanded(
            child: ElevatedButton(
              onPressed: () => onSelectionChanged(true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    wantsProvider ? AppColors.primaryRed : Colors.white,
                foregroundColor:
                    wantsProvider ? Colors.white : AppColors.primaryRed,
                elevation: 0,
                side: BorderSide(
                  color: AppColors.primaryRed,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Text(
                localizations.translate('yes'),
                style: TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
