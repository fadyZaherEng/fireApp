import 'package:flutter/material.dart';
import '../../../../constants/app_constants.dart';

class InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final IconData suffixIcon;

  const InputField({
    Key? key,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.inputBorderColor,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.right,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.hintText,
              suffixIcon: Icon(
                suffixIcon,
                color: AppColors.iconColor,
                size: AppSizes.iconSizeMedium,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(
                top: 14,
                right: 15,
                bottom: 14,
                left: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
