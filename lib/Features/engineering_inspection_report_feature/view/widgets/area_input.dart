import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/localization/app_localizations.dart';

class AreaInput extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations localizations;
  final bool enabled;

  const AreaInput({
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
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontFamily: 'Almarai',
          fontSize: 14.sp,
        ),
        enabled: enabled,
        decoration: InputDecoration(
          hintText: localizations.translate('areaHint'),
          hintStyle: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey.shade200,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return localizations.translate('areaRequired');
          }
          final area = double.tryParse(value);
          if (area == null || area <= 0) {
            return localizations.translate('areaInvalid');
          }
          return null;
        },
      ),
    );
  }
}
