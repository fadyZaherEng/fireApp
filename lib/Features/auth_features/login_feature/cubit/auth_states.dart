import '../data/models/auth_models.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class SendOtpSuccess extends AuthState {
  final String message;

  SendOtpSuccess({required this.message});
}

class SendOtpFailure extends AuthState {
  final String error;

  SendOtpFailure({required this.error});
}

class ResendOtpSuccess extends AuthState {
  final String message;

  ResendOtpSuccess({required this.message});
}

class ResendOtpFailure extends AuthState {
  final String error;

  ResendOtpFailure({required this.error});
}

class VerifyOtpSuccess extends AuthState {
  final String token;
  final String status;
  final OnboardingData onboarding;
  final CompanyData companyData;
  final EmployeeDetails employeeDetails;

  VerifyOtpSuccess({
    required this.token,
    required this.status,
    required this.onboarding,
    required this.companyData,
    required this.employeeDetails,
  });
}

class VerifyOtpFailure extends AuthState {
  final String error;

  VerifyOtpFailure({required this.error});
}

class RegisterSuccess extends AuthState {
  final String token;
  final String status;
  final OnboardingData onboarding;
  final EmployeeDetails employeeDetails;

  RegisterSuccess({
    required this.token,
    required this.status,
    required this.onboarding,
    required this.employeeDetails,
  });
}

class RegisterFailure extends AuthState {
  final String error;

  RegisterFailure({required this.error});
}
