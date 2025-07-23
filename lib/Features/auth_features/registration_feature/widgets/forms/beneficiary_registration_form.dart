import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../controllers/registration_form_controller.dart';
import '../registration_input_field.dart';
import '../registration_checkbox.dart';

class BeneficiaryRegistrationForm extends StatefulWidget {
  final RegistrationFormController formController;
  final VoidCallback onLocationTap;
  final Function(bool) onCertifyChanged;
  final Function(bool) onAgreeTermsChanged;

  const BeneficiaryRegistrationForm({
    super.key,
    required this.formController,
    required this.onLocationTap,
    required this.onCertifyChanged,
    required this.onAgreeTermsChanged,
  });

  @override
  State<BeneficiaryRegistrationForm> createState() =>
      _BeneficiaryRegistrationFormState();
}

class _BeneficiaryRegistrationFormState
    extends State<BeneficiaryRegistrationForm> {
  AppLocalizations get _localizations => AppLocalizations.of(context);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formController.formKey,
      child: Column(
        children: [
          // Facility Name Field
          RegistrationInputField(
            controller: widget.formController.companyNameController,
            icon: Icons.business,
            placeholder: _localizations.translate('enterFacilityName'),
            validator: (value) => widget.formController
                .validateFacilityName(value, _localizations),
          ),

          SizedBox(height: 12.h),

          // Email Field
          RegistrationInputField(
            controller: widget.formController.emailController,
            icon: Icons.email,
            placeholder: _localizations.translate('enterEmailAddress'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                widget.formController.validateEmail(value, _localizations),
          ),

          SizedBox(height: 12.h),

          // Commercial Registration Field
          RegistrationInputField(
            controller: widget.formController.commercialRegistrationController,
            icon: Icons.business_center,
            placeholder:
                _localizations.translate('enterCommercialRegistration'),
            validator: (value) => widget.formController
                .validateCommercialRegistration(value, _localizations),
          ),

          SizedBox(height: 12.h),

          // Location Field with Map Button
          GestureDetector(
            onTap: widget.onLocationTap,
            child: AbsorbPointer(
              child: RegistrationInputField(
                controller: widget.formController.locationController,
                icon: Icons.location_on,
                placeholder: _localizations.translate('selectLocationFromMap'),
                suffixIcon: Icon(
                  Icons.map,
                  color: const Color(0xFF1C4587),
                  size: 20.w,
                ),
                validator: (value) => widget.formController
                    .validateLocation(value, _localizations),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Phone Field
          RegistrationInputField(
            controller: widget.formController.phoneController,
            icon: Icons.phone,
            placeholder: _localizations.translate('directManagerPhone'),
            keyboardType: TextInputType.phone,
            validator: (value) =>
                widget.formController.validatePhone(value, _localizations),
          ),

          SizedBox(height: 12.h),

          // Facility Activity Field
          RegistrationInputField(
            controller: widget.formController.facilityActivityController,
            icon: Icons.work,
            placeholder: _localizations.translate('facilityActivity'),
            validator: (value) => widget.formController
                .validateFacilityActivity(value, _localizations),
          ),

          SizedBox(height: 16.h),

          // Checkboxes
          RegistrationCheckbox(
            value: widget.formController.certifyInformation,
            text: _localizations.translate('iCertifyInformation'),
            onChanged: (value) {
              widget.formController.updateCertifyInformation(value ?? false);
              widget.onCertifyChanged(value ?? false);
            },
          ),

          SizedBox(height: 8.h),

          RegistrationCheckbox(
            value: widget.formController.agreeTerms,
            text: _localizations.translate('iAgreeTermsAndConditions'),
            onChanged: (value) {
              widget.formController.updateAgreeTerms(value ?? false);
              widget.onAgreeTermsChanged(value ?? false);
            },
          ),
        ],
      ),
    );
  }
}
