import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../data/models/certificate_models.dart';
import 'provider_choice_buttons.dart';
import 'service_provider_dropdown.dart';
import 'selected_provider_info.dart';
import 'branch_selector.dart';
import 'section_title.dart';

class ServiceProviderSection extends StatelessWidget {
  final bool wantsProvider;
  final ServiceProvider? selectedProvider;
  final List<ServiceProvider> providers;
  final Function(bool) onProviderChoiceChanged;
  final Function(ServiceProvider?) onProviderChanged;
  final AppLocalizations localizations;
  final bool isLoadingProviders;

  // Branch selection parameters
  final List<Branch> branches;
  final String selectedBranch;
  final Function(String?) onBranchChanged;

  const ServiceProviderSection({
    super.key,
    required this.wantsProvider,
    required this.selectedProvider,
    required this.providers,
    required this.onProviderChoiceChanged,
    required this.onProviderChanged,
    required this.localizations,
    required this.branches,
    required this.selectedBranch,
    required this.onBranchChanged,
    this.isLoadingProviders = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section Title
        Row(
          children: [
            Text(
              localizations.translate('serviceProviderSelection'),
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 18.sp,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          localizations.translate('wantSpecificProvider'),
          style: TextStyle(
            fontFamily: 'Almarai',
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 16.h),

        // Yes/No Selection
        ProviderChoiceButtons(
          wantsProvider: wantsProvider,
          onSelectionChanged: onProviderChoiceChanged,
          localizations: localizations,
        ),
        SizedBox(height: 20.h),

        // Branch Selection (after yes/no buttons)
        SectionTitle(title: localizations.translate('selectBranch')),
        SizedBox(height: 12.h),
        BranchSelector(
          branches: branches,
          selectedBranch: selectedBranch,
          onBranchChanged: onBranchChanged,
          localizations: localizations,
        ),
        SizedBox(height: 20.h),

        // Service Provider Dropdown - Show only if user chose "Yes"
        if (wantsProvider) ...[
          if (isLoadingProviders)
            Container(
              height: 50.h,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                color: AppColors.primaryRed,
              ),
            )
          else
            ServiceProviderDropdown(
              providers: providers,
              selectedProvider: selectedProvider,
              onProviderChanged: onProviderChanged,
              localizations: localizations,
            ),
          SizedBox(height: 20.h),
        ],

        // Show selected provider info if one was chosen
        if (selectedProvider != null) ...[
          SelectedProviderInfo(
            provider: selectedProvider!,
            localizations: localizations,
          ),
          SizedBox(height: 20.h),
        ],
      ],
    );
  }
}
