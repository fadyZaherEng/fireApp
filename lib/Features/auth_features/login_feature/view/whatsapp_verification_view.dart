import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_states.dart';
import '../data/services/auth_api_service.dart';

class WhatsAppVerificationView extends StatefulWidget {
  final String phoneNumber;

  const WhatsAppVerificationView({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<WhatsAppVerificationView> createState() =>
      _WhatsAppVerificationViewState();
}

class _WhatsAppVerificationViewState extends State<WhatsAppVerificationView> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  Timer? _timer;
  int _remainingSeconds = 30;
  bool _canResend = false;
  late AuthCubit _authCubit;

  AppLocalizations get _localizations => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(AuthApiService());
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    _authCubit.close();
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 30;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _onVerifyPressed() {
    String code = _controllers.map((controller) => controller.text).join();
    if (code.length == 4) {
      print('Verification code entered: $code');
      _authCubit.verifyOtp("+966${widget.phoneNumber}", code);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localizations.translate('invalidVerificationCode')),
          backgroundColor: const Color(0xFFBA2D2D),
        ),
      );
    }
  }

  void _resendCode() {
    if (_canResend) {
      _authCubit.resendOtp(widget.phoneNumber);
      _startTimer();
    }
  }

  void _contactUs() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_localizations.translate('contactUsButton')),
        backgroundColor: const Color(0xFF1C4587),
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF1C4587),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  _localizations.translate('verifyingOtp'),
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
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return BlocProvider(
      create: (context) => _authCubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF0F9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(isRTL ? Icons.arrow_forward : Icons.arrow_back,
                color: const Color(0xFF1C4587)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) async {
            if (state is AuthLoading) {
              _showLoadingDialog();
            } else {
              _hideLoadingDialog();

              if (state is ResendOtpSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: const Color(0xFF25D366),
                  ),
                );
              } else if (state is ResendOtpFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: const Color(0xFFBA2D2D),
                  ),
                );
              } else if (state is VerifyOtpSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(_localizations.translate('verificationSuccess')),
                    backgroundColor: const Color(0xFF25D366),
                  ),
                );

                // Store authentication data
                await _authCubit.handleSuccessfulVerification(state);

                // Navigate to home
                Navigator.pushReplacementNamed(context, Routes.home);
              } else if (state is VerifyOtpFailure) {
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 16.h),

                    // Illustration
                    SizedBox(
                      width: 200.w,
                      height: 200.h,
                      child: Image.asset(
                        'assets/images/otp_verification.png',
                        width: 200.w,
                        height: 200.h,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200.w,
                            height: 200.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.message,
                              color: const Color(0xFF1C4587),
                              size: 80.sp,
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Instruction Text
                    Container(
                      constraints: BoxConstraints(maxWidth: 320.w),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _localizations
                                  .translate('otpVerificationInstruction'),
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.4,
                                color: const Color(0xFF333333),
                                fontFamily: isRTL ? 'Almarai' : 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text: '\n${widget.phoneNumber}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.4,
                                color: const Color(0xFF1C4587),
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // OTP Input Fields
                    _buildOTPFields(),

                    SizedBox(height: 24.h),

                    // Primary Button
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return Container(
                          width: double.infinity,
                          constraints: BoxConstraints(maxWidth: 320.w),
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed:
                                state is AuthLoading ? null : _onVerifyPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBA2D2D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _localizations.translate('nextButton'),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: isRTL ? 'Almarai' : 'Poppins',
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 24.h),

                    // Resend Code Text
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              _localizations.translate('didntReceiveAnyCode'),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF333333),
                                fontFamily: isRTL ? 'Almarai' : 'Poppins',
                              ),
                            ),
                            GestureDetector(
                              onTap: (_canResend && state is! AuthLoading)
                                  ? _resendCode
                                  : null,
                              child: Text(
                                _localizations.translate('resendAgain'),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: (_canResend && state is! AuthLoading)
                                      ? const Color(0xFF1C4587)
                                      : const Color(0xFF888888),
                                  fontFamily: isRTL ? 'Almarai' : 'Poppins',
                                  decoration:
                                      (_canResend && state is! AuthLoading)
                                          ? TextDecoration.underline
                                          : null,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 8.h),

                    // Timer
                    if (!_canResend)
                      Text(
                        _localizations.translate('requestNewCodeIn').replaceAll(
                            '{time}', _formatTime(_remainingSeconds)),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF888888),
                          fontFamily: isRTL ? 'Almarai' : 'Poppins',
                        ),
                      ),

                    SizedBox(height: 32.h),

                    // Contact Button
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 320.w),
                      height: 48.h,
                      child: OutlinedButton(
                        onPressed: _contactUs,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFF1C4587), width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          _localizations.translate('contactUsButton'),
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: const Color(0xFF1C4587),
                            fontFamily: isRTL ? 'Almarai' : 'Poppins',
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // Bottom indicator bar (iOS style)
                    Container(
                      width: 135.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2.5.r),
                      ),
                    ),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPFields() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            child: _buildOTPBox(index),
          );
        }),
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    return Container(
      width: 44.w,
      height: 52.h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFBA2D2D),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }

          // Auto-verify when all fields are filled
          if (index == 5 && value.isNotEmpty) {
            String code =
                _controllers.map((controller) => controller.text).join();
            if (code.length == 6) {
              _onVerifyPressed();
            }
          }
        },
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF333333),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }
}
