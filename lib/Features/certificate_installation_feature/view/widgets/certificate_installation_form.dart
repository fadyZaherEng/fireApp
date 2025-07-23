import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../data/models/certificate_models.dart';
import 'service_provider_section.dart';
import 'system_type_selector.dart';
import 'area_input.dart';
import 'device_list_section.dart';
import 'fire_extinguisher_section.dart';
import 'submit_button.dart';
import 'section_title.dart';

class CertificateInstallationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController areaController;
  final List<Branch> branches;
  final String selectedBranch;
  final String selectedSystemType;
  final List<AlertDevice> alertDevices;
  final List<FireExtinguisher> fireExtinguishers;
  final Function(String?) onBranchChanged;
  final Function(String?) onSystemTypeChanged;
  final VoidCallback onSubmit;
  final AppLocalizations localizations;

  // Service Provider related parameters
  final bool wantsProvider;
  final ServiceProvider? selectedProvider;
  final List<ServiceProvider> providers;
  final Function(bool) onProviderChoiceChanged;
  final Function(ServiceProvider?) onProviderChanged;
  final bool isLoadingProviders;
  final bool systemTypeEnabled;
  final bool areaEnabled;

  const CertificateInstallationForm({
    super.key,
    required this.formKey,
    required this.areaController,
    required this.branches,
    required this.selectedBranch,
    required this.selectedSystemType,
    required this.alertDevices,
    required this.fireExtinguishers,
    required this.onBranchChanged,
    required this.onSystemTypeChanged,
    required this.onSubmit,
    required this.localizations,
    required this.wantsProvider,
    required this.selectedProvider,
    required this.providers,
    required this.onProviderChoiceChanged,
    required this.onProviderChanged,
    this.isLoadingProviders = false,
    this.systemTypeEnabled = true,
    this.areaEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServiceProviderSection(
            wantsProvider: wantsProvider,
            selectedProvider: selectedProvider,
            providers: providers,
            onProviderChoiceChanged: onProviderChoiceChanged,
            onProviderChanged: onProviderChanged,
            localizations: localizations,
            branches: branches,
            selectedBranch: selectedBranch,
            onBranchChanged: onBranchChanged,
            isLoadingProviders: isLoadingProviders,
          ),

          // System Type
          SectionTitle(title: localizations.translate('systemType')),
          SizedBox(height: 12.h),
          SystemTypeSelector(
            selectedSystemType: selectedSystemType,
            onSystemTypeChanged: onSystemTypeChanged,
            localizations: localizations,
            enabled: systemTypeEnabled,
          ),
          SizedBox(height: 20.h),

          // Area
          SectionTitle(title: localizations.translate('areaLabel')),
          SizedBox(height: 12.h),
          AreaInput(
            controller: areaController,
            localizations: localizations,
            enabled: areaEnabled,
          ),
          SizedBox(height: 20.h),

          // Alert Devices
          DeviceListSection(
            devices: alertDevices,
            localizations: localizations,
            title: localizations.translate('alertDevices'),
          ),
          SizedBox(height: 20.h),

          // Fire Extinguishers - Only display if there are items
          if (fireExtinguishers.isNotEmpty) ...[
            FireExtinguisherSection(
              extinguishers: fireExtinguishers,
              localizations: localizations,
              title: localizations.translate('fireExtinguishers'),
            ),
            SizedBox(height: 30.h),
          ],

          // Submit Button
          SubmitButton(
            onPressed: onSubmit,
            localizations: localizations,
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
