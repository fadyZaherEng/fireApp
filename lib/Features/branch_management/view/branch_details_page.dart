import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/routes.dart';
import '../../../core/services/shared_pref/shared_pref.dart';
import '../../../core/utils/constants/branch_colors.dart';
import '../../../core/widgets/branch_widgets.dart';
import '../../../core/widgets/paginated_manager_dropdown.dart';
import '../../../core/widgets/mall_dropdown.dart';
import '../../location_picker/widgets/location_picker_button.dart';
import '../cubit/manager_cubit.dart';
import '../cubit/mall_cubit.dart';
import '../data/models/manager_models.dart';
import '../data/models/mall_model.dart';
import '../data/services/manager_api_service.dart';
import '../data/services/mall_api_service.dart';
import '../models/branch_data.dart';
import 'branch_quantities_page.dart';

String? selectedSystemType;

class BranchDetailsPage extends StatefulWidget {
  const BranchDetailsPage({super.key});

  @override
  State<BranchDetailsPage> createState() => _BranchDetailsPageState();
}

class _BranchDetailsPageState extends State<BranchDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _mainEstablishmentController = TextEditingController();
  final _branchController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _areaController = TextEditingController();
  Manager? _selectedManager;
  Mall? _selectedMall;
  bool _insideCommercialComplex = false;

  // Location picker state variables
  String? _selectedAddress;
  double? _selectedLatitude;
  double? _selectedLongitude;

  // Working days data
  final Map<String, WorkingDayData> _workingDays = {};

  @override
  void initState() {
    super.initState();
    _initializeWorkingDays();
  }

  void _initializeWorkingDays() {
    final days = [
      'friday',
      'saturday',
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday'
    ];
    for (String day in days) {
      _workingDays[day] = WorkingDayData(
        isActive: false,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              final cubit = ManagerCubit(ManagerApiService());
              // Load managers immediately when the cubit is created
              cubit.loadManagers();
              return cubit;
            },
          ),
          BlocProvider(
            create: (context) {
              final cubit = MallCubit(MallApiService());
              // Load nearby malls immediately when the cubit is created
              cubit.loadNearbyMalls();
              return cubit;
            },
          ),
        ],
        child: WillPopScope(
          onWillPop: () async {
            // Navigate to home with replacement when back button is pressed
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.home,
              (route) => false,
            );
            return false; // Prevent default back navigation
          },
          child: Scaffold(
            backgroundColor: BranchColors.lightBlue,
            appBar: AppBar(
              backgroundColor: BranchColors.lightBlue,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: BranchColors.primaryBlue,
                  size: 20.sp,
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.home,
                    (route) => false,
                  );
                },
              ),
            ),
            body: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: BranchSpacing.xs.h,
                        bottom: BranchSpacing.lg.h,
                        left: BranchSpacing.lg.w,
                        right: BranchSpacing.lg.w,
                      ),
                      child: Text(
                        localizations.translate('addYourBranches'),
                        style: TextStyle(
                          fontFamily: 'Almarai',
                          fontWeight: FontWeight.w700,
                          fontSize: 24.sp,
                          height: 22 / 24,
                          letterSpacing: 0,
                          color: BranchColors.primaryBlue,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: BranchSpacing.xs.h,
                        bottom: BranchSpacing.lg.h,
                        left: BranchSpacing.lg.w,
                        right: BranchSpacing.lg.w,
                      ),
                      child: Text(
                        localizations.translate('enterAvailableQuantities'),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontFamily: isRTL ? 'Almarai' : 'Poppins',
                        ),
                      ),
                    ),

                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                            horizontal: BranchSpacing.lg.w),
                        child: Column(
                          children: [
                            // Form fields section
                            _buildFormFields(localizations, isRTL),

                            SizedBox(height: BranchSpacing.xxl.h),

                            // Map section
                            _buildMapSection(localizations, isRTL),

                            SizedBox(height: BranchSpacing.xxl.h),

                            // Commercial complex section
                            _buildCommercialComplexSection(
                                localizations, isRTL),

                            SizedBox(height: BranchSpacing.xxl.h),

                            // Working hours section
                            _buildWorkingHoursSection(localizations, isRTL),

                            SizedBox(height: BranchSpacing.xxl.h),
                          ],
                        ),
                      ),
                    ),
                    // Bottom CTA button
                    Padding(
                        padding: EdgeInsets.all(BranchSpacing.lg.w),
                        child: PrimaryButton(
                          text: localizations
                              .translate('startEnteringQuantities'),
                          onPressed: _validateAndProceed,
                        )),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildFormFields(AppLocalizations localizations, bool isRTL) {
    return Column(
      children: [
        // Main establishment field
        Column(
          children: [
            Row(
              children: [
                Text(
                  localizations.translate('mainEstablishment'),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: BranchColors.primaryBlue,
                    fontFamily: isRTL ? 'Almarai' : 'Poppins',
                  ),
                ),
              ],
            ),
            SizedBox(height: BranchSpacing.sm.h),
            FutureBuilder<String?>(
              future: Future.value(SharedPref().getString('user_employee')),
              builder: (context, snapshot) {
                String fullName = '';
                if (snapshot.hasData && snapshot.data != null) {
                  final userData = jsonDecode(snapshot.data!);
                  fullName = userData['fullName'] ?? '';
                }

                return CustomTextField(
                  enabled: false,
                  suffixIcon: Icon(Icons.home, color: BranchColors.primaryBlue),
                  controller: _mainEstablishmentController,
                  hintText: fullName.isNotEmpty
                      ? fullName
                      : localizations.translate('enterMainEstablishmentName'),
                );
              },
            ),
          ],
        ),

        SizedBox(height: BranchSpacing.lg.h),

        // Branch field
        Column(
          children: [
            Row(
              children: [
                Text(
                  localizations.translate('branch'),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: BranchColors.primaryBlue,
                    fontFamily: isRTL ? 'Almarai' : 'Poppins',
                  ),
                ),
              ],
            ),
            SizedBox(height: BranchSpacing.sm.h),
            CustomTextField(
              suffixIcon: Icon(Icons.home, color: BranchColors.primaryBlue),
              controller: _branchController,
              hintText: localizations.translate('enterBranchName'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Branch name is required';
                }
                return null;
              },
            ),
          ],
        ),

        SizedBox(height: BranchSpacing.lg.h), // Responsible person dropdown
        Column(
          children: [
            Row(
              children: [
                Text(
                  localizations.translate('branchManagerName'),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: BranchColors.primaryBlue,
                    fontFamily: isRTL ? 'Almarai' : 'Poppins',
                  ),
                ),
              ],
            ),
            SizedBox(height: BranchSpacing.sm.h),
            PaginatedManagerDropdown(
              selectedManager: _selectedManager,
              hintText: localizations.translate('selectManagerName'),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
              ),
              onChanged: (manager) {
                setState(() {
                  _selectedManager = manager;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapSection(AppLocalizations localizations, bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Map label
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              localizations.translate('addLocation'),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: BranchColors.primaryBlue,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
              ),
            ),
            SizedBox(width: BranchSpacing.sm.w),
            Icon(
              Icons.location_pin,
              size: 20.sp,
              color: BranchColors.primaryRed,
            ),
          ],
        ),

        SizedBox(height: BranchSpacing.sm.h),

        // Location Picker Button - Interactive map selection
        Builder(
          builder: (builderContext) => LocationPickerButton(
            selectedAddress: _selectedAddress,
            latitude: _selectedLatitude,
            longitude: _selectedLongitude,
            hintText: localizations.translate('selectLocationFromMap'),
            onLocationSelected: (latitude, longitude, address) {
              setState(() {
                _selectedLatitude = latitude;
                _selectedLongitude = longitude;
                _selectedAddress = address;
              });

              // Reload nearby malls with the new coordinates using the builder context
              builderContext.read<MallCubit>().loadNearbyMalls(
                    latitude: latitude,
                    longitude: longitude,
                  );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommercialComplexSection(
      AppLocalizations localizations, bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Question
        Text(
          localizations.translate('isLocationInsideCommercialComplex'),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: BranchColors.primaryBlue,
            fontFamily: isRTL ? 'Almarai' : 'Poppins',
          ),
        ),

        SizedBox(height: BranchSpacing.lg.h),

        // Radio buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              localizations.translate('no'),
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
              ),
            ),
            Radio<bool>(
              value: false,
              groupValue: _insideCommercialComplex,
              onChanged: (value) =>
                  setState(() => _insideCommercialComplex = value ?? false),
              activeColor: BranchColors.primaryRed,
            ),
            SizedBox(width: BranchSpacing.xl.w),
            Text(
              localizations.translate('yes'),
              style: TextStyle(
                fontSize: 14.sp,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: _insideCommercialComplex,
              onChanged: (value) =>
                  setState(() => _insideCommercialComplex = value ?? false),
              activeColor: BranchColors.primaryRed,
            ),
          ],
        ),

        // Mall dropdown (shown only if yes is selected)
        if (_insideCommercialComplex) ...[
          SizedBox(height: BranchSpacing.lg.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                localizations.translate('selectComplex'),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: BranchColors.primaryBlue,
                  fontFamily: isRTL ? 'Almarai' : 'Poppins',
                ),
              ),
              SizedBox(height: BranchSpacing.sm.h),
              MallDropdown(
                selectedMall: _selectedMall,
                hintText: localizations.translate('commercialComplex'),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontFamily: isRTL ? 'Almarai' : 'Poppins',
                ),
                onChanged: (mall) {
                  setState(() {
                    _selectedMall = mall;
                  });
                },
              ),
            ],
          ),
        ],

        SizedBox(height: BranchSpacing.xl.h),

        // Area field
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              localizations.translate('area'),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: BranchColors.primaryBlue,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
              ),
            ),
            SizedBox(height: BranchSpacing.sm.h),
            Container(
              height: BranchSpacing.fieldHeight.h,
              decoration: BoxDecoration(
                color: BranchColors.white,
                border: Border.all(
                  color: BranchColors.fieldBorder,
                  width: 1,
                ),
                borderRadius:
                    BorderRadius.circular(BranchSpacing.borderRadius.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40.w,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(BranchSpacing.borderRadius.r),
                        bottomLeft:
                            Radius.circular(BranchSpacing.borderRadius.r),
                      ),
                    ),
                    child: Icon(
                      Icons.straighten,
                      color: BranchColors.primaryBlue,
                      size: 20.sp,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _areaController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontFamily: 'Almarai',
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: BranchColors.textHint,
                          fontFamily: 'Almarai',
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: BranchSpacing.md.w,
                          vertical: BranchSpacing.sm.h,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: BranchSpacing.xl.h),

        // System type dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              localizations.translate('systemType'),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: BranchColors.primaryBlue,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
              ),
            ),
            SizedBox(height: BranchSpacing.sm.h),
            CustomDropdownField(
              value: selectedSystemType,
              items: [
                localizations.translate('normal'),
                localizations.translate('addressed'),
              ],
              hintText: localizations.translate('normal'),
              onChanged: (value) {
                setState(() {
                  selectedSystemType = value;
                });

                // Immediately update the system type for immediate feedback
                if (value != null) {
                  print('System type changed to: $value');
                  print(
                      'Will be converted to API type: ${_getSystemTypeForAPI(value)}');
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkingHoursSection(AppLocalizations localizations, bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Working hours header
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              localizations.translate('workingHours'),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: BranchColors.primaryRed,
                fontFamily: isRTL ? 'Almarai' : 'Poppins',
              ),
            ),
            SizedBox(width: BranchSpacing.sm.w),
            Icon(
              Icons.access_time,
              size: 18.sp,
              color: BranchColors.primaryRed,
            ),
          ],
        ),
        SizedBox(height: BranchSpacing.xl.h),
        // Working day rows
        ...getWorkingDaysList(localizations).map(
          (dayData) => Container(
            margin: EdgeInsets.only(bottom: BranchSpacing.md.h),
            padding: EdgeInsets.symmetric(
              horizontal: BranchSpacing.lg.w,
              vertical: BranchSpacing.md.h,
            ),
            decoration: BoxDecoration(
              color: BranchColors.white,
              border: Border.all(
                color: BranchColors.fieldBorder,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(BranchSpacing.borderRadius.r),
            ),
            child: Row(
              children: [
                // From time picker
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // AM/PM for from time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              color: _getAMPMColor(dayData['key']!, true, true),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                color: _getAMPMColor(
                                            dayData['key']!, true, true) ==
                                        Colors.grey.shade100
                                    ? Colors.grey.shade300
                                    : BranchColors.primaryBlue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'AM',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: _getAMPMTextColor(
                                      dayData['key']!, true, true),
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Container(
                            width: 32.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              color:
                                  _getAMPMColor(dayData['key']!, true, false),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                color: _getAMPMColor(
                                            dayData['key']!, true, false) ==
                                        Colors.grey.shade100
                                    ? Colors.grey.shade300
                                    : BranchColors.primaryBlue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'PM',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: _getAMPMTextColor(
                                      dayData['key']!, true, false),
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h), // Time display and picker
                      GestureDetector(
                        onTap: () => _showTimePicker(dayData['key']!, true),
                        child: Container(
                          width: 70.w,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _workingDays[dayData['key']!]?.isActive == true
                                    ? Colors.blue.shade50
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: _workingDays[dayData['key']!]?.isActive ==
                                      true
                                  ? Colors.blue.shade300
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _workingDays[dayData['key']!]?.isActive == true
                                ? _formatTime(
                                    _workingDays[dayData['key']!]!.startTime)
                                : '8:00',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: _workingDays[dayData['key']!]?.isActive ==
                                      true
                                  ? Colors.black
                                  : Colors.grey,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // "من" label
                      Text(
                        localizations.translate('from'),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: BranchColors.textSecondary,
                          fontFamily: isRTL ? 'Almarai' : 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: BranchSpacing.lg.w),

                // To time picker
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // AM/PM for to time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              color:
                                  _getAMPMColor(dayData['key']!, false, true),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                color: _getAMPMColor(
                                            dayData['key']!, false, true) ==
                                        Colors.grey.shade100
                                    ? Colors.grey.shade300
                                    : BranchColors.primaryBlue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'AM',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: _getAMPMTextColor(
                                      dayData['key']!, false, true),
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Container(
                            width: 32.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              color:
                                  _getAMPMColor(dayData['key']!, false, false),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                color: _getAMPMColor(
                                            dayData['key']!, false, false) ==
                                        Colors.grey.shade100
                                    ? Colors.grey.shade300
                                    : BranchColors.primaryBlue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'PM',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: _getAMPMTextColor(
                                      dayData['key']!, false, false),
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h), // Time display and picker
                      GestureDetector(
                        onTap: () => _showTimePicker(dayData['key']!, false),
                        child: Container(
                          width: 70.w,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _workingDays[dayData['key']!]?.isActive == true
                                    ? Colors.blue.shade50
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(
                              color: _workingDays[dayData['key']!]?.isActive ==
                                      true
                                  ? Colors.blue.shade300
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _workingDays[dayData['key']!]?.isActive == true
                                ? _formatTime(
                                    _workingDays[dayData['key']!]!.endTime)
                                : '17:00',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: _workingDays[dayData['key']!]?.isActive ==
                                      true
                                  ? Colors.black
                                  : Colors.grey,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // "إلى" label
                      Text(
                        localizations.translate('to'),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: BranchColors.textSecondary,
                          fontFamily: isRTL ? 'Almarai' : 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: BranchSpacing.lg.w),

                // Day name and checkbox
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Day name
                      Text(
                        dayData['name']!,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: BranchColors.primaryBlue,
                          fontFamily: isRTL ? 'Almarai' : 'Poppins',
                        ),
                      ),

                      // Checkbox
                      SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: Checkbox(
                          value:
                              _workingDays[dayData['key']!]?.isActive ?? false,
                          onChanged: (value) {
                            setState(() {
                              _workingDays[dayData['key']!] =
                                  _workingDays[dayData['key']!]!
                                      .copyWith(isActive: value ?? false);
                            });
                          },
                          activeColor: BranchColors.primaryRed,
                          checkColor: BranchColors.white,
                          side: BorderSide(
                            color: BranchColors.fieldBorder,
                            width: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Map<String, String>> getWorkingDaysList(AppLocalizations localizations) {
    return [
      {'key': 'friday', 'name': localizations.translate('friday')},
      {'key': 'saturday', 'name': localizations.translate('saturday')},
      {'key': 'sunday', 'name': localizations.translate('sunday')},
      {'key': 'monday', 'name': localizations.translate('monday')},
      {'key': 'tuesday', 'name': localizations.translate('tuesday')},
      {'key': 'wednesday', 'name': localizations.translate('wednesday')},
      {'key': 'thursday', 'name': localizations.translate('thursday')},
    ];
  }

  void _showTimePicker(String dayKey, bool isStartTime) {
    final localizations = AppLocalizations.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // Auto-enable the day if it's not active
    if (_workingDays[dayKey]?.isActive != true) {
      setState(() {
        _workingDays[dayKey] = _workingDays[dayKey]!.copyWith(isActive: true);
      });
    }

    TimeOfDay initialTime = isStartTime
        ? _workingDays[dayKey]!.startTime
        : _workingDays[dayKey]!.endTime;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300.h,
          decoration: BoxDecoration(
            color: BranchColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(BranchSpacing.md.w),
                decoration: BoxDecoration(
                  color: BranchColors.primaryBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        localizations.translate('cancel'),
                        style: TextStyle(
                          color: BranchColors.white,
                          fontSize: 16.sp,
                          fontFamily: isRTL ? 'Almarai' : 'Poppins',
                        ),
                      ),
                    ),
                    Text(
                      isStartTime
                          ? localizations.translate('selectStartTime')
                          : localizations.translate('selectEndTime'),
                      style: TextStyle(
                        color: BranchColors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: isRTL ? 'Almarai' : 'Poppins',
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        localizations.translate('done'),
                        style: TextStyle(
                          color: BranchColors.white,
                          fontSize: 16.sp,
                          fontFamily: isRTL ? 'Almarai' : 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Time picker
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: false,
                  initialDateTime: DateTime(
                    2024,
                    1,
                    1,
                    initialTime.hour,
                    initialTime.minute,
                  ),
                  onDateTimeChanged: (DateTime dateTime) {
                    TimeOfDay newTime = TimeOfDay(
                      hour: dateTime.hour,
                      minute: dateTime.minute,
                    );

                    setState(() {
                      if (isStartTime) {
                        _workingDays[dayKey] = _workingDays[dayKey]!.copyWith(
                          startTime: newTime,
                        );
                      } else {
                        _workingDays[dayKey] = _workingDays[dayKey]!.copyWith(
                          endTime: newTime,
                        );
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _validateAndProceed() {
    if (_formKey.currentState?.validate() ?? false) {
      // Check if manager is selected
      if (_selectedManager == null) {
        final localizations = AppLocalizations.of(context);
        final isRTL = Directionality.of(context) == TextDirection.rtl;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.translate('selectManagerName'),
              style: TextStyle(fontFamily: isRTL ? 'Almarai' : 'Poppins'),
            ),
            backgroundColor: BranchColors.primaryRed,
          ),
        );
        return;
      }

      // Check if at least one working day is active
      bool hasActiveDay = _workingDays.values.any((day) => day.isActive);

      if (!hasActiveDay) {
        final localizations = AppLocalizations.of(context);
        final isRTL = Directionality.of(context) == TextDirection.rtl;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.translate('selectAtLeastOneWorkingDay'),
              style: TextStyle(fontFamily: isRTL ? 'Almarai' : 'Poppins'),
            ),
            backgroundColor: BranchColors.primaryRed,
          ),
        );
        return;
      } // Navigate to quantities page with replacement to ensure proper back navigation
      // Convert selectedSystemType to the appropriate type value
      String systemTypeForAPI = _getSystemTypeForAPI(selectedSystemType);

      // Collect all branch data
      final branchData = BranchData(
        branchName: _branchController.text.trim(),
        employeeId: _selectedManager?.id ?? '',
        latitude: _selectedLatitude,
        longitude: _selectedLongitude,
        address: _selectedAddress,
        mallName: _selectedMall?.name,
        space: double.tryParse(_areaController.text.trim()),
        systemType: systemTypeForAPI,
        workingDays: _getWorkingDaysData(),
      );

      print('Final system type for API: $systemTypeForAPI');
      print('Branch data: ${branchData.branchName}, ${branchData.employeeId}');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BranchQuantitiesPage(
            systemType: systemTypeForAPI,
            branchData: branchData,
          ),
        ),
      );
    }
  }

  /// Convert working days data to the format needed for BranchData
  List<BranchWorkingDayData> _getWorkingDaysData() {
    return _workingDays.entries
        .where((entry) => entry.value.isActive)
        .map((entry) => BranchWorkingDayData(
              day: entry.key,
              startHour: entry.value.startTime.hour,
              startMinute: entry.value.startTime.minute,
              endHour: entry.value.endTime.hour,
              endMinute: entry.value.endTime.minute,
            ))
        .toList();
  }

  @override
  void dispose() {
    _mainEstablishmentController.dispose();
    _branchController.dispose();
    _branchNameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  // Helper methods for AM/PM styling and time formatting
  Color _getAMPMColor(String dayKey, bool isStartTime, bool isAM) {
    if (_workingDays[dayKey]?.isActive != true) {
      return Colors.grey.shade100;
    }

    TimeOfDay time = isStartTime
        ? _workingDays[dayKey]!.startTime
        : _workingDays[dayKey]!.endTime;

    bool timeIsAM = time.hour < 12;

    if ((isAM && timeIsAM) || (!isAM && !timeIsAM)) {
      return BranchColors.primaryBlue.withOpacity(0.1);
    }

    return Colors.grey.shade100;
  }

  Color _getAMPMTextColor(String dayKey, bool isStartTime, bool isAM) {
    if (_workingDays[dayKey]?.isActive != true) {
      return Colors.grey;
    }

    TimeOfDay time = isStartTime
        ? _workingDays[dayKey]!.startTime
        : _workingDays[dayKey]!.endTime;

    bool timeIsAM = time.hour < 12;

    if ((isAM && timeIsAM) || (!isAM && !timeIsAM)) {
      return BranchColors.primaryBlue;
    }

    return Colors.grey;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Helper method to convert UI system type to API type
  String _getSystemTypeForAPI(String? uiSystemType) {
    if (uiSystemType == null) return 'zone';

    final localizations = AppLocalizations.of(context);
    final normalText = localizations.translate('normal');
    final addressedText = localizations.translate('addressed');

    if (uiSystemType == addressedText) {
      return 'loop';
    } else if (uiSystemType == normalText) {
      return 'zone';
    }

    // Fallback for English terms or other cases
    if (uiSystemType.toLowerCase().contains('addressed') ||
        uiSystemType.toLowerCase().contains('loop')) {
      return 'loop';
    }

    return 'zone'; // Default to zone
  }
}

/// Data class for working day information
class WorkingDayData {
  final bool isActive;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  WorkingDayData({
    required this.isActive,
    required this.startTime,
    required this.endTime,
  });

  WorkingDayData copyWith({
    bool? isActive,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return WorkingDayData(
      isActive: isActive ?? this.isActive,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

/// Custom painter for map grid pattern
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1.0;

    const double gridSize = 20.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
