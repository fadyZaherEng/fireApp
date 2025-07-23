class CertificateInstallationResponse {
  final List<CertificateGroup> certificateGroups;

  CertificateInstallationResponse({
    required this.certificateGroups,
  });

  factory CertificateInstallationResponse.fromJson(List<dynamic> json) {
    return CertificateInstallationResponse(
      certificateGroups:
          json.map((item) => CertificateGroup.fromJson(item)).toList(),
    );
  }
}

class CertificateGroup {
  final List<CertificateItem> certificates;
  final int total;
  final Branch branch;
  final Provider provider;

  CertificateGroup({
    required this.certificates,
    required this.total,
    required this.branch,
    required this.provider,
  });

  factory CertificateGroup.fromJson(Map<String, dynamic> json) {
    return CertificateGroup(
      certificates: (json['certificates'] as List?)
              ?.map((item) => CertificateItem.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      branch: Branch.fromJson(json['branch'] ?? {}),
      provider: Provider.fromJson(json['provider'] ?? {}),
    );
  }
}

class CertificateItem {
  final ScheduleJob scheduleJob;
  final String file;
  final int createdAt;

  CertificateItem({
    required this.scheduleJob,
    required this.file,
    required this.createdAt,
  });

  factory CertificateItem.fromJson(Map<String, dynamic> json) {
    return CertificateItem(
      scheduleJob: ScheduleJob.fromJson(json['scheduleJob'] ?? {}),
      file: json['file'] ?? '',
      createdAt: json['createdAt'] ?? 0,
    );
  }

  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt);
}

class ScheduleJob {
  final ResponseEmployee responseEmployee;
  final String requestNumber;
  final String type;

  ScheduleJob({
    required this.responseEmployee,
    required this.requestNumber,
    required this.type,
  });

  factory ScheduleJob.fromJson(Map<String, dynamic> json) {
    return ScheduleJob(
      responseEmployee:
          ResponseEmployee.fromJson(json['responseEmployee'] ?? {}),
      requestNumber: json['requestNumber'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class ResponseEmployee {
  final String id;
  final String fullName;

  ResponseEmployee({
    required this.id,
    required this.fullName,
  });

  factory ResponseEmployee.fromJson(Map<String, dynamic> json) {
    return ResponseEmployee(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
    );
  }
}

class Branch {
  final String name;
  final String id;

  Branch({
    required this.name,
    required this.id,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      name: json['name'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}

class Provider {
  final String name;
  final String id;

  Provider({
    required this.name,
    required this.id,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      name: json['name'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}
