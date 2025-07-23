import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../data/models/certificate_models.dart';

class FireExtinguisherSection extends StatelessWidget {
  final List<FireExtinguisher> extinguishers;
  final AppLocalizations localizations;
  final String title;

  const FireExtinguisherSection({
    super.key,
    required this.extinguishers,
    required this.localizations,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 16.sp,
            color: AppColors.blackTextColor,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
            },
            children: [
              // Table Header
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      localizations.translate('fireExtinguishers'),
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      localizations.translate('count'),
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              // Table Rows
              ...extinguishers.map((extinguisher) {
                return TableRow(
                  decoration: BoxDecoration(
                    border: extinguishers.indexOf(extinguisher) <
                            extinguishers.length - 1
                        ? Border(
                            bottom: BorderSide(color: Colors.grey.shade200))
                        : null,
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        extinguisher
                            .type, // Using the type which now contains the itemName
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 14.sp,
                          color: AppColors.blackTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        extinguisher.count.toString(),
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontSize: 14.sp,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}
