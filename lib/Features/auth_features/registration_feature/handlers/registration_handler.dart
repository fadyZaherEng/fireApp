import 'package:flutter/material.dart';
import '../../../../../core/localization/app_localizations.dart';
import '../../login_feature/cubit/auth_cubit.dart';
import '../../login_feature/cubit/auth_states.dart';
import '../controllers/registration_form_controller.dart';
import '../widgets/dialogs/registration_success_dialog.dart';
import '../widgets/dialogs/registration_loading_dialog.dart';
import '../widgets/helpers/registration_snackbar_helper.dart';
import '../../../location_picker/widgets/location_map_picker.dart';

class RegistrationHandler {
  final BuildContext context;
  final AuthCubit authCubit;
  final RegistrationFormController formController;

  RegistrationHandler({
    required this.context,
    required this.authCubit,
    required this.formController,
  });

  AppLocalizations get _localizations => AppLocalizations.of(context);

  void handleCompleteRegistration() {
    if (formController.validateForm(_localizations)) {
      final validationError = formController.getValidationError(_localizations);

      if (validationError != null) {
        RegistrationSnackBarHelper.showError(context, validationError);
        return;
      }

      // Create the registration request
      final request = formController.createRegistrationRequest();
      authCubit.register(request);
    }
  }

  void handleAuthStateChange(AuthState state) async {
    if (state is AuthLoading) {
      RegistrationLoadingDialog.show(context);
    } else {
      RegistrationLoadingDialog.hide(context);

      if (state is RegisterSuccess) {
        // Store authentication data
        await authCubit.handleSuccessfulRegistration(state);
        RegistrationSuccessDialog.show(context);
      } else if (state is RegisterFailure) {
        RegistrationSnackBarHelper.showError(context, state.error);
      }
    }
  }

  Future<void> handleLocationSelection() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationMapPicker(
          initialLatitude: formController.selectedLatitude,
          initialLongitude: formController.selectedLongitude,
          onLocationSelected: (latitude, longitude) {
            formController.updateLocation(
              latitude: latitude,
              longitude: longitude,
              address: null,
            );
          },
        ),
      ),
    );

    if (result != null) {
      formController.updateLocation(
        latitude: result['latitude'],
        longitude: result['longitude'],
        address: result['address'],
      );
    }
  }
}
