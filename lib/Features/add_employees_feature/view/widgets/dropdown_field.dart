import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';

class DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const DropdownField({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.fieldLabel.copyWith(
                fontFamily: 'Almarai',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                height: 22 / 16,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingSmall),
        Container(
          width: 312,
          height: 45.h,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.inputBorderColor,
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                left: 15,
              ),
            ),
            style: AppTextStyles.inputText.copyWith(
              fontFamily: 'Almarai',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.0,
              letterSpacing: 0,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primaryBlue,
              size: AppSizes.iconSizeMedium,
            ),
            alignment: Alignment.center,
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                alignment: Alignment.centerRight,
                child: Text(localizations.translate(value)),
              );
            }).toList(),
            onChanged: onChanged,
            isDense: true,
          ),
        ),
      ],
    );
  }
}
