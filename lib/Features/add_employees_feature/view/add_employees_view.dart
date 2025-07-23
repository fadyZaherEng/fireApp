import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/routes.dart';
import '../cubit/add_employee_cubit.dart';
import '../cubit/add_employee_states.dart';
import '../data/services/employee_api_service.dart';
import '../constants/employee_constants.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/employee_tabs.dart';
import 'widgets/employee_form.dart';
import 'widgets/loading_dialog.dart';

class AddEmployeeView extends StatefulWidget {
  const AddEmployeeView({super.key});

  @override
  State<AddEmployeeView> createState() => _AddEmployeeViewState();
}

class _AddEmployeeViewState extends State<AddEmployeeView> {
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _phoneControllers = [];
  final List<String> _selectedRoles = [];
  final List<String> _selectedCountries = [];
  final List<File?> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  late AddEmployeeCubit _addEmployeeCubit;
  AppLocalizations get _localizations => AppLocalizations.of(context);
  int currentEmployeeIndex = 0;

  @override
  void initState() {
    super.initState();
    _addEmployeeCubit = AddEmployeeCubit(EmployeeApiService());
    _addInitialEmployee();
  }

  void _addInitialEmployee() {
    _nameControllers.add(TextEditingController());
    _phoneControllers.add(TextEditingController());
    _selectedRoles.add('management');
    _selectedCountries.add('SA');
    _selectedImages.add(null);
  }

  void _addNewEmployee() {
    setState(() {
      _nameControllers.add(TextEditingController());
      _phoneControllers.add(TextEditingController());
      _selectedRoles.add('management');
      _selectedCountries.add('SA');
      _selectedImages.add(null);
      currentEmployeeIndex = _nameControllers.length - 1;
    });
  }

  Map<String, String> _getSelectedCountryData(int index) => EmployeeConstants
      .countries
      .firstWhere((country) => country['code'] == _selectedCountries[index]);

  Future<void> _pickImage(int index) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImages[index] = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_localizations.translate('imageSelectionError'))),
      );
    }
  }

  void _showCountryPicker(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _localizations.translate('selectCountry'),
                  style: AppTextStyles.fieldLabel,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: EmployeeConstants.countries.length,
                  itemBuilder: (context, countryIndex) {
                    final country = EmployeeConstants.countries[countryIndex];
                    return ListTile(
                      leading: Text(
                        country['flag']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(country['name']!),
                      subtitle: Text(country['dialCode']!),
                      onTap: () {
                        setState(() {
                          _selectedCountries[index] = country['code']!;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _addEmployeeCubit,
      child: BlocListener<AddEmployeeCubit, AddEmployeeState>(
        listener: (context, state) {
          if (state is AddEmployeeLoading) {
            LoadingDialog.show(context);
          } else {
            LoadingDialog.hide(context);

            if (state is AddEmployeeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFF25D366),
                ),
              );
              Navigator.pushNamed(context, Routes.addEmployeesSuccess);
            } else if (state is AddEmployeeFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: const Color(0xFFBA2D2D),
                ),
              );
            }
          }
        },
        child: _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            const CustomAppBar(),

            // Employee tabs
            if (_nameControllers.length > 1)
              EmployeeTabs(
                count: _nameControllers.length,
                currentIndex: currentEmployeeIndex,
                onTabTap: (index) {
                  setState(() {
                    currentEmployeeIndex = index;
                  });
                },
              ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.cardHorizontalPadding),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSizes.paddingLarge),

                      // Main Form Card Container
                      EmployeeForm(
                        index: currentEmployeeIndex,
                        nameController: _nameControllers[currentEmployeeIndex],
                        phoneController:
                            _phoneControllers[currentEmployeeIndex],
                        selectedRole: _selectedRoles[currentEmployeeIndex],
                        selectedCountry:
                            _selectedCountries[currentEmployeeIndex],
                        selectedImage: _selectedImages[currentEmployeeIndex],
                        pickImage: _pickImage,
                        onRoleChanged: (String? newValue) {
                          setState(() {
                            _selectedRoles[currentEmployeeIndex] = newValue!;
                          });
                        },
                        showCountryPicker: _showCountryPicker,
                        roles: EmployeeConstants.roles,
                        countries: EmployeeConstants.countries,
                      ),

                      const SizedBox(height: AppSizes.paddingLarge),

                      // Add More Button
                      TextButton(
                        onPressed: _addNewEmployee,
                        child: Text(
                          _localizations.translate('addMore'),
                          style: AppTextStyles.addMoreText,
                        ),
                      ),

                      const SizedBox(height: AppSizes.paddingLarge),

                      // Save Button
                      SizedBox(
                        width: AppSizes.cardWidth,
                        height: AppSizes.buttonHeight,
                        child: ElevatedButton(
                          onPressed: () {
                            _saveEmployee();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppSizes.borderRadiusSmall),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            _localizations.translate('save'),
                            style: AppTextStyles.buttonText,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.paddingXXLarge),

                      // iOS Home Indicator
                      Container(
                        width: AppSizes.homeIndicatorWidth,
                        height: AppSizes.homeIndicatorHeight,
                        decoration: BoxDecoration(
                          color: AppColors.homeIndicatorColor,
                          borderRadius: BorderRadius.circular(
                              AppSizes.homeIndicatorHeight / 2),
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed _buildEmployeeForm as it's now in EmployeeForm widget

  // Removed _buildInputField, _buildDropdownField, and _buildPhoneField as they've been moved to separate widget files

  void _saveEmployee() {
    // Validate current employee
    if (_nameControllers[currentEmployeeIndex].text.trim().isEmpty) {
      _showErrorSnackBar(_localizations.translate('enterEmployeeName'));
      return;
    }

    if (_phoneControllers[currentEmployeeIndex].text.trim().isEmpty) {
      _showErrorSnackBar(_localizations.translate('phoneRequired'));
      return;
    }

    // Use the selected role to get the permission
    final selectedRole = _selectedRoles[currentEmployeeIndex];
    final selectedCountryData = _getSelectedCountryData(currentEmployeeIndex);
    final fullPhoneNumber = selectedCountryData['dialCode']! +
        _phoneControllers[currentEmployeeIndex].text.trim();

    // Use the correct permission mapping
    final permission =
        EmployeeConstants.roleMapping[selectedRole] ?? 'management';

    final profileImageUrl = _selectedImages[currentEmployeeIndex] != null
        ? "https://cdn3d.iconscout.com/3d/premium/thumb/boy-avatar-3d-icon-download-in-png-blend-fbx-gltf-file-formats--male-person-character-mens-style-pack-people-icons-8330281.png?f=webp"
        : "https://cdn3d.iconscout.com/3d/premium/thumb/boy-avatar-3d-icon-download-in-png-blend-fbx-gltf-file-formats--male-person-character-mens-style-pack-people-icons-8330281.png?f=webp";

    // Use the selected role to get the job title
    final jobTitle =
        EmployeeConstants.jobTitleMapping[selectedRole] ?? 'مدير النظام';

    // Remove debug prints for production
    print('🐛 DEBUG: selectedRole = $selectedRole');
    print('🐛 DEBUG: permission = $permission');
    print('🐛 DEBUG: jobTitle = $jobTitle');

    _addEmployeeCubit.addEmployee(
      fullName: _nameControllers[currentEmployeeIndex].text.trim(),
      phoneNumber: fullPhoneNumber,
      permission: permission,
      profileImage: profileImageUrl,
      jobTitle: jobTitle,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFBA2D2D),
      ),
    );
  }

  // Removed _showLoadingDialog and _hideLoadingDialog methods as they're now in LoadingDialog class

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
    _addEmployeeCubit.close();
    super.dispose();
  }
}
