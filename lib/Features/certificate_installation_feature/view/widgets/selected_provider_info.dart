import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../data/models/certificate_models.dart';

class SelectedProviderInfo extends StatelessWidget {
  final ServiceProvider provider;
  final AppLocalizations localizations;

  const SelectedProviderInfo({
    super.key,
    required this.provider,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.business,
              color: AppColors.primaryBlue,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.translate('selectedServiceProvider'),
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  provider.nameAr.isNotEmpty ? provider.nameAr : provider.name,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 14.sp,
                    color: AppColors.blackTextColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: AppColors.primaryBlue,
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}
