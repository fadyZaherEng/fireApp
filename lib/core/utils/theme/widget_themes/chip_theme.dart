import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class TChipTheme {
  TChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: CColors.textGrey.withOpacity(0.4),
    labelStyle: const TextStyle(color: CColors.textDark),
    selectedColor: CColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: CColors.textLight,
  );

  static ChipThemeData darkChipTheme = const ChipThemeData(
    disabledColor: CColors.dark,
    labelStyle: TextStyle(color: CColors.textLight),
    selectedColor: CColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: CColors.textLight,
  );
}
