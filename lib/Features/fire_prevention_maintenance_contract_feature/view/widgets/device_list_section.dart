import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../data/models/certificate_models.dart';

class DeviceListSection extends StatelessWidget {
  final List<AlertDevice> devices;
  final AppLocalizations localizations;
  final String title;

  const DeviceListSection({
    super.key,
    required this.devices,
    required this.localizations,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const SizedBox.shrink();
    }

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
                      localizations.translate('alertDevices'),
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
              ...devices.map((device) {
                return TableRow(
                  decoration: BoxDecoration(
                    border: devices.indexOf(device) < devices.length - 1
                        ? Border(
                            bottom: BorderSide(color: Colors.grey.shade200))
                        : null,
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        device
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
                        device.count.toString(),
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
