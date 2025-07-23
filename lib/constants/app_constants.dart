import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF1C4587);
  static const Color primaryRed = Color(0xFFBA2D2D);

  // Background Colors
  static const Color backgroundColor = Color(0xFFEAF0F9);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Border Colors
  static const Color borderColor = Color(0xFF1C4587);
  static const Color inputBorderColor = Color(0xFF1C4587);

  // Text Colors
  static const Color primaryTextColor = Color(0xFF1C4587);
  static const Color hintTextColor = Color(0xFF999999);
  static const Color whiteTextColor = Color(0xFFFFFFFF);
  static const Color blackTextColor = Color(0xFF000000);

  // Icon Colors
  static const Color iconColor = Color(0xFF999999);
  static const Color primaryIconColor = Color(0xFF1C4587);

  // iOS Home Indicator
  static const Color homeIndicatorColor =
      Color(0x4D000000); // Black with 30% opacity

  static const Color cardBgColor = Color(0xff363636);
  static const Color cardBgLightColor = Color(0xff999999);
  static const Color colorB58D67 = Color(0xffB58D67);
  static const Color colorE5D1B2 = Color(0xffE5D1B2);
  static const Color colorF9EED2 = Color(0xffF9EED2);
  static const Color colorEFEFED = Color(0xffEFEFED);
}

class AppSizes {
  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 24.0;
  static const double paddingXXLarge = 32.0;
  static const double paddingHuge = 32.0;
  static const double cardHorizontalPadding = 24.0;
  static const double cardWidth = 320.0;
  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;

  // Border Width
  static const double borderWidth = 1.0;
  static const double inputBorderWidth = 1.5;

  // Input Field Heights
  static const double inputFieldHeight = 48.0;
  static const double buttonHeight = 48.0;

  // Profile Image
  static const double profileImageSize = 96.0;
  static const double cameraIconSize = 24.0;
  static const double cameraIconInnerSize = 16.0;

  // Icon Sizes
  static const double iconSizeSmall = 18.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;

  // Font Sizes
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  // Flag Size
  static const double flagWidth = 20.0;
  static const double flagHeight = 14.0;

  // iOS Home Indicator
  static const double homeIndicatorWidth = 135.0;
  static const double homeIndicatorHeight = 5.0;
}

class AppTextStyles {
  static const TextStyle appBarTitle = TextStyle(
    fontSize: AppSizes.fontSizeXLarge,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryTextColor,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontSize: AppSizes.fontSizeSmall,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryTextColor,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: AppSizes.fontSizeMedium,
    color: AppColors.blackTextColor,
  );

  static const TextStyle hintText = TextStyle(
    fontSize: AppSizes.fontSizeMedium,
    color: AppColors.hintTextColor,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: AppSizes.fontSizeMedium,
    fontWeight: FontWeight.bold,
    color: AppColors.whiteTextColor,
  );

  static const TextStyle addMoreText = TextStyle(
    fontSize: AppSizes.fontSizeSmall,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryRed,
  );
  static const TextStyle phoneCodeText = TextStyle(
    fontSize: AppSizes.fontSizeMedium,
    fontWeight: FontWeight.w500,
    color: AppColors.blackTextColor,
  );
}
