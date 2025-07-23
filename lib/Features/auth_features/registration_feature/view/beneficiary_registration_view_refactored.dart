import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safetyZone/Features/auth_features/registration_feature/widgets/registration_button.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../login_feature/cubit/auth_cubit.dart';
import '../../login_feature/cubit/auth_states.dart';
import '../../login_feature/data/services/auth_api_service.dart';
import '../widgets/user_illustration.dart';
import '../controllers/registration_form_controller.dart';
import '../handlers/registration_handler.dart';
import '../widgets/forms/beneficiary_registration_form.dart';

class BeneficiaryRegistrationView extends StatefulWidget {
  const BeneficiaryRegistrationView({super.key});

  @override
  State<BeneficiaryRegistrationView> createState() =>
      _BeneficiaryRegistrationViewState();
}

class _BeneficiaryRegistrationViewState
    extends State<BeneficiaryRegistrationView> {
  late AuthCubit _authCubit;
  late RegistrationFormController _formController;
  late RegistrationHandler _registrationHandler;

  AppLocalizations get _localizations => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(AuthApiService());
    _formController = RegistrationFormController();
    _registrationHandler = RegistrationHandler(
      context: context,
      authCubit: _authCubit,
      formController: _formController,
    );
  }

  @override
  void dispose() {
    _formController.dispose();
    _authCubit.close();
    super.dispose();
  }

  void _updateFormState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _authCubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF0F6),
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) async {
            _registrationHandler.handleAuthStateChange(state);
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30.h),

                    // User Illustration
                    const UserIllustration(),

                    SizedBox(height: 16.h),

                    // Title
                    Text(
                      _localizations.translate('beneficiaryRegistration'),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC82323),
                        fontFamily: 'Almarai',
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 16.h),

                    // Registration Form
                    BeneficiaryRegistrationForm(
                      formController: _formController,
                      onLocationTap: () async {
                        await _registrationHandler.handleLocationSelection();
                        _updateFormState();
                      },
                      onCertifyChanged: (value) {
                        _updateFormState();
                      },
                      onAgreeTermsChanged: (value) {
                        _updateFormState();
                      },
                    ),

                    SizedBox(height: 24.h),

                    // Complete Registration Button
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return RegistrationButton(
                          text:
                              _localizations.translate('completeRegistration'),
                          onPressed: state is AuthLoading
                              ? () {}
                              : _registrationHandler.handleCompleteRegistration,
                        );
                      },
                    ),

                    SizedBox(height: 34.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
