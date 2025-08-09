import 'package:safetyZone/Features/branch_management/data/models/product_item_model.dart';

class ServiceProvider {
  final String id;
  final String name;
  final String nameAr;
  final String logo;
  final double rating;
  final String description;
  final String descriptionAr;
  final bool isRecommended;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final String? bankAccountNumber;
  final String? bankName;
  final String? commercialRegistrationNumber;
  final bool? isVerified;
  final LocationData? location;

  const ServiceProvider({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.logo,
    required this.rating,
    required this.description,
    required this.descriptionAr,
    this.isRecommended = false,
    this.email,
    this.phoneNumber,
    this.address,
    this.bankAccountNumber,
    this.bankName,
    this.commercialRegistrationNumber,
    this.isVerified,
    this.location,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['companyName'] ?? json['name'] ?? '',
      nameAr:
          json['companyName'] ?? json['name_ar'] ?? json['companyName'] ?? '',
      logo: json['image'] ?? json['logo'] ?? '',
      rating: 4.5, // Default rating since it's not in the API response
      description: json['description'] ?? '',
      descriptionAr: json['description_ar'] ?? json['description'] ?? '',
      isRecommended: json['is_recommended'] ?? false,
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      bankAccountNumber: json['bankAccountNumber'],
      bankName: json['bankName'],
      commercialRegistrationNumber: json['commercialRegistrationNumber'],
      isVerified: json['isVerified'],
      location: json['location'] != null
          ? LocationData.fromJson(json['location'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'logo': logo,
      'rating': rating,
      'description': description,
      'description_ar': descriptionAr,
      'is_recommended': isRecommended,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'bankAccountNumber': bankAccountNumber,
      'bankName': bankName,
      'commercialRegistrationNumber': commercialRegistrationNumber,
      'isVerified': isVerified,
      'location': location?.toJson(),
    };
  }
}

class LocationData {
  final String type;
  final List<double> coordinates;

  const LocationData({
    required this.type,
    required this.coordinates,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(
          json['coordinates']?.map((x) => x.toDouble()) ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0.0;
  double get latitude => coordinates.length > 1 ? coordinates[1] : 0.0;
}

class CertificateType {
  final String id;
  final String name;
  final String nameAr;
  final String icon;
  final String description;
  final String descriptionAr;

  const CertificateType({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.icon,
    required this.description,
    required this.descriptionAr,
  });
}

class AlertDevice {
  final String type;
  final int count;

  const AlertDevice({
    required this.type,
    required this.count,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'count': count,
    };
  }
}

class FireExtinguisher {
  final String type;
  final int count;

  const FireExtinguisher({
    required this.type,
    required this.count,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'count': count,
    };
  }
}

// Certificate Installation Request Models
class CertificateInstallationRequest {
  final String branch;
  final String requestType;
  final List<ProviderSelection>? providers;

  const CertificateInstallationRequest({
    required this.branch,
    required this.requestType,
    this.providers,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'branch': branch,
      'requestType': requestType,
    };

    // Only include providers if it's not null and not empty
    if (providers != null && providers!.isNotEmpty) {
      json['providers'] = providers!.map((p) => p.toJson()).toList();
    }

    return json;
  }
}

class ProviderSelection {
  final String provider;

  const ProviderSelection({
    required this.provider,
  });

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
    };
  }
}

// Certificate Installation Response Models
class CertificateInstallationResponse {
  final String consumer;
  final String branch;
  final String requestNumber;
  final List<ProviderStatus> providers;
  final String systemType;
  final double space;
  final List<RequestItem> items;
  final String requestType;
  final String status;
  final int createdAt;
  final String id;

  const CertificateInstallationResponse({
    required this.consumer,
    required this.branch,
    required this.requestNumber,
    required this.providers,
    required this.systemType,
    required this.space,
    required this.items,
    required this.requestType,
    required this.status,
    required this.createdAt,
    required this.id,
  });

  factory CertificateInstallationResponse.fromJson(Map<String, dynamic> json) {
    return CertificateInstallationResponse(
      consumer: json['consumer'] ?? '',
      branch: json['branch'] ?? '',
      requestNumber: json['requestNumber'] ?? '',
      providers: (json['providers'] as List<dynamic>? ?? [])
          .map((provider) => ProviderStatus.fromJson(provider))
          .toList(),
      systemType: json['systemType'] ?? '',
      space: (json['space'] ?? 0).toDouble(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => RequestItem.fromJson(item))
          .toList(),
      requestType: json['requestType'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? 0,
      id: json['_id'] ?? '',
    );
  }
}

class ProviderStatus {
  final String provider;
  final String status;
  final String id;

  const ProviderStatus({
    required this.provider,
    required this.status,
    required this.id,
  });

  factory ProviderStatus.fromJson(Map<String, dynamic> json) {
    return ProviderStatus(
      provider: json['provider'] ?? '',
      status: json['status'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}

class RequestItem {
  final String itemId;
  final int quantity;
  final String id;

  const RequestItem({
    required this.itemId,
    required this.quantity,
    required this.id,
  });

  factory RequestItem.fromJson(Map<String, dynamic> json) {
    String itemId = '';
    if (json['item_id'] is String) {
      itemId = json['item_id'] ?? '';
    } else if (json['item_id'] is Map<String, dynamic>) {
      itemId = json['item_id']['_id'] ?? '';
    }

    return RequestItem(
      itemId: itemId,
      quantity: json['quantity'] ?? 0,
      id: json['_id'] ?? '',
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

class Branch {
  final String id;
  final String branchName;
  final String address;
  final String mall;
  final double space;
  final String systemType;
  final List<double> coordinates;

  const Branch({
    required this.id,
    required this.branchName,
    required this.address,
    required this.mall,
    required this.space,
    required this.systemType,
    required this.coordinates,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    final coordinates = (location['coordinates'] as List<dynamic>?)
            ?.map((coord) => (coord as num).toDouble())
            .toList() ??
        [0.0, 0.0];

    return Branch(
      id: json['_id'] ?? '',
      branchName: json['branchName'] ?? '',
      address: json['address'] ?? '',
      mall: json['mall'] ?? '',
      space: (json['space'] ?? 0).toDouble(),
      systemType: json['systemType'] ?? '',
      coordinates: coordinates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'branchName': branchName,
      'address': address,
      'mall': mall,
      'space': space,
      'systemType': systemType,
      'location': {
        'type': 'Point',
        'coordinates': coordinates,
      },
    };
  }
}

// Models for detailed branch information with items
class BranchItem {
  final String id;
  final ItemDetails itemDetails;
  final int quantity;

  const BranchItem({
    required this.id,
    required this.itemDetails,
    required this.quantity,
  });

  factory BranchItem.fromJson(Map<String, dynamic> json) {
    return BranchItem(
      id: json['_id'] ?? '',
      itemDetails: ItemDetails.fromJson(json['item_id'] ?? {}),
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'item_id': itemDetails.toJson(),
      'quantity': quantity,
    };
  }
}

class ItemDetails {
  final String id;
  final ItemName itemName;
  final String itemCode;
  final String image;
  final String supplierName;
  final double supplyPrice;
  final bool isDeleted;
  final String admin;
  final String type;
  final String? alarmType;
  final String? subCategory;
  final String createdAt;
  final String updatedAt;

  const ItemDetails({
    required this.id,
    required this.itemName,
    required this.itemCode,
    required this.image,
    required this.supplierName,
    required this.supplyPrice,
    required this.isDeleted,
    required this.admin,
    required this.type,
    this.alarmType,
    this.subCategory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItemDetails.fromJson(Map<String, dynamic> json) {
    return ItemDetails(
      id: json['_id'] ?? '',
      itemName: ItemName.fromJson(json['itemName'] ?? {}),
      itemCode: json['itemCode'] ?? '',
      image: json['image'] ?? '',
      supplierName: json['supplierName'] ?? '',
      supplyPrice: (json['supplyPrice'] ?? 0).toDouble(),
      isDeleted: json['isDeleted'] ?? false,
      admin: json['admin'] ?? '',
      type: json['type'] ?? '',
      alarmType: json['alarmType'],
      subCategory: json['subCategory'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'itemName': itemName.mapToJson(),
      'itemCode': itemCode,
      'image': image,
      'supplierName': supplierName,
      'supplyPrice': supplyPrice,
      'isDeleted': isDeleted,
      'admin': admin,
      'type': type,
      'alarmType': alarmType,
      'subCategory': subCategory,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class WorkingDay {
  final String id;
  final String day;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const WorkingDay({
    required this.id,
    required this.day,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  factory WorkingDay.fromJson(Map<String, dynamic> json) {
    return WorkingDay(
      id: json['_id'] ?? '',
      day: json['day'] ?? '',
      startHour: json['startHour'] ?? 0,
      startMinute: json['startMinute'] ?? 0,
      endHour: json['endHour'] ?? 0,
      endMinute: json['endMinute'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'day': day,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
    };
  }
}

// class BranchDetails {
//   final String id;
//   final String branchName;
//   final String employee;
//   final String address;
//   final String mall;
//   final double space;
//   final String systemType;
//   final String consumer;
//   final List<double> coordinates;
//   final List<WorkingDay> workingDays;
//   final List<BranchItem> items;
//   final int createdAt;
//
//   const BranchDetails({
//     required this.id,
//     required this.branchName,
//     required this.employee,
//     required this.address,
//     required this.mall,
//     required this.space,
//     required this.systemType,
//     required this.consumer,
//     required this.coordinates,
//     required this.workingDays,
//     required this.items,
//     required this.createdAt,
//   });
//
//   factory BranchDetails.fromJson(Map<String, dynamic> json) {
//     final location = json['location'] ?? {};
//     final coordinates = (location['coordinates'] as List<dynamic>?)
//             ?.map((coord) => (coord as num).toDouble())
//             .toList() ??
//         [0.0, 0.0];
//
//     return BranchDetails(
//       id: json['_id'] ?? '',
//       branchName: json['branchName'] ?? '',
//       employee: json['employee'] ?? '',
//       address: json['address'] ?? '',
//       mall: json['mall'] ?? '',
//       space: (json['space'] ?? 0).toDouble(),
//       systemType: json['systemType'] ?? '',
//       consumer: json['consumer'] ?? '',
//       coordinates: coordinates,
//       workingDays: (json['workingDays'] as List<dynamic>? ?? [])
//           .map((day) => WorkingDay.fromJson(day))
//           .toList(),
//       items: (json['items'] as List<dynamic>? ?? [])
//           .map((item) => BranchItem.fromJson(item))
//           .toList(),
//       createdAt: json['createdAt'] ?? 0,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'branchName': branchName,
//       'employee': employee,
//       'address': address,
//       'mall': mall,
//       'space': space,
//       'systemType': systemType,
//       'consumer': consumer,
//       'location': {
//         'type': 'Point',
//         'coordinates': coordinates,
//       },
//       'workingDays': workingDays.map((day) => day.toJson()).toList(),
//       'items': items.map((item) => item.toJson()).toList(),
//       'createdAt': createdAt,
//     };
//   }
// }
class BranchDetails {
  final String id;
  final String branchName;
  final String employee;
  final String address;
  final String mall;
  final double space;
  final String systemType;
  final String consumer;
  final List<double> coordinates;
  final List<WorkingDay> workingDays;
  final List<BranchItem> alarmItem;
  final List<BranchItem> fireSystemItem;
  final List<BranchItem> fireExtinguisherItem;
  final int createdAt;

  const BranchDetails({
    required this.id,
    required this.branchName,
    required this.employee,
    required this.address,
    required this.mall,
    required this.space,
    required this.systemType,
    required this.consumer,
    required this.coordinates,
    required this.workingDays,
    required this.fireSystemItem,
    required this.fireExtinguisherItem,
    required this.alarmItem,
    required this.createdAt,
  });

  factory BranchDetails.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    final coordinates = (location['coordinates'] as List<dynamic>?)
        ?.map((coord) => (coord as num).toDouble())
        .toList() ??
        [0.0, 0.0];

    return BranchDetails(
      id: json['_id'] ?? '',
      branchName: json['branchName'] ?? '',
      employee: json['employee'] ?? '',
      address: json['address'] ?? '',
      mall: json['mall'] ?? '',
      space: (json['space'] ?? 0).toDouble(),
      systemType: json['systemType'] ?? '',
      consumer: json['consumer'] ?? '',
      coordinates: coordinates,
      workingDays: (json['workingDays'] as List<dynamic>? ?? [])
          .map((day) => WorkingDay.fromJson(day))
          .toList(),
      alarmItem: (json['alarmItem'] as List<dynamic>? ?? [])
          .map((item) => BranchItem.fromJson(item))
          .toList(),
      fireSystemItem: (json['fireSystemItem'] as List<dynamic>? ?? [])
          .map((item) => BranchItem.fromJson(item))
          .toList(),
      fireExtinguisherItem: (json['fireExtinguisherItem'] as List<dynamic>? ?? [])
          .map((item) => BranchItem.fromJson(item))
          .toList(),
      createdAt: json['createdAt'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'branchName': branchName,
      'employee': employee,
      'address': address,
      'mall': mall,
      'space': space,
      'systemType': systemType,
      'consumer': consumer,
      'location': {
        'type': 'Point',
        'coordinates': coordinates,
      },
      'workingDays': workingDays.map((day) => day.toJson()).toList(),
      'alarmItem': alarmItem.map((item) => item.toJson()).toList(),
      'fireSystemItem': fireSystemItem.map((item) => item.toJson()).toList(),
      'fireExtinguisherItem': fireExtinguisherItem.map((item) => item.toJson()).toList(),
      'createdAt': createdAt,
    };
  }
}
