import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../core/localization/app_localizations.dart';

class DurationInput extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations localizations;
  final bool enabled;

  const DurationInput({
    super.key,
    required this.controller,
    required this.localizations,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Almarai',
          fontSize: 16.sp,
          color: enabled ? AppColors.blackTextColor : AppColors.hintTextColor,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        decoration: InputDecoration(
          hintText: localizations.translate('enterDurationInMonths'),
          hintStyle: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 14.sp,
            color: AppColors.hintTextColor,
          ),
          suffixText: localizations.translate('months'),
          suffixStyle: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 14.sp,
            color: AppColors.primaryTextColor,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return localizations.translate('durationRequired');
          }
          final duration = int.tryParse(value);
          if (duration == null || duration < 1) {
            return localizations.translate('enterValidDuration');
          }
          if (duration > 120) {
            return localizations.translate('durationTooLong');
          }
          return null;
        },
      ),
    );
  }
}
