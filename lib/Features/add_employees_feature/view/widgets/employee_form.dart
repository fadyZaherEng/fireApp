import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import 'input_field.dart';
import 'dropdown_field.dart';
import 'phone_field.dart';

class EmployeeForm extends StatelessWidget {
  final int index;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final String selectedRole;
  final String selectedCountry;
  final File? selectedImage;
  final Function(int) pickImage;
  final Function(String?) onRoleChanged;
  final Function(int) showCountryPicker;
  final List<String> roles;
  final List<Map<String, String>> countries;

  const EmployeeForm({
    super.key,
    required this.index,
    required this.nameController,
    required this.phoneController,
    required this.selectedRole,
    required this.selectedCountry,
    required this.selectedImage,
    required this.pickImage,
    required this.onRoleChanged,
    required this.showCountryPicker,
    required this.roles,
    required this.countries,
  });

  Map<String, String> _getSelectedCountryData() =>
      countries.firstWhere((country) => country['code'] == selectedCountry);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return Container(
      width: AppSizes.cardWidth,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
        border: Border.all(
          color: AppColors.borderColor,
          width: AppSizes.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Profile Image Section
          Center(
            child: GestureDetector(
              onTap: () => pickImage(index),
              child: Stack(
                children: [
                  Container(
                    width: AppSizes.profileImageSize,
                    height: AppSizes.profileImageSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      image: selectedImage != null
                          ? DecorationImage(
                              image: FileImage(selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: selectedImage == null
                        ? Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.grey[400],
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: AppSizes.cameraIconSize,
                      height: AppSizes.cameraIconSize,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppColors.whiteTextColor,
                        size: AppSizes.cameraIconInnerSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),

          // Name Field
          InputField(
            label: localizations.translate('employeeName'),
            controller: nameController,
            hintText: localizations.translate('enterEmployeeName'),
            suffixIcon: Icons.person_outline,
          ),
          const SizedBox(height: AppSizes.paddingLarge),

          // Role Dropdown
          DropdownField(
            label: localizations.translate('employeeRole'),
            value: selectedRole,
            items: roles,
            onChanged: onRoleChanged,
          ),
          const SizedBox(height: AppSizes.paddingLarge),

          // Phone Field
          PhoneField(
            index: index,
            phoneController: phoneController,
            selectedCountry: selectedCountry,
            countries: countries,
            showCountryPicker: showCountryPicker,
            getSelectedCountryData: _getSelectedCountryData,
          ),
        ],
      ),
    );
  }
}
