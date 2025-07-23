import 'package:flutter/material.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.paddingMedium,
        left: AppSizes.paddingLarge,
        right: AppSizes.paddingLarge,
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.primaryBlue,
                size: AppSizes.iconSizeLarge,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSizes.paddingMedium),
              child: Text(
                localizations.translate('addEmployees'),
                style: AppTextStyles.appBarTitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
