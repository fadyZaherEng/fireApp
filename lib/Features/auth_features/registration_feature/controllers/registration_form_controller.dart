import 'package:flutter/material.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../login_feature/data/models/auth_models.dart';

class RegistrationFormController {
  // Form key and controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController commercialRegistrationController =
      TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController facilityActivityController =
      TextEditingController();

  // State variables
  bool certifyInformation = false;
  bool agreeTerms = false;
  double? selectedLatitude; // Cairo latitude
  double? selectedLongitude; // Cairo longitude

  RegistrationFormController() {
    // Set default location to Cairo, Egypt
    locationController.text;
  }

  void dispose() {
    companyNameController.dispose();
    emailController.dispose();
    commercialRegistrationController.dispose();
    locationController.dispose();
    phoneController.dispose();
    facilityActivityController.dispose();
  }

  void updateCertifyInformation(bool value) {
    certifyInformation = value;
  }

  void updateAgreeTerms(bool value) {
    agreeTerms = value;
  }

  void updateLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) {
    selectedLatitude = latitude;
    selectedLongitude = longitude;
    locationController.text = address ??
        '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  bool validateForm(AppLocalizations localizations) {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (!certifyInformation) {
      return false;
    }

    if (!agreeTerms) {
      return false;
    }

    if (selectedLatitude == null || selectedLongitude == null) {
      return false;
    }

    return true;
  }

  String? getValidationError(AppLocalizations localizations) {
    if (!certifyInformation) {
      return localizations.translate('mustCertifyInformation');
    }

    if (!agreeTerms) {
      return localizations.translate('mustAgreeTerms');
    }

    if (selectedLatitude == null || selectedLongitude == null) {
      return localizations.translate('locationRequired');
    }

    return null;
  }

  RegisterRequest createRegistrationRequest() {
    return RegisterRequest(
      companyName: companyNameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: "+966${phoneController.text.trim()}",
      commercialRegistrationNumber:
          commercialRegistrationController.text.trim(),
      facilityActivity: facilityActivityController.text.trim(),
      location: LocationData(
        type: 'Point',
        coordinates: [selectedLongitude!, selectedLatitude!],
      ),
      address: locationController.text.trim(),
    );
  }

  // Field validators
  String? validateFacilityName(String? value, AppLocalizations localizations) {
    if (value == null || value.trim().isEmpty) {
      return localizations.translate('facilityNameRequired');
    }
    return null;
  }

  String? validateEmail(String? value, AppLocalizations localizations) {
    if (value == null || value.trim().isEmpty) {
      return localizations.translate('emailRequired');
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return localizations.translate('invalidEmail');
    }
    return null;
  }

  String? validateCommercialRegistration(
      String? value, AppLocalizations localizations) {
    if (value == null || value.trim().isEmpty) {
      return localizations.translate('commercialRegistrationRequired');
    }
    return null;
  }

  String? validateLocation(String? value, AppLocalizations localizations) {
    if (selectedLatitude == null || selectedLongitude == null) {
      return localizations.translate('locationRequired');
    }
    return null;
  }

  String? validatePhone(String? value, AppLocalizations localizations) {
    if (value == null || value.trim().isEmpty) {
      return localizations.translate('phoneRequired');
    }
    return null;
  }

  String? validateFacilityActivity(
      String? value, AppLocalizations localizations) {
    if (value == null || value.trim().isEmpty) {
      return localizations.translate('facilityActivityRequired');
    }
    return null;
  }
}
