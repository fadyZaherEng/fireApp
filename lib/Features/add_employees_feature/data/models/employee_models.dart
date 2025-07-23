import 'dart:io';

class AddEmployeeRequest {
  final String fullName;
  final String phoneNumber;
  final String permission;
  final String profileImage;
  final String jobTitle;

  AddEmployeeRequest({
    required this.fullName,
    required this.phoneNumber,
    required this.permission,
    required this.profileImage,
    required this.jobTitle,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'permission': permission,
      'profileImage': profileImage,
      'jobTitle': jobTitle,
    };
  }
}

class AddEmployeeResponse {
  final String message;
  final Map<String, dynamic>? employeeData;

  AddEmployeeResponse({
    required this.message,
    this.employeeData,
  });

  factory AddEmployeeResponse.fromJson(Map<String, dynamic> json) {
    return AddEmployeeResponse(
      message: json['message'] ?? 'Employee added successfully',
      employeeData: json['employeeData'],
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

class Employee {
  final String? id;
  final String fullName;
  final String phoneNumber;
  final String permission;
  final String profileImage;
  final String jobTitle;
  final String selectedRole;
  final String selectedCountry;
  final File? selectedImage;

  Employee({
    this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.permission,
    required this.profileImage,
    required this.jobTitle,
    required this.selectedRole,
    required this.selectedCountry,
    this.selectedImage,
  });

  Employee copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? permission,
    String? profileImage,
    String? jobTitle,
    String? selectedRole,
    String? selectedCountry,
    File? selectedImage,
  }) {
    return Employee(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      permission: permission ?? this.permission,
      profileImage: profileImage ?? this.profileImage,
      jobTitle: jobTitle ?? this.jobTitle,
      selectedRole: selectedRole ?? this.selectedRole,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}
