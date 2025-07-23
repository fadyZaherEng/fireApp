class SendOtpRequest {
  final String phoneNumber;

  SendOtpRequest({required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
    };
  }
}

class ResendOtpRequest {
  final String phoneNumber;

  ResendOtpRequest({required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
    };
  }
}

class VerifyOtpRequest {
  final String phoneNumber;
  final String otp;

  VerifyOtpRequest({
    required this.phoneNumber,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'code': otp,
    };
  }
}

class OtpResponse {
  final String message;

  OtpResponse({required this.message});

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      message: json['message'] ?? '',
    );
  }
}

class OnboardingData {
  final bool employees;
  final bool branches;
  final bool termsAndConditions;

  OnboardingData({
    required this.employees,
    required this.branches,
    required this.termsAndConditions,
  });

  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      employees: json['employees'] ?? false,
      branches: json['branches'] ?? false,
      termsAndConditions: json['termsAndConditions'] ?? false,
    );
  }
}

class CompanyData {
  final String companyName;
  final String? image;
  final String email;

  CompanyData({
    required this.companyName,
    this.image,
    required this.email,
  });

  factory CompanyData.fromJson(Map<String, dynamic> json) {
    return CompanyData(
      companyName: json['companyName'] ?? '',
      image: json['image'],
      email: json['email'] ?? '',
    );
  }
}

class EmployeeDetails {
  final String fullName;
  final String? image;
  final String jobTitle;

  EmployeeDetails({
    required this.fullName,
    this.image,
    required this.jobTitle,
  });

  factory EmployeeDetails.fromJson(Map<String, dynamic> json) {
    return EmployeeDetails(
      fullName: json['fullName'] ?? '',
      image: json['image'],
      jobTitle: json['jobTitle'] ?? '',
    );
  }
}

class VerifyOtpResponse {
  final String token;
  final String status;
  final OnboardingData onboarding;
  final CompanyData companyData;
  final EmployeeDetails employeeDetails;

  VerifyOtpResponse({
    required this.token,
    required this.status,
    required this.onboarding,
    required this.companyData,
    required this.employeeDetails,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      token: json['token'] ?? '',
      status: json['status'] ?? '',
      onboarding: OnboardingData.fromJson(json['onboarding'] ?? {}),
      companyData: CompanyData.fromJson(json['companyData'] ?? {}),
      employeeDetails: EmployeeDetails.fromJson(json['employeeDetails'] ?? {}),
    );
  }
}

class VerifyOtpErrorResponse {
  final String message;

  VerifyOtpErrorResponse({required this.message});

  factory VerifyOtpErrorResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpErrorResponse(
      message: json['message'] ?? 'Verification failed',
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });
}

class LocationData {
  final String type;
  final List<double> coordinates;

  LocationData({
    required this.type,
    required this.coordinates,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(json['coordinates'] ?? []),
    );
  }
}

class RegisterRequest {
  final String companyName;
  final String email;
  final String phoneNumber;
  final String commercialRegistrationNumber;
  final String facilityActivity;
  final LocationData location;
  final String address;

  RegisterRequest({
    required this.companyName,
    required this.email,
    required this.phoneNumber,
    required this.commercialRegistrationNumber,
    required this.facilityActivity,
    required this.location,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'email': email,
      'phoneNumber': phoneNumber,
      'commercialRegistrationNumber': commercialRegistrationNumber,
      'facilityActivity': facilityActivity,
      'location': location.toJson(),
      'address': address,
    };
  }
}

class RegisterResponse {
  final String token;
  final String status;
  final OnboardingData onboarding;
  final EmployeeDetails employeeDetails;

  RegisterResponse({
    required this.token,
    required this.status,
    required this.onboarding,
    required this.employeeDetails,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      token: json['token'] ?? '',
      status: json['status'] ?? '',
      onboarding: OnboardingData.fromJson(json['onboarding'] ?? {}),
      employeeDetails: EmployeeDetails.fromJson(json['employeeDetails'] ?? {}),
    );
  }
}

class CheckAuthResponse {
  final String? status;
  final OnboardingData? onboarding;
  final CompanyData? companyData;

  CheckAuthResponse({
    this.status,
    this.onboarding,
    this.companyData,
  });

  factory CheckAuthResponse.fromJson(Map<String, dynamic> json) {
    return CheckAuthResponse(
      status: json['status'],
      onboarding: json['onboarding'] != null
          ? OnboardingData.fromJson(json['onboarding'])
          : null,
      companyData: json['companyData'] != null
          ? CompanyData.fromJson(json['companyData'])
          : null,
    );
  }
}
