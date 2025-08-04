import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../widgets/phone_input_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/login_illustration.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_states.dart';
import '../data/services/auth_api_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+966';
  late AuthCubit _authCubit;

  AppLocalizations get _localizations => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(AuthApiService());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _authCubit.close();
    super.dispose();
  }

  void _onNextPressed() {
    if (_phoneController.text.isNotEmpty) {
      final fullPhoneNumber = _selectedCountryCode + _phoneController.text;
      _authCubit.sendOtp(fullPhoneNumber);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localizations.translate('phoneNumberRequired')),
          backgroundColor: const Color(0xFFBA2D2D),
        ),
      );
    }
  }

  void _onRegisterAsBeneficiaryPressed() {
    Navigator.pushNamed(context, Routes.beneficiaryRegistration);
  }

  void _onContactUsPressed() {
    Navigator.pushNamed(context, Routes.contactUs);
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitDoubleBounce(
                  color: const Color(0xFF1C4587),
                ),
                SizedBox(height: 16.h),
                Text(
                  _localizations.translate('sendingOtp'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'Almarai',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _hideLoadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _authCubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF0F9),
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) {
              _showLoadingDialog();
            } else {
              _hideLoadingDialog();

              if (state is SendOtpSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: const Color(0xFF25D366),
                  ),
                );
                // Navigate to verification screen
                Navigator.pushNamed(
                  context,
                  Routes.whatsappVerification,
                  arguments: {
                    'phoneNumber': _phoneController.text,
                  },
                );
              } else if (state is SendOtpFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: const Color(0xFFBA2D2D),
                  ),
                );
              }
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 45.h),

                    // Illustration
                    const LoginIllustration(),

                    SizedBox(height: 26.h),

                    // WhatsApp Number Label
                    Row(
                      children: [
                        Text(
                          _localizations.translate('whatsappNumber'),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                            fontFamily: 'Almarai',
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    // Phone Input Field
                    PhoneInputField(
                      selectedCountryname:
                          _localizations.translate('saudiArabia'),
                      phoneController: _phoneController,
                      selectedCountryCode: _selectedCountryCode,
                      onCountryCodeChanged: (String countryCode) {
                        setState(() {
                          _selectedCountryCode = countryCode;
                        });
                      },
                    ),

                    SizedBox(height: 18.h),

                    // Primary Button - التالي
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return PrimaryButton(
                          text: _localizations.translate('next'),
                          onPressed:
                              state is AuthLoading ? () {} : _onNextPressed,
                        );
                      },
                    ),

                    SizedBox(height: 24.h),

                    // Divider Line
                    Container(
                      width: 225.w,
                      height: 1.h,
                      color: const Color(0xFF9F9F9F),
                    ),

                    SizedBox(height: 18.h),

                    // Secondary Button - تسجيل كمستفيد
                    SecondaryButton(
                      text: _localizations.translate('registerAsBeneficiary'),
                      onPressed: _onRegisterAsBeneficiaryPressed,
                    ),

                    SizedBox(height: 12.h),

                    // Secondary Button - تواصل معنا
                    SecondaryButton(
                      text: _localizations.translate('contactUs'),
                      onPressed: _onContactUsPressed,
                    ),

                    SizedBox(height: 32.h),
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
