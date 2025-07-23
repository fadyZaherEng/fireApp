class TermsClause {
  final String text;
  final String? id;

  TermsClause({
    required this.text,
    this.id,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'text': text,
    };
    if (id != null) {
      json['_id'] = id!;
    }
    return json;
  }

  factory TermsClause.fromJson(Map<String, dynamic> json) {
    return TermsClause(
      text: json['text'] ?? '',
      id: json['_id'],
    );
  }
}

class CreateTermsRequest {
  final String employee;
  final String responsibleEmployeeName;
  final List<TermsClause> clauses;
  final bool? isFirstTime;

  CreateTermsRequest({
    required this.employee,
    required this.responsibleEmployeeName,
    required this.clauses,
    this.isFirstTime,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'employee': employee,
      'responsibleEmployeeName': responsibleEmployeeName,
      'clauses': clauses.map((clause) => clause.toJson()).toList(),
    };

    if (isFirstTime != null) {
      json['isFirstTime'] = isFirstTime!;
    }

    return json;
  }
}

class TermsAndConditionsData {
  final String id;
  final String employee;
  final String? company;
  final String responsibleEmployeeName;
  final List<TermsClause> clauses;
  final int? createdAt;
  final int? version;

  TermsAndConditionsData({
    required this.id,
    required this.employee,
    this.company,
    required this.responsibleEmployeeName,
    required this.clauses,
    this.createdAt,
    this.version,
  });

  factory TermsAndConditionsData.fromJson(Map<String, dynamic> json) {
    return TermsAndConditionsData(
      id: json['_id'] ?? '',
      employee: json['employee'] ?? '',
      company: json['company'],
      responsibleEmployeeName: json['responsibleEmployeeName'] ?? '',
      clauses: (json['clauses'] as List<dynamic>? ?? [])
          .map((clause) => TermsClause.fromJson(clause))
          .toList(),
      createdAt: json['createdAt'],
      version: json['__v'],
    );
  }
}

class TermsAndConditionsResponse {
  final bool success;
  final TermsAndConditionsData data;

  TermsAndConditionsResponse({
    required this.success,
    required this.data,
  });

  factory TermsAndConditionsResponse.fromJson(Map<String, dynamic> json) {
    return TermsAndConditionsResponse(
      success: json['success'] ?? false,
      data: TermsAndConditionsData.fromJson(json['data'] ?? {}),
    );
  }
}

class Employee {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? profileImage;
  final String jobTitle;
  final String permission;
  final String employeeType;
  final bool isDeleted;

  Employee({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.profileImage,
    required this.jobTitle,
    required this.permission,
    required this.employeeType,
    required this.isDeleted,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profileImage: json['profileImage'],
      jobTitle: json['jobTitle'] ?? '',
      permission: json['permission'] ?? '',
      employeeType: json['employeeType'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
