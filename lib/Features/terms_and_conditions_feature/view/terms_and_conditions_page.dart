import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/routes.dart';

import '../data/services/terms_api_service.dart';
import '../data/models/terms_models.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  final TextEditingController _termsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TermsAndConditionsApiService _termsApiService =
      TermsAndConditionsApiService();

  bool _isLoading = false;
  bool _isLoadingEmployees = false;
  List<Employee> _employees = [];
  Employee? _selectedEmployee;
  String? _employeesError;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoadingEmployees = true;
      _employeesError = null;
    });

    try {
      final employees =
          await _termsApiService.getContractDocumentationEmployees();
      if (mounted) {
        setState(() {
          _employees = employees.where((e) => !e.isDeleted).toList();
          _isLoadingEmployees = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _employeesError = e.toString();
          _isLoadingEmployees = false;
        });
      }
    }
  }

  void _saveTerms() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedEmployee == null) {
      _showError('يرجى اختيار المسؤول');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse terms text into clauses (split by lines for now)
      final termsText = _termsController.text.trim();
      final clauses = termsText
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => TermsClause(text: line.trim()))
          .toList();

      if (clauses.isEmpty) {
        clauses.add(TermsClause(text: termsText));
      }

      final request = CreateTermsRequest(
        employee: _selectedEmployee!.id, // Use selected employee's ID
        responsibleEmployeeName: _selectedEmployee!.fullName,
        clauses: clauses,
        isFirstTime: true,
      );

      print('Creating terms and conditions...');
      final response = await _termsApiService.createTermsAndConditions(request);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          print(
              'Terms and conditions created successfully: ID=${response.data.id}');
          Navigator.of(context).pushNamed(Routes.termsAndConditionsSuccess);
        } else {
          _showError('Failed to save terms and conditions');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        print('Error saving terms and conditions: $e');
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE9EFF6),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header with back button and title
              _buildHeader(isRTL, localizations),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),

                      // Name field label
                      _buildLabel(
                        text: 'اسم المصرح له بتوثيق العقود',
                        color: const Color(0xFF4A90E2),
                        isRTL: isRTL,
                      ),

                      SizedBox(height: 6.h),

                      // Name input field
                      _buildPersonNameField(isRTL),

                      SizedBox(height: 16.h),

                      // Terms label with icon
                      _buildTermsLabel(isRTL, localizations),

                      SizedBox(height: 6.h),

                      // Terms text area
                      _buildTermsTextArea(isRTL),

                      SizedBox(height: 24.h),

                      // Save button
                      _buildSaveButton(isRTL),

                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isRTL, AppLocalizations localizations) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 24.w,
              height: 24.h,
              alignment: Alignment.center,
              child: Icon(
                isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                color: const Color(0xFF003366),
                size: 20.sp,
              ),
            ),
          ),

          // Title
          Expanded(
            child: Text(
              localizations.translate('termsAndConditions'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF003366),
                fontFamily: 'Almarai',
              ),
            ),
          ),

          // Spacer for balance
          SizedBox(width: 24.w),
        ],
      ),
    );
  }

  Widget _buildLabel({
    required String text,
    required Color color,
    required bool isRTL,
    Widget? icon,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          icon,
          SizedBox(width: 8.w),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: color,
            fontFamily: 'Almarai',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonNameField(bool isRTL) {
    final localizations = AppLocalizations.of(context);

    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFB0BEC5)),
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
      ),
      child: _isLoadingEmployees
          ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    localizations.translate('loadingEmployees'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF9E9E9E),
                      fontFamily: 'Almarai',
                    ),
                  ),
                ],
              ),
            )
          : _employeesError != null
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          localizations.translate('failedToLoadEmployees'),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.red,
                            fontFamily: 'Almarai',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: _loadEmployees,
                        child: Icon(
                          Icons.refresh,
                          color: const Color(0xFF4A90E2),
                          size: 16.sp,
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonFormField<Employee>(
                  value: _selectedEmployee,
                  decoration: InputDecoration(
                    hintText:
                        localizations.translate('selectResponsibleEmployee'),
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF9E9E9E),
                      fontFamily: 'Almarai',
                    ),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: const Color(0xFF9E9E9E),
                      size: 20.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Almarai',
                    color: Colors.black,
                  ),
                  isExpanded: true,
                  items: _employees.map((Employee employee) {
                    return DropdownMenuItem<Employee>(
                      value: employee,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16.r,
                            backgroundColor: const Color(0xFF4A90E2),
                            backgroundImage: employee.profileImage != null
                                ? NetworkImage(employee.profileImage!)
                                : null,
                            child: employee.profileImage == null
                                ? Icon(
                                    Icons.person,
                                    size: 16.sp,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              '${employee.fullName} - ${employee.jobTitle}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Almarai',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (Employee? value) {
                    setState(() {
                      _selectedEmployee = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'يرجى اختيار المسؤول';
                    }
                    return null;
                  },
                  menuMaxHeight: 200.h,
                ),
    );
  }

  Widget _buildTermsLabel(bool isRTL, localizations) {
    return Row(
      children: [
        Icon(
          Icons.assignment_outlined,
          color: const Color(0xFFD32F2F),
          size: 20.sp,
        ),
        SizedBox(width: 8.w),
        Text(
          localizations.translate('authorizedPersonForContracts'),
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFFD32F2F),
            fontFamily: 'Almarai',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsTextArea(bool isRTL) {
    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1976D2)),
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
      ),
      child: TextFormField(
        controller: _termsController,
        maxLines: null,
        expands: true,
        textAlign: isRTL ? TextAlign.right : TextAlign.left,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontSize: 14.sp,
          fontFamily: 'Almarai',
        ),
        decoration: InputDecoration(
          hintText: 'ادخل البنود والشروط...',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF9E9E9E),
            fontFamily: 'Almarai',
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12.w),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'يرجى إدخال البنود والشروط';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSaveButton(bool isRTL) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTerms,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLoading ? Colors.grey : const Color(0xFFC62828),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'حفظ',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Almarai',
                ),
              ),
      ),
    );
  }
}
