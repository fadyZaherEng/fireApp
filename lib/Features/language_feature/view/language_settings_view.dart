import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/cubit/locale_cubit.dart';
import '../../../core/services/shared_pref/pref_keys.dart';
import '../../../core/services/shared_pref/shared_pref.dart';

class LanguageSettingsView extends StatefulWidget {
  const LanguageSettingsView({super.key});

  @override
  State<LanguageSettingsView> createState() => _LanguageSettingsViewState();
}

class _LanguageSettingsViewState extends State<LanguageSettingsView> {
  String? selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  void _loadCurrentLanguage() {
    final currentLanguage =
        SharedPref().getString(PrefKeys.languageCode) ?? 'en';
    setState(() {
      selectedLanguage = currentLanguage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isArabic = localizations.isArabic();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          localizations.translate('languageSettings'),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
            fontFamily: 'Almarai',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.primaryBlue,
              size: 24.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              localizations.translate('selectPreferredLanguage'),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
                fontFamily: 'Almarai',
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            ),

            SizedBox(height: 20.h),

            // Language Options
            _buildLanguageOption(
              title: 'العربية',
              subtitle: 'Arabic',
              languageCode: 'ar',
              isSelected: selectedLanguage == 'ar',
            ),

            SizedBox(height: 16.h),

            _buildLanguageOption(
              title: 'English',
              subtitle: 'الإنجليزية',
              languageCode: 'en',
              isSelected: selectedLanguage == 'en',
            ),

            const Spacer(),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed:
                    selectedLanguage != null ? _applyLanguageChange : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  localizations.translate('applyChanges'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Info Text
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.primaryBlue,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      localizations.translate('languageChangeImmediate'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primaryBlue,
                        fontFamily: 'Almarai',
                      ),
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      textDirection:
                          isArabic ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String subtitle,
    required String languageCode,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = languageCode;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Language Flag/Icon
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue.withOpacity(0.1)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  languageCode == 'ar' ? '🇸🇦' : '🇺🇸',
                  style: TextStyle(fontSize: 20.sp),
                ),
              ),
            ),

            SizedBox(width: 16.w),

            // Language Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : const Color(0xFF333333),
                      fontFamily: languageCode == 'ar' ? 'Almarai' : 'Poppins',
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF666666),
                      fontFamily: languageCode == 'ar' ? 'Poppins' : 'Almarai',
                    ),
                  ),
                ],
              ),
            ),

            // Selection Indicator
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color:
                  isSelected ? AppColors.primaryBlue : const Color(0xFFE0E0E0),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _applyLanguageChange() {
    if (selectedLanguage == null) return;

    // Save language preference
    SharedPref().setString(PrefKeys.appLanguage, selectedLanguage!);
    SharedPref().setString(PrefKeys.languageCode, selectedLanguage!);
    SharedPref().setBool(PrefKeys.isLanguageSelected, true);

    // Apply language change immediately
    context.read<LocaleCubit>().changeLanguage(selectedLanguage!);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selectedLanguage == 'ar'
              ? 'تم تغيير اللغة بنجاح'
              : 'Language changed successfully',
          style: const TextStyle(fontFamily: 'Almarai'),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
}
