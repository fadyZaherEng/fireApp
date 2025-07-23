import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/cubit/locale_cubit.dart';
import '../../../core/routing/routes.dart';
import '../../../core/services/shared_pref/pref_keys.dart';
import '../../../core/services/shared_pref/shared_pref.dart';
import '../../../core/utils/constants/image_strings.dart';

class LanguageSelectionView extends StatefulWidget {
  const LanguageSelectionView({super.key});

  @override
  State<LanguageSelectionView> createState() => _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends State<LanguageSelectionView> {
  String selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: -16.w,
            child: SizedBox(
              width: 408.w,
              height: 527.h,
              child: Image.asset(
                TImages.firefighter,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Bottom Sheet with specific dimensions
          Positioned(
            top: 491.h, // Positioned from top as specified
            left: 0,
            right: 0,
            child: Container(
              width: 375.w,
              height: 321.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Sheet Handle Line
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),

                      // Title - اختر اللغة (Select Language)
                      Row(
                        children: [
                          Text(
                            localizations.translate('selectLanguage'),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      // Language Options
                      _buildLanguageButton(
                        label: localizations.translate('english'),
                        isSelected: selectedLanguage == 'en',
                        onTap: () => _selectLanguage('en'),
                      ),

                      SizedBox(height: 12.h),

                      _buildLanguageButton(
                        label: localizations.translate('arabic'),
                        isSelected: selectedLanguage == 'ar',
                        onTap: () => _selectLanguage('ar'),
                      ),

                      SizedBox(height: 12.h),
                      // Confirm Button
                      Container(
                        width: 345.w,
                        height: 50.h,
                        margin: EdgeInsets.only(top: 10.h),
                        child: ElevatedButton(
                          onPressed: _confirmLanguage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB71C1C),
                            padding: EdgeInsets.only(
                              top: 12.h,
                              right: 120.w,
                              bottom: 12.h,
                              left: 120.w,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Builder(
                            builder: (context) {
                              // Use AppLocalizations to get translated text
                              final String confirmText =
                                  AppLocalizations.of(context)
                                      .translate('confirm');
                              return Text(
                                confirmText,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Add padding for bottom spacing
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 345.w,
        height: 48.h,
        margin: EdgeInsets.only(bottom: 10.h), // Gap between buttons
        padding: EdgeInsets.only(
          top: 12.h,
          right: 120.w,
          bottom: 12.h,
          left: 120.w,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF0F0) : Colors.transparent,
          border: Border.all(
            color:
                isSelected ? const Color(0xFFB71C1C) : const Color(0xFF222222),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24.r), // Updated border radius
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Icon(
                Icons.check,
                color: const Color(0xFFB71C1C),
                size: 15.sp,
              ),
            if (isSelected) SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                color: isSelected
                    ? const Color(0xFFB71C1C)
                    : const Color(0xFF222222),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectLanguage(String language) {
    setState(() {
      selectedLanguage = language;
    });

    // Apply language change immediately to preview
    context.read<LocaleCubit>().changeLanguage(language);
  }

  void _confirmLanguage() {
    // Save language preference
    SharedPref().setBool(PrefKeys.isLanguageSelected, true);
    SharedPref().setString(PrefKeys.appLanguage, selectedLanguage);
    SharedPref().setString(PrefKeys.languageCode, selectedLanguage);

    // Ensure language is updated in the app
    context.read<LocaleCubit>().changeLanguage(selectedLanguage);

    // Navigate to onboarding
    Navigator.pushReplacementNamed(context, Routes.onboarding);
  }
}
