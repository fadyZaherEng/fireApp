import 'package:flutter/material.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';

class PhoneField extends StatelessWidget {
  final int index;
  final TextEditingController phoneController;
  final String selectedCountry;
  final List<Map<String, String>> countries;
  final Function(int) showCountryPicker;
  final Function() getSelectedCountryData;

  const PhoneField({
    Key? key,
    required this.index,
    required this.phoneController,
    required this.selectedCountry,
    required this.countries,
    required this.showCountryPicker,
    required this.getSelectedCountryData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final countryData = getSelectedCountryData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Text(
              localizations.translate('employeePhone'),
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
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.inputBorderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Phone number input
              Expanded(
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.inputText,
                  maxLength: 9,
                  decoration: const InputDecoration(
                    hintText: 'XXXXXXXXX',
                    hintStyle: AppTextStyles.hintText,
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.only(
                      top: 14,
                      right: 20,
                      bottom: 14,
                      left: 20,
                    ),
                  ),
                ),
              ),
              // Country flag and code
              GestureDetector(
                onTap: () => showCountryPicker(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMedium),
                  child: Row(
                    children: [
                      Text(
                        countryData['dialCode']!,
                        style: AppTextStyles.phoneCodeText,
                      ),
                      const SizedBox(width: AppSizes.paddingSmall),
                      Text(
                        countryData['flag']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
