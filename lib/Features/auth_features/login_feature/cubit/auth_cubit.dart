import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../data/services/auth_api_service.dart';
import '../data/models/auth_models.dart';
import 'auth_states.dart';
import '../../../../core/services/shared_pref/shared_pref.dart';
import '../../../../core/services/shared_pref/pref_keys.dart';
import 'dart:convert';

class AuthCubit extends Cubit<AuthState> {
  final AuthApiService _authApiService;
  final Logger _logger = Logger();

  AuthCubit(this._authApiService) : super(AuthInitial());

  Future<void> sendOtp(String phoneNumber) async {
    _logger.i('🎯 AuthCubit: Sending OTP to $phoneNumber');
    emit(AuthLoading());

    try {
      final request = SendOtpRequest(phoneNumber: phoneNumber);
      final response = await _authApiService.sendOtp(request);

      if (response.success) {
        _logger.i('✅ AuthCubit: OTP sent successfully');
        emit(SendOtpSuccess(message: response.message));
      } else {
        _logger.w('⚠️ AuthCubit: Send OTP failed - ${response.message}');
        emit(SendOtpFailure(error: response.message));
      }
    } catch (e) {
      _logger.e('💥 AuthCubit: Unexpected error in sendOtp - $e');
      emit(SendOtpFailure(error: 'An unexpected error occurred'));
    }
  }

  Future<void> resendOtp(String phoneNumber) async {
    _logger.i('🔄 AuthCubit: Resending OTP to $phoneNumber');
    emit(AuthLoading());

    try {
      final request = ResendOtpRequest(phoneNumber: phoneNumber);
      final response = await _authApiService.resendOtp(request);

      if (response.success) {
        _logger.i('✅ AuthCubit: OTP resent successfully');
        emit(ResendOtpSuccess(message: response.message));
      } else {
        _logger.w('⚠️ AuthCubit: Resend OTP failed - ${response.message}');
        emit(ResendOtpFailure(error: response.message));
      }
    } catch (e) {
      _logger.e('💥 AuthCubit: Unexpected error in resendOtp - $e');
      emit(ResendOtpFailure(error: 'Failed to resend OTP'));
    }
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    _logger.i('🔍 AuthCubit: Verifying OTP for $phoneNumber');
    emit(AuthLoading());

    try {
      final request = VerifyOtpRequest(phoneNumber: phoneNumber, otp: otp);
      final response = await _authApiService.verifyOtp(request);

      if (response.success && response.data != null) {
        _logger.i('✅ AuthCubit: OTP verified successfully');
        final data = response.data!;
        emit(VerifyOtpSuccess(
          token: data.token,
          status: data.status,
          onboarding: data.onboarding,
          companyData: data.companyData,
          employeeDetails: data.employeeDetails,
        ));
      } else {
        _logger.w('⚠️ AuthCubit: Verify OTP failed - ${response.message}');
        emit(VerifyOtpFailure(error: response.message));
      }
    } catch (e) {
      _logger.e('💥 AuthCubit: Unexpected error in verifyOtp - $e');
      emit(VerifyOtpFailure(error: 'An unexpected error occurred'));
    }
  }

  Future<void> register(RegisterRequest request) async {
    _logger.i('📝 AuthCubit: Registering new beneficiary');
    emit(AuthLoading());

    try {
      final response = await _authApiService.register(request);

      if (response.success && response.data != null) {
        _logger.i('✅ AuthCubit: Registration successful');
        final data = response.data!;
        emit(RegisterSuccess(
          token: data.token,
          status: data.status,
          onboarding: data.onboarding,
          employeeDetails: data.employeeDetails,
        ));
      } else {
        _logger.w('⚠️ AuthCubit: Registration failed - ${response.message}');
        emit(RegisterFailure(error: response.message));
      }
    } catch (e) {
      _logger.e('💥 AuthCubit: Unexpected error in register - $e');
      emit(RegisterFailure(error: 'An unexpected error occurred'));
    }
  }

  // Store authentication data securely
  Future<void> handleSuccessfulVerification(VerifyOtpSuccess state) async {
    _logger.i('🚀 Handling successful verification...');
    _logger.d('Token: ${state.token}');
    _logger.d('Status: ${state.status}');
    _logger.d('Company: ${state.companyData.companyName}');
    _logger.d('Employee: ${state.employeeDetails.fullName}');
    _logger.d('Onboarding Status: ${state.onboarding}');

    try {
      // Store authentication data
      await SharedPref().setString(PrefKeys.token, state.token);
      await SharedPref().setBool(PrefKeys.isAuthenticated, true);

      // Store user data for home screen
      await SharedPref().setString('user_status', state.status);
      await SharedPref().setString(
          'user_onboarding',
          jsonEncode({
            'employees': state.onboarding.employees,
            'branches': state.onboarding.branches,
            'termsAndConditions': state.onboarding.termsAndConditions,
          }));
      await SharedPref().setString(
          'user_company',
          jsonEncode({
            'companyName': state.companyData.companyName,
            'image': state.companyData.image,
            'email': state.companyData.email,
          }));
      await SharedPref().setString(
          'user_employee',
          jsonEncode({
            'fullName': state.employeeDetails.fullName,
            'image': state.employeeDetails.image,
            'jobTitle': state.employeeDetails.jobTitle,
          }));

      _logger.i('✅ Authentication data stored successfully');
    } catch (e) {
      _logger.e('💥 Error storing authentication data: $e');
    }
  }

  // Store authentication data for registration
  Future<void> handleSuccessfulRegistration(RegisterSuccess state) async {
    _logger.i('🚀 Handling successful registration...');
    _logger.d('Token: ${state.token}');
    _logger.d('Status: ${state.status}');
    _logger.d('Employee: ${state.employeeDetails.fullName}');
    _logger.d('Onboarding Status: ${state.onboarding}');

    try {
      // Store authentication data
      await SharedPref().setString(PrefKeys.token, state.token);
      await SharedPref().setBool(PrefKeys.isAuthenticated, true);

      // Store user data for home screen
      await SharedPref().setString('user_status', state.status);
      await SharedPref().setString(
          'user_onboarding',
          jsonEncode({
            'employees': state.onboarding.employees,
            'branches': state.onboarding.branches,
            'termsAndConditions': state.onboarding.termsAndConditions,
          }));
      await SharedPref().setString(
          'user_employee',
          jsonEncode({
            'fullName': state.employeeDetails.fullName,
            'image': state.employeeDetails.image,
            'jobTitle': state.employeeDetails.jobTitle,
          }));

      _logger.i('✅ Registration data stored successfully');
    } catch (e) {
      _logger.e('💥 Error storing registration data: $e');
    }
  }

  // Check if user is already authenticated
  Future<bool> isUserAuthenticated() async {
    final token = SharedPref().getString(PrefKeys.token);
    final isAuthenticated = SharedPref().getBool(PrefKeys.isAuthenticated);

    _logger.d('🔍 Token exists: ${token != null}');
    _logger.d('🔍 Is authenticated: $isAuthenticated');

    return token != null && isAuthenticated;
  }

  // Logout user
  Future<void> logout() async {
    _logger.i('🚪 Logging out user');

    try {
      // Clear all authentication data
      await SharedPref().removePreference(PrefKeys.token);
      await SharedPref().removePreference(PrefKeys.isAuthenticated);
      await SharedPref().removePreference('user_status');
      await SharedPref().removePreference('user_onboarding');
      await SharedPref().removePreference('user_company');
      await SharedPref().removePreference('user_employee');

      _logger.i('✅ Logout successful');
      emit(AuthInitial());
    } catch (e) {
      _logger.e('💥 Error during logout: $e');
    }
  }

  void resetState() {
    _logger.d('🔄 AuthCubit: Resetting state');
    emit(AuthInitial());
  }
}
