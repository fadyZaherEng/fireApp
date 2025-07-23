import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../data/models/certificate_models.dart';

class ServiceProviderDropdown extends StatelessWidget {
  final List<ServiceProvider> providers;
  final ServiceProvider? selectedProvider;
  final Function(ServiceProvider?) onProviderChanged;
  final AppLocalizations localizations;

  const ServiceProviderDropdown({
    super.key,
    required this.providers,
    required this.selectedProvider,
    required this.onProviderChanged,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.translate('selectServiceProvider'),
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
          child: DropdownButtonFormField<ServiceProvider>(
            value: selectedProvider,
            decoration: InputDecoration(
              hintText: localizations.translate('serviceProviderHint'),
              hintStyle: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              suffixIcon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
            ),
            isExpanded: true,
            items: providers.map((provider) {
              final displayName =
                  provider.nameAr.isNotEmpty ? provider.nameAr : provider.name;

              return DropdownMenuItem<ServiceProvider>(
                value: provider,
                child: Text(
                  displayName,
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 14.sp,
                    color: AppColors.blackTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onProviderChanged,
          ),
        ),
      ],
    );
  }
}
