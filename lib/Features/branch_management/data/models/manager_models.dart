class Manager {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? profileImage;
  final String jobTitle;
  final String permission;

  Manager({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.profileImage,
    required this.jobTitle,
    required this.permission,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profileImage: json['profileImage'],
      jobTitle: json['jobTitle'] ?? '',
      permission: json['permission'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'jobTitle': jobTitle,
      'permission': permission,
    };
  }
}

class ManagerListResponse {
  final List<Manager> managers;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  ManagerListResponse({
    required this.managers,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });
  factory ManagerListResponse.fromJson(Map<String, dynamic> json) {
    // Parse the actual API response structure
    final List<dynamic> resultList = json['result'] as List<dynamic>? ?? [];
    final int count = json['count'] as int? ?? 0;

    return ManagerListResponse(
      managers: resultList
          .map((item) => Manager.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: count,
      currentPage: 1, // Since pagination info is not provided in the API
      totalPages: 1, // We'll assume single page for now
      hasNextPage: false, // No pagination info available
      hasPrevPage: false, // No pagination info available
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
