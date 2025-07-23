import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/localization/app_localizations.dart';

class SystemTypeSelector extends StatelessWidget {
  final String selectedSystemType;
  final Function(String?)? onSystemTypeChanged;
  final AppLocalizations localizations;
  final bool enabled;

  const SystemTypeSelector({
    super.key,
    required this.selectedSystemType,
    required this.onSystemTypeChanged,
    required this.localizations,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final systemTypes = [
      localizations.translate('systemTypeNormal'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: systemTypes.contains(selectedSystemType)
            ? selectedSystemType
            : systemTypes[0],
        decoration: InputDecoration(
          hintText: localizations.translate('selectSystemTypeHint'),
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
        items: systemTypes.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(
              type,
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 14.sp,
              ),
            ),
          );
        }).toList(),
        onChanged: enabled
            ? onSystemTypeChanged
            : null, // Disable dropdown if not enabled
      ),
    );
  }
}
