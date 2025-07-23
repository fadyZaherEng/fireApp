import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../core/localization/app_localizations.dart';

class VisitsPerYearSelector extends StatelessWidget {
  final int selectedVisits;
  final Function(int) onVisitsChanged;
  final AppLocalizations localizations;

  const VisitsPerYearSelector({
    super.key,
    required this.selectedVisits,
    required this.onVisitsChanged,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final visits = [2, 4, 6, 12];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: visits.map((visit) {
          final isSelected = selectedVisits == visit;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: GestureDetector(
                onTap: () => onVisitsChanged(visit),
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primaryRed : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryRed
                          : AppColors.borderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      visit.toString(),
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.blackTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
